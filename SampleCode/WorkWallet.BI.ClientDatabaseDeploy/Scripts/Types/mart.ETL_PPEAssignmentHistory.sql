DROP TYPE IF EXISTS mart.ETL_PPEAssignmentHistoryTable;
GO

CREATE TYPE mart.ETL_PPEAssignmentHistoryTable AS TABLE
(
    PPEAssignmentHistoryId uniqueidentifier NOT NULL
    ,PPEAssignmentId uniqueidentifier NOT NULL
    ,PPEActionCode int NOT NULL
    ,ActionedByContactId uniqueidentifier NULL -- allow NULLs
    ,ActionedOn datetimeoffset(7) NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (ActionedOn, PPEAssignmentHistoryId) -- putting ActionedOn first to order the data load
);
GO
