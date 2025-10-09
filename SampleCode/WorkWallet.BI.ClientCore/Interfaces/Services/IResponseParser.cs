using WorkWallet.BI.ClientCore.Models;

namespace WorkWallet.BI.ClientCore.Interfaces.Services;

public interface IResponseParser
{
    Context ParseContext(string json);
    void ValidateResponse(Context context, long? lastSynchronizationVersion, Guid walletId, string dataType);
}
