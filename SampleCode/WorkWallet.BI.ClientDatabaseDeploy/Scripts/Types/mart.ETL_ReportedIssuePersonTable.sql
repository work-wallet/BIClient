DROP TYPE IF EXISTS mart.ETL_ReportedIssuePersonTable;
GO

CREATE TYPE mart.ETL_ReportedIssuePersonTable AS TABLE
(
    ReportedIssueId uniqueidentifier NOT NULL
    ,PersonId uniqueidentifier NOT NULL
    ,OptionId uniqueidentifier NOT NULL
    ,Question nvarchar(500) NOT NULL
    ,[Option] nvarchar(50) NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (ReportedIssueId, PersonId, OptionId)
);
GO