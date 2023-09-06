DROP PROCEDURE IF EXISTS mart.ETL_DeleteActionFacts;
GO

CREATE PROCEDURE mart.ETL_DeleteActionFacts @ActionTable mart.ETL_ActionTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    DELETE mart.ActionUpdate
    FROM mart.ActionUpdate AS au
    INNER JOIN mart.[Action] AS act ON au.Action_key = act.Action_key
    INNER JOIN @ActionTable AS a ON act.ActionId = a.ActionId;

    PRINT 'DELETE mart.ActionUpdate, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
