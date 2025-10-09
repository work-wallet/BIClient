namespace WorkWallet.BI.ClientDatabaseDeploy.Exceptions;

/// <summary>
/// Exception thrown when a database script has an unexpected or unsupported type classification.
/// This indicates the script doesn't match any of the expected DbUp groups (Clean, Schema, Types, StoredProcedures).
/// </summary>
internal class ScriptUnexpectedTypeException(string scriptType, string scriptName) :
    ScriptException($"Unexpected script type '{scriptType}'", scriptName)
{
}
