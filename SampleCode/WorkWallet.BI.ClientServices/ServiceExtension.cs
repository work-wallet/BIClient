using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Http.Resilience;
using Microsoft.Extensions.Logging;
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
        // Add custom resilience handler with service access for logging and progress reporting
        .AddResilienceHandler("HttpRetryWithProgress", (builder, context) =>
        {
            // Get services from the context for use in callbacks
            var logger = context.ServiceProvider.GetService<ILogger<TImplementation>>();
            var progressService = context.ServiceProvider.GetService<IProgressService>();
            
            builder.AddRetry(new HttpRetryStrategyOptions
            {
                // Configure retry for rate limiting and transient failures
                ShouldHandle = args => new ValueTask<bool>(
                    args.Outcome.Exception is HttpRequestException ||
                    (args.Outcome.Result?.StatusCode == HttpStatusCode.TooManyRequests) ||
                    (args.Outcome.Result?.StatusCode >= HttpStatusCode.InternalServerError)),
                    
                MaxRetryAttempts = 5,
                BackoffType = DelayBackoffType.Exponential,
                UseJitter = true,
                Delay = TimeSpan.FromSeconds(1),
                MaxDelay = TimeSpan.FromMinutes(1),
                
                // Add custom logging and progress reporting for retry events
                OnRetry = args =>
                {
                    var response = args.Outcome.Result;
                    
                    if (response?.StatusCode == HttpStatusCode.TooManyRequests)
                    {
                        var retryAfter = response.Headers.RetryAfter?.ToString() ?? "not specified";
                        logger?.LogWarning(
                            "Rate limited (HTTP 429). Retry attempt {AttemptNumber} in {Delay}ms. Retry-After: {RetryAfter}",
                            args.AttemptNumber,
                            args.RetryDelay.TotalMilliseconds,
                            retryAfter);
                        
                        progressService?.ReportHttpRetry(
                            args.AttemptNumber, 
                            args.RetryDelay, 
                            (int)HttpStatusCode.TooManyRequests, 
                            retryAfter);
                    }
                    else
                    {
                        var statusCode = (int?)response?.StatusCode;
                        logger?.LogWarning(
                            "HTTP request failed with {StatusCode}. Retry attempt {AttemptNumber} in {Delay}ms",
                            response?.StatusCode ?? HttpStatusCode.RequestTimeout,
                            args.AttemptNumber,
                            args.RetryDelay.TotalMilliseconds);
                        
                        progressService?.ReportHttpRetry(
                            args.AttemptNumber, 
                            args.RetryDelay, 
                            statusCode, 
                            null);
                    }
                    
                    return ValueTask.CompletedTask;
                }
            });
        });
    }
}
