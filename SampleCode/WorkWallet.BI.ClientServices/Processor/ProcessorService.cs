using IdentityModel.Client;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Net.Http;
using System.Threading.Tasks;
using WorkWallet.BI.ClientCore.Interfaces.Services;
using WorkWallet.BI.ClientCore.Options;

namespace WorkWallet.BI.ClientServices.Processor
{
    public class ProcessorService : IProcessorService
    {
        private readonly ILogger<ProcessorService> _logger;
        private readonly ProcessorServiceOptions _serviceOptions;
        private readonly IDataStoreService _dataStore;

        public ProcessorService(
            ILogger<ProcessorService> logger,
            IOptions<ProcessorServiceOptions> serviceOptions,
            IDataStoreService dataStore)
        {
            _logger = logger;
            _serviceOptions = serviceOptions.Value;
            _dataStore = dataStore;
        }

        public async Task RunAsync()
        {
            // obtain an OAuth access token for the client
            // (the API is secured using OAuth client credentials AND a wallet secret passed to the API methods)
             TokenResponse token = await GetAccessToken();

            // loop (supporting multiple wallets)
            foreach (var agentWallet in _serviceOptions.AgentWallets)
            {
                var processorOptions = new ProcessorOptions
                {
                    AccessToken = token.AccessToken,
                    ApiUrl = _serviceOptions.AgentApiUrl,
                    WalletId = agentWallet.WalletId,
                    WalletSecret = agentWallet.WalletSecret,
                    PageSize = _serviceOptions.AgentPageSize
                };

                await ProcessAsync(processorOptions, "SiteAudits", "AUDIT_UPDATED");
                await ProcessAsync(processorOptions, "ReportedIssues", "REPORTED_ISSUE_UPDATED");
                await ProcessAsync(processorOptions, "Inductions", "INDUCTION_UPDATED");
                await ProcessAsync(processorOptions, "Permits", "PERMIT_UPDATED");
                await ProcessAsync(processorOptions, "Actions", "ACTION_UPDATED");
            }
        }

        private async Task ProcessAsync(ProcessorOptions processorOptions, string dataType, string logType)
        {
            var processor = new Processor(
                logger: _logger,
                options: processorOptions,
                dataStore: _dataStore,
                dataType: dataType,
                logType: logType);

            await processor.Run();
        }

        private async Task<TokenResponse> GetAccessToken()
        {
            // discover endpoints from metadata
            var client = new HttpClient();
            var disco = await client.GetDiscoveryDocumentAsync(_serviceOptions.ApiAccessAuthority);
            if (disco.IsError)
            {
                throw new ApplicationException($"Failed to get discovery document: {disco.Error}");
            }

            // request token
            var tokenResponse = await client.RequestClientCredentialsTokenAsync(new ClientCredentialsTokenRequest
            {
                Address = disco.TokenEndpoint,

                ClientId = _serviceOptions.ApiAccessClientId,
                ClientSecret = _serviceOptions.ApiAccessClientSecret,
                Scope = _serviceOptions.ApiAccessScope
            });

            if (tokenResponse.IsError)
            {
                throw new ApplicationException($"Failed to get token: {tokenResponse.Error}");
            }

            _logger.LogInformation("API access token obtained from {ApiAccessAuthority} for client {ApiAccessClientId}", _serviceOptions.ApiAccessAuthority, _serviceOptions.ApiAccessClientId);

            return tokenResponse;
        }
    }
}
