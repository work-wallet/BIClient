using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using WorkWallet.BI.ClientCore.Exceptions;
using WorkWallet.BI.ClientCore.Interfaces.Services;
using WorkWallet.BI.ClientCore.Models;
using WorkWallet.BI.ClientCore.Options;
using WorkWallet.BI.ClientCore.Utils;

namespace WorkWallet.BI.ClientServices.Processor;

public class ProcessorService(
    ILogger<ProcessorService> logger,
    IOptions<ProcessorServiceOptions> serviceOptions,
    IDataStoreService dataStore,
    IProgressService progressService,
    IWalletContextService walletContextService,
    IApiClient apiClient,
    IResponseParser responseParser) : IProcessorService
{
    private readonly ProcessorServiceOptions _serviceOptions = serviceOptions.Value;

    public async Task RunAsync(CancellationToken cancellationToken = default)
    {
        // loop (supporting multiple wallets)
        foreach (var agentWallet in _serviceOptions.AgentWallets)
        {
            cancellationToken.ThrowIfCancellationRequested();

            WalletContext walletContext = await walletContextService.GetWalletContextAsync(agentWallet.WalletId, cancellationToken);
            logger.LogInformation("Start process for wallet {wallet}", agentWallet.WalletId);
            progressService.WriteWallet(walletContext.Name.Trim(), walletContext.DataRegion);

            // if no dataTypes are provided, then use all the ones that we know about
            string[] dataSets = _serviceOptions.DataSets.Length > 0 ? _serviceOptions.DataSets : [.. DataSets.Entries.Keys];

            // repeat for all the dataSets selected
            foreach (string dataSet in dataSets)
            {
                cancellationToken.ThrowIfCancellationRequested();

                var entry = DataSets.Entries.FirstOrDefault(dt => dt.Key.Equals(dataSet, StringComparison.OrdinalIgnoreCase));

                // the requested dataType is not in our lookup of expected types
                if (entry.Equals(default(KeyValuePair<string, string>)))
                {
                    throw new UnsupportedDataTypeException(dataSet);
                }

                // process for this dataType
                await ProcessAsync(walletContext, entry.Key, entry.Value, cancellationToken);
            }
        }
    }

    private async Task ProcessAsync(
        WalletContext walletContext,
        string dataType,
        string logType,
        CancellationToken cancellationToken = default)
    {
        logger.LogDebug("Processing {dataType} for wallet {wallet}", dataType, walletContext.Id);

        var processingState = await InitializeProcessingAsync(walletContext, logType, dataType);
        var result = await ProcessPagesAsync(walletContext, dataType, processingState, cancellationToken);
        await FinalizeProcessingAsync(walletContext, logType, dataType, result);
    }

    private async Task<ProcessingState> InitializeProcessingAsync(WalletContext walletContext, string logType, string dataType)
    {
        // obtain our last database change tracking synchronization number (or null if this is the first sync)
        long? lastSynchronizationVersion = await dataStore.GetLastSynchronizationVersionAsync(walletContext.Id, logType);

        if (!lastSynchronizationVersion.HasValue)
        {
            // no last synchronization data, treat this as a reset and delete all data
            await dataStore.ResetAsync(walletContext.Id, dataType);
        }

        return new ProcessingState(lastSynchronizationVersion);
    }

    private async Task<ProcessingResult> ProcessPagesAsync(
        WalletContext walletContext, 
        string dataType, 
        ProcessingState state, 
        CancellationToken cancellationToken)
    {
        progressService.StartShowProgress(dataType, !state.LastSynchronizationVersion.HasValue);
        
        int pageNumber = 0;
        long? firstPageSyncVersion = null;
        Context context;
        
        do
        {
            cancellationToken.ThrowIfCancellationRequested();
            
            var pageResult = await ProcessSinglePageAsync(walletContext, dataType, state.LastSynchronizationVersion, ++pageNumber, cancellationToken);
            context = pageResult.Context;
            
            if (pageNumber == 1)
                firstPageSyncVersion = context.SynchronizationVersion;
                
            if (context.Count > 0)
            {
                cancellationToken.ThrowIfCancellationRequested();
                await dataStore.LoadAsync(dataType, pageResult.Json);
            }
            else
            {
                logger.LogDebug("No records to load");
            }
            
        } while (PaginationLogic.ShouldContinuePaging(context));
        
        progressService.EndShowProgress(context.FullCount);
        
        return new ProcessingResult(firstPageSyncVersion!.Value, context.FullCount);
    }

    private async Task<PageResult> ProcessSinglePageAsync(
        WalletContext walletContext,
        string dataType,
        long? lastSynchronizationVersion,
        int pageNumber,
        CancellationToken cancellationToken)
    {
        // call the Work Wallet API end point and obtain the results as JSON
        string json = await apiClient.FetchDataPageAsync(walletContext, dataType, lastSynchronizationVersion, pageNumber, cancellationToken);

        progressService.ShowProgress();

        try
        {
            // extract and validate the context information
            var context = responseParser.ParseContext(json);
            responseParser.ValidateResponse(context, lastSynchronizationVersion, walletContext.Id, dataType);

            LogPageDetails(dataType, json, context);

            bool hasMorePages = PaginationLogic.ShouldContinuePaging(context);
            return new PageResult(context, json, hasMorePages);
        }
        catch (JsonParseException ex)
        {
            // Enrich with wallet context for better error reporting
            throw new DeserializeResponseException(ex.TargetType, ex.Message, walletContext.Id, dataType);
        }
    }

    private void LogPageDetails(string dataType, string json, Context context)
    {
        logger.LogDebug("API for {DataType} returned JSON of length {Length}", dataType, json.Length);
        logger.LogDebug("Count: {Count}", context.Count);
        logger.LogDebug("FullCount: {FullCount}", context.FullCount);
        logger.LogDebug("LastSynchronizationVersion: {LastSynchronizationVersion}", context.LastSynchronizationVersion);
        logger.LogDebug("SynchronizationVersion: {SynchronizationVersion}", context.SynchronizationVersion);
        logger.LogDebug("PageNumber: {PageNumber}, PageSize: {PageSize}", context.PageNumber, context.PageSize);
    }

    private async Task FinalizeProcessingAsync(WalletContext walletContext, string logType, string dataType, ProcessingResult result)
    {
        // update our change detection / logging table, so we only fetch new and changed data next time
        // (must do this, even if no rows are obtained as lastSynchronizationVersion can otherwise become invalid)
        // use the SynchronizationVersion from the first page to avoid missing changes that occur during paging
        await dataStore.UpdateLastSyncAsync(walletContext.Id, logType, result.SynchronizationVersion, result.TotalRecords);

        if (result.TotalRecords > 0)
        {
            logger.LogDebug("A total of {FullCount} {DataType} records received.", result.TotalRecords, dataType);

            // perform any post processing
            await dataStore.PostProcessAsync(walletContext.Id, dataType);
        }
        else
        {
            logger.LogDebug("No {DataType} records received.", dataType);
        }
    }
}
