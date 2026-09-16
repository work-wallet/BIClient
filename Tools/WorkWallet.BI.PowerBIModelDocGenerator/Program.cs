using System.Text;
using System.Text.RegularExpressions;
using WorkWallet.BI.PowerBIModelDocGenerator;

var checkOnly = args.Contains("--check", StringComparer.OrdinalIgnoreCase);

var repoRoot = FindRepoRoot(Directory.GetCurrentDirectory());
var powerBiSamplesDir = Path.Combine(repoRoot, "PowerBISamples");
var indexPath = Path.Combine(repoRoot, "PowerBISamplesModels.md");
// A single monolithic file with every diagram got too large for editors to render reliably,
// so each module gets its own file under this folder, linked from the index.
var modulesDirName = "PowerBISamplesModels";
var modulesDir = Path.Combine(repoRoot, modulesDirName);

var datasetFolders = Directory.GetDirectories(powerBiSamplesDir)
    .Select(d => new DirectoryInfo(d).Name)
    .OrderBy(n => n, StringComparer.Ordinal)
    .ToList();

var datasets = new List<(string FolderName, string Title, List<(DiagramPage Page, string Mermaid)> Pages)>();

foreach (var folderName in datasetFolders)
{
    var semanticModelDir = Path.Combine(powerBiSamplesDir, folderName, $"{folderName}.SemanticModel");
    var definitionDir = Path.Combine(semanticModelDir, "definition");
    var diagramLayoutPath = Path.Combine(semanticModelDir, "diagramLayout.json");
    var relationshipsPath = Path.Combine(definitionDir, "relationships.tmdl");
    var tablesDir = Path.Combine(definitionDir, "tables");

    if (!File.Exists(diagramLayoutPath) || !File.Exists(relationshipsPath) || !Directory.Exists(tablesDir))
    {
        Console.Error.WriteLine($"Skipping '{folderName}': expected semantic model files not found under {semanticModelDir}");
        continue;
    }

    var tables = Directory.GetFiles(tablesDir, "*.tmdl")
        .Select(TmdlReader.ReadTable)
        .ToDictionary(t => t.Name, StringComparer.Ordinal);

    // Power BI's auto-generated date-hierarchy tables (one per date column) are never shown
    // in the model diagram, so relationships to/from them would only produce misleading FK tags.
    var relationships = TmdlReader.ReadRelationships(relationshipsPath)
        .Where(r => !IsAutoDateTable(r.FromTable) && !IsAutoDateTable(r.ToTable))
        .ToList();
    var pages = DiagramLayoutReader.ReadPages(diagramLayoutPath);

    var renderedPages = pages
        .Select(page => (Page: page, Mermaid: MermaidErDiagramBuilder.Build(page, tables, relationships)))
        .ToList();

    datasets.Add((folderName, ToDisplayTitle(folderName), renderedPages));
}

// Relative (repo-root-relative, forward-slash) path -> file content, for every generated file.
var outputs = new Dictionary<string, string>(StringComparer.Ordinal)
{
    ["PowerBISamplesModels.md"] = BuildIndexMarkdown(datasets),
};

foreach (var dataset in datasets)
{
    var relativePath = $"{modulesDirName}/{dataset.FolderName}.md";
    outputs[relativePath] = BuildModuleMarkdown(dataset.Title, dataset.Pages);
}

if (checkOnly)
{
    var problems = new List<string>();

    foreach (var (relativePath, expectedContent) in outputs)
    {
        var fullPath = Path.Combine(repoRoot, relativePath.Replace('/', Path.DirectorySeparatorChar));
        var current = File.Exists(fullPath) ? File.ReadAllText(fullPath) : string.Empty;
        if (!string.Equals(NormalizeLineEndings(current), NormalizeLineEndings(expectedContent), StringComparison.Ordinal))
        {
            problems.Add($"{relativePath} is missing or out of date.");
        }
    }

    if (Directory.Exists(modulesDir))
    {
        var expectedFullPaths = outputs.Keys
            .Select(p => Path.Combine(repoRoot, p.Replace('/', Path.DirectorySeparatorChar)))
            .ToHashSet(StringComparer.OrdinalIgnoreCase);
        var orphans = Directory.GetFiles(modulesDir, "*.md", SearchOption.AllDirectories)
            .Where(f => !expectedFullPaths.Contains(f));
        problems.AddRange(orphans.Select(f => $"{Path.GetRelativePath(repoRoot, f)} is an orphaned generated file."));
    }

    if (problems.Count > 0)
    {
        foreach (var problem in problems)
        {
            Console.Error.WriteLine(problem);
        }

        Console.Error.WriteLine("Run this tool without --check to regenerate the docs.");
        return 1;
    }

    Console.WriteLine("Power BI model docs are up to date.");
    return 0;
}

// Regenerate the modules folder from scratch so renamed/removed diagram pages don't leave orphans.
if (Directory.Exists(modulesDir))
{
    Directory.Delete(modulesDir, recursive: true);
}

foreach (var (relativePath, content) in outputs)
{
    var fullPath = Path.Combine(repoRoot, relativePath.Replace('/', Path.DirectorySeparatorChar));
    Directory.CreateDirectory(Path.GetDirectoryName(fullPath)!);
    File.WriteAllText(fullPath, content);
}

Console.WriteLine($"Wrote {indexPath} and {outputs.Count - 1} module file(s) under {modulesDir}");
return 0;

static string FindRepoRoot(string startDirectory)
{
    var dir = new DirectoryInfo(startDirectory);
    while (dir is not null)
    {
        if (File.Exists(Path.Combine(dir.FullName, "PowerBISamplesModels.md")))
        {
            return dir.FullName;
        }

        dir = dir.Parent;
    }

    throw new InvalidOperationException(
        $"Could not locate repo root (no PowerBISamplesModels.md found above '{startDirectory}').");
}

// "ReportedIssues" -> "Reported Issues"; acronyms like "PPE" are left untouched.
static string ToDisplayTitle(string folderName) => Regex.Replace(folderName, "(?<=[a-z])(?=[A-Z])", " ");

static bool IsAutoDateTable(string tableName) =>
    tableName.StartsWith("LocalDateTable_", StringComparison.Ordinal) ||
    tableName.StartsWith("DateTableTemplate_", StringComparison.Ordinal);

static string Slugify(string heading) =>
    Regex.Replace(heading.ToLowerInvariant().Replace(' ', '-'), "[^a-z0-9-]", string.Empty);

static string NormalizeLineEndings(string text) => text.Replace("\r\n", "\n");

static string BuildIndexMarkdown(List<(string FolderName, string Title, List<(DiagramPage Page, string Mermaid)> Pages)> datasets)
{
    var sb = new StringBuilder();

    sb.AppendLine("# Power BI Samples - Semantic Models");
    sb.AppendLine();
    sb.AppendLine("For convenience, entity-relationship diagrams for the Power BI semantic models used in the");
    sb.AppendLine("sample reports are presented here. They give a sense of what data is available in each");
    sb.AppendLine("semantic model and how the tables relate, without installing Power BI Desktop or having a");
    sb.AppendLine("Power BI licence.");
    sb.AppendLine();
    sb.AppendLine("Each linked page corresponds to one page of the Power BI Desktop model view for that");
    sb.AppendLine("semantic model (the built-in \"All tables\" page is skipped, since it is overwhelming). The");
    sb.AppendLine("Wallet dimension table is omitted from every diagram for clarity. Dashed lines indicate an");
    sb.AppendLine("inactive relationship. Each column is prefixed with its kind instead of its data type:");
    sb.AppendLine();
    sb.AppendLine("| Prefix | Meaning |");
    sb.AppendLine("| --- | --- |");
    sb.AppendLine("| `attr` | Plain source column |");
    sb.AppendLine("| `calc` | DAX calculated column |");
    sb.AppendLine("| `measure` | DAX measure |");
    sb.AppendLine("| `agg` | Source column with a non-default implicit aggregation (e.g. sum) |");

    foreach (var dataset in datasets)
    {
        sb.AppendLine();
        sb.AppendLine($"## {dataset.Title}");
        sb.AppendLine();

        var modulePath = $"PowerBISamplesModels/{dataset.FolderName}.md";
        sb.AppendLine($"[{dataset.Title} diagrams]({modulePath})");
        sb.AppendLine();

        foreach (var (page, _) in dataset.Pages)
        {
            var heading = $"{dataset.Title} - {page.Name}";
            sb.AppendLine($"* [{heading}]({modulePath}#{Slugify(heading)})");
        }
    }

    sb.AppendLine();
    sb.AppendLine("## For Maintainers");
    sb.AppendLine();
    sb.AppendLine("This file and the linked pages under `PowerBISamplesModels/` are auto-generated - do not");
    sb.AppendLine("edit them by hand. Update the relevant `.SemanticModel` project(s) in Power BI Desktop");
    sb.AppendLine("(including adding/arranging diagram pages), then regenerate the docs by running:");
    sb.AppendLine();
    sb.AppendLine("```powershell");
    sb.AppendLine("dotnet run --project Tools/WorkWallet.BI.PowerBIModelDocGenerator/WorkWallet.BI.PowerBIModelDocGenerator.csproj");
    sb.AppendLine("```");

    return sb.ToString();
}

static string BuildModuleMarkdown(string datasetTitle, List<(DiagramPage Page, string Mermaid)> pages)
{
    var sb = new StringBuilder();

    sb.AppendLine($"# {datasetTitle}");
    sb.AppendLine();
    sb.AppendLine("[<- Back to index](../PowerBISamplesModels.md)");

    foreach (var (page, mermaid) in pages)
    {
        sb.AppendLine();
        sb.AppendLine($"## {datasetTitle} - {page.Name}");
        sb.AppendLine();
        sb.AppendLine(mermaid);
    }

    return sb.ToString();
}
