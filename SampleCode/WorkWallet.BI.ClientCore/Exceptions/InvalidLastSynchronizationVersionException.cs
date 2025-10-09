namespace WorkWallet.BI.ClientCore.Exceptions;

/// <summary>
/// Exception thrown when the lastSynchronizationVersion from local tracking is invalid or too old.
/// This typically occurs when the server's change tracking retention period has expired, requiring a full data reload.
/// </summary>
public class InvalidLastSynchronizationVersionException(long? lastSynchronizationVersion, long minValidSynchronizationVersion, Guid walletId, string dataType) :
    WalletException($"Invalid lastSynchronizationVersion {lastSynchronizationVersion} < {minValidSynchronizationVersion}", walletId, dataType)
{
}
