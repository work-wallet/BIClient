DROP TYPE IF EXISTS mart.ETL_ActionTable;
GO

CREATE TYPE mart.ETL_ActionTable AS TABLE
(
    ActionId uniqueidentifier NOT NULL
    ,ActionTypeCode int NOT NULL
    ,TargetId uniqueidentifier NOT NULL
    ,TargetReference nvarchar(128) NOT NULL
    ,Title nvarchar(100) NOT NULL
    ,[Description] nvarchar(max) NOT NULL
    ,AssignedTo nvarchar(100) NOT NULL
    ,PriorityCode int NOT NULL
    ,DueOn date NOT NULL
    ,OriginalDueOn date NOT NULL
    ,ActionStatusCode int NOT NULL
    ,Deleted bit NOT NULL
    ,CreatedOn datetimeoffset(7) NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (CreatedOn, ActionId, ActionTypeCode) -- putting CreatedOn first to order the data load
);
GO