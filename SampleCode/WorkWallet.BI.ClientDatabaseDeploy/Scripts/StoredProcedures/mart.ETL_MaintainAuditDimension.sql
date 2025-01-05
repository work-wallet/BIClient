DROP PROCEDURE IF EXISTS mart.ETL_MaintainAuditDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainAuditDimension @AuditTable mart.ETL_AuditTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.[Audit] AS target
    USING (
        SELECT
            a.AuditId,
            a.Reference,
            a.AuditReference,
            g.AuditGroup_key,
            s.AuditStatus_key,
            t.AuditType_key,
            ol.Location_key,
            a.InspectedOn,
            a.[Description],
            a.TotalScore,
            a.TotalPotentialScore,
            a.AverageScore,
            a.AveragePotentialScore,
            a.PercentageScore,
            a.Flags,
            a.GradingSetOption,
            a.ExternalIdentifier,
            w.Wallet_key
        FROM
            @AuditTable AS a
            INNER JOIN mart.AuditStatus AS s ON a.AuditStatusCode = s.AuditStatusCode
            INNER JOIN mart.AuditType AS t ON a.AuditTypeId = t.AuditTypeId AND a.AuditTypeVersion = t.AuditTypeVersion
            INNER JOIN mart.[Location] AS ol ON a.LocationId = ol.LocationId
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
            INNER JOIN mart.AuditGroup AS g ON w.Wallet_key = g.Wallet_key AND a.AuditGroup = g.AuditGroup
    ) AS source
    ON target.AuditId = source.AuditId
    WHEN MATCHED AND (
        target.Reference <> source.Reference
        OR target.AuditReference <> source.AuditReference
        OR target.AuditGroup_key <> source.AuditGroup_key
        OR target.AuditStatus_key <> source.AuditStatus_key
        OR target.AuditType_key <> source.AuditType_key
        OR target.Location_key <> source.Location_key
        OR target.InspectedOn <> source.InspectedOn
        OR target.[Description] <> source.[Description]
        OR target.TotalScore <> source.TotalScore
        OR target.TotalPotentialScore <> source.TotalPotentialScore
        OR target.AverageScore <> source.AverageScore
        OR target.AveragePotentialScore <> source.AveragePotentialScore
        OR target.PercentageScore <> source.PercentageScore
        OR target.Flags <> source.Flags
        OR target.GradingSetOption <> source.GradingSetOption
        OR target.ExternalIdentifier <> source.ExternalIdentifier
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            Reference = source.Reference,
            AuditReference = source.AuditReference,
            AuditGroup_key = source.AuditGroup_key,
            AuditStatus_key = source.AuditStatus_key,
            AuditType_key = source.AuditType_key,
            Location_key = source.Location_key,
            InspectedOn = source.InspectedOn,
            [Description] = source.[Description],
            TotalScore = source.TotalScore,
            TotalPotentialScore = source.TotalPotentialScore,
            AverageScore = source.AverageScore,
            AveragePotentialScore = source.AveragePotentialScore,
            PercentageScore = source.PercentageScore,
            Flags = source.Flags,
            GradingSetOption = source.GradingSetOption,
            ExternalIdentifier = source.ExternalIdentifier,
            Wallet_key = source.Wallet_key,
            _edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            AuditId,
            Reference,
            AuditReference,
            AuditGroup_key,
            AuditStatus_key,
            AuditType_key,
            Location_key,
            InspectedOn,
            [Description],
            TotalScore,
            TotalPotentialScore,
            AverageScore,
            AveragePotentialScore,
            PercentageScore,
            Flags,
            GradingSetOption,
            ExternalIdentifier,
            Wallet_key
        ) VALUES (
            source.AuditId,
            source.Reference,
            source.AuditReference,
            source.AuditGroup_key,
            source.AuditStatus_key,
            source.AuditType_key,
            source.Location_key,
            source.InspectedOn,
            source.[Description],
            source.TotalScore,
            source.TotalPotentialScore,
            source.AverageScore,
            source.AveragePotentialScore,
            source.PercentageScore,
            source.Flags,
            source.GradingSetOption,
            source.ExternalIdentifier,
            source.Wallet_key
        );

    PRINT 'MERGE mart.Audit, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
