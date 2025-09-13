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

    private string GetSecretForWallet(Guid walletId)
    {
        return _serviceOptions.AgentWallets.Single(w => w.WalletId == walletId).WalletSecret;
    }
    
    // the wallet endpoint uses camel case (the dataextract endpoints use pascal case)
    private static readonly JsonSerializerOptions _jsonCamelCaseOptions = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase
    };
}
