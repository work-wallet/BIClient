DROP PROCEDURE IF EXISTS mart.ETL_MaintainAssetInspectionDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainAssetInspectionDimension @inspectionTable mart.ETL_AssetInspectionTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.AssetInspection AS target
    USING (
        SELECT
            i.InspectionId
            ,a.Asset_key
            ,i.InspectionTypeId
            ,i.InspectionType
            ,i.InspectionDate
            ,i.InspectedBy
            ,i.Deleted
            ,w.Wallet_key
        FROM
            @inspectionTable AS i
            INNER JOIN mart.Asset AS a ON i.AssetId = a.AssetId
            INNER JOIN mart.Wallet AS w ON i.WalletId = w.WalletId
    ) AS source
    ON target.InspectionId = source.InspectionId
    WHEN MATCHED AND (
        target.Asset_key <> source.Asset_key
        OR target.InspectionTypeId <> source.InspectionTypeId
        OR target.InspectionType <> source.InspectionType
        OR target.InspectionDate <> source.InspectionDate
        OR target.InspectedBy <> source.InspectedBy
        OR target.Deleted <> source.Deleted
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            Asset_key = source.Asset_key
            ,InspectionTypeId = source.InspectionTypeId
            ,InspectionType = source.InspectionType
            ,InspectionDate = source.InspectionDate
            ,InspectedBy = source.InspectedBy
            ,Deleted = source.Deleted
            ,Wallet_key = source.Wallet_key
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            InspectionId
            ,Asset_key
            ,InspectionTypeId
            ,InspectionType
            ,InspectionDate
            ,InspectedBy
            ,Deleted
            ,Wallet_key
        ) VALUES (
            source.InspectionId
            ,source.Asset_key
            ,source.InspectionTypeId
            ,source.InspectionType
            ,source.InspectionDate
            ,source.InspectedBy
            ,source.Deleted
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.AssetInspection, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

END
GO
