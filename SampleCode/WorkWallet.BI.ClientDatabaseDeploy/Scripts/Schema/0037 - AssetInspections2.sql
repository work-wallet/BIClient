-- Replace the old AssetInspections/AssetObservations schema entirely with the new
-- AssetInspections2/AssetObservations2 shape (audit-style workflow, scoring, grading).
-- The old v1 API endpoints are dead-ended (always return empty data) so this drops
-- the old tables outright rather than keeping them alongside the new ones.
-- AssetObservationStatus is untouched - ObservationStatusCode semantics are unchanged.

DROP TABLE mart.AssetInspectionPropertyFact;
DROP TABLE mart.AssetInspectionChecklistItemFact;
DROP TABLE mart.AssetInspectionObservationFact;
DROP TABLE mart.AssetInspectionProperty;
DROP TABLE mart.AssetInspectionChecklistItem;
DROP TABLE mart.AssetInspection;
DROP TABLE mart.AssetObservation;

-- AssetInspectionStatus lookup table (distinct enum to AuditStatusCode)
CREATE TABLE mart.AssetInspectionStatus
(
    AssetInspectionStatus_key int IDENTITY
    ,InspectionStatusCode int NOT NULL /* business key */
    ,InspectionStatus nvarchar(50) NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AssetInspectionStatus__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AssetInspectionStatus] PRIMARY KEY (AssetInspectionStatus_key)
    ,CONSTRAINT [UQ_mart.AssetInspectionStatus_InspectionStatusCode] UNIQUE (InspectionStatusCode)
);

INSERT INTO mart.AssetInspectionStatus (InspectionStatusCode, InspectionStatus) VALUES (0, N'Complete');
INSERT INTO mart.AssetInspectionStatus (InspectionStatusCode, InspectionStatus) VALUES (1, N'Adjustment');
INSERT INTO mart.AssetInspectionStatus (InspectionStatusCode, InspectionStatus) VALUES (2, N'InProgress');
INSERT INTO mart.AssetInspectionStatus (InspectionStatusCode, InspectionStatus) VALUES (3, N'Deleted');
INSERT INTO mart.AssetInspectionStatus (InspectionStatusCode, InspectionStatus) VALUES (4, N'ReadyForReview');
INSERT INTO mart.AssetInspectionStatus (InspectionStatusCode, InspectionStatus) VALUES (5, N'Archived');

-- InspectionWorkflowComponentType lookup table (generic across the solution, not just Asset Inspections;
-- filtered to the codes that can appear as AssetInspectionObservationFact.WorkflowComponentTypeCode)
CREATE TABLE mart.InspectionWorkflowComponentType
(
    InspectionWorkflowComponentType_key int IDENTITY
    ,WorkflowComponentTypeCode int NOT NULL /* business key */
    ,WorkflowComponentType nvarchar(50) NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.InspectionWorkflowComponentType__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.InspectionWorkflowComponentType] PRIMARY KEY (InspectionWorkflowComponentType_key)
    ,CONSTRAINT [UQ_mart.InspectionWorkflowComponentType_WorkflowComponentTypeCode] UNIQUE (WorkflowComponentTypeCode)
);

INSERT INTO mart.InspectionWorkflowComponentType (WorkflowComponentTypeCode, WorkflowComponentType) VALUES (5, N'ChecklistOption');
INSERT INTO mart.InspectionWorkflowComponentType (WorkflowComponentTypeCode, WorkflowComponentType) VALUES (6, N'TextQuestion');
INSERT INTO mart.InspectionWorkflowComponentType (WorkflowComponentTypeCode, WorkflowComponentType) VALUES (7, N'Signature');
INSERT INTO mart.InspectionWorkflowComponentType (WorkflowComponentTypeCode, WorkflowComponentType) VALUES (8, N'Image');
INSERT INTO mart.InspectionWorkflowComponentType (WorkflowComponentTypeCode, WorkflowComponentType) VALUES (11, N'BranchOption');
INSERT INTO mart.InspectionWorkflowComponentType (WorkflowComponentTypeCode, WorkflowComponentType) VALUES (15, N'NumericQuestion');
INSERT INTO mart.InspectionWorkflowComponentType (WorkflowComponentTypeCode, WorkflowComponentType) VALUES (17, N'DateTimeQuestion');
INSERT INTO mart.InspectionWorkflowComponentType (WorkflowComponentTypeCode, WorkflowComponentType) VALUES (18, N'ScoredResponse');

CREATE TABLE mart.AssetInspectionType
(
    AssetInspectionType_key int IDENTITY
    ,InspectionTypeId uniqueidentifier NOT NULL /* business key */
    ,InspectionTypeVersion int NOT NULL         /* business key */
    ,InspectionType nvarchar(500) NOT NULL
    ,[Description] nvarchar(2000) NOT NULL
    ,ScoringEnabled bit NOT NULL
    ,DisplayPercentage bit NOT NULL
    ,DisplayTotalScore bit NOT NULL
    ,DisplayAverageScore bit NOT NULL
    ,GradingSetId uniqueidentifier NOT NULL
    ,GradingSetVersion int NOT NULL
    ,GradingSet nvarchar(100) NOT NULL
    ,GradingSetIsPercentage bit NOT NULL
    ,GradingSetIsScore bit NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AssetInspectionType__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AssetInspectionType] PRIMARY KEY (AssetInspectionType_key)
    ,CONSTRAINT [UQ_mart.AssetInspectionType_InspectionTypeId_InspectionTypeVersion] UNIQUE(InspectionTypeId, InspectionTypeVersion)
    ,CONSTRAINT [FK_mart.AssetInspectionType_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.AssetInspectionNumericQuestion
(
    AssetInspectionNumericQuestion_key int IDENTITY
    ,QuestionId uniqueidentifier NOT NULL /* business key */
    ,Question nvarchar(max) NOT NULL
    ,Mandatory bit NOT NULL
    ,Scale int NOT NULL
    ,Unit_key int NOT NULL
    ,Section nvarchar(250) NOT NULL
    ,OrderInSection int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AssetInspectionNumericQuestion__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AssetInspectionNumericQuestion] PRIMARY KEY (AssetInspectionNumericQuestion_key)
    ,CONSTRAINT [UQ_mart.AssetInspectionNumericQuestion_QuestionId] UNIQUE(QuestionId)
    ,CONSTRAINT [FK_mart.AssetInspectionNumericQuestion_mart.Unit_Unit_key] FOREIGN KEY(Unit_key) REFERENCES mart.Unit
    ,CONSTRAINT [FK_mart.AssetInspectionNumericQuestion_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.AssetInspectionDateTimeQuestion
(
    AssetInspectionDateTimeQuestion_key int IDENTITY
    ,QuestionId uniqueidentifier NOT NULL /* business key */
    ,Question nvarchar(max) NOT NULL
    ,Mandatory bit NOT NULL
    ,[Date] bit NOT NULL
    ,[Time] bit NOT NULL
    ,Section nvarchar(250) NOT NULL
    ,OrderInSection int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AssetInspectionDateTimeQuestion__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AssetInspectionDateTimeQuestion] PRIMARY KEY (AssetInspectionDateTimeQuestion_key)
    ,CONSTRAINT [UQ_mart.AssetInspectionDateTimeQuestion_QuestionId] UNIQUE(QuestionId)
    ,CONSTRAINT [FK_mart.AssetInspectionDateTimeQuestion_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.AssetInspectionChecklistOption
(
    AssetInspectionChecklistOption_key int IDENTITY
    ,ChecklistId uniqueidentifier NOT NULL /* business key */
    ,OptionId uniqueidentifier NOT NULL    /* business key */
    ,Question nvarchar(max) NOT NULL
    ,[Value] nvarchar(250) NOT NULL
    ,Mandatory bit NOT NULL
    ,[Order] int NOT NULL
    ,Section nvarchar(250) NOT NULL
    ,OrderInSection int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AssetInspectionChecklistOption__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AssetInspectionChecklistOption] PRIMARY KEY (AssetInspectionChecklistOption_key)
    ,CONSTRAINT [UQ_mart.AssetInspectionChecklistOption_ChecklistId_OptionId] UNIQUE(ChecklistId, OptionId)
    ,CONSTRAINT [FK_mart.AssetInspectionChecklistOption_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.AssetInspectionBranchOption
(
    AssetInspectionBranchOption_key int IDENTITY
    ,BranchId uniqueidentifier NOT NULL /* business key */
    ,OptionId uniqueidentifier NOT NULL /* business key */
    ,Branch nvarchar(max) NOT NULL
    ,[Value] nvarchar(250) NOT NULL
    ,[Order] int NOT NULL
    ,Section nvarchar(250) NOT NULL
    ,OrderInSection int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AssetInspectionBranchOption__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AssetInspectionBranchOption] PRIMARY KEY (AssetInspectionBranchOption_key)
    ,CONSTRAINT [UQ_mart.AssetInspectionBranchOption_BranchId_OptionId] UNIQUE(BranchId, OptionId)
    ,CONSTRAINT [FK_mart.AssetInspectionBranchOption_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.AssetInspectionScoredResponse
(
    AssetInspectionScoredResponse_key int IDENTITY
    ,BranchId uniqueidentifier NOT NULL /* business key */
    ,OptionId uniqueidentifier NOT NULL /* business key */
    ,Branch nvarchar(max) NOT NULL
    ,[Value] nvarchar(100) NOT NULL
    ,[Order] int NOT NULL
    ,Section nvarchar(250) NOT NULL
    ,OrderInSection int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AssetInspectionScoredResponse__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AssetInspectionScoredResponse] PRIMARY KEY (AssetInspectionScoredResponse_key)
    ,CONSTRAINT [UQ_mart.AssetInspectionScoredResponse_BranchId_OptionId] UNIQUE(BranchId, OptionId)
    ,CONSTRAINT [FK_mart.AssetInspectionScoredResponse_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.AssetInspectionScoreSection
(
    AssetInspectionScoreSection_key int IDENTITY
    ,AssetInspectionType_key int NOT NULL /* business key */
    ,SectionId uniqueidentifier NOT NULL  /* business key */
    ,Section nvarchar(250) NOT NULL
    ,DisplayScore bit NOT NULL
    ,[Order] int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AssetInspectionScoreSection__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AssetInspectionScoreSection] PRIMARY KEY (AssetInspectionScoreSection_key)
    ,CONSTRAINT [UQ_mart.AssetInspectionScoreSection_AssetInspectionType_key_SectionId] UNIQUE(AssetInspectionType_key, SectionId)
    ,CONSTRAINT [FK_mart.AssetInspectionScoreSection_mart.AssetInspectionType_AssetInspectionType_key] FOREIGN KEY(AssetInspectionType_key) REFERENCES mart.AssetInspectionType
    ,CONSTRAINT [FK_mart.AssetInspectionScoreSection_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.AssetInspectionScoreTag
(
    AssetInspectionScoreTag_key int IDENTITY
    ,TagId uniqueidentifier NOT NULL /* business key */
    ,TagVersion int NOT NULL         /* business key */
    ,Tag nvarchar(250) NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AssetInspectionScoreTag__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AssetInspectionScoreTag] PRIMARY KEY (AssetInspectionScoreTag_key)
    ,CONSTRAINT [UQ_mart.AssetInspectionScoreTag_TagId_TagVersion] UNIQUE(TagId, TagVersion)
    ,CONSTRAINT [FK_mart.AssetInspectionScoreTag_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.AssetInspection
(
    AssetInspection_key int IDENTITY
    ,InspectionId uniqueidentifier NOT NULL /* business key */
    ,Asset_key int NOT NULL
    ,AssetInspectionStatus_key int NOT NULL
    ,AssetInspectionType_key int NOT NULL
    ,InspectedOn datetime NOT NULL
    ,TotalScore int NOT NULL
    ,TotalPotentialScore int NOT NULL
    ,AverageScore decimal(38,6) NOT NULL
    ,AveragePotentialScore decimal(38,6) NOT NULL
    ,PercentageScore decimal(7,6) NOT NULL
    ,Defects int NOT NULL
    ,Passed int NOT NULL -- -1 = not applicable/unknown, 0 = failed, 1 = passed
    ,GradingSetOption_key int NOT NULL
    ,ExternalIdentifier nvarchar(255) NOT NULL
    ,InspectedByCompany nvarchar(max) NOT NULL -- empty string unless the inspection was externally recorded
    ,InProgressStatusDate datetimeoffset(7) NULL -- allow NULLs
    ,ReadyForReviewStatusDate datetimeoffset(7) NULL -- allow NULLs
    ,CompleteStatusDate datetimeoffset(7) NULL -- allow NULLs
    ,ArchivedStatusDate datetimeoffset(7) NULL -- allow NULLs
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AssetInspection__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AssetInspection] PRIMARY KEY (AssetInspection_key)
    ,CONSTRAINT [UQ_mart.AssetInspection_InspectionId] UNIQUE(InspectionId)
    ,CONSTRAINT [FK_mart.AssetInspection_mart.Asset_Asset_key] FOREIGN KEY(Asset_key) REFERENCES mart.Asset
    ,CONSTRAINT [FK_mart.AssetInspection_mart.AssetInspectionStatus_AssetInspectionStatus_key] FOREIGN KEY(AssetInspectionStatus_key) REFERENCES mart.AssetInspectionStatus
    ,CONSTRAINT [FK_mart.AssetInspection_mart.AssetInspectionType_AssetInspectionType_key] FOREIGN KEY(AssetInspectionType_key) REFERENCES mart.AssetInspectionType
    ,CONSTRAINT [FK_mart.AssetInspection_mart.GradingSetOption_GradingSetOption_key] FOREIGN KEY(GradingSetOption_key) REFERENCES mart.GradingSetOption
    ,CONSTRAINT [FK_mart.AssetInspection_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

-- AssetObservation dimension table (redefined - contact identity via Contact_key, notes moved to mart.AssetObservationNote)
CREATE TABLE mart.AssetObservation
(
    AssetObservation_key int IDENTITY
    ,ObservationId uniqueidentifier NOT NULL /* business key */
    ,Asset_key int NOT NULL
    ,AssetObservationStatus_key int NOT NULL
    ,ObservedOn datetimeoffset(7) NOT NULL
    ,ObservedByContact_key int NULL -- allow NULLs
    ,Deleted bit NOT NULL
    ,ClosedOn datetimeoffset(7) NULL -- allow NULLs
    ,ClosedByContact_key int NULL -- allow NULLs
    ,ClosureNotes nvarchar(max) NOT NULL
    ,IsFinalised bit NOT NULL -- false while attached to an InProgress/ReadyForReview inspection, true once that inspection is Complete
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AssetObservation__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AssetObservation] PRIMARY KEY (AssetObservation_key)
    ,CONSTRAINT [UQ_mart.AssetObservation_ObservationId] UNIQUE(ObservationId)
    ,CONSTRAINT [FK_mart.AssetObservation_mart.Asset_Asset_key] FOREIGN KEY(Asset_key) REFERENCES mart.Asset
    ,CONSTRAINT [FK_mart.AssetObservation_mart.AssetObservationStatus_AssetObservationStatus_key] FOREIGN KEY(AssetObservationStatus_key) REFERENCES mart.AssetObservationStatus
    ,CONSTRAINT [FK_mart.AssetObservation_mart.Contact_ObservedByContact_key] FOREIGN KEY(ObservedByContact_key) REFERENCES mart.Contact
    ,CONSTRAINT [FK_mart.AssetObservation_mart.Contact_ClosedByContact_key] FOREIGN KEY(ClosedByContact_key) REFERENCES mart.Contact
    ,CONSTRAINT [FK_mart.AssetObservation_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

-- AssetObservationNote dimension table (free-text notes, 1:N per observation, replaces the old Details/ActionTaken columns)
CREATE TABLE mart.AssetObservationNote
(
    AssetObservationNote_key int IDENTITY
    ,NoteId uniqueidentifier NOT NULL /* business key */
    ,AssetObservation_key int NOT NULL
    ,Notes nvarchar(max) NOT NULL
    ,CreatedOn datetimeoffset(7) NOT NULL
    ,CreatedByContact_key int NULL -- allow NULLs
    ,EditedOn datetimeoffset(7) NULL -- allow NULLs
    ,Deleted bit NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AssetObservationNote__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AssetObservationNote] PRIMARY KEY (AssetObservationNote_key)
    ,CONSTRAINT [UQ_mart.AssetObservationNote_NoteId] UNIQUE(NoteId)
    ,CONSTRAINT [FK_mart.AssetObservationNote_mart.AssetObservation_AssetObservation_key] FOREIGN KEY(AssetObservation_key) REFERENCES mart.AssetObservation
    ,CONSTRAINT [FK_mart.AssetObservationNote_mart.Contact_CreatedByContact_key] FOREIGN KEY(CreatedByContact_key) REFERENCES mart.Contact
    ,CONSTRAINT [FK_mart.AssetObservationNote_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.AssetInspectionInspectedByFact
(
    AssetInspection_key int NOT NULL
    ,Contact_key int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AssetInspectionInspectedByFact__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AssetInspectionInspectedByFact] PRIMARY KEY (AssetInspection_key, Contact_key)
    ,CONSTRAINT [FK_mart.AssetInspectionInspectedByFact_mart.AssetInspection_AssetInspection_key] FOREIGN KEY(AssetInspection_key) REFERENCES mart.AssetInspection
    ,CONSTRAINT [FK_mart.AssetInspectionInspectedByFact_mart.Contact_Contact_key] FOREIGN KEY(Contact_key) REFERENCES mart.Contact
    ,CONSTRAINT [FK_mart.AssetInspectionInspectedByFact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.AssetInspectionNumericAnswerFact
(
    AssetInspection_key int NOT NULL
    ,AssetInspectionNumericQuestion_key int NOT NULL
    ,Answer decimal(35,6) NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AssetInspectionNumericAnswerFact__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AssetInspectionNumericAnswerFact] PRIMARY KEY (AssetInspection_key, AssetInspectionNumericQuestion_key)
    ,CONSTRAINT [FK_mart.AssetInspectionNumericAnswerFact_mart.AssetInspection_AssetInspection_key] FOREIGN KEY(AssetInspection_key) REFERENCES mart.AssetInspection
    ,CONSTRAINT [FK_mart.AssetInspectionNumericAnswerFact_mart.AssetInspectionNumericQuestion_AssetInspectionNumericQuestion_key] FOREIGN KEY(AssetInspectionNumericQuestion_key) REFERENCES mart.AssetInspectionNumericQuestion
    ,CONSTRAINT [FK_mart.AssetInspectionNumericAnswerFact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.AssetInspectionDateTimeAnswerFact
(
    AssetInspection_key int NOT NULL
    ,AssetInspectionDateTimeQuestion_key int NOT NULL
    ,AnswerDateTime smalldatetime NULL -- allow null
    ,AnswerDate date NULL -- allow null
    ,AnswerTime time(0) NULL -- allow null
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AssetInspectionDateTimeAnswerFact__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AssetInspectionDateTimeAnswerFact] PRIMARY KEY (AssetInspection_key, AssetInspectionDateTimeQuestion_key)
    ,CONSTRAINT [FK_mart.AssetInspectionDateTimeAnswerFact_mart.AssetInspection_AssetInspection_key] FOREIGN KEY(AssetInspection_key) REFERENCES mart.AssetInspection
    ,CONSTRAINT [FK_mart.AssetInspectionDateTimeAnswerFact_mart.AssetInspectionDateTimeQuestion_AssetInspectionDateTimeQuestion_key] FOREIGN KEY(AssetInspectionDateTimeQuestion_key) REFERENCES mart.AssetInspectionDateTimeQuestion
    ,CONSTRAINT [FK_mart.AssetInspectionDateTimeAnswerFact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.AssetInspectionChecklistAnswerFact
(
    AssetInspection_key int NOT NULL
    ,AssetInspectionChecklistOption_key int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AssetInspectionChecklistAnswerFact__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AssetInspectionChecklistAnswerFact] PRIMARY KEY (AssetInspection_key, AssetInspectionChecklistOption_key)
    ,CONSTRAINT [FK_mart.AssetInspectionChecklistAnswerFact_mart.AssetInspection_AssetInspection_key] FOREIGN KEY(AssetInspection_key) REFERENCES mart.AssetInspection
    ,CONSTRAINT [FK_mart.AssetInspectionChecklistAnswerFact_mart.AssetInspectionChecklistOption_AssetInspectionChecklistOption_key] FOREIGN KEY(AssetInspectionChecklistOption_key) REFERENCES mart.AssetInspectionChecklistOption
    ,CONSTRAINT [FK_mart.AssetInspectionChecklistAnswerFact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.AssetInspectionBranchOptionFact
(
    AssetInspection_key int NOT NULL
    ,AssetInspectionBranchOption_key int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AssetInspectionBranchOptionFact__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AssetInspectionBranchOptionFact] PRIMARY KEY (AssetInspection_key, AssetInspectionBranchOption_key)
    ,CONSTRAINT [FK_mart.AssetInspectionBranchOptionFact_mart.AssetInspection_AssetInspection_key] FOREIGN KEY(AssetInspection_key) REFERENCES mart.AssetInspection
    ,CONSTRAINT [FK_mart.AssetInspectionBranchOptionFact_mart.AssetInspectionBranchOption_AssetInspectionBranchOption_key] FOREIGN KEY(AssetInspectionBranchOption_key) REFERENCES mart.AssetInspectionBranchOption
    ,CONSTRAINT [FK_mart.AssetInspectionBranchOptionFact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.AssetInspectionScoredResponseFact
(
    AssetInspection_key int NOT NULL
    ,AssetInspectionScoredResponse_key int NOT NULL
    ,TotalScore int NOT NULL
    ,TotalPotentialScore int NOT NULL
    ,PercentageScore decimal(7,6) NOT NULL
    ,Defect bit NOT NULL
    ,GradingSetOption_key int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AssetInspectionScoredResponseFact__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AssetInspectionScoredResponseFact] PRIMARY KEY (AssetInspection_key, AssetInspectionScoredResponse_key)
    ,CONSTRAINT [FK_mart.AssetInspectionScoredResponseFact_mart.AssetInspection_AssetInspection_key] FOREIGN KEY(AssetInspection_key) REFERENCES mart.AssetInspection
    ,CONSTRAINT [FK_mart.AssetInspectionScoredResponseFact_mart.AssetInspectionScoredResponse_AssetInspectionScoredResponse_key] FOREIGN KEY(AssetInspectionScoredResponse_key) REFERENCES mart.AssetInspectionScoredResponse
    ,CONSTRAINT [FK_mart.AssetInspectionScoredResponseFact_mart.GradingSetOption_GradingSetOption_key] FOREIGN KEY(GradingSetOption_key) REFERENCES mart.GradingSetOption
    ,CONSTRAINT [FK_mart.AssetInspectionScoredResponseFact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.AssetInspectionScoreSectionFact
(
    AssetInspection_key int NOT NULL
    ,AssetInspectionScoreSection_key int NOT NULL
    ,TotalScore int NOT NULL
    ,TotalPotentialScore int NOT NULL
    ,AverageScore decimal(38,6) NOT NULL
    ,AveragePotentialScore decimal(38,6) NOT NULL
    ,PercentageScore decimal(7,6) NOT NULL
    ,Defects int NOT NULL
    ,Passed int NOT NULL -- -1 = not applicable/unknown, 0 = failed, 1 = passed
    ,GradingSetOption_key int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AssetInspectionScoreSectionFact__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AssetInspectionScoreSectionFact] PRIMARY KEY (AssetInspection_key, AssetInspectionScoreSection_key)
    ,CONSTRAINT [FK_mart.AssetInspectionScoreSectionFact_mart.AssetInspection_AssetInspection_key] FOREIGN KEY(AssetInspection_key) REFERENCES mart.AssetInspection
    ,CONSTRAINT [FK_mart.AssetInspectionScoreSectionFact_mart.AssetInspectionScoreSection_AssetInspectionScoreSection_key] FOREIGN KEY(AssetInspectionScoreSection_key) REFERENCES mart.AssetInspectionScoreSection
    ,CONSTRAINT [FK_mart.AssetInspectionScoreSectionFact_mart.GradingSetOption_GradingSetOption_key] FOREIGN KEY(GradingSetOption_key) REFERENCES mart.GradingSetOption
    ,CONSTRAINT [FK_mart.AssetInspectionScoreSectionFact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.AssetInspectionScoreTagFact
(
    AssetInspection_key int NOT NULL
    ,AssetInspectionScoreTag_key int NOT NULL
    ,TotalScore int NOT NULL
    ,TotalPotentialScore int NOT NULL
    ,AverageScore decimal(38,6) NOT NULL
    ,AveragePotentialScore decimal(38,6) NOT NULL
    ,PercentageScore decimal(7,6) NOT NULL
    ,Defects int NOT NULL
    ,GradingSetOption_key int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AssetInspectionScoreTagFact__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AssetInspectionScoreTagFact] PRIMARY KEY (AssetInspection_key, AssetInspectionScoreTag_key)
    ,CONSTRAINT [FK_mart.AssetInspectionScoreTagFact_mart.AssetInspection_AssetInspection_key] FOREIGN KEY(AssetInspection_key) REFERENCES mart.AssetInspection
    ,CONSTRAINT [FK_mart.AssetInspectionScoreTagFact_mart.AssetInspectionScoreTag_AssetInspectionScoreTag_key] FOREIGN KEY(AssetInspectionScoreTag_key) REFERENCES mart.AssetInspectionScoreTag
    ,CONSTRAINT [FK_mart.AssetInspectionScoreTagFact_mart.GradingSetOption_GradingSetOption_key] FOREIGN KEY(GradingSetOption_key) REFERENCES mart.GradingSetOption
    ,CONSTRAINT [FK_mart.AssetInspectionScoreTagFact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.AssetInspectionObservationFact
(
    AssetInspectionObservationFact_key int IDENTITY
    ,AssetInspection_key int NOT NULL
    ,AssetObservation_key int NOT NULL
    ,WorkflowComponentId uniqueidentifier NULL -- allow NULLs (observation not linked to a specific workflow component)
    ,InspectionWorkflowComponentType_key int NULL -- allow NULLs (null whenever WorkflowComponentId is null)
    ,WorkflowComponentDescription nvarchar(max) NOT NULL -- empty string when WorkflowComponentId is null
    ,[New] bit NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AssetInspectionObservationFact__created] DEFAULT SYSUTCDATETIME()
    ,CONSTRAINT [PK_mart.AssetInspectionObservationFact] PRIMARY KEY (AssetInspectionObservationFact_key)
    ,CONSTRAINT [UQ_mart.AssetInspectionObservationFact_AssetInspection_key_AssetObservation_key] UNIQUE(AssetInspection_key, AssetObservation_key)
    ,CONSTRAINT [FK_mart.AssetInspectionObservationFact_mart.AssetInspection_AssetInspection_key] FOREIGN KEY(AssetInspection_key) REFERENCES mart.AssetInspection
    ,CONSTRAINT [FK_mart.AssetInspectionObservationFact_mart.AssetObservation_AssetObservation_key] FOREIGN KEY(AssetObservation_key) REFERENCES mart.AssetObservation
    ,CONSTRAINT [FK_mart.AssetInspectionObservationFact_mart.InspectionWorkflowComponentType_InspectionWorkflowComponentType_key] FOREIGN KEY(InspectionWorkflowComponentType_key) REFERENCES mart.InspectionWorkflowComponentType
    ,CONSTRAINT [FK_mart.AssetInspectionObservationFact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

GO
