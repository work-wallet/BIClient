DROP PROCEDURE IF EXISTS mart.ETL_LoadReportedIssueInvestigationTeamFact;
GO

CREATE PROCEDURE mart.ETL_LoadReportedIssueInvestigationTeamFact
    @reportedIssueInvestigationTeamTable mart.ETL_ReportedIssueInvestigationTeamTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    -- insert missing entries
    INSERT INTO mart.ReportedIssueInvestigationTeamFact
    (
        -- keys
        ReportedIssue_key
        ,Contact_key
        ,Wallet_key
        -- facts
    )
    SELECT DISTINCT
        -- keys
        ri.ReportedIssue_key
        ,c.Contact_key
        ,w.Wallet_key
        -- facts
    FROM
        @reportedIssueInvestigationTeamTable AS a
        INNER JOIN mart.ReportedIssue AS ri ON a.ReportedIssueId = ri.ReportedIssueId
        INNER JOIN mart.Contact AS c ON a.ContactId = c.ContactId
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId;

    PRINT 'INSERT mart.ReportedIssueInvestigationTeamFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
