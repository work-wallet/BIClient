DROP PROCEDURE IF EXISTS mart.ETL_MaintainAssetInspectionChecklistItemDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainAssetInspectionChecklistItemDimension @checklistItemTable mart.ETL_AssetInspectionChecklistItemTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.AssetInspectionChecklistItem AS target
    USING (
        SELECT DISTINCT
            ci.ChecklistId
            ,ci.ChecklistName
            ,ci.ChecklistItemId
            ,ci.ChecklistItemName
            ,ci.ChecklistItemDisplayOrder
            ,w.Wallet_key
        FROM
            @checklistItemTable AS ci
            INNER JOIN mart.Wallet AS w ON ci.WalletId = w.WalletId
    ) AS source
    ON target.ChecklistItemId = source.ChecklistItemId
    WHEN MATCHED AND (
        target.ChecklistId <> source.ChecklistId
        OR target.ChecklistName <> source.ChecklistName
        OR target.ChecklistItemName <> source.ChecklistItemName
        OR target.ChecklistItemDisplayOrder <> source.ChecklistItemDisplayOrder
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            ChecklistId = source.ChecklistId
            ,ChecklistName = source.ChecklistName
            ,ChecklistItemName = source.ChecklistItemName
            ,ChecklistItemDisplayOrder = source.ChecklistItemDisplayOrder
            ,Wallet_key = source.Wallet_key
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            ChecklistId
            ,ChecklistName
            ,ChecklistItemId
            ,ChecklistItemName
            ,ChecklistItemDisplayOrder
            ,Wallet_key
        ) VALUES (
            source.ChecklistId
            ,source.ChecklistName
            ,source.ChecklistItemId
            ,source.ChecklistItemName
            ,source.ChecklistItemDisplayOrder
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.AssetInspectionChecklistItem, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

END
GO
