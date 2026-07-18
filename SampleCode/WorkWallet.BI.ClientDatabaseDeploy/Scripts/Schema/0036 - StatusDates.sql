-- Audits: add status change date columns to mart.[Audit] dimension.
-- These capture the first date on which the audit entered each status,
-- and are null when the current status means the date would be misleading.

IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE [Name] = N'PlannedStatusDate' AND object_id = OBJECT_ID(N'mart.[Audit]'))
BEGIN

    ALTER TABLE mart.[Audit]
    ADD
        PlannedStatusDate datetimeoffset(7) NULL
        ,ReportInProgressStatusDate datetimeoffset(7) NULL
        ,ReadyForReviewStatusDate datetimeoffset(7) NULL
        ,CompleteStatusDate datetimeoffset(7) NULL
        ,ClosedStatusDate datetimeoffset(7) NULL;

END

GO

-- ReportedIssues: add UnderInvestigationDate column to mart.ReportedIssue dimension.
-- Uses '0001-01-01' as a sentinel value (same convention as CloseDate) when not yet reached.

IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE [Name] = N'UnderInvestigationDate' AND object_id = OBJECT_ID(N'mart.ReportedIssue'))
BEGIN

    ALTER TABLE mart.ReportedIssue
    ADD
        UnderInvestigationDate datetimeoffset(7) NOT NULL
        CONSTRAINT [DF_mart.ReportedIssue_UnderInvestigationDate] DEFAULT CAST('0001-01-01' AS datetimeoffset(7)) WITH VALUES;

    ALTER TABLE mart.ReportedIssue DROP CONSTRAINT [DF_mart.ReportedIssue_UnderInvestigationDate];

END

GO
