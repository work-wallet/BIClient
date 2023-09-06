DROP PROCEDURE IF EXISTS mart.ETL_DeleteSiteAuditFacts;
GO

CREATE PROCEDURE mart.ETL_DeleteSiteAuditFacts @siteAuditTable mart.ETL_SiteAuditTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    DELETE mart.SiteAuditChecklistFact
    FROM mart.SiteAuditChecklistFact AS d
    INNER JOIN mart.SiteAudit AS sa ON d.SiteAudit_key = sa.SiteAudit_key
    INNER JOIN @siteAuditTable AS a ON sa.SiteAuditId = a.SiteAuditId;

    PRINT 'DELETE mart.SiteAuditChecklistFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

    DELETE mart.SiteAuditChecklistItemFact
    FROM mart.SiteAuditChecklistItemFact AS d
    INNER JOIN mart.SiteAudit AS sa ON d.SiteAudit_key = sa.SiteAudit_key
    INNER JOIN @siteAuditTable AS a ON sa.SiteAuditId = a.SiteAuditId;

    PRINT 'DELETE mart.SiteAuditChecklistItemFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

END
GO
