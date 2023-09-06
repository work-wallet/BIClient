DROP PROCEDURE IF EXISTS mart.ETL_LoadSiteAuditChecklistFact;
GO

CREATE PROCEDURE mart.ETL_LoadSiteAuditChecklistFact @siteAuditChecklistFactTable mart.ETL_SiteAuditChecklistFactTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    -- insert missing entries
    INSERT INTO mart.SiteAuditChecklistFact
    (
        -- keys
        SiteAudit_key
        ,SiteAuditChecklist_key
        ,SiteAuditType_key
        ,Location_key
        ,SiteAuditStatus_key
        ,Wallet_key
        -- facts
        ,HasScore
        ,Score
        ,PotentialScore
        ,[Percent]
        ,PassFailStatus
        ,Passed
        ,PassScore
    )
    SELECT
        -- keys
        sa.SiteAudit_key
        ,sac.SiteAuditChecklist_key
        ,sat.SiteAuditType_key
        ,ol.Location_key
        ,sas.SiteAuditStatus_key
        ,w.Wallet_key
        -- facts
        ,a.HasScore
        ,a.Score
        ,a.PotentialScore
        ,a.[Percent]
        ,a.PassFailStatus
        ,a.Passed
        ,a.PassScore
    FROM
        @siteAuditChecklistFactTable AS a
        INNER JOIN mart.SiteAudit sa ON a.SiteAuditId = sa.SiteAuditId
        INNER JOIN mart.SiteAuditStatus AS sas ON a.SiteAuditStatusCode = sas.SiteAuditStatusCode
        INNER JOIN mart.SiteAuditType AS sat ON a.SiteAuditTypeId = sat.SiteAuditTypeId
        INNER JOIN mart.SiteAuditChecklist AS sac ON a.SiteAuditChecklistId = sac.SiteAuditChecklistId AND a.SiteAuditChecklistVersion = sac.SiteAuditChecklistVersion
        INNER JOIN mart.[Location] AS ol ON a.LocationId = ol.LocationId
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId;

    PRINT 'INSERT mart.SiteAuditChecklistFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
