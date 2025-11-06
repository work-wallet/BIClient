CREATE TABLE mart.SafetyCardStatus
(
    SafetyCardStatus_key int IDENTITY
    ,SafetyCardStatusCode int NOT NULL /* business key */
    ,SafetyCardStatus nvarchar(50) NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.SafetyCardStatus__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.SafetyCardStatus] PRIMARY KEY (SafetyCardStatus_key)
    ,CONSTRAINT [UQ_mart.SafetyCardStatus_SafetyCardStatusCode] UNIQUE(SafetyCardStatusCode)
);

INSERT INTO mart.SafetyCardStatus (SafetyCardStatusCode, SafetyCardStatus) VALUES (0, N'Active');
INSERT INTO mart.SafetyCardStatus (SafetyCardStatusCode, SafetyCardStatus) VALUES (1, N'Archived');
INSERT INTO mart.SafetyCardStatus (SafetyCardStatusCode, SafetyCardStatus) VALUES (3, N'Deleted');

CREATE TABLE mart.SafetyCardType
(
    SafetyCardType_key int IDENTITY
    ,SafetyCardTypeCode int NOT NULL /* business key */
    ,SafetyCardType nvarchar(50) NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.SafetyCardType__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.SafetyCardType] PRIMARY KEY (SafetyCardType_key)
    ,CONSTRAINT [UQ_mart.SafetyCardType_SafetyCardTypeCode] UNIQUE(SafetyCardTypeCode)
);

INSERT INTO mart.SafetyCardType (SafetyCardTypeCode, SafetyCardType) VALUES (0, N'Green');
INSERT INTO mart.SafetyCardType (SafetyCardTypeCode, SafetyCardType) VALUES (1, N'Yellow');
INSERT INTO mart.SafetyCardType (SafetyCardTypeCode, SafetyCardType) VALUES (2, N'Red');

CREATE TABLE mart.SafetyCardOccupationRole
(
    SafetyCardOccupationRole_key int IDENTITY
    ,OccupationRoleCode int NOT NULL /* business key */
    ,OccupationRole nvarchar(50) NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.SafetyCardOccupationRole__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.SafetyCardOccupationRole] PRIMARY KEY (SafetyCardOccupationRole_key)
    ,CONSTRAINT [UQ_mart.SafetyCardOccupationRole_OccupationRoleCode] UNIQUE(OccupationRoleCode)
);

INSERT INTO mart.SafetyCardOccupationRole (OccupationRoleCode, OccupationRole) VALUES (-1, N'Unknown');
INSERT INTO mart.SafetyCardOccupationRole (OccupationRoleCode, OccupationRole) VALUES (0, N'Apprentice');
INSERT INTO mart.SafetyCardOccupationRole (OccupationRoleCode, OccupationRole) VALUES (1, N'Trainee');
INSERT INTO mart.SafetyCardOccupationRole (OccupationRoleCode, OccupationRole) VALUES (2, N'Foreman');
INSERT INTO mart.SafetyCardOccupationRole (OccupationRoleCode, OccupationRole) VALUES (3, N'Supervisor');
INSERT INTO mart.SafetyCardOccupationRole (OccupationRoleCode, OccupationRole) VALUES (4, N'Manager');
INSERT INTO mart.SafetyCardOccupationRole (OccupationRoleCode, OccupationRole) VALUES (5, N'Contracts Manager / Engineer');
INSERT INTO mart.SafetyCardOccupationRole (OccupationRoleCode, OccupationRole) VALUES (6, N'Director');
INSERT INTO mart.SafetyCardOccupationRole (OccupationRoleCode, OccupationRole) VALUES (7, N'General Operative');

CREATE TABLE mart.SafetyCardCategory
(
    SafetyCardCategory_key int IDENTITY
    ,SafetyCardCategoryId uniqueidentifier NOT NULL
    ,CategoryName nvarchar(500) NOT NULL
    ,CategoryReference nvarchar(50) NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.SafetyCardCategory__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.SafetyCardCategory] PRIMARY KEY (SafetyCardCategory_key)
    ,CONSTRAINT [UQ_mart.SafetyCardCategory_SafetyCardCategoryId] UNIQUE(SafetyCardCategoryId)
    ,CONSTRAINT [FK_mart.SafetyCardCategory_mart.Wallet_Wallet_key] FOREIGN KEY (Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.SafetyCard
(
    SafetyCard_key int IDENTITY
    ,SafetyCardId uniqueidentifier NOT NULL
    ,SafetyCardReference nvarchar(50) NOT NULL
    ,SafetyCardType_key int NOT NULL
    ,ReportedByUser nvarchar(100) NOT NULL
    ,ReportedDateTime datetime NOT NULL
    ,SafetyCardCategory_key int NOT NULL
    ,Employer nvarchar(max) NOT NULL
    ,Employee nvarchar(max) NOT NULL
    ,EmployeeContact_key int NULL -- allow NULLs
    ,InductionNumber nvarchar(500) NOT NULL
    ,ReportDetails nvarchar(max) NOT NULL
    ,SafetyCardStatus_key int NOT NULL
    ,HasSignature bit NOT NULL
    ,SignatureDate datetime NOT NULL
    ,Occupation nvarchar(255) NOT NULL
    ,SafetyCardOccupationRole_key int NOT NULL
    ,Location_key int NOT NULL
    ,ExternalIdentifier nvarchar(255) NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.SafetyCard__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.SafetyCard] PRIMARY KEY (SafetyCard_key)
    ,CONSTRAINT [UQ_mart.SafetyCard_SafetyCardId] UNIQUE(SafetyCardId)
    ,CONSTRAINT [FK_mart.SafetyCard_mart.SafetyCardType_SafetyCardType_key] FOREIGN KEY (SafetyCardType_key) REFERENCES mart.SafetyCardType
    ,CONSTRAINT [FK_mart.SafetyCard_mart.SafetyCardCategory_SafetyCardCategory_key] FOREIGN KEY (SafetyCardCategory_key) REFERENCES mart.SafetyCardCategory
    ,CONSTRAINT [FK_mart.SafetyCard_mart.SafetyCardStatus_SafetyCardStatus_key] FOREIGN KEY (SafetyCardStatus_key) REFERENCES mart.SafetyCardStatus
    ,CONSTRAINT [FK_mart.SafetyCard_mart.SafetyCardOccupationRole_SafetyCardOccupationRole_key] FOREIGN KEY (SafetyCardOccupationRole_key) REFERENCES mart.SafetyCardOccupationRole
    ,CONSTRAINT [FK_mart.SafetyCard_mart.Location_Location_key] FOREIGN KEY (Location_key) REFERENCES mart.[Location]
    ,CONSTRAINT [FK_mart.SafetyCard_mart.Wallet_Wallet_key] FOREIGN KEY (Wallet_key) REFERENCES mart.Wallet
);

GO
