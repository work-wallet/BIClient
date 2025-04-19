namespace WorkWallet.BI.ClientCore.Interfaces.Services;

public interface IProcessorService
{
    Task RunAsync(CancellationToken cancellationToken = default);
}
