-- ReportedIssues: add LeadInvestigatorContact_key to ReportedIssue dimension
-- and add ReportedIssueInvestigationTeamFact table for investigation team members.

-- Step 1: add LeadInvestigatorContact_key column and FK constraint to mart.ReportedIssue.

IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE [Name] = N'LeadInvestigatorContact_key' AND object_id = OBJECT_ID(N'mart.ReportedIssue'))
BEGIN

    ALTER TABLE mart.ReportedIssue
    ADD
        LeadInvestigatorContact_key int NULL
        ,CONSTRAINT [FK_mart.ReportedIssue_mart.Contact_LeadInvestigatorContact_key]
            FOREIGN KEY (LeadInvestigatorContact_key) REFERENCES mart.Contact (Contact_key);

END

GO

-- Step 2: create mart.ReportedIssueInvestigationTeamFact table.

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE [name] = N'ReportedIssueInvestigationTeamFact' AND [schema_id] = SCHEMA_ID(N'mart'))
BEGIN

    CREATE TABLE mart.ReportedIssueInvestigationTeamFact
    (
        ReportedIssue_key int NOT NULL
        ,Contact_key int NOT NULL
        ,Wallet_key int NOT NULL
        ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.ReportedIssueInvestigationTeamFact__created] DEFAULT SYSUTCDATETIME()
        ,_edited datetime2(7) NULL
        ,CONSTRAINT [PK_mart.ReportedIssueInvestigationTeamFact] PRIMARY KEY (ReportedIssue_key, Contact_key)
        ,CONSTRAINT [FK_mart.ReportedIssueInvestigationTeamFact_mart.ReportedIssue_ReportedIssue_key] FOREIGN KEY (ReportedIssue_key) REFERENCES mart.ReportedIssue
        ,CONSTRAINT [FK_mart.ReportedIssueInvestigationTeamFact_mart.Contact_Contact_key] FOREIGN KEY (Contact_key) REFERENCES mart.Contact
        ,CONSTRAINT [FK_mart.ReportedIssueInvestigationTeamFact_mart.Wallet_Wallet_key] FOREIGN KEY (Wallet_key) REFERENCES mart.Wallet
    );

END

GO
