DROP PROCEDURE IF EXISTS mart.ETL_DeletePermitFacts;
GO

CREATE PROCEDURE mart.ETL_DeletePermitFacts @permitToWorkTable mart.ETL_PermitToWorkTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    DELETE mart.PermitChecklistAnswerFact
    FROM mart.PermitChecklistAnswerFact AS d
    INNER JOIN mart.Permit AS p ON d.Permit_key = p.Permit_key
    INNER JOIN @permitToWorkTable AS a ON p.PermitId = a.PermitToWorkId;

    PRINT 'DELETE mart.PermitChecklistAnswerFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
