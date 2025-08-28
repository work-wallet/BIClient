DROP TYPE IF EXISTS mart.ETL_PPEAssignmentTable;
GO

CREATE TYPE mart.ETL_PPEAssignmentTable AS TABLE
(
    PPEAssignmentId uniqueidentifier NOT NULL
    ,AssignedToContactId uniqueidentifier NOT NULL
    ,PPETypeId uniqueidentifier NOT NULL
    ,PPETypeVariantId uniqueidentifier NOT NULL
    ,AssignedOn date NOT NULL
    ,ExpiredOn date NULL -- allow NULLs
    ,PPEStatusCode int NOT NULL
    ,AssignedFromStockId uniqueidentifier NULL -- allow NULLs
    ,ReturnedToStockId uniqueidentifier NULL -- allow NULLs
    ,ReplacementRequestedFromStockId uniqueidentifier NULL -- allow NULLs
    ,ReplacementRequestedOn datetimeoffset(7) NULL -- allow NULLs
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (AssignedOn, PPEAssignmentId) -- putting AssignedOn first to order the data load
);
GO
