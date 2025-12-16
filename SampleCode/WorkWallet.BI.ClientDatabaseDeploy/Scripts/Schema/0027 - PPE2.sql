-- PPE: add PPEPropertyType dimension table
CREATE TABLE mart.PPEPropertyType
(
    PPEPropertyType_key int IDENTITY
    ,PPEPropertyType nvarchar(20) NOT NULL
    ,CONSTRAINT [PK_mart.PPEPropertyType] PRIMARY KEY (PPEPropertyType_key)
    ,CONSTRAINT [UQ_mart.PPEPropertyType_PPEPropertyType] UNIQUE(PPEPropertyType)
);

INSERT INTO mart.PPEPropertyType (PPEPropertyType) VALUES (N'Text');
INSERT INTO mart.PPEPropertyType (PPEPropertyType) VALUES (N'Number');
INSERT INTO mart.PPEPropertyType (PPEPropertyType) VALUES (N'Select');
INSERT INTO mart.PPEPropertyType (PPEPropertyType) VALUES (N'Date');
INSERT INTO mart.PPEPropertyType (PPEPropertyType) VALUES (N'Time');
INSERT INTO mart.PPEPropertyType (PPEPropertyType) VALUES (N'DateTime');

-- PPE: add PPEProperty dimension table
CREATE TABLE mart.PPEProperty
(
    PPEProperty_key int IDENTITY
    ,PPEPropertyType_key int NOT NULL
    ,Property nvarchar(250) NOT NULL
    ,DisplayOrder int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.PPEProperty__created] DEFAULT SYSUTCDATETIME()
    ,CONSTRAINT [PK_mart.PPEProperty] PRIMARY KEY (PPEProperty_key)
    ,CONSTRAINT [UQ_mart.PPEProperty_Business_Key] UNIQUE(PPEPropertyType_key, Property, Wallet_key)
    ,CONSTRAINT [FK_mart.PPEProperty_mart.PPEPropertyType_PPEPropertyType_key] FOREIGN KEY(PPEPropertyType_key) REFERENCES mart.PPEPropertyType
    ,CONSTRAINT [FK_mart.PPEProperty_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

-- PPE: add PPEPropertyFact table
-- Note: Uses PPETypeId natural key instead of PPEType_key surrogate because properties are scoped to Type level, not Type+Variant level
CREATE TABLE mart.PPEPropertyFact
(
    PPEPropertyFact_key int IDENTITY
    ,PPETypeId uniqueidentifier NOT NULL
    ,PPEProperty_key int NOT NULL
    ,[Value] nvarchar(max) NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.PPEPropertyFact__created] DEFAULT SYSUTCDATETIME()
    ,CONSTRAINT [PK_mart.PPEPropertyFact] PRIMARY KEY (PPEPropertyFact_key)
    ,CONSTRAINT [FK_mart.PPEPropertyFact_mart.PPEProperty_PPEProperty_key] FOREIGN KEY(PPEProperty_key) REFERENCES mart.PPEProperty
    ,CONSTRAINT [FK_mart.PPEPropertyFact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

-- PPE: add PPEGroup dimension table
CREATE TABLE mart.PPEGroup
(
    PPEGroup_key int IDENTITY
    ,PPEGroupId uniqueidentifier NOT NULL /* business key */
    ,PPEGroup nvarchar(100) NOT NULL
    ,Active bit NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.PPEGroup__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.PPEGroup] PRIMARY KEY (PPEGroup_key)
    ,CONSTRAINT [UQ_mart.PPEGroup_PPEGroupId] UNIQUE (PPEGroupId)
    ,CONSTRAINT [FK_mart.PPEGroup_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

-- PPE: add PPEGroupFact table (many-to-many relationship between PPEType and PPEGroup)
CREATE TABLE mart.PPEGroupFact
(
    PPEGroupFact_key int IDENTITY
    ,PPEType_key int NOT NULL
    ,PPEGroup_key int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.PPEGroupFact__created] DEFAULT SYSUTCDATETIME()
    ,CONSTRAINT [PK_mart.PPEGroupFact] PRIMARY KEY (PPEGroupFact_key)
    ,CONSTRAINT [UQ_mart.PPEGroupFact_Business_Key] UNIQUE (PPEType_key, PPEGroup_key)
    ,CONSTRAINT [FK_mart.PPEGroupFact_mart.PPEType_PPEType_key] FOREIGN KEY(PPEType_key) REFERENCES mart.PPEType
    ,CONSTRAINT [FK_mart.PPEGroupFact_mart.PPEGroup_PPEGroup_key] FOREIGN KEY(PPEGroup_key) REFERENCES mart.PPEGroup
    ,CONSTRAINT [FK_mart.PPEGroupFact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

GO
