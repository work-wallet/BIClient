DROP PROCEDURE IF EXISTS mart.ETL_MaintainAssetAssignmentDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainAssetAssignmentDimension @assetAssignmentTable mart.ETL_AssetAssignmentTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

	MERGE mart.AssetAssignment AS target
	USING (
		SELECT DISTINCT
			a.AssignmentType
			,aat.AssetAssignmentType_key
			,a.AssignedTo
			,a.CompanyId
			,a.Company
			,a.SiteId
			,a.[Site]
			,w.Wallet_key
		FROM
			@assetAssignmentTable AS a
			INNER JOIN mart.AssetAssignmentType AS aat ON a.AssignmentType = aat.AssetAssignmentType
			INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
	) AS source
	ON
		target.AssetAssignmentType_key = source.AssetAssignmentType_key
		AND target.Wallet_key = source.Wallet_key
		AND
		(
			(
				source.AssignmentType = N'Site'
				AND target.CompanyId = source.CompanyId
				AND target.SiteId = source.SiteId
			)
			OR
			(
				source.AssignmentType <> N'Site'
				AND target.AssignedTo = source.AssignedTo
			)
		)
	WHEN MATCHED AND (
		source.AssignmentType = N'Site'
		AND
		(
			target.AssignedTo <> source.AssignedTo
			OR target.Company <> source.Company
			OR target.[Site] <> source.[Site]
		)
	)
	THEN
		UPDATE SET
			AssignedTo = source.AssignedTo
			,Company = source.Company
			,[Site] = source.[Site]
			,_edited = SYSUTCDATETIME()
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			AssetAssignmentType_key
			,AssignedTo
			,CompanyId
			,Company
			,SiteId
			,[Site]
			,Wallet_key
		) VALUES (
			source.AssetAssignmentType_key
			,source.AssignedTo
			,source.CompanyId
			,source.Company
			,source.SiteId
			,source.[Site]
			,source.Wallet_key
		);

    PRINT 'MERGE mart.AssetAssignment, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

END
GO
