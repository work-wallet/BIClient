namespace WorkWallet.BI.ClientCore.Interfaces.Services;

public interface IDataStoreService
{
    public Task<long?> GetLastSynchronizationVersionAsync(Guid walletId, string logType);
    public Task LoadAsync(string dataType, string json);
    public Task UpdateLastSyncAsync(Guid walletId, string logType, long synchronizationVersion, int rowsProcessed);
    public Task PostProcessAsync(Guid walletId, string dataType);
}
