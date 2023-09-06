DROP PROCEDURE IF EXISTS mart.ETL_MaintainActionDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainActionDimension @ActionTable mart.ETL_ActionTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    -- type 1 changes (do first, before inserting new)
    UPDATE mart.[Action]
    SET
        ActionType_key = atype.ActionType_key
        ,TargetId = a.TargetId
        ,TargetReference = a.TargetReference
        ,Title = a.Title
        ,[Description] = a.[Description]
        ,AssignedTo = a.AssignedTo
        ,ActionPriority_key = ap.ActionPriority_key
        ,DueOn = a.DueOn
        ,ActionStatus_key = astat.ActionStatus_key
        ,Deleted = a.Deleted
        ,CreatedOn = a.CreatedOn
        ,Wallet_key = w.Wallet_key
        ,_edited = SYSUTCDATETIME()
    FROM
        @ActionTable AS a
        INNER JOIN mart.ActionStatus AS astat ON a.ActionStatusCode = astat.ActionStatusCode
        INNER JOIN mart.ActionType AS atype ON a.ActionTypeCode = atype.ActionTypeCode
        INNER JOIN mart.ActionPriority AS ap ON a.PriorityCode = ap.ActionPriorityCode
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        LEFT OUTER JOIN mart.[Action] AS b ON a.ActionId = b.ActionId
    WHERE /* only where the data has changed */
        atype.ActionType_key <> b.ActionType_key
        OR a.TargetId <> b.TargetId
        OR a.TargetReference <> b.TargetReference
        OR a.Title <> b.Title
        OR a.[Description] <> b.[Description]
        OR a.AssignedTo <> b.AssignedTo
        OR ap.ActionPriority_key <> b.ActionPriority_key
        OR a.DueOn <> b.DueOn
        OR astat.ActionStatus_key <> b.ActionStatus_key
        OR a.Deleted <> b.Deleted
        OR a.CreatedOn <> b.CreatedOn
        OR w.Wallet_key <> b.Wallet_key;

    PRINT 'UPDATE mart.Action, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

    -- insert missing entries
    INSERT INTO mart.[Action]
    (
        ActionId
        ,ActionType_key
        ,TargetId
        ,TargetReference
        ,Title
        ,[Description]
        ,AssignedTo
        ,ActionPriority_key
        ,DueOn
        ,ActionStatus_key
        ,Deleted
        ,CreatedOn
        ,Wallet_key
    )
    SELECT
        a.ActionId
        ,atype.ActionType_key
        ,a.TargetId
        ,a.TargetReference
        ,a.Title
        ,a.[Description]
        ,a.AssignedTo
        ,ap.ActionPriority_key
        ,a.DueOn
        ,astat.ActionStatus_key
        ,a.Deleted
        ,a.CreatedOn
        ,w.Wallet_key
    FROM
        @ActionTable AS a
        INNER JOIN mart.ActionStatus AS astat ON a.ActionStatusCode = astat.ActionStatusCode
        INNER JOIN mart.ActionType AS atype ON a.ActionTypeCode = atype.ActionTypeCode
        INNER JOIN mart.ActionPriority AS ap ON a.PriorityCode = ap.ActionPriorityCode
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        LEFT OUTER JOIN mart.[Action] AS b ON
            a.ActionId = b.ActionId
    WHERE
        b.ActionId IS NULL;

    PRINT 'INSERT mart.Action, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
