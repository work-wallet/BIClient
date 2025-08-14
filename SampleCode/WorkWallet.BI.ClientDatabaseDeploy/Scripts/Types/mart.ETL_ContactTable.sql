DROP TYPE IF EXISTS mart.ETL_ContactTable;
GO

CREATE TYPE mart.ETL_ContactTable AS TABLE
(
    ContactId uniqueidentifier NOT NULL
    ,[Name] nvarchar(max) NOT NULL
    ,EmailAddress nvarchar(max) NOT NULL
    ,CompanyName nvarchar(max) NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (ContactId)
);
GO
