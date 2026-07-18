DROP PROCEDURE IF EXISTS mart.ETL_MaintainAuditDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainAuditDimension @auditTable mart.ETL_AuditTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.[Audit] AS target
    USING (
        SELECT
            a.AuditId
            ,a.Reference
            ,a.AuditReference
            ,g.AuditGroup_key
            ,s.AuditStatus_key
            ,t.AuditType_key
            ,ol.Location_key
            ,a.InspectedOn
            ,a.TotalScore
            ,a.TotalPotentialScore
            ,a.AverageScore
            ,a.AveragePotentialScore
            ,a.PercentageScore
            ,a.Flags
            ,gso.GradingSetOption_key
            ,a.ExternalIdentifier
            ,a.PlannedStatusDate
            ,a.ReportInProgressStatusDate
            ,a.ReadyForReviewStatusDate
            ,a.CompleteStatusDate
            ,a.ClosedStatusDate
            ,w.Wallet_key
        FROM
            @auditTable AS a
            INNER JOIN mart.AuditGroup AS g ON a.AuditGroupId = g.AuditGroupId
            INNER JOIN mart.AuditStatus AS s ON a.AuditStatusCode = s.AuditStatusCode
            INNER JOIN mart.AuditType AS t ON a.AuditTypeId = t.AuditTypeId AND a.AuditTypeVersion = t.AuditTypeVersion
            INNER JOIN mart.[Location] AS ol ON a.LocationId = ol.LocationId
            INNER JOIN mart.GradingSetOption AS gso ON a.GradingSetOptionId = gso.GradingSetOptionId
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
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
        OR target.TotalScore <> source.TotalScore
        OR target.TotalPotentialScore <> source.TotalPotentialScore
        OR target.AverageScore <> source.AverageScore
        OR target.AveragePotentialScore <> source.AveragePotentialScore
        OR target.PercentageScore <> source.PercentageScore
        OR target.Flags <> source.Flags
        OR target.GradingSetOption_key <> source.GradingSetOption_key
        OR target.ExternalIdentifier <> source.ExternalIdentifier
        OR target.PlannedStatusDate IS DISTINCT FROM source.PlannedStatusDate
        OR target.ReportInProgressStatusDate IS DISTINCT FROM source.ReportInProgressStatusDate
        OR target.ReadyForReviewStatusDate IS DISTINCT FROM source.ReadyForReviewStatusDate
        OR target.CompleteStatusDate IS DISTINCT FROM source.CompleteStatusDate
        OR target.ClosedStatusDate IS DISTINCT FROM source.ClosedStatusDate
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            Reference = source.Reference
            ,AuditReference = source.AuditReference
            ,AuditGroup_key = source.AuditGroup_key
            ,AuditStatus_key = source.AuditStatus_key
            ,AuditType_key = source.AuditType_key
            ,Location_key = source.Location_key
            ,InspectedOn = source.InspectedOn
            ,TotalScore = source.TotalScore
            ,TotalPotentialScore = source.TotalPotentialScore
            ,AverageScore = source.AverageScore
            ,AveragePotentialScore = source.AveragePotentialScore
            ,PercentageScore = source.PercentageScore
            ,Flags = source.Flags
            ,GradingSetOption_key = source.GradingSetOption_key
            ,ExternalIdentifier = source.ExternalIdentifier
            ,PlannedStatusDate = source.PlannedStatusDate
            ,ReportInProgressStatusDate = source.ReportInProgressStatusDate
            ,ReadyForReviewStatusDate = source.ReadyForReviewStatusDate
            ,CompleteStatusDate = source.CompleteStatusDate
            ,ClosedStatusDate = source.ClosedStatusDate
            ,Wallet_key = source.Wallet_key
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            AuditId
            ,Reference
            ,AuditReference
            ,AuditGroup_key
            ,AuditStatus_key
            ,AuditType_key
            ,Location_key
            ,InspectedOn
            ,TotalScore
            ,TotalPotentialScore
            ,AverageScore
            ,AveragePotentialScore
            ,PercentageScore
            ,Flags
            ,GradingSetOption_key
            ,ExternalIdentifier
            ,PlannedStatusDate
            ,ReportInProgressStatusDate
            ,ReadyForReviewStatusDate
            ,CompleteStatusDate
            ,ClosedStatusDate
            ,Wallet_key
        ) VALUES (
            source.AuditId
            ,source.Reference
            ,source.AuditReference
            ,source.AuditGroup_key
            ,source.AuditStatus_key
            ,source.AuditType_key
            ,source.Location_key
            ,source.InspectedOn
            ,source.TotalScore
            ,source.TotalPotentialScore
            ,source.AverageScore
            ,source.AveragePotentialScore
            ,source.PercentageScore
            ,source.Flags
            ,source.GradingSetOption_key
            ,source.ExternalIdentifier
            ,source.PlannedStatusDate
            ,source.ReportInProgressStatusDate
            ,source.ReadyForReviewStatusDate
            ,source.CompleteStatusDate
            ,source.ClosedStatusDate
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.Audit, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
