DROP PROCEDURE IF EXISTS mart.ETL_MaintainPermitChecklistAnswerDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainPermitChecklistAnswerDimension @permitToWorkChecklistAnswerTable mart.ETL_PermitToWorkChecklistAnswerTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.PermitChecklistAnswer AS target
    USING (
        SELECT DISTINCT
            a.CategorySectionType
            ,a.Question
            ,a.[Option]
            ,a.[Order]
            ,a.Section
            ,a.SectionOrder
            ,a.OrderInSection
            ,w.Wallet_key
        FROM
            @permitToWorkChecklistAnswerTable AS a
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON
        target.Wallet_key = source.Wallet_key
        AND target.Question = source.Question
        AND target.[Option] = source.[Option]
    WHEN MATCHED AND (
        target.CategorySectionType <> source.CategorySectionType
        OR target.[Order] <> source.[Order]
        OR target.Section <> source.Section
        OR target.SectionOrder <> source.SectionOrder
        OR target.OrderInSection <> source.OrderInSection
    )
    THEN
        UPDATE SET
            CategorySectionType = source.CategorySectionType
            ,[Order] = source.[Order]
            ,Section = source.Section
            ,SectionOrder = source.SectionOrder
            ,OrderInSection = source.OrderInSection
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            CategorySectionType
            ,Question
            ,[Option]
            ,[Order]
            ,Section
            ,SectionOrder
            ,OrderInSection
            ,Wallet_key
        ) VALUES (
            source.CategorySectionType
            ,source.Question
            ,source.[Option]
            ,source.[Order]
            ,source.Section
            ,source.SectionOrder
            ,source.OrderInSection
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.PermitChecklistAnswer, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
