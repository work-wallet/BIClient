DROP PROCEDURE IF EXISTS mart.ETL_DeleteAssetInspectionFacts;
GO

CREATE PROCEDURE mart.ETL_DeleteAssetInspectionFacts @inspectionTable mart.ETL_AssetInspectionTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    DELETE mart.AssetInspectionPropertyFact
    FROM mart.AssetInspectionPropertyFact AS aipf
    INNER JOIN mart.AssetInspection AS ai ON aipf.AssetInspection_key = ai.AssetInspection_key
    INNER JOIN @inspectionTable AS i ON ai.InspectionId = i.InspectionId;

    PRINT 'DELETE mart.AssetInspectionPropertyFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

    DELETE mart.AssetInspectionChecklistItemFact
    FROM mart.AssetInspectionChecklistItemFact AS aicif
    INNER JOIN mart.AssetInspection AS ai ON aicif.AssetInspection_key = ai.AssetInspection_key
    INNER JOIN @inspectionTable AS i ON ai.InspectionId = i.InspectionId;

    PRINT 'DELETE mart.AssetInspectionChecklistItemFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

    DELETE mart.AssetInspectionObservationFact
    FROM mart.AssetInspectionObservationFact AS aiof
    INNER JOIN mart.AssetInspection AS ai ON aiof.AssetInspection_key = ai.AssetInspection_key
    INNER JOIN @inspectionTable AS i ON ai.InspectionId = i.InspectionId;

    PRINT 'DELETE mart.AssetInspectionObservationFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
