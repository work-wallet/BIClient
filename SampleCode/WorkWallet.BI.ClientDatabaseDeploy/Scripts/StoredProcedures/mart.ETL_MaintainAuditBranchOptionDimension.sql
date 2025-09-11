DROP PROCEDURE IF EXISTS mart.ETL_MaintainAuditBranchOptionDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainAuditBranchOptionDimension @auditBranchOptionTable mart.ETL_AuditBranchOptionTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.AuditBranchOption AS target
    USING (
        SELECT DISTINCT
            a.BranchId
            ,a.OptionId
            ,a.Branch
            ,a.[Value]
            ,a.[Order]
            ,a.Section
            ,a.OrderInSection
            ,w.Wallet_key
        FROM
            @auditBranchOptionTable AS a
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON target.BranchId = source.BranchId AND target.OptionId = source.OptionId
    WHEN MATCHED AND (
        target.Branch <> source.Branch
        OR target.[Value] <> source.[Value]
        OR target.[Order] <> source.[Order]
        OR target.Section <> source.Section
        OR target.OrderInSection <> source.OrderInSection
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            Branch = source.Branch
            ,[Value] = source.[Value]
            ,[Order] = source.[Order]
            ,Section = source.Section
            ,OrderInSection = source.OrderInSection
            ,Wallet_key = source.Wallet_key
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            BranchId
            ,OptionId
            ,Branch
            ,[Value]
            ,[Order]
            ,Section
            ,OrderInSection
            ,Wallet_key
        ) VALUES (
            source.BranchId
            ,source.OptionId
            ,source.Branch
            ,source.[Value]
            ,source.[Order]
            ,source.Section
            ,source.OrderInSection
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.AuditBranchOption, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
