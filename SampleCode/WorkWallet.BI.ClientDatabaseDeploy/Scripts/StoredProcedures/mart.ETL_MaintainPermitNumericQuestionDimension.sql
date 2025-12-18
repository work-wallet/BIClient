DROP PROCEDURE IF EXISTS mart.ETL_MaintainPermitNumericQuestionDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainPermitNumericQuestionDimension @permitToWorkNumericAnswerTable mart.ETL_PermitToWorkNumericAnswerTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.PermitNumericQuestion AS target
    USING (
        SELECT DISTINCT
            a.QuestionId
            ,a.Question
            ,a.Mandatory
            ,a.Scale
            ,u.Unit_key
            ,a.CategorySectionTypeId
            ,a.CategorySectionType
            ,a.SectionId
            ,a.Section
            ,a.SectionOrder
            ,a.OrderInSection
            ,w.Wallet_key
        FROM
            @permitToWorkNumericAnswerTable AS a
            INNER JOIN mart.Unit AS u ON a.UnitCode = u.UnitCode
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON target.QuestionId = source.QuestionId
    WHEN MATCHED AND (
        target.Question <> source.Question
        OR target.Mandatory <> source.Mandatory
        OR target.Scale <> source.Scale
        OR target.Unit_key <> source.Unit_key
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
            ,Mandatory = source.Mandatory
            ,Scale = source.Scale
            ,Unit_key = source.Unit_key
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
            QuestionId
            ,Question
            ,Mandatory
            ,Scale
            ,Unit_key
            ,CategorySectionTypeId
            ,CategorySectionType
            ,SectionId
            ,Section
            ,SectionOrder
            ,OrderInSection
            ,Wallet_key
        ) VALUES (
            source.QuestionId
            ,source.Question
            ,source.Mandatory
            ,source.Scale
            ,source.Unit_key
            ,source.CategorySectionTypeId
            ,source.CategorySectionType
            ,source.SectionId
            ,source.Section
            ,source.SectionOrder
            ,source.OrderInSection
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.PermitNumericQuestion, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
