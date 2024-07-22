DROP PROCEDURE IF EXISTS mart.ETL_MaintainSiteAuditChecklistDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainSiteAuditChecklistDimension @siteAuditChecklistTable mart.ETL_SiteAuditChecklistTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.SiteAuditChecklist AS target
    USING (
        SELECT
            a.SiteAuditChecklistId,
            a.SiteAuditChecklistVersion,
            a.ChecklistName,
            a.ChecklistDescription,
            a.NumberOfResponseOptions,
            a.ScoringEnabled,
            a.PassStatus,
            a.ChecklistWeighting,
            a.FailedItemScoring,
            a.FailedItemsCountTowardsAverageScore,
            a.FailedItemsSetTheChecklistScoreToZero,
            w.Wallet_key
        FROM
            @siteAuditChecklistTable AS a
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON
        target.SiteAuditChecklistId = source.SiteAuditChecklistId
        AND target.SiteAuditChecklistVersion = source.SiteAuditChecklistVersion
    WHEN MATCHED AND (
        source.ChecklistName <> target.ChecklistName OR
        source.ChecklistDescription <> target.ChecklistDescription OR
        source.NumberOfResponseOptions <> target.NumberOfResponseOptions OR
        source.ScoringEnabled <> target.ScoringEnabled OR
        source.PassStatus <> target.PassStatus OR
        source.ChecklistWeighting <> target.ChecklistWeighting OR
        source.FailedItemScoring <> target.FailedItemScoring OR
        source.FailedItemsCountTowardsAverageScore <> target.FailedItemsCountTowardsAverageScore OR
        source.FailedItemsSetTheChecklistScoreToZero <> target.FailedItemsSetTheChecklistScoreToZero OR
        source.Wallet_key <> target.Wallet_key
    ) THEN
        UPDATE SET
            ChecklistName = source.ChecklistName,
            ChecklistDescription = source.ChecklistDescription,
            NumberOfResponseOptions = source.NumberOfResponseOptions,
            ScoringEnabled = source.ScoringEnabled,
            PassStatus = source.PassStatus,
            ChecklistWeighting = source.ChecklistWeighting,
            FailedItemScoring = source.FailedItemScoring,
            FailedItemsCountTowardsAverageScore = source.FailedItemsCountTowardsAverageScore,
            FailedItemsSetTheChecklistScoreToZero = source.FailedItemsSetTheChecklistScoreToZero,
            Wallet_key = source.Wallet_key,
            _edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            SiteAuditChecklistId,
            SiteAuditChecklistVersion,
            ChecklistName,
            ChecklistDescription,
            NumberOfResponseOptions,
            ScoringEnabled,
            PassStatus,
            ChecklistWeighting,
            FailedItemScoring,
            FailedItemsCountTowardsAverageScore,
            FailedItemsSetTheChecklistScoreToZero,
            Wallet_key
        ) VALUES (
            source.SiteAuditChecklistId,
            source.SiteAuditChecklistVersion,
            source.ChecklistName,
            source.ChecklistDescription,
            source.NumberOfResponseOptions,
            source.ScoringEnabled,
            source.PassStatus,
            source.ChecklistWeighting,
            source.FailedItemScoring,
            source.FailedItemsCountTowardsAverageScore,
            source.FailedItemsSetTheChecklistScoreToZero,
            source.Wallet_key
        );

    PRINT 'MERGE mart.SiteAuditChecklist, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
