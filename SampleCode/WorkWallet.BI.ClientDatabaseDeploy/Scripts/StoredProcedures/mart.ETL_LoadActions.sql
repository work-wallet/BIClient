DROP PROCEDURE IF EXISTS mart.ETL_LoadActions;
GO

CREATE PROCEDURE mart.ETL_LoadActions
    @json nvarchar(max)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION

        -- maintain the Wallet dimension table

        DECLARE @walletTable mart.ETL_WalletTable;

        INSERT INTO @walletTable
        (
            WalletId
            ,Wallet
        )
        SELECT * FROM OPENJSON(@json, '$.Wallets')
        WITH
        (
            WalletId uniqueidentifier
            ,Wallet nvarchar(50)
        );

        EXEC mart.ETL_MaintainWalletDimension @walletTable = @walletTable;

        -- maintain the Action table

        DECLARE @actionTable mart.ETL_ActionTable;

        INSERT INTO @actionTable
        (
            ActionId
            ,ActionTypeCode
            ,TargetId
            ,TargetReference
            ,Title
            ,[Description]
            ,AssignedTo
            ,PriorityCode
            ,DueOn
            ,OriginalDueOn
            ,ActionStatusCode
            ,Deleted
            ,CreatedOn
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.Actions')
        WITH
        (
            ActionId uniqueidentifier
            ,ActionTypeCode int
            ,TargetId uniqueidentifier
            ,TargetReference nvarchar(128)
            ,Title nvarchar(100)
            ,[Description] nvarchar(max)
            ,AssignedTo nvarchar(100)
            ,PriorityCode int
            ,DueOn date
            ,OriginalDueOn date
            ,ActionStatusCode int
            ,Deleted bit
            ,CreatedOn datetimeoffset(7)
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainActionDimension @actionTable = @actionTable;

        EXEC mart.ETL_DeleteActionFacts @actionTable = @actionTable;

        -- load the ActionUpdate data

        DECLARE @actionUpdateTable mart.ETL_ActionUpdateTable;

        INSERT INTO @actionUpdateTable
        (
            ActionUpdateId
            ,ActionId
            ,Comments
            ,ActionStatusCode
            ,Deleted
            ,CreatedOn
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.ActionUpdates')
        WITH
        (
            ActionUpdateId uniqueidentifier
            ,ActionId uniqueidentifier
            ,Comments nvarchar(max)
            ,ActionStatusCode int
            ,Deleted bit
            ,CreatedOn datetimeoffset(7)
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_LoadActionUpdates @actionUpdateTable = @actionUpdateTable;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;

        DECLARE @ErrorMessage NVARCHAR(4000);  
        DECLARE @ErrorSeverity INT;  
        DECLARE @ErrorState INT;  

        SELECT   
           @ErrorMessage = ERROR_MESSAGE(),  
           @ErrorSeverity = ERROR_SEVERITY(),  
           @ErrorState = ERROR_STATE();  

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
    END
GO
