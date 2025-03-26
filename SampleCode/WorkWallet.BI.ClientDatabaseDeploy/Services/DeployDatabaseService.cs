using DbUp;
using DbUp.Engine;
using DbUp.Support;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System.Reflection;
using WorkWallet.BI.ClientDatabaseDeploy.Utils;

namespace WorkWallet.BI.ClientDatabaseDeploy.Services;

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
        var connectionString = _settings.DatabaseConnectionString ?? throw new ArgumentNullException("Please provide database connection string.");

        logger.LogInformation("Ensure database exists");
        EnsureDatabase.For.SqlDatabase(connectionString);

        try
        {
            var schemaUpgrader = DeployChanges.To
                .SqlDatabase(connectionString)

                // 1: clean
                .WithScriptsEmbeddedInAssembly(
                    Assembly.GetExecutingAssembly(),
                    s => ScriptUtils.ParseScriptFileType(s) == ScriptFileType.Clean,
                    new SqlScriptOptions { ScriptType = ScriptType.RunAlways, RunGroupOrder = 1 })

                // 2: schema (run once / journalled)
                .WithScriptsEmbeddedInAssembly(
                    Assembly.GetExecutingAssembly(),
                    s => ScriptUtils.ParseScriptFileType(s) == ScriptFileType.Schema,
                    new SqlScriptOptions { ScriptType = ScriptType.RunOnce, RunGroupOrder = 2 })

                // 3: types
                .WithScriptsEmbeddedInAssembly(
                    Assembly.GetExecutingAssembly(),
                    s => ScriptUtils.ParseScriptFileType(s) == ScriptFileType.Type,
                    new SqlScriptOptions { ScriptType = ScriptType.RunAlways, RunGroupOrder = 3 })

                // 4: stored procedures
                .WithScriptsEmbeddedInAssembly(
                    Assembly.GetExecutingAssembly(),
                    s => ScriptUtils.ParseScriptFileType(s) == ScriptFileType.StoredProcedure,
                    new SqlScriptOptions { ScriptType = ScriptType.RunAlways, RunGroupOrder = 4 })

                .LogToConsole()
                .WithExecutionTimeout(TimeSpan.FromMinutes(1))
                .WithTransaction()
                .Build();

            var result = schemaUpgrader.PerformUpgrade();

            if (!result.Successful)
            {
                throw result.Error;
            }
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Exception thrown in DeployDatabase: '{exception}'", ex.Message);
        }
    }
}
