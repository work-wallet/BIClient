DROP TYPE IF EXISTS mart.ETL_AuditTypeTable;
GO

CREATE TYPE mart.ETL_AuditTypeTable AS TABLE
(
    AuditTypeId uniqueidentifier NOT NULL
    ,AuditTypeVersion int NOT NULL
    ,AuditType nvarchar(500) NOT NULL
    ,[Description] nvarchar(2000) NOT NULL
    ,ScoringEnabled bit NOT NULL
    ,DisplayPercentage bit NOT NULL
    ,DisplayTotalScore bit NOT NULL
    ,DisplayAverageScore bit NOT NULL
    ,GradingSet nvarchar(100) NOT NULL
    ,GradingSetIsPercentage bit NOT NULL
    ,GradingSetIsScore bit NOT NULL
    ,ReportingEnabled bit NOT NULL
    ,ReportingAbbreviation nvarchar(4) NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (AuditTypeId, AuditTypeVersion)
);
GO
