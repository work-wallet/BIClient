using System.Net;
using System.Text.Json;
using System.Web;
using WorkWallet.BI.ClientCore.Exceptions;
using WorkWallet.BI.ClientCore.Interfaces.Services;
using WorkWallet.BI.ClientCore.Models;

namespace WorkWallet.BI.ClientServices.Services;

public class ApiClient(HttpClient httpClient) : IApiClient
{
    /// <summary>
    /// Fetches a page of data from the API for the specified wallet context and data type
    /// </summary>
    public async Task<string> FetchDataPageAsync(
        WalletContext walletContext,
        string walletSecret,
        string dataType,
        long? lastSynchronizationVersion,
        int pageNumber,
        int pageSize,
        CancellationToken cancellationToken = default)
    {
        var query = HttpUtility.ParseQueryString(string.Empty);

        query["walletId"] = walletContext.Id.ToString();
        query["walletSecret"] = walletSecret;
        query["pageNumber"] = pageNumber.ToString();
        query["pageSize"] = pageSize.ToString();

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
                // (Should never happen, as we obtained DataRegion from the API)
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

    /// <summary>
    /// Attempts to parse a PageSize validation error response from the API
    /// </summary>
    private static bool TryParsePageSizeError(string responseContent, out PageSizeErrorResponse? errorResponse)
    {
        errorResponse = null;
        
        try
        {
            var parsed = JsonSerializer.Deserialize<PageSizeErrorResponse>(responseContent, _jsonCaseInsensitiveOptions);

            // Validate that this is actually a PageSize error
            if (parsed != null && 
                !string.IsNullOrEmpty(parsed.Error) &&
                parsed.Error.StartsWith("PageSize exceeds maximum", StringComparison.OrdinalIgnoreCase) &&
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


    /// <summary>
    /// Case-insensitive JSON deserialization options
    /// </summary>
    private static readonly JsonSerializerOptions _jsonCaseInsensitiveOptions = new()
    {
        PropertyNameCaseInsensitive = true
    };
}
