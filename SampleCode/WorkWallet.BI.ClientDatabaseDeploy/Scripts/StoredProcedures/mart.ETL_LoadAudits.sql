DROP PROCEDURE IF EXISTS mart.ETL_LoadAudits;
GO

CREATE PROCEDURE mart.ETL_LoadAudits
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

        -- maintain GradingSetOptionTable dimension

        DECLARE @gradingSetOptionTable mart.ETL_GradingSetOptionTable;

        INSERT INTO @gradingSetOptionTable
        (
            GradingSetId
            ,GradingSetVersion
            ,GradingSetOptionId
            ,GradingSet
            ,GradingSetOption
            ,[Value]
            ,ColourHex
            ,GradingSetIsPercentage
            ,GradingSetIsScore
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.GradingSetOptions')
        WITH
        (
            GradingSetId uniqueidentifier
            ,GradingSetVersion int
            ,GradingSetOptionId uniqueidentifier
            ,GradingSet nvarchar(100)
            ,GradingSetOption nvarchar(250)
            ,[Value] int
            ,ColourHex nvarchar(7)
            ,GradingSetIsPercentage bit
            ,GradingSetIsScore bit
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainGradingSetOptionDimension @gradingSetOptionTable = @gradingSetOptionTable;
        
        -- maintain AuditType dimension

        DECLARE @auditTypeTable mart.ETL_AuditTypeTable;

        INSERT INTO @auditTypeTable
        (
            AuditTypeId
            ,AuditTypeVersion
            ,AuditType
            ,[Description]
            ,ScoringEnabled
            ,DisplayPercentage
            ,DisplayTotalScore
            ,DisplayAverageScore
            ,GradingSetId
            ,GradingSetVersion
            ,GradingSet
            ,GradingSetIsPercentage
            ,GradingSetIsScore
            ,ReportingEnabled
            ,ReportingAbbreviation
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.AuditTypes')
        WITH
        (
            AuditTypeId uniqueidentifier
            ,AuditTypeVersion int
            ,AuditType nvarchar(500)
            ,[Description] nvarchar(2000)
            ,ScoringEnabled bit
            ,DisplayPercentage bit
            ,DisplayTotalScore bit
            ,DisplayAverageScore bit
            ,GradingSetId uniqueidentifier
            ,GradingSetVersion int
            ,GradingSet nvarchar(100)
            ,GradingSetIsPercentage bit
            ,GradingSetIsScore bit
            ,ReportingEnabled bit
            ,ReportingAbbreviation nvarchar(4)
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainAuditTypeDimension @auditTypeTable = @auditTypeTable;

        -- maintain Audit dimension

        DECLARE @auditTable mart.ETL_AuditTable;

        INSERT INTO @auditTable
        (
            AuditId
            ,Reference
            ,AuditReference
            ,AuditGroupId
            ,AuditGroup
            ,AuditStatusCode
            ,AuditTypeId
            ,AuditTypeVersion
            ,LocationId
            ,InspectedOn
            ,TotalScore
            ,TotalPotentialScore
            ,AverageScore
            ,AveragePotentialScore
            ,PercentageScore
            ,Flags
            ,GradingSetOptionId
            ,ExternalIdentifier
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.Audits')
        WITH
        (
            AuditId uniqueidentifier
            ,Reference int
            ,AuditReference nvarchar(50)
            ,AuditGroupId uniqueidentifier
            ,AuditGroup nvarchar(40)
            ,AuditStatusCode int
            ,AuditTypeId uniqueidentifier
            ,AuditTypeVersion int
            ,LocationId uniqueidentifier
            ,InspectedOn datetime
            ,TotalScore int
            ,TotalPotentialScore int
            ,AverageScore decimal(38,6)
            ,AveragePotentialScore decimal(38,6)
            ,PercentageScore decimal(7,6)
            ,Flags int
            ,GradingSetOptionId uniqueidentifier
            ,ExternalIdentifier nvarchar(255)
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainAuditGroupDimension @auditTable = @auditTable;
        EXEC mart.ETL_MaintainAuditDimension @auditTable = @auditTable;

        EXEC mart.ETL_DeleteAuditFacts @auditTable = @auditTable;

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

        -- load the AuditInspectedBy data

        DECLARE @auditInspectedByTable mart.ETL_AuditInspectedByTable;

        INSERT INTO @auditInspectedByTable
        (
            AuditId
            ,ContactId
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.AuditInspectors')
        WITH
        (
            AuditId uniqueidentifier
            ,ContactId uniqueidentifier
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_LoadAuditInspectedByFact @auditInspectedByTable = @auditInspectedByTable;

        -- load the AuditNumericAnswer data

        DECLARE @auditNumericAnswerTable mart.ETL_AuditNumericAnswerTable;

        INSERT INTO @auditNumericAnswerTable
        (
            AuditId
            ,QuestionId
            ,Question
            ,Mandatory
            ,Scale
            ,UnitCode
            ,Answer
            ,SectionId
            ,Section
            ,OrderInSection
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.AuditNumericAnswers')
        WITH
        (
            AuditId uniqueidentifier
            ,QuestionId uniqueidentifier
            ,Question nvarchar(500)
            ,Mandatory bit
            ,Scale int
            ,UnitCode int
            ,Answer decimal(35,6)
            ,SectionId uniqueidentifier
            ,Section nvarchar(250)
            ,OrderInSection int
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainAuditNumericQuestionDimension @auditNumericAnswerTable = @auditNumericAnswerTable;
        EXEC mart.ETL_LoadAuditNumericAnswerFact @auditNumericAnswerTable = @auditNumericAnswerTable;

        -- load the AuditDateTimeAnswer data

        DECLARE @auditDateTimeAnswerTable mart.ETL_AuditDateTimeAnswerTable;

        INSERT INTO @auditDateTimeAnswerTable
        (
            AuditId
            ,QuestionId
            ,Question
            ,Mandatory
            ,[Date]
            ,[Time]
            ,Answer
            ,SectionId
            ,Section
            ,OrderInSection
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.AuditDateTimeAnswers')
        WITH
        (
            AuditId uniqueidentifier
            ,QuestionId uniqueidentifier
            ,Question nvarchar(500)
            ,Mandatory bit
            ,[Date] bit
            ,[Time] bit
            ,Answer datetime
            ,SectionId uniqueidentifier
            ,Section nvarchar(250)
            ,OrderInSection int
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainAuditDateTimeQuestionDimension @auditDateTimeAnswerTable = @auditDateTimeAnswerTable;
        EXEC mart.ETL_LoadAuditDateTimeAnswerFact @auditDateTimeAnswerTable = @auditDateTimeAnswerTable;

        -- load the AuditChecklistAnswer data

        DECLARE @auditChecklistAnswerTable mart.ETL_AuditChecklistAnswerTable;

        INSERT INTO @auditChecklistAnswerTable
        (
            AuditId
            ,ChecklistId
            ,OptionId
            ,Question
            ,[Value]
            ,Mandatory
            ,[Order]
            ,SectionId
            ,Section
            ,OrderInSection
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.AuditChecklistAnswers')
        WITH
        (
            AuditId uniqueidentifier
            ,ChecklistId uniqueidentifier
            ,OptionId uniqueidentifier
            ,Question nvarchar(100)
            ,[Value] nvarchar(250)
            ,Mandatory bit
            ,[Order] int
            ,SectionId uniqueidentifier
            ,Section nvarchar(250)
            ,OrderInSection int
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainAuditChecklistOptionDimension @auditChecklistAnswerTable = @auditChecklistAnswerTable;
        EXEC mart.ETL_LoadAuditChecklistAnswerFact @auditChecklistAnswerTable = @auditChecklistAnswerTable;

        -- load the AuditBranchOption data

        DECLARE @auditBranchOptionTable mart.ETL_AuditBranchOptionTable;

        INSERT INTO @auditBranchOptionTable
        (
            AuditId
            ,BranchId
            ,OptionId
            ,Branch
            ,[Value]
            ,[Order]
            ,SectionId
            ,Section
            ,OrderInSection
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.AuditBranchOptions')
        WITH
        (
            AuditId uniqueidentifier
            ,BranchId uniqueidentifier
            ,OptionId uniqueidentifier
            ,Branch nvarchar(100)
            ,[Value] nvarchar(250)
            ,[Order] int
            ,SectionId uniqueidentifier
            ,Section nvarchar(250)
            ,OrderInSection int
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainAuditBranchOptionDimension @auditBranchOptionTable = @auditBranchOptionTable;
        EXEC mart.ETL_LoadAuditBranchOptionFact @auditBranchOptionTable = @auditBranchOptionTable;

        -- load the AuditScoredResponse data

        DECLARE @auditScoredResponseTable mart.ETL_AuditScoredResponseTable;

        INSERT INTO @auditScoredResponseTable
        (
            AuditId
            ,BranchId
            ,OptionId
            ,Branch
            ,[Value]
            ,[Order]
            ,TotalScore
            ,TotalPotentialScore
            ,PercentageScore
            ,Flag
            ,GradingSetOptionId
            ,SectionId
            ,Section
            ,OrderInSection
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.AuditScoredResponses')
        WITH
        (
            AuditId uniqueidentifier
            ,BranchId uniqueidentifier
            ,OptionId uniqueidentifier
            ,Branch nvarchar(500)
            ,[Value] nvarchar(100)
            ,[Order] int
            ,TotalScore int
            ,TotalPotentialScore int
            ,PercentageScore decimal(7,6)
            ,Flag bit
            ,GradingSetOptionId uniqueidentifier
            ,SectionId uniqueidentifier
            ,Section nvarchar(250)
            ,OrderInSection int
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainAuditScoredResponseDimension @auditScoredResponseTable = @auditScoredResponseTable;
        EXEC mart.ETL_LoadAuditScoredResponseFact @auditScoredResponseTable = @auditScoredResponseTable;

        -- load the AuditScoreSection data

        DECLARE @auditScoreSectionTable mart.ETL_AuditScoreSectionTable;

        INSERT INTO @auditScoreSectionTable
        (
            AuditId
            ,SectionId
            ,Section
            ,DisplayScore
            ,[Order]
            ,TotalScore
            ,TotalPotentialScore
            ,AverageScore
            ,AveragePotentialScore
            ,PercentageScore
            ,Flags
            ,GradingSetOptionId
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.AuditScoreSections')
        WITH
        (
            AuditId uniqueidentifier
            ,SectionId uniqueidentifier
            ,Section nvarchar(250)
            ,DisplayScore bit
            ,[Order] int
            ,TotalScore int
            ,TotalPotentialScore int
            ,AverageScore decimal(38,6)
            ,AveragePotentialScore decimal(38,6)
            ,PercentageScore decimal(7,6)
            ,Flags int
            ,GradingSetOptionId uniqueidentifier
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainAuditScoreSectionDimension @auditScoreSectionTable = @auditScoreSectionTable;
        EXEC mart.ETL_LoadAuditScoreSectionFact @auditScoreSectionTable = @auditScoreSectionTable;

        -- load the AuditScoreTag data

        DECLARE @auditScoreTagTable mart.ETL_AuditScoreTagTable;

        INSERT INTO @auditScoreTagTable
        (
            AuditId
            ,TagId
            ,TagVersion
            ,Tag
            ,TotalScore
            ,TotalPotentialScore
            ,AverageScore
            ,AveragePotentialScore
            ,PercentageScore
            ,Flags
            ,GradingSetOptionId
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.AuditScoreTags')
        WITH
        (
            AuditId uniqueidentifier
            ,TagId uniqueidentifier
            ,TagVersion int
            ,Tag nvarchar(250)
            ,TotalScore int
            ,TotalPotentialScore int
            ,AverageScore decimal(38,6)
            ,AveragePotentialScore decimal(38,6)
            ,PercentageScore decimal(7,6)
            ,Flags int
            ,GradingSetOptionId uniqueidentifier
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainAuditScoreTagDimension @auditScoreTagTable = @auditScoreTagTable;
        EXEC mart.ETL_LoadAuditScoreTagFact @auditScoreTagTable = @auditScoreTagTable;

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
