DROP TYPE IF EXISTS mart.ETL_ReportedIssueNumericAnswerTable;
GO

CREATE TYPE mart.ETL_ReportedIssueNumericAnswerTable AS TABLE
(
    ReportedIssueId uniqueidentifier NOT NULL
    ,NumberId uniqueidentifier NOT NULL
    ,Question nvarchar(500) NOT NULL
    ,Scale int NOT NULL
    ,UnitCode int NOT NULL
    ,Answer decimal(35,6) NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (ReportedIssueId, NumberId)
);
GO
