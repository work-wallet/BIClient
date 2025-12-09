DROP PROCEDURE IF EXISTS mart.ETL_LoadAssetInspectionChecklistItemFact;
GO

CREATE PROCEDURE mart.ETL_LoadAssetInspectionChecklistItemFact @checklistItemTable mart.ETL_AssetInspectionChecklistItemTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO mart.AssetInspectionChecklistItemFact
    (
        AssetInspection_key
        ,AssetInspectionChecklistItem_key
        ,Response
        ,ResponseText
        ,Wallet_key
    )
    SELECT
        ai.AssetInspection_key
        ,aici.AssetInspectionChecklistItem_key
        ,ci.Response
        ,ci.ResponseText
        ,w.Wallet_key
    FROM
        @checklistItemTable AS ci
        INNER JOIN mart.AssetInspection AS ai ON ci.InspectionId = ai.InspectionId
        INNER JOIN mart.AssetInspectionChecklistItem AS aici ON ci.ChecklistItemId = aici.ChecklistItemId
        INNER JOIN mart.Wallet AS w ON ci.WalletId = w.WalletId;

    PRINT 'INSERT INTO mart.AssetInspectionChecklistItemFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

END
GO
