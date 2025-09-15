using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Http.Resilience;
using Microsoft.Extensions.Options;
using Polly;
using System.Net;
using WorkWallet.BI.ClientCore.Interfaces.Services;
using WorkWallet.BI.ClientCore.Options;
using WorkWallet.BI.ClientServices.DataStore;
using WorkWallet.BI.ClientServices.Processor;
using WorkWallet.BI.ClientServices.Services;

namespace WorkWallet.BI.ClientServices;

public static class ServiceExtension
{
    public static IServiceCollection AddProcessorService(
        this IServiceCollection services)
    {
        // register our processor dependencies that don't need HttpClient
        services.AddScoped<IProcessorService, ProcessorService>();
        services.AddScoped<IResponseParser, ResponseParser>();
        services.AddScoped<IDataSetResolver, DataSetResolver>();

        // register our bearer token handler
        services.AddHttpClient<BearerTokenHandler>((serviceProvider, client) =>
        {
            var options = serviceProvider.GetService<IOptions<ProcessorServiceOptions>>()!.Value;
            client.BaseAddress = new Uri(options.ApiAccessAuthority);
        });

        // register services with shared HttpClient configuration
        AddHttpClientService<IApiClient, ApiClient>(services);
        AddHttpClientService<IWalletContextService, WalletContextService>(services);

        return services;
    }

    public static IServiceCollection AddSQLService(
        this IServiceCollection services,
        Action<SQLServiceOptions> options)
    {
        services.AddScoped<IDataStoreService, SQLService>();
        if (options == null)
        {
            throw new ArgumentNullException(nameof(options),
                @"Please provide options for SQLService.");
        }
        services.Configure(options);
        return services;
    }

    private static void AddHttpClientService<TInterface, TImplementation>(IServiceCollection services)
        where TInterface : class
        where TImplementation : class, TInterface
    {
        services.AddHttpClient<TInterface, TImplementation>((serviceProvider, client) =>
        {
            var options = serviceProvider.GetService<IOptions<ProcessorServiceOptions>>()!.Value;
            client.BaseAddress = new Uri(options.AgentApiUrl);
            client.Timeout = TimeSpan.FromSeconds(options.AgentTimeout);
        })
        .ConfigurePrimaryHttpMessageHandler<BearerTokenHandler>()
        // the message handler already handles token expiry, but we additionally want the handler to be replaced in order to pick up DNS changes
        // (note we will only get a new message handler when a new instance of ProcessorService is instantiated)
        .SetHandlerLifetime(TimeSpan.FromMinutes(60))
        // Add resilience for rate limiting (429) and transient failures
        .AddStandardResilienceHandler(options =>
        {
            // Configure retry for rate limiting and transient failures
            options.Retry.ShouldHandle = args => new ValueTask<bool>(
                args.Outcome.Exception is HttpRequestException ||
                (args.Outcome.Result?.StatusCode == HttpStatusCode.TooManyRequests) ||
                (args.Outcome.Result?.StatusCode >= HttpStatusCode.InternalServerError));
                
            options.Retry.MaxRetryAttempts = 5;
            options.Retry.BackoffType = DelayBackoffType.Exponential;
            options.Retry.UseJitter = true;
            options.Retry.Delay = TimeSpan.FromSeconds(1);
            options.Retry.MaxDelay = TimeSpan.FromMinutes(1);
        });
    }
}
