DROP TYPE IF EXISTS mart.ETL_AssetAssignmentTable;
GO

CREATE TYPE mart.ETL_AssetAssignmentTable AS TABLE
(
    AssetId uniqueidentifier NOT NULL
    ,AssignedOn datetimeoffset(7) NOT NULL
    ,AssignmentType nvarchar(20) NOT NULL
    ,AssignedTo nvarchar(max) NOT NULL
    ,AssignedToContactId uniqueidentifier NULL -- allow NULLs
    ,CompanyId uniqueidentifier NOT NULL
    ,Company nvarchar(max) NOT NULL
    ,SiteId uniqueidentifier NOT NULL
    ,[Site] nvarchar(max) NOT NULL
    ,WalletId uniqueidentifier NOT NULL
);
GO
