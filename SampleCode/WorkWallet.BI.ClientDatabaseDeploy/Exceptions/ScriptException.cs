namespace WorkWallet.BI.ClientDatabaseDeploy.Exceptions;

internal abstract class ScriptException(string message, string scriptName) :
    Exception($"{message} (scriptName: '{scriptName}')")
{
}
