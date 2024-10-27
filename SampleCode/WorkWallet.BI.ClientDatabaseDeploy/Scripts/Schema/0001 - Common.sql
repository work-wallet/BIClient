IF NOT EXISTS ( SELECT  *
                FROM    sys.schemas
                WHERE   name = N'mart' )
    EXEC('CREATE SCHEMA [mart]');

CREATE TABLE mart.ETL_ChangeDetection
(
    WalletId uniqueidentifier NOT NULL
    ,IsLatest bit NOT NULL
    ,LogType nvarchar(255) NOT NULL
    ,LastProcessedTime datetimeoffset(7) NOT NULL
    ,LastSynchronizationVersion bigint NOT NULL
    ,RowsProcessed int NOT NULL
    ,CONSTRAINT [PK_mart.ETL_ChangeDetection] PRIMARY KEY (WalletId, IsLatest, LogType, LastProcessedTime)
);

CREATE TABLE mart.Wallet
(
    Wallet_key int IDENTITY
    ,WalletId uniqueidentifier NOT NULL /* business key */
    ,Wallet nvarchar(max) NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.Wallet__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.Wallet] PRIMARY KEY (Wallet_key)
    ,CONSTRAINT [UQ_mart.Wallet_WalletId] UNIQUE(WalletId)
);

CREATE TABLE mart.[Location]
(
    Location_key int IDENTITY
    ,LocationId uniqueidentifier NOT NULL /* business key */
    ,LocationTypeCode int NOT NULL /* 1 - job, 2 - operating site, 3 - general location */
    ,LocationType nvarchar(50) NOT NULL /* ditto */
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
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.Location__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.Location] PRIMARY KEY (Location_key)
    ,CONSTRAINT [UQ_mart.Location_LocationId] UNIQUE(LocationId)
    ,CONSTRAINT [FK_mart.Location_mart.Wallet_Wallet_key] FOREIGN KEY (Wallet_key) REFERENCES mart.Wallet
);
GO
