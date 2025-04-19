using System.Net;

namespace WorkWallet.BI.ClientCore.Exceptions;

public class ApiException(HttpStatusCode httpStatusCode, Guid walletId, string dataType) :
    WalletException($"Failed to call API, HTTP response code: '{httpStatusCode}'", walletId, dataType)
{
}
