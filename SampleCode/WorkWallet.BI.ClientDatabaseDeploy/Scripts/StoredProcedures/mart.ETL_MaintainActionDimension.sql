DROP PROCEDURE IF EXISTS mart.ETL_MaintainActionDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainActionDimension @ActionTable mart.ETL_ActionTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.[Action] AS target
    USING (
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
            ,a.OriginalDueOn
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
    ) AS source
    ON target.ActionId = source.ActionId
    WHEN MATCHED AND (
        target.ActionType_key <> source.ActionType_key
        OR target.TargetId <> source.TargetId
        OR target.TargetReference <> source.TargetReference
        OR target.Title <> source.Title
        OR target.[Description] <> source.[Description]
        OR target.AssignedTo <> source.AssignedTo
        OR target.ActionPriority_key <> source.ActionPriority_key
        OR target.DueOn <> source.DueOn
        OR target.OriginalDueOn <> source.OriginalDueOn
        OR target.ActionStatus_key <> source.ActionStatus_key
        OR target.Deleted <> source.Deleted
        OR target.CreatedOn <> source.CreatedOn
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            ActionType_key = source.ActionType_key
            ,TargetId = source.TargetId
            ,TargetReference = source.TargetReference
            ,Title = source.Title
            ,[Description] = source.[Description]
            ,AssignedTo = source.AssignedTo
            ,ActionPriority_key = source.ActionPriority_key
            ,DueOn = source.DueOn
            ,OriginalDueOn = source.OriginalDueOn
            ,ActionStatus_key = source.ActionStatus_key
            ,Deleted = source.Deleted
            ,CreatedOn = source.CreatedOn
            ,Wallet_key = source.Wallet_key
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            ActionId
            ,ActionType_key
            ,TargetId
            ,TargetReference
            ,Title
            ,[Description]
            ,AssignedTo
            ,ActionPriority_key
            ,DueOn
            ,OriginalDueOn
            ,ActionStatus_key
            ,Deleted
            ,CreatedOn
            ,Wallet_key
        ) VALUES (
            source.ActionId
            ,source.ActionType_key
            ,source.TargetId
            ,source.TargetReference
            ,source.Title
            ,source.[Description]
            ,source.AssignedTo
            ,source.ActionPriority_key
            ,source.DueOn
            ,source.OriginalDueOn
            ,source.ActionStatus_key
            ,source.Deleted
            ,source.CreatedOn
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.Action, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
