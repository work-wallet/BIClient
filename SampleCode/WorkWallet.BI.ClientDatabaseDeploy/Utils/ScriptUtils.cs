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

            Regex rx = new Regex($"^{assemblyName}\\.Scripts\\.(Clean|Schema|Types|StoredProcedures)\\..+\\.sql",
                RegexOptions.Compiled | RegexOptions.IgnoreCase);
            Match m = rx.Match(scriptName);
            if (m.Success)
            {
                string capture = m.Groups[1].Value.ToLower();
                switch (capture)
                {
                    case "clean":
                        return ScriptFileType.Clean;
                    case "schema":
                        return ScriptFileType.Schema;
                    case "types":
                        return ScriptFileType.Type;
                    case "storedprocedures":
                        return ScriptFileType.StoredProcedure;
                    default:
                        throw new ApplicationException($"unexpected script type {m.Value}");
                }
            }
            else
            {
                throw new ApplicationException($"failed to parse script {scriptName}");
            }
        }
    }
}
