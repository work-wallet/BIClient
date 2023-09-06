DROP PROCEDURE IF EXISTS mart.ETL_LoadActionUpdates;
GO

CREATE PROCEDURE mart.ETL_LoadActionUpdates
    @ActionUpdateTable mart.ETL_ActionUpdateTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO mart.ActionUpdate
    (
        ActionUpdateId
        ,Action_key
        ,Comments
        ,ActionStatus_key
        ,Deleted
        ,CreatedOn
        ,Wallet_key
    )
    SELECT DISTINCT
        a.ActionUpdateId
        ,act.Action_key
        ,a.Comments
        ,astat.ActionStatus_key
        ,a.Deleted
        ,a.CreatedOn
        ,w.Wallet_key
    FROM
        @ActionUpdateTable AS a
        INNER JOIN mart.[Action] AS act ON a.ActionId = act.ActionId
        INNER JOIN mart.ActionStatus AS astat ON a.ActionStatusCode = astat.ActionStatusCode
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId;

    PRINT 'INSERT mart.ActionUpdate, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
