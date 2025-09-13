using Microsoft.Extensions.Options;
using System.Net;
using System.Text.Json;
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
        int? pageSize = null,
        CancellationToken cancellationToken = default)
    {
        var query = HttpUtility.ParseQueryString(string.Empty);

        query["walletId"] = walletContext.Id.ToString();
        query["walletSecret"] = GetSecretForWallet(walletContext.Id);
        query["pageNumber"] = pageNumber.ToString();
        query["pageSize"] = (pageSize ?? _serviceOptions.AgentPageSize).ToString();

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
            if (response.StatusCode == HttpStatusCode.BadRequest)
            {
                string responseContent = await response.Content.ReadAsStringAsync(cancellationToken);
                
                // Check for the specific "Incorrect data region" error message
                if (string.Equals(responseContent, "Incorrect data region", StringComparison.OrdinalIgnoreCase))
                {
                    throw new IncorrectDataRegionException(walletContext.DataRegion, walletContext.Id, dataType);
                }
                
                // Try to parse as PageSize validation error
                if (TryParsePageSizeError(responseContent, out var pageSizeError) && pageSizeError != null)
                {
                    throw new PageSizeExceededException(
                        pageSizeError.RequestedPageSize, 
                        pageSizeError.MaxPageSize, 
                        pageSizeError.Error);
                }
            }
            
            // Default API exception for other error cases
            throw new ApiException(response.StatusCode, walletContext.Id, dataType);
        }

        return await response.Content.ReadAsStringAsync(cancellationToken);
    }

    private string GetSecretForWallet(Guid walletId)
    {
        return _serviceOptions.AgentWallets.Single(w => w.WalletId == walletId).WalletSecret;
    }

    /// <summary>
    /// Attempts to parse a PageSize validation error response from the API
    /// </summary>
    private static bool TryParsePageSizeError(string responseContent, out PageSizeErrorResponse? errorResponse)
    {
        errorResponse = null;
        
        try
        {
            var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
            var parsed = JsonSerializer.Deserialize<PageSizeErrorResponse>(responseContent, options);
            
            // Validate that this is actually a PageSize error
            if (parsed != null && 
                !string.IsNullOrEmpty(parsed.Error) &&
                parsed.MaxPageSize > 0 &&
                parsed.RequestedPageSize > 0)
            {
                errorResponse = parsed;
                return true;
            }
        }
        catch (JsonException)
        {
            // Not valid JSON or doesn't match our expected structure
        }
        
        return false;
    }

    /// <summary>
    /// Data structure for PageSize validation error responses
    /// </summary>
    private record PageSizeErrorResponse(
        string Error,
        int MaxPageSize,
        int RequestedPageSize);
}
