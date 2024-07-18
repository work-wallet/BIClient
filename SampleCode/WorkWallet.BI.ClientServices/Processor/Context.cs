namespace WorkWallet.BI.ClientServices.Processor;

public class Context
{
    public int Version { get; set; }
    public int Count { get; set; }
    public int FullCount { get; set; }
    public int PageNumber { get; set; }
    public int PageSize { get; set; }
    public long? LastSynchronizationVersion { get; set; }
    public long SynchronizationVersion { get; set; }
}
