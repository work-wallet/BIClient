namespace WorkWallet.BI.ClientCore.Exceptions;

public class JsonParseException(
    Type targetType,
    string? json = null,
    string? propertyPath = null,
    Exception? innerException = null)
    : Exception(
        BuildMessage(targetType, propertyPath),
        innerException)
{
    public string? Json { get; } = TruncateJson(json);
    public Type TargetType { get; } = targetType;
    public string? PropertyPath { get; } = propertyPath;

    private static string BuildMessage(Type targetType, string? propertyPath) =>
        $"Failed to parse JSON to {targetType.Name}" +
        (propertyPath != null ? $" at property '{propertyPath}'" : "");

    private static string? TruncateJson(string? json) =>
        json?.Length > 1000 ? json[..1000] + "..." : json;
}
