DROP PROCEDURE IF EXISTS mart.ETL_MaintainReportedIssueDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainReportedIssueDimension @reportedIssueTable mart.ETL_ReportedIssueTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.ReportedIssue AS target
    USING (
        SELECT
            a.ReportedIssueId
            ,a.ReportedIssueReference
            ,a.OccurredOn
            ,a.ReportedOn
            ,a.ReportedBy
            ,c.Contact_key AS ReportedByContact_key
            ,a.ReportedByCompany
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
            INNER JOIN mart.ReportedIssueCategory AS ric ON a.SubcategoryId = ric.SubcategoryId AND a.CategoryVersion = ric.CategoryVersion
            INNER JOIN mart.[Location] AS ol ON a.LocationId = ol.LocationId
            INNER JOIN mart.Contact AS c ON a.ReportedByContactId = c.ContactId
            INNER JOIN mart.ReportedIssueSeverity AS riv ON a.ReportedIssueSeverityCode = riv.ReportedIssueSeverityCode
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON target.ReportedIssueId = source.ReportedIssueId
    WHEN MATCHED AND (
            target.ReportedIssueReference <> source.ReportedIssueReference
            OR target.OccurredOn <> source.OccurredOn
            OR target.ReportedOn <> source.ReportedOn
            OR target.ReportedBy <> source.ReportedBy
            OR target.ReportedByContact_key IS DISTINCT FROM source.ReportedByContact_key
            OR target.ReportedByCompany <> source.ReportedByCompany
            OR target.ReportedIssueStatus_key <> source.ReportedIssueStatus_key
            OR target.ReportedIssueCategory_key <> source.ReportedIssueCategory_key
            OR target.Location_key <> source.Location_key
            OR target.ReportedIssueOverview <> source.ReportedIssueOverview
            OR target.ReportedIssueSeverity_key <> source.ReportedIssueSeverity_key
            OR target.CloseDate <> source.CloseDate
            OR target.Wallet_key <> source.Wallet_key
        ) THEN
        UPDATE SET
            ReportedIssueReference = source.ReportedIssueReference
            ,OccurredOn = source.OccurredOn
            ,ReportedOn = source.ReportedOn
            ,ReportedBy = source.ReportedBy
            ,ReportedByContact_key = source.ReportedByContact_key
            ,ReportedByCompany = source.ReportedByCompany
            ,ReportedIssueStatus_key = source.ReportedIssueStatus_key
            ,ReportedIssueCategory_key = source.ReportedIssueCategory_key
            ,Location_key = source.Location_key
            ,ReportedIssueOverview = source.ReportedIssueOverview
            ,ReportedIssueSeverity_key = source.ReportedIssueSeverity_key
            ,CloseDate = source.CloseDate
            ,Wallet_key = source.Wallet_key
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            ReportedIssueId
            ,ReportedIssueReference
            ,OccurredOn
            ,ReportedOn
            ,ReportedBy
            ,ReportedByContact_key
            ,ReportedByCompany
            ,ReportedIssueStatus_key
            ,ReportedIssueCategory_key
            ,Location_key
            ,ReportedIssueOverview
            ,ReportedIssueSeverity_key
            ,CloseDate
            ,Wallet_key
        )
        VALUES (
            source.ReportedIssueId
            ,source.ReportedIssueReference
            ,source.OccurredOn
            ,source.ReportedOn
            ,source.ReportedBy
            ,source.ReportedByContact_key
            ,source.ReportedByCompany
            ,source.ReportedIssueStatus_key
            ,source.ReportedIssueCategory_key
            ,source.Location_key
            ,source.ReportedIssueOverview
            ,source.ReportedIssueSeverity_key
            ,source.CloseDate
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.ReportedIssue, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
