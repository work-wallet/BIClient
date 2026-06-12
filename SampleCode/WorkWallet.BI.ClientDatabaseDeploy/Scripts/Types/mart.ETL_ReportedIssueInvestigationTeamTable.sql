DROP TYPE IF EXISTS mart.ETL_ReportedIssueInvestigationTeamTable;
GO

CREATE TYPE mart.ETL_ReportedIssueInvestigationTeamTable AS TABLE
(
    ReportedIssueId uniqueidentifier NOT NULL
    ,ContactId uniqueidentifier NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (ReportedIssueId, ContactId)
);
GO
