namespace WorkWallet.BI.ClientDatabaseDeploy.Exceptions;

internal class ScriptUnexpectedTypeException(string scriptType, string scriptName) :
    ScriptException($"Unexpected script type '{scriptType}'", scriptName)
{
}
