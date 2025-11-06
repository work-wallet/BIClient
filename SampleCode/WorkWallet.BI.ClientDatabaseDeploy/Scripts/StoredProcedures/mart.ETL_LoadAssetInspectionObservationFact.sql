DROP PROCEDURE IF EXISTS mart.ETL_LoadAssetInspectionObservationFact;
GO

CREATE PROCEDURE mart.ETL_LoadAssetInspectionObservationFact @inspectionObservationTable mart.ETL_AssetInspectionObservationTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO mart.AssetInspectionObservationFact
    (
        AssetInspection_key
        ,AssetObservation_key
        ,AssetInspectionChecklistItem_key
        ,[New]
        ,Wallet_key
    )
    SELECT
        ai.AssetInspection_key
        ,ao.AssetObservation_key
        ,aici.AssetInspectionChecklistItem_key
        ,io.[New]
        ,w.Wallet_key
    FROM
        @inspectionObservationTable AS io
        INNER JOIN mart.AssetInspection AS ai ON io.InspectionId = ai.InspectionId
        INNER JOIN mart.AssetObservation AS ao ON io.ObservationId = ao.ObservationId
        LEFT JOIN mart.AssetInspectionChecklistItem AS aici ON io.ChecklistItemId = aici.ChecklistItemId
        INNER JOIN mart.Wallet AS w ON io.WalletId = w.WalletId;

    PRINT 'INSERT INTO mart.AssetInspectionObservationFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

END
GO
