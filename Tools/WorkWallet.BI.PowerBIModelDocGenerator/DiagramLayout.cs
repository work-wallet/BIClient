using System.Text.Json;

namespace WorkWallet.BI.PowerBIModelDocGenerator;

/// <summary>Minimal shape of a Power BI Desktop `diagramLayout.json` file.</summary>
public sealed class DiagramLayoutRoot
{
    public List<DiagramPage> Diagrams { get; set; } = [];
}

public sealed class DiagramPage
{
    public string Name { get; set; } = string.Empty;

    public List<DiagramNode> Nodes { get; set; } = [];
}

public sealed class DiagramNode
{
    public string NodeIndex { get; set; } = string.Empty;
}

public static class DiagramLayoutReader
{
    private static readonly JsonSerializerOptions Options = new()
    {
        PropertyNameCaseInsensitive = true,
    };

    /// <summary>
    /// Reads the pages from a diagramLayout.json, skipping the built-in "All tables" page,
    /// preserving the ordinal (declaration) order used by Power BI Desktop.
    /// </summary>
    public static List<DiagramPage> ReadPages(string diagramLayoutJsonPath)
    {
        var json = File.ReadAllText(diagramLayoutJsonPath);
        var root = JsonSerializer.Deserialize<DiagramLayoutRoot>(json, Options)
            ?? throw new InvalidOperationException($"Could not parse {diagramLayoutJsonPath}");

        return
        [
            .. root.Diagrams
                .Where(d => !string.Equals(d.Name, "All tables", StringComparison.OrdinalIgnoreCase))
        ];
    }
}
