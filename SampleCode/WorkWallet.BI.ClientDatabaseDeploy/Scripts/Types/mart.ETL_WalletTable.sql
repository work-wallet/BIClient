DROP TYPE IF EXISTS mart.ETL_WalletTable;
GO

CREATE TYPE mart.ETL_WalletTable AS TABLE
(
    WalletId uniqueidentifier NOT NULL
    ,Wallet nvarchar(max) NOT NULL
    ,PRIMARY KEY (WalletId)
);
GO
