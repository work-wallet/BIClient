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
    ,CONSTRAINT [PK_mart.PPEType] PRIMARY KEY (PPEType_key)
    ,CONSTRAINT [UQ_mart.PPEType_PPETypeId_PPETypeVariantId] UNIQUE (PPETypeId, PPETypeVariantId)
    ,CONSTRAINT [FK_mart.PPEType_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.PPEStock
(
    PPEStock_key int IDENTITY
    ,PPEStockId uniqueidentifier NOT NULL
    ,Location_key int NOT NULL
    ,PPEType_key int NOT NULL
    ,StockQuantity int NOT NULL
    ,WarningQuantity int NULL -- allow NULLs
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.PPEStock__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.PPEStock] PRIMARY KEY (PPEStock_key)
    ,CONSTRAINT [UQ_mart.PPEStock_PPEStockId] UNIQUE (PPEStockId)
    ,CONSTRAINT [FK_mart.PPEStock_mart.Location_Location_key] FOREIGN KEY(Location_key) REFERENCES mart.Location
    ,CONSTRAINT [FK_mart.PPEStock_mart.PPEType_PPEType_key] FOREIGN KEY(PPEType_key) REFERENCES mart.PPEType
    ,CONSTRAINT [FK_mart.PPEStock_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.PPEStockHistory
(
    PPEStockHistory_key int IDENTITY
    ,PPEStockHistoryId uniqueidentifier NOT NULL
    ,PPEStock_key int NOT NULL
    ,PPEAction_key int NOT NULL
    ,TransferredFromPPEStock_key int NULL -- allow NULLs
    ,StockQuantity int NOT NULL
    ,ActionedByContact_key int NULL -- allow NULLs
    ,ActionedOn datetimeoffset(7) NOT NULL
    ,Notes nvarchar(250) NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.PPEStockHistory__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.PPEStockHistory] PRIMARY KEY (PPEStockHistory_key)
    ,CONSTRAINT [UQ_mart.PPEStockHistory_PPEStockHistoryId] UNIQUE (PPEStockHistoryId)
    ,CONSTRAINT [FK_mart.PPEStockHistory_mart.PPEStock_PPEStock_key] FOREIGN KEY(PPEStock_key) REFERENCES mart.PPEStock
    ,CONSTRAINT [FK_mart.PPEStockHistory_mart.PPEAction_PPEAction_key] FOREIGN KEY(PPEAction_key) REFERENCES mart.PPEAction
    ,CONSTRAINT [FK_mart.PPEStockHistory_mart.Contact_ActionedByContact_key] FOREIGN KEY(ActionedByContact_key) REFERENCES mart.Contact
    ,CONSTRAINT [FK_mart.PPEStockHistory_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.PPEAssignment
(
    PPEAssignment_key int IDENTITY
    ,PPEAssignmentId uniqueidentifier NOT NULL
    ,AssignedToContact_key int NOT NULL
    ,PPEType_key int NOT NULL
    ,AssignedOn date NOT NULL
    ,ExpiredOn date NULL -- allow NULLs
    ,PPEStatus_key int NOT NULL
    ,AssignedFromPPEStock_key int NULL -- allow NULLs
    ,ReturnedToPPEStock_key int NULL -- allow NULLs
    ,ReplacementRequestedFromPPEStock_key int NULL -- allow NULLs
    ,ReplacementRequestedOn datetimeoffset(7) NULL -- allow NULLs
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.PPEAssignment__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.PPEAssignment] PRIMARY KEY (PPEAssignment_key)
    ,CONSTRAINT [UQ_mart.PPEAssignment_PPEAssignmentId] UNIQUE (PPEAssignmentId)
    ,CONSTRAINT [FK_mart.PPEAssignment_mart.Contact_AssignedToContact_key] FOREIGN KEY(AssignedToContact_key) REFERENCES mart.Contact
    ,CONSTRAINT [FK_mart.PPEAssignment_mart.PPEType_PPEType_key] FOREIGN KEY(PPEType_key) REFERENCES mart.PPEType
    ,CONSTRAINT [FK_mart.PPEAssignment_mart.PPEStatus_PPEStatus_key] FOREIGN KEY(PPEStatus_key) REFERENCES mart.PPEStatus
    ,CONSTRAINT [FK_mart.PPEAssignment_mart.PPEStock_AssignedFromPPEStock_key] FOREIGN KEY(AssignedFromPPEStock_key) REFERENCES mart.PPEStock
    ,CONSTRAINT [FK_mart.PPEAssignment_mart.PPEStock_ReturnedToPPEStock_key] FOREIGN KEY(ReturnedToPPEStock_key) REFERENCES mart.PPEStock
    ,CONSTRAINT [FK_mart.PPEAssignment_mart.PPEStock_ReplacementRequestedFromPPEStock_key] FOREIGN KEY(ReplacementRequestedFromPPEStock_key) REFERENCES mart.PPEStock
    ,CONSTRAINT [FK_mart.PPEAssignment_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.PPEAssignmentHistory
(
    PPEAssignmentHistory_key int IDENTITY
    ,PPEAssignmentHistoryId uniqueidentifier NOT NULL
    ,PPEAssignment_key int NOT NULL
    ,PPEAction_key int NOT NULL
    ,ActionedByContact_key int NULL -- allow NULLs
    ,ActionedOn datetimeoffset(7) NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.PPEAssignmentHistory__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.PPEAssignmentHistory] PRIMARY KEY (PPEAssignmentHistory_key)
    ,CONSTRAINT [UQ_mart.PPEAssignmentHistory_PPEAssignmentHistoryId] UNIQUE (PPEAssignmentHistoryId)
    ,CONSTRAINT [FK_mart.PPEAssignmentHistory_mart.PPEAssignment_PPEAssignment_key] FOREIGN KEY(PPEAssignment_key) REFERENCES mart.PPEAssignment
    ,CONSTRAINT [FK_mart.PPEAssignmentHistory_mart.PPEAction_PPEAction_key] FOREIGN KEY(PPEAction_key) REFERENCES mart.PPEAction
    ,CONSTRAINT [FK_mart.PPEAssignmentHistory_mart.Contact_ActionedByContact_key] FOREIGN KEY(ActionedByContact_key) REFERENCES mart.Contact
    ,CONSTRAINT [FK_mart.PPEAssignmentHistory_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);
