DROP TYPE IF EXISTS mart.ETL_AssetInspectionPropertyTable;
GO

CREATE TYPE mart.ETL_AssetInspectionPropertyTable AS TABLE
(
    AssetId uniqueidentifier NOT NULL
    ,InspectionId uniqueidentifier NOT NULL
    ,Property nvarchar(250) NOT NULL
    ,PropertyType nvarchar(20) NOT NULL
    ,[Value] nvarchar(max) NOT NULL
    ,WalletId uniqueidentifier NOT NULL
);
GO
