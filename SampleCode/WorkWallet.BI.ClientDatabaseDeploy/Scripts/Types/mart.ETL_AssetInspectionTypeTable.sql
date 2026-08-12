DROP TYPE IF EXISTS mart.ETL_AssetInspectionTypeTable;
GO

CREATE TYPE mart.ETL_AssetInspectionTypeTable AS TABLE
(
    InspectionTypeId uniqueidentifier NOT NULL
    ,InspectionTypeVersion int NOT NULL
    ,InspectionType nvarchar(500) NOT NULL
    ,[Description] nvarchar(2000) NOT NULL
    ,ScoringEnabled bit NOT NULL
    ,DisplayPercentage bit NOT NULL
    ,DisplayTotalScore bit NOT NULL
    ,DisplayAverageScore bit NOT NULL
    ,GradingSetId uniqueidentifier NOT NULL
    ,GradingSetVersion int NOT NULL
    ,GradingSet nvarchar(100) NOT NULL
    ,GradingSetIsPercentage bit NOT NULL
    ,GradingSetIsScore bit NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (InspectionTypeId, InspectionTypeVersion)
);
GO
