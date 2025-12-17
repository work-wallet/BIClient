DROP PROCEDURE IF EXISTS mart.ETL_MaintainPermitBranchOptionDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainPermitBranchOptionDimension @permitToWorkBranchOptionTable mart.ETL_PermitToWorkBranchOptionTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.PermitBranchOption AS target
    USING (
        SELECT DISTINCT
            a.BranchId
            ,a.OptionId
            ,a.Branch
            ,a.[Value]
            ,a.[Order]
            ,a.CategorySectionType
            ,a.Section
            ,a.SectionOrder
            ,a.OrderInSection
            ,w.Wallet_key
        FROM
            @permitToWorkBranchOptionTable AS a
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON target.BranchId = source.BranchId AND target.OptionId = source.OptionId
    WHEN MATCHED AND (
        target.Branch <> source.Branch
        OR target.[Value] <> source.[Value]
        OR target.[Order] <> source.[Order]
        OR target.CategorySectionType <> source.CategorySectionType
        OR target.Section <> source.Section
        OR target.SectionOrder <> source.SectionOrder
        OR target.OrderInSection <> source.OrderInSection
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            Branch = source.Branch
            ,[Value] = source.[Value]
            ,[Order] = source.[Order]
            ,CategorySectionType = source.CategorySectionType
            ,Section = source.Section
            ,SectionOrder = source.SectionOrder
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
            ,CategorySectionType
            ,Section
            ,SectionOrder
            ,OrderInSection
            ,Wallet_key
        ) VALUES (
            source.BranchId
            ,source.OptionId
            ,source.Branch
            ,source.[Value]
            ,source.[Order]
            ,source.CategorySectionType
            ,source.Section
            ,source.SectionOrder
            ,source.OrderInSection
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.PermitBranchOption, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
