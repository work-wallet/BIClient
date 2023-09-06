DROP TYPE IF EXISTS mart.ETL_ReportedIssueOptionSelectTable;
GO

CREATE TYPE mart.ETL_ReportedIssueOptionSelectTable AS TABLE
(
    ReportedIssueId uniqueidentifier NOT NULL
    ,ChecklistId uniqueidentifier NOT NULL
    ,OptionId uniqueidentifier NOT NULL
    ,Question nvarchar(100) NOT NULL
    ,[Option] nvarchar(250) NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (ReportedIssueId, ChecklistId, OptionId)
);
GO