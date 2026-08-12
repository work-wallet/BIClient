DROP PROCEDURE IF EXISTS mart.ETL_MaintainAssetInspectionTypeDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainAssetInspectionTypeDimension @assetInspectionTypeTable mart.ETL_AssetInspectionTypeTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.AssetInspectionType AS target
    USING (
        SELECT
            a.InspectionTypeId
            ,a.InspectionTypeVersion
            ,a.InspectionType
            ,a.[Description]
            ,a.ScoringEnabled
            ,a.DisplayPercentage
            ,a.DisplayTotalScore
            ,a.DisplayAverageScore
            ,a.GradingSetId
            ,a.GradingSetVersion
            ,a.GradingSet
            ,a.GradingSetIsPercentage
            ,a.GradingSetIsScore
            ,w.Wallet_key
        FROM
            @assetInspectionTypeTable AS a
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON target.InspectionTypeId = source.InspectionTypeId AND target.InspectionTypeVersion = source.InspectionTypeVersion
    WHEN MATCHED AND (
        target.InspectionType <> source.InspectionType
        OR target.[Description] <> source.[Description]
        OR target.ScoringEnabled <> source.ScoringEnabled
        OR target.DisplayPercentage <> source.DisplayPercentage
        OR target.DisplayTotalScore <> source.DisplayTotalScore
        OR target.DisplayAverageScore <> source.DisplayAverageScore
        OR target.GradingSetId <> source.GradingSetId
        OR target.GradingSetVersion <> source.GradingSetVersion
        OR target.GradingSet <> source.GradingSet
        OR target.GradingSetIsPercentage <> source.GradingSetIsPercentage
        OR target.GradingSetIsScore <> source.GradingSetIsScore
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            InspectionType = source.InspectionType
            ,[Description] = source.[Description]
            ,ScoringEnabled = source.ScoringEnabled
            ,DisplayPercentage = source.DisplayPercentage
            ,DisplayTotalScore = source.DisplayTotalScore
            ,DisplayAverageScore = source.DisplayAverageScore
            ,GradingSetId = source.GradingSetId
            ,GradingSetVersion = source.GradingSetVersion
            ,GradingSet = source.GradingSet
            ,GradingSetIsPercentage = source.GradingSetIsPercentage
            ,GradingSetIsScore = source.GradingSetIsScore
            ,Wallet_key = source.Wallet_key
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            InspectionTypeId
            ,InspectionTypeVersion
            ,InspectionType
            ,[Description]
            ,ScoringEnabled
            ,DisplayPercentage
            ,DisplayTotalScore
            ,DisplayAverageScore
            ,GradingSetId
            ,GradingSetVersion
            ,GradingSet
            ,GradingSetIsPercentage
            ,GradingSetIsScore
            ,Wallet_key
        ) VALUES (
            source.InspectionTypeId
            ,source.InspectionTypeVersion
            ,source.InspectionType
            ,source.[Description]
            ,source.ScoringEnabled
            ,source.DisplayPercentage
            ,source.DisplayTotalScore
            ,source.DisplayAverageScore
            ,source.GradingSetId
            ,source.GradingSetVersion
            ,source.GradingSet
            ,source.GradingSetIsPercentage
            ,source.GradingSetIsScore
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.AssetInspectionType, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
