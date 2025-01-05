DROP PROCEDURE IF EXISTS mart.ETL_MaintainAuditNumericQuestionDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainAuditNumericQuestionDimension @auditNumbericAnswerTable mart.ETL_AuditNumericAnswerTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.AuditNumericQuestion AS target
    USING (
        SELECT DISTINCT
            a.QuestionId,
            a.Question,
            a.Mandatory,
            a.Scale,
            u.Unit_key,
            w.Wallet_key
        FROM
            @auditNumbericAnswerTable AS a
            INNER JOIN mart.Unit AS u ON a.UnitCode = u.UnitCode
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON target.QuestionId = source.QuestionId
    WHEN MATCHED AND (
        target.Question <> source.Question
        OR target.Mandatory <> source.Mandatory
        OR target.Scale <> source.Scale
        OR target.Unit_key <> source.Unit_key
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            Question = source.Question,
            Mandatory = source.Mandatory,
            Scale = source.Scale,
            Unit_key = source.Unit_key,
            Wallet_key = source.Wallet_key,
            _edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            QuestionId,
            Question,
            Mandatory,
            Scale,
            Unit_key,
            Wallet_key
        ) VALUES (
            source.QuestionId,
            source.Question,
            source.Mandatory,
            source.Scale,
            source.Unit_key,
            source.Wallet_key
        );

    PRINT 'MERGE mart.AuditNumericQuestion, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
