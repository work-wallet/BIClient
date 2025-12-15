DROP PROCEDURE IF EXISTS mart.ETL_MaintainAssetPropertyDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainAssetPropertyDimension @assetPropertyTable mart.ETL_AssetPropertyTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.AssetProperty AS target
    USING (
        SELECT DISTINCT
            apt.AssetPropertyType_key
            ,a.IsSharedProperty
            ,a.Property
            ,w.Wallet_key
        FROM
            @assetPropertyTable AS a
            INNER JOIN mart.AssetPropertyType AS apt ON a.PropertyType = apt.AssetPropertyType
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON
        target.AssetPropertyType_key = source.AssetPropertyType_key
        AND target.IsSharedProperty = source.IsSharedProperty
        AND target.Property = source.Property
        AND target.Wallet_key = source.Wallet_key
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            AssetPropertyType_key
            ,IsSharedProperty
            ,Property
            ,Wallet_key
        ) VALUES (
            source.AssetPropertyType_key
            ,source.IsSharedProperty
            ,source.Property
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.AssetProperty, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

END
GO
