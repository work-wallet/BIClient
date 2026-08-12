DROP PROCEDURE IF EXISTS mart.ETL_LoadAssetInspectionNumericAnswerFact;
GO

CREATE PROCEDURE mart.ETL_LoadAssetInspectionNumericAnswerFact
    @assetInspectionNumericAnswerTable mart.ETL_AssetInspectionNumericAnswerTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO mart.AssetInspectionNumericAnswerFact
    (
        AssetInspection_key
        ,AssetInspectionNumericQuestion_key
        ,Answer
        ,Wallet_key
    )
    SELECT DISTINCT
        i.AssetInspection_key
        ,q.AssetInspectionNumericQuestion_key
        ,x.Answer
        ,w.Wallet_key
    FROM
        @assetInspectionNumericAnswerTable AS x
        INNER JOIN mart.AssetInspection AS i ON x.InspectionId = i.InspectionId
        INNER JOIN mart.AssetInspectionNumericQuestion AS q ON x.QuestionId = q.QuestionId
        INNER JOIN mart.Wallet AS w ON x.WalletId = w.WalletId;

    PRINT 'INSERT mart.AssetInspectionNumericAnswerFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
