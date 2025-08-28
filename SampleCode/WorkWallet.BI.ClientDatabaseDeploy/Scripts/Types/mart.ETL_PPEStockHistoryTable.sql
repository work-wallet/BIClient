DROP TYPE IF EXISTS mart.ETL_PPEStockHistoryTable;
GO

CREATE TYPE mart.ETL_PPEStockHistoryTable AS TABLE
(
    PPEStockHistoryId uniqueidentifier NOT NULL
    ,PPEStockId uniqueidentifier NOT NULL
    ,PPEActionCode int NOT NULL
    ,TransferredFromStockId uniqueidentifier NULL -- allow NULLs
    ,StockQuantity int NOT NULL
    ,ActionedByContactId uniqueidentifier NULL -- allow NULLs
    ,ActionedOn datetimeoffset(7) NOT NULL
    ,Notes nvarchar(250) NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (ActionedOn, PPEStockHistoryId) -- putting ActionedOn first to order the data load
);
GO
