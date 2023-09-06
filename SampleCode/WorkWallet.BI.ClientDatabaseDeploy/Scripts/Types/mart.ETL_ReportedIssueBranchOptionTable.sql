DROP TYPE IF EXISTS mart.ETL_ReportedIssueBranchOptionTable;
GO

CREATE TYPE mart.ETL_ReportedIssueBranchOptionTable AS TABLE
(
    ReportedIssueId uniqueidentifier NOT NULL
    ,BranchId uniqueidentifier NOT NULL
    ,OptionId uniqueidentifier NOT NULL
    ,Branch nvarchar(100) NOT NULL
    ,[Option] nvarchar(250) NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (ReportedIssueId, BranchId, OptionId)
);
GO