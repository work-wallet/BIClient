using System.Text.Json;
using WorkWallet.BI.ClientCore.Exceptions;
using WorkWallet.BI.ClientCore.Interfaces.Services;
using WorkWallet.BI.ClientCore.Models;

namespace WorkWallet.BI.ClientServices.Services;

public class ResponseParser : IResponseParser
{
    /// <summary>
    /// Extracts and parses the Context object from a data extraction API JSON response.
    /// The Context contains pagination information, synchronization version, and error details.
    /// </summary>
    public Context ParseContext(string json)
    {
        try
        {
            using var document = JsonDocument.Parse(json);
            var contextElement = document.RootElement.GetProperty("Context");
            return JsonSerializer.Deserialize<Context>(contextElement.GetRawText())!;
        }
        catch (Exception ex)
        {
            throw new JsonParseException(typeof(Context), json, "Context", ex);
        }
    }

    /// <summary>
    /// Validates the parsed API response context and throws appropriate exceptions for error conditions.
    /// Handles specific error scenarios like invalid synchronization versions and general API errors.
    /// </summary>
    public void ValidateResponse(Context context, long? lastSynchronizationVersion, Guid walletId, string dataType)
    {
        if (context.Error == "Invalid LastSynchronizationVersion")
        {
            throw new InvalidLastSynchronizationVersionException(
                lastSynchronizationVersion!.Value, 
                context.MinValidSynchronizationVersion, 
                walletId, 
                dataType);
        }

        if (context.Error.Length != 0)
        {
            throw new ApiErrorResponseException(context.Error, walletId, dataType);
        }
    }
}
