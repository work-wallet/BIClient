DROP PROCEDURE IF EXISTS mart.ETL_LoadAssetInspectionDateTimeAnswerFact;
GO

CREATE PROCEDURE mart.ETL_LoadAssetInspectionDateTimeAnswerFact
    @assetInspectionDateTimeAnswerTable mart.ETL_AssetInspectionDateTimeAnswerTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO mart.AssetInspectionDateTimeAnswerFact
    (
        AssetInspection_key
        ,AssetInspectionDateTimeQuestion_key
        ,AnswerDateTime
        ,AnswerDate
        ,AnswerTime
        ,Wallet_key
    )
    SELECT DISTINCT
        i.AssetInspection_key
        ,q.AssetInspectionDateTimeQuestion_key
        ,CASE WHEN q.[Date] = 1 AND q.[Time] = 1 THEN CAST(x.Answer AS smalldatetime) END AS AnswerDateTime
        ,CASE WHEN q.[Date] = 1 THEN CAST(x.Answer AS date) END AS AnswerDate
        ,CASE WHEN q.[Time] = 1 THEN CAST(x.Answer AS time(0)) END AS AnswerTime
        ,w.Wallet_key
    FROM
        @assetInspectionDateTimeAnswerTable AS x
        INNER JOIN mart.AssetInspection AS i ON x.InspectionId = i.InspectionId
        INNER JOIN mart.AssetInspectionDateTimeQuestion AS q ON x.QuestionId = q.QuestionId
        INNER JOIN mart.Wallet AS w ON x.WalletId = w.WalletId;

    PRINT 'INSERT mart.AssetInspectionDateTimeAnswerFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
