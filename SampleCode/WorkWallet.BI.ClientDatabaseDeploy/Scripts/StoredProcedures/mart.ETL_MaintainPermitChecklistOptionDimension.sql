DROP PROCEDURE IF EXISTS mart.ETL_MaintainPermitChecklistOptionDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainPermitChecklistOptionDimension @permitToWorkChecklistAnswerTable mart.ETL_PermitToWorkChecklistAnswerTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.PermitChecklistOption AS target
    USING (
        SELECT DISTINCT
            a.ChecklistId
            ,a.OptionId
            ,a.Question
            ,a.[Option]
            ,a.Mandatory
            ,a.[Order]
            ,a.CategorySectionTypeId
            ,a.CategorySectionType
            ,a.SectionId
            ,a.Section
            ,a.SectionOrder
            ,a.OrderInSection
            ,w.Wallet_key
        FROM
            @permitToWorkChecklistAnswerTable AS a
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON target.ChecklistId = source.ChecklistId AND target.OptionId = source.OptionId
    WHEN MATCHED AND (
        target.Question <> source.Question
        OR target.[Option] <> source.[Option]
        OR target.Mandatory <> source.Mandatory
        OR target.[Order] <> source.[Order]
        OR target.CategorySectionTypeId <> source.CategorySectionTypeId
        OR target.CategorySectionType <> source.CategorySectionType
        OR target.SectionId <> source.SectionId
        OR target.Section <> source.Section
        OR target.SectionOrder <> source.SectionOrder
        OR target.OrderInSection <> source.OrderInSection
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            Question = source.Question
            ,[Option] = source.[Option]
            ,Mandatory = source.Mandatory
            ,[Order] = source.[Order]
            ,CategorySectionTypeId = source.CategorySectionTypeId
            ,CategorySectionType = source.CategorySectionType
            ,SectionId = source.SectionId
            ,Section = source.Section
            ,SectionOrder = source.SectionOrder
            ,OrderInSection = source.OrderInSection
            ,Wallet_key = source.Wallet_key
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            ChecklistId
            ,OptionId
            ,Question
            ,[Option]
            ,Mandatory
            ,[Order]
            ,CategorySectionTypeId
            ,CategorySectionType
            ,SectionId
            ,Section
            ,SectionOrder
            ,OrderInSection
            ,Wallet_key
        ) VALUES (
            source.ChecklistId
            ,source.OptionId
            ,source.Question
            ,source.[Option]
            ,source.Mandatory
            ,source.[Order]
            ,source.CategorySectionTypeId
            ,source.CategorySectionType
            ,source.SectionId
            ,source.Section
            ,source.SectionOrder
            ,source.OrderInSection
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.PermitChecklistOption, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
