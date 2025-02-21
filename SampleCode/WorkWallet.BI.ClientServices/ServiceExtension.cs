﻿using Microsoft.Extensions.DependencyInjection;
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
        // register our bearer token handler
        services.AddHttpClient<BearerTokenHandler>((serviceProvider, client) =>
        {
            var options = serviceProvider.GetService<IOptions<ProcessorServiceOptions>>()!.Value;
            client.BaseAddress = new Uri(options.ApiAccessAuthority);
        });

        // register the processor service
        services.AddHttpClient<IProcessorService, ProcessorService>((serviceProvider, client) =>
        {
            var options = serviceProvider.GetService<IOptions<ProcessorServiceOptions>>()!.Value;
            client.BaseAddress = new Uri(options.AgentApiUrl);
            client.Timeout = TimeSpan.FromSeconds(options.AgentTimeout);
        })
        .ConfigurePrimaryHttpMessageHandler<BearerTokenHandler>()
        // the message handler already handles token expiry, but we additionally want the handler to be replaced in order to pick up DNS changes
        // (note we will only get a new message handler when a new instance of ProcessorService is instantiated)
        .SetHandlerLifetime(TimeSpan.FromMinutes(60));

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
}
