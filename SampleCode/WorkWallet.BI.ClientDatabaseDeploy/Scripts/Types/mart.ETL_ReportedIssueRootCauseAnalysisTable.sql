DROP TYPE IF EXISTS mart.ETL_ReportedIssueRootCauseAnalysisTable;
GO

CREATE TYPE mart.ETL_ReportedIssueRootCauseAnalysisTable AS TABLE
(
    ReportedIssueRootCauseAnalysisId uniqueidentifier NOT NULL
    ,ReportedIssueId uniqueidentifier NOT NULL
    ,ReportedIssueRootCauseAnalysisTypeCode int NOT NULL
    ,RootCauseAnalysis nvarchar(100) NOT NULL
    ,RootCauseAnalysisDescription nvarchar(400) NOT NULL
    ,RootCauseAnalysisOrder int NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (ReportedIssueRootCauseAnalysisId)
);
GO
