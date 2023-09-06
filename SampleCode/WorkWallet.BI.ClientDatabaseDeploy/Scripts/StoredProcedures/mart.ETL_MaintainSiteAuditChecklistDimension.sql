DROP PROCEDURE IF EXISTS mart.ETL_MaintainSiteAuditChecklistDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainSiteAuditChecklistDimension @siteAuditChecklistTable mart.ETL_SiteAuditChecklistTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    -- type 1 changes (do first, before inserting new)
    UPDATE mart.SiteAuditChecklist
    SET
        ChecklistName = a.ChecklistName
        ,ChecklistDescription = a.ChecklistDescription
        ,NumberOfResponseOptions = a.NumberOfResponseOptions
        ,ScoringEnabled = a.ScoringEnabled
        ,PassStatus = a.PassStatus
        ,ChecklistWeighting = a.ChecklistWeighting
        ,FailedItemScoring = a.FailedItemScoring
        ,FailedItemsCountTowardsAverageScore = a.FailedItemsCountTowardsAverageScore
        ,FailedItemsSetTheChecklistScoreToZero = a.FailedItemsSetTheChecklistScoreToZero
        ,Wallet_key = w.Wallet_key
        ,_edited = SYSUTCDATETIME()
    FROM
        @siteAuditChecklistTable AS a
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        INNER JOIN mart.SiteAuditChecklist AS b ON a.SiteAuditChecklistId = b.SiteAuditChecklistId AND a.SiteAuditChecklistVersion = b.SiteAuditChecklistVersion
    WHERE /* only where the data has changed */
        a.ChecklistName <> b.ChecklistName
        OR a.ChecklistDescription <> b.ChecklistDescription
        OR a.NumberOfResponseOptions <> b.NumberOfResponseOptions
        OR a.ScoringEnabled <> b.ScoringEnabled
        OR a.PassStatus <> b.PassStatus
        OR a.ChecklistWeighting <> b.ChecklistWeighting
        OR a.FailedItemScoring <> b.FailedItemScoring
        OR a.FailedItemsCountTowardsAverageScore <> b.FailedItemsCountTowardsAverageScore
        OR a.FailedItemsSetTheChecklistScoreToZero <> b.FailedItemsSetTheChecklistScoreToZero
        OR w.Wallet_key <> b.Wallet_key;

    PRINT 'UPDATE mart.SiteAuditChecklist, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

    -- insert missing entries
    INSERT INTO mart.SiteAuditChecklist
    (
        SiteAuditChecklistId
        ,SiteAuditChecklistVersion
        ,ChecklistName
        ,ChecklistDescription
        ,NumberOfResponseOptions
        ,ScoringEnabled
        ,PassStatus
        ,ChecklistWeighting
        ,FailedItemScoring
        ,FailedItemsCountTowardsAverageScore
        ,FailedItemsSetTheChecklistScoreToZero
        ,Wallet_key
    )
    SELECT
        a.SiteAuditChecklistId
        ,a.SiteAuditChecklistVersion
        ,a.ChecklistName
        ,a.ChecklistDescription
        ,a.NumberOfResponseOptions
        ,a.ScoringEnabled
        ,a.PassStatus
        ,a.ChecklistWeighting
        ,a.FailedItemScoring
        ,a.FailedItemsCountTowardsAverageScore
        ,a.FailedItemsSetTheChecklistScoreToZero
        ,w.Wallet_key
    FROM
        @siteAuditChecklistTable AS a
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        LEFT OUTER JOIN mart.SiteAuditChecklist AS b ON a.SiteAuditChecklistId = b.SiteAuditChecklistId AND a.SiteAuditChecklistVersion = b.SiteAuditChecklistVersion
    WHERE
        b.SiteAuditChecklistId IS NULL;

    PRINT 'INSERT mart.SiteAuditChecklist, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
