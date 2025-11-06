DROP PROCEDURE IF EXISTS mart.ETL_MaintainAssetInspectionPropertyDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainAssetInspectionPropertyDimension @inspectionPropertyTable mart.ETL_AssetInspectionPropertyTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.AssetInspectionProperty AS target
    USING (
        SELECT DISTINCT
            apt.AssetPropertyType_key
            ,ip.Property
            ,w.Wallet_key
        FROM
            @inspectionPropertyTable AS ip
            INNER JOIN mart.AssetPropertyType AS apt ON ip.PropertyType = apt.AssetPropertyType
            INNER JOIN mart.Wallet AS w ON ip.WalletId = w.WalletId
    ) AS source
    ON
        target.AssetPropertyType_key = source.AssetPropertyType_key
        AND target.Property = source.Property
        AND target.Wallet_key = source.Wallet_key
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            AssetPropertyType_key
            ,Property
            ,Wallet_key
        ) VALUES (
            source.AssetPropertyType_key
            ,source.Property
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.AssetInspectionProperty, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

END
GO
