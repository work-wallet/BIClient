DROP PROCEDURE IF EXISTS mart.ETL_LoadAssetInspectionPropertyFact;
GO

CREATE PROCEDURE mart.ETL_LoadAssetInspectionPropertyFact @inspectionPropertyTable mart.ETL_AssetInspectionPropertyTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO mart.AssetInspectionPropertyFact
    (
        AssetInspection_key
        ,AssetInspectionProperty_key
        ,[Value]
        ,Wallet_key
    )
    SELECT
        ai.AssetInspection_key
        ,aip.AssetInspectionProperty_key
        ,ip.[Value]
        ,w.Wallet_key
    FROM
        @inspectionPropertyTable AS ip
        INNER JOIN mart.AssetInspection AS ai ON ip.InspectionId = ai.InspectionId
        INNER JOIN mart.AssetPropertyType AS apt ON ip.PropertyType = apt.AssetPropertyType
        INNER JOIN mart.Wallet AS w ON ip.WalletId = w.WalletId
        INNER JOIN mart.AssetInspectionProperty AS aip ON aip.Property = ip.Property AND aip.AssetPropertyType_key = apt.AssetPropertyType_key AND aip.Wallet_key = w.Wallet_key;

    PRINT 'INSERT INTO mart.AssetInspectionPropertyFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

END
GO
