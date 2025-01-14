CREATE TABLE mart.AuditStatus
(
    AuditStatus_key int IDENTITY
    ,AuditStatusCode int NOT NULL /* business key */
    ,AuditStatus nvarchar(50) NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AuditStatus__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AuditStatus] PRIMARY KEY (AuditStatus_key)
    ,CONSTRAINT [UQ_mart.AuditStatus_AuditStatusCode] UNIQUE (AuditStatusCode)
);

INSERT INTO mart.AuditStatus (AuditStatusCode, AuditStatus) VALUES (0, N'Planned');
INSERT INTO mart.AuditStatus (AuditStatusCode, AuditStatus) VALUES (1, N'Report In Progress');
INSERT INTO mart.AuditStatus (AuditStatusCode, AuditStatus) VALUES (2, N'Ready For Review');
INSERT INTO mart.AuditStatus (AuditStatusCode, AuditStatus) VALUES (3, N'Complete');
INSERT INTO mart.AuditStatus (AuditStatusCode, AuditStatus) VALUES (4, N'Cancelled');
INSERT INTO mart.AuditStatus (AuditStatusCode, AuditStatus) VALUES (5, N'Deleted');
INSERT INTO mart.AuditStatus (AuditStatusCode, AuditStatus) VALUES (6, N'Closed');
INSERT INTO mart.AuditStatus (AuditStatusCode, AuditStatus) VALUES (7, N'Archived');

CREATE TABLE mart.Unit
(
    Unit_key int IDENTITY
    ,UnitCode int NOT NULL /* business key */
    ,[Group] nvarchar(50) NOT NULL
    ,Unit nvarchar(50) NOT NULL
    ,UnitAcronym nvarchar(10) NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.Unit__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.Unit] PRIMARY KEY (Unit_key)
    ,CONSTRAINT [UQ_mart.Unit_UnitCode] UNIQUE (UnitCode)
);

INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (0,  N'None',          N'',                       N'');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (1,  N'Distance',      N'Inch',                   N'in');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (2,  N'Distance',      N'Foot',                   N'ft');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (3,  N'Distance',      N'Mile',                   N'mi');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (4,  N'Distance',      N'Millimetre',             N'mm');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (5,  N'Distance',      N'Centimetre',             N'cm');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (6,  N'Distance',      N'Metre',                  N'm');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (7,  N'Distance',      N'Kilometre',              N'km');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (8,  N'Volume',        N'Millilitre',             N'ml');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (9,  N'Volume',        N'Litre',                  N'l');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (10, N'Volume',        N'Gallon',                 N'gal');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (11, N'Volume',        N'Cubic Metre',            N'm³');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (12, N'Time',          N'Hour',                   N'hr');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (13, N'Time',          N'Minute',                 N'min');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (14, N'Time',          N'Second',                 N's');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (15, N'Temperature',   N'Fahrenheit',             N'°F');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (16, N'Temperature',   N'Celsius',                N'°C');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (17, N'Temperature',   N'Kelvin',                 N'K');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (18, N'Weight',        N'Ounce',                  N'oz');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (19, N'Weight',        N'Pound',                  N'lb');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (20, N'Weight',        N'Ton',                    N'ton');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (21, N'Weight',        N'Tonne',                  N't');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (22, N'Weight',        N'Gram',                   N'g');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (23, N'Weight',        N'Kilogram',               N'kg');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (24, N'Power',         N'Ampere',                 N'A');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (25, N'Power',         N'Hertz',                  N'Hz');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (26, N'Power',         N'Ohm',                    N'Ω');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (27, N'Power',         N'Volt',                   N'V');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (28, N'Power',         N'Watt',                   N'W');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (29, N'Miscellaneous', N'Bar',                    N'bar');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (30, N'Miscellaneous', N'Candela',                N'cd');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (31, N'Miscellaneous', N'Cycles',                 N'cycles');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (32, N'Miscellaneous', N'Percent',                N'%');
INSERT INTO mart.Unit (UnitCode, [Group], Unit, UnitAcronym) VALUES (33, N'Miscellaneous', N'Pounds Per Square Inch', N'psi');

CREATE TABLE mart.AuditType
(
    AuditType_key int IDENTITY
    ,AuditTypeId uniqueidentifier NOT NULL /* business key */
    ,AuditTypeVersion int NOT NULL         /* business key */
    ,AuditType nvarchar(500) NOT NULL
    ,[Description] nvarchar(2000) NOT NULL
    ,ScoringEnabled bit NOT NULL
    ,DisplayPercentage bit NOT NULL
    ,DisplayTotalScore bit NOT NULL
    ,DisplayAverageScore bit NOT NULL
    ,GradingSet nvarchar(100) NOT NULL
    ,GradingSetIsPercentage bit NOT NULL
    ,GradingSetIsScore bit NOT NULL
    ,ReportingEnabled bit NOT NULL
    ,ReportingAbbreviation nvarchar(4) NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AuditType__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AuditType] PRIMARY KEY (AuditType_key)
    ,CONSTRAINT [UQ_mart.AuditType_AuditTypeId_AuditTypeVersion] UNIQUE(AuditTypeId, AuditTypeVersion)
    ,CONSTRAINT [FK_mart.AuditType_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.AuditGroup
(
    AuditGroup_key int IDENTITY
    ,AuditGroupId uniqueidentifier NOT NULL /* business key */
    ,AuditGroup nvarchar(40) NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AuditGroup__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AuditGroup] PRIMARY KEY (AuditGroup_key)
    ,CONSTRAINT [UQ_mart.AuditGroup_AuditGroupId] UNIQUE(AuditGroupId)
    ,CONSTRAINT [FK_mart.AuditGroup_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.[Audit]
(
    Audit_key int IDENTITY
    ,AuditId uniqueidentifier NOT NULL /* business key */
    ,Reference int NOT NULL
    ,AuditReference nvarchar(50) NOT NULL
    ,AuditGroup_key int NOT NULL
    ,AuditStatus_key int NOT NULL
    ,AuditType_key int NOT NULL
    ,Location_key int NOT NULL
    ,InspectedOn datetime NOT NULL
    ,TotalScore int NOT NULL
    ,TotalPotentialScore int NOT NULL
    ,AverageScore decimal(38,6) NOT NULL
    ,AveragePotentialScore decimal(38,6) NOT NULL
    ,PercentageScore decimal(7,6) NOT NULL
    ,Flags int NOT NULL
    ,GradingSetOption nvarchar(250) NOT NULL
    ,ExternalIdentifier nvarchar(255) NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.Audit__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.Audit] PRIMARY KEY (Audit_key)
    ,CONSTRAINT [UQ_mart.Audit_AuditId] UNIQUE(AuditId)
    ,CONSTRAINT [FK_mart.Audit_mart.AuditGroup_AuditGroup_key] FOREIGN KEY(AuditGroup_key) REFERENCES mart.AuditGroup
    ,CONSTRAINT [FK_mart.Audit_mart.AuditStatus_AuditStatus_key] FOREIGN KEY(AuditStatus_key) REFERENCES mart.AuditStatus
    ,CONSTRAINT [FK_mart.Audit_mart.AuditType_AuditType_key] FOREIGN KEY(AuditType_key) REFERENCES mart.AuditType
    ,CONSTRAINT [FK_mart.Audit_mart.Location_Location_key] FOREIGN KEY(Location_key) REFERENCES mart.[Location]
    ,CONSTRAINT [FK_mart.Audit_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.AuditInspectedByFact
(
    Audit_key int NOT NULL
    ,Contact_key int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AuditInspectedByFact__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AuditInspectedByFact] PRIMARY KEY (Audit_key, Contact_key)
    ,CONSTRAINT [FK_mart.AuditInspectedByFact_mart.Audit_Audit_key] FOREIGN KEY(Audit_key) REFERENCES mart.[Audit]
    ,CONSTRAINT [FK_mart.AuditInspectedByFact_mart.Contact_Contact_key] FOREIGN KEY(Contact_key) REFERENCES mart.Contact
    ,CONSTRAINT [FK_mart.AuditInspectedByFact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.AuditNumericQuestion
(
    AuditNumericQuestion_key int IDENTITY
    ,QuestionId uniqueidentifier NOT NULL  /* business key */
    ,Question nvarchar(500) NOT NULL
    ,Mandatory bit NOT NULL
    ,Scale int NOT NULL
    ,Unit_key int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AuditNumericQuestion__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AuditNumericQuestion] PRIMARY KEY (AuditNumericQuestion_key)
    ,CONSTRAINT [UQ_mart.AuditNumericQuestion_QuestionId] UNIQUE(QuestionId)
    ,CONSTRAINT [FK_mart.AuditNumericQuestion_mart.Unit_Unit_key] FOREIGN KEY(Unit_key) REFERENCES mart.Unit
    ,CONSTRAINT [FK_mart.AuditNumericQuestion_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.AuditNumericAnswerFact
(
    Audit_key int NOT NULL
    ,AuditNumericQuestion_key int NOT NULL
    ,Answer decimal(35,6) NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AuditNumericAnswerFact__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AuditNumericAnswerFact] PRIMARY KEY (Audit_key, AuditNumericQuestion_key)
    ,CONSTRAINT [FK_mart.AuditNumericAnswerFact_mart.AuditNumericQuestion_AuditNumericQuestion_key] FOREIGN KEY(AuditNumericQuestion_key) REFERENCES mart.AuditNumericQuestion
    ,CONSTRAINT [FK_mart.AuditNumericAnswerFact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.AuditDateTimeQuestion
(
    AuditDateTimeQuestion_key int IDENTITY
    ,QuestionId uniqueidentifier NOT NULL  /* business key */
    ,Question nvarchar(500) NOT NULL
    ,Mandatory bit NOT NULL
    ,[Date] bit NOT NULL
    ,[Time] bit NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AuditDateTimeQuestion__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AuditDateTimeQuestion] PRIMARY KEY (AuditDateTimeQuestion_key)
    ,CONSTRAINT [UQ_mart.AuditDateTimeQuestion_QuestionId] UNIQUE(QuestionId)
    ,CONSTRAINT [FK_mart.AuditDateTimeQuestion_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.AuditDateTimeAnswerFact
(
    Audit_key int NOT NULL
    ,AuditDateTimeQuestion_key int NOT NULL
    ,AnswerDateTime smalldatetime NULL -- allow null
    ,AnswerDate date NULL -- allow null
    ,AnswerTime time(0) NULL -- allow null
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AuditDateTimeAnswerFact__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AuditDateTimeAnswerFact] PRIMARY KEY (Audit_key, AuditDateTimeQuestion_key)
    ,CONSTRAINT [FK_mart.AuditDateTimeAnswerFact_mart.AuditDateTimeQuestion_AuditDateTimeQuestion_key] FOREIGN KEY(AuditDateTimeQuestion_key) REFERENCES mart.AuditDateTimeQuestion
    ,CONSTRAINT [FK_mart.AuditDateTimeAnswerFact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.AuditChecklistOption
(
    AuditChecklistOption_key int IDENTITY
    ,ChecklistId uniqueidentifier NOT NULL  /* business key */
    ,OptionId uniqueidentifier NOT NULL     /* business key */
    ,Question nvarchar(100) NOT NULL
    ,[Value] nvarchar(250) NOT NULL
    ,Mandatory bit NOT NULL
    ,[Order] int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AuditChecklistOption__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AuditChecklistOption] PRIMARY KEY (AuditChecklistOption_key)
    ,CONSTRAINT [UQ_mart.AuditChecklistOption_ChecklistId_OptionId] UNIQUE(ChecklistId, OptionId)
    ,CONSTRAINT [FK_mart.AuditChecklistOption_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.AuditChecklistAnswerFact
(
    Audit_key int NOT NULL
    ,AuditChecklistOption_key int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AuditChecklistAnswerFact__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AuditChecklistAnswerFact] PRIMARY KEY (Audit_key, AuditChecklistOption_key)
    ,CONSTRAINT [FK_mart.AuditChecklistAnswerFact_mart.AuditChecklistOption_AuditChecklistOption_key] FOREIGN KEY(AuditChecklistOption_key) REFERENCES mart.AuditChecklistOption
    ,CONSTRAINT [FK_mart.AuditChecklistAnswerFact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.AuditBranchOption
(
    AuditBranchOption_key int IDENTITY
    ,BranchId uniqueidentifier NOT NULL  /* business key */
    ,OptionId uniqueidentifier NOT NULL /* business key */
    ,Branch nvarchar(100) NOT NULL
    ,[Value] nvarchar(250) NOT NULL
    ,[Order] int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AuditBranchOption__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AuditBranchOption] PRIMARY KEY (AuditBranchOption_key)
    ,CONSTRAINT [UQ_mart.AuditBranchOption_BranchId_OptionId] UNIQUE(BranchId, OptionId)
    ,CONSTRAINT [FK_mart.AuditBranchOption_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.AuditBranchOptionFact
(
    Audit_key int NOT NULL
    ,AuditBranchOption_key int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AuditBranchOptionFact__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AuditBranchOptionFact] PRIMARY KEY (Audit_key, AuditBranchOption_key)
    ,CONSTRAINT [FK_mart.AuditBranchOptionFact_mart.AuditBranchOption_AuditBranchOption_key] FOREIGN KEY(AuditBranchOption_key) REFERENCES mart.AuditBranchOption
    ,CONSTRAINT [FK_mart.AuditBranchOptionFact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.AuditGradingSetOption
(
    AuditGradingSetOption_key int IDENTITY
    ,GradingSetOptionId uniqueidentifier NOT NULL /* business key */
    ,GradingSet nvarchar(100) NOT NULL
    ,GradingSetOption nvarchar(250) NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AuditGradingSetOption__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AuditGradingSetOption] PRIMARY KEY (AuditGradingSetOption_key)
    ,CONSTRAINT [UQ_mart.AuditGradingSetOption_GradingSet_GradingSetOptionId] UNIQUE(GradingSetOptionId)
    ,CONSTRAINT [FK_mart.AuditGradingSetOption_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.AuditScoredResponse
(
    AuditScoredResponse_key int IDENTITY
    ,BranchId uniqueidentifier NOT NULL  /* business key */
    ,OptionId uniqueidentifier NOT NULL  /* business key */
    ,Branch nvarchar(100) NOT NULL
    ,[Value] nvarchar(250) NOT NULL
    ,[Order] int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AuditScoredResponse__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AuditScoredResponse] PRIMARY KEY (AuditScoredResponse_key)
    ,CONSTRAINT [UQ_mart.AuditScoredResponse_BranchId_OptionId] UNIQUE(BranchId, OptionId)
    ,CONSTRAINT [FK_mart.AuditScoredResponse_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.AuditScoredResponseFact
(
    Audit_key int NOT NULL
    ,AuditScoredResponse_key int NOT NULL
    ,TotalScore int NOT NULL
    ,TotalPotentialScore int NOT NULL
    ,PercentageScore decimal(7,6) NOT NULL
    ,Flag bit NOT NULL
    ,AuditGradingSet_key int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AuditScoredResponseFact__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AuditScoredResponseFact] PRIMARY KEY (Audit_key, AuditScoredResponse_key)
    ,CONSTRAINT [FK_mart.AuditScoredResponseFact_mart.AuditScoredResponse_AuditScoredResponse_key] FOREIGN KEY(AuditScoredResponse_key) REFERENCES mart.AuditScoredResponse
    ,CONSTRAINT [FK_mart.AuditScoredResponseFact_mart.AuditGradingSetOption_AuditGradingSet_key] FOREIGN KEY(AuditGradingSet_key) REFERENCES mart.AuditGradingSetOption
    ,CONSTRAINT [FK_mart.AuditScoredResponseFact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.AuditScoreSection
(
    AuditScoreSection_key int IDENTITY
    ,AuditType_key int NOT NULL          /* business key */
    ,SectionId uniqueidentifier NOT NULL /* business key */
    ,Section nvarchar(100) NOT NULL
    ,DisplayScore bit NOT NULL
    ,[Order] int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AuditScoreSection__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AuditScoreSection] PRIMARY KEY (AuditScoreSection_key)
    ,CONSTRAINT [UQ_mart.AuditScoreSection_AuditType_key_SectionId] UNIQUE(AuditType_key, SectionId)
    ,CONSTRAINT [FK_mart.AuditScoreSection_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.AuditScoreSectionFact
(
    Audit_key int NOT NULL
    ,AuditScoreSection_key int NOT NULL
    ,TotalScore int NOT NULL
    ,TotalPotentialScore int NOT NULL
    ,AverageScore decimal(38,6) NOT NULL
    ,AveragePotentialScore decimal(38,6) NOT NULL
    ,PercentageScore decimal(7,6) NOT NULL
    ,Flags int NOT NULL
    ,AuditGradingSet_key int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AuditScoreSectionFact__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AuditScoreSectionFact] PRIMARY KEY (Audit_key, AuditScoreSection_key)
    ,CONSTRAINT [FK_mart.AuditScoreSectionFact_mart.AuditScoreSection_AuditScoreSection_key] FOREIGN KEY(AuditScoreSection_key) REFERENCES mart.AuditScoreSection
    ,CONSTRAINT [FK_mart.AuditScoreSectionFact_mart.AuditGradingSetOption_AuditGradingSet_key] FOREIGN KEY(AuditGradingSet_key) REFERENCES mart.AuditGradingSetOption
    ,CONSTRAINT [FK_mart.AuditScoreSectionFact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.AuditScoreTag
(
    AuditScoreTag_key int IDENTITY
    ,TagId uniqueidentifier NOT NULL /* business key */
    ,TagVersion int NOT NULL         /* business key */
    ,Tag nvarchar(250) NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AuditScoreTag__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AuditScoreTag] PRIMARY KEY (AuditScoreTag_key)
    ,CONSTRAINT [UQ_mart.AuditScoreTag_TagId_TagVersion] UNIQUE(TagId, TagVersion)
    ,CONSTRAINT [FK_mart.AuditScoreTag_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.AuditScoreTagFact
(
    Audit_key int NOT NULL
    ,AuditScoreTag_key int NOT NULL
    ,TotalScore int NOT NULL
    ,TotalPotentialScore int NOT NULL
    ,AverageScore decimal(38,6) NOT NULL
    ,AveragePotentialScore decimal(38,6) NOT NULL
    ,PercentageScore decimal(7,6) NOT NULL
    ,Flags int NOT NULL
    ,AuditGradingSet_key int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.AuditScoreTagFact__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.AuditScoreTagFact] PRIMARY KEY (Audit_key, AuditScoreTag_key)
    ,CONSTRAINT [FK_mart.AuditScoreTagFact_mart.AuditScoreTag_AuditScoreTag_key] FOREIGN KEY(AuditScoreTag_key) REFERENCES mart.AuditScoreTag
    ,CONSTRAINT [FK_mart.AuditScoreTagFact_mart.AuditGradingSetOption_AuditGradingSet_key] FOREIGN KEY(AuditGradingSet_key) REFERENCES mart.AuditGradingSetOption
    ,CONSTRAINT [FK_mart.AuditScoreTagFact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

GO
