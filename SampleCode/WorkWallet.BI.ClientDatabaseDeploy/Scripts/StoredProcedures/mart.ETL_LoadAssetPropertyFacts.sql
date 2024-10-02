DROP PROCEDURE IF EXISTS mart.ETL_LoadAssetPropertyFacts;
GO

CREATE PROCEDURE mart.ETL_LoadAssetPropertyFacts
    @assetPropertyTable mart.ETL_AssetPropertyTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO mart.AssetPropertyFact
    (
        Asset_key
        ,AssetProperty_key
        ,[Value]
        ,Wallet_key
    )
    SELECT DISTINCT
        Asset.Asset_key
        ,ap.AssetProperty_key
        ,a.[Value]
        ,w.Wallet_key
    FROM
        @assetPropertyTable AS a
        INNER JOIN mart.Asset ON a.AssetId = Asset.AssetId
        INNER JOIN mart.AssetPropertyType AS apt ON a.PropertyType = apt.AssetPropertyType
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        INNER JOIN mart.AssetProperty AS ap ON
            apt.AssetPropertyType_key = ap.AssetPropertyType_key
            AND a.Property = ap.Property
            AND a.WalletId = w.WalletId;

    PRINT 'INSERT mart.AssetPropertyFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
