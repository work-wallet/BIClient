DROP PROCEDURE IF EXISTS mart.ETL_LoadPPEStocks;
GO

CREATE PROCEDURE mart.ETL_LoadPPEStocks
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

        -- maintain the Location dimension

        DECLARE @locationTable mart.ETL_LocationTable;

        INSERT INTO @locationTable
        (
            LocationId
            ,LocationTypeCode
            ,LocationType
            ,[Location]
            ,CompanyId
            ,Company
            ,SiteId
            ,[Site]
            ,AreaId
            ,Area
            ,JobId
            ,Job
            ,SiteLocationId
            ,Department
            ,ExternalIdentifier
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.Locations')
        WITH
        (
            LocationId uniqueidentifier
            ,LocationTypeCode int
            ,LocationType nvarchar(50)
            ,[Location] nvarchar(max)
            ,CompanyId uniqueidentifier
            ,Company nvarchar(max)
            ,SiteId uniqueidentifier
            ,[Site] nvarchar(max)
            ,AreaId uniqueidentifier
            ,[Area] nvarchar(255)
            ,JobId uniqueidentifier
            ,Job nvarchar(50)
            ,SiteLocationId uniqueidentifier
            ,Department nvarchar(30)
            ,ExternalIdentifier nvarchar(255)
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainLocationDimension @locationTable = @locationTable;

        -- maintain PPEType dimension

        DECLARE @ppeTypeTable mart.ETL_PPETypeTable;

        INSERT INTO @ppeTypeTable
        (
            PPETypeId
            ,PPETypeVariantId
            ,[Type]
            ,Variant
            ,VariantOrder
            ,LifespanDays
            ,[Value]
            ,TypeDeleted
            ,VariantDeleted
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.PPETypes')
        WITH
        (
            PPETypeId uniqueidentifier
            ,PPETypeVariantId uniqueidentifier
            ,[Type] nvarchar(100)
            ,Variant nvarchar(200)
            ,VariantOrder int
            ,LifespanDays int
            ,[Value] decimal(10, 2)
            ,TypeDeleted bit
            ,VariantDeleted bit
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainPPETypeDimension @ppeTypeTable = @ppeTypeTable;

        -- maintain PPEStock dimension

        DECLARE @ppeStockTable mart.ETL_PPEStockTable;

        INSERT INTO @ppeStockTable
        (
            PPEStockId
            ,LocationId
            ,PPETypeId
            ,PPETypeVariantId
            ,StockQuantity
            ,WarningQuantity
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.PPEStocks')
        WITH
        (
            PPEStockId uniqueidentifier
            ,LocationId uniqueidentifier
            ,PPETypeId uniqueidentifier
            ,PPETypeVariantId uniqueidentifier
            ,StockQuantity int
            ,WarningQuantity int
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainPPEStockDimension @ppeStockTable = @ppeStockTable;

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
