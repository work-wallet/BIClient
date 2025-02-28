using System.Net;

namespace WorkWallet.BI.ClientCore.Exceptions;

public class WalletContextException(HttpStatusCode httpStatusCode, Guid walletId) :
    WalletException($"Failed to obtain wallet context, HTTP response code: '{httpStatusCode}'", walletId)
{
}
