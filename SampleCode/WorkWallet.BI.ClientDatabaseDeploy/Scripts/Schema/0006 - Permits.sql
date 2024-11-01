CREATE TABLE mart.PermitStatus
(
    PermitStatus_key int IDENTITY
    ,PermitStatusCode int NOT NULL /* business key */
    ,PermitStatus nvarchar(50) NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.PermitStatus__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.PermitStatus] PRIMARY KEY (PermitStatus_key)
    ,CONSTRAINT [UQ_mart.PermitStatus_Code] UNIQUE(PermitStatusCode)
);

INSERT INTO mart.PermitStatus (PermitStatusCode, PermitStatus) VALUES (1, N'Draft');
INSERT INTO mart.PermitStatus (PermitStatusCode, PermitStatus) VALUES (2, N'Pending');
INSERT INTO mart.PermitStatus (PermitStatusCode, PermitStatus) VALUES (3, N'Active');
INSERT INTO mart.PermitStatus (PermitStatusCode, PermitStatus) VALUES (4, N'Expired');
INSERT INTO mart.PermitStatus (PermitStatusCode, PermitStatus) VALUES (5, N'Closed');
INSERT INTO mart.PermitStatus (PermitStatusCode, PermitStatus) VALUES (6, N'Archived');
INSERT INTO mart.PermitStatus (PermitStatusCode, PermitStatus) VALUES (7, N'Deleted');

CREATE TABLE mart.PermitCategory
(
    PermitCategory_key int IDENTITY
    ,CategoryId uniqueidentifier NOT NULL
    ,CategoryVersion int NOT NULL
    ,CategoryName nvarchar(75) NOT NULL
    ,ExpiryTypeId int NOT NULL
    ,ExpiryType nvarchar(50) NOT NULL
    ,ValidityPeriodId int NOT NULL
    ,ValidityPeriod nvarchar(50) NOT NULL
    ,ValidityPeriodMinutes int NOT NULL
    ,IssueTypeId int NOT NULL
    ,IssueType nvarchar(50) NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.PermitCategory__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.PermitCategory] PRIMARY KEY (PermitCategory_key)
    ,CONSTRAINT [UQ_mart.PermitCategory_CategoryId_CategoryVersion] UNIQUE(CategoryId, CategoryVersion)
    ,CONSTRAINT [FK_mart.PermitCategory_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.Permit
(
    Permit_key int IDENTITY
    ,PermitId uniqueidentifier NOT NULL /* business key */
    ,PermitReference nvarchar(50) NOT NULL
    ,PermitCategory_key int NOT NULL
    ,Location_key int NOT NULL
    ,PermitDescription nvarchar(750) NOT NULL
    ,IssuedToCompanyId uniqueidentifier NOT NULL
    ,IssuedToCompany nvarchar(max) NOT NULL
    ,IssuedOn datetime NOT NULL
    ,IssuedForMinutes int NULL
    ,IssuedExpiry datetime NOT NULL
    ,ClosedOn datetime NULL
    ,PermitStatus_key int NOT NULL
    ,HasBeenExpired bit NOT NULL
    ,HasBeenClosed bit NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.Permit__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.Permit] PRIMARY KEY (Permit_key)
    ,CONSTRAINT [UQ_mart.Permit_PermitId] UNIQUE(PermitId)
    ,CONSTRAINT [FK_mart.Permit_mart.PermitCategory_PermitCategory_key] FOREIGN KEY(PermitCategory_key) REFERENCES mart.PermitCategory
    ,CONSTRAINT [FK_mart.Permit_mart.Location_Location_key] FOREIGN KEY(Location_key) REFERENCES mart.[Location]
    ,CONSTRAINT [FK_mart.Permit_mart.PermitStatus_PermitStatus_key] FOREIGN KEY(PermitStatus_key) REFERENCES mart.PermitStatus
    ,CONSTRAINT [FK_mart.Permit_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.PermitChecklistAnswer
(
    PermitChecklistAnswer_key int IDENTITY
    ,CategorySectionType nvarchar(50) NOT NULL
    ,Question nvarchar(1000) NOT NULL
    ,[Option] nvarchar(250) NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.PermitChecklistAnswer__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.PermitChecklistAnswer] PRIMARY KEY (PermitChecklistAnswer_key)
    ,CONSTRAINT [FK_mart.PermitChecklistAnswer_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.PermitChecklistAnswerFact
(
    Permit_key int NOT NULL
    ,PermitChecklistAnswer_key int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.PermitChecklistAnswerFact__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.PermitChecklistAnswerFact] PRIMARY KEY (Permit_key, PermitChecklistAnswer_key)
    ,CONSTRAINT [FK_mart.PermitChecklistAnswerFact_mart.Permit_Permit_key] FOREIGN KEY(Permit_key) REFERENCES mart.Permit
    ,CONSTRAINT [FK_mart.PermitChecklistAnswerFact_mart.PermitChecklistAnswer_PermitChecklistAnswer_key] FOREIGN KEY(PermitChecklistAnswer_key) REFERENCES mart.PermitChecklistAnswer
    ,CONSTRAINT [FK_mart.PermitChecklistAnswerFact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

GO
