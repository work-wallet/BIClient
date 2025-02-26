using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Web;
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

    private record WalletContext
    {
        public Guid Id { get; set; }
        public required string Name { get; set; }
        public required string DataRegion { get; set; }
    }

    public async Task RunAsync()
    {
        // loop (supporting multiple wallets)
        foreach (var agentWallet in _serviceOptions.AgentWallets)
        {
            WalletContext walletContext = await GetWalletContextAsync(agentWallet.WalletId);
            logger.LogInformation("Start process for wallet {wallet}", agentWallet.WalletId);
            progressService.WriteWallet(walletContext.Name.Trim(), walletContext.DataRegion);

            await ProcessAsync(walletContext, "SiteAudits", "AUDIT_UPDATED");
            await ProcessAsync(walletContext, "ReportedIssues", "REPORTED_ISSUE_UPDATED");
            await ProcessAsync(walletContext, "Inductions", "INDUCTION_UPDATED");
            await ProcessAsync(walletContext, "Permits", "PERMIT_UPDATED");
            await ProcessAsync(walletContext, "Actions", "ACTION_UPDATED");
            await ProcessAsync(walletContext, "Assets", "ASSET_UPDATED");
            await ProcessAsync(walletContext, "SafetyCards", "SAFETY_CARD_UPDATED");
            await ProcessAsync(walletContext, "Audits", "AUDIT2_UPDATED");
        }
    }

    private async Task ProcessAsync(
        WalletContext walletContext,
        string dataType,
        string logType)
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
            ++pageNumber;

            // call the Work Wallet API end point and obtain the results as JSON
            string json = await CallApiAsync(
                walletContext,
                dataType,
                lastSynchronizationVersion,
                pageNumber);

            progressService.ShowProgress();

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

            logger.LogDebug("API for {DataType} returned JSON of length {Length}", dataType, json.Length);
            logger.LogDebug("Count: {Count}", context.Count);
            logger.LogDebug("FullCount: {FullCount}", context.FullCount);
            logger.LogDebug("LastSynchronizationVersion: {LastSynchronizationVersion}", context.LastSynchronizationVersion);
            logger.LogDebug("SynchronizationVersion: {SynchronizationVersion}", context.SynchronizationVersion);
            logger.LogDebug("PageNumber: {PageNumber} / {totalPages}, PageSize: {PageSize}", context.PageNumber, totalPages, context.PageSize);

            if (context.Count > 0)
            {
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

    private async Task<WalletContext> GetWalletContextAsync(Guid walletId)
    {
        var query = HttpUtility.ParseQueryString(string.Empty);

        query["walletId"] = walletId.ToString();
        query["walletSecret"] = GetSecretForWallet(walletId);

        string url = $"wallet?{query}";

        var response = await httpClient.GetAsync(url);
        if (!response.IsSuccessStatusCode)
        {
            throw new ApplicationException($"Failed to obtain the wallet context: {response.StatusCode}");
        }

        string content = await response.Content.ReadAsStringAsync();

        // parse the JSON response
        return JsonConvert.DeserializeObject<WalletContext>(content) ?? throw new ApplicationException($"Failed to parse wallet context response");
    }

    private async Task<string> CallApiAsync(
        WalletContext walletContext,
        string dataType,
        long? lastSynchronizationVersion,
        int pageNumber)
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

        var response = await httpClient.SendAsync(request);
        if (!response.IsSuccessStatusCode)
        {
            throw new ApplicationException($"Failed to call the API: {response.StatusCode}");
        }

        return await response.Content.ReadAsStringAsync();
    }

    private string GetSecretForWallet(Guid walletId)
    {
        return _serviceOptions.AgentWallets.Single(w => w.WalletId == walletId).WalletSecret;
    }
}
