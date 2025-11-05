-- Add support for the new property types used in Assets (not used in AssetInspections directly, but needed to bring the Assets module up to date)
-- (has been back-fixed in the 0009 script)
IF NOT EXISTS (SELECT 1 FROM mart.AssetPropertyType WHERE AssetPropertyType = N'Date')
BEGIN
    INSERT INTO mart.AssetPropertyType (AssetPropertyType) VALUES (N'Date');
END

IF NOT EXISTS (SELECT 1 FROM mart.AssetPropertyType WHERE AssetPropertyType = N'Time')
BEGIN
    INSERT INTO mart.AssetPropertyType (AssetPropertyType) VALUES (N'Time');
END

IF NOT EXISTS (SELECT 1 FROM mart.AssetPropertyType WHERE AssetPropertyType = N'DateTime')
BEGIN
    INSERT INTO mart.AssetPropertyType (AssetPropertyType) VALUES (N'DateTime');
END

-- AssetObservation Status lookup table
CREATE TABLE mart.AssetObservationStatus
(
    AssetObservationStatus_key int IDENTITY
    ,AssetObservationStatusCode int NOT NULL /* business key */
    ,AssetObservationStatus nvarchar(50) NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AssetObservationStatus__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AssetObservationStatus] PRIMARY KEY (AssetObservationStatus_key)
    ,CONSTRAINT [UQ_mart.AssetObservationStatus_AssetObservationStatusCode] UNIQUE(AssetObservationStatusCode)
);

INSERT INTO mart.AssetObservationStatus (AssetObservationStatusCode, AssetObservationStatus) VALUES (0, N'Observation');
INSERT INTO mart.AssetObservationStatus (AssetObservationStatusCode, AssetObservationStatus) VALUES (1, N'Defect (Open)');
INSERT INTO mart.AssetObservationStatus (AssetObservationStatusCode, AssetObservationStatus) VALUES (32, N'Defect (Closed)');

-- AssetInspection dimension table
CREATE TABLE mart.AssetInspection
(
    AssetInspection_key int IDENTITY
    ,InspectionId uniqueidentifier NOT NULL /* business key */
    ,Asset_key int NOT NULL
    ,InspectionTypeId uniqueidentifier NOT NULL
    ,InspectionType nvarchar(75) NOT NULL
    ,InspectionDate datetime NOT NULL
    ,InspectedBy nvarchar(81) NOT NULL
    ,Deleted bit NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AssetInspection__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AssetInspection] PRIMARY KEY (AssetInspection_key)
    ,CONSTRAINT [UQ_mart.AssetInspection_InspectionId] UNIQUE(InspectionId)
    ,CONSTRAINT [FK_mart.AssetInspection_mart.Asset_Asset_key] FOREIGN KEY(Asset_key) REFERENCES mart.Asset
    ,CONSTRAINT [FK_mart.AssetInspection_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

-- AssetInspectionChecklistItem dimension table
CREATE TABLE mart.AssetInspectionChecklistItem
(
    AssetInspectionChecklistItem_key int IDENTITY
    ,ChecklistId uniqueidentifier NOT NULL
    ,ChecklistName nvarchar(250) NOT NULL
    ,ChecklistItemId uniqueidentifier NOT NULL /* business key */
    ,ChecklistItemName nvarchar(250) NOT NULL
    ,ChecklistItemDisplayOrder int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AssetInspectionChecklistItem__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AssetInspectionChecklistItem] PRIMARY KEY (AssetInspectionChecklistItem_key)
    ,CONSTRAINT [UQ_mart.AssetInspectionChecklistItem_ChecklistItemId] UNIQUE(ChecklistItemId)
    ,CONSTRAINT [FK_mart.AssetInspectionChecklistItem_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

-- AssetInspectionProperty dimension table
CREATE TABLE mart.AssetInspectionProperty
(
    AssetInspectionProperty_key int IDENTITY
    ,AssetPropertyType_key int NOT NULL
    ,Property nvarchar(250) NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AssetInspectionProperty__created] DEFAULT SYSUTCDATETIME()
    ,CONSTRAINT [PK_mart.AssetInspectionProperty] PRIMARY KEY (AssetInspectionProperty_key)
    ,CONSTRAINT [FK_mart.AssetInspectionProperty_mart.AssetPropertyType_AssetPropertyType_key] FOREIGN KEY(AssetPropertyType_key) REFERENCES mart.AssetPropertyType
    ,CONSTRAINT [FK_mart.AssetInspectionProperty_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

-- AssetObservation dimension table
CREATE TABLE mart.AssetObservation
(
    AssetObservation_key int IDENTITY
    ,ObservationId uniqueidentifier NOT NULL /* business key */
    ,Asset_key int NOT NULL
    ,Details nvarchar(max) NOT NULL
    ,ActionTaken nvarchar(max) NOT NULL
    ,AssetObservationStatus_key int NOT NULL
    ,ObservedOn datetimeoffset(7) NOT NULL
    ,ObservedBy nvarchar(81) NOT NULL
    ,ClosedOn datetimeoffset(7) NULL -- allow NULLs
    ,ClosedBy nvarchar(81) NOT NULL
    ,ClosureNotes nvarchar(max) NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AssetObservation__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AssetObservation] PRIMARY KEY (AssetObservation_key)
    ,CONSTRAINT [UQ_mart.AssetObservation_ObservationId] UNIQUE(ObservationId)
    ,CONSTRAINT [FK_mart.AssetObservation_mart.Asset_Asset_key] FOREIGN KEY(Asset_key) REFERENCES mart.Asset
    ,CONSTRAINT [FK_mart.AssetObservation_mart.AssetObservationStatus_AssetObservationStatus_key] FOREIGN KEY(AssetObservationStatus_key) REFERENCES mart.AssetObservationStatus
    ,CONSTRAINT [FK_mart.AssetObservation_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

-- AssetInspectionPropertyFact fact table
CREATE TABLE mart.AssetInspectionPropertyFact
(
    AssetInspectionPropertyFact_key int IDENTITY
    ,AssetInspection_key int NOT NULL
    ,AssetInspectionProperty_key int NOT NULL
    ,[Value] nvarchar(max) NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AssetInspectionPropertyFact__created] DEFAULT SYSUTCDATETIME()
    ,CONSTRAINT [PK_mart.AssetInspectionPropertyFact] PRIMARY KEY (AssetInspectionPropertyFact_key)
    ,CONSTRAINT [FK_mart.AssetInspectionPropertyFact_mart.AssetInspection_AssetInspection_key] FOREIGN KEY(AssetInspection_key) REFERENCES mart.AssetInspection
    ,CONSTRAINT [FK_mart.AssetInspectionPropertyFact_mart.AssetInspectionProperty_AssetInspectionProperty_key] FOREIGN KEY(AssetInspectionProperty_key) REFERENCES mart.AssetInspectionProperty
    ,CONSTRAINT [FK_mart.AssetInspectionPropertyFact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

-- AssetInspectionChecklistItemFact fact table
CREATE TABLE mart.AssetInspectionChecklistItemFact
(
    AssetInspectionChecklistItemFact_key int IDENTITY
    ,AssetInspection_key int NOT NULL
    ,AssetInspectionChecklistItem_key int NOT NULL
    ,Response int NOT NULL
    ,ResponseText nvarchar(64) NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AssetInspectionChecklistItemFact__created] DEFAULT SYSUTCDATETIME()
    ,CONSTRAINT [PK_mart.AssetInspectionChecklistItemFact] PRIMARY KEY (AssetInspectionChecklistItemFact_key)
    ,CONSTRAINT [FK_mart.AssetInspectionChecklistItemFact_mart.AssetInspection_AssetInspection_key] FOREIGN KEY(AssetInspection_key) REFERENCES mart.AssetInspection
    ,CONSTRAINT [FK_mart.AssetInspectionChecklistItemFact_mart.AssetInspectionChecklistItem_AssetInspectionChecklistItem_key] FOREIGN KEY(AssetInspectionChecklistItem_key) REFERENCES mart.AssetInspectionChecklistItem
    ,CONSTRAINT [FK_mart.AssetInspectionChecklistItemFact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

-- AssetInspectionObservationFact fact table (links inspections/checklists and observations)
CREATE TABLE mart.AssetInspectionObservationFact
(
    AssetInspectionObservationFact_key int IDENTITY
    ,AssetInspection_key int NOT NULL
    ,AssetObservation_key int NOT NULL
    ,AssetInspectionChecklistItem_key int NULL -- allow NULLs (observation may not be linked to a specific checklist item)
    ,[New] bit NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AssetInspectionObservationFact__created] DEFAULT SYSUTCDATETIME()
    ,CONSTRAINT [PK_mart.AssetInspectionObservationFact] PRIMARY KEY (AssetInspectionObservationFact_key)
    ,CONSTRAINT [FK_mart.AssetInspectionObservationFact_mart.AssetInspection_AssetInspection_key] FOREIGN KEY(AssetInspection_key) REFERENCES mart.AssetInspection
    ,CONSTRAINT [FK_mart.AssetInspectionObservationFact_mart.AssetObservation_AssetObservation_key] FOREIGN KEY(AssetObservation_key) REFERENCES mart.AssetObservation
    ,CONSTRAINT [FK_mart.AssetInspectionObservationFact_mart.AssetInspectionChecklistItem_AssetInspectionChecklistItem_key] FOREIGN KEY(AssetInspectionChecklistItem_key) REFERENCES mart.AssetInspectionChecklistItem
    ,CONSTRAINT [FK_mart.AssetInspectionObservationFact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);
