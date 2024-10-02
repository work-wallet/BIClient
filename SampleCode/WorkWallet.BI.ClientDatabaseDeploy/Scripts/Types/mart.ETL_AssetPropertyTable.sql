DROP TYPE IF EXISTS mart.ETL_AssetPropertyTable;
GO

CREATE TYPE mart.ETL_AssetPropertyTable AS TABLE
(
    AssetId uniqueidentifier NOT NULL
    ,Property nvarchar(250) NOT NULL
    ,PropertyType nvarchar(20) NOT NULL
    ,[Value] nvarchar(max) NOT NULL
    ,WalletId uniqueidentifier NOT NULL
);
GO
