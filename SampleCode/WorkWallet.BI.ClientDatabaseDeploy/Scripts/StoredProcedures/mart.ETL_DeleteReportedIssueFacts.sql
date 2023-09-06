DROP PROCEDURE IF EXISTS mart.ETL_DeleteReportedIssueFacts;
GO

CREATE PROCEDURE mart.ETL_DeleteReportedIssueFacts @reportedIssueTable mart.ETL_ReportedIssueTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    DELETE mart.ReportedIssueRootCauseAnalysisFact
    FROM mart.ReportedIssueRootCauseAnalysisFact AS d
    INNER JOIN mart.ReportedIssue AS ri ON d.ReportedIssue_key = ri.ReportedIssue_key
    INNER JOIN @reportedIssueTable AS a ON ri.ReportedIssueId = a.ReportedIssueId;

    PRINT 'DELETE mart.ReportedIssueRootCauseAnalysisFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

    DELETE mart.ReportedIssueBranchOptionFact
    FROM mart.ReportedIssueBranchOptionFact AS d
    INNER JOIN mart.ReportedIssue AS ri ON d.ReportedIssue_key = ri.ReportedIssue_key
    INNER JOIN @reportedIssueTable AS a ON ri.ReportedIssueId = a.ReportedIssueId;

    PRINT 'DELETE mart.ReportedIssueBranchOptionFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

    DELETE mart.ReportedIssueBodyPartFact
    FROM mart.ReportedIssueBodyPartFact AS d
    INNER JOIN mart.ReportedIssue AS ri ON d.ReportedIssue_key = ri.ReportedIssue_key
    INNER JOIN @reportedIssueTable AS a ON ri.ReportedIssueId = a.ReportedIssueId;

    PRINT 'DELETE mart.ReportedIssueBodyPartFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

    DELETE mart.ReportedIssueOptionSelectFact
    FROM mart.ReportedIssueOptionSelectFact AS d
    INNER JOIN mart.ReportedIssue AS ri ON d.ReportedIssue_key = ri.ReportedIssue_key
    INNER JOIN @reportedIssueTable AS a ON ri.ReportedIssueId = a.ReportedIssueId;

    PRINT 'DELETE mart.ReportedIssueOptionSelectFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

    DELETE mart.ReportedIssuePersonFact
    FROM mart.ReportedIssuePersonFact AS d
    INNER JOIN mart.ReportedIssue AS ri ON d.ReportedIssue_key = ri.ReportedIssue_key
    INNER JOIN @reportedIssueTable AS a ON ri.ReportedIssueId = a.ReportedIssueId;

    PRINT 'DELETE mart.ReportedIssuePersonFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
