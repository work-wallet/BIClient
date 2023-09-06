DROP TYPE IF EXISTS mart.ETL_SiteAuditChecklistFactTable;
GO

CREATE TYPE mart.ETL_SiteAuditChecklistFactTable AS TABLE
(
    -- keys
    SiteAuditId uniqueidentifier NOT NULL
    ,SiteAuditChecklistId uniqueidentifier NOT NULL
    ,SiteAuditChecklistVersion int NOT NULL
    ,SiteAuditTypeId uniqueidentifier NOT NULL
    ,LocationId uniqueidentifier NOT NULL
    ,SiteAuditStatusCode int NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    -- facts
    ,HasScore bit NOT NULL
    ,Score decimal(5,2) NOT NULL
    ,PotentialScore decimal(5,2) NOT NULL
    ,[Percent] int NOT NULL
    ,PassFailStatus int NOT NULL
    ,Passed bit NOT NULL
    ,PassScore int NOT NULL
    ,PRIMARY KEY (SiteAuditId, SiteAuditChecklistId, SiteAuditChecklistVersion)
);
GO
