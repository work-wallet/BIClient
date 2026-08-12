DROP PROCEDURE IF EXISTS mart.ETL_DeleteAssetInspectionFacts;
GO

CREATE PROCEDURE mart.ETL_DeleteAssetInspectionFacts @inspectionTable mart.ETL_AssetInspectionTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    DELETE mart.AssetInspectionInspectedByFact
    FROM mart.AssetInspectionInspectedByFact AS f
    INNER JOIN mart.AssetInspection AS a ON f.AssetInspection_key = a.AssetInspection_key
    INNER JOIN @inspectionTable AS x ON a.InspectionId = x.InspectionId;

    PRINT 'DELETE mart.AssetInspectionInspectedByFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

    DELETE mart.AssetInspectionNumericAnswerFact
    FROM mart.AssetInspectionNumericAnswerFact AS f
    INNER JOIN mart.AssetInspection AS a ON f.AssetInspection_key = a.AssetInspection_key
    INNER JOIN @inspectionTable AS x ON a.InspectionId = x.InspectionId;

    PRINT 'DELETE mart.AssetInspectionNumericAnswerFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

    DELETE mart.AssetInspectionDateTimeAnswerFact
    FROM mart.AssetInspectionDateTimeAnswerFact AS f
    INNER JOIN mart.AssetInspection AS a ON f.AssetInspection_key = a.AssetInspection_key
    INNER JOIN @inspectionTable AS x ON a.InspectionId = x.InspectionId;

    PRINT 'DELETE mart.AssetInspectionDateTimeAnswerFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

    DELETE mart.AssetInspectionChecklistAnswerFact
    FROM mart.AssetInspectionChecklistAnswerFact AS f
    INNER JOIN mart.AssetInspection AS a ON f.AssetInspection_key = a.AssetInspection_key
    INNER JOIN @inspectionTable AS x ON a.InspectionId = x.InspectionId;

    PRINT 'DELETE mart.AssetInspectionChecklistAnswerFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

    DELETE mart.AssetInspectionBranchOptionFact
    FROM mart.AssetInspectionBranchOptionFact AS f
    INNER JOIN mart.AssetInspection AS a ON f.AssetInspection_key = a.AssetInspection_key
    INNER JOIN @inspectionTable AS x ON a.InspectionId = x.InspectionId;

    PRINT 'DELETE mart.AssetInspectionBranchOptionFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

    DELETE mart.AssetInspectionScoredResponseFact
    FROM mart.AssetInspectionScoredResponseFact AS f
    INNER JOIN mart.AssetInspection AS a ON f.AssetInspection_key = a.AssetInspection_key
    INNER JOIN @inspectionTable AS x ON a.InspectionId = x.InspectionId;

    PRINT 'DELETE mart.AssetInspectionScoredResponseFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

    DELETE mart.AssetInspectionScoreSectionFact
    FROM mart.AssetInspectionScoreSectionFact AS f
    INNER JOIN mart.AssetInspection AS a ON f.AssetInspection_key = a.AssetInspection_key
    INNER JOIN @inspectionTable AS x ON a.InspectionId = x.InspectionId;

    PRINT 'DELETE mart.AssetInspectionScoreSectionFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

    DELETE mart.AssetInspectionScoreTagFact
    FROM mart.AssetInspectionScoreTagFact AS f
    INNER JOIN mart.AssetInspection AS a ON f.AssetInspection_key = a.AssetInspection_key
    INNER JOIN @inspectionTable AS x ON a.InspectionId = x.InspectionId;

    PRINT 'DELETE mart.AssetInspectionScoreTagFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

    DELETE mart.AssetInspectionObservationFact
    FROM mart.AssetInspectionObservationFact AS f
    INNER JOIN mart.AssetInspection AS a ON f.AssetInspection_key = a.AssetInspection_key
    INNER JOIN @inspectionTable AS x ON a.InspectionId = x.InspectionId;

    PRINT 'DELETE mart.AssetInspectionObservationFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END

GO
