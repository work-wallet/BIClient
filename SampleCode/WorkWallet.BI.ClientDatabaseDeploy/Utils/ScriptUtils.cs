using System.Reflection;
using System.Text.RegularExpressions;

namespace WorkWallet.BI.ClientDatabaseDeploy.Utils
{
    internal class ScriptUtils
    {
        internal static ScriptFileType ParseScriptType(string scriptName)
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
                    _ => throw new ApplicationException($"unexpected script type {m.Value}"),
                };
            }
            else
            {
                throw new ApplicationException($"failed to parse script {scriptName}");
            }
        }
    }
}
