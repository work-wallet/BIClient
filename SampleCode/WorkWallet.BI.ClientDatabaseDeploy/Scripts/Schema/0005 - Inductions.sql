-- mart.InductionStatus
CREATE TABLE mart.InductionStatus
(
    InductionStatus_key int IDENTITY
    ,InductionStatusCode int NOT NULL /* business key */
    ,InductionStatus nvarchar(50) NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.InductionStatus__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.InductionStatus] PRIMARY KEY (InductionStatus_key)
    ,CONSTRAINT [UQ_mart.InductionStatus_Code] UNIQUE(InductionStatusCode)
);

INSERT INTO mart.InductionStatus (InductionStatusCode, InductionStatus) VALUES (0, N'Active');
INSERT INTO mart.InductionStatus (InductionStatusCode, InductionStatus) VALUES (1, N'Archived');
INSERT INTO mart.InductionStatus (InductionStatusCode, InductionStatus) VALUES (3, N'Deleted');

-- mart.InductionTakenStatus
CREATE TABLE mart.InductionTakenStatus
(
    InductionTakenStatus_key int IDENTITY
    ,InductionTakenStatusCode int NOT NULL /* business key */
    ,InductionTakenStatus nvarchar(50) NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.InductionTakenStatus__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.InductionTakenStatus] PRIMARY KEY (InductionTakenStatus_key)
    ,CONSTRAINT [UQ_mart.InductionTakenStatus_Code] UNIQUE(InductionTakenStatusCode)
);

INSERT INTO mart.InductionTakenStatus (InductionTakenStatusCode, InductionTakenStatus) VALUES (1, N'Passed');
INSERT INTO mart.InductionTakenStatus (InductionTakenStatusCode, InductionTakenStatus) VALUES (2, N'Completed');
INSERT INTO mart.InductionTakenStatus (InductionTakenStatusCode, InductionTakenStatus) VALUES (3, N'Failed');
INSERT INTO mart.InductionTakenStatus (InductionTakenStatusCode, InductionTakenStatus) VALUES (4, N'Passed'); -- PassedExpiringSoon
INSERT INTO mart.InductionTakenStatus (InductionTakenStatusCode, InductionTakenStatus) VALUES (5, N'Completed'); -- CompletedExpiringSoon
INSERT INTO mart.InductionTakenStatus (InductionTakenStatusCode, InductionTakenStatus) VALUES (6, N'Expired');
INSERT INTO mart.InductionTakenStatus (InductionTakenStatusCode, InductionTakenStatus) VALUES (7, N'Invalid');

-- mart.Induction
CREATE TABLE mart.Induction
(
    Induction_key int IDENTITY
    ,InductionId uniqueidentifier NOT NULL
    ,InductionVersion int NOT NULL
    ,InductionName nvarchar(100) NOT NULL
    ,ValidForDays int NOT NULL
    ,CreatedOn datetimeoffset(7) NOT NULL
    ,Active bit NOT NULL
    ,InductionStatus_key int NOT NULL
    ,TestPassMark int NOT NULL
    ,TestQuestionCount int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.Induction__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.Induction] PRIMARY KEY (Induction_key)
    ,CONSTRAINT [UQ_mart.Induction_InductionId_InductionVersion] UNIQUE(InductionId, InductionVersion)
)

ALTER TABLE mart.Induction WITH CHECK ADD CONSTRAINT [FK_mart.Induction_dbo.mart.InductionStatus_InductionStatus_key] FOREIGN KEY(InductionStatus_key)
REFERENCES mart.InductionStatus (InductionStatus_key);

ALTER TABLE mart.Induction CHECK CONSTRAINT [FK_mart.Induction_dbo.mart.InductionStatus_InductionStatus_key];

ALTER TABLE mart.Induction WITH CHECK ADD CONSTRAINT [FK_mart.Induction_dbo.mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key)
REFERENCES mart.[Wallet] (Wallet_key);

ALTER TABLE mart.Induction CHECK CONSTRAINT [FK_mart.Induction_dbo.mart.Wallet_Wallet_key];

-- mart.InductionTaken
CREATE TABLE mart.InductionTaken
(
    InductionTaken_key int IDENTITY
    ,InductionTakenId uniqueidentifier NOT NULL
    ,Induction_key int NOT NULL
    ,ContactId uniqueidentifier NOT NULL
    ,[Name] nvarchar(max) NOT NULL
    ,CompanyName nvarchar(max) NOT NULL
    ,TakenOn datetime NOT NULL
    ,CorrectTestQuestionCount int NOT NULL
    ,InductionTakenStatus_key int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.InductionTaken__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.InductionTaken] PRIMARY KEY (InductionTaken_key)
    ,CONSTRAINT [UQ_mart.InductionTaken_InductionTakenId] UNIQUE(InductionTakenId)
)

ALTER TABLE mart.InductionTaken WITH CHECK ADD CONSTRAINT [FK_mart.InductionTaken_dbo.mart.InductionTakenStatus_InductionTakenStatus_key] FOREIGN KEY(InductionTakenStatus_key)
REFERENCES mart.InductionTakenStatus (InductionTakenStatus_key);

ALTER TABLE mart.InductionTaken CHECK CONSTRAINT [FK_mart.InductionTaken_dbo.mart.InductionTakenStatus_InductionTakenStatus_key];

ALTER TABLE mart.InductionTaken WITH CHECK ADD CONSTRAINT [FK_mart.InductionTaken_dbo.mart.Induction_Induction_key] FOREIGN KEY(Induction_key)
REFERENCES mart.Induction (Induction_key);

ALTER TABLE mart.InductionTaken CHECK CONSTRAINT [FK_mart.InductionTaken_dbo.mart.Induction_Induction_key];

ALTER TABLE mart.InductionTaken WITH CHECK ADD CONSTRAINT [FK_mart.InductionTaken_dbo.mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key)
REFERENCES mart.[Wallet] (Wallet_key);

ALTER TABLE mart.InductionTaken CHECK CONSTRAINT [FK_mart.InductionTaken_dbo.mart.Wallet_Wallet_key];

-- mart.InductionCustomQuestion
CREATE TABLE mart.InductionCustomQuestion
(
    InductionCustomQuestion_key int IDENTITY
    ,Title nvarchar(250) NOT NULL
    ,[Value] nvarchar(250) NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.InductionCustomQuestion__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.InductionCustomQuestion] PRIMARY KEY (InductionCustomQuestion_key)
    ,CONSTRAINT [UQ_mart.InductionCustomQuestion_Wallet_key_Title_Value] UNIQUE(Wallet_key, Title, [Value])
)

ALTER TABLE mart.InductionCustomQuestion WITH CHECK ADD CONSTRAINT [FK_mart.InductionCustomQuestion_dbo.mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key)
REFERENCES mart.[Wallet] (Wallet_key);

ALTER TABLE mart.InductionCustomQuestion CHECK CONSTRAINT [FK_mart.InductionCustomQuestion_dbo.mart.Wallet_Wallet_key];

-- mart.InductionCustomQuestionFact
CREATE TABLE mart.InductionCustomQuestionFact
(
    InductionTaken_key int NOT NULL
    ,InductionCustomQuestion_key int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.InductionCustomQuestionFact__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.InductionCustomQuestionFact] PRIMARY KEY (InductionTaken_key, InductionCustomQuestion_key)
)

ALTER TABLE mart.InductionCustomQuestionFact WITH CHECK ADD CONSTRAINT [FK_mart.InductionCustomQuestionFact_dbo.mart.InductionTaken_InductionTaken_key] FOREIGN KEY(InductionTaken_key)
REFERENCES mart.InductionTaken (InductionTaken_key);

ALTER TABLE mart.InductionCustomQuestionFact CHECK CONSTRAINT [FK_mart.InductionCustomQuestionFact_dbo.mart.InductionTaken_InductionTaken_key];

ALTER TABLE mart.InductionCustomQuestionFact WITH CHECK ADD CONSTRAINT [FK_mart.InductionCustomQuestionFact_dbo.mart.InductionCustomQuestion_InductionCustomQuestion_key] FOREIGN KEY(InductionCustomQuestion_key)
REFERENCES mart.[InductionCustomQuestion] (InductionCustomQuestion_key);

ALTER TABLE mart.InductionCustomQuestionFact CHECK CONSTRAINT [FK_mart.InductionCustomQuestionFact_dbo.mart.InductionCustomQuestion_InductionCustomQuestion_key];

ALTER TABLE mart.InductionCustomQuestionFact WITH CHECK ADD CONSTRAINT [FK_mart.InductionCustomQuestionFact_dbo.mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key)
REFERENCES mart.[Wallet] (Wallet_key);

ALTER TABLE mart.InductionCustomQuestionFact CHECK CONSTRAINT [FK_mart.InductionCustomQuestionFact_dbo.mart.Wallet_Wallet_key];

GO
