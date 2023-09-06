DROP TYPE IF EXISTS mart.ETL_ReportedIssueBodyPartTable;
GO

CREATE TYPE mart.ETL_ReportedIssueBodyPartTable AS TABLE
(
    ReportedIssueId uniqueidentifier NOT NULL
    ,ReportedIssueBodyPartId uniqueidentifier NOT NULL
    ,Question nvarchar(100) NOT NULL
    ,BodyParts bigint NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (ReportedIssueId, ReportedIssueBodyPartId)
);
GO