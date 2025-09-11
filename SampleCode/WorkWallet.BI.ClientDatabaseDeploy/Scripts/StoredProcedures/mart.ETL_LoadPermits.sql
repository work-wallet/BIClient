DROP PROCEDURE IF EXISTS mart.ETL_LoadPermits;
GO

CREATE PROCEDURE mart.ETL_LoadPermits
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

        -- maintain PermitCategory dimension

        DECLARE @permitToWorkCategoryTable mart.ETL_PermitToWorkCategoryTable;

        INSERT INTO @permitToWorkCategoryTable
        (
            CategoryId
            ,CategoryVersion
            ,CategoryName
            ,ExpiryTypeId
            ,ExpiryType
            ,ValidityPeriodId
            ,ValidityPeriod
            ,ValidityPeriodMinutes
            ,IssueTypeId
            ,IssueType
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.PermitCategories')
        WITH
        (
            CategoryId uniqueidentifier
            ,CategoryVersion int
            ,CategoryName nvarchar(75)
            ,ExpiryTypeId int
            ,ExpiryType nvarchar(50)
            ,ValidityPeriodId int
            ,ValidityPeriod nvarchar(50)
            ,ValidityPeriodMinutes int
            ,IssueTypeId int
            ,IssueType nvarchar(50)
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainPermitCategoryDimension @permitToWorkCategoryTable = @permitToWorkCategoryTable;

        -- maintain the Permits table

        DECLARE @permitToWorkTable mart.ETL_PermitToWorkTable;

        INSERT INTO @permitToWorkTable
        (
            PermitToWorkId
            ,PermitToWorkReference
            ,CategoryId
            ,CategoryVersion
            ,SiteLocationId
            ,[Description]
            ,IssuedToCompanyId
            ,IssuedToCompany
            ,IssuedOn
            ,IssuedForMinutes
            ,IssuedExpiry
            ,ClosedOn
            ,StatusId
            ,HasBeenExpired
            ,HasBeenClosed
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.Permits')
        WITH
        (
            PermitToWorkId uniqueidentifier
            ,PermitToWorkReference nvarchar(50)
            ,CategoryId uniqueidentifier
            ,CategoryVersion int
            ,SiteLocationId uniqueidentifier
            ,[Description] nvarchar(750)
            ,IssuedToCompanyId uniqueidentifier
            ,IssuedToCompany nvarchar(max)
            ,IssuedOn datetime
            ,IssuedForMinutes int
            ,IssuedExpiry datetime
            ,ClosedOn datetime
            ,StatusId int
            ,HasBeenExpired bit
            ,HasBeenClosed bit
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainPermitDimension @permitToWorkTable = @permitToWorkTable;

        EXEC mart.ETL_DeletePermitFacts @permitToWorkTable = @permitToWorkTable;

        -- load the PermitChecklistAnswers data

        DECLARE @permitToWorkChecklistAnswerTable mart.ETL_PermitToWorkChecklistAnswerTable;

        INSERT INTO @permitToWorkChecklistAnswerTable
        (
            PermitToWorkId
            ,ChecklistId
            ,OptionId
            ,CategorySectionTypeId
            ,CategorySectionType
            ,Question
            ,[Option]
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.PermitChecklistAnswers')
        WITH
        (
            PermitToWorkId uniqueidentifier
            ,ChecklistId uniqueidentifier
            ,OptionId uniqueidentifier
            ,CategorySectionTypeId int
            ,CategorySectionType nvarchar(50)
            ,Question nvarchar(1000)
            ,[Option] nvarchar(250)
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainPermitChecklistAnswerDimension @permitToWorkChecklistAnswerTable = @permitToWorkChecklistAnswerTable;

        EXEC mart.ETL_LoadPermitChecklistAnswerFact @permitToWorkChecklistAnswerTable = @permitToWorkChecklistAnswerTable;

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
