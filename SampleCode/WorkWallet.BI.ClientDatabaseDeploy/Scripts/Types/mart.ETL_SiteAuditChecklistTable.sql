DROP TYPE IF EXISTS mart.ETL_SiteAuditChecklistTable;
GO

CREATE TYPE mart.ETL_SiteAuditChecklistTable AS TABLE
(
    SiteAuditChecklistId uniqueidentifier NOT NULL
    ,SiteAuditChecklistVersion int NOT NULL
    ,ChecklistName nvarchar(250) NOT NULL
    ,ChecklistDescription nvarchar(1000) NOT NULL
    ,NumberOfResponseOptions int NOT NULL
    ,ScoringEnabled bit NOT NULL
    ,PassStatus int NOT NULL
    ,ChecklistWeighting int NOT NULL
    ,FailedItemScoring int NOT NULL
    ,FailedItemsCountTowardsAverageScore bit NOT NULL
    ,FailedItemsSetTheChecklistScoreToZero bit NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (SiteAuditChecklistId, SiteAuditChecklistVersion)
);
GO
