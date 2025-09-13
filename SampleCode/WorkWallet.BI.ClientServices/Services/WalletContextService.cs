using Microsoft.Extensions.Options;
using System.Text.Json;
using System.Web;
using WorkWallet.BI.ClientCore.Exceptions;
using WorkWallet.BI.ClientCore.Interfaces.Services;
using WorkWallet.BI.ClientCore.Models;
using WorkWallet.BI.ClientCore.Options;

namespace WorkWallet.BI.ClientServices.Services;

public class WalletContextService(
    HttpClient httpClient,
    IOptions<ProcessorServiceOptions> serviceOptions) : IWalletContextService
{
    private readonly ProcessorServiceOptions _serviceOptions = serviceOptions.Value;

    /// <summary>
    /// Retrieves wallet context information including data region and configuration metadata.
    /// This information is required before making data extraction API calls.
    /// </summary>
    public async Task<WalletContext> GetWalletContextAsync(Guid walletId, CancellationToken cancellationToken = default)
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

        try
        {
            // parse the JSON response
            return JsonSerializer.Deserialize<WalletContext>(content, _jsonCamelCaseOptions) 
                ?? throw new JsonParseException(typeof(WalletContext), content);
        }
        catch (JsonException ex)
        {
            throw new JsonParseException(typeof(WalletContext), content, null, ex);
        }
        catch (JsonParseException ex)
        {
            // Enrich with wallet context for better error reporting
            throw new DeserializeResponseException(ex.TargetType, walletId);
        }
    }

    /// <summary>
    /// Retrieves the wallet secret for the specified wallet ID from configuration.
    /// The wallet secret is required for API authentication.
    /// </summary>
    private string GetSecretForWallet(Guid walletId)
    {
        return _serviceOptions.AgentWallets.Single(w => w.WalletId == walletId).WalletSecret;
    }
    
    /// <summary>
    /// JSON serialization options configured for camel case property naming.
    /// The wallet endpoint uses camel case naming convention (differs from data extract endpoints which use pascal case).
    /// </summary>
    private static readonly JsonSerializerOptions _jsonCamelCaseOptions = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase
    };
}
