using System.Text;
using System.Text.RegularExpressions;

namespace WorkWallet.BI.PowerBIModelDocGenerator;

/// <summary>Renders one Power BI Desktop diagram page as a Mermaid `erDiagram` code block.</summary>
public static class MermaidErDiagramBuilder
{
    public static string Build(
        DiagramPage page,
        IReadOnlyDictionary<string, TmdlTable> tablesByName,
        IReadOnlyList<TmdlRelationship> relationships)
    {
        var pageTableNames = page.Nodes.Select(n => n.NodeIndex).ToHashSet(StringComparer.Ordinal);

        var sb = new StringBuilder();
        sb.AppendLine("```mermaid");
        // Explicit theme keeps relationship lines visible regardless of viewer theme.
        sb.AppendLine("---");
        sb.AppendLine("config:");
        sb.AppendLine("  theme: neutral");
        sb.AppendLine("---");
        sb.AppendLine("erDiagram");

        foreach (var node in page.Nodes)
        {
            if (!tablesByName.TryGetValue(node.NodeIndex, out var table))
            {
                continue;
            }

            sb.AppendLine($"    {Quote(table.Name)} {{");
            foreach (var column in table.Columns)
            {
                // Mermaid attribute names can't contain spaces; drop them rather than
                // substituting an underscore, so e.g. "Is Latest" becomes "IsLatest".
                var attributeName = SanitizeAttributeName(column.Name);
                sb.AppendLine($"        {column.Category} {attributeName}");
            }
            sb.AppendLine("    }");
        }

        foreach (var relationship in relationships)
        {
            if (!pageTableNames.Contains(relationship.FromTable) || !pageTableNames.Contains(relationship.ToTable))
            {
                continue;
            }

            // Solid line for active relationships, dashed for inactive (matches the greyed-out
            // dashed lines Power BI Desktop itself draws for inactive relationships).
            var line = relationship.IsActive ? "--" : "..";
            sb.AppendLine(
                $"    {Quote(relationship.FromTable)} }}o{line}|| {Quote(relationship.ToTable)} : {Quote(relationship.FromColumn)}");
        }

        sb.Append("```");
        return sb.ToString();
    }

    private static string Quote(string value) => $"\"{value}\"";

    private static string SanitizeAttributeName(string value) =>
        Regex.Replace(Regex.Replace(value, @"\s+", string.Empty), @"[^A-Za-z0-9_]", "_");
}
