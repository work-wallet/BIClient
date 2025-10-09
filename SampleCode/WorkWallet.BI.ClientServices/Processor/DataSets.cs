namespace WorkWallet.BI.ClientServices.Processor;

internal static class DataSets
{
    // dictionary holding all the data sets and associated log types (as used in the database table mart.ETL_ChangeDetection for tracking)
    private static Dictionary<string, string> _entries = new()
    {
        { "Actions", "ACTION_UPDATED" },
        { "Assets", "ASSET_UPDATED" },
        { "Audits", "AUDIT2_UPDATED" },
        { "Inductions", "INDUCTION_UPDATED" },
        { "Permits", "PERMIT_UPDATED" },
        { "PPEAssignments", "PPE_ASSIGNMENT_UPDATED" },
        { "PPEStockHistories", "PPE_STOCK_HISTORY_UPDATED" },
        { "PPEStocks", "PPE_STOCK_UPDATED" },
        { "ReportedIssues", "REPORTED_ISSUE_UPDATED" },
        { "SafetyCards", "SAFETY_CARD_UPDATED" }
    };

    internal static IReadOnlyDictionary<string, string> Entries => _entries.AsReadOnly();
}
