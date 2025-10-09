namespace WorkWallet.BI.ClientCore.Exceptions;

/// <summary>
/// Exception thrown when JSON parsing fails during deserialization of API responses.
/// Provides rich context including the target type, problematic JSON content, and specific property path where parsing failed.
/// </summary>
public class JsonParseException(
    Type targetType,
    string? json = null,
    string? propertyPath = null,
    Exception? innerException = null)
    : Exception(
        BuildMessage(targetType, propertyPath),
        innerException)
{
    /// <summary>
    /// The JSON content that failed to parse (truncated to 1000 characters for readability)
    /// </summary>
    public string? Json { get; } = TruncateJson(json);
    
    /// <summary>
    /// The target type that the JSON was being deserialized to
    /// </summary>
    public Type TargetType { get; } = targetType;
    
    /// <summary>
    /// The specific property path where parsing failed (if available)
    /// </summary>
    public string? PropertyPath { get; } = propertyPath;

    private static string BuildMessage(Type targetType, string? propertyPath) =>
        $"Failed to parse JSON to {targetType.Name}" +
        (propertyPath != null ? $" at property '{propertyPath}'" : "");

    private static string? TruncateJson(string? json) =>
        json?.Length > 1000 ? json[..1000] + "..." : json;
}
