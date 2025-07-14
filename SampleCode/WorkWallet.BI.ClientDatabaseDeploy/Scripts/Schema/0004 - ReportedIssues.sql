CREATE TABLE mart.ReportedIssueStatus
(
    ReportedIssueStatus_key int IDENTITY
    ,ReportedIssueStatusCode int NOT NULL /* business key */
    ,ReportedIssueStatus nvarchar(50) NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.ReportedIssueStatus__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.ReportedIssueStatus] PRIMARY KEY (ReportedIssueStatus_key)
    ,CONSTRAINT [UQ_mart.ReportedIssueStatus_Code] UNIQUE(ReportedIssueStatusCode)
);

INSERT INTO mart.ReportedIssueStatus (ReportedIssueStatusCode, ReportedIssueStatus) VALUES (2, N'Reported');
INSERT INTO mart.ReportedIssueStatus (ReportedIssueStatusCode, ReportedIssueStatus) VALUES (3, N'Under Investigation');
INSERT INTO mart.ReportedIssueStatus (ReportedIssueStatusCode, ReportedIssueStatus) VALUES (4, N'Closed');
INSERT INTO mart.ReportedIssueStatus (ReportedIssueStatusCode, ReportedIssueStatus) VALUES (6, N'Closed (Archived)');
INSERT INTO mart.ReportedIssueStatus (ReportedIssueStatusCode, ReportedIssueStatus) VALUES (8, N'Deleted');

CREATE TABLE mart.ReportedIssueSeverity
(
    ReportedIssueSeverity_key int IDENTITY
    ,ReportedIssueSeverityCode int NOT NULL /* business key */
    ,ReportedIssueSeverity nvarchar(50) NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.ReportedIssueSeverity__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.ReportedIssueSeverity] PRIMARY KEY (ReportedIssueSeverity_key)
    ,CONSTRAINT [UQ_mart.ReportedIssueSeverity_Code] UNIQUE(ReportedIssueSeverityCode)
);

INSERT INTO mart.ReportedIssueSeverity (ReportedIssueSeverityCode, ReportedIssueSeverity) VALUES (-1, N'');
INSERT INTO mart.ReportedIssueSeverity (ReportedIssueSeverityCode, ReportedIssueSeverity) VALUES (1, N'Low');
INSERT INTO mart.ReportedIssueSeverity (ReportedIssueSeverityCode, ReportedIssueSeverity) VALUES (2, N'Medium');
INSERT INTO mart.ReportedIssueSeverity (ReportedIssueSeverityCode, ReportedIssueSeverity) VALUES (4, N'High');
INSERT INTO mart.ReportedIssueSeverity (ReportedIssueSeverityCode, ReportedIssueSeverity) VALUES (8, N'Critical');

CREATE TABLE mart.ReportedIssueBodyPartEnum
(
    ReportedIssueBodyPartEnum_key int IDENTITY
    ,MaskIndex tinyint NOT NULL /* business key */
    ,[Group] nvarchar(50) NOT NULL
    ,BodyPart nvarchar(50) NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.ReportedIssueBodyPartEnum__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.ReportedIssueBodyPartEnum] PRIMARY KEY (ReportedIssueBodyPartEnum_key)
    ,CONSTRAINT [UQ_mart.ReportedIssueBodyPartEnum_MaskIndex] UNIQUE(MaskIndex)
    ,CONSTRAINT [UQ_mart.ReportedIssueBodyPartEnum_BodyPart] UNIQUE(BodyPart)
);

INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (0, N'Head', N'Head');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (1, N'Head', N'Eye - Left');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (2, N'Head', N'Ear - Left');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (3, N'Head', N'Face');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (4, N'Head', N'Teeth');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (5, N'Upper Body', N'Neck');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (6, N'Upper Body', N'Shoulder - Left');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (7, N'Upper Body', N'Arm - Left');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (8, N'Upper Body', N'Hand / Wrist - Left');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (9, N'Upper Body', N'Finger(s) - Left');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (10, N'Upper Body', N'Chest / Lungs');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (11, N'Upper Body', N'Stomach');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (12, N'Lower Body', N'Hip - Left');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (13, N'Lower Body', N'Leg - Left');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (14, N'Lower Body', N'Knee - Left');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (15, N'Lower Body', N'Ankle - Left');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (16, N'Lower Body', N'Foot - Left');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (17, N'Lower Body', N'Toe(s) - Left');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (18, N'General', N'Whole Body');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (19, N'Head', N'Nose');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (20, N'Head', N'Mouth');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (21, N'Upper Body', N'Back');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (22, N'Lower Body', N'Shin - Left');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (23, N'Upper Body', N'Elbow - Left');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (24, N'Head', N'Eye - Right');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (25, N'Head', N'Ear - Right');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (26, N'Upper Body', N'Shoulder - Right');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (27, N'Upper Body', N'Arm - Right');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (28, N'Upper Body', N'Elbow - Right');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (29, N'Upper Body', N'Hand / Wrist - Right');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (30, N'Lower Body', N'Hip - Right');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (31, N'Lower Body', N'Leg - Right');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (32, N'Lower Body', N'Knee - Right');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (33, N'Lower Body', N'Shin - Right');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (34, N'Lower Body', N'Ankle - Right');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (35, N'Lower Body', N'Foot - Right');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (36, N'Upper Body', N'Finger(s) - Right');
INSERT INTO mart.ReportedIssueBodyPartEnum (MaskIndex, [Group], BodyPart) VALUES (37, N'Lower Body', N'Toe(s) - Right');

CREATE TABLE mart.ReportedIssueRootCauseAnalysisType
(   ReportedIssueRootCauseAnalysisType_key int IDENTITY
    ,ReportedIssueRootCauseAnalysisTypeCode int NOT NULL /* business key */
    ,ReportedIssueRootCauseAnalysisType nvarchar(50) NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.ReportedIssueRootCauseAnalysisType__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.ReportedIssueRootCauseAnalysisType] PRIMARY KEY (ReportedIssueRootCauseAnalysisType_key)
    ,CONSTRAINT [UQ_mart.ReportedIssueRootCauseAnalysisType_Code] UNIQUE(ReportedIssueRootCauseAnalysisTypeCode)
);

INSERT INTO mart.ReportedIssueRootCauseAnalysisType (ReportedIssueRootCauseAnalysisTypeCode, ReportedIssueRootCauseAnalysisType) VALUES (1, N'Root Cause');
INSERT INTO mart.ReportedIssueRootCauseAnalysisType (ReportedIssueRootCauseAnalysisTypeCode, ReportedIssueRootCauseAnalysisType) VALUES (2, N'Immediate Cause');

CREATE TABLE mart.ReportedIssueCategory
(
    ReportedIssueCategory_key int IDENTITY
    ,SubcategoryId uniqueidentifier NOT NULL /* business key */
    ,CategoryVersion int NOT NULL /* business key */
    ,CategoryName nvarchar(50) NOT NULL
    ,CategoryDescription nvarchar(200) NOT NULL
    ,SubcategoryName nvarchar(200) NOT NULL
    ,SubcategoryDescription nvarchar(200) NOT NULL
    ,SubcategoryOrder int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.ReportedIssueCategory__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.ReportedIssueCategory] PRIMARY KEY (ReportedIssueCategory_key)
    ,CONSTRAINT [UQ_mart.ReportedIssueCategory_SubcategoryId_CategoryVersion] UNIQUE(SubcategoryId, CategoryVersion)
    ,CONSTRAINT [FK_mart.ReportedIssueCategory_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.ReportedIssue
(
    ReportedIssue_key int IDENTITY
    ,ReportedIssueId uniqueidentifier NOT NULL /* business key */
    ,ReportedIssueReference nvarchar(50) NOT NULL
    ,OccurredOn datetime2(7) NOT NULL
    ,ReportedOn datetime2(7) NOT NULL
    ,ReportedBy nvarchar(max) NOT NULL
    ,ReportedByCompany nvarchar(max) NOT NULL
    ,ReportedIssueStatus_key int NOT NULL
    ,ReportedIssueCategory_key int NOT NULL
    ,Location_key int NOT NULL
    ,ReportedIssueOverview nvarchar(max) NOT NULL
    ,ReportedIssueSeverity_key int NOT NULL
    ,CloseDate datetimeoffset(7) NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.ReportedIssue__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.ReportedIssue] PRIMARY KEY (ReportedIssue_key)
    ,CONSTRAINT [UQ_mart.ReportedIssue_ReportedIssueId] UNIQUE(ReportedIssueId)
    ,CONSTRAINT [FK_mart.ReportedIssue_mart.ReportedIssueStatus_ReportedIssueStatus_key] FOREIGN KEY(ReportedIssueStatus_key) REFERENCES mart.ReportedIssueStatus
    ,CONSTRAINT [FK_mart.ReportedIssue_mart.ReportedIssueCategory_ReportedIssueCategory_key] FOREIGN KEY(ReportedIssueCategory_key) REFERENCES mart.ReportedIssueCategory
    ,CONSTRAINT [FK_mart.ReportedIssue_mart.ReportedIssueSeverity_ReportedIssueSeverity_key] FOREIGN KEY(ReportedIssueSeverity_key) REFERENCES mart.ReportedIssueSeverity
    ,CONSTRAINT [FK_mart.ReportedIssue_mart.Location_Location_key] FOREIGN KEY(Location_key) REFERENCES mart.[Location]
    ,CONSTRAINT [FK_mart.ReportedIssue_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.ReportedIssueRootCauseAnalysisFact
(
    ReportedIssue_key int NOT NULL
    ,ReportedIssueRootCauseAnalysisType_key int NOT NULL
    ,RootCauseAnalysis nvarchar(100) NOT NULL
    ,RootCauseAnalysisDescription nvarchar(400) NOT NULL
    ,RootCauseAnalysisOrder int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.ReportedIssueRootCauseAnalysis__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    /* no primary key specified as we can get duplicate data */
    ,CONSTRAINT [FK_mart.ReportedIssueRootCauseAnalysisFact_mart.ReportedIssue_ReportedIssue_key] FOREIGN KEY(ReportedIssue_key) REFERENCES mart.ReportedIssue
    ,CONSTRAINT [FK_mart.ReportedIssueRootCauseAnalysisFact_mart.ReportedIssueRootCauseAnalysisType_ReportedIssueRootCauseAnalysisType_key] FOREIGN KEY(ReportedIssueRootCauseAnalysisType_key) REFERENCES mart.ReportedIssueRootCauseAnalysisType
    ,CONSTRAINT [FK_mart.ReportedIssueRootCauseAnalysisFact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.ReportedIssueBranchOption
(
    ReportedIssueBranchOption_key int IDENTITY
    ,Branch nvarchar(100) NOT NULL
    ,[Option] nvarchar(250) NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.ReportedIssueBranchOption__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.ReportedIssueBranchOption] PRIMARY KEY (ReportedIssueBranchOption_key)
    ,CONSTRAINT [UQ_mart.ReportedIssueBranchOption_Wallet_key_Branch_Option] UNIQUE(Wallet_key, Branch, [Option])
    ,CONSTRAINT [FK_mart.ReportedIssueBranchOption_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.ReportedIssueBranchOptionFact
(
    ReportedIssue_key int NOT NULL
    ,ReportedIssueBranchOption_key int NOT NULL
    ,Investigation bit NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.ReportedIssueBranchOptionFact__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.ReportedIssueBranchOptionFact] PRIMARY KEY (ReportedIssue_key, ReportedIssueBranchOption_key, Investigation)
    ,CONSTRAINT [FK_mart.ReportedIssueBranchOptionFact_mart.ReportedIssue_ReportedIssue_key] FOREIGN KEY(ReportedIssue_key) REFERENCES mart.ReportedIssue
    ,CONSTRAINT [FK_mart.ReportedIssueBranchOptionFact_mart.ReportedIssueBranchOption_ReportedIssueBranchOption_key] FOREIGN KEY(ReportedIssueBranchOption_key) REFERENCES mart.ReportedIssueBranchOption
    ,CONSTRAINT [FK_mart.ReportedIssueBranchOptionFact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.ReportedIssueBodyPart
(
    ReportedIssueBodyPart_key int IDENTITY
    ,ReportedIssueBodyPartEnum_key int NOT NULL
    ,Question nvarchar(100) NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.ReportedIssueBodyPart__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.ReportedIssueBodyPart] PRIMARY KEY (ReportedIssueBodyPart_key)
    ,CONSTRAINT [UQ_mart.ReportedIssueBodyPart_Wallet_key_ReportedIssueBodyPartEnum_key_Question] UNIQUE(Wallet_key, ReportedIssueBodyPartEnum_key, Question)
    ,CONSTRAINT [FK_mart.ReportedIssueBodyPart_mart.ReportedIssueBodyPartEnum_ReportedIssueBodyPartEnum_key] FOREIGN KEY(ReportedIssueBodyPartEnum_key) REFERENCES mart.ReportedIssueBodyPartEnum
    ,CONSTRAINT [FK_mart.ReportedIssueBodyPart_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.ReportedIssueBodyPartFact
(
    ReportedIssue_key int NOT NULL
    ,ReportedIssueBodyPart_key int NOT NULL
    ,Investigation bit NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.ReportedIssueBodyPartFact__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.ReportedIssueBodyPartFact] PRIMARY KEY (ReportedIssue_key, ReportedIssueBodyPart_key, Investigation)
    ,CONSTRAINT [FK_mart.ReportedIssueBodyPartFact_mart.ReportedIssue_ReportedIssue_key] FOREIGN KEY(ReportedIssue_key) REFERENCES mart.ReportedIssue
    ,CONSTRAINT [FK_mart.ReportedIssueBodyPartFact_mart.ReportedIssueBodyPart_ReportedIssueBodyPart_key] FOREIGN KEY(ReportedIssueBodyPart_key) REFERENCES mart.ReportedIssueBodyPart
    ,CONSTRAINT [FK_mart.ReportedIssueBodyPartFact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.ReportedIssueOptionSelect
(
    ReportedIssueOptionSelect_key int IDENTITY
    ,Question nvarchar(100) NOT NULL
    ,[Option] nvarchar(250) NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.ReportedIssueOptionSelect__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.ReportedIssueOptionSelect] PRIMARY KEY (ReportedIssueOptionSelect_key)
    ,CONSTRAINT [UQ_mart.ReportedIssueOptionSelect_Wallet_key_Question_Option] UNIQUE(Wallet_key, Question, [Option])
    ,CONSTRAINT [FK_mart.ReportedIssueOptionSelect_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.ReportedIssueOptionSelectFact
(
    ReportedIssue_key int NOT NULL
    ,ReportedIssueOptionSelect_key int NOT NULL
    ,Investigation bit NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.ReportedIssueOptionSelectFact__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.ReportedIssueOptionSelectFact] PRIMARY KEY (ReportedIssue_key, ReportedIssueOptionSelect_key, Investigation)
    ,CONSTRAINT [FK_mart.ReportedIssueOptionSelectFact_mart.ReportedIssue_ReportedIssue_key] FOREIGN KEY(ReportedIssue_key) REFERENCES mart.ReportedIssue
    ,CONSTRAINT [FK_mart.ReportedIssueOptionSelectFact_mart.ReportedIssueOptionSelect_ReportedIssueOptionSelect_key] FOREIGN KEY(ReportedIssueOptionSelect_key) REFERENCES mart.ReportedIssueOptionSelect
    ,CONSTRAINT [FK_mart.ReportedIssueOptionSelectFact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.ReportedIssuePerson
(
    ReportedIssuePerson_key int IDENTITY
    ,Question nvarchar(100) NOT NULL
    ,[Option] nvarchar(50) NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.ReportedIssuePerson__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.ReportedIssuePerson] PRIMARY KEY (ReportedIssuePerson_key)
    ,CONSTRAINT [UQ_mart.ReportedIssuePerson_Wallet_key_Question_Option] UNIQUE(Wallet_key, Question, [Option])
    ,CONSTRAINT [FK_mart.ReportedIssuePerson_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.ReportedIssuePersonFact
(
    ReportedIssue_key int NOT NULL
    ,ReportedIssuePerson_key int NOT NULL
    ,Investigation bit NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.ReportedIssuePersonFact__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.ReportedIssuePersonFact] PRIMARY KEY (ReportedIssue_key, ReportedIssuePerson_key, Investigation)
    ,CONSTRAINT [FK_mart.ReportedIssuePersonFact_mart.ReportedIssue_ReportedIssue_key] FOREIGN KEY(ReportedIssue_key) REFERENCES mart.ReportedIssue
    ,CONSTRAINT [FK_mart.ReportedIssuePersonFact_mart.ReportedIssuePerson_ReportedIssuePerson_key] FOREIGN KEY(ReportedIssuePerson_key) REFERENCES mart.ReportedIssuePerson
    ,CONSTRAINT [FK_mart.ReportedIssuePersonFact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

GO
