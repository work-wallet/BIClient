DROP PROCEDURE IF EXISTS mart.ETL_MaintainReportedIssueOptionSelectDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainReportedIssueOptionSelectDimension @reportedIssueOptionSelectTable mart.ETL_ReportedIssueOptionSelectTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    -- insert missing entries
    INSERT INTO mart.ReportedIssueOptionSelect
    (
        Question
        ,[Option]
        ,Wallet_key
    )
    SELECT DISTINCT
        a.Question
        ,a.[Option]
        ,w.Wallet_key
    FROM
        @reportedIssueOptionSelectTable AS a
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        LEFT OUTER JOIN mart.ReportedIssueOptionSelect AS b ON
            w.Wallet_key = b.Wallet_key
            AND a.Question = b.Question
            AND a.[Option] = b.[Option]
    WHERE
        b.Question IS NULL;

    PRINT 'INSERT mart.ReportedIssueOptionSelect, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
