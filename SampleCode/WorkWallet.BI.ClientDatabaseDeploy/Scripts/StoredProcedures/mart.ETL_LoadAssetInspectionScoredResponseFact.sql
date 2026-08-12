DROP PROCEDURE IF EXISTS mart.ETL_LoadAssetInspectionScoredResponseFact;
GO

CREATE PROCEDURE mart.ETL_LoadAssetInspectionScoredResponseFact
    @assetInspectionScoredResponseTable mart.ETL_AssetInspectionScoredResponseTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO mart.AssetInspectionScoredResponseFact
    (
        AssetInspection_key
        ,AssetInspectionScoredResponse_key
        ,TotalScore
        ,TotalPotentialScore
        ,PercentageScore
        ,Defect
        ,GradingSetOption_key
        ,Wallet_key
    )
    SELECT DISTINCT
        i.AssetInspection_key
        ,o.AssetInspectionScoredResponse_key
        ,x.TotalScore
        ,x.TotalPotentialScore
        ,x.PercentageScore
        ,x.Defect
        ,gso.GradingSetOption_key
        ,w.Wallet_key
    FROM
        @assetInspectionScoredResponseTable AS x
        INNER JOIN mart.AssetInspection AS i ON x.InspectionId = i.InspectionId
        INNER JOIN mart.AssetInspectionScoredResponse AS o ON x.BranchId = o.BranchId AND x.OptionId = o.OptionId
        INNER JOIN mart.GradingSetOption AS gso ON x.GradingSetOptionId = gso.GradingSetOptionId
        INNER JOIN mart.Wallet AS w ON x.WalletId = w.WalletId;

    PRINT 'INSERT mart.AssetInspectionScoredResponseFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
