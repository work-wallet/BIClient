DROP PROCEDURE IF EXISTS mart.ETL_MaintainSiteAuditDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainSiteAuditDimension @siteAuditTable mart.ETL_SiteAuditTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    -- type 1 changes (do first, before inserting new)
    UPDATE mart.SiteAudit
    SET
        AuditReference = a.AuditReference
        ,DateAndTimeOfInspection = a.DateAndTimeOfInspection
        ,SiteAuditStatus_key = sas.SiteAuditStatus_key
        ,SiteAuditType_key = sat.SiteAuditType_key
        ,Location_key = ol.Location_key
        ,AuditSummary = a.AuditSummary
        ,HasScore = a.HasScore
        ,Passed = a.Passed
        ,ActualScore = a.ActualScore
        ,PotentialScore = a.PotentialScore
        ,[Percent] = a.[Percent]
        ,Wallet_key = w.Wallet_key
        ,_edited = SYSUTCDATETIME()
    FROM
        @siteAuditTable AS a
        INNER JOIN mart.SiteAuditStatus AS sas ON a.SiteAuditStatusCode = sas.SiteAuditStatusCode
        INNER JOIN mart.SiteAuditType AS sat ON a.SiteAuditTypeId = sat.SiteAuditTypeId
        INNER JOIN mart.[Location] AS ol ON a.LocationId = ol.LocationId
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        INNER JOIN mart.SiteAudit AS b ON a.SiteAuditId = b.SiteAuditId
    WHERE /* only where the data has changed */
        a.AuditReference <> b.AuditReference
        OR a.DateAndTimeOfInspection <> b.DateAndTimeOfInspection
        OR sas.SiteAuditStatus_key <> b.SiteAuditStatus_key
        OR sat.SiteAuditType_key <> b.SiteAuditType_key
        OR ol.Location_key <> b.Location_key
        OR a.AuditSummary <> b.AuditSummary
        OR a.HasScore <> b.HasScore
        OR a.Passed <> b.Passed
        OR a.ActualScore <> b.ActualScore
        OR a.PotentialScore <> b.PotentialScore
        OR a.[Percent] <> b.[Percent]
        OR w.Wallet_key <> b.Wallet_key;

    PRINT 'UPDATE mart.SiteAudit, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

    -- insert missing entries
    INSERT INTO mart.SiteAudit
    (
        SiteAuditId
        ,AuditReference
        ,DateAndTimeOfInspection
        ,SiteAuditStatus_key
        ,SiteAuditType_key
        ,Location_key
        ,AuditSummary
        ,HasScore
        ,Passed
        ,ActualScore
        ,PotentialScore
        ,[Percent]
        ,Wallet_key
    )
    SELECT
        a.SiteAuditId
        ,a.AuditReference
        ,a.DateAndTimeOfInspection
        ,sas.SiteAuditStatus_key
        ,sat.SiteAuditType_key
        ,ol.Location_key
        ,a.AuditSummary
        ,a.HasScore
        ,a.Passed
        ,a.ActualScore
        ,a.PotentialScore
        ,a.[Percent]
        ,w.Wallet_key
    FROM
        @siteAuditTable AS a
        INNER JOIN mart.SiteAuditStatus AS sas ON a.SiteAuditStatusCode = sas.SiteAuditStatusCode
        INNER JOIN mart.SiteAuditType AS sat ON a.SiteAuditTypeId = sat.SiteAuditTypeId
        INNER JOIN mart.[Location] AS ol ON a.LocationId = ol.LocationId
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        LEFT OUTER JOIN mart.SiteAudit AS b ON a.SiteAuditId = b.SiteAuditId
    WHERE
        b.SiteAuditId IS NULL;

    PRINT 'INSERT mart.SiteAudit, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
