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

    DELETE mart.AuditBranchOptionFact
    FROM mart.AuditBranchOptionFact AS f
    INNER JOIN mart.[Audit] AS a ON f.Audit_key = a.Audit_key
    INNER JOIN @auditTable AS x ON a.AuditId = x.AuditId;

    PRINT 'DELETE mart.AuditBranchOptionFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

    DELETE mart.AuditScoredResponseFact
    FROM mart.AuditScoredResponseFact AS f
    INNER JOIN mart.[Audit] AS a ON f.Audit_key = a.Audit_key
    INNER JOIN @auditTable AS x ON a.AuditId = x.AuditId;

    PRINT 'DELETE mart.AuditScoredResponseFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

    DELETE mart.AuditScoreSectionFact
    FROM mart.AuditScoreSectionFact AS f
    INNER JOIN mart.[Audit] AS a ON f.Audit_key = a.Audit_key
    INNER JOIN @auditTable AS x ON a.AuditId = x.AuditId;

    PRINT 'DELETE mart.AuditScoreSectionFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

    DELETE mart.AuditScoreTagFact
    FROM mart.AuditScoreTagFact AS f
    INNER JOIN mart.[Audit] AS a ON f.Audit_key = a.Audit_key
    INNER JOIN @auditTable AS x ON a.AuditId = x.AuditId;

    PRINT 'DELETE mart.AuditScoreTagFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END

GO
