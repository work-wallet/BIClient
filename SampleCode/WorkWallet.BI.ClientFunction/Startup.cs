using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using System;
using WorkWallet.BI.ClientCore.Options;
using WorkWallet.BI.ClientServices;

[assembly: FunctionsStartup(typeof(WorkWallet.BI.ClientFunction.Startup))]

namespace WorkWallet.BI.ClientFunction
{
    public class Startup : FunctionsStartup
    {
        public override void Configure(IFunctionsHostBuilder builder)
        {
            ConfigureServices(builder.Services);
        }

        public static IServiceCollection ConfigureServices(IServiceCollection services)
        {
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

            return services;
        }
    }
}
