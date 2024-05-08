using DbUp;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using WorkWallet.BI.ClientDatabaseDeploy.Utils;

namespace WorkWallet.BI.ClientDatabaseDeploy.Services
{
    internal class DeployDatabaseService(
        IHostApplicationLifetime applicationLifetime,
        ILogger<DeployDatabaseService> logger,
        IOptions<AppSettings> settings) : IHostedService
    {
        private readonly AppSettings _settings = settings.Value;

        public Task StartAsync(CancellationToken cancellationToken)
        {
            try
            {
                DeployDatabase();
                applicationLifetime.StopApplication();
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Exception thrown in StartAsync: '{exception}'", ex.Message);
            }
            return Task.CompletedTask;
        }

        public Task StopAsync(CancellationToken cancellationToken)
        {
            return Task.CompletedTask;
        }

        private void DeployDatabase()
        {
            var connectionString = _settings.DatabaseConnectionString ?? throw new ApplicationException("No database connection string set");

            logger.LogInformation("Ensure database exists");
            EnsureDatabase.For.SqlDatabase(connectionString);

            try
            {
                logger.LogInformation("Clean");
                DbUpUtils.UpgradeDatabaseNoJournal(connectionString, ScriptFileType.Clean);

                logger.LogInformation("Deploy schema scripts");
                DbUpUtils.UpgradeDatabase(connectionString, ScriptFileType.Schema);

                logger.LogInformation("Deploy type scripts");
                DbUpUtils.UpgradeDatabaseNoJournal(connectionString, ScriptFileType.Type);

                logger.LogInformation("Deploy stored procedure scripts");
                DbUpUtils.UpgradeDatabaseNoJournal(connectionString, ScriptFileType.StoredProcedure);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Exception thrown in DeployDatabase: '{exception}'", ex.Message);
            }
        }
    }
}
