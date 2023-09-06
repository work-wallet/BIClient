DROP PROCEDURE IF EXISTS mart.ETL_LoadSiteAudits;
GO

CREATE PROCEDURE mart.ETL_LoadSiteAudits
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
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainLocationDimension @locationTable = @locationTable;

        -- maintain SiteAuditType dimension

        DECLARE @siteAuditTypeTable mart.ETL_SiteAuditTypeTable;

        INSERT INTO @siteAuditTypeTable
        (
            SiteAuditTypeId
            ,SiteAuditType
            ,DisplayScoring
            ,ScoringMethod
            ,DisplayOptions
            ,ShowPercentage
            ,ShowScore
            ,ShowPassFail
            ,ShowGrading
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.SiteAuditTypes')
        WITH
        (
            SiteAuditTypeId uniqueidentifier
            ,SiteAuditType nvarchar(75)
            ,DisplayScoring bit
            ,ScoringMethod int
            ,DisplayOptions int
            ,ShowPercentage bit
            ,ShowScore bit
            ,ShowPassFail bit
            ,ShowGrading bit
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainSiteAuditTypeDimension @siteAuditTypeTable = @siteAuditTypeTable;

        -- maintain the SiteAudit table

        DECLARE @siteAuditTable mart.ETL_SiteAuditTable;

        INSERT INTO @siteAuditTable
        (
            SiteAuditId
            ,AuditReference
            ,DateAndTimeOfInspection
            ,SiteAuditStatusCode
            ,SiteAuditTypeId
            ,LocationId
            ,AuditSummary
            ,HasScore
            ,Passed
            ,ActualScore
            ,PotentialScore
            ,[Percent]
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.SiteAudits')
        WITH
        (
            SiteAuditId uniqueidentifier
            ,AuditReference nvarchar(50)
            ,DateAndTimeOfInspection datetime2(7)
            ,SiteAuditStatusCode int
            ,SiteAuditTypeId uniqueidentifier
            ,LocationId uniqueidentifier
            ,AuditSummary nvarchar(max)
            ,HasScore bit
            ,Passed bit
            ,ActualScore decimal(5,2)
            ,PotentialScore decimal(5,2)
            ,[Percent] int
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainSiteAuditDimension @siteAuditTable = @siteAuditTable;

        EXEC mart.ETL_DeleteSiteAuditFacts @siteAuditTable = @siteAuditTable;

        -- maintain SiteAuditChecklist dimension

        DECLARE @siteAuditChecklistTable mart.ETL_SiteAuditChecklistTable;

        INSERT INTO @siteAuditChecklistTable
        (
            SiteAuditChecklistId
            ,SiteAuditChecklistVersion
            ,ChecklistName
            ,ChecklistDescription
            ,NumberOfResponseOptions
            ,ScoringEnabled
            ,PassStatus
            ,ChecklistWeighting
            ,FailedItemScoring
            ,FailedItemsCountTowardsAverageScore
            ,FailedItemsSetTheChecklistScoreToZero
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.SiteAuditChecklists')
        WITH
        (
            SiteAuditChecklistId uniqueidentifier
            ,SiteAuditChecklistVersion int
            ,ChecklistName nvarchar(250)
            ,ChecklistDescription nvarchar(1000)
            ,NumberOfResponseOptions int
            ,ScoringEnabled bit
            ,PassStatus int
            ,ChecklistWeighting int
            ,FailedItemScoring int
            ,FailedItemsCountTowardsAverageScore bit
            ,FailedItemsSetTheChecklistScoreToZero bit
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainSiteAuditChecklistDimension @siteAuditChecklistTable = @siteAuditChecklistTable;

        -- load the SiteAuditChecklistFact data

        DECLARE @siteAuditChecklistFactTable mart.ETL_SiteAuditChecklistFactTable;

        INSERT INTO @siteAuditChecklistFactTable
        (
            -- keys
            SiteAuditId
            ,SiteAuditChecklistId
            ,SiteAuditChecklistVersion
            ,SiteAuditTypeId
            ,LocationId
            ,SiteAuditStatusCode
            ,WalletId
            -- facts
            ,HasScore
            ,Score
            ,PotentialScore
            ,[Percent]
            ,PassFailStatus
            ,Passed
            ,PassScore
        )
        SELECT * FROM OPENJSON(@json, '$.SiteAuditChecklistFacts')
        WITH
        (
            -- keys
            SiteAuditId uniqueidentifier
            ,SiteAuditChecklistId uniqueidentifier
            ,SiteAuditChecklistVersion int
            ,SiteAuditTypeId uniqueidentifier
            ,LocationId uniqueidentifier
            ,SiteAuditStatusCode int
            ,WalletId uniqueidentifier
            -- facts
            ,HasScore bit
            ,Score decimal(5,2)
            ,PotentialScore decimal(5,2)
            ,[Percent] int
            ,PassFailStatus int
            ,Passed bit
            ,PassScore int
        );

        EXEC mart.ETL_LoadSiteAuditChecklistFact @siteAuditChecklistFactTable = @siteAuditChecklistFactTable;

        -- maintain SiteAuditChecklistItem dimension

        DECLARE @siteAuditChecklistItemTable mart.ETL_SiteAuditChecklistItemTable;

        INSERT INTO @siteAuditChecklistItemTable
        (
            SiteAuditChecklistItemId
            ,SiteAuditChecklistId
            ,SiteAuditChecklistVersion
            ,ChecklistItemTitle
            ,ChecklistItemDescription
            ,DisplayOrder
            ,x.WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.SiteAuditChecklistItems')
        WITH
        (
            SiteAuditChecklistItemId uniqueidentifier
            ,SiteAuditChecklistId uniqueidentifier
            ,SiteAuditChecklistVersion int
            ,ChecklistItemTitle nvarchar(250)
            ,ChecklistItemDescription nvarchar(1000)
            ,DisplayOrder int
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainSiteAuditChecklistItemDimension @siteAuditChecklistItemTable = @siteAuditChecklistItemTable;

        -- load the SiteAuditChecklistFact data

        DECLARE @siteAuditChecklistItemFactTable mart.ETL_SiteAuditChecklistItemFactTable;

        INSERT INTO @siteAuditChecklistItemFactTable
        (
            -- keys
            SiteAuditId
            ,SiteAuditChecklistId
            ,SiteAuditChecklistVersion
            ,SiteAuditChecklistItemId
            ,SiteAuditTypeId
            ,LocationId
            ,SiteAuditStatusCode
            ,WalletId
            -- facts
            ,ChecklistItemStatusName
            ,ChecklistItemStatus
        )
        SELECT * FROM OPENJSON(@json, '$.SiteAuditChecklistItemFacts')
        WITH
        (
            -- keys
            SiteAuditId uniqueidentifier
            ,SiteAuditChecklistId uniqueidentifier
            ,SiteAuditChecklistVersion int
            ,SiteAuditChecklistItemId uniqueidentifier
            ,SiteAuditTypeId uniqueidentifier
            ,LocationId uniqueidentifier
            ,SiteAuditStatusCode int
            ,WalletId uniqueidentifier
            -- facts
            ,ChecklistItemStatusName nvarchar(64)
            ,ChecklistItemStatus int
        );

        EXEC mart.ETL_LoadSiteAuditChecklistItemFact @siteAuditChecklistItemFactTable = @siteAuditChecklistItemFactTable;

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
