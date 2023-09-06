DROP PROCEDURE IF EXISTS mart.ETL_MaintainReportedIssueDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainReportedIssueDimension @reportedIssueTable mart.ETL_ReportedIssueTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    -- type 1 changes (do first, before inserting new)
    UPDATE mart.ReportedIssue
    SET
        ReportedIssueReference = a.ReportedIssueReference
        ,OccurredOn = a.OccurredOn
        ,ReportedOn = a.ReportedOn
        ,ReportedBy = a.ReportedBy
        ,ReportedIssueStatus_key = ris.ReportedIssueStatus_key
        ,ReportedIssueCategory_key = ric.ReportedIssueCategory_key
        ,Location_key = ol.Location_key
        ,ReportedIssueOverview = a.ReportedIssueOverview
        ,ReportedIssueSeverity_key = riv.ReportedIssueSeverity_key
        ,CloseDate = a.CloseDate
        ,Wallet_key = w.Wallet_key
        ,_edited = SYSUTCDATETIME()
    FROM
        @reportedIssueTable AS a
        INNER JOIN mart.ReportedIssueStatus AS ris ON a.ReportedIssueStatusCode = ris.ReportedIssueStatusCode
        INNER JOIN mart.ReportedIssueCategory AS ric ON
            a.SubcategoryId = ric.SubcategoryId
            AND a.CategoryVersion = ric.CategoryVersion
        INNER JOIN mart.[Location] AS ol ON a.LocationId = ol.LocationId
        INNER JOIN mart.ReportedIssueSeverity AS riv ON a.ReportedIssueSeverityCode = riv.ReportedIssueSeverityCode
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        INNER JOIN mart.ReportedIssue AS b ON a.ReportedIssueId = b.ReportedIssueId
    WHERE /* only where the data has changed */
        a.ReportedIssueReference <> b.ReportedIssueReference
        OR a.OccurredOn <> b.OccurredOn
        OR a.ReportedOn <> b.ReportedOn
        OR a. ReportedBy <> b.ReportedBy
        OR ris.ReportedIssueStatus_key <> b.ReportedIssueStatus_key
        OR ric.ReportedIssueCategory_key <> b.ReportedIssueCategory_key
        OR ol.Location_key <> b.Location_key
        OR a.ReportedIssueOverview <> b.ReportedIssueOverview
        OR riv.ReportedIssueSeverity_key <> b.ReportedIssueSeverity_key
        OR a.CloseDate <> b.CloseDate
        OR w.Wallet_key <> b.Wallet_key;

    PRINT 'UPDATE mart.ReportedIssue, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

    -- insert missing entries
    INSERT INTO mart.ReportedIssue
    (
        ReportedIssueId
        ,ReportedIssueReference
        ,OccurredOn
        ,ReportedOn
        ,ReportedBy
        ,ReportedIssueStatus_key
        ,ReportedIssueCategory_key
        ,Location_key
        ,ReportedIssueOverview
        ,ReportedIssueSeverity_key
        ,CloseDate
        ,Wallet_key
    )
    SELECT
        a.ReportedIssueId
        ,a.ReportedIssueReference
        ,a.OccurredOn
        ,a.ReportedOn
        ,a.ReportedBy
        ,ris.ReportedIssueStatus_key
        ,ric.ReportedIssueCategory_key
        ,ol.Location_key
        ,a.ReportedIssueOverview
        ,riv.ReportedIssueSeverity_key
        ,a.CloseDate
        ,w.Wallet_key
    FROM
        @reportedIssueTable AS a
        INNER JOIN mart.ReportedIssueStatus AS ris ON a.ReportedIssueStatusCode = ris.ReportedIssueStatusCode
        INNER JOIN mart.ReportedIssueCategory AS ric ON
            a.SubcategoryId = ric.SubcategoryId
            AND a.CategoryVersion = ric.CategoryVersion
        INNER JOIN mart.[Location] AS ol ON a.LocationId = ol.LocationId
        INNER JOIN mart.ReportedIssueSeverity AS riv ON a.ReportedIssueSeverityCode = riv.ReportedIssueSeverityCode
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        LEFT OUTER JOIN mart.ReportedIssue AS b ON a.ReportedIssueId = b.ReportedIssueId
    WHERE
        b.ReportedIssueId IS NULL;

    PRINT 'INSERT mart.ReportedIssue, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
