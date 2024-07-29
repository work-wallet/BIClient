DROP PROCEDURE IF EXISTS mart.ETL_MaintainSiteAuditDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainSiteAuditDimension @siteAuditTable mart.ETL_SiteAuditTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.SiteAudit AS target
    USING (
        SELECT
            a.SiteAuditId,
            a.AuditReference,
            a.DateAndTimeOfInspection,
            sas.SiteAuditStatus_key,
            sat.SiteAuditType_key,
            ol.Location_key,
            a.AuditSummary,
            a.HasScore,
            a.Passed,
            a.ActualScore,
            a.PotentialScore,
            a.[Percent],
            w.Wallet_key
        FROM
            @siteAuditTable AS a
            INNER JOIN mart.SiteAuditStatus AS sas ON a.SiteAuditStatusCode = sas.SiteAuditStatusCode
            INNER JOIN mart.SiteAuditType AS sat ON a.SiteAuditTypeId = sat.SiteAuditTypeId
            INNER JOIN mart.[Location] AS ol ON a.LocationId = ol.LocationId
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON target.SiteAuditId = source.SiteAuditId
    WHEN MATCHED AND (
        target.AuditReference <> source.AuditReference
        OR target.DateAndTimeOfInspection <> source.DateAndTimeOfInspection
        OR target.SiteAuditStatus_key <> source.SiteAuditStatus_key
        OR target.SiteAuditType_key <> source.SiteAuditType_key
        OR target.Location_key <> source.Location_key
        OR target.AuditSummary <> source.AuditSummary
        OR target.HasScore <> source.HasScore
        OR target.Passed <> source.Passed
        OR target.ActualScore <> source.ActualScore
        OR target.PotentialScore <> source.PotentialScore
        OR target.[Percent] <> source.[Percent]
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            AuditReference = source.AuditReference,
            DateAndTimeOfInspection = source.DateAndTimeOfInspection,
            SiteAuditStatus_key = source.SiteAuditStatus_key,
            SiteAuditType_key = source.SiteAuditType_key,
            Location_key = source.Location_key,
            AuditSummary = source.AuditSummary,
            HasScore = source.HasScore,
            Passed = source.Passed,
            ActualScore = source.ActualScore,
            PotentialScore = source.PotentialScore,
            [Percent] = source.[Percent],
            Wallet_key = source.Wallet_key,
            _edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            SiteAuditId,
            AuditReference,
            DateAndTimeOfInspection,
            SiteAuditStatus_key,
            SiteAuditType_key,
            Location_key,
            AuditSummary,
            HasScore,
            Passed,
            ActualScore,
            PotentialScore,
            [Percent],
            Wallet_key
        ) VALUES (
            source.SiteAuditId,
            source.AuditReference,
            source.DateAndTimeOfInspection,
            source.SiteAuditStatus_key,
            source.SiteAuditType_key,
            source.Location_key,
            source.AuditSummary,
            source.HasScore,
            source.Passed,
            source.ActualScore,
            source.PotentialScore,
            source.[Percent],
            source.Wallet_key
        );

    PRINT 'MERGE mart.SiteAudit, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
