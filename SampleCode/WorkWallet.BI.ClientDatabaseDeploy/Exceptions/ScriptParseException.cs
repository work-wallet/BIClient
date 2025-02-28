namespace WorkWallet.BI.ClientDatabaseDeploy.Exceptions;

internal class ScriptParseException(string scriptName) :
    ScriptException("Failed to parse script", scriptName)
{
}
