namespace WorkWallet.BI.ClientCore.Interfaces.Services;

public interface IProgressService
{
    public void WriteWallet(string wallet, string dataRegion);
    public void StartShowProgress(string dataType, bool reset);
    public void ShowProgress();
    public void EndShowProgress(int records);
    public void ReportPageSizeReduced(int oldPageSize, int newPageSize);
    public void ReportHttpRetry(int attemptNumber, TimeSpan delay, int? statusCode, string? retryAfter);
}

// implemention that does nothing
public class NullProgressService : IProgressService
{
    public void WriteWallet(string wallet, string dataRegion) { }
    public void StartShowProgress(string dataType, bool reset) { }
    public void ShowProgress() { }
    public void EndShowProgress(int records) { }
    public void ReportPageSizeReduced(int oldPageSize, int newPageSize) { }
    public void ReportHttpRetry(int attemptNumber, TimeSpan delay, int? statusCode, string? retryAfter) { }
}
