using Microsoft.Extensions.Options;
using WorkWallet.BI.ClientCore.Exceptions;
using WorkWallet.BI.ClientCore.Interfaces.Services;
using WorkWallet.BI.ClientCore.Options;

namespace WorkWallet.BI.ClientServices.Processor;

/// <summary>
/// Handles dataset configuration and validation logic
/// </summary>
public class DataSetResolver(IOptions<ProcessorServiceOptions> serviceOptions) : IDataSetResolver
{
    private readonly ProcessorServiceOptions _serviceOptions = serviceOptions.Value;

    /// <summary>
    /// Determines which datasets to process based on configuration.
    /// Uses all available datasets if none specifically configured.
    /// </summary>
    public IEnumerable<(string DataType, string LogType)> GetDataSetEntriesToProcess()
    {
        // if no DataSets are provided, then use all the ones that we know about
        var requestedDataSets = _serviceOptions.DataSets.Length > 0 
            ? _serviceOptions.DataSets 
            : DataSets.Entries.Keys;

        foreach (string dataSet in requestedDataSets)
        {
            var entry = DataSets.Entries.FirstOrDefault(dt => 
                dt.Key.Equals(dataSet, StringComparison.OrdinalIgnoreCase));

            // the requested dataType is not in our lookup of expected types
            if (entry.Equals(default(KeyValuePair<string, string>)))
            {
                throw new UnsupportedDataTypeException(dataSet);
            }

            yield return (entry.Key, entry.Value);
        }
    }
}
