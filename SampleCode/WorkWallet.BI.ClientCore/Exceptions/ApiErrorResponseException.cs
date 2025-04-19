namespace WorkWallet.BI.ClientCore.Exceptions;

public class ApiErrorResponseException(string error, Guid walletId, string dataType) :
    WalletException($"API reported error '{error}'", walletId, dataType)
{
}
