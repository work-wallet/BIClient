DROP TYPE IF EXISTS mart.ETL_AssetInspectionTable;
GO

CREATE TYPE mart.ETL_AssetInspectionTable AS TABLE
(
    AssetId uniqueidentifier NOT NULL
    ,InspectionId uniqueidentifier NOT NULL
    ,InspectionTypeId uniqueidentifier NOT NULL
    ,InspectionType nvarchar(75) NOT NULL
    ,InspectionDate datetime NOT NULL
    ,InspectedBy nvarchar(81) NOT NULL
    ,Deleted bit NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (InspectionDate, InspectionId) -- putting InspectionDate first to order the data load
);
GO
