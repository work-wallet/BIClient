namespace WorkWallet.BI.ClientDatabaseDeploy.Exceptions;

/// <summary>
/// Exception thrown when a script file path doesn't match the expected naming pattern for DbUp deployment scripts.
/// This indicates the script file is not located in the correct folder structure or doesn't follow the required naming convention.
/// Expected pattern: Scripts.(Clean|Schema|Types|StoredProcedures).*.sql
/// </summary>
internal class ScriptPathParseException(string scriptName) :
    ScriptException("Failed to parse script path", scriptName)
{
}
