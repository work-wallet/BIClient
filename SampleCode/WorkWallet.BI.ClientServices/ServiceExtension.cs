using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
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
        this IServiceCollection services,
        IConfiguration configuration,
        string optionsSection = "ClientOptions")
    {
        // Retrieve BluBug config section or throw
        var blubugServiceOptionsConfig = configuration.GetRequiredSection("ClientOptions");

        var processorServiceOptions = blubugServiceOptionsConfig.Get<ProcessorServiceOptions>()
            ?? throw new InvalidOperationException($"Could not bind a configuration section named '{optionsSection}' to an instance of {nameof(ProcessorServiceOptions)}");

        // register our bearer token handler
        services.AddTransient<BearerTokenHandler>();
        services.AddHttpClient<BearerTokenHandler>("TokenAPI");

        // Token Server: Add and configure named HttpClient to be created through IHttpClientFactory
        services.AddHttpClient("TokenAPI", client =>
        {
            client.BaseAddress = new Uri(processorServiceOptions.ApiAccessAuthority);
        });

        // API: Add and configure named HttpClient to be created through IHttpClientFactory
        services.AddHttpClient("WorkWalletAPI", client =>
        {
            client.BaseAddress = new Uri(processorServiceOptions.AgentApiUrl);
            client.Timeout = TimeSpan.FromSeconds(processorServiceOptions.AgentTimeout);
        })
        .ConfigurePrimaryHttpMessageHandler<BearerTokenHandler>();

        return services;
    }
}
