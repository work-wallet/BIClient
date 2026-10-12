DROP PROCEDURE IF EXISTS mart.ETL_LoadReportedIssueDateTimeAnswerFact;
GO

CREATE PROCEDURE mart.ETL_LoadReportedIssueDateTimeAnswerFact
    @reportedIssueDateTimeAnswerTable mart.ETL_ReportedIssueDateTimeAnswerTable READONLY
    ,@investigation bit
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO mart.ReportedIssueDateTimeAnswerFact
    (
        -- keys
        ReportedIssue_key
        ,DateTimeId
        ,Investigation
        ,ReportedIssueDateTimeQuestion_key
        ,Wallet_key
        -- facts
        ,AnswerDateTime
        ,AnswerDate
        ,AnswerTime
    )
    SELECT
        -- keys
        ri.ReportedIssue_key
        ,a.DateTimeId
        ,@investigation
        ,q.ReportedIssueDateTimeQuestion_key
        ,w.Wallet_key
        -- facts (only the parts the question captures are meaningful)
        ,CASE WHEN q.[Date] = 1 AND q.[Time] = 1 THEN a.Answer ELSE NULL END AS AnswerDateTime
        ,CASE WHEN q.[Date] = 1 THEN a.Answer ELSE NULL END AS AnswerDate
        ,CASE WHEN q.[Time] = 1 THEN a.Answer ELSE NULL END AS AnswerTime
    FROM
        @reportedIssueDateTimeAnswerTable AS a
        INNER JOIN mart.ReportedIssue AS ri ON a.ReportedIssueId = ri.ReportedIssueId
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        INNER JOIN mart.ReportedIssueDateTimeQuestion AS q ON
            w.Wallet_key = q.Wallet_key
            AND a.Question = q.Question
            AND a.[Date] = q.[Date]
            AND a.[Time] = q.[Time];

    PRINT 'INSERT mart.ReportedIssueDateTimeAnswerFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
