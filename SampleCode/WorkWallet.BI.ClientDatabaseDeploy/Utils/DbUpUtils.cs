using DbUp;
using DbUp.Helpers;
using System.Reflection;

namespace WorkWallet.BI.ClientDatabaseDeploy.Utils
{
    internal class DbUpUtils
    {
        internal static void UpgradeDatabase(string connectionString, ScriptFileType scriptType)
        {
            var schemaUpgrader = DeployChanges.To
                .SqlDatabase(connectionString)
                .WithScriptsEmbeddedInAssembly(Assembly.GetExecutingAssembly(), s => ScriptUtils.ParseScriptType(s) == scriptType)
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

        internal static void UpgradeDatabaseNoTransaction(string connectionString, ScriptFileType scriptType)
        {
            var schemaUpgrader = DeployChanges.To
                .SqlDatabase(connectionString)
                .WithScriptsEmbeddedInAssembly(Assembly.GetExecutingAssembly(), s => ScriptUtils.ParseScriptType(s) == scriptType)
                .LogToConsole()
                .WithExecutionTimeout(TimeSpan.FromMinutes(1))
                .Build();

            var result = schemaUpgrader.PerformUpgrade();

            if (!result.Successful)
            {
                throw result.Error;
            }
        }

        internal static void UpgradeDatabaseNoJournal(string connectionString, ScriptFileType scriptType)
        {
            var codeUpgrader = DeployChanges.To
                .SqlDatabase(connectionString)
                .WithScriptsEmbeddedInAssembly(Assembly.GetExecutingAssembly(), s => ScriptUtils.ParseScriptType(s) == scriptType)
                .LogToConsole()
                .WithExecutionTimeout(TimeSpan.FromMinutes(1))
                .JournalTo(new NullJournal())
                .WithTransaction()
                .Build();

            var result = codeUpgrader.PerformUpgrade();

            if (!result.Successful)
            {
                throw result.Error;
            }
        }
    }
}
