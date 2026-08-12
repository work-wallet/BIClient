DROP TYPE IF EXISTS mart.ETL_AssetInspectionTable;
GO

CREATE TYPE mart.ETL_AssetInspectionTable AS TABLE
(
    InspectionId uniqueidentifier NOT NULL
    ,AssetId uniqueidentifier NOT NULL
    ,InspectionStatusCode int NOT NULL
    ,InspectionTypeId uniqueidentifier NOT NULL
    ,InspectionTypeVersion int NOT NULL
    ,InspectedOn datetime NOT NULL
    ,TotalScore int NOT NULL
    ,TotalPotentialScore int NOT NULL
    ,AverageScore decimal(38,6) NOT NULL
    ,AveragePotentialScore decimal(38,6) NOT NULL
    ,PercentageScore decimal(7,6) NOT NULL
    ,Defects int NOT NULL
    ,Passed int NOT NULL -- -1 = not applicable/unknown, 0 = failed, 1 = passed
    ,GradingSetOptionId uniqueidentifier NOT NULL
    ,ExternalIdentifier nvarchar(255) NOT NULL
    ,InspectedByCompany nvarchar(max) NOT NULL
    ,InProgressStatusDate datetimeoffset(7) NULL -- allow NULLs
    ,ReadyForReviewStatusDate datetimeoffset(7) NULL -- allow NULLs
    ,CompleteStatusDate datetimeoffset(7) NULL -- allow NULLs
    ,ArchivedStatusDate datetimeoffset(7) NULL -- allow NULLs
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (InspectedOn, InspectionId) -- putting InspectedOn first to order the data load
);
GO
