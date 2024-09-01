DROP TYPE IF EXISTS mart.ETL_LocationTable;
GO

CREATE TYPE mart.ETL_LocationTable AS TABLE
(
    LocationId uniqueidentifier NOT NULL
    ,LocationTypeCode int NOT NULL
    ,LocationType nvarchar(50) NOT NULL
    ,[Location] nvarchar(max) NOT NULL
    ,CompanyId uniqueidentifier NOT NULL
    ,Company nvarchar(max) NOT NULL
    ,SiteId uniqueidentifier NOT NULL
    ,[Site] nvarchar(max) NOT NULL
    ,AreaId uniqueidentifier NOT NULL
    ,[Area] nvarchar(255) NOT NULL
    ,JobId uniqueidentifier NOT NULL
    ,Job nvarchar(50) NOT NULL
    ,SiteLocationId uniqueidentifier NOT NULL
    ,Department nvarchar(30) NOT NULL
    ,ExternalIdentifier nvarchar(255) NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (LocationId)
);
GO
