namespace WorkWallet.BI.ClientCore.Exceptions;

/// <summary>
/// Exception thrown when the requested page size exceeds the maximum allowed value for a dataset.
/// Contains the maximum allowed page size to enable automatic retry with a smaller value.
/// </summary>
public class PageSizeExceededException(
    int requestedPageSize, 
    int maxPageSize, 
    string? message = null) : Exception(message ?? $"PageSize {requestedPageSize} exceeds maximum allowed value of {maxPageSize}")
{
    /// <summary>
    /// The page size that was requested and rejected by the API
    /// </summary>
    public int RequestedPageSize { get; } = requestedPageSize;

    /// <summary>
    /// The maximum page size allowed for this dataset
    /// </summary>
    public int MaxPageSize { get; } = maxPageSize;
}