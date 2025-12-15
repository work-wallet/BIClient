DROP PROCEDURE IF EXISTS mart.ETL_DeletePPEPropertyFacts;
GO

CREATE PROCEDURE mart.ETL_DeletePPEPropertyFacts @ppeTypeTable mart.ETL_PPETypeTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    DELETE mart.PPEPropertyFact
    FROM mart.PPEPropertyFact AS ppf
    INNER JOIN (SELECT DISTINCT PPETypeId FROM @ppeTypeTable) AS pt ON ppf.PPETypeId = pt.PPETypeId;

    PRINT 'DELETE mart.PPEPropertyFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
