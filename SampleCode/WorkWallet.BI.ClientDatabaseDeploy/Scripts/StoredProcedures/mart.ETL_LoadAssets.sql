DROP PROCEDURE IF EXISTS mart.ETL_LoadAssets;
GO

CREATE PROCEDURE mart.ETL_LoadAssets
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

        -- maintain the Asset table

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

        EXEC mart.ETL_DeleteAssetFacts @assetTable = @assetTable;

        -- load the AssetProperty data

        DECLARE @assetPropertyTable mart.ETL_AssetPropertyTable;

        INSERT INTO @assetPropertyTable
        (
            AssetId
            ,Property
            ,PropertyType
            ,[Value]
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.Properties')
        WITH
        (
            AssetId uniqueidentifier
            ,Property nvarchar(250)
            ,PropertyType nvarchar(20)
            ,[Value] nvarchar(max)
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainAssetPropertyDimension @assetPropertyTable = @assetPropertyTable;

        EXEC mart.ETL_LoadAssetPropertyFact @assetPropertyTable = @assetPropertyTable;

        -- load the AssetAssignment data

        DECLARE @assetAssignmentTable mart.ETL_AssetAssignmentTable;

        INSERT INTO @assetAssignmentTable
        (
            AssetId
            ,AssignedOn
            ,AssignmentType
            ,AssignedTo
            ,CompanyId
            ,Company
            ,SiteId
            ,[Site]
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.Assignments')
        WITH
        (
            AssetId uniqueidentifier
            ,AssignedOn datetimeoffset(7)
            ,AssignmentType nvarchar(20)
            ,AssignedTo nvarchar(max)
            ,CompanyId uniqueidentifier
            ,Company nvarchar(max)
            ,SiteId uniqueidentifier
            ,[Site] nvarchar(max)
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainAssetAssignmentDimension @assetAssignmentTable = @assetAssignmentTable;

        EXEC mart.ETL_LoadAssetAssignmentFact @assetAssignmentTable = @assetAssignmentTable;

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
