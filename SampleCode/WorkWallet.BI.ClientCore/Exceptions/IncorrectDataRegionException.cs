namespace WorkWallet.BI.ClientCore.Exceptions;

public class IncorrectDataRegionException(string dataRegion, Guid walletId, string dataType) :
    WalletException($"Incorrect DataRegion '{dataRegion}'", walletId, dataType)
{
}
