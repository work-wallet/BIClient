DROP PROCEDURE IF EXISTS mart.ETL_MaintainReportedIssueBranchOptionDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainReportedIssueBranchOptionDimension @reportedIssueBranchOptionTable mart.ETL_ReportedIssueBranchOptionTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    -- insert missing entries
    INSERT INTO mart.ReportedIssueBranchOption
    (
        Branch
        ,[Option]
        ,Wallet_key
    )
    SELECT DISTINCT
        a.Branch
        ,a.[Option]
        ,w.Wallet_key
    FROM
        @reportedIssueBranchOptionTable AS a
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        LEFT OUTER JOIN mart.ReportedIssueBranchOption AS b ON
            w.Wallet_key = b.Wallet_key
            AND a.Branch = b.Branch
            AND a.[Option] = b.[Option]
    WHERE
        b.Branch IS NULL;

    PRINT 'INSERT mart.ReportedIssueBranchOption, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
