using System.Text.RegularExpressions;

namespace WorkWallet.BI.PowerBIModelDocGenerator;

// Category mirrors the icon Power BI Desktop shows next to a field: a plain source
// column ("attr"), a DAX calculated column ("calc"), a DAX measure ("measure"), or a
// plain numeric column with a non-default implicit aggregation ("agg").
public sealed record TmdlColumn(string Name, string Category);

public sealed class TmdlTable
{
    public required string Name { get; init; }

    public List<TmdlColumn> Columns { get; } = [];
}

public sealed record TmdlRelationship(string FromTable, string FromColumn, string ToTable, string ToColumn, bool IsActive);

/// <summary>
/// Very small, purpose-built reader for the subset of TMDL syntax that Power BI Desktop
/// generates for this repo's semantic models (single-column relationships, no explicit
/// cardinality overrides). Not a general-purpose TMDL parser.
/// </summary>
public static partial class TmdlReader
{
    [GeneratedRegex(@"^table\s+(?<name>'[^']+'|\S+)")]
    private static partial Regex TableNameRegex();

    [GeneratedRegex(@"^\t(?<kind>column|measure)\s+(?<name>'[^']+'|[^\s=]+)(?<rest>.*)$")]
    private static partial Regex MemberRegex();

    [GeneratedRegex(@"^\t\tsummarizeBy:\s*(?<value>\S+)")]
    private static partial Regex SummarizeByRegex();

    [GeneratedRegex(@"^\t(column|measure)\s")]
    private static partial Regex NextMemberStartRegex();

    [GeneratedRegex(@"\r?\n\r?\n")]
    private static partial Regex RelationshipBlockSeparatorRegex();

    [GeneratedRegex(@"fromColumn:\s*(?<ref>.+)")]
    private static partial Regex FromColumnRegex();

    [GeneratedRegex(@"toColumn:\s*(?<ref>.+)")]
    private static partial Regex ToColumnRegex();

    [GeneratedRegex(@"^\s*isActive:\s*false\s*$", RegexOptions.Multiline)]
    private static partial Regex InactiveRelationshipRegex();

    public static TmdlTable ReadTable(string tableTmdlPath)
    {
        var lines = File.ReadAllLines(tableTmdlPath);

        var tableNameMatch = lines.Select(l => TableNameRegex().Match(l)).First(m => m.Success);
        var table = new TmdlTable { Name = Unquote(tableNameMatch.Groups["name"].Value) };

        for (var i = 0; i < lines.Length; i++)
        {
            var memberMatch = MemberRegex().Match(lines[i]);
            if (!memberMatch.Success)
            {
                continue;
            }

            var name = Unquote(memberMatch.Groups["name"].Value);
            var isMeasure = memberMatch.Groups["kind"].Value == "measure";
            var isCalculated = memberMatch.Groups["rest"].Value.TrimStart().StartsWith('=');
            var summarizeBy = "none";
            var isHidden = false;

            for (var j = i + 1; j < lines.Length; j++)
            {
                // Stop scanning this member's properties once the next column/measure starts.
                if (NextMemberStartRegex().IsMatch(lines[j]))
                {
                    break;
                }

                var summarizeByMatch = SummarizeByRegex().Match(lines[j]);
                if (summarizeByMatch.Success)
                {
                    summarizeBy = summarizeByMatch.Groups["value"].Value;
                }

                if (lines[j].Trim() == "isHidden")
                {
                    isHidden = true;
                }
            }

            if (isHidden)
            {
                continue;
            }

            var category = isMeasure ? "measure"
                : isCalculated ? "calc"
                : summarizeBy != "none" ? "agg"
                : "attr";
            table.Columns.Add(new TmdlColumn(name, category));
        }

        return table;
    }

    public static List<TmdlRelationship> ReadRelationships(string relationshipsTmdlPath)
    {
        var text = File.ReadAllText(relationshipsTmdlPath);
        var blocks = RelationshipBlockSeparatorRegex().Split(text)
            .Where(b => b.TrimStart().StartsWith("relationship ", StringComparison.Ordinal));

        var relationships = new List<TmdlRelationship>();

        foreach (var block in blocks)
        {
            var fromMatch = FromColumnRegex().Match(block);
            var toMatch = ToColumnRegex().Match(block);
            if (!fromMatch.Success || !toMatch.Success)
            {
                continue;
            }

            var (fromTable, fromColumn) = ParseTableColumnRef(fromMatch.Groups["ref"].Value);
            var (toTable, toColumn) = ParseTableColumnRef(toMatch.Groups["ref"].Value);
            var isActive = !InactiveRelationshipRegex().IsMatch(block);

            relationships.Add(new TmdlRelationship(fromTable, fromColumn, toTable, toColumn, isActive));
        }

        return relationships;
    }

    private static (string Table, string Column) ParseTableColumnRef(string reference)
    {
        reference = reference.Trim();

        string table;
        string rest;
        if (reference.StartsWith('\''))
        {
            var closingQuote = reference.IndexOf('\'', 1);
            table = reference[1..closingQuote];
            rest = reference[(closingQuote + 2)..]; // skip closing quote and the following '.'
        }
        else
        {
            var dot = reference.IndexOf('.');
            table = reference[..dot];
            rest = reference[(dot + 1)..];
        }

        return (table, Unquote(rest.Trim()));
    }

    private static string Unquote(string value) =>
        value.Length >= 2 && value[0] == '\'' && value[^1] == '\'' ? value[1..^1] : value;
}
