DROP PROCEDURE IF EXISTS mart.ETL_LoadAuditChecklistAnswerFact;
GO

CREATE PROCEDURE mart.ETL_LoadAuditChecklistAnswerFact
    @auditChecklistAnswerTable mart.ETL_AuditChecklistAnswerTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO mart.AuditChecklistAnswerFact
    (
        Audit_key
        ,AuditChecklistOption_key
        ,Wallet_key
    )
    SELECT DISTINCT
        a.Audit_key
        ,q.AuditChecklistOption_key
        ,w.Wallet_key
    FROM
        @auditChecklistAnswerTable AS x
        INNER JOIN mart.[Audit] AS a ON x.AuditId = a.AuditId
        INNER JOIN mart.AuditChecklistOption AS q ON x.ChecklistId = q.ChecklistId AND x.OptionId = q.OptionId
        INNER JOIN mart.Wallet AS w ON x.WalletId = w.WalletId;

    PRINT 'INSERT mart.AuditChecklistAnswerFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
