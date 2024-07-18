using Microsoft.Extensions.DependencyInjection;
using WorkWallet.BI.ClientCore.Interfaces.Services;
using WorkWallet.BI.ClientCore.Options;
using WorkWallet.BI.ClientServices.DataStore;
using WorkWallet.BI.ClientServices.Processor;

namespace WorkWallet.BI.ClientServices;

public static class ServiceExtension
{
    public static IServiceCollection AddProcessorService(
        this IServiceCollection serviceCollection)
    {
        serviceCollection.AddTransient<IProcessorService, ProcessorService>();
        return serviceCollection;
    }

    public static IServiceCollection AddSQLService(
        this IServiceCollection serviceCollection,
        Action<SQLServiceOptions> options)
    {
        serviceCollection.AddTransient<IDataStoreService, SQLService>();
        if (options == null)
        {
            throw new ArgumentNullException(nameof(options),
                @"Please provide options for SQLService.");
        }
        serviceCollection.Configure(options);
        return serviceCollection;
    }
}
