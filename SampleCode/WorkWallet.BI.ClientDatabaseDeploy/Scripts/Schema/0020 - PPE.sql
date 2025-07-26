CREATE TABLE mart.PPEStatus
(
    PPEStatus_key int IDENTITY
    ,PPEStatusCode int NOT NULL /* business key */
    ,PPEStatus nvarchar(50) NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.PPEStatus__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.PPEStatus] PRIMARY KEY (PPEStatus_key)
    ,CONSTRAINT [UQ_mart.PPEStatus_PPEStatusCode] UNIQUE (PPEStatusCode)
);

INSERT INTO mart.PPEStatus (PPEStatusCode, PPEStatus) VALUES (1, N'Assigned');
INSERT INTO mart.PPEStatus (PPEStatusCode, PPEStatus) VALUES (2, N'Returned');
INSERT INTO mart.PPEStatus (PPEStatusCode, PPEStatus) VALUES (3, N'Replaced');
INSERT INTO mart.PPEStatus (PPEStatusCode, PPEStatus) VALUES (4, N'Removed');

CREATE TABLE mart.PPEAction
(
    PPEAction_key int IDENTITY
    ,PPEActionCode int NOT NULL /* business key */
    ,PPEAction nvarchar(50) NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.PPEAction__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.PPEAction] PRIMARY KEY (PPEAction_key)
    ,CONSTRAINT [UQ_mart.PPEAction_PPEActionCode] UNIQUE (PPEActionCode)
);

INSERT INTO mart.PPEAction (PPEActionCode, PPEAction) VALUES (1, N'Removed');
INSERT INTO mart.PPEAction (PPEActionCode, PPEAction) VALUES (2, N'Returned');
INSERT INTO mart.PPEAction (PPEActionCode, PPEAction) VALUES (3, N'Replaced');
INSERT INTO mart.PPEAction (PPEActionCode, PPEAction) VALUES (4, N'Assigned');
INSERT INTO mart.PPEAction (PPEActionCode, PPEAction) VALUES (5, N'Stock Removed');
INSERT INTO mart.PPEAction (PPEActionCode, PPEAction) VALUES (6, N'Stock Transferred');
INSERT INTO mart.PPEAction (PPEActionCode, PPEAction) VALUES (7, N'Stock Created');

CREATE TABLE mart.PPEType
(
    PPEType_key int IDENTITY
    ,PPETypeId uniqueidentifier NOT NULL /* business key */
    ,PPETypeVariantId uniqueidentifier NOT NULL /* business key */
    ,[Type] nvarchar(100) NOT NULL
    ,Variant nvarchar(200) NULL -- allow NULLs
    ,VariantOrder int NULL -- allow NULLs
    ,LifespanDays int NULL -- allow NULLs
    ,[Value] decimal(10, 2) NULL -- allow NULLs
    ,TypeDeleted bit NOT NULL
    ,VariantDeleted bit NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.PPEType__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.PPEType] PRIMARY KEY (PPEType_key, PPETypeVariantId)
    ,CONSTRAINT [UQ_mart.PPEType_PPETypeId_PPETypeVariantId] UNIQUE (PPETypeId, PPETypeVariantId)
    ,CONSTRAINT [FK_mart.PPEType_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.PPEStock
(
    PPEStock_key int IDENTITY
    ,PPEStockId uniqueidentifier NOT NULL
    ,LocationId uniqueidentifier NOT NULL
    ,PPETypeId uniqueidentifier NOT NULL
    ,PPETypeVariantId uniqueidentifier NOT NULL
    ,StockQuantity int NOT NULL
    ,WarningQuantity int NULL -- allow NULLs
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.PPEStock__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.PPEStock] PRIMARY KEY (PPEStock_key)
    ,CONSTRAINT [UQ_mart.PPEStock_PPEStockId] UNIQUE (PPEStockId)
    ,CONSTRAINT [FK_mart.PPEStock_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);
