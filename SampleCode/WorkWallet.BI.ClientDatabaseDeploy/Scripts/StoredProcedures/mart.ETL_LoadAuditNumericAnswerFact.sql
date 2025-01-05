DROP PROCEDURE IF EXISTS mart.ETL_LoadAuditNumericAnswerFact;
GO

CREATE PROCEDURE mart.ETL_LoadAuditNumericAnswerFact
    @auditNumericAnswerTable mart.ETL_AuditNumericAnswerTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO mart.AuditNumericAnswerFact
    (
        Audit_key
        ,AuditNumericQuestion_key
        ,Answer
        ,Wallet_key
    )
    SELECT DISTINCT
        a.Audit_key
        ,q.AuditNumericQuestion_key
        ,x.Answer
        ,w.Wallet_key
    FROM
        @auditNumericAnswerTable AS x
        INNER JOIN mart.[Audit] AS a ON x.AuditId = a.AuditId
        INNER JOIN mart.AuditNumericQuestion AS q ON x.QuestionId = q.QuestionId
        INNER JOIN mart.Wallet AS w ON x.WalletId = w.WalletId;

    PRINT 'INSERT mart.AuditNumericAnswerFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
