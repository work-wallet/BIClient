DROP TYPE IF EXISTS mart.ETL_ReportedIssueTable;
GO

CREATE TYPE mart.ETL_ReportedIssueTable AS TABLE
(
    ReportedIssueId uniqueidentifier NOT NULL
    ,ReportedIssueReference nvarchar(50) NOT NULL
    ,OccurredOn datetime2(7) NOT NULL
    ,ReportedOn datetime2(7) NOT NULL
    ,ReportedBy nvarchar(max) NOT NULL
    ,ReportedByCompany nvarchar(max) NOT NULL
    ,ReportedIssueStatusCode int NOT NULL
    ,SubcategoryId uniqueidentifier NOT NULL
    ,CategoryVersion int NOT NULL
    ,LocationId uniqueidentifier NOT NULL
    ,ReportedIssueOverview nvarchar(max) NOT NULL
    ,ReportedIssueSeverityCode int NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,CloseDate datetimeoffset(7) NOT NULL
    ,PRIMARY KEY (ReportedIssueReference, ReportedIssueId) -- putting ReportedIssueReference first to order the data load
);
GO