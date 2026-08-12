DROP TYPE IF EXISTS mart.ETL_AssetInspectionScoreSectionTable;
GO

CREATE TYPE mart.ETL_AssetInspectionScoreSectionTable AS TABLE
(
    InspectionId uniqueidentifier NOT NULL
    ,SectionId uniqueidentifier NOT NULL
    ,Section nvarchar(250) NOT NULL
    ,DisplayScore bit NOT NULL
    ,[Order] int NOT NULL
    ,TotalScore int NOT NULL
    ,TotalPotentialScore int NOT NULL
    ,AverageScore decimal(38,6) NOT NULL
    ,AveragePotentialScore decimal(38,6) NOT NULL
    ,PercentageScore decimal(7,6) NOT NULL
    ,Defects int NOT NULL
    ,Passed int NOT NULL -- -1 = not applicable/unknown, 0 = failed, 1 = passed
    ,GradingSetOptionId uniqueidentifier NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (InspectionId, SectionId)
);
GO
