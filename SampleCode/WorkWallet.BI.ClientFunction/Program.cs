using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using WorkWallet.BI.ClientCore.Options;
using WorkWallet.BI.ClientServices;

var host = new HostBuilder()
    .ConfigureFunctionsWebApplication()
    .ConfigureServices((hostingContext, services) => {
        services.AddApplicationInsightsTelemetryWorkerService();
        services.ConfigureFunctionsApplicationInsights();

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
                options.SqlDbConnectionString = Environment.GetEnvironmentVariable("sqldb_connection");
            });
    })
    .Build();

host.Run();