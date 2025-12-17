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
            ,HasBeenExtended
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
            ,StatusId2 int -- StatusId is deprecated, replaced by StatusId2
            ,HasBeenExpired bit
            ,HasBeenClosed bit
            ,HasBeenExtended bit
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
            ,Question
            ,[Option]
            ,[Order]
            ,CategorySectionType
            ,Section
            ,SectionOrder
            ,OrderInSection
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.PermitChecklistAnswers')
        WITH
        (
            PermitToWorkId uniqueidentifier
            ,ChecklistId uniqueidentifier
            ,OptionId uniqueidentifier
            ,Question nvarchar(1000)
            ,[Option] nvarchar(250)
            ,[Order] int
            ,CategorySectionType nvarchar(50)
            ,Section nvarchar(100)
            ,SectionOrder int
            ,OrderInSection int
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainPermitChecklistAnswerDimension @permitToWorkChecklistAnswerTable = @permitToWorkChecklistAnswerTable;

        EXEC mart.ETL_LoadPermitChecklistAnswerFact @permitToWorkChecklistAnswerTable = @permitToWorkChecklistAnswerTable;

        -- load the PermitNumericAnswers data

        DECLARE @permitToWorkNumericAnswerTable mart.ETL_PermitToWorkNumericAnswerTable;

        INSERT INTO @permitToWorkNumericAnswerTable
        (
            PermitToWorkId
            ,QuestionId
            ,Question
            ,Scale
            ,UnitCode
            ,Answer
            ,CategorySectionType
            ,Section
            ,SectionOrder
            ,OrderInSection
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.PermitNumericAnswers')
        WITH
        (
            PermitToWorkId uniqueidentifier
            ,QuestionId uniqueidentifier
            ,Question nvarchar(1000)
            ,Scale int
            ,UnitCode int
            ,Answer decimal(35,6)
            ,CategorySectionType nvarchar(50)
            ,Section nvarchar(100)
            ,SectionOrder int
            ,OrderInSection int
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainPermitNumericQuestionDimension @permitToWorkNumericAnswerTable = @permitToWorkNumericAnswerTable;

        EXEC mart.ETL_LoadPermitNumericAnswerFact @permitToWorkNumericAnswerTable = @permitToWorkNumericAnswerTable;

        -- load the PermitDateTimeAnswers data

        DECLARE @permitToWorkDateTimeAnswerTable mart.ETL_PermitToWorkDateTimeAnswerTable;

        INSERT INTO @permitToWorkDateTimeAnswerTable
        (
            PermitToWorkId
            ,QuestionId
            ,Question
            ,[Date]
            ,[Time]
            ,Answer
            ,CategorySectionType
            ,Section
            ,SectionOrder
            ,OrderInSection
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.PermitDateTimeAnswers')
        WITH
        (
            PermitToWorkId uniqueidentifier
            ,QuestionId uniqueidentifier
            ,Question nvarchar(1000)
            ,[Date] bit
            ,[Time] bit
            ,Answer datetime
            ,CategorySectionType nvarchar(50)
            ,Section nvarchar(100)
            ,SectionOrder int
            ,OrderInSection int
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainPermitDateTimeQuestionDimension @permitToWorkDateTimeAnswerTable = @permitToWorkDateTimeAnswerTable;

        EXEC mart.ETL_LoadPermitDateTimeAnswerFact @permitToWorkDateTimeAnswerTable = @permitToWorkDateTimeAnswerTable;

        -- load the PermitBranchOptions data

        DECLARE @permitToWorkBranchOptionTable mart.ETL_PermitToWorkBranchOptionTable;

        INSERT INTO @permitToWorkBranchOptionTable
        (
            PermitToWorkId
            ,BranchId
            ,OptionId
            ,Branch
            ,[Value]
            ,[Order]
            ,CategorySectionType
            ,Section
            ,SectionOrder
            ,OrderInSection
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.PermitBranchOptions')
        WITH
        (
            PermitToWorkId uniqueidentifier
            ,BranchId uniqueidentifier
            ,OptionId uniqueidentifier
            ,Branch nvarchar(1000)
            ,[Value] nvarchar(250)
            ,[Order] int
            ,CategorySectionType nvarchar(50)
            ,Section nvarchar(100)
            ,SectionOrder int
            ,OrderInSection int
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainPermitBranchOptionDimension @permitToWorkBranchOptionTable = @permitToWorkBranchOptionTable;

        EXEC mart.ETL_LoadPermitBranchOptionFact @permitToWorkBranchOptionTable = @permitToWorkBranchOptionTable;

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
