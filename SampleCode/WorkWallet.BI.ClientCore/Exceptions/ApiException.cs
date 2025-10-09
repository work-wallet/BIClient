using System.Net;

namespace WorkWallet.BI.ClientCore.Exceptions;

/// <summary>
/// Exception thrown when an API call fails with an HTTP error status code.
/// Provides context about the HTTP response status for debugging and error handling.
/// </summary>
public class ApiException(HttpStatusCode httpStatusCode, Guid walletId, string dataType) :
    WalletException($"Failed to call API, HTTP response code: '{httpStatusCode}'", walletId, dataType)
{
}
