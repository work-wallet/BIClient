using Microsoft.Extensions.Options;
using System.Net;
using System.Web;
using WorkWallet.BI.ClientCore.Exceptions;
using WorkWallet.BI.ClientCore.Interfaces.Services;
using WorkWallet.BI.ClientCore.Models;
using WorkWallet.BI.ClientCore.Options;

namespace WorkWallet.BI.ClientServices.Services;

public class ApiClient(
    HttpClient httpClient,
    IOptions<ProcessorServiceOptions> serviceOptions) : IApiClient
{
    private readonly ProcessorServiceOptions _serviceOptions = serviceOptions.Value;

    public async Task<string> FetchDataPageAsync(
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
            query["lastSynchronizationVersion"] = lastSynchronizationVersion.Value.ToString();
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
