-- add additional ReportedByCompany column for ReportedIssues
-- (has been back-fixed in the 0004 script)

IF NOT EXISTS(select 1 from sys.columns where [Name] = N'ReportedByCompany' and Object_ID = Object_ID(N'mart.ReportedIssue'))
BEGIN

    ALTER TABLE
        mart.ReportedIssue
    ADD
        ReportedByCompany nvarchar(max) NOT NULL CONSTRAINT DF_mart_ReportedIssue_ReportedByCompany DEFAULT N'[not captured when downloaded]';

    ALTER TABLE mart.ReportedIssue DROP CONSTRAINT DF_mart_ReportedIssue_ReportedByCompany;

END

GO