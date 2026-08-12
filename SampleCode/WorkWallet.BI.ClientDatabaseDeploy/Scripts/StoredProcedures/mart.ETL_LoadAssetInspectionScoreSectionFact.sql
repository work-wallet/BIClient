DROP PROCEDURE IF EXISTS mart.ETL_LoadAssetInspectionScoreSectionFact;
GO

CREATE PROCEDURE mart.ETL_LoadAssetInspectionScoreSectionFact
    @assetInspectionScoreSectionTable mart.ETL_AssetInspectionScoreSectionTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO mart.AssetInspectionScoreSectionFact
    (
        AssetInspection_key
        ,AssetInspectionScoreSection_key
        ,TotalScore
        ,TotalPotentialScore
        ,AverageScore
        ,AveragePotentialScore
        ,PercentageScore
        ,Defects
        ,Passed
        ,GradingSetOption_key
        ,Wallet_key
    )
    SELECT DISTINCT
        i.AssetInspection_key
        ,s.AssetInspectionScoreSection_key
        ,x.TotalScore
        ,x.TotalPotentialScore
        ,x.AverageScore
        ,x.AveragePotentialScore
        ,x.PercentageScore
        ,x.Defects
        ,x.Passed
        ,gso.GradingSetOption_key
        ,w.Wallet_key
    FROM
        @assetInspectionScoreSectionTable AS x
        INNER JOIN mart.AssetInspection AS i ON x.InspectionId = i.InspectionId
        INNER JOIN mart.AssetInspectionScoreSection AS s ON i.AssetInspectionType_key = s.AssetInspectionType_key AND x.SectionId = s.SectionId
        INNER JOIN mart.GradingSetOption AS gso ON x.GradingSetOptionId = gso.GradingSetOptionId
        INNER JOIN mart.Wallet AS w ON x.WalletId = w.WalletId;

    PRINT 'INSERT mart.AssetInspectionScoreSectionFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
