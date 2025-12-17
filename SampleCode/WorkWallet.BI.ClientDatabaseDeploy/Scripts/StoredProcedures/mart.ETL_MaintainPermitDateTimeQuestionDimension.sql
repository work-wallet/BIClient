DROP PROCEDURE IF EXISTS mart.ETL_MaintainPermitDateTimeQuestionDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainPermitDateTimeQuestionDimension @permitToWorkDateTimeAnswerTable mart.ETL_PermitToWorkDateTimeAnswerTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.PermitDateTimeQuestion AS target
    USING (
        SELECT DISTINCT
            a.QuestionId
            ,a.Question
            ,a.[Date]
            ,a.[Time]
            ,a.CategorySectionType
            ,a.Section
            ,a.SectionOrder
            ,a.OrderInSection
            ,w.Wallet_key
        FROM
            @permitToWorkDateTimeAnswerTable AS a
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON target.QuestionId = source.QuestionId
    WHEN MATCHED AND (
        target.Question <> source.Question
        OR target.[Date] <> source.[Date]
        OR target.[Time] <> source.[Time]
        OR target.CategorySectionType <> source.CategorySectionType
        OR target.Section <> source.Section
        OR target.SectionOrder <> source.SectionOrder
        OR target.OrderInSection <> source.OrderInSection
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            Question = source.Question
            ,[Date] = source.[Date]
            ,[Time] = source.[Time]
            ,CategorySectionType = source.CategorySectionType
            ,Section = source.Section
            ,SectionOrder = source.SectionOrder
            ,OrderInSection = source.OrderInSection
            ,Wallet_key = source.Wallet_key
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            QuestionId
            ,Question
            ,[Date]
            ,[Time]
            ,CategorySectionType
            ,Section
            ,SectionOrder
            ,OrderInSection
            ,Wallet_key
        ) VALUES (
            source.QuestionId
            ,source.Question
            ,source.[Date]
            ,source.[Time]
            ,source.CategorySectionType
            ,source.Section
            ,source.SectionOrder
            ,source.OrderInSection
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.PermitDateTimeQuestion, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
