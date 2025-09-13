namespace WorkWallet.BI.ClientCore.Exceptions;

/// <summary>
/// Exception thrown when the DataRegion header sent with API requests doesn't match the wallet's actual region.
/// </summary>
public class IncorrectDataRegionException(string dataRegion, Guid walletId, string dataType) :
    WalletException($"Incorrect DataRegion '{dataRegion}'", walletId, dataType)
{
}
