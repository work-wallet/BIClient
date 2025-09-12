namespace WorkWallet.BI.ClientCore.Models;

public record PageResult(Context Context, string Json);

public record ProcessingResult(long SynchronizationVersion, int TotalRecords);

public record ProcessingState(long? LastSynchronizationVersion);
