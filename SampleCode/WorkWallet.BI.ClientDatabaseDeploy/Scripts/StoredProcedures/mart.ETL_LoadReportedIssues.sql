DROP PROCEDURE IF EXISTS mart.ETL_LoadReportedIssues;
GO

CREATE PROCEDURE mart.ETL_LoadReportedIssues
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

        -- maintain ReportedIssueCategory dimension

        DECLARE @reportedIssueCategoryTable mart.ETL_ReportedIssueCategoryTable;

        INSERT INTO @reportedIssueCategoryTable
        (
            SubcategoryId
            ,CategoryVersion
            ,CategoryName
            ,CategoryDescription
            ,SubcategoryName
            ,SubcategoryDescription
            ,SubcategoryOrder
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.ReportedIssueCategories')
        WITH
        (
            SubcategoryId uniqueidentifier
            ,CategoryVersion int
            ,CategoryName nvarchar(50)
            ,CategoryDescription nvarchar(200)
            ,SubcategoryName nvarchar(200)
            ,SubcategoryDescription nvarchar(200)
            ,SubcategoryOrder int
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainReportedIssueCategoryDimension @reportedIssueCategoryTable = @reportedIssueCategoryTable;

        -- maintain the ReportedIssue table

        DECLARE @reportedIssueTable mart.ETL_ReportedIssueTable;

        INSERT INTO @reportedIssueTable
        (
            ReportedIssueId
            ,ReportedIssueReference
            ,OccurredOn
            ,ReportedOn
            ,ReportedBy
            ,ReportedByCompany
            ,ReportedIssueStatusCode
            ,SubcategoryId
            ,CategoryVersion
            ,LocationId
            ,ReportedIssueOverview
            ,ReportedIssueSeverityCode
            ,WalletId
            ,CloseDate
        )
        SELECT * FROM OPENJSON(@json, '$.ReportedIssues')
        WITH
        (
            ReportedIssueId uniqueidentifier
            ,ReportedIssueReference nvarchar(50)
            ,OccurredOn datetime2(7)
            ,ReportedOn datetime2(7)
            ,ReportedBy nvarchar(max)
            ,ReportedByCompany nvarchar(max)
            ,ReportedIssueStatusCode int
            ,SubcategoryId uniqueidentifier
            ,CategoryVersion int
            ,LocationId uniqueidentifier
            ,ReportedIssueOverview nvarchar(max)
            ,ReportedIssueSeverityCode int
            ,WalletId uniqueidentifier
            ,CloseDate datetimeoffset(7)
        );

        EXEC mart.ETL_MaintainReportedIssueDimension @reportedIssueTable = @reportedIssueTable;

        EXEC mart.ETL_DeleteReportedIssueFacts @reportedIssueTable = @reportedIssueTable;

        -- load the ReportedIssueRootCauseAnalysis data

        DECLARE @reportedIssueRootCauseAnalysisTable mart.ETL_ReportedIssueRootCauseAnalysisTable;

        INSERT INTO @reportedIssueRootCauseAnalysisTable
        (
            ReportedIssueRootCauseAnalysisId
            ,ReportedIssueId
            ,ReportedIssueRootCauseAnalysisTypeCode
            ,RootCauseAnalysis
            ,RootCauseAnalysisDescription
            ,RootCauseAnalysisOrder
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.ReportedIssueRootCauseAnalysis')
        WITH
        (
            ReportedIssueRootCauseAnalysisId uniqueidentifier
            ,ReportedIssueId uniqueidentifier
            ,ReportedIssueRootCauseAnalysisTypeCode int
            ,RootCauseAnalysis nvarchar(100)
            ,RootCauseAnalysisDescription nvarchar(400)
            ,RootCauseAnalysisOrder int
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_LoadReportedIssueRootCauseAnalysisFact @reportedIssueRootCauseAnalysisTable = @reportedIssueRootCauseAnalysisTable;

        -- load the ReportedIssueBranchOption data

        DECLARE @reportedIssueBranchOptionTable mart.ETL_ReportedIssueBranchOptionTable;

        INSERT INTO @reportedIssueBranchOptionTable
        (
            ReportedIssueId
            ,BranchId
            ,OptionId
            ,Branch
            ,[Option]
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.ReportedIssueBranchOptions')
        WITH
        (
            ReportedIssueId uniqueidentifier
            ,BranchId uniqueidentifier
            ,OptionId uniqueidentifier
            ,Branch nvarchar(100)
            ,[Option] nvarchar(250)
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainReportedIssueBranchOptionDimension @reportedIssueBranchOptionTable = @reportedIssueBranchOptionTable;

        EXEC mart.ETL_LoadReportedIssueBranchOptionFact @reportedIssueBranchOptionTable = @reportedIssueBranchOptionTable, @investigation = 0;

        -- load the ReportedIssueBodyPart data

        DECLARE @reportedIssueBodyPartTable mart.ETL_ReportedIssueBodyPartTable;

        INSERT INTO @reportedIssueBodyPartTable
        (
            ReportedIssueId
            ,ReportedIssueBodyPartId
            ,Question
            ,BodyParts
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.ReportedIssueBodyParts')
        WITH
        (
            ReportedIssueId uniqueidentifier
            ,ReportedIssueBodyPartId uniqueidentifier
            ,Question nvarchar(100)
            ,BodyParts bigint
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainReportedIssueBodyPartDimension @reportedIssueBodyPartTable = @reportedIssueBodyPartTable;

        EXEC mart.ETL_LoadReportedIssueBodyPartFact @reportedIssueBodyPartTable = @reportedIssueBodyPartTable, @investigation = 0;

        -- load the ReportedIssueOptionSelect data

        DECLARE @reportedIssueOptionSelectTable mart.ETL_ReportedIssueOptionSelectTable;

        INSERT INTO @reportedIssueOptionSelectTable
        (
            ReportedIssueId
            ,ChecklistId
            ,OptionId
            ,Question
            ,[Option]
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.ReportedIssueOptionSelects')
        WITH
        (
            ReportedIssueId uniqueidentifier
            ,ChecklistId uniqueidentifier
            ,OptionId uniqueidentifier
            ,Question nvarchar(100)
            ,[Option] nvarchar(250)
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainReportedIssueOptionSelectDimension @reportedIssueOptionSelectTable = @reportedIssueOptionSelectTable;

        EXEC mart.ETL_LoadReportedIssueOptionSelectFact @reportedIssueOptionSelectTable = @reportedIssueOptionSelectTable, @investigation = 0;

        -- load the ReportedIssuePerson data

        DECLARE @reportedIssuePersonTable mart.ETL_ReportedIssuePersonTable;

        INSERT INTO @reportedIssuePersonTable
        (
            ReportedIssueId
            ,PersonId
            ,OptionId
            ,Question
            ,[Option]
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.ReportedIssuePeople')
        WITH
        (
            ReportedIssueId uniqueidentifier
            ,PersonId uniqueidentifier
            ,OptionId uniqueidentifier
            ,Question nvarchar(100)
            ,[Option] nvarchar(50)
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainReportedIssuePersonDimension @reportedIssuePersonTable = @reportedIssuePersonTable;

        EXEC mart.ETL_LoadReportedIssuePersonFact @reportedIssuePersonTable = @reportedIssuePersonTable, @investigation = 0;

        -- load the ReportedIssueInvestigationBranchOption data

        DECLARE @reportedIssueInvestigationBranchOptionTable mart.ETL_ReportedIssueBranchOptionTable;

        INSERT INTO @reportedIssueInvestigationBranchOptionTable
        (
            ReportedIssueId
            ,BranchId
            ,OptionId
            ,Branch
            ,[Option]
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.ReportedIssueInvestigationBranchOptions')
        WITH
        (
            ReportedIssueId uniqueidentifier
            ,BranchId uniqueidentifier
            ,OptionId uniqueidentifier
            ,Branch nvarchar(100)
            ,[Option] nvarchar(250)
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainReportedIssueBranchOptionDimension @reportedIssueBranchOptionTable = @reportedIssueInvestigationBranchOptionTable;

        EXEC mart.ETL_LoadReportedIssueBranchOptionFact @reportedIssueBranchOptionTable = @reportedIssueInvestigationBranchOptionTable, @investigation = 1;

        -- load the ReportedIssueInvestigationBodyPart data

        DECLARE @reportedIssueInvestigationBodyPartTable mart.ETL_ReportedIssueBodyPartTable;

        INSERT INTO @reportedIssueInvestigationBodyPartTable
        (
            ReportedIssueId
            ,ReportedIssueBodyPartId
            ,Question
            ,BodyParts
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.ReportedIssueInvestigationBodyParts')
        WITH
        (
            ReportedIssueId uniqueidentifier
            ,ReportedIssueBodyPartId uniqueidentifier
            ,Question nvarchar(100)
            ,BodyParts bigint
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainReportedIssueBodyPartDimension @reportedIssueBodyPartTable = @reportedIssueInvestigationBodyPartTable;

        EXEC mart.ETL_LoadReportedIssueBodyPartFact @reportedIssueBodyPartTable = @reportedIssueInvestigationBodyPartTable, @investigation = 1;

        -- load the ReportedIssueInvestigationOptionSelect data

        DECLARE @reportedIssueInvestigationOptionSelectTable mart.ETL_ReportedIssueOptionSelectTable;

        INSERT INTO @reportedIssueInvestigationOptionSelectTable
        (
            ReportedIssueId
            ,ChecklistId
            ,OptionId
            ,Question
            ,[Option]
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.ReportedIssueInvestigationOptionSelects')
        WITH
        (
            ReportedIssueId uniqueidentifier
            ,ChecklistId uniqueidentifier
            ,OptionId uniqueidentifier
            ,Question nvarchar(100)
            ,[Option] nvarchar(250)
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainReportedIssueOptionSelectDimension @reportedIssueOptionSelectTable = @reportedIssueInvestigationOptionSelectTable;

        EXEC mart.ETL_LoadReportedIssueOptionSelectFact @reportedIssueOptionSelectTable = @reportedIssueInvestigationOptionSelectTable, @investigation = 1;

        -- load the ReportedIssueInvestigationPerson data

        DECLARE @reportedIssueInvestigationPersonTable mart.ETL_ReportedIssuePersonTable;

        INSERT INTO @reportedIssueInvestigationPersonTable
        (
            ReportedIssueId
            ,PersonId
            ,OptionId
            ,Question
            ,[Option]
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.ReportedIssueInvestigationPeople')
        WITH
        (
            ReportedIssueId uniqueidentifier
            ,PersonId uniqueidentifier
            ,OptionId uniqueidentifier
            ,Question nvarchar(100)
            ,[Option] nvarchar(50)
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainReportedIssuePersonDimension @reportedIssuePersonTable = @reportedIssueInvestigationPersonTable;

        EXEC mart.ETL_LoadReportedIssuePersonFact @reportedIssuePersonTable = @reportedIssueInvestigationPersonTable, @investigation = 1;

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
