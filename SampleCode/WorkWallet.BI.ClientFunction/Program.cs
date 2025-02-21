using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using WorkWallet.BI.ClientCore.Interfaces.Services;
using WorkWallet.BI.ClientCore.Options;
using WorkWallet.BI.ClientServices;

var host = new HostBuilder()
    .ConfigureAppConfiguration((hostContext, config) =>
    {
        // add appsettings.json for logging configuration for our application
        // (host logging is independent and configured through host.json)
        config.AddJsonFile("appsettings.json", optional: true);
    })
    .ConfigureFunctionsWorkerDefaults()
    .ConfigureServices((hostingContext, services) =>
    {
        // configure application insights
        services.AddApplicationInsightsTelemetryWorkerService(options => options.EnableDependencyTrackingTelemetryModule = false);
        services.ConfigureFunctionsApplicationInsights();

        // configure 'our' services
        services
            .AddOptions<ProcessorServiceOptions>()
            .Configure<IConfiguration>((settings, configuration) =>
            {
                configuration.GetSection("FuncOptions").Bind(settings);
            });
        services
            .AddProcessorService()
            .AddSQLService(options =>
            {
                options.SqlDbConnectionString = Environment.GetEnvironmentVariable("sqldb_connection")!;
            })
            .AddSingleton<IProgressService, NullProgressService>();
    })
    .ConfigureLogging((hostingContext, logging) =>
    {
        // remove the default rule that fixes the log level at Warning or above
        logging.Services.Configure<LoggerFilterOptions>(options =>
        {
            LoggerFilterRule? defaultRule = options.Rules.FirstOrDefault(rule => rule.ProviderName
                == "Microsoft.Extensions.Logging.ApplicationInsights.ApplicationInsightsLoggerProvider");
            if (defaultRule is not null)
            {
                options.Rules.Remove(defaultRule);
            }
        });

        // Make sure the configuration of the appsettings.json file is picked up.
        logging.AddConfiguration(hostingContext.Configuration.GetSection("Logging"));
    })
    .Build();

host.Run();