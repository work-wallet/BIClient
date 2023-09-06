using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;

namespace WorkWallet.BI.ClientDatabaseDeploy
{
    internal class Program
    {
        static async Task Main(string[] args)
        {
            var host = CreateHostBuilder(args);

            await host.RunConsoleAsync();
        }

        static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureAppConfiguration((builder) => builder.AddUserSecrets<Program>())
                .UseStartup<Startup>();
    }
}