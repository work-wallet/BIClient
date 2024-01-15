-- mart.AssetStatus
CREATE TABLE mart.AssetStatus
(
    AssetStatus_key int IDENTITY
    ,AssetStatusCode int NOT NULL /* business key */
    ,AssetStatus nvarchar(50) NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AssetStatus__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AssetStatus] PRIMARY KEY (AssetStatus_key)
    ,CONSTRAINT [UQ_mart.AssetStatus_AssetStatusCode] UNIQUE(AssetStatusCode)
);

INSERT INTO mart.AssetStatus (AssetStatusCode, AssetStatus) VALUES (0, N'Active');
INSERT INTO mart.AssetStatus (AssetStatusCode, AssetStatus) VALUES (1, N'Out Of Service');
INSERT INTO mart.AssetStatus (AssetStatusCode, AssetStatus) VALUES (2, N'Decomissioned');
INSERT INTO mart.AssetStatus (AssetStatusCode, AssetStatus) VALUES (3, N'Deleted');

-- mart.AssetPropertyType
CREATE TABLE mart.AssetPropertyType
(
    AssetPropertyType_key int IDENTITY
    ,AssetPropertyType nvarchar(50) NOT NULL
    ,CONSTRAINT [PK_mart.AssetPropertyType] PRIMARY KEY (AssetPropertyType_key)
    ,CONSTRAINT [UQ_mart.AssetPropertyType_AssetPropertyType] UNIQUE(AssetPropertyType)
)

INSERT INTO mart.AssetPropertyType (AssetPropertyType) VALUES (N'Text');
INSERT INTO mart.AssetPropertyType (AssetPropertyType) VALUES (N'Number');
INSERT INTO mart.AssetPropertyType (AssetPropertyType) VALUES (N'Select');

-- mart.AssetAssignmentType
CREATE TABLE mart.AssetAssignmentType
(
    AssetAssignmentType_key int IDENTITY
    ,AssetAssignmentType nvarchar(50) NOT NULL
    ,CONSTRAINT [PK_mart.AssetAssignmentType] PRIMARY KEY (AssetAssignmentType_key)
    ,CONSTRAINT [UQ_mart.AssetAssignmentType_AssetAssignmentType] UNIQUE(AssetAssignmentType)
)

INSERT INTO mart.AssetAssignmentType (AssetAssignmentType) VALUES (N'User');
INSERT INTO mart.AssetAssignmentType (AssetAssignmentType) VALUES (N'Site');
INSERT INTO mart.AssetAssignmentType (AssetAssignmentType) VALUES (N'Unassigned');

-- mart.Asset
CREATE TABLE mart.[Asset]
(
    Asset_key int IDENTITY
	,AssetId uniqueidentifier NOT NULL /* business key */
	,AssetType nvarchar(75) NOT NULL
    ,AssetStatus_key int NOT NULL
	,Reference nvarchar(143) NOT NULL
	,[Name] nvarchar(75) NOT NULL
	,[Description] nvarchar(max) NOT NULL
	,CreatedOn datetimeoffset(7) NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.Asset__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.Asset] PRIMARY KEY (Asset_key)
    ,CONSTRAINT [UQ_mart.Asset_AssetId] UNIQUE(AssetId)
)

ALTER TABLE mart.[Asset] WITH CHECK ADD CONSTRAINT [FK_mart.Asset_dbo.mart.AssetStatus_AssetStatus_key] FOREIGN KEY(AssetStatus_key)
REFERENCES mart.AssetStatus (AssetStatus_key);

ALTER TABLE mart.[Asset] CHECK CONSTRAINT [FK_mart.Asset_dbo.mart.AssetStatus_AssetStatus_key];

ALTER TABLE mart.Asset WITH CHECK ADD CONSTRAINT [FK_mart.Asset_dbo.mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key)
REFERENCES mart.[Wallet] (Wallet_key);

ALTER TABLE mart.Asset CHECK CONSTRAINT [FK_mart.Asset_dbo.mart.Wallet_Wallet_key];

-- mart.AssetProperty
CREATE TABLE mart.AssetProperty
(
    AssetProperty_key int IDENTITY
	,AssetPropertyType_key int NOT NULL
 	,Property nvarchar(250) NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AssetProperty__created] DEFAULT SYSUTCDATETIME()
    ,CONSTRAINT [PK_mart.AssetProperty] PRIMARY KEY (AssetProperty_key)
)

ALTER TABLE mart.AssetProperty WITH CHECK ADD CONSTRAINT [FK_mart.AssetProperty_dbo.mart.AssetPropertyType_AssetPropertyType_key] FOREIGN KEY(AssetPropertyType_key)
REFERENCES mart.[AssetPropertyType] (AssetPropertyType_key);

ALTER TABLE mart.AssetProperty CHECK CONSTRAINT [FK_mart.AssetProperty_dbo.mart.AssetPropertyType_AssetPropertyType_key];

ALTER TABLE mart.AssetProperty WITH CHECK ADD CONSTRAINT [FK_mart.AssetProperty_dbo.mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key)
REFERENCES mart.[Wallet] (Wallet_key);

ALTER TABLE mart.AssetProperty CHECK CONSTRAINT [FK_mart.AssetProperty_dbo.mart.Wallet_Wallet_key];

-- mart.AssetPropertyFact
CREATE TABLE mart.AssetPropertyFact
(
    AssetPropertyFact_key int IDENTITY
    ,Asset_key int NOT NULL
    ,AssetProperty_key int NOT NULL
	,[Value] nvarchar(max) NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AssetPropertyFact__created] DEFAULT SYSUTCDATETIME()
    ,CONSTRAINT [PK_mart.AssetPropertyFact] PRIMARY KEY (AssetPropertyFact_key)
)

ALTER TABLE mart.AssetPropertyFact WITH CHECK ADD CONSTRAINT [FK_mart.AssetPropertyFact_dbo.mart.Asset_Asset_key] FOREIGN KEY(Asset_key)
REFERENCES mart.[Asset] (Asset_key);

ALTER TABLE mart.AssetPropertyFact CHECK CONSTRAINT [FK_mart.AssetPropertyFact_dbo.mart.Asset_Asset_key];

ALTER TABLE mart.AssetPropertyFact WITH CHECK ADD CONSTRAINT [FK_mart.AssetPropertyFact_dbo.mart.AssetProperty_AssetProperty_key] FOREIGN KEY(AssetProperty_key)
REFERENCES mart.AssetProperty (AssetProperty_key);

ALTER TABLE mart.AssetPropertyFact CHECK CONSTRAINT [FK_mart.AssetPropertyFact_dbo.mart.AssetProperty_AssetProperty_key];

ALTER TABLE mart.AssetPropertyFact WITH CHECK ADD CONSTRAINT [FK_mart.AssetPropertyFact_dbo.mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key)
REFERENCES mart.[Wallet] (Wallet_key);

ALTER TABLE mart.AssetPropertyFact CHECK CONSTRAINT [FK_mart.AssetPropertyFact_dbo.mart.Wallet_Wallet_key];

-- mart.AssetAssignment
CREATE TABLE mart.AssetAssignment
(
    AssetAssignment_key int IDENTITY
	,AssetAssignmentType_key int NOT NULL
	,AssignedTo nvarchar(max) NOT NULL
	,CompanyId uniqueidentifier NOT NULL
	,Company nvarchar(max) NOT NULL
	,SiteId uniqueidentifier NOT NULL
	,[Site] nvarchar(max) NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AssetAssignment__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AssetAssignment] PRIMARY KEY (AssetAssignment_key)
)

ALTER TABLE mart.AssetAssignment WITH CHECK ADD CONSTRAINT [FK_mart.AssetAssignment_dbo.mart.AssetAssignmentType_AssetAssignmentType_key] FOREIGN KEY(AssetAssignmentType_key)
REFERENCES mart.[AssetAssignmentType] (AssetAssignmentType_key);

ALTER TABLE mart.AssetAssignment CHECK CONSTRAINT [FK_mart.AssetAssignment_dbo.mart.AssetAssignmentType_AssetAssignmentType_key];

ALTER TABLE mart.AssetAssignment WITH CHECK ADD CONSTRAINT [FK_mart.AssetAssignment_dbo.mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key)
REFERENCES mart.[Wallet] (Wallet_key);

ALTER TABLE mart.AssetAssignment CHECK CONSTRAINT [FK_mart.AssetAssignment_dbo.mart.Wallet_Wallet_key];

-- mart.AssetAssignmentFact
CREATE TABLE mart.AssetAssignmentFact
(
    AssetAssignmentFact_key int IDENTITY
    ,Asset_key int NOT NULL
    ,AssetAssignment_key int NOT NULL
	,AssignedOn datetimeoffset(7) NOT NULL
	,AssignedEnd datetimeoffset(7) NULL
    ,IsLatest bit NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AssetAssignmentFact__created] DEFAULT SYSUTCDATETIME()
    ,CONSTRAINT [PK_mart.AssetAssignmentFact] PRIMARY KEY (AssetAssignmentFact_key)
)

ALTER TABLE mart.AssetAssignmentFact WITH CHECK ADD CONSTRAINT [FK_mart.AssetAssignmentFact_dbo.mart.Asset_Asset_key] FOREIGN KEY(Asset_key)
REFERENCES mart.[Asset] (Asset_key);

ALTER TABLE mart.AssetAssignmentFact CHECK CONSTRAINT [FK_mart.AssetAssignmentFact_dbo.mart.Asset_Asset_key];

ALTER TABLE mart.AssetAssignmentFact WITH CHECK ADD CONSTRAINT [FK_mart.AssetAssignmentFact_dbo.mart.AssetAssignment_AssetAssignment_key] FOREIGN KEY(AssetAssignment_key)
REFERENCES mart.AssetAssignment (AssetAssignment_key);

ALTER TABLE mart.AssetAssignmentFact CHECK CONSTRAINT [FK_mart.AssetAssignmentFact_dbo.mart.AssetAssignment_AssetAssignment_key];

ALTER TABLE mart.AssetAssignmentFact WITH CHECK ADD CONSTRAINT [FK_mart.AssetAssignmentFact_dbo.mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key)
REFERENCES mart.[Wallet] (Wallet_key);

ALTER TABLE mart.AssetAssignmentFact CHECK CONSTRAINT [FK_mart.AssetAssignmentFact_dbo.mart.Wallet_Wallet_key];

GO