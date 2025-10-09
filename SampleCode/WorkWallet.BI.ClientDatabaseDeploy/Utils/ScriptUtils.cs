using System.Reflection;
using System.Text.RegularExpressions;
using WorkWallet.BI.ClientDatabaseDeploy.Exceptions;

namespace WorkWallet.BI.ClientDatabaseDeploy.Utils;

internal class ScriptUtils
{
    internal static ScriptFileType ParseScriptFileType(string scriptName)
    {
        // the scriptName is passed in with the name of assembly and folders with '.' replacing the path separator.
        string? assemblyName = Assembly.GetExecutingAssembly().GetName().Name!.Replace("/", ".");

        Regex rx = new($"^{assemblyName}\\.Scripts\\.(Clean|Schema|Types|StoredProcedures)\\..+\\.sql",
            RegexOptions.Compiled | RegexOptions.IgnoreCase);
        Match m = rx.Match(scriptName);
        if (m.Success)
        {
            string capture = m.Groups[1].Value.ToLower();
            return capture switch
            {
                "clean" => ScriptFileType.Clean,
                "schema" => ScriptFileType.Schema,
                "types" => ScriptFileType.Type,
                "storedprocedures" => ScriptFileType.StoredProcedure,
                _ => throw new ScriptUnexpectedTypeException(capture, scriptName)
            };
        }
        else
        {
            throw new ScriptPathParseException(scriptName);
        }
    }
}
