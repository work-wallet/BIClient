DROP PROCEDURE IF EXISTS mart.ETL_MaintainAssetDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainAssetDimension @assetTable mart.ETL_AssetTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

	WITH src
	AS
	(
		SELECT
			a.AssetId
			,a.AssetType
			,astat.AssetStatus_key
			,a.Reference
			,a.[Name]
			,a.[Description]
			,a.CreatedOn
			,w.Wallet_key
		FROM @assetTable AS a
		INNER JOIN mart.AssetStatus AS astat ON a.AssetStatusCode = astat.AssetStatusCode
		INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
	)
	MERGE mart.Asset AS tgt
	USING
		src ON tgt.AssetId = src.AssetId
	WHEN MATCHED AND
	(
		tgt.AssetType <> src.AssetType
		OR tgt.Reference <> src.Reference
		OR tgt.[Name] <> src.[Name]
		OR tgt.[Description] <> src.[Description]
		OR tgt.CreatedOn <> src.CreatedOn
		OR tgt.Wallet_key <> src.Wallet_key
	)
	THEN UPDATE
		SET
			AssetType = src.AssetType
			,Reference = src.Reference
			,[Name] = src.[Name]
			,[Description] = src.[Description]
			,CreatedOn = src.CreatedOn
			,Wallet_key = src.Wallet_key
			,_edited = SYSUTCDATETIME()
	WHEN NOT MATCHED
	THEN
		INSERT
		(
			AssetId
			,AssetType
			,AssetStatus_key
			,Reference
			,[Name]
			,[Description]
			,CreatedOn
			,Wallet_key
		)
		VALUES
		(
			src.AssetId
			,src.AssetType
			,src.AssetStatus_key
			,src.Reference
			,src.[Name]
			,src.[Description]
			,src.CreatedOn
			,src.Wallet_key
		);

    PRINT 'MERGE mart.Asset, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

END
GO
