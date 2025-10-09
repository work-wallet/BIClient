using WorkWallet.BI.ClientCore.Models;

namespace WorkWallet.BI.ClientCore.Utils;

public static class PaginationLogic
{
    /// <summary>
    /// Determines if pagination should continue based on the context.
    /// Continues when the number of records returned equals the page size,
    /// indicating there may be more pages available.
    /// </summary>
    public static bool ShouldContinuePaging(Context context) => context.Count == context.PageSize;
}
