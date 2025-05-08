DROP PROCEDURE IF EXISTS mart.ETL_MaintainAssetDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainAssetDimension @assetTable mart.ETL_AssetTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.Asset AS target
    USING (
        SELECT
            a.AssetId
            ,a.AssetType
            ,astat.AssetStatus_key
            ,a.Reference
            ,a.[Name]
            ,a.[Description]
            ,a.CreatedOn
            ,w.Wallet_key
        FROM
            @assetTable AS a
            INNER JOIN mart.AssetStatus AS astat ON a.AssetStatusCode = astat.AssetStatusCode
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON target.AssetId = source.AssetId
    WHEN MATCHED AND (
        target.AssetType <> source.AssetType
        OR target.AssetStatus_key <> source.AssetStatus_key
        OR target.Reference <> source.Reference
        OR target.[Name] <> source.[Name]
        OR target.[Description] <> source.[Description]
        OR target.CreatedOn <> source.CreatedOn
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            AssetType = source.AssetType
            ,AssetStatus_key = source.AssetStatus_key
            ,Reference = source.Reference
            ,[Name] = source.[Name]
            ,[Description] = source.[Description]
            ,CreatedOn = source.CreatedOn
            ,Wallet_key = source.Wallet_key
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            AssetId
            ,AssetType
            ,AssetStatus_key
            ,Reference
            ,[Name]
            ,[Description]
            ,CreatedOn
            ,Wallet_key
        ) VALUES (
            source.AssetId
            ,source.AssetType
            ,source.AssetStatus_key
            ,source.Reference
            ,source.[Name]
            ,source.[Description]
            ,source.CreatedOn
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.Asset, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

END
GO
