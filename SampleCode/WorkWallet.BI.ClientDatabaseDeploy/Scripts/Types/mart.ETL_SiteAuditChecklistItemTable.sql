DROP TYPE IF EXISTS mart.ETL_SiteAuditChecklistItemTable;
GO

CREATE TYPE mart.ETL_SiteAuditChecklistItemTable AS TABLE
(
    SiteAuditChecklistItemId uniqueidentifier NOT NULL
    ,SiteAuditChecklistId uniqueidentifier NOT NULL
    ,SiteAuditChecklistVersion int NOT NULL
    ,ChecklistItemTitle nvarchar(250) NOT NULL
    ,ChecklistItemDescription nvarchar(1000) NOT NULL
    ,DisplayOrder int NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (SiteAuditChecklistItemId)
)
GO
