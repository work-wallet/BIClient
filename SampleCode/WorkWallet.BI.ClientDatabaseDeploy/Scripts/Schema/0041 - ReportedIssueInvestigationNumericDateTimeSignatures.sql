-- ReportedIssueInvestigationNumericAnswers / ReportedIssueInvestigationDateTimeAnswers /
-- ReportedIssueInvestigationSignatures: answers to the investigation process's Ask Numeric Question,
-- Ask DateTime Question and Request Signature blocks.
--
-- Following the existing ReportedIssue workflow tables, the facts carry an Investigation flag (these
-- blocks currently only exist in the investigation process) and the question dimensions are keyed on
-- text per wallet rather than on the source block id, because the block ids change every time the
-- investigation process is edited (each process version clones its blocks with new ids).
--
-- The numeric/date-time facts include the source block id (NumberId/DateTimeId) in the primary key, so
-- two blocks with the same question text on one issue are both kept rather than colliding on the
-- text-keyed dimension.

CREATE TABLE mart.ReportedIssueNumericQuestion
(
    ReportedIssueNumericQuestion_key int IDENTITY
    ,Question nvarchar(500) NOT NULL
    ,Scale int NOT NULL
    ,Unit_key int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.ReportedIssueNumericQuestion__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.ReportedIssueNumericQuestion] PRIMARY KEY (ReportedIssueNumericQuestion_key)
    ,CONSTRAINT [UQ_mart.ReportedIssueNumericQuestion_Wallet_key_Question_Scale_Unit_key] UNIQUE(Wallet_key, Question, Scale, Unit_key)
    ,CONSTRAINT [FK_mart.ReportedIssueNumericQuestion_mart.Unit_Unit_key] FOREIGN KEY(Unit_key) REFERENCES mart.Unit
    ,CONSTRAINT [FK_mart.ReportedIssueNumericQuestion_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.ReportedIssueNumericAnswerFact
(
    ReportedIssue_key int NOT NULL
    ,NumberId uniqueidentifier NOT NULL /* business key (with ReportedIssue_key, Investigation) */
    ,Investigation bit NOT NULL
    ,ReportedIssueNumericQuestion_key int NOT NULL
    ,Answer decimal(35,6) NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.ReportedIssueNumericAnswerFact__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.ReportedIssueNumericAnswerFact] PRIMARY KEY (ReportedIssue_key, NumberId, Investigation)
    ,CONSTRAINT [FK_mart.ReportedIssueNumericAnswerFact_mart.ReportedIssue_ReportedIssue_key] FOREIGN KEY(ReportedIssue_key) REFERENCES mart.ReportedIssue
    ,CONSTRAINT [FK_mart.ReportedIssueNumericAnswerFact_mart.ReportedIssueNumericQuestion_ReportedIssueNumericQuestion_key] FOREIGN KEY(ReportedIssueNumericQuestion_key) REFERENCES mart.ReportedIssueNumericQuestion
    ,CONSTRAINT [FK_mart.ReportedIssueNumericAnswerFact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.ReportedIssueDateTimeQuestion
(
    ReportedIssueDateTimeQuestion_key int IDENTITY
    ,Question nvarchar(500) NOT NULL
    ,[Date] bit NOT NULL
    ,[Time] bit NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.ReportedIssueDateTimeQuestion__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.ReportedIssueDateTimeQuestion] PRIMARY KEY (ReportedIssueDateTimeQuestion_key)
    ,CONSTRAINT [UQ_mart.ReportedIssueDateTimeQuestion_Wallet_key_Question_Date_Time] UNIQUE(Wallet_key, Question, [Date], [Time])
    ,CONSTRAINT [FK_mart.ReportedIssueDateTimeQuestion_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.ReportedIssueDateTimeAnswerFact
(
    ReportedIssue_key int NOT NULL
    ,DateTimeId uniqueidentifier NOT NULL /* business key (with ReportedIssue_key, Investigation) */
    ,Investigation bit NOT NULL
    ,ReportedIssueDateTimeQuestion_key int NOT NULL
    ,AnswerDateTime smalldatetime NULL -- allow null
    ,AnswerDate date NULL -- allow null
    ,AnswerTime time(0) NULL -- allow null
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.ReportedIssueDateTimeAnswerFact__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.ReportedIssueDateTimeAnswerFact] PRIMARY KEY (ReportedIssue_key, DateTimeId, Investigation)
    ,CONSTRAINT [FK_mart.ReportedIssueDateTimeAnswerFact_mart.ReportedIssue_ReportedIssue_key] FOREIGN KEY(ReportedIssue_key) REFERENCES mart.ReportedIssue
    ,CONSTRAINT [FK_mart.ReportedIssueDateTimeAnswerFact_mart.ReportedIssueDateTimeQuestion_ReportedIssueDateTimeQuestion_key] FOREIGN KEY(ReportedIssueDateTimeQuestion_key) REFERENCES mart.ReportedIssueDateTimeQuestion
    ,CONSTRAINT [FK_mart.ReportedIssueDateTimeAnswerFact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

-- Keyed on the source signature row id, since a signature block can allow multiple signatures.
-- Clustered on ReportedIssue_key (not the PK) so the per-issue deletes in
-- mart.ETL_DeleteReportedIssueFacts have a seek path, and to avoid fragmentation from
-- clustering on a random GUID.
CREATE TABLE mart.ReportedIssueSignatureFact
(
    ReportedIssueSignatureId uniqueidentifier NOT NULL /* business key */
    ,Investigation bit NOT NULL
    ,ReportedIssue_key int NOT NULL
    ,SignatureId uniqueidentifier NOT NULL -- the signature block; groups the signatures captured by one block
    ,ReportedIssuePersonOptionType_key int NOT NULL
    ,Contact_key int NULL -- nullable; null for 'Other' (typed-in) signatories
    ,[Name] nvarchar(max) NOT NULL
    ,JobTitle nvarchar(50) NOT NULL
    ,[Description] nvarchar(250) NOT NULL
    ,SignedOn datetime NULL -- nullable; may not be set on an in-progress investigation
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.ReportedIssueSignatureFact__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.ReportedIssueSignatureFact] PRIMARY KEY NONCLUSTERED (ReportedIssueSignatureId, Investigation)
    ,CONSTRAINT [FK_mart.ReportedIssueSignatureFact_mart.ReportedIssue_ReportedIssue_key] FOREIGN KEY(ReportedIssue_key) REFERENCES mart.ReportedIssue
    ,CONSTRAINT [FK_mart.ReportedIssueSignatureFact_mart.ReportedIssuePersonOptionType_ReportedIssuePersonOptionType_key] FOREIGN KEY(ReportedIssuePersonOptionType_key) REFERENCES mart.ReportedIssuePersonOptionType
    ,CONSTRAINT [FK_mart.ReportedIssueSignatureFact_mart.Contact_Contact_key] FOREIGN KEY(Contact_key) REFERENCES mart.Contact
    ,CONSTRAINT [FK_mart.ReportedIssueSignatureFact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE CLUSTERED INDEX [IX_mart.ReportedIssueSignatureFact_ReportedIssue_key] ON mart.ReportedIssueSignatureFact (ReportedIssue_key);

GO
