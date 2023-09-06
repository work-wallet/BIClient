-- mart.SiteAuditStatus
CREATE TABLE mart.SiteAuditStatus
(   SiteAuditStatus_key int IDENTITY
    ,SiteAuditStatusCode int NOT NULL /* business key */
    ,SiteAuditStatus nvarchar(50) NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.SiteAuditStatus__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.SiteAuditStatus] PRIMARY KEY (SiteAuditStatus_key)
    ,CONSTRAINT [UQ_mart.SiteAuditStatus_Code] UNIQUE(SiteAuditStatusCode)
);

INSERT INTO mart.SiteAuditStatus (SiteAuditStatusCode, SiteAuditStatus) VALUES (0, N'Planned');
INSERT INTO mart.SiteAuditStatus (SiteAuditStatusCode, SiteAuditStatus) VALUES (1, N'In Progress');
INSERT INTO mart.SiteAuditStatus (SiteAuditStatusCode, SiteAuditStatus) VALUES (2, N'Ready for Signature');
INSERT INTO mart.SiteAuditStatus (SiteAuditStatusCode, SiteAuditStatus) VALUES (3, N'Complete (Open)');
INSERT INTO mart.SiteAuditStatus (SiteAuditStatusCode, SiteAuditStatus) VALUES (4, N'Cancelled');
INSERT INTO mart.SiteAuditStatus (SiteAuditStatusCode, SiteAuditStatus) VALUES (5, N'Deleted');
INSERT INTO mart.SiteAuditStatus (SiteAuditStatusCode, SiteAuditStatus) VALUES (6, N'Closed');

-- mart.SiteAuditType (type 1 SCD - though possibly should be type 2 due to controls for scoring methods)
CREATE TABLE mart.SiteAuditType
(
    SiteAuditType_key int IDENTITY
    ,SiteAuditTypeId uniqueidentifier NOT NULL /* business key */
    ,SiteAuditType nvarchar(75) NOT NULL
    ,DisplayScoring bit NOT NULL
    ,ScoringMethod int NOT NULL
    ,DisplayOptions int NOT NULL
    ,ShowPercentage bit NOT NULL
    ,ShowScore bit NOT NULL
    ,ShowPassFail bit NOT NULL
    ,ShowGrading bit NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.SiteAuditType__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.SiteAuditType] PRIMARY KEY (SiteAuditType_key)
    ,CONSTRAINT [UQ_mart.SiteAuditType_SiteAuditTypeId] UNIQUE(SiteAuditTypeId)
)

ALTER TABLE mart.SiteAuditType WITH CHECK ADD CONSTRAINT [FK_mart.SiteAuditType_dbo.mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key)
REFERENCES mart.[Wallet] (Wallet_key);

ALTER TABLE mart.SiteAuditType CHECK CONSTRAINT [FK_mart.SiteAuditType_dbo.mart.Wallet_Wallet_key];

-- mart.SiteAudit
CREATE TABLE mart.SiteAudit
(
    SiteAudit_key int IDENTITY
    ,SiteAuditId uniqueidentifier NOT NULL /* business key */
    ,AuditReference nvarchar(50) NOT NULL
    ,DateAndTimeOfInspection datetime2(7) NOT NULL
    ,SiteAuditStatus_key int NOT NULL
    ,SiteAuditType_key int NOT NULL
    ,Location_key int NOT NULL
    ,AuditSummary nvarchar(max) NOT NULL
    ,HasScore bit NOT NULL
    ,Passed bit NOT NULL
    ,ActualScore decimal(5,2) NOT NULL
    ,PotentialScore decimal(5,2) NOT NULL
    ,[Percent] int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.SiteAudit__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.SiteAudit] PRIMARY KEY (SiteAudit_key)
    ,CONSTRAINT [UQ_mart.SiteAudit_SiteAuditId] UNIQUE(SiteAuditId)
)

ALTER TABLE mart.SiteAudit WITH CHECK ADD CONSTRAINT [FK_mart.SiteAudit_dbo.mart.SiteAuditStatus_SiteAuditStatus_key] FOREIGN KEY(SiteAuditStatus_key)
REFERENCES mart.SiteAuditStatus (SiteAuditStatus_key);

ALTER TABLE mart.SiteAudit CHECK CONSTRAINT [FK_mart.SiteAudit_dbo.mart.SiteAuditStatus_SiteAuditStatus_key];

ALTER TABLE mart.SiteAudit WITH CHECK ADD CONSTRAINT [FK_mart.SiteAudit_dbo.mart.SiteAuditType_SiteAuditType_key] FOREIGN KEY(SiteAuditType_key)
REFERENCES mart.SiteAuditType (SiteAuditType_key);

ALTER TABLE mart.SiteAudit CHECK CONSTRAINT [FK_mart.SiteAudit_dbo.mart.SiteAuditType_SiteAuditType_key];

ALTER TABLE mart.SiteAudit WITH CHECK ADD CONSTRAINT [FK_mart.SiteAudit_dbo.mart.Location_Location_key] FOREIGN KEY(Location_key)
REFERENCES mart.[Location] (Location_key);

ALTER TABLE mart.SiteAudit CHECK CONSTRAINT [FK_mart.SiteAudit_dbo.mart.Location_Location_key];

ALTER TABLE mart.SiteAudit WITH CHECK ADD CONSTRAINT [FK_mart.SiteAudit_dbo.mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key)
REFERENCES mart.[Wallet] (Wallet_key);

ALTER TABLE mart.SiteAudit CHECK CONSTRAINT [FK_mart.SiteAudit_dbo.mart.Wallet_Wallet_key];

-- mart.SiteAuditChecklist
CREATE TABLE mart.SiteAuditChecklist
(
    SiteAuditChecklist_key int IDENTITY
    ,SiteAuditChecklistId uniqueidentifier NOT NULL /* business key */
    ,SiteAuditChecklistVersion int NOT NULL /* business key */
    ,ChecklistName nvarchar(250) NOT NULL
    ,ChecklistDescription nvarchar(1000) NOT NULL
    ,NumberOfResponseOptions int NOT NULL
    ,ScoringEnabled bit NOT NULL
    ,PassStatus int NOT NULL
    ,ChecklistWeighting int NOT NULL
    ,FailedItemScoring int NOT NULL
    ,FailedItemsCountTowardsAverageScore bit NOT NULL
    ,FailedItemsSetTheChecklistScoreToZero bit NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.SiteAuditChecklist__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.SiteAuditChecklist] PRIMARY KEY (SiteAuditChecklist_key)
    ,CONSTRAINT [UQ_mart.SiteAuditChecklist_SiteAuditChecklistId_SiteAuditChecklistVersion] UNIQUE(SiteAuditChecklistId, SiteAuditChecklistVersion)
)

ALTER TABLE mart.SiteAuditChecklist WITH CHECK ADD CONSTRAINT [FK_mart.SiteAuditChecklist_dbo.mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key)
REFERENCES mart.[Wallet] (Wallet_key);

ALTER TABLE mart.SiteAuditChecklist CHECK CONSTRAINT [FK_mart.SiteAuditChecklist_dbo.mart.Wallet_Wallet_key];

-- mart.SiteAuditChecklistItem
CREATE TABLE mart.SiteAuditChecklistItem
(
    SiteAuditChecklistItem_key int IDENTITY
    ,SiteAuditChecklistItemId uniqueidentifier NOT NULL /* business key */
    ,SiteAuditChecklist_key int NOT NULL
    ,ChecklistItemTitle nvarchar(250) NOT NULL
    ,ChecklistItemDescription nvarchar(1000) NOT NULL
    ,DisplayOrder int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.SiteAuditChecklistItem__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.SiteAuditChecklistItem] PRIMARY KEY (SiteAuditChecklistItem_key)
    ,CONSTRAINT [UQ_mart.SiteAuditChecklistItem_SiteAuditChecklistItemId] UNIQUE(SiteAuditChecklistItemId)
)

ALTER TABLE mart.SiteAuditChecklistItem WITH CHECK ADD CONSTRAINT [FK_mart.SiteAuditChecklistItem_dbo.mart.SiteAuditChecklist_SiteAuditChecklist_key] FOREIGN KEY(SiteAuditChecklist_key)
REFERENCES mart.SiteAuditChecklist (SiteAuditChecklist_key);

ALTER TABLE mart.SiteAuditChecklistItem CHECK CONSTRAINT [FK_mart.SiteAuditChecklistItem_dbo.mart.SiteAuditChecklist_SiteAuditChecklist_key];

ALTER TABLE mart.SiteAuditChecklistItem WITH CHECK ADD CONSTRAINT [FK_mart.SiteAuditChecklistItem_dbo.mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key)
REFERENCES mart.[Wallet] (Wallet_key);

ALTER TABLE mart.SiteAuditChecklistItem CHECK CONSTRAINT [FK_mart.SiteAuditChecklistItem_dbo.mart.Wallet_Wallet_key];

-- mart.SiteAuditChecklistFact
CREATE TABLE mart.SiteAuditChecklistFact
(
    -- keys
    SiteAudit_key int NOT NULL /* primary key - include first, as used to delete old facts */
    ,SiteAuditChecklist_key int NOT NULL /* primary key */
    ,SiteAuditType_key int NOT NULL
    ,Location_key int NOT NULL
    ,SiteAuditStatus_key int NOT NULL
    ,Wallet_key int NOT NULL
    -- facts
    ,HasScore bit NOT NULL
    ,Score decimal(5,2) NOT NULL
    ,PotentialScore decimal(5,2) NOT NULL
    ,[Percent] int NOT NULL
    ,PassFailStatus int NOT NULL
    ,Passed bit NOT NULL
    ,PassScore int NOT NULL
    ,CONSTRAINT [PK_mart.SiteAuditChecklistFact] PRIMARY KEY (SiteAudit_key, SiteAuditChecklist_key)
)

ALTER TABLE mart.SiteAuditChecklistFact WITH CHECK ADD CONSTRAINT [FK_mart.SiteAuditChecklistFact_dbo.mart.SiteAudit_SiteAudit_key] FOREIGN KEY(SiteAudit_key)
REFERENCES mart.[SiteAudit] (SiteAudit_key);

ALTER TABLE mart.SiteAuditChecklistFact CHECK CONSTRAINT [FK_mart.SiteAuditChecklistFact_dbo.mart.SiteAudit_SiteAudit_key];

ALTER TABLE mart.SiteAuditChecklistFact WITH CHECK ADD CONSTRAINT [FK_mart.SiteAuditChecklistFact_dbo.mart.SiteAuditChecklist_SiteAuditChecklist_key] FOREIGN KEY(SiteAuditChecklist_key)
REFERENCES mart.[SiteAuditChecklist] (SiteAuditChecklist_key);

ALTER TABLE mart.SiteAuditChecklistFact CHECK CONSTRAINT [FK_mart.SiteAuditChecklistFact_dbo.mart.SiteAuditChecklist_SiteAuditChecklist_key];

ALTER TABLE mart.SiteAuditChecklistFact WITH CHECK ADD CONSTRAINT [FK_mart.SiteAuditChecklistFact_dbo.mart.SiteAuditType_SiteAuditType_key] FOREIGN KEY(SiteAuditType_key)
REFERENCES mart.[SiteAuditType] (SiteAuditType_key);

ALTER TABLE mart.SiteAuditChecklistFact CHECK CONSTRAINT [FK_mart.SiteAuditChecklistFact_dbo.mart.SiteAuditType_SiteAuditType_key];

ALTER TABLE mart.SiteAuditChecklistFact WITH CHECK ADD CONSTRAINT [FK_mart.SiteAuditChecklistFact_dbo.mart.Location_Location_key] FOREIGN KEY(Location_key)
REFERENCES mart.[Location] (Location_key);

ALTER TABLE mart.SiteAuditChecklistFact CHECK CONSTRAINT [FK_mart.SiteAuditChecklistFact_dbo.mart.Location_Location_key];

ALTER TABLE mart.SiteAuditChecklistFact WITH CHECK ADD CONSTRAINT [FK_mart.SiteAuditChecklistFact_dbo.mart.SiteAuditStatus_SiteAuditStatus_key] FOREIGN KEY(SiteAuditStatus_key)
REFERENCES mart.[SiteAuditStatus] (SiteAuditStatus_key);

ALTER TABLE mart.SiteAuditChecklistFact CHECK CONSTRAINT [FK_mart.SiteAuditChecklistFact_dbo.mart.SiteAuditStatus_SiteAuditStatus_key];

ALTER TABLE mart.SiteAuditChecklistFact WITH CHECK ADD CONSTRAINT [FK_mart.SiteAuditChecklistFact_dbo.mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key)
REFERENCES mart.[Wallet] (Wallet_key);

ALTER TABLE mart.SiteAuditChecklistFact CHECK CONSTRAINT [FK_mart.SiteAuditChecklistFact_dbo.mart.Wallet_Wallet_key];

-- mart.SiteAuditChecklistFact
CREATE TABLE mart.SiteAuditChecklistItemFact
(
    -- keys
    SiteAudit_key int NOT NULL /* primary key - include first, as used to delete old facts */
    ,SiteAuditChecklist_key int NOT NULL /* primary key */
    ,SiteAuditChecklistItem_key int NOT NULL /* primary key */
    ,SiteAuditType_key int NOT NULL
    ,Location_key int NOT NULL
    ,SiteAuditStatus_key int NOT NULL
    ,Wallet_key int NOT NULL
    -- facts
    ,ChecklistItemStatusName nvarchar(64) NOT NULL
    ,ChecklistItemStatus int NOT NULL
    ,CONSTRAINT [PK_mart.SiteAuditChecklistItemFact] PRIMARY KEY (SiteAudit_key, SiteAuditChecklist_key, SiteAuditChecklistItem_key)
)

ALTER TABLE mart.SiteAuditChecklistItemFact WITH CHECK ADD CONSTRAINT [FK_mart.SiteAuditChecklistItemFact_dbo.mart.SiteAudit_SiteAudit_key] FOREIGN KEY(SiteAudit_key)
REFERENCES mart.[SiteAudit] (SiteAudit_key);

ALTER TABLE mart.SiteAuditChecklistItemFact CHECK CONSTRAINT [FK_mart.SiteAuditChecklistItemFact_dbo.mart.SiteAudit_SiteAudit_key];

ALTER TABLE mart.SiteAuditChecklistItemFact WITH CHECK ADD CONSTRAINT [FK_mart.SiteAuditChecklistItemFact_dbo.mart.SiteAuditChecklist_SiteAuditChecklist_key] FOREIGN KEY(SiteAuditChecklist_key)
REFERENCES mart.[SiteAuditChecklist] (SiteAuditChecklist_key);

ALTER TABLE mart.SiteAuditChecklistItemFact CHECK CONSTRAINT [FK_mart.SiteAuditChecklistItemFact_dbo.mart.SiteAuditChecklist_SiteAuditChecklist_key];

ALTER TABLE mart.SiteAuditChecklistItemFact WITH CHECK ADD CONSTRAINT [FK_mart.SiteAuditChecklistItemFact_dbo.mart.SiteAuditChecklistItem_SiteAuditChecklistItem_key] FOREIGN KEY(SiteAuditChecklistItem_key)
REFERENCES mart.[SiteAuditChecklistItem] (SiteAuditChecklistItem_key);

ALTER TABLE mart.SiteAuditChecklistItemFact CHECK CONSTRAINT [FK_mart.SiteAuditChecklistItemFact_dbo.mart.SiteAuditChecklistItem_SiteAuditChecklistItem_key];

ALTER TABLE mart.SiteAuditChecklistItemFact WITH CHECK ADD CONSTRAINT [FK_mart.SiteAuditChecklistItemFact_dbo.mart.SiteAuditType_SiteAuditType_key] FOREIGN KEY(SiteAuditType_key)
REFERENCES mart.[SiteAuditType] (SiteAuditType_key);

ALTER TABLE mart.SiteAuditChecklistItemFact CHECK CONSTRAINT [FK_mart.SiteAuditChecklistItemFact_dbo.mart.SiteAuditType_SiteAuditType_key];

ALTER TABLE mart.SiteAuditChecklistItemFact WITH CHECK ADD CONSTRAINT [FK_mart.SiteAuditChecklistItemFact_dbo.mart.Location_Location_key] FOREIGN KEY(Location_key)
REFERENCES mart.[Location] (Location_key);

ALTER TABLE mart.SiteAuditChecklistItemFact CHECK CONSTRAINT [FK_mart.SiteAuditChecklistItemFact_dbo.mart.Location_Location_key];

ALTER TABLE mart.SiteAuditChecklistItemFact WITH CHECK ADD CONSTRAINT [FK_mart.SiteAuditChecklistItemFact_dbo.mart.SiteAuditStatus_SiteAuditStatus_key] FOREIGN KEY(SiteAuditStatus_key)
REFERENCES mart.[SiteAuditStatus] (SiteAuditStatus_key);

ALTER TABLE mart.SiteAuditChecklistItemFact CHECK CONSTRAINT [FK_mart.SiteAuditChecklistItemFact_dbo.mart.SiteAuditStatus_SiteAuditStatus_key];

ALTER TABLE mart.SiteAuditChecklistItemFact WITH CHECK ADD CONSTRAINT [FK_mart.SiteAuditChecklistItemFact_dbo.mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key)
REFERENCES mart.[Wallet] (Wallet_key);

ALTER TABLE mart.SiteAuditChecklistItemFact CHECK CONSTRAINT [FK_mart.SiteAuditChecklistItemFact_dbo.mart.Wallet_Wallet_key];

GO
