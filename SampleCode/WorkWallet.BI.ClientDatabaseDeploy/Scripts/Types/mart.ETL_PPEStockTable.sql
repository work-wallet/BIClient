DROP TYPE IF EXISTS mart.ETL_PPEStockTable;
GO

CREATE TYPE mart.ETL_PPEStockTable AS TABLE
(
    PPEStockId uniqueidentifier NOT NULL
    ,LocationId uniqueidentifier NOT NULL
    ,PPETypeId uniqueidentifier NOT NULL
    ,PPETypeVariantId uniqueidentifier NOT NULL
    ,StockQuantity int NOT NULL
    ,WarningQuantity int NULL -- allow NULLs
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (PPEStockId)
);
GO
