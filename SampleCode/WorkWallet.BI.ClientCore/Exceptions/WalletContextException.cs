using System.Net;

namespace WorkWallet.BI.ClientCore.Exceptions;

/// <summary>
/// Exception thrown when retrieving wallet context information fails due to HTTP errors.
/// This typically occurs during the initial wallet validation and metadata retrieval phase.
/// </summary>
public class WalletContextException(HttpStatusCode httpStatusCode, Guid walletId) :
    WalletException($"Failed to obtain wallet context, HTTP response code: '{httpStatusCode}'", walletId)
{
}
