namespace WorkWallet.BI.ClientServices.Processor;

internal static class DataSets
{
    // dictionary holding all the data sets and associated log types (as used in the database table mart.ETL_ChangeDetection for tracking)
    private static Dictionary<string, string> _entries = new()
    {
        { "ReportedIssues", "REPORTED_ISSUE_UPDATED" },
        { "Inductions", "INDUCTION_UPDATED" },
        { "Permits", "PERMIT_UPDATED" },
        { "Actions", "ACTION_UPDATED" },
        { "Assets", "ASSET_UPDATED" },
        { "SafetyCards", "SAFETY_CARD_UPDATED" },
        { "Audits", "AUDIT2_UPDATED" },
        { "PPEStocks", "PPE_STOCK_UPDATED" },
        { "PPEStockHistories", "PPE_STOCK_HISTORY_UPDATED" },
        { "PPEAssignments", "PPE_ASSIGNMENT_UPDATED" }
    };

    internal static IReadOnlyDictionary<string, string> Entries => _entries.AsReadOnly();
}
