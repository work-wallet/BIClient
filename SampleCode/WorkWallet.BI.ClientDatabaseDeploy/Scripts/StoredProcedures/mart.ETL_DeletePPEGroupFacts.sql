DROP PROCEDURE IF EXISTS mart.ETL_DeletePPEGroupFacts;
GO

CREATE PROCEDURE mart.ETL_DeletePPEGroupFacts @ppeTypeTable mart.ETL_PPETypeTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    DELETE mart.PPEGroupFact
    FROM mart.PPEGroupFact AS ptgf
    INNER JOIN mart.PPEType AS pt ON ptgf.PPEType_key = pt.PPEType_key
    INNER JOIN (SELECT DISTINCT PPETypeId, PPETypeVariantId FROM @ppeTypeTable) AS ptt ON pt.PPETypeId = ptt.PPETypeId AND pt.PPETypeVariantId = ptt.PPETypeVariantId;

    PRINT 'DELETE mart.PPEGroupFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
