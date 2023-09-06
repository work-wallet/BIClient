DROP PROCEDURE IF EXISTS mart.ETL_MaintainSiteAuditTypeDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainSiteAuditTypeDimension @siteAuditTypeTable mart.ETL_SiteAuditTypeTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    -- type 1 changes (do first, before inserting new)
    UPDATE mart.SiteAuditType
    SET
        SiteAuditType = a.SiteAuditType
        ,Wallet_key = w.Wallet_key
        ,DisplayScoring = a.DisplayScoring
        ,ScoringMethod = a.ScoringMethod
        ,DisplayOptions = a.DisplayOptions
        ,ShowPercentage = a.ShowPercentage
        ,ShowScore = a.ShowScore
        ,ShowPassFail = a.ShowPassFail
        ,ShowGrading = a.ShowGrading
        ,_edited = SYSUTCDATETIME()
    FROM
        @siteAuditTypeTable AS a
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        INNER JOIN mart.SiteAuditType AS b ON a.SiteAuditTypeId = b.SiteAuditTypeId
    WHERE /* only where the data has changed */
        a.SiteAuditType <> b.SiteAuditType
        OR a.DisplayScoring <> b.DisplayScoring
        OR a.ScoringMethod <> b.ScoringMethod
        OR a.DisplayOptions <> b.DisplayOptions
        OR a.ShowPercentage <> b.ShowPercentage
        OR a.ShowScore <> b.ShowScore
        OR a.ShowPassFail <> b.ShowPassFail
        OR a.ShowGrading <> b.ShowGrading
        OR w.Wallet_key <> b.Wallet_key;

    PRINT 'UPDATE mart.SiteAuditType, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

    -- insert missing entries
    INSERT INTO mart.SiteAuditType
    (
        SiteAuditTypeId
        ,SiteAuditType
        ,DisplayScoring
        ,ScoringMethod
        ,DisplayOptions
        ,ShowPercentage
        ,ShowScore
        ,ShowPassFail
        ,ShowGrading
        ,Wallet_key
    )
    SELECT
        a.SiteAuditTypeId
        ,a.SiteAuditType
        ,a.DisplayScoring
        ,a.ScoringMethod
        ,a.DisplayOptions
        ,a.ShowPercentage
        ,a.ShowScore
        ,a.ShowPassFail
        ,a.ShowGrading
        ,w.Wallet_key
    FROM
        @siteAuditTypeTable AS a
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        LEFT OUTER JOIN mart.SiteAuditType AS b ON a.SiteAuditTypeId = b.SiteAuditTypeId
    WHERE
        b.SiteAuditTypeId IS NULL;

    PRINT 'INSERT mart.SiteAuditType, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
