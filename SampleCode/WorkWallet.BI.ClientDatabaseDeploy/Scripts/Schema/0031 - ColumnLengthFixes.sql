-- Fix column lengths to match source schema and add Location SiteStatus support
-- Audits: Update Question columns to nvarchar(max) to match dbo.InspectionTypeWorkflowComponents.Description
-- ReportedIssues: Update Question/Branch columns to nvarchar(500) to match various source tables
-- Location: Add SiteStatus column nvarchar(80) to support site status tracking

-- Audit dimension tables
ALTER TABLE mart.AuditNumericQuestion
    ALTER COLUMN Question nvarchar(max) NOT NULL;

ALTER TABLE mart.AuditDateTimeQuestion
    ALTER COLUMN Question nvarchar(max) NOT NULL;

ALTER TABLE mart.AuditChecklistOption
    ALTER COLUMN Question nvarchar(max) NOT NULL;

ALTER TABLE mart.AuditBranchOption
    ALTER COLUMN Branch nvarchar(max) NOT NULL;

ALTER TABLE mart.AuditScoredResponse
    ALTER COLUMN Branch nvarchar(max) NOT NULL;

-- ReportedIssue dimension tables
ALTER TABLE mart.ReportedIssueBranchOption
    ALTER COLUMN Branch nvarchar(500) NOT NULL;

ALTER TABLE mart.ReportedIssueBodyPart
    ALTER COLUMN Question nvarchar(500) NOT NULL;

ALTER TABLE mart.ReportedIssueOptionSelect
    ALTER COLUMN Question nvarchar(500) NOT NULL;

ALTER TABLE mart.ReportedIssuePerson
    ALTER COLUMN Question nvarchar(500) NOT NULL;

-- Location dimension table
ALTER TABLE
    mart.[Location]
ADD
    SiteStatus nvarchar(80) NOT NULL
    CONSTRAINT DF_Location_SiteStatus DEFAULT N'[not captured when downloaded]' WITH VALUES;

ALTER TABLE mart.[Location] DROP CONSTRAINT DF_Location_SiteStatus;

GO
