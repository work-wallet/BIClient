DROP PROCEDURE IF EXISTS mart.ETL_LoadSiteAuditChecklistItemFact;
GO

CREATE PROCEDURE mart.ETL_LoadSiteAuditChecklistItemFact @siteAuditChecklistItemFactTable mart.ETL_SiteAuditChecklistItemFactTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    -- insert missing entries
    INSERT INTO mart.SiteAuditChecklistItemFact
    (
        -- keys
        SiteAudit_key
        ,SiteAuditChecklist_key
        ,SiteAuditChecklistItem_key
        ,SiteAuditType_key
        ,Location_key
        ,SiteAuditStatus_key
        ,Wallet_key
        -- facts
        ,ChecklistItemStatusName
        ,ChecklistItemStatus
    )
    SELECT
        -- keys
        sa.SiteAudit_key
        ,sac.SiteAuditChecklist_key
        ,saci.SiteAuditChecklistItem_key
        ,sat.SiteAuditType_key
        ,ol.Location_key
        ,sas.SiteAuditStatus_key
        ,w.Wallet_key
        -- facts
        ,a.ChecklistItemStatusName
        ,a.ChecklistItemStatus
    FROM
        @siteAuditChecklistItemFactTable AS a
        INNER JOIN mart.SiteAudit sa ON a.SiteAuditId = sa.SiteAuditId
        INNER JOIN mart.SiteAuditStatus AS sas ON a.SiteAuditStatusCode = sas.SiteAuditStatusCode
        INNER JOIN mart.SiteAuditType AS sat ON a.SiteAuditTypeId = sat.SiteAuditTypeId
        INNER JOIN mart.SiteAuditChecklist AS sac ON a.SiteAuditChecklistId = sac.SiteAuditChecklistId AND a.SiteAuditChecklistVersion = sac.SiteAuditChecklistVersion
        INNER JOIN mart.SiteAuditChecklistItem AS saci ON a.SiteAuditChecklistItemId = saci.SiteAuditChecklistItemId
        INNER JOIN mart.[Location] AS ol ON a.LocationId = ol.LocationId
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId;

    PRINT 'INSERT mart.SiteAuditChecklistItemFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
