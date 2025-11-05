DROP PROCEDURE IF EXISTS mart.ETL_LoadAssetObservations;
GO

CREATE PROCEDURE mart.ETL_LoadAssetObservations
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

        -- maintain the Asset dimension table

        DECLARE @assetTable mart.ETL_AssetTable;

        INSERT INTO @assetTable
        (
            AssetId
            ,AssetType
            ,AssetStatusCode
            ,Reference
            ,[Name]
            ,[Description]
            ,CreatedOn
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.Assets')
        WITH
        (
            AssetId uniqueidentifier
            ,AssetType nvarchar(75)
            ,AssetStatusCode int
            ,Reference nvarchar(143)
            ,[Name] nvarchar(75)
            ,[Description] nvarchar(max)
            ,CreatedOn datetimeoffset(7)
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainAssetDimension @assetTable = @assetTable;

        -- maintain the AssetObservation dimension table

        DECLARE @observationTable mart.ETL_AssetObservationTable;

        INSERT INTO @observationTable
        (
            AssetId
            ,ObservationId
            ,Details
            ,ActionTaken
            ,StatusId
            ,ObservedOn
            ,ObservedBy
            ,Deleted
            ,ClosedOn
            ,ClosedBy
            ,ClosureNotes
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.Observations')
        WITH
        (
            AssetId uniqueidentifier
            ,ObservationId uniqueidentifier
            ,Details nvarchar(max)
            ,ActionTaken nvarchar(max)
            ,StatusId int
            ,ObservedOn datetimeoffset(7)
            ,ObservedBy nvarchar(81)
            ,Deleted bit
            ,ClosedOn datetimeoffset(7)
            ,ClosedBy nvarchar(81)
            ,ClosureNotes nvarchar(max)
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainAssetObservationDimension @observationTable = @observationTable;

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO
