DROP PROCEDURE IF EXISTS mart.ETL_MaintainReportedIssueDateTimeQuestionDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainReportedIssueDateTimeQuestionDimension @reportedIssueDateTimeAnswerTable mart.ETL_ReportedIssueDateTimeAnswerTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.ReportedIssueDateTimeQuestion AS target
    USING (
        SELECT DISTINCT
            a.Question
            ,a.[Date]
            ,a.[Time]
            ,w.Wallet_key
        FROM
            @reportedIssueDateTimeAnswerTable AS a
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON
        target.Question = source.Question
        AND target.[Date] = source.[Date]
        AND target.[Time] = source.[Time]
        AND target.Wallet_key = source.Wallet_key
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            Question
            ,[Date]
            ,[Time]
            ,Wallet_key
        )
        VALUES (
            source.Question
            ,source.[Date]
            ,source.[Time]
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.ReportedIssueDateTimeQuestion, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
