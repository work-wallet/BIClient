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
        private readonly ProcessorServiceOptions _options;
        private readonly IDataStoreService _dataStore;

        public ProcessorService(
            ILogger<ProcessorService> logger,
            IOptions<ProcessorServiceOptions> options,
            IDataStoreService dataStore)
        {
            _logger = logger;
            _options = options.Value;
            _dataStore = dataStore;
        }

        public async Task RunAsync()
        {
            // obtain an OAuth access token for the client
            // (the API is secured using OAuth client credentials AND a wallet secret passed to the API methods)
            TokenResponse token = await GetAccessToken();

            await ProcessAsync(token.AccessToken, "SiteAudits", "AUDIT_UPDATED");
            await ProcessAsync(token.AccessToken, "ReportedIssues", "REPORTED_ISSUE_UPDATED");
            await ProcessAsync(token.AccessToken, "Inductions", "INDUCTION_UPDATED");
            await ProcessAsync(token.AccessToken, "Permits", "PERMIT_UPDATED");
            await ProcessAsync(token.AccessToken, "Actions", "ACTION_UPDATED");
        }

        private async Task ProcessAsync(string accessToken, string dataType, string logType)
        {
            var processor = new Processor(
                logger: _logger,
                options: _options,
                dataStore: _dataStore,
                dataType: dataType,
                logType: logType,
                accessToken: accessToken);

            await processor.Run();
        }

        private async Task<TokenResponse> GetAccessToken()
        {
            // discover endpoints from metadata
            var client = new HttpClient();
            var disco = await client.GetDiscoveryDocumentAsync(_options.ApiAccessAuthority);
            if (disco.IsError)
            {
                throw new ApplicationException($"Failed to get discovery document: {disco.Error}");
            }

            // request token
            var tokenResponse = await client.RequestClientCredentialsTokenAsync(new ClientCredentialsTokenRequest
            {
                Address = disco.TokenEndpoint,

                ClientId = _options.ApiAccessClientId,
                ClientSecret = _options.ApiAccessClientSecret,
                Scope = _options.ApiAccessScope
            });

            if (tokenResponse.IsError)
            {
                throw new ApplicationException($"Failed to get token: {tokenResponse.Error}");
            }

            _logger.LogInformation("API access token obtained from {ApiAccessAuthority} for client {ApiAccessClientId}", _options.ApiAccessAuthority, _options.ApiAccessClientId);

            return tokenResponse;
        }
    }
}
