DROP PROCEDURE IF EXISTS mart.ETL_LoadReportedIssueBranchOptionFact;
GO

CREATE PROCEDURE mart.ETL_LoadReportedIssueBranchOptionFact
    @reportedIssueBranchOptionTable mart.ETL_ReportedIssueBranchOptionTable READONLY
    ,@investigation bit
AS
BEGIN
    SET NOCOUNT ON;

    -- insert missing entries
    INSERT INTO mart.ReportedIssueBranchOptionFact
    (
        -- keys
        ReportedIssue_key
        ,ReportedIssueBranchOption_key
        ,Investigation
        ,Wallet_key
        -- facts
    )
    SELECT DISTINCT
        -- keys
        ri.ReportedIssue_key
        ,ribo.ReportedIssueBranchOption_key
        ,@investigation
        ,w.Wallet_key
        -- facts
    FROM
        @reportedIssueBranchOptionTable AS a
        INNER JOIN mart.ReportedIssue AS ri ON a.ReportedIssueId = ri.ReportedIssueId
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        INNER JOIN mart.ReportedIssueBranchOption AS ribo ON
            w.Wallet_key = ribo.Wallet_key
            AND a.Branch = ribo.Branch
            AND a.[Option] = ribo.[Option];

    PRINT 'INSERT mart.ReportedIssueBranchOptionFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
