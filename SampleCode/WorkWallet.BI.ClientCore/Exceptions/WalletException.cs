namespace WorkWallet.BI.ClientCore.Exceptions;

public class WalletException : Exception
{
    public WalletException(Guid walletId) :
        base($"Exception processing wallet: '{walletId}'")
    {
    }

    public WalletException(Guid walletId, string dataType) :
        base($"Exception processing dataType: '{dataType}' for wallet: '{walletId}'")
    {
    }

    protected WalletException(string message, Guid walletId) :
        base($"{message} (wallet: '{walletId}')")
    {
    }

    protected WalletException(string message, Guid walletId, string dataType) :
        base($"{message} (wallet: {walletId}, dataType: '{dataType}')")
    {
    }
}
