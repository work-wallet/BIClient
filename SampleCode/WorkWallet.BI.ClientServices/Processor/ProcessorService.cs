using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using WorkWallet.BI.ClientCore.Exceptions;
using WorkWallet.BI.ClientCore.Interfaces.Services;
using WorkWallet.BI.ClientCore.Models;
using WorkWallet.BI.ClientCore.Options;
using WorkWallet.BI.ClientCore.Utils;

namespace WorkWallet.BI.ClientServices.Processor;

/// <summary>
/// Orchestrates the synchronization of data from Work Wallet APIs to local storage.
/// 
/// Flow:
/// 1. For each configured wallet
/// 2. For each configured dataset (or all if none specified)
/// 3. Initialize synchronization state (incremental vs full sync)
/// 4. Process data in pages to handle large datasets
/// 5. Store data and update synchronization tracking
/// 6. Perform post-processing
/// </summary>
public class ProcessorService(
    ILogger<ProcessorService> logger,
    IOptions<ProcessorServiceOptions> serviceOptions,
    IDataStoreService dataStore,
    IProgressService progressService,
    IWalletContextService walletContextService,
    IApiClient apiClient,
    IResponseParser responseParser,
    IDataSetResolver dataSetResolver) : IProcessorService
{
    private readonly ProcessorServiceOptions _serviceOptions = serviceOptions.Value;

    #region Public Interface
    
    /// <summary>
    /// Main entry point: processes all configured wallets and datasets
    /// </summary>
    public async Task RunAsync(CancellationToken cancellationToken = default)
    {
        // loop (supporting multiple wallets)
        foreach (var agentWallet in _serviceOptions.AgentWallets)
        {
            cancellationToken.ThrowIfCancellationRequested();

            string walletSecret = GetSecretForWallet(agentWallet.WalletId);
            WalletContext walletContext = await walletContextService.GetWalletContextAsync(agentWallet.WalletId, walletSecret, cancellationToken);
            logger.LogInformation("Start process for wallet {wallet}", agentWallet.WalletId);
            progressService.WriteWallet(walletContext.Name.Trim(), walletContext.DataRegion);

            await ProcessWalletDataSetsAsync(walletContext, cancellationToken);
        }
    }

    #endregion

    #region Wallet and Dataset Orchestration

    /// <summary>
    /// Processes all datasets for a single wallet
    /// </summary>
    private async Task ProcessWalletDataSetsAsync(WalletContext walletContext, CancellationToken cancellationToken)
    {
        var dataSetEntries = dataSetResolver.GetDataSetEntriesToProcess();

        foreach (var (dataType, logType) in dataSetEntries)
        {
            cancellationToken.ThrowIfCancellationRequested();
            await ProcessAsync(walletContext, dataType, logType, cancellationToken);
        }
    }

    #endregion

    #region Dataset Processing Pipeline

    /// <summary>
    /// Main processing pipeline for a single dataset:
    /// Initialize → Process Pages → Finalize
    /// </summary>
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

    /// <summary>
    /// Initializes processing state and handles full vs incremental sync
    /// </summary>

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

    /// <summary>
    /// Processes all pages of data for a dataset, handling pagination automatically
    /// </summary>
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
        int currentPageSize = _serviceOptions.AgentPageSize; // Start with default, reset per dataset
        
        do
        {
            cancellationToken.ThrowIfCancellationRequested();
            
            var pageResult = await ProcessSinglePageWithRetryAsync(
                walletContext, dataType, state.LastSynchronizationVersion, ++pageNumber, 
                currentPageSize, cancellationToken);
            
            context = pageResult.Context;
            
            // Update page size if it was adjusted during retry
            currentPageSize = pageResult.UsedPageSize;
            
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

    /// <summary>
    /// Processes a single page with automatic retry for PageSize validation errors
    /// </summary>
    private async Task<PageResultWithSize> ProcessSinglePageWithRetryAsync(
        WalletContext walletContext,
        string dataType,
        long? lastSynchronizationVersion,
        int pageNumber,
        int initialPageSize,
        CancellationToken cancellationToken)
    {
        int currentPageSize = initialPageSize;
        
        while (true)
        {
            try
            {
                var pageResult = await ProcessSinglePageAsync(
                    walletContext, dataType, lastSynchronizationVersion, 
                    pageNumber, currentPageSize, _serviceOptions.SetBetaFlag,
                    cancellationToken);

                return new PageResultWithSize(pageResult.Context, pageResult.Json, currentPageSize);
            }
            catch (PageSizeExceededException ex)
            {
                logger.LogWarning("PageSize {RequestedPageSize} exceeded for dataset {DataType}, retrying with maxPageSize {MaxPageSize}", 
                    ex.RequestedPageSize, dataType, ex.MaxPageSize);

                    progressService.ReportPageSizeReduced(currentPageSize, ex.MaxPageSize);
                
                currentPageSize = ex.MaxPageSize;
                // Continue the loop to retry with the smaller page size
            }
        }
    }

    /// <summary>
    /// Processes a single page of data: fetch, parse, validate, return
    /// </summary>
    private async Task<PageResult> ProcessSinglePageAsync(
        WalletContext walletContext,
        string dataType,
        long? lastSynchronizationVersion,
        int pageNumber,
        int pageSize,
        bool? setBetaFlag,
        CancellationToken cancellationToken)
    {
        // call the Work Wallet API end point and obtain the results as JSON
        string walletSecret = GetSecretForWallet(walletContext.Id);
        string json = await apiClient.FetchDataPageAsync(walletContext, walletSecret, dataType, lastSynchronizationVersion, pageNumber, pageSize, setBetaFlag, cancellationToken);

        progressService.ShowProgress();

        try
        {
            // extract and validate the context information
            var context = responseParser.ParseContext(json);
            responseParser.ValidateResponse(context, lastSynchronizationVersion, walletContext.Id, dataType);

            LogPageDetails(dataType, json, context);

            return new PageResult(context, json);
        }
        catch (JsonParseException ex)
        {
            // Enrich with wallet context for better error reporting
            throw new DeserializeResponseException(ex.TargetType, ex.Message, walletContext.Id, dataType);
        }
    }

    /// <summary>
    /// Updates synchronization tracking and performs post-processing
    /// </summary>
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

    #endregion

    #region Helper Methods

    /// <summary>
    /// Logs detailed information about the API response for debugging
    /// </summary>
    private void LogPageDetails(string dataType, string json, Context context)
    {
        logger.LogDebug("API for {DataType} returned JSON of length {Length}", dataType, json.Length);
        logger.LogDebug("Count: {Count}", context.Count);
        logger.LogDebug("FullCount: {FullCount}", context.FullCount);
        logger.LogDebug("LastSynchronizationVersion: {LastSynchronizationVersion}", context.LastSynchronizationVersion);
        logger.LogDebug("SynchronizationVersion: {SynchronizationVersion}", context.SynchronizationVersion);
        logger.LogDebug("PageNumber: {PageNumber}, PageSize: {PageSize}", context.PageNumber, context.PageSize);
        logger.LogDebug("ExecutionTimeMs: {ExecutionTimeMs}", context.ExecutionTimeMs);
    }

    /// <summary>
    /// Gets the wallet secret for the specified wallet ID from configuration
    /// </summary>
    private string GetSecretForWallet(Guid walletId)
    {
        return _serviceOptions.AgentWallets.Single(w => w.WalletId == walletId).WalletSecret;
    }

    #endregion
}

/// <summary>
/// Extended page result that includes the page size used for the request
/// </summary>
internal record PageResultWithSize(Context Context, string Json, int UsedPageSize);
