DROP PROCEDURE IF EXISTS mart.ETL_MaintainReportedIssueNumericQuestionDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainReportedIssueNumericQuestionDimension @reportedIssueNumericAnswerTable mart.ETL_ReportedIssueNumericAnswerTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.ReportedIssueNumericQuestion AS target
    USING (
        SELECT DISTINCT
            a.Question
            ,a.Scale
            ,u.Unit_key
            ,w.Wallet_key
        FROM
            @reportedIssueNumericAnswerTable AS a
            INNER JOIN mart.Unit AS u ON a.UnitCode = u.UnitCode
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON
        target.Question = source.Question
        AND target.Scale = source.Scale
        AND target.Unit_key = source.Unit_key
        AND target.Wallet_key = source.Wallet_key
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            Question
            ,Scale
            ,Unit_key
            ,Wallet_key
        )
        VALUES (
            source.Question
            ,source.Scale
            ,source.Unit_key
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.ReportedIssueNumericQuestion, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
