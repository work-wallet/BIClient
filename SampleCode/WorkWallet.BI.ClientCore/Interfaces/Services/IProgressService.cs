namespace WorkWallet.BI.ClientCore.Interfaces.Services;

public interface IProgressService
{
    public void WriteWallet(string wallet, string dataRegion);
    public void StartShowProgress(string dataType, bool reset);
    public void ShowProgress();
    public void EndShowProgress(int records);
    public void ReportPageSizeReduced(int oldPageSize, int newPageSize);
}

// implemention that does nothing
public class NullProgressService : IProgressService
{
    public void WriteWallet(string wallet, string dataRegion) { }
    public void StartShowProgress(string dataType, bool reset) { }
    public void ShowProgress() { }
    public void EndShowProgress(int records) { }
    public void ReportPageSizeReduced(int oldPageSize, int newPageSize) { }
}
