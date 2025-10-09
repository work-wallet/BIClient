DROP PROCEDURE IF EXISTS mart.ETL_MaintainAuditDateTimeQuestionDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainAuditDateTimeQuestionDimension @auditDateTimeAnswerTable mart.ETL_AuditDateTimeAnswerTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.AuditDateTimeQuestion AS target
    USING (
        SELECT DISTINCT
            a.QuestionId
            ,a.Question
            ,a.Mandatory
            ,a.[Date]
            ,a.[Time]
            ,a.Section
            ,a.OrderInSection
            ,w.Wallet_key
        FROM
            @auditDateTimeAnswerTable AS a
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON target.QuestionId = source.QuestionId
    WHEN MATCHED AND (
        target.Question <> source.Question
        OR target.Mandatory <> source.Mandatory
        OR target.[Date] <> source.[Date]
        OR target.[Time] <> source.[Time]
        OR target.Section <> source.Section
        OR target.OrderInSection <> source.OrderInSection
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            Question = source.Question
            ,Mandatory = source.Mandatory
            ,[Date] = source.[Date]
            ,[Time] = source.[Time]
            ,Section = source.Section
            ,OrderInSection = source.OrderInSection
            ,Wallet_key = source.Wallet_key
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            QuestionId
            ,Question
            ,Mandatory
            ,[Date]
            ,[Time]
            ,Section
            ,OrderInSection
            ,Wallet_key
        ) VALUES (
            source.QuestionId
            ,source.Question
            ,source.Mandatory
            ,source.[Date]
            ,source.[Time]
            ,source.Section
            ,source.OrderInSection
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.AuditDateTimeQuestion, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
