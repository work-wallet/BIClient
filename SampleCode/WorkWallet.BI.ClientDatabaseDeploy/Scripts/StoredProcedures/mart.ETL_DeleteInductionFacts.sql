DROP PROCEDURE IF EXISTS mart.ETL_DeleteInductionFacts;
GO

CREATE PROCEDURE mart.ETL_DeleteInductionFacts @inductionTakenTable mart.ETL_InductionTakenTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    DELETE mart.InductionCustomQuestionFact
    FROM mart.InductionCustomQuestionFact AS d
    INNER JOIN mart.InductionTaken AS it ON d.InductionTaken_key = it.InductionTaken_key
    INNER JOIN @inductionTakenTable AS a ON it.InductionTakenId = a.InductionTakenId;

    PRINT 'DELETE mart.InductionCustomQuestionFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
