namespace WorkWallet.BI.ClientCore.Interfaces.Services;

public interface IProgressService
{
    public void WriteWallet(string wallet, string dataRegion);
    public void StartShowProgress(string dataType, bool reset);
    public void ShowProgress();
    public void EndShowProgress(int records);
}

// implemention that does nothing
public class NullProgressService : IProgressService
{
    public void WriteWallet(string wallet, string dataRegion) { }
    public void StartShowProgress(string dataType, bool reset) { }
    public void ShowProgress() { }
    public void EndShowProgress(int records) { }
}
