namespace WorkWallet.BI.ClientCore.Exceptions;

public class InvalidLastSynchronizationVersionException(long? lastSynchronizationVersion, long minValidSynchronizationVersion, Guid walletId, string dataType) :
    WalletException($"Invalid lastSynchronizationVersion {lastSynchronizationVersion} < {minValidSynchronizationVersion}", walletId, dataType)
{
}
