DROP PROCEDURE IF EXISTS mart.ETL_LoadReportedIssueRootCauseAnalysisFact;
GO

CREATE PROCEDURE mart.ETL_LoadReportedIssueRootCauseAnalysisFact @reportedIssueRootCauseAnalysisTable mart.ETL_ReportedIssueRootCauseAnalysisTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    -- insert missing entries
    INSERT INTO mart.ReportedIssueRootCauseAnalysisFact
    (
        -- keys
        ReportedIssue_key
        ,ReportedIssueRootCauseAnalysisType_key
        ,RootCauseAnalysisOrder
        ,Wallet_key
        -- facts
        ,RootCauseAnalysis
        ,RootCauseAnalysisDescription
    )
    SELECT
        -- keys
        ri.ReportedIssue_key
        ,rircat.ReportedIssueRootCauseAnalysisType_key
        ,a.RootCauseAnalysisOrder
        ,w.Wallet_key
        -- facts
        ,a.RootCauseAnalysis
        ,a.RootCauseAnalysisDescription
    FROM
        @reportedIssueRootCauseAnalysisTable AS a
        INNER JOIN mart.ReportedIssue AS ri ON a.ReportedIssueId = ri.ReportedIssueId
        INNER JOIN mart.ReportedIssueRootCauseAnalysisType AS rircat ON a.ReportedIssueRootCauseAnalysisTypeCode = rircat.ReportedIssueRootCauseAnalysisTypeCode
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId;

    PRINT 'INSERT mart.ReportedIssueRootCauseAnalysisFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
