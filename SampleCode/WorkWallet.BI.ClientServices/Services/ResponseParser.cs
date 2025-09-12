using System.Text.Json;
using WorkWallet.BI.ClientCore.Exceptions;
using WorkWallet.BI.ClientCore.Interfaces.Services;
using WorkWallet.BI.ClientCore.Models;

namespace WorkWallet.BI.ClientServices.Services;

public class ResponseParser : IResponseParser
{
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
