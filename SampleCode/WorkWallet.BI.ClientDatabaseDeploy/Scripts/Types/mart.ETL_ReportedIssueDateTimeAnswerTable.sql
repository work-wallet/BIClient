DROP TYPE IF EXISTS mart.ETL_ReportedIssueDateTimeAnswerTable;
GO

CREATE TYPE mart.ETL_ReportedIssueDateTimeAnswerTable AS TABLE
(
    ReportedIssueId uniqueidentifier NOT NULL
    ,DateTimeId uniqueidentifier NOT NULL
    ,Question nvarchar(500) NOT NULL
    ,[Date] bit NOT NULL
    ,[Time] bit NOT NULL
    ,Answer datetime NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (ReportedIssueId, DateTimeId)
);
GO
