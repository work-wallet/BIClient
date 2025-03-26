namespace WorkWallet.BI.ClientCore.Exceptions;

public class UnsupportedDataTypeException(string dataType) :
    Exception($"Unsupported dataType: \"{dataType}\"")
{
}
