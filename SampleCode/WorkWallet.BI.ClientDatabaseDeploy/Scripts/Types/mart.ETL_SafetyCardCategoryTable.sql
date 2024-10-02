DROP TYPE IF EXISTS mart.ETL_SafetyCardCategoryTable;
GO

CREATE TYPE mart.ETL_SafetyCardCategoryTable AS TABLE
(
    SafetyCardCategoryId uniqueidentifier NOT NULL
    ,CategoryName nvarchar(500) NOT NULL
    ,CategoryReference nvarchar(50) NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    PRIMARY KEY (SafetyCardCategoryId)
);
GO