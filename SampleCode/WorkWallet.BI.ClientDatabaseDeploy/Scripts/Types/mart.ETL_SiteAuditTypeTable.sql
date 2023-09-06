DROP TYPE IF EXISTS mart.ETL_SiteAuditTypeTable;
GO

CREATE TYPE mart.ETL_SiteAuditTypeTable AS TABLE
(
    SiteAuditTypeId uniqueidentifier NOT NULL
    ,SiteAuditType nvarchar(75) NOT NULL
    ,DisplayScoring bit NOT NULL
    ,ScoringMethod int NOT NULL
    ,DisplayOptions int NOT NULL
    ,ShowPercentage bit NOT NULL
    ,ShowScore bit NOT NULL
    ,ShowPassFail bit NOT NULL
    ,ShowGrading bit NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (SiteAuditTypeId)
);
GO
