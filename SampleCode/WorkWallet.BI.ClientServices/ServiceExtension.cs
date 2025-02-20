using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;
using WorkWallet.BI.ClientCore.Interfaces.Services;
using WorkWallet.BI.ClientCore.Options;
using WorkWallet.BI.ClientServices.DataStore;
using WorkWallet.BI.ClientServices.Processor;

namespace WorkWallet.BI.ClientServices;

public static class ServiceExtension
{
    public static IServiceCollection AddProcessorService(
        this IServiceCollection services)
    {
        services.AddTransient<IProcessorService, ProcessorService>();
        services.AddHttpClient<IProcessorService, ProcessorService>("WorkWalletAPI");
        return services;
    }

    public static IServiceCollection AddSQLService(
        this IServiceCollection services,
        Action<SQLServiceOptions> options)
    {
        services.AddTransient<IDataStoreService, SQLService>();
        if (options == null)
        {
            throw new ArgumentNullException(nameof(options),
                @"Please provide options for SQLService.");
        }
        services.Configure(options);
        return services;
    }

    public static IServiceCollection AddAPIServices(
        this IServiceCollection services)
    {
        // register our bearer token handler
        services.AddTransient<BearerTokenHandler>();
        services.AddHttpClient<BearerTokenHandler>("TokenAPI");

        // Token Server: Add and configure named HttpClient to be created through IHttpClientFactory
        services.AddHttpClient("TokenAPI", (serviceProvider, client) =>
        {
            var options = serviceProvider.GetService<IOptions<ProcessorServiceOptions>>()!.Value;
            client.BaseAddress = new Uri(options.ApiAccessAuthority);
        });

        // API: Add and configure named HttpClient to be created through IHttpClientFactory
        services.AddHttpClient("WorkWalletAPI", (serviceProvider, client) =>
        {
            var options = serviceProvider.GetService<IOptions<ProcessorServiceOptions>>()!.Value;
            client.BaseAddress = new Uri(options.AgentApiUrl);
            client.Timeout = TimeSpan.FromSeconds(options.AgentTimeout);
        })
        .ConfigurePrimaryHttpMessageHandler<BearerTokenHandler>();

        return services;
    }
}
