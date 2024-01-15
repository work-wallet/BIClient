DROP PROCEDURE IF EXISTS mart.ETL_LoadAssetAssignmentFacts;
GO

CREATE PROCEDURE mart.ETL_LoadAssetAssignmentFacts
    @assetAssignmentTable mart.ETL_AssetAssignmentTable READONLY
AS
BEGIN
    SET NOCOUNT ON;


	WITH cte
	AS
	(
		SELECT DISTINCT
			Asset.Asset_key
			,aa.AssetAssignment_key
			,a.AssignedOn
			,w.Wallet_key
		FROM
			@assetAssignmentTable AS a
			INNER JOIN mart.Asset ON a.AssetId = Asset.AssetId
			INNER JOIN mart.AssetAssignmentType AS aat ON a.AssignmentType = aat.AssetAssignmentType
			INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
			INNER JOIN mart.AssetAssignment AS aa ON
				aat.AssetAssignmentType_key = aa.AssetAssignmentType_key
				AND w.Wallet_key = aa.Wallet_key
				AND
				(
					(
						aat.AssetAssignmentType = N'Site'
						AND a.CompanyId = aa.CompanyId
						AND a.SiteId = aa.SiteId
					)
					OR
					(
						aat.AssetAssignmentType <> N'Site'
						AND a.AssignedTo = aa.AssignedTo
					)
				)
				AND a.WalletId = w.WalletId
	)
	INSERT INTO mart.AssetAssignmentFact
    (
		Asset_key
		,AssetAssignment_key
		,AssignedOn
		,AssignedEnd
		,IsLatest
        ,Wallet_key
    )
	SELECT
		cte.Asset_key
		,cte.AssetAssignment_key
		,cte.AssignedOn
		,LEAD(cte.AssignedOn) OVER (PARTITION BY cte.Asset_key ORDER BY cte.AssignedOn) AS AssignedEnd
		,CASE WHEN ROW_NUMBER() OVER (PARTITION BY cte.Asset_key ORDER BY cte.AssignedOn DESC) = 1 THEN 1 ELSE 0 END AS IsLatest
		,cte.Wallet_key
	FROM
		cte;

    PRINT 'INSERT mart.AssetAssignmentFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
