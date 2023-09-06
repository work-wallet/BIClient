using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using System;
using System.Threading.Tasks;
using WorkWallet.BI.ClientCore.Interfaces.Services;
using WorkWallet.BI.ClientCore.Options;
using WorkWallet.BI.ClientServices;

namespace WorkWallet.BI.ClientSample
{
    class Program
    {
        static async Task Main(string[] args)
        {
            try
            {
                using IHost host = Host.CreateDefaultBuilder(args)
                    .ConfigureServices((context, services) =>
                    {
                        ConfigureServices(services, context.Configuration);
                    })
                    .Build();

                IServiceProvider serviceProvider = host.Services;

                var processorService = serviceProvider.GetRequiredService<IProcessorService>();

                await processorService.RunAsync();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }

            if (System.Diagnostics.Debugger.IsAttached)
            {
                Console.WriteLine("Press any key to exit");
                Console.ReadKey();
            }
        }

        private static IServiceCollection ConfigureServices(IServiceCollection services, IConfiguration configuration)
        {
            services
                .AddOptions<ProcessorServiceOptions>()
                .Configure<IConfiguration>((settings, configuration) =>
                {
                    configuration.GetSection("ClientOptions").Bind(settings);
                });

            services
                .AddProcessorService()
                .AddSQLService(options =>
                {
                    options.SqlDbConnectionString = configuration.GetConnectionString("ClientDb");
                });

            return services;
        }
    }
}
