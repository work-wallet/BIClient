DROP TYPE IF EXISTS mart.ETL_PPEGroupTable;
GO

CREATE TYPE mart.ETL_PPEGroupTable AS TABLE
(
    PPEGroupId uniqueidentifier NOT NULL
    ,PPEGroup nvarchar(100) NOT NULL
    ,Active bit NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (PPEGroupId)
);
GO
