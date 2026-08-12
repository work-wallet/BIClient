DROP PROCEDURE IF EXISTS mart.ETL_MaintainAssetInspectionDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainAssetInspectionDimension @inspectionTable mart.ETL_AssetInspectionTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.AssetInspection AS target
    USING (
        SELECT
            i.InspectionId
            ,a.Asset_key
            ,s.AssetInspectionStatus_key
            ,t.AssetInspectionType_key
            ,i.InspectedOn
            ,i.TotalScore
            ,i.TotalPotentialScore
            ,i.AverageScore
            ,i.AveragePotentialScore
            ,i.PercentageScore
            ,i.Defects
            ,i.Passed
            ,gso.GradingSetOption_key
            ,i.ExternalIdentifier
            ,i.InspectedByCompany
            ,i.InProgressStatusDate
            ,i.ReadyForReviewStatusDate
            ,i.CompleteStatusDate
            ,i.ArchivedStatusDate
            ,w.Wallet_key
        FROM
            @inspectionTable AS i
            INNER JOIN mart.Asset AS a ON i.AssetId = a.AssetId
            INNER JOIN mart.AssetInspectionStatus AS s ON i.InspectionStatusCode = s.InspectionStatusCode
            INNER JOIN mart.AssetInspectionType AS t ON i.InspectionTypeId = t.InspectionTypeId AND i.InspectionTypeVersion = t.InspectionTypeVersion
            INNER JOIN mart.GradingSetOption AS gso ON i.GradingSetOptionId = gso.GradingSetOptionId
            INNER JOIN mart.Wallet AS w ON i.WalletId = w.WalletId
    ) AS source
    ON target.InspectionId = source.InspectionId
    WHEN MATCHED AND (
        target.Asset_key <> source.Asset_key
        OR target.AssetInspectionStatus_key <> source.AssetInspectionStatus_key
        OR target.AssetInspectionType_key <> source.AssetInspectionType_key
        OR target.InspectedOn <> source.InspectedOn
        OR target.TotalScore <> source.TotalScore
        OR target.TotalPotentialScore <> source.TotalPotentialScore
        OR target.AverageScore <> source.AverageScore
        OR target.AveragePotentialScore <> source.AveragePotentialScore
        OR target.PercentageScore <> source.PercentageScore
        OR target.Defects <> source.Defects
        OR target.Passed <> source.Passed
        OR target.GradingSetOption_key <> source.GradingSetOption_key
        OR target.ExternalIdentifier <> source.ExternalIdentifier
        OR target.InspectedByCompany <> source.InspectedByCompany
        OR target.InProgressStatusDate IS DISTINCT FROM source.InProgressStatusDate
        OR target.ReadyForReviewStatusDate IS DISTINCT FROM source.ReadyForReviewStatusDate
        OR target.CompleteStatusDate IS DISTINCT FROM source.CompleteStatusDate
        OR target.ArchivedStatusDate IS DISTINCT FROM source.ArchivedStatusDate
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            Asset_key = source.Asset_key
            ,AssetInspectionStatus_key = source.AssetInspectionStatus_key
            ,AssetInspectionType_key = source.AssetInspectionType_key
            ,InspectedOn = source.InspectedOn
            ,TotalScore = source.TotalScore
            ,TotalPotentialScore = source.TotalPotentialScore
            ,AverageScore = source.AverageScore
            ,AveragePotentialScore = source.AveragePotentialScore
            ,PercentageScore = source.PercentageScore
            ,Defects = source.Defects
            ,Passed = source.Passed
            ,GradingSetOption_key = source.GradingSetOption_key
            ,ExternalIdentifier = source.ExternalIdentifier
            ,InspectedByCompany = source.InspectedByCompany
            ,InProgressStatusDate = source.InProgressStatusDate
            ,ReadyForReviewStatusDate = source.ReadyForReviewStatusDate
            ,CompleteStatusDate = source.CompleteStatusDate
            ,ArchivedStatusDate = source.ArchivedStatusDate
            ,Wallet_key = source.Wallet_key
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            InspectionId
            ,Asset_key
            ,AssetInspectionStatus_key
            ,AssetInspectionType_key
            ,InspectedOn
            ,TotalScore
            ,TotalPotentialScore
            ,AverageScore
            ,AveragePotentialScore
            ,PercentageScore
            ,Defects
            ,Passed
            ,GradingSetOption_key
            ,ExternalIdentifier
            ,InspectedByCompany
            ,InProgressStatusDate
            ,ReadyForReviewStatusDate
            ,CompleteStatusDate
            ,ArchivedStatusDate
            ,Wallet_key
        ) VALUES (
            source.InspectionId
            ,source.Asset_key
            ,source.AssetInspectionStatus_key
            ,source.AssetInspectionType_key
            ,source.InspectedOn
            ,source.TotalScore
            ,source.TotalPotentialScore
            ,source.AverageScore
            ,source.AveragePotentialScore
            ,source.PercentageScore
            ,source.Defects
            ,source.Passed
            ,source.GradingSetOption_key
            ,source.ExternalIdentifier
            ,source.InspectedByCompany
            ,source.InProgressStatusDate
            ,source.ReadyForReviewStatusDate
            ,source.CompleteStatusDate
            ,source.ArchivedStatusDate
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.AssetInspection, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
