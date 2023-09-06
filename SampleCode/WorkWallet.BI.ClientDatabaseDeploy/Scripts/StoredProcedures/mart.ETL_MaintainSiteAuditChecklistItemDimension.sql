DROP PROCEDURE IF EXISTS mart.ETL_MaintainSiteAuditChecklistItemDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainSiteAuditChecklistItemDimension @siteAuditChecklistItemTable mart.ETL_SiteAuditChecklistItemTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    -- type 1 changes (do first, before inserting new)
    UPDATE mart.SiteAuditChecklistItem
    SET
        SiteAuditChecklist_key = sac.SiteAuditChecklist_key
        ,ChecklistItemTitle = a.ChecklistItemTitle
        ,ChecklistItemDescription = a.ChecklistItemDescription
        ,DisplayOrder = a.DisplayOrder
        ,Wallet_key = w.Wallet_key
        ,_edited = SYSUTCDATETIME()
    FROM
        @siteAuditChecklistItemTable AS a
        INNER JOIN mart.SiteAuditChecklist AS sac ON a.SiteAuditChecklistId = sac.SiteAuditChecklistId AND a.SiteAuditChecklistVersion = sac.SiteAuditChecklistVersion
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        INNER JOIN mart.SiteAuditChecklistItem AS b ON a.SiteAuditChecklistItemId = b.SiteAuditChecklistItemId
    WHERE /* only where the data has changed */
        sac.SiteAuditChecklist_key <> b.SiteAuditChecklist_key
        OR a.ChecklistItemTitle <> b.ChecklistItemTitle
        OR a.ChecklistItemDescription <> b.ChecklistItemDescription
        OR a.DisplayOrder <> b.DisplayOrder
        OR w.Wallet_key <> b.Wallet_key;

    PRINT 'UPDATE mart.SiteAuditChecklistItem, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

    -- insert missing entries
    INSERT INTO mart.SiteAuditChecklistItem
    (
        SiteAuditChecklistItemId
        ,SiteAuditChecklist_key
        ,ChecklistItemTitle
        ,ChecklistItemDescription
        ,DisplayOrder
        ,Wallet_key
    )
    SELECT
        a.SiteAuditChecklistItemId
        ,sac.SiteAuditChecklist_key
        ,a.ChecklistItemTitle
        ,a.ChecklistItemDescription
        ,a.DisplayOrder
        ,w.Wallet_key
    FROM
        @siteAuditChecklistItemTable AS a
        INNER JOIN mart.SiteAuditChecklist AS sac ON a.SiteAuditChecklistId = sac.SiteAuditChecklistId AND a.SiteAuditChecklistVersion = sac.SiteAuditChecklistVersion
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        LEFT OUTER JOIN mart.SiteAuditChecklistItem AS b ON a.SiteAuditChecklistItemId = b.SiteAuditChecklistItemId
    WHERE
        b.SiteAuditChecklistItemId IS NULL;

    PRINT 'INSERT mart.SiteAuditChecklistItem, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
