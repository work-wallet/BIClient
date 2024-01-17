DROP PROCEDURE IF EXISTS mart.ETL_MaintainAssetAssignmentDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainAssetAssignmentDimension @assetAssignmentTable mart.ETL_AssetAssignmentTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

	WITH src
	AS
	(
		SELECT DISTINCT
			a.AssignmentType
			,aat.AssetAssignmentType_key
			,a.AssignedTo
			,a.CompanyId
			,a.Company
			,a.SiteId
			,a.[Site]
			,w.Wallet_key
		FROM @assetAssignmentTable AS a
		INNER JOIN mart.AssetAssignmentType AS aat ON a.AssignmentType = aat.AssetAssignmentType
		INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
	)
	MERGE mart.AssetAssignment AS tgt
	USING
		src ON
			tgt.AssetAssignmentType_key = src.AssetAssignmentType_key
			AND tgt.Wallet_key = src.Wallet_key
			AND
			(
				(
					src.AssignmentType = N'Site'
					AND tgt.CompanyId = src.CompanyId
					AND tgt.SiteId = src.SiteId
				)
				OR
				(
					src.AssignmentType <> N'Site'
					AND tgt.AssignedTo = src.AssignedTo
				)
			)
	WHEN MATCHED AND
	(
		src.AssignmentType = N'Site'
		AND
		(
			tgt.AssignedTo <> src.AssignedTo
			OR tgt.Company <> src.Company
			OR tgt.[Site] <> src.[Site]
		)
	)
	THEN UPDATE
		SET
			AssignedTo = src.AssignedTo
			,Company = src.Company
			,[Site] = src.[Site]
			,_edited = SYSUTCDATETIME()
	WHEN NOT MATCHED
	THEN
		INSERT
		(
			AssetAssignmentType_key
			,AssignedTo
			,CompanyId
			,Company
			,SiteId
			,[Site]
			,Wallet_key
		)
		VALUES
		(
			src.AssetAssignmentType_key
			,src.AssignedTo
			,src.CompanyId
			,src.Company
			,src.SiteId
			,src.[Site]
			,src.Wallet_key
		);

    PRINT 'MERGE mart.AssetAssignment, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

END
GO
