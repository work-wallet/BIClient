namespace WorkWallet.BI.ClientCore.Models;

public record PageResult(Context Context, string Json, bool HasMorePages);

public record ProcessingResult(long SynchronizationVersion, int TotalRecords);

public record ProcessingState(long? LastSynchronizationVersion);
