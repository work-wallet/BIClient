DROP PROCEDURE IF EXISTS mart.ETL_MaintainReportedIssueOptionSelectDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainReportedIssueOptionSelectDimension @reportedIssueOptionSelectTable mart.ETL_ReportedIssueOptionSelectTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.ReportedIssueOptionSelect AS target
    USING (
        SELECT DISTINCT
            a.Question
            ,a.[Option]
            ,w.Wallet_key
        FROM
            @reportedIssueOptionSelectTable AS a
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON
        target.Question = source.Question
        AND target.[Option] = source.[Option]
        AND target.Wallet_key = source.Wallet_key
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            Question
            ,[Option]
            ,Wallet_key
        )
        VALUES (
            source.Question
            ,source.[Option]
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.ReportedIssueOptionSelect, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
