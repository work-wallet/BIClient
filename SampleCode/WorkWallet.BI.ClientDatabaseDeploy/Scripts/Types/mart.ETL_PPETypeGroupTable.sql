DROP TYPE IF EXISTS mart.ETL_PPETypeGroupTable;
GO

CREATE TYPE mart.ETL_PPETypeGroupTable AS TABLE
(
    PPETypeId uniqueidentifier NOT NULL
    ,PPEGroupId uniqueidentifier NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (PPETypeId, PPEGroupId)
);
GO
