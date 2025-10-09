DROP PROCEDURE IF EXISTS mart.ETL_MaintainReportedIssueBranchOptionDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainReportedIssueBranchOptionDimension @reportedIssueBranchOptionTable mart.ETL_ReportedIssueBranchOptionTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.ReportedIssueBranchOption AS target
    USING (
        SELECT DISTINCT
            a.Branch
            ,a.[Option]
            ,w.Wallet_key
        FROM
            @reportedIssueBranchOptionTable AS a
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON
        target.Wallet_key = source.Wallet_key
        AND target.Branch = source.Branch
        AND target.[Option] = source.[Option]
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            Branch
            ,[Option]
            ,Wallet_key
        )
        VALUES (
            source.Branch
            ,source.[Option]
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.ReportedIssueBranchOption, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
