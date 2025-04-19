DROP TYPE IF EXISTS mart.ETL_AuditScoreTagTable;
GO

CREATE TYPE mart.ETL_AuditScoreTagTable AS TABLE
(
    AuditId uniqueidentifier NOT NULL
    ,TagId uniqueidentifier NOT NULL
    ,TagVersion int NOT NULL
    ,Tag nvarchar(250) NOT NULL
    ,TotalScore int NOT NULL
    ,TotalPotentialScore int NOT NULL
    ,AverageScore decimal(38,6) NOT NULL
    ,AveragePotentialScore decimal(38,6) NOT NULL
    ,PercentageScore decimal(7,6) NOT NULL
    ,Flags int NOT NULL
    ,GradingSetOptionId uniqueidentifier NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (AuditId, TagId, TagVersion)
);
GO
