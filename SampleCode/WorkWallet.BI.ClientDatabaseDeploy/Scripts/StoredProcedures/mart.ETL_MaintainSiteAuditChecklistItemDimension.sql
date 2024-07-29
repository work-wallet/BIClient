DROP PROCEDURE IF EXISTS mart.ETL_MaintainSiteAuditChecklistItemDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainSiteAuditChecklistItemDimension @siteAuditChecklistItemTable mart.ETL_SiteAuditChecklistItemTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.SiteAuditChecklistItem AS target
    USING (
        SELECT
            a.SiteAuditChecklistItemId,
            sac.SiteAuditChecklist_key,
            a.ChecklistItemTitle,
            a.ChecklistItemDescription,
            a.DisplayOrder,
            w.Wallet_key
        FROM
            @siteAuditChecklistItemTable AS a
            INNER JOIN mart.SiteAuditChecklist AS sac ON a.SiteAuditChecklistId = sac.SiteAuditChecklistId AND a.SiteAuditChecklistVersion = sac.SiteAuditChecklistVersion
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON target.SiteAuditChecklistItemId = source.SiteAuditChecklistItemId
    WHEN MATCHED AND (
        target.SiteAuditChecklist_key <> source.SiteAuditChecklist_key
        OR target.ChecklistItemTitle <> source.ChecklistItemTitle
        OR target.ChecklistItemDescription <> source.ChecklistItemDescription
        OR target.DisplayOrder <> source.DisplayOrder
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            SiteAuditChecklist_key = source.SiteAuditChecklist_key,
            ChecklistItemTitle = source.ChecklistItemTitle,
            ChecklistItemDescription = source.ChecklistItemDescription,
            DisplayOrder = source.DisplayOrder,
            Wallet_key = source.Wallet_key,
            _edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            SiteAuditChecklistItemId,
            SiteAuditChecklist_key,
            ChecklistItemTitle,
            ChecklistItemDescription,
            DisplayOrder,
            Wallet_key
        ) VALUES (
            source.SiteAuditChecklistItemId,
            source.SiteAuditChecklist_key,
            source.ChecklistItemTitle,
            source.ChecklistItemDescription,
            source.DisplayOrder,
            source.Wallet_key
        );

    PRINT 'MERGE mart.SiteAuditChecklistItem, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
