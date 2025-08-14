using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System.Net;
using System.Text.Json;
using System.Web;
using WorkWallet.BI.ClientCore.Exceptions;
using WorkWallet.BI.ClientCore.Interfaces.Services;
using WorkWallet.BI.ClientCore.Options;

namespace WorkWallet.BI.ClientServices.Processor;

public class ProcessorService(
    ILogger<ProcessorService> logger,
    IOptions<ProcessorServiceOptions> serviceOptions,
    HttpClient httpClient,
    IDataStoreService dataStore,
    IProgressService progressService) : IProcessorService
{
    private readonly ProcessorServiceOptions _serviceOptions = serviceOptions.Value;
    
    // the wallet endpoint uses camel case (the dataextract endpoints use pascal case)
    private static readonly JsonSerializerOptions _jsonCamelCaseOptions = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase
    };

    private record WalletContext
    {
        public Guid Id { get; set; }
        public required string Name { get; set; }
        public required string DataRegion { get; set; }
    }

    public async Task RunAsync(CancellationToken cancellationToken = default)
    {
        // loop (supporting multiple wallets)
        foreach (var agentWallet in _serviceOptions.AgentWallets)
        {
            cancellationToken.ThrowIfCancellationRequested();

            WalletContext walletContext = await GetWalletContextAsync(agentWallet.WalletId, cancellationToken);
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

        // obtain our last database change tracking synchronization number (or null if this is the first sync)
        long? lastSynchronizationVersion = await dataStore.GetLastSynchronizationVersionAsync(walletContext.Id, logType);

        if (!lastSynchronizationVersion.HasValue)
        {
            // no last synchronization data, treat this as a reset and delete all data
            await dataStore.ResetAsync(walletContext.Id, dataType);
        }

        int pageNumber = 0;
        int totalPages;
        Context context;

        // we support data paging in order to be able to cope with large result sets
        progressService.StartShowProgress(dataType, !lastSynchronizationVersion.HasValue);
        do
        {
            cancellationToken.ThrowIfCancellationRequested();

            ++pageNumber;

            // call the Work Wallet API end point and obtain the results as JSON
            string json = await CallApiAsync(
                walletContext,
                dataType,
                lastSynchronizationVersion,
                pageNumber,
                cancellationToken);

            progressService.ShowProgress();

            try
            {
                // extract the context information (this is included at the top of the JSON)
                using var document = JsonDocument.Parse(json);
                var contextElement = document.RootElement.GetProperty("Context");
                context = JsonSerializer.Deserialize<Context>(contextElement.GetRawText())!;
            }
            catch (Exception ex)
            {
                throw new DeserializeResponseException(typeof(Context), ex.Message, walletContext.Id, dataType);
            }

            // check for errors
            if (context.Error == "Invalid LastSynchronizationVersion")
            {
                throw new InvalidLastSynchronizationVersionException(lastSynchronizationVersion.Value, context.MinValidSynchronizationVersion, walletContext.Id, dataType);
            }

            if (context.Error.Length != 0)
            {
                throw new ApiErrorResponseException(context.Error, walletContext.Id, dataType);
            }

            // now we know how many rows there are in total, we can calculate the total number of pages we need to fetch
            // note that we want to calculate this every iteration (in case server data has been added to)
            totalPages = (context.FullCount - 1) / context.PageSize + 1;

            logger.LogDebug("API for {DataType} returned JSON of length {Length}", dataType, json.Length);
            logger.LogDebug("Count: {Count}", context.Count);
            logger.LogDebug("FullCount: {FullCount}", context.FullCount);
            logger.LogDebug("LastSynchronizationVersion: {LastSynchronizationVersion}", context.LastSynchronizationVersion);
            logger.LogDebug("SynchronizationVersion: {SynchronizationVersion}", context.SynchronizationVersion);
            logger.LogDebug("PageNumber: {PageNumber} / {totalPages}, PageSize: {PageSize}", context.PageNumber, totalPages, context.PageSize);

            if (context.Count > 0)
            {
                cancellationToken.ThrowIfCancellationRequested();

                // load into our local database (all the heavy lifting is done in the stored procedure)
                await dataStore.LoadAsync(dataType, json);
            }
            else
            {
                logger.LogDebug($"No records to load");
            }

        } while (pageNumber < totalPages);
        progressService.EndShowProgress(context.FullCount);

        // update our change detection / logging table, so we only fetch new and changed data next time
        // (must do this, even if no rows are obtained as lastSynchronizationVersion can otherwise become invalid)
        await dataStore.UpdateLastSyncAsync(walletContext.Id, logType, context.SynchronizationVersion, context.FullCount);

        if (context.FullCount > 0)
        {
            logger.LogDebug("A total of {FullCount} {DataType} records received.", context.FullCount, dataType);

            // perform any post processing
            await dataStore.PostProcessAsync(walletContext.Id, dataType);
        }
        else
        {
            logger.LogDebug("No {DataType} records received.", dataType);
        }
    }

    private async Task<WalletContext> GetWalletContextAsync(Guid walletId, CancellationToken cancellationToken = default)
    {
        var query = HttpUtility.ParseQueryString(string.Empty);

        query["walletId"] = walletId.ToString();
        query["walletSecret"] = GetSecretForWallet(walletId);

        string url = $"wallet?{query}";

        var response = await httpClient.GetAsync(url, cancellationToken);
        if (!response.IsSuccessStatusCode)
        {
            throw new WalletContextException(response.StatusCode, walletId);
        }

        string content = await response.Content.ReadAsStringAsync(cancellationToken);

        // parse the JSON response
        return JsonSerializer.Deserialize<WalletContext>(content, _jsonCamelCaseOptions) ?? throw new DeserializeResponseException(typeof(WalletContext), walletId);
    }

    private async Task<string> CallApiAsync(
        WalletContext walletContext,
        string dataType,
        long? lastSynchronizationVersion,
        int pageNumber,
        CancellationToken cancellationToken = default)
    {
        var query = HttpUtility.ParseQueryString(string.Empty);

        query["walletId"] = walletContext.Id.ToString();
        query["walletSecret"] = GetSecretForWallet(walletContext.Id);
        query["pageNumber"] = pageNumber.ToString();
        query["pageSize"] = _serviceOptions.AgentPageSize.ToString();

        if (lastSynchronizationVersion.HasValue)
        {
            query["lastSynchronizationVersion"] = (lastSynchronizationVersion.Value).ToString();
        }

        string url = $"dataextract/{dataType}?{query}";

        var request = new HttpRequestMessage(HttpMethod.Get, url);
        request.Headers.Add("DataRegion", walletContext.DataRegion);

        var response = await httpClient.SendAsync(request, cancellationToken);
        if (!response.IsSuccessStatusCode)
        {
            if (response.StatusCode == HttpStatusCode.BadRequest &&                
                string.Equals(await response.Content.ReadAsStringAsync(cancellationToken), "Incorrect data region", StringComparison.OrdinalIgnoreCase))
            {
                throw new IncorrectDataRegionException(walletContext.DataRegion, walletContext.Id, dataType);
            }
            else
            {
                throw new ApiException(response.StatusCode, walletContext.Id, dataType);
            }
        }

        return await response.Content.ReadAsStringAsync(cancellationToken);
    }

    private string GetSecretForWallet(Guid walletId)
    {
        return _serviceOptions.AgentWallets.Single(w => w.WalletId == walletId).WalletSecret;
    }
}
