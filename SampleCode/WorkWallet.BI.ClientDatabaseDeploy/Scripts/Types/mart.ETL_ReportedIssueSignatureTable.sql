DROP TYPE IF EXISTS mart.ETL_ReportedIssueSignatureTable;
GO

CREATE TYPE mart.ETL_ReportedIssueSignatureTable AS TABLE
(
    ReportedIssueSignatureId uniqueidentifier NOT NULL
    ,ReportedIssueId uniqueidentifier NOT NULL
    ,SignatureId uniqueidentifier NOT NULL
    ,[Name] nvarchar(max) NOT NULL
    ,PersonOptionTypeCode int NOT NULL
    ,ContactId uniqueidentifier NULL
    ,JobTitle nvarchar(50) NOT NULL
    ,[Description] nvarchar(250) NOT NULL
    ,SignedOn datetime NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (ReportedIssueSignatureId)
);
GO
