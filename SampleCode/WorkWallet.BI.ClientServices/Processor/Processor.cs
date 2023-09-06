﻿using IdentityModel.Client;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Linq;
using System;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web;
using WorkWallet.BI.ClientCore.Interfaces.Services;
using WorkWallet.BI.ClientCore.Options;

namespace WorkWallet.BI.ClientServices.Processor
{
    internal class Processor
    {
        private readonly ILogger<ProcessorService> _logger;
        private readonly ProcessorServiceOptions _options;
        private IDataStoreService _dataStore;
        private readonly string _dataType;
        private readonly string _logType;
        private readonly string _accessToken;

        internal Processor(
            ILogger<ProcessorService> logger,
            ProcessorServiceOptions options,
            IDataStoreService dataStore,
            string dataType,
            string logType,
            string accessToken)
        {
            _logger = logger;
            _options = options;
            _dataStore = dataStore;
            _dataType = dataType;
            _logType = logType;
            _accessToken = accessToken;
        }

        public async Task Run()
        {
            // obtain our last database change tracking synchronization number (or null if this is the first sync)
            long? lastSynchronizationVersion = await _dataStore.GetLastSynchronizationVersionAsync(_options.AgentWalletId, _logType);

            if (!lastSynchronizationVersion.HasValue)
            {
                // no last synchronization data, treat this as a reset and delete all data
                await _dataStore.ResetAsync(_options.AgentWalletId, _dataType);
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

                if (_dataType == "SiteAudits")
                {
                    // work around non-generic fields returned from the API (fix this in future release)
                    context = res["Context"].ToObject<SiteAuditsContext>();
                }
                else
                {
                    context = res["Context"].ToObject<Context>();
                }

                // now we know how many rows there are in total, we can calculate the total number of pages we need to fetch
                // note that we want to calculate this every iteration (in case server data has been added to)
                totalPages = (context.FullCount - 1) / context.PageSize + 1;

                _logger.LogInformation($"API for {_dataType} returned JSON of lenght {json.Length}");
                _logger.LogInformation($"Count: {context.Count}");
                _logger.LogInformation($"FullCount: {context.FullCount}");
                _logger.LogInformation($"LastSynchronizationVersion: {context.LastSynchronizationVersion}");
                _logger.LogInformation($"SynchronizationVersion: {context.SynchronizationVersion}");
                _logger.LogInformation($"PageNumber: {context.PageNumber} / {totalPages}, PageSize: {context.PageSize}");

                if (context.Count > 0)
                {
                    // load into our local database (all the heavy lifting is done in the stored procedure)
                    await _dataStore.LoadAsync(_dataType, json);
                }
                else
                {
                    _logger.LogInformation($"No records to load");
                }

            } while (pageNumber < totalPages);

            if (context.FullCount > 0)
            {
                _logger.LogInformation($"A total of {context.FullCount} {_dataType} records received.");

                // finally update our change detection / logging table, so we only fetch new and changed data next time
                await _dataStore.UpdateLastSyncAsync(_options.AgentWalletId, _logType, context.SynchronizationVersion, context.FullCount);
            }
            else
            {
                _logger.LogInformation($"No {_dataType} records received.");
            }
        }

        private async Task<string> CallApiAsync(long? lastSynchronizationVersion, int pageNumber)
        {
            var url = QueryUrl($"dataextract/{_dataType}", pageNumber, _options.AgentPageSize, lastSynchronizationVersion);

            var apiClient = new HttpClient();
            apiClient.SetBearerToken(_accessToken);

            var response = await apiClient.GetAsync(url);
            if (!response.IsSuccessStatusCode)
            {
                throw new ApplicationException($"Failed to call the API: {response.StatusCode}");
            }

            return await response.Content.ReadAsStringAsync();
        }

        private string QueryUrl(string method, int pageNumber, int pageSize, long? lastSynchronizationVersion)
        {
            var builder = new UriBuilder(_options.AgentApiUrl)
            {
                Path = method
            };

            var query = HttpUtility.ParseQueryString(string.Empty);

            query["walletId"] = _options.AgentWalletId.ToString();
            query["walletSecret"] = _options.AgentWalletSecret;
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
}
