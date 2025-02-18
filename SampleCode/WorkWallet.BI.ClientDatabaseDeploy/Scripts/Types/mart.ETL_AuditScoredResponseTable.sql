DROP TYPE IF EXISTS mart.ETL_AuditScoredResponseTable;
GO

CREATE TYPE mart.ETL_AuditScoredResponseTable AS TABLE
(
    AuditId uniqueidentifier NOT NULL
    ,BranchId uniqueidentifier NOT NULL
    ,OptionId uniqueidentifier NOT NULL
    ,Branch nvarchar(500) NOT NULL
    ,[Value] nvarchar(100) NOT NULL
    ,[Order] int NOT NULL
    ,TotalScore int NOT NULL
    ,TotalPotentialScore int NOT NULL
    ,PercentageScore decimal(7,6) NOT NULL
    ,Flag bit NOT NULL
    ,GradingSetOptionId uniqueidentifier NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (AuditId, BranchId, OptionId)
);
GO
