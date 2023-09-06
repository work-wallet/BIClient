DROP TYPE IF EXISTS mart.ETL_SiteAuditTable;
GO

CREATE TYPE mart.ETL_SiteAuditTable AS TABLE
(
    SiteAuditId uniqueidentifier NOT NULL
    ,AuditReference nvarchar(50) NOT NULL
    ,DateAndTimeOfInspection datetime2(7) NOT NULL
    ,SiteAuditStatusCode int NOT NULL
    ,SiteAuditTypeId uniqueidentifier NOT NULL
    ,LocationId uniqueidentifier NOT NULL
    ,AuditSummary nvarchar(max) NOT NULL
    ,HasScore bit NOT NULL
    ,Passed bit NOT NULL
    ,ActualScore decimal(5,2) NOT NULL
    ,PotentialScore decimal(5,2) NOT NULL
    ,[Percent] int NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (AuditReference, SiteAuditId) -- putting AuditReference first to order the data load
);
GO
