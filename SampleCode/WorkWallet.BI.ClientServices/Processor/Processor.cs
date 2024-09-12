using IdentityModel.Client;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Linq;
using System.Web;
using WorkWallet.BI.ClientCore.Interfaces.Services;

namespace WorkWallet.BI.ClientServices.Processor;

internal class ProcessorOptions
{
    public required string AccessToken { get; set; }
    public required string ApiUrl { get; set; }
    public required Guid WalletId { get; set; }
    public required string WalletSecret { get; set; }
    public required int PageSize { get; set; }
}

internal class Processor
{
    private readonly ILogger<ProcessorService> _logger;
    private readonly ProcessorOptions _options;
    private readonly IDataStoreService _dataStore;
    private readonly string _dataType;
    private readonly string _logType;

    internal Processor(
        ILogger<ProcessorService> logger,
        ProcessorOptions options,
        IDataStoreService dataStore,
        string dataType,
        string logType)
    {
        _logger = logger;
        _options = options;
        _dataStore = dataStore;
        _dataType = dataType;
        _logType = logType;
    }

    public async Task Run()
    {
        _logger.LogInformation("Processing for wallet: {wallet}, data type: {dataType}", _options.WalletId, _dataType);

        // obtain our last database change tracking synchronization number (or null if this is the first sync)
        long? lastSynchronizationVersion = await _dataStore.GetLastSynchronizationVersionAsync(_options.WalletId, _logType);

        if (!lastSynchronizationVersion.HasValue)
        {
            // no last synchronization data, treat this as a reset and delete all data
            await _dataStore.ResetAsync(_options.WalletId, _dataType);
        }

        int pageNumber = 0;
        int totalPages;
        Context context;

        // we support data paging in order to be able to cope with large result sets
        do
        {
            ++pageNumber;

            // call the Work Wallet API end point and obtain the results as JSON
            string json = await CallApiAsync(lastSynchronizationVersion, pageNumber);

            // extract the context information (this is included at the top of the JSON)
            var res = JObject.Parse(json);
            context = res["Context"]!.ToObject<Context>()!;

            // check for errors
            if (context.Error == "Invalid LastSynchronizationVersion")
            {
                throw new ApplicationException($"Error '{context.Error}' (requested {lastSynchronizationVersion} minimum {context.MinValidSynchronizationVersion}) - most likely caused by a significant number of days elapsed since last synchronisation.");
            }

            if (context.Error.Length != 0)
            {
                throw new ApplicationException($"Error '{context.Error}'");
            }

            // now we know how many rows there are in total, we can calculate the total number of pages we need to fetch
            // note that we want to calculate this every iteration (in case server data has been added to)
            totalPages = (context.FullCount - 1) / context.PageSize + 1;

            _logger.LogDebug("API for {DataType} returned JSON of length {Length}", _dataType, json.Length);
            _logger.LogDebug("Count: {Count}", context.Count);
            _logger.LogDebug("FullCount: {FullCount}", context.FullCount);
            _logger.LogDebug("LastSynchronizationVersion: {LastSynchronizationVersion}", context.LastSynchronizationVersion);
            _logger.LogDebug("SynchronizationVersion: {SynchronizationVersion}", context.SynchronizationVersion);
            _logger.LogDebug("PageNumber: {PageNumber} / {totalPages}, PageSize: {PageSize}", context.PageNumber, totalPages, context.PageSize);

            if (context.Count > 0)
            {
                // load into our local database (all the heavy lifting is done in the stored procedure)
                await _dataStore.LoadAsync(_dataType, json);
            }
            else
            {
                _logger.LogDebug($"No records to load");
            }

        } while (pageNumber < totalPages);

        if (context.FullCount > 0)
        {
            _logger.LogInformation("A total of {FullCount} {DataType} records received.", context.FullCount, _dataType);

            // finally update our change detection / logging table, so we only fetch new and changed data next time
            await _dataStore.UpdateLastSyncAsync(_options.WalletId, _logType, context.SynchronizationVersion, context.FullCount);
        }
        else
        {
            _logger.LogInformation("No {DataType} records received.", _dataType);
        }
    }

    private async Task<string> CallApiAsync(long? lastSynchronizationVersion, int pageNumber)
    {
        var url = QueryUrl($"dataextract/{_dataType}", pageNumber, _options.PageSize, lastSynchronizationVersion);

        var apiClient = new HttpClient();
        apiClient.SetBearerToken(_options.AccessToken);

        var response = await apiClient.GetAsync(url);
        if (!response.IsSuccessStatusCode)
        {
            throw new ApplicationException($"Failed to call the API: {response.StatusCode}");
        }

        return await response.Content.ReadAsStringAsync();
    }

    private string QueryUrl(string method, int pageNumber, int pageSize, long? lastSynchronizationVersion)
    {
        var builder = new UriBuilder(_options.ApiUrl)
        {
            Path = method
        };

        var query = HttpUtility.ParseQueryString(string.Empty);

        query["walletId"] = _options.WalletId.ToString();
        query["walletSecret"] = _options.WalletSecret;
        query["pageNumber"] = (pageNumber).ToString();
        query["pageSize"] = (pageSize).ToString();

        if (lastSynchronizationVersion.HasValue)
        {
            query["lastSynchronizationVersion"] = (lastSynchronizationVersion.Value).ToString();
        }

        builder.Query = query.ToString();

        return builder.ToString();
    }
}
