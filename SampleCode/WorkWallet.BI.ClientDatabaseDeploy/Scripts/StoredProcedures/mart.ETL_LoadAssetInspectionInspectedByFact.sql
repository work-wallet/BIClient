DROP PROCEDURE IF EXISTS mart.ETL_LoadAssetInspectionInspectedByFact;
GO

CREATE PROCEDURE mart.ETL_LoadAssetInspectionInspectedByFact
    @assetInspectionInspectedByTable mart.ETL_AssetInspectionInspectedByTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO mart.AssetInspectionInspectedByFact
    (
        AssetInspection_key
        ,Contact_key
        ,Wallet_key
    )
    SELECT DISTINCT
        i.AssetInspection_key
        ,c.Contact_key
        ,w.Wallet_key
    FROM
        @assetInspectionInspectedByTable AS x
        INNER JOIN mart.AssetInspection AS i ON x.InspectionId = i.InspectionId
        INNER JOIN mart.Contact AS c ON x.ContactId = c.ContactId
        INNER JOIN mart.Wallet AS w ON x.WalletId = w.WalletId;

    PRINT 'INSERT mart.AssetInspectionInspectedByFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
