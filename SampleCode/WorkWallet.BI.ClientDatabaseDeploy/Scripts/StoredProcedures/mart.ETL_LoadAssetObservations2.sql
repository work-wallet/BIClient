DROP PROCEDURE IF EXISTS mart.ETL_LoadAssetObservations2;
GO

-- Top-level entry point for the AssetObservations2 dataset (proc name mirrors the dataType/URL convention:
-- WorkWallet.BI.ClientServices.DataStore.SQLService calls mart.ETL_Load{dataType})
CREATE PROCEDURE mart.ETL_LoadAssetObservations2
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

        -- maintain the Contact dimension table (observers, closers, observation-note authors)

        DECLARE @contactTable mart.ETL_ContactTable;

        INSERT INTO @contactTable
        (
            ContactId
            ,[Name]
            ,EmailAddress
            ,CompanyName
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.Contacts')
        WITH
        (
            ContactId uniqueidentifier
            ,[Name] nvarchar(max)
            ,EmailAddress nvarchar(max)
            ,CompanyName nvarchar(max)
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainContactDimension @contactTable = @contactTable;

        -- maintain the AssetObservation dimension table

        DECLARE @observationTable mart.ETL_AssetObservationTable;

        INSERT INTO @observationTable
        (
            AssetId
            ,ObservationId
            ,ObservationStatusCode
            ,ObservedOn
            ,ObservedByContactId
            ,Deleted
            ,ClosedOn
            ,ClosedByContactId
            ,ClosureNotes
            ,IsFinalised
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.Observations')
        WITH
        (
            AssetId uniqueidentifier
            ,ObservationId uniqueidentifier
            ,ObservationStatusCode int
            ,ObservedOn datetimeoffset(7)
            ,ObservedByContactId uniqueidentifier
            ,Deleted bit
            ,ClosedOn datetimeoffset(7)
            ,ClosedByContactId uniqueidentifier
            ,ClosureNotes nvarchar(max)
            ,IsFinalised bit
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainAssetObservationDimension @observationTable = @observationTable;

        -- maintain the AssetObservationNote dimension table

        DECLARE @observationNoteTable mart.ETL_AssetObservationNoteTable;

        INSERT INTO @observationNoteTable
        (
            ObservationId
            ,NoteId
            ,Notes
            ,CreatedOn
            ,CreatedByContactId
            ,EditedOn
            ,Deleted
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.ObservationNotes')
        WITH
        (
            ObservationId uniqueidentifier
            ,NoteId uniqueidentifier
            ,Notes nvarchar(max)
            ,CreatedOn datetimeoffset(7)
            ,CreatedByContactId uniqueidentifier
            ,EditedOn datetimeoffset(7)
            ,Deleted bit
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainAssetObservationNoteDimension @observationNoteTable = @observationNoteTable;

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
