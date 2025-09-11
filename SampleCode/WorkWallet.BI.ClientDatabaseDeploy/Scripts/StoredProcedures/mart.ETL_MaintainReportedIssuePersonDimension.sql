DROP PROCEDURE IF EXISTS mart.ETL_MaintainReportedIssuePersonDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainReportedIssuePersonDimension @reportedIssuePersonTable mart.ETL_ReportedIssuePersonTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.ReportedIssuePerson AS target
    USING (
        SELECT DISTINCT
            a.Question
            ,a.[Option]
            ,w.Wallet_key
        FROM
            @reportedIssuePersonTable AS a
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

    PRINT 'MERGE mart.ReportedIssuePerson, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
