DROP PROCEDURE IF EXISTS mart.ETL_DeleteAuditFacts;
GO

CREATE PROCEDURE mart.ETL_DeleteAuditFacts @auditTable mart.ETL_AuditTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    DELETE mart.AuditInspectedByFact
    FROM mart.AuditInspectedByFact AS f
    INNER JOIN mart.[Audit] AS a ON f.Audit_key = a.Audit_key
    INNER JOIN @auditTable AS x ON a.AuditId = x.AuditId;

    PRINT 'DELETE mart.AuditInspectedByFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

    DELETE mart.AuditNumericAnswerFact
    FROM mart.AuditNumericAnswerFact AS f
    INNER JOIN mart.[Audit] AS a ON f.Audit_key = a.Audit_key
    INNER JOIN @auditTable AS x ON a.AuditId = x.AuditId;

    PRINT 'DELETE mart.AuditNumericAnswerFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

    DELETE mart.AuditDateTimeAnswerFact
    FROM mart.AuditDateTimeAnswerFact AS f
    INNER JOIN mart.[Audit] AS a ON f.Audit_key = a.Audit_key
    INNER JOIN @auditTable AS x ON a.AuditId = x.AuditId;

    PRINT 'DELETE mart.AuditDateTimeAnswerFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

    DELETE mart.AuditChecklistAnswerFact
    FROM mart.AuditChecklistAnswerFact AS f
    INNER JOIN mart.[Audit] AS a ON f.Audit_key = a.Audit_key
    INNER JOIN @auditTable AS x ON a.AuditId = x.AuditId;

    PRINT 'DELETE mart.AuditChecklistAnswerFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
