using WorkWallet.BI.ClientCore.Models;

namespace WorkWallet.BI.ClientCore.Interfaces.Services;

public interface IWalletContextService
{
    Task<WalletContext> GetWalletContextAsync(Guid walletId, CancellationToken cancellationToken = default);
}
