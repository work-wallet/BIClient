DROP TYPE IF EXISTS mart.ETL_ActionUpdateTable;
GO

CREATE TYPE mart.ETL_ActionUpdateTable AS TABLE
(
    ActionUpdateId uniqueidentifier NOT NULL
    ,ActionId uniqueidentifier NOT NULL
    ,Comments nvarchar(max) NOT NULL
    ,ActionStatusCode int NOT NULL
    ,Deleted bit NOT NULL
    ,CreatedOn datetimeoffset(7) NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (ActionUpdateId)
);
GO