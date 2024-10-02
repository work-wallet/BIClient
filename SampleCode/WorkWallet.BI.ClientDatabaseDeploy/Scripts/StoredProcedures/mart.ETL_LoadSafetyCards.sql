DROP PROCEDURE IF EXISTS mart.ETL_LoadSafetyCards;
GO

CREATE PROCEDURE mart.ETL_LoadSafetyCards
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

        -- maintain SafetyCardCategory dimension

        DECLARE @safetyCardCategoryTable mart.ETL_SafetyCardCategoryTable;

        INSERT INTO @safetyCardCategoryTable
        (
            SafetyCardCategoryId
            ,CategoryName
            ,CategoryReference
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.SafetyCardCategories')
        WITH
        (
            SafetyCardCategoryId uniqueidentifier
            ,CategoryName nvarchar(500)
            ,CategoryReference nvarchar(50)
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainSafetyCardCategoryDimension @safetyCardCategoryTable = @safetyCardCategoryTable;

        -- maintain the Permits table

        DECLARE @safetyCardTable mart.ETL_SafetyCardTable;

        INSERT INTO @safetyCardTable
        (
            SafetyCardId
            ,SafetyCardReference
            ,SafetyCardTypeCode
            ,ReportedByUser
            ,ReportedDateTime
            ,SafetyCardCategoryId
            ,Employer
            ,Employee
            ,InductionNumber
            ,ReportDetails
            ,SafetyCardStatusCode
            ,HasSignature
            ,SignatureDate
            ,Occupation
            ,OccupationRoleCode
            ,LocationId
            ,ExternalIdentifier
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.SafetyCards')
        WITH
        (
            SafetyCardId uniqueidentifier
            ,SafetyCardReference nvarchar(50)
            ,SafetyCardTypeCode int
            ,ReportedByUser nvarchar(100)
            ,ReportedDateTime datetime
            ,SafetyCardCategoryId uniqueidentifier
            ,Employer nvarchar(max)
            ,Employee nvarchar(max)
            ,InductionNumber nvarchar(500)
            ,ReportDetails nvarchar(max)
            ,SafetyCardStatusCode int
            ,HasSignature bit
            ,SignatureDate datetime
            ,Occupation nvarchar(255)
            ,OccupationRoleCode int
            ,LocationId uniqueidentifier
            ,ExternalIdentifier nvarchar(255)
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainSafetyCardDimension @safetyCardTable = @safetyCardTable;
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
