-- Fix column lengths to match source schema
-- Audits: Update Question columns to nvarchar(max) to match dbo.InspectionTypeWorkflowComponents.Description
-- ReportedIssues: Update Question/Branch columns to nvarchar(500) to match various source tables

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

GO
