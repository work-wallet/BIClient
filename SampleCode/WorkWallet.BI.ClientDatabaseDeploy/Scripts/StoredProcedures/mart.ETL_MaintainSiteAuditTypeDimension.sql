DROP PROCEDURE IF EXISTS mart.ETL_MaintainSiteAuditTypeDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainSiteAuditTypeDimension @siteAuditTypeTable mart.ETL_SiteAuditTypeTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.SiteAuditType AS target
    USING (
        SELECT
            a.SiteAuditTypeId,
            a.SiteAuditType,
            a.DisplayScoring,
            a.ScoringMethod,
            a.DisplayOptions,
            a.ShowPercentage,
            a.ShowScore,
            a.ShowPassFail,
            a.ShowGrading,
            w.Wallet_key
        FROM
            @siteAuditTypeTable AS a
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON target.SiteAuditTypeId = source.SiteAuditTypeId
    WHEN MATCHED AND (
        target.SiteAuditType <> source.SiteAuditType
        OR target.DisplayScoring <> source.DisplayScoring
        OR target.ScoringMethod <> source.ScoringMethod
        OR target.DisplayOptions <> source.DisplayOptions
        OR target.ShowPercentage <> source.ShowPercentage
        OR target.ShowScore <> source.ShowScore
        OR target.ShowPassFail <> source.ShowPassFail
        OR target.ShowGrading <> source.ShowGrading
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            SiteAuditType = source.SiteAuditType,
            Wallet_key = source.Wallet_key,
            DisplayScoring = source.DisplayScoring,
            ScoringMethod = source.ScoringMethod,
            DisplayOptions = source.DisplayOptions,
            ShowPercentage = source.ShowPercentage,
            ShowScore = source.ShowScore,
            ShowPassFail = source.ShowPassFail,
            ShowGrading = source.ShowGrading,
            _edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            SiteAuditTypeId,
            SiteAuditType,
            DisplayScoring,
            ScoringMethod,
            DisplayOptions,
            ShowPercentage,
            ShowScore,
            ShowPassFail,
            ShowGrading,
            Wallet_key
        ) VALUES (
            source.SiteAuditTypeId,
            source.SiteAuditType,
            source.DisplayScoring,
            source.ScoringMethod,
            source.DisplayOptions,
            source.ShowPercentage,
            source.ShowScore,
            source.ShowPassFail,
            source.ShowGrading,
            source.Wallet_key
        );

    PRINT 'MERGE mart.SiteAuditType, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
