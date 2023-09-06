DROP PROCEDURE IF EXISTS mart.ETL_LoadReportedIssuePersonFact;
GO

CREATE PROCEDURE mart.ETL_LoadReportedIssuePersonFact
    @reportedIssuePersonTable mart.ETL_ReportedIssuePersonTable READONLY
    ,@investigation bit
AS
BEGIN
    SET NOCOUNT ON;

    -- insert missing entries
    INSERT INTO mart.ReportedIssuePersonFact
    (
        -- keys
        ReportedIssue_key
        ,ReportedIssuePerson_key
        ,Investigation
        ,Wallet_key
        -- facts
    )
    SELECT DISTINCT
        -- keys
        ri.ReportedIssue_key
        ,ribo.ReportedIssuePerson_key
        ,@investigation
        ,w.Wallet_key
        -- facts
    FROM
        @reportedIssuePersonTable AS a
        INNER JOIN mart.ReportedIssue AS ri ON a.ReportedIssueId = ri.ReportedIssueId
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        INNER JOIN mart.ReportedIssuePerson AS ribo ON
            w.Wallet_key = ribo.Wallet_key
            AND a.Question = ribo.Question
            AND a.[Option] = ribo.[Option];

    PRINT 'INSERT mart.ReportedIssuePersonFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
