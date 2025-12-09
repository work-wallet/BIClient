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
    ,CONSTRAINT [FK_mart.Induction_mart.InductionStatus_InductionStatus_key] FOREIGN KEY(InductionStatus_key) REFERENCES mart.InductionStatus
    ,CONSTRAINT [FK_mart.Induction_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.[Wallet]
);

CREATE TABLE mart.InductionTaken
(
    InductionTaken_key int IDENTITY
    ,InductionTakenId uniqueidentifier NOT NULL
    ,Induction_key int NOT NULL
    ,Contact_key int NULL -- allow NULLs (data from older versions of the API did not process contacts, will never be NULL for new data)
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
    ,CONSTRAINT [FK_mart.InductionTaken_mart.InductionTakenStatus_InductionTakenStatus_key] FOREIGN KEY(InductionTakenStatus_key) REFERENCES mart.InductionTakenStatus
    ,CONSTRAINT [FK_mart.InductionTaken_mart.Induction_Induction_key] FOREIGN KEY(Induction_key) REFERENCES mart.Induction
    ,CONSTRAINT [FK_mart.InductionTaken_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

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
    ,CONSTRAINT [FK_mart.InductionCustomQuestion_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.[Wallet]
);

CREATE TABLE mart.InductionCustomQuestionFact
(
    InductionTaken_key int NOT NULL
    ,InductionCustomQuestion_key int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.InductionCustomQuestionFact__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.InductionCustomQuestionFact] PRIMARY KEY (InductionTaken_key, InductionCustomQuestion_key)
    ,CONSTRAINT [FK_mart.InductionCustomQuestionFact_mart.InductionTaken_InductionTaken_key] FOREIGN KEY(InductionTaken_key) REFERENCES mart.InductionTaken
    ,CONSTRAINT [FK_mart.InductionCustomQuestionFact_mart.InductionCustomQuestion_InductionCustomQuestion_key] FOREIGN KEY(InductionCustomQuestion_key) REFERENCES mart.InductionCustomQuestion
    ,CONSTRAINT [FK_mart.InductionCustomQuestionFact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

GO
