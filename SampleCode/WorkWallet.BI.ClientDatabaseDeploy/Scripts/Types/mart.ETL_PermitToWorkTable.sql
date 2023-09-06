DROP TYPE IF EXISTS mart.ETL_PermitToWorkTable;
GO

CREATE TYPE mart.ETL_PermitToWorkTable AS TABLE
(
    PermitToWorkId uniqueidentifier NOT NULL
    ,PermitToWorkReference nvarchar(50) NOT NULL
    ,CategoryId uniqueidentifier NOT NULL
    ,CategoryVersion int NOT NULL
    ,SiteLocationId uniqueidentifier NOT NULL
    ,[Description] nvarchar(750) NOT NULL
    ,IssuedToCompanyId uniqueidentifier NOT NULL
    ,IssuedToCompany nvarchar(max) NOT NULL
    ,IssuedOn datetime NOT NULL
    ,IssuedForMinutes int NULL
    ,IssuedExpiry datetime NOT NULL
    ,ClosedOn datetime NULL
    ,StatusId int NOT NULL
    ,HasBeenExpired bit NOT NULL
    ,HasBeenClosed bit NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (PermitToWorkReference, PermitToWorkId) -- putting PermitToWorkReference first to order the data load
);
GO