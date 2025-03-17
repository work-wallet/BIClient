namespace WorkWallet.BI.ClientCore.Interfaces.Services;

public interface IDataStoreService
{
    public Task<long?> GetLastSynchronizationVersionAsync(Guid walletId, string logType, CancellationToken cancellationToken = default);
    public Task LoadAsync(string dataType, string json, CancellationToken cancellationToken = default);
    public Task UpdateLastSyncAsync(Guid walletId, string logType, long synchronizationVersion, int rowsProcessed, CancellationToken cancellationToken = default);
    public Task ResetAsync(Guid walletId, string dataType, CancellationToken cancellationToken = default);
    public Task PostProcessAsync(Guid walletId, string dataType, CancellationToken cancellationToken = default);
}
