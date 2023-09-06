DROP PROCEDURE IF EXISTS mart.ETL_MaintainReportedIssuePersonDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainReportedIssuePersonDimension @reportedIssuePersonTable mart.ETL_ReportedIssuePersonTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    -- insert missing entries
    INSERT INTO mart.ReportedIssuePerson
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
        @reportedIssuePersonTable AS a
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        LEFT OUTER JOIN mart.ReportedIssuePerson AS b ON
            w.Wallet_key = b.Wallet_key
            AND a.Question = b.Question
            AND a.[Option] = b.[Option]
    WHERE
        b.Question IS NULL;

    PRINT 'INSERT mart.ReportedIssuePerson, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
