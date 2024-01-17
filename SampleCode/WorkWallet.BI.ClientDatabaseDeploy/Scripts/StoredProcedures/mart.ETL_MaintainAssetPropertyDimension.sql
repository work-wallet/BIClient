DROP PROCEDURE IF EXISTS mart.ETL_MaintainAssetPropertyDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainAssetPropertyDimension @assetPropertyTable mart.ETL_AssetPropertyTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

	WITH src
	AS
	(
		SELECT DISTINCT
			apt.AssetPropertyType_key
			,a.Property
			,w.Wallet_key
		FROM @assetPropertyTable AS a
		INNER JOIN mart.AssetPropertyType AS apt ON a.PropertyType = apt.AssetPropertyType
		INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
	)
	MERGE mart.AssetProperty AS tgt
	USING
		src ON
			tgt.AssetPropertyType_key = src.AssetPropertyType_key
			AND tgt.Property = src.Property
			AND tgt.Wallet_key = src.Wallet_key
	WHEN NOT MATCHED
	THEN
		INSERT
		(
			AssetPropertyType_key
			,Property
			,Wallet_key
		)
		VALUES
		(
			src.AssetPropertyType_key
			,src.Property
			,src.Wallet_key
		);

    PRINT 'MERGE mart.AssetProperty, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

END
GO
