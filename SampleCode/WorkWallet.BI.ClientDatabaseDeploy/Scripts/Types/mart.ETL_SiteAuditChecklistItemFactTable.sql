DROP TYPE IF EXISTS mart.ETL_SiteAuditChecklistItemFactTable;
GO

CREATE TYPE mart.ETL_SiteAuditChecklistItemFactTable AS TABLE
(
    -- keys
    SiteAuditId uniqueidentifier NOT NULL
    ,SiteAuditChecklistId uniqueidentifier NOT NULL
    ,SiteAuditChecklistVersion int NOT NULL
    ,SiteAuditChecklistItemId uniqueidentifier NOT NULL
    ,SiteAuditTypeId uniqueidentifier NOT NULL
    ,LocationId uniqueidentifier NOT NULL
    ,SiteAuditStatusCode int NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    -- facts
    ,ChecklistItemStatusName nvarchar(64) NOT NULL
    ,ChecklistItemStatus int NOT NULL
    ,PRIMARY KEY (SiteAuditId, SiteAuditChecklistId, SiteAuditChecklistVersion, SiteAuditChecklistItemId)
);
GO
