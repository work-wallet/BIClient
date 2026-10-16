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
            ,AllDepartments
            ,ExternalIdentifier
            ,SiteStatus
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
            ,Department nvarchar(50)
            ,AllDepartments nvarchar(max)
            ,ExternalIdentifier nvarchar(255)
            ,SiteStatus nvarchar(80)
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainLocationDimension @locationTable = @locationTable;

        -- load the Contact dimension

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
            ,ReportedByContactId
            ,ReportedByCompany
            ,ReportedIssueStatusCode
            ,SubcategoryId
            ,CategoryVersion
            ,LocationId
            ,ReportedIssueOverview
            ,ReportedIssueSeverityCode
            ,WalletId
            ,UnderInvestigationDate
            ,CloseDate
            ,LeadInvestigatorContactId
        )
        SELECT * FROM OPENJSON(@json, '$.ReportedIssues')
        WITH
        (
            ReportedIssueId uniqueidentifier
            ,ReportedIssueReference nvarchar(50)
            ,OccurredOn datetime2(7)
            ,ReportedOn datetime2(7)
            ,ReportedBy nvarchar(max)
            ,ReportedByContactId uniqueidentifier
            ,ReportedByCompany nvarchar(max)
            ,ReportedIssueStatusCode int
            ,SubcategoryId uniqueidentifier
            ,CategoryVersion int
            ,LocationId uniqueidentifier
            ,ReportedIssueOverview nvarchar(max)
            ,ReportedIssueSeverityCode int
            ,WalletId uniqueidentifier
            ,UnderInvestigationDate datetimeoffset(7)
            ,CloseDate datetimeoffset(7)
            ,LeadInvestigatorContactId uniqueidentifier -- nullable; key omitted from JSON when no lead investigator assigned
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
            ,Branch nvarchar(500)
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
            ,Question nvarchar(500)
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
            ,Question nvarchar(500)
            ,[Option] nvarchar(250)
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainReportedIssueOptionSelectDimension @reportedIssueOptionSelectTable = @reportedIssueOptionSelectTable;

        EXEC mart.ETL_LoadReportedIssueOptionSelectFact @reportedIssueOptionSelectTable = @reportedIssueOptionSelectTable, @investigation = 0;

        -- load the ReportedIssuePerson2 data (enriched detail: PersonOptionTypeCode, ContactId, FirstName, LastName, Email;
        -- also a superset of ReportedIssuePeople, additionally including N/A answers)

        DECLARE @reportedIssuePersonTable2 mart.ETL_ReportedIssuePersonTable2;

        INSERT INTO @reportedIssuePersonTable2
        (
            ReportedIssuePersonId
            ,ReportedIssueId
            ,PersonId
            ,OptionId
            ,Question
            ,[Option]
            ,PersonOptionTypeCode
            ,ContactId
            ,FirstName
            ,LastName
            ,Email
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.ReportedIssuePeople2')
        WITH
        (
            ReportedIssuePersonId uniqueidentifier
            ,ReportedIssueId uniqueidentifier
            ,PersonId uniqueidentifier
            ,OptionId uniqueidentifier
            ,Question nvarchar(500)
            ,[Option] nvarchar(50)
            ,PersonOptionTypeCode int
            ,ContactId uniqueidentifier
            ,FirstName nvarchar(max)
            ,LastName nvarchar(max)
            ,Email nvarchar(max)
            ,WalletId uniqueidentifier
        );

        -- seed the shared ReportedIssuePerson dimension from the full superset (including N/A answers) so it covers
        -- both ReportedIssuePersonFact2 below and the deprecated ReportedIssuePersonFact derived further down
        DECLARE @reportedIssuePersonDimensionTable mart.ETL_ReportedIssuePersonTable;

        INSERT INTO @reportedIssuePersonDimensionTable
        (
            ReportedIssueId
            ,PersonId
            ,OptionId
            ,Question
            ,[Option]
            ,WalletId
        )
        SELECT DISTINCT
            ReportedIssueId
            ,PersonId
            ,OptionId
            ,Question
            ,[Option]
            ,WalletId
        FROM @reportedIssuePersonTable2;

        EXEC mart.ETL_MaintainReportedIssuePersonDimension @reportedIssuePersonTable = @reportedIssuePersonDimensionTable;

        EXEC mart.ETL_LoadReportedIssuePersonFact2 @reportedIssuePersonTable2 = @reportedIssuePersonTable2, @investigation = 0;

        -- load the deprecated ReportedIssuePeople data, derived from ReportedIssuePeople2 by excluding N/A answers
        -- (the deprecated dataset never included them); the dimension is already seeded above

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
        SELECT DISTINCT
            ReportedIssueId
            ,PersonId
            ,OptionId
            ,Question
            ,[Option]
            ,WalletId
        FROM @reportedIssuePersonTable2
        WHERE PersonOptionTypeCode <> -1;

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
            ,Branch nvarchar(500)
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
            ,Question nvarchar(500)
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
            ,Question nvarchar(500)
            ,[Option] nvarchar(250)
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainReportedIssueOptionSelectDimension @reportedIssueOptionSelectTable = @reportedIssueInvestigationOptionSelectTable;

        EXEC mart.ETL_LoadReportedIssueOptionSelectFact @reportedIssueOptionSelectTable = @reportedIssueInvestigationOptionSelectTable, @investigation = 1;

        -- load the ReportedIssueInvestigationPerson2 data (enriched detail: PersonOptionTypeCode, ContactId, FirstName, LastName, Email;
        -- also a superset of ReportedIssueInvestigationPeople, additionally including N/A answers)

        DECLARE @reportedIssueInvestigationPersonTable2 mart.ETL_ReportedIssuePersonTable2;

        INSERT INTO @reportedIssueInvestigationPersonTable2
        (
            ReportedIssuePersonId
            ,ReportedIssueId
            ,PersonId
            ,OptionId
            ,Question
            ,[Option]
            ,PersonOptionTypeCode
            ,ContactId
            ,FirstName
            ,LastName
            ,Email
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.ReportedIssueInvestigationPeople2')
        WITH
        (
            ReportedIssuePersonId uniqueidentifier '$.ReportedIssueInvestigationPersonId'
            ,ReportedIssueId uniqueidentifier
            ,PersonId uniqueidentifier
            ,OptionId uniqueidentifier
            ,Question nvarchar(500)
            ,[Option] nvarchar(50)
            ,PersonOptionTypeCode int
            ,ContactId uniqueidentifier
            ,FirstName nvarchar(max)
            ,LastName nvarchar(max)
            ,Email nvarchar(max)
            ,WalletId uniqueidentifier
        );

        -- seed the shared ReportedIssuePerson dimension from the full superset (including N/A answers) so it covers
        -- both ReportedIssuePersonFact2 below and the deprecated ReportedIssuePersonFact derived further down
        DECLARE @reportedIssueInvestigationPersonDimensionTable mart.ETL_ReportedIssuePersonTable;

        INSERT INTO @reportedIssueInvestigationPersonDimensionTable
        (
            ReportedIssueId
            ,PersonId
            ,OptionId
            ,Question
            ,[Option]
            ,WalletId
        )
        SELECT DISTINCT
            ReportedIssueId
            ,PersonId
            ,OptionId
            ,Question
            ,[Option]
            ,WalletId
        FROM @reportedIssueInvestigationPersonTable2;

        EXEC mart.ETL_MaintainReportedIssuePersonDimension @reportedIssuePersonTable = @reportedIssueInvestigationPersonDimensionTable;

        EXEC mart.ETL_LoadReportedIssuePersonFact2 @reportedIssuePersonTable2 = @reportedIssueInvestigationPersonTable2, @investigation = 1;

        -- load the deprecated ReportedIssueInvestigationPeople data, derived from ReportedIssueInvestigationPeople2 by
        -- excluding N/A answers (the deprecated dataset never included them); the dimension is already seeded above

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
        SELECT DISTINCT
            ReportedIssueId
            ,PersonId
            ,OptionId
            ,Question
            ,[Option]
            ,WalletId
        FROM @reportedIssueInvestigationPersonTable2
        WHERE PersonOptionTypeCode <> -1;

        EXEC mart.ETL_LoadReportedIssuePersonFact @reportedIssuePersonTable = @reportedIssueInvestigationPersonTable, @investigation = 1;

        -- load the ReportedIssueInvestigationTeam data

        DECLARE @reportedIssueInvestigationTeamTable mart.ETL_ReportedIssueInvestigationTeamTable;

        INSERT INTO @reportedIssueInvestigationTeamTable
        (
            ReportedIssueId
            ,ContactId
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.ReportedIssueInvestigationTeam')
        WITH
        (
            ReportedIssueId uniqueidentifier
            ,ContactId uniqueidentifier
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_LoadReportedIssueInvestigationTeamFact @reportedIssueInvestigationTeamTable = @reportedIssueInvestigationTeamTable;

        -- load the ReportedIssueInvestigationNumericAnswer data

        DECLARE @reportedIssueInvestigationNumericAnswerTable mart.ETL_ReportedIssueNumericAnswerTable;

        INSERT INTO @reportedIssueInvestigationNumericAnswerTable
        (
            ReportedIssueId
            ,NumberId
            ,Question
            ,Scale
            ,UnitCode
            ,Answer
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.ReportedIssueInvestigationNumericAnswers')
        WITH
        (
            ReportedIssueId uniqueidentifier
            ,NumberId uniqueidentifier
            ,Question nvarchar(500)
            ,Scale int
            ,UnitCode int
            ,Answer decimal(35,6)
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainReportedIssueNumericQuestionDimension @reportedIssueNumericAnswerTable = @reportedIssueInvestigationNumericAnswerTable;

        EXEC mart.ETL_LoadReportedIssueNumericAnswerFact @reportedIssueNumericAnswerTable = @reportedIssueInvestigationNumericAnswerTable, @investigation = 1;

        -- load the ReportedIssueInvestigationDateTimeAnswer data

        DECLARE @reportedIssueInvestigationDateTimeAnswerTable mart.ETL_ReportedIssueDateTimeAnswerTable;

        INSERT INTO @reportedIssueInvestigationDateTimeAnswerTable
        (
            ReportedIssueId
            ,DateTimeId
            ,Question
            ,[Date]
            ,[Time]
            ,Answer
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.ReportedIssueInvestigationDateTimeAnswers')
        WITH
        (
            ReportedIssueId uniqueidentifier
            ,DateTimeId uniqueidentifier
            ,Question nvarchar(500)
            ,[Date] bit
            ,[Time] bit
            ,Answer datetime
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainReportedIssueDateTimeQuestionDimension @reportedIssueDateTimeAnswerTable = @reportedIssueInvestigationDateTimeAnswerTable;

        EXEC mart.ETL_LoadReportedIssueDateTimeAnswerFact @reportedIssueDateTimeAnswerTable = @reportedIssueInvestigationDateTimeAnswerTable, @investigation = 1;

        -- load the ReportedIssueInvestigationSignature data

        DECLARE @reportedIssueInvestigationSignatureTable mart.ETL_ReportedIssueSignatureTable;

        INSERT INTO @reportedIssueInvestigationSignatureTable
        (
            ReportedIssueSignatureId
            ,ReportedIssueId
            ,SignatureId
            ,[Name]
            ,PersonOptionTypeCode
            ,ContactId
            ,JobTitle
            ,[Description]
            ,SignedOn
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.ReportedIssueInvestigationSignatures')
        WITH
        (
            ReportedIssueSignatureId uniqueidentifier '$.ReportedIssueInvestigationSignatureId'
            ,ReportedIssueId uniqueidentifier
            ,SignatureId uniqueidentifier
            ,[Name] nvarchar(max)
            ,PersonOptionTypeCode int
            ,ContactId uniqueidentifier -- nullable; key omitted from JSON for 'Other' (typed-in) signatories
            ,JobTitle nvarchar(50)
            ,[Description] nvarchar(250)
            ,SignedOn datetime -- nullable; key omitted from JSON when not set
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_LoadReportedIssueSignatureFact @reportedIssueSignatureTable = @reportedIssueInvestigationSignatureTable, @investigation = 1;

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
