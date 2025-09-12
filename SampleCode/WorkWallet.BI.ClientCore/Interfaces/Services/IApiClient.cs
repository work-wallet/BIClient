using WorkWallet.BI.ClientCore.Models;

namespace WorkWallet.BI.ClientCore.Interfaces.Services;

public interface IApiClient
{
    Task<string> FetchDataPageAsync(
        WalletContext walletContext,
        string dataType,
        long? lastSynchronizationVersion,
        int pageNumber,
        CancellationToken cancellationToken = default);
}
