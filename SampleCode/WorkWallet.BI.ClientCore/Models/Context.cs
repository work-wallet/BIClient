namespace WorkWallet.BI.ClientCore.Models;

public class Context
{
    public required string Dataset { get; set; }
    public int Version { get; set; }
    public int Count { get; set; }
    public int FullCount { get; set; }
    public int PageNumber { get; set; }
    public int PageSize { get; set; }
    public long? LastSynchronizationVersion { get; set; }
    public long SynchronizationVersion { get; set; }
    public required string Error { get; set; }
    public DateTime UTC { get; set; }
    public int ExecutionTimeMs { get; set; }
    public bool? Beta { get; set; }
    public int MinValidSynchronizationVersion { get; set; }
}
