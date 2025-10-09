namespace WorkWallet.BI.ClientCore.Exceptions;

/// <summary>
/// Exception thrown when a requested dataset type is not supported by the client.
/// This indicates the dataset name in configuration doesn't match any known dataset in the DataSets lookup.
/// </summary>
public class UnsupportedDataTypeException(string dataType) :
    Exception($"Unsupported dataType: \"{dataType}\"")
{
}
