DROP TYPE IF EXISTS mart.ETL_ReportedIssueCategoryTable;
GO

CREATE TYPE mart.ETL_ReportedIssueCategoryTable AS TABLE
(
    SubcategoryId uniqueidentifier NOT NULL
    ,CategoryVersion int NOT NULL
    ,CategoryName nvarchar(50) NOT NULL
    ,CategoryDescription nvarchar(200) NOT NULL
    ,SubcategoryName nvarchar(200) NOT NULL
    ,SubcategoryDescription nvarchar(200) NOT NULL
    ,SubcategoryOrder int NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (SubcategoryId, CategoryVersion)
);
GO
