DROP TYPE IF EXISTS mart.ETL_PermitToWorkCategoryTable;
GO

CREATE TYPE mart.ETL_PermitToWorkCategoryTable AS TABLE
(
    CategoryId uniqueidentifier NOT NULL
    ,CategoryVersion int NOT NULL
    ,CategoryName nvarchar(75) NOT NULL
    ,ExpiryTypeId int NOT NULL
    ,ExpiryType nvarchar(50) NOT NULL
    ,ValidityPeriodId int NOT NULL
    ,ValidityPeriod nvarchar(50) NOT NULL
    ,ValidityPeriodMinutes int NOT NULL
    ,IssueTypeId int NOT NULL
    ,IssueType nvarchar(50) NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (CategoryId, CategoryVersion)
);
GO