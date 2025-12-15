DROP TYPE IF EXISTS mart.ETL_PPETypePropertyTable;
GO

CREATE TYPE mart.ETL_PPETypePropertyTable AS TABLE
(
    PPETypeId uniqueidentifier NOT NULL
    ,Property nvarchar(250) NOT NULL
    ,PropertyType nvarchar(20) NOT NULL
    ,DisplayOrder int NOT NULL
    ,[Value] nvarchar(max) NOT NULL
    ,WalletId uniqueidentifier NOT NULL
);
GO
