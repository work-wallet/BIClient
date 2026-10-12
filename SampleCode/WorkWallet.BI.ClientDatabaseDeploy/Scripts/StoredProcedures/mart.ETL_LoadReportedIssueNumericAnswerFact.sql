DROP PROCEDURE IF EXISTS mart.ETL_LoadReportedIssueNumericAnswerFact;
GO

CREATE PROCEDURE mart.ETL_LoadReportedIssueNumericAnswerFact
    @reportedIssueNumericAnswerTable mart.ETL_ReportedIssueNumericAnswerTable READONLY
    ,@investigation bit
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO mart.ReportedIssueNumericAnswerFact
    (
        -- keys
        ReportedIssue_key
        ,NumberId
        ,Investigation
        ,ReportedIssueNumericQuestion_key
        ,Wallet_key
        -- facts
        ,Answer
    )
    SELECT
        -- keys
        ri.ReportedIssue_key
        ,a.NumberId
        ,@investigation
        ,q.ReportedIssueNumericQuestion_key
        ,w.Wallet_key
        -- facts
        ,a.Answer
    FROM
        @reportedIssueNumericAnswerTable AS a
        INNER JOIN mart.ReportedIssue AS ri ON a.ReportedIssueId = ri.ReportedIssueId
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        INNER JOIN mart.Unit AS u ON a.UnitCode = u.UnitCode
        INNER JOIN mart.ReportedIssueNumericQuestion AS q ON
            w.Wallet_key = q.Wallet_key
            AND a.Question = q.Question
            AND a.Scale = q.Scale
            AND u.Unit_key = q.Unit_key;

    PRINT 'INSERT mart.ReportedIssueNumericAnswerFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
