DROP TYPE IF EXISTS mart.ETL_AuditTable;
GO

CREATE TYPE mart.ETL_AuditTable AS TABLE
(
    AuditId uniqueidentifier NOT NULL
    ,Reference int NOT NULL
    ,AuditReference nvarchar(50) NOT NULL
    ,AuditGroupId uniqueidentifier NOT NULL
    ,AuditGroup nvarchar(40) NOT NULL
    ,AuditStatusCode int NOT NULL
    ,AuditTypeId uniqueidentifier NOT NULL
    ,AuditTypeVersion int NOT NULL
    ,LocationId uniqueidentifier NOT NULL
    ,InspectedOn datetime NOT NULL
    ,TotalScore int NOT NULL
    ,TotalPotentialScore int NOT NULL
    ,AverageScore decimal(38,6) NOT NULL
    ,AveragePotentialScore decimal(38,6) NOT NULL
    ,PercentageScore decimal(7,6) NOT NULL
    ,Flags int NOT NULL
    ,GradingSetOptionId uniqueidentifier NOT NULL
    ,ExternalIdentifier nvarchar(255) NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (Reference, AuditId) -- putting Reference first to order the data load
);
GO
