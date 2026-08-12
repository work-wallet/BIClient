DROP PROCEDURE IF EXISTS mart.ETL_LoadAssetInspectionScoreTagFact;
GO

CREATE PROCEDURE mart.ETL_LoadAssetInspectionScoreTagFact
    @assetInspectionScoreTagTable mart.ETL_AssetInspectionScoreTagTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO mart.AssetInspectionScoreTagFact
    (
        AssetInspection_key
        ,AssetInspectionScoreTag_key
        ,TotalScore
        ,TotalPotentialScore
        ,AverageScore
        ,AveragePotentialScore
        ,PercentageScore
        ,Defects
        ,GradingSetOption_key
        ,Wallet_key
    )
    SELECT DISTINCT
        i.AssetInspection_key
        ,t.AssetInspectionScoreTag_key
        ,x.TotalScore
        ,x.TotalPotentialScore
        ,x.AverageScore
        ,x.AveragePotentialScore
        ,x.PercentageScore
        ,x.Defects
        ,gso.GradingSetOption_key
        ,w.Wallet_key
    FROM
        @assetInspectionScoreTagTable AS x
        INNER JOIN mart.AssetInspection AS i ON x.InspectionId = i.InspectionId
        INNER JOIN mart.AssetInspectionScoreTag AS t ON x.TagId = t.TagId AND x.TagVersion = t.TagVersion
        INNER JOIN mart.GradingSetOption AS gso ON x.GradingSetOptionId = gso.GradingSetOptionId
        INNER JOIN mart.Wallet AS w ON x.WalletId = w.WalletId;

    PRINT 'INSERT mart.AssetInspectionScoreTagFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
