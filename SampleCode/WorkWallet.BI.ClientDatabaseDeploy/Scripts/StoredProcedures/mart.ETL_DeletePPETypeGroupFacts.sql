DROP PROCEDURE IF EXISTS mart.ETL_DeletePPETypeGroupFacts;
GO

CREATE PROCEDURE mart.ETL_DeletePPETypeGroupFacts @ppeTypeTable mart.ETL_PPETypeTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    DELETE mart.PPETypeGroupFact
    FROM mart.PPETypeGroupFact AS ptgf
    INNER JOIN mart.PPEType AS pt ON ptgf.PPEType_key = pt.PPEType_key
    INNER JOIN (SELECT DISTINCT PPETypeId, PPETypeVariantId FROM @ppeTypeTable) AS ptt ON pt.PPETypeId = ptt.PPETypeId AND pt.PPETypeVariantId = ptt.PPETypeVariantId;

    PRINT 'DELETE mart.PPETypeGroupFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
