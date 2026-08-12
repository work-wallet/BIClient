DROP TYPE IF EXISTS mart.ETL_AssetInspectionScoreTagTable;
GO

CREATE TYPE mart.ETL_AssetInspectionScoreTagTable AS TABLE
(
    InspectionId uniqueidentifier NOT NULL
    ,TagId uniqueidentifier NOT NULL
    ,TagVersion int NOT NULL
    ,Tag nvarchar(250) NOT NULL
    ,TotalScore int NOT NULL
    ,TotalPotentialScore int NOT NULL
    ,AverageScore decimal(38,6) NOT NULL
    ,AveragePotentialScore decimal(38,6) NOT NULL
    ,PercentageScore decimal(7,6) NOT NULL
    ,Defects int NOT NULL
    ,GradingSetOptionId uniqueidentifier NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (InspectionId, TagId, TagVersion)
);
GO
