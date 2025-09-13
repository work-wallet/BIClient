namespace WorkWallet.BI.ClientCore.Interfaces.Services;

public interface IDataSetResolver
{
    IEnumerable<(string DataType, string LogType)> GetDataSetEntriesToProcess();
}
