DROP PROCEDURE IF EXISTS mart.ETL_LoadReportedIssueOptionSelectFact;
GO

CREATE PROCEDURE mart.ETL_LoadReportedIssueOptionSelectFact
    @reportedIssueOptionSelectTable mart.ETL_ReportedIssueOptionSelectTable READONLY
    ,@investigation bit
AS
BEGIN
    SET NOCOUNT ON;

    -- insert missing entries
    INSERT INTO mart.ReportedIssueOptionSelectFact
    (
        -- keys
        ReportedIssue_key
        ,ReportedIssueOptionSelect_key
        ,Investigation
        ,Wallet_key
        -- facts
    )
    SELECT DISTINCT
        -- keys
        ri.ReportedIssue_key
        ,ribo.ReportedIssueOptionSelect_key
        ,@investigation
        ,w.Wallet_key
        -- facts
    FROM
        @reportedIssueOptionSelectTable AS a
        INNER JOIN mart.ReportedIssue AS ri ON a.ReportedIssueId = ri.ReportedIssueId
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        INNER JOIN mart.ReportedIssueOptionSelect AS ribo ON
            w.Wallet_key = ribo.Wallet_key
            AND a.Question = ribo.Question
            AND a.[Option] = ribo.[Option];

    PRINT 'INSERT mart.ReportedIssueOptionSelectFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
