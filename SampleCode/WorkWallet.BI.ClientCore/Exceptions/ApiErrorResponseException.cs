namespace WorkWallet.BI.ClientCore.Exceptions;

/// <summary>
/// Exception thrown when the API returns a successful HTTP response but includes an error message in the response body.
/// Contains the specific error message reported by the API for detailed error diagnosis.
/// </summary>
public class ApiErrorResponseException(string error, Guid walletId, string dataType) :
    WalletException($"API reported error '{error}'", walletId, dataType)
{
}
