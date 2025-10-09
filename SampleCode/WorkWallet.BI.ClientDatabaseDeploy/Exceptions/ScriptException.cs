namespace WorkWallet.BI.ClientDatabaseDeploy.Exceptions;

/// <summary>
/// Base exception class for all database script-related errors during deployment.
/// Provides consistent context information including the script name for debugging deployment issues.
/// </summary>
internal abstract class ScriptException(string message, string scriptName) :
    Exception($"{message} (scriptName: '{scriptName}')")
{
}
