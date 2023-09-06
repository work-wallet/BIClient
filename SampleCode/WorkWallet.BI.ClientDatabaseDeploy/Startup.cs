using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using WorkWallet.BI.ClientDatabaseDeploy.Services;

namespace WorkWallet.BI.ClientDatabaseDeploy
{
    public class Startup
    {
        IConfiguration Configuration { get; }

        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public void ConfigureServices(IServiceCollection services)
        {
            services.Configure<AppSettings>(Configuration.GetSection(nameof(AppSettings)));

            services.AddHostedService<DeployDatabaseService>();
        }
    }
}
