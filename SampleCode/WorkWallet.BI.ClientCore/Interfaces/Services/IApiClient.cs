using WorkWallet.BI.ClientCore.Models;

namespace WorkWallet.BI.ClientCore.Interfaces.Services;

public interface IApiClient
{
    Task<string> FetchDataPageAsync(
        WalletContext walletContext,
        string walletSecret,
        string dataType,
        long? lastSynchronizationVersion,
        int pageNumber,
        int pageSize,
        bool? setBetaFlag,
        CancellationToken cancellationToken = default);
}
