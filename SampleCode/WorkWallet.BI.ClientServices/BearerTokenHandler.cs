using IdentityModel.Client;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System.Net.Http.Headers;
using WorkWallet.BI.ClientCore.Options;

namespace WorkWallet.BI.ClientServices;

public class BearerTokenHandler(
    ILogger<BearerTokenHandler> logger,
    IOptions<ProcessorServiceOptions> serviceOptions,
    HttpClient httpClient) : HttpClientHandler
{
    private readonly ProcessorServiceOptions _serviceOptions = serviceOptions.Value;
    private string? _accessToken = null;

    protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
    {
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", await GetAccessTokenAsync());
        return await base.SendAsync(request, cancellationToken);
    }

    private async Task<string> GetAccessTokenAsync()
    {
        if (_accessToken is not null)
        {
            // already have an access token
            return _accessToken;
        }

        // discover endpoints from metadata
        var disco = await httpClient.GetDiscoveryDocumentAsync(_serviceOptions.ApiAccessAuthority);
        if (disco.IsError)
        {
            throw new ApplicationException($"Failed to get discovery document: {disco.Error}");
        }

        // request token
        var tokenResponse = await httpClient.RequestClientCredentialsTokenAsync(new ClientCredentialsTokenRequest
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

        logger.LogDebug("API access token obtained from {ApiAccessAuthority} for client {ApiAccessClientId}", _serviceOptions.ApiAccessAuthority, _serviceOptions.ApiAccessClientId);

        return _accessToken = tokenResponse.AccessToken!;
    }
}
