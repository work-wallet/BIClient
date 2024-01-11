DROP PROCEDURE IF EXISTS mart.ETL_DeleteAssetFacts;
GO

CREATE PROCEDURE mart.ETL_DeleteAssetFacts @assetTable mart.ETL_AssetTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    DELETE mart.AssetPropertyFact
    FROM mart.AssetPropertyFact AS apf
    INNER JOIN mart.Asset ON apf.Asset_key = Asset.Asset_key
    INNER JOIN @assetTable AS a ON Asset.AssetId = a.AssetId;


    PRINT 'DELETE mart.AssetPropertyFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

    DELETE mart.AssetAssignmentFact
    FROM mart.AssetAssignmentFact AS aaf
    INNER JOIN mart.Asset ON aaf.Asset_key = Asset.Asset_key
    INNER JOIN @assetTable AS a ON Asset.AssetId = a.AssetId;

    PRINT 'DELETE mart.AssetAssignmentFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
