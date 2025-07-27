DROP TYPE IF EXISTS mart.ETL_PPETypeTable;
GO

CREATE TYPE mart.ETL_PPETypeTable AS TABLE
(
    PPETypeId uniqueidentifier NOT NULL
    ,PPETypeVariantId uniqueidentifier NOT NULL
    ,[Type] nvarchar(100) NOT NULL
    ,Variant nvarchar(200) NULL -- allow NULLs
    ,VariantOrder int NULL -- allow NULLs
    ,LifespanDays int NULL -- allow NULLs
    ,[Value] decimal(10, 2) NULL -- allow NULLs
    ,TypeDeleted bit NOT NULL
    ,VariantDeleted bit NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (PPETypeId, PPETypeVariantId)
);
GO
