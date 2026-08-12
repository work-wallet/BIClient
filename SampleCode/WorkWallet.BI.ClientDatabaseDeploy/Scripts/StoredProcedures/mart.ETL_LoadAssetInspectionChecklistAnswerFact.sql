DROP PROCEDURE IF EXISTS mart.ETL_LoadAssetInspectionChecklistAnswerFact;
GO

CREATE PROCEDURE mart.ETL_LoadAssetInspectionChecklistAnswerFact
    @assetInspectionChecklistAnswerTable mart.ETL_AssetInspectionChecklistAnswerTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO mart.AssetInspectionChecklistAnswerFact
    (
        AssetInspection_key
        ,AssetInspectionChecklistOption_key
        ,Wallet_key
    )
    SELECT DISTINCT
        i.AssetInspection_key
        ,o.AssetInspectionChecklistOption_key
        ,w.Wallet_key
    FROM
        @assetInspectionChecklistAnswerTable AS x
        INNER JOIN mart.AssetInspection AS i ON x.InspectionId = i.InspectionId
        INNER JOIN mart.AssetInspectionChecklistOption AS o ON x.ChecklistId = o.ChecklistId AND x.OptionId = o.OptionId
        INNER JOIN mart.Wallet AS w ON x.WalletId = w.WalletId;

    PRINT 'INSERT mart.AssetInspectionChecklistAnswerFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
