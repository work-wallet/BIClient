DROP PROCEDURE IF EXISTS mart.ETL_LoadAssetInspections2;
GO

-- Top-level entry point for the AssetInspections2 dataset (proc name mirrors the dataType/URL convention:
-- WorkWallet.BI.ClientServices.DataStore.SQLService calls mart.ETL_Load{dataType})
CREATE PROCEDURE mart.ETL_LoadAssetInspections2
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

        -- maintain the GradingSetOption dimension table

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

        -- maintain the AssetInspectionType dimension table

        DECLARE @assetInspectionTypeTable mart.ETL_AssetInspectionTypeTable;

        INSERT INTO @assetInspectionTypeTable
        (
            InspectionTypeId
            ,InspectionTypeVersion
            ,InspectionType
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
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.InspectionTypes')
        WITH
        (
            InspectionTypeId uniqueidentifier
            ,InspectionTypeVersion int
            ,InspectionType nvarchar(500)
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
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainAssetInspectionTypeDimension @assetInspectionTypeTable = @assetInspectionTypeTable;

        -- maintain the AssetInspection dimension table (core)

        DECLARE @inspectionTable mart.ETL_AssetInspectionTable;

        INSERT INTO @inspectionTable
        (
            InspectionId
            ,AssetId
            ,InspectionStatusCode
            ,InspectionTypeId
            ,InspectionTypeVersion
            ,InspectedOn
            ,TotalScore
            ,TotalPotentialScore
            ,AverageScore
            ,AveragePotentialScore
            ,PercentageScore
            ,Defects
            ,Passed
            ,GradingSetOptionId
            ,ExternalIdentifier
            ,InspectedByCompany
            ,InProgressStatusDate
            ,ReadyForReviewStatusDate
            ,CompleteStatusDate
            ,ArchivedStatusDate
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.Inspections')
        WITH
        (
            InspectionId uniqueidentifier
            ,AssetId uniqueidentifier
            ,InspectionStatusCode int
            ,InspectionTypeId uniqueidentifier
            ,InspectionTypeVersion int
            ,InspectedOn datetime
            ,TotalScore int
            ,TotalPotentialScore int
            ,AverageScore decimal(38,6)
            ,AveragePotentialScore decimal(38,6)
            ,PercentageScore decimal(7,6)
            ,Defects int
            ,Passed int
            ,GradingSetOptionId uniqueidentifier
            ,ExternalIdentifier nvarchar(255)
            ,InspectedByCompany nvarchar(max)
            ,InProgressStatusDate datetimeoffset(7)
            ,ReadyForReviewStatusDate datetimeoffset(7)
            ,CompleteStatusDate datetimeoffset(7)
            ,ArchivedStatusDate datetimeoffset(7)
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainAssetInspectionDimension @inspectionTable = @inspectionTable;

        -- delete existing facts for the inspections being loaded (re-inserted below)

        EXEC mart.ETL_DeleteAssetInspectionFacts @inspectionTable = @inspectionTable;

        -- maintain the Contact dimension table (inspectors, observers, closers, observation-note authors)

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

        -- load the InspectionInspectors data

        DECLARE @assetInspectionInspectedByTable mart.ETL_AssetInspectionInspectedByTable;

        INSERT INTO @assetInspectionInspectedByTable
        (
            InspectionId
            ,ContactId
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.InspectionInspectors')
        WITH
        (
            InspectionId uniqueidentifier
            ,ContactId uniqueidentifier
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_LoadAssetInspectionInspectedByFact @assetInspectionInspectedByTable = @assetInspectionInspectedByTable;

        -- load the InspectionNumericAnswers data

        DECLARE @assetInspectionNumericAnswerTable mart.ETL_AssetInspectionNumericAnswerTable;

        INSERT INTO @assetInspectionNumericAnswerTable
        (
            InspectionId
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
        SELECT * FROM OPENJSON(@json, '$.InspectionNumericAnswers')
        WITH
        (
            InspectionId uniqueidentifier
            ,QuestionId uniqueidentifier
            ,Question nvarchar(max)
            ,Mandatory bit
            ,Scale int
            ,UnitCode int
            ,Answer decimal(35,6)
            ,SectionId uniqueidentifier
            ,Section nvarchar(250)
            ,OrderInSection int
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainAssetInspectionNumericQuestionDimension @assetInspectionNumericAnswerTable = @assetInspectionNumericAnswerTable;
        EXEC mart.ETL_LoadAssetInspectionNumericAnswerFact @assetInspectionNumericAnswerTable = @assetInspectionNumericAnswerTable;

        -- load the InspectionDateTimeAnswers data

        DECLARE @assetInspectionDateTimeAnswerTable mart.ETL_AssetInspectionDateTimeAnswerTable;

        INSERT INTO @assetInspectionDateTimeAnswerTable
        (
            InspectionId
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
        SELECT * FROM OPENJSON(@json, '$.InspectionDateTimeAnswers')
        WITH
        (
            InspectionId uniqueidentifier
            ,QuestionId uniqueidentifier
            ,Question nvarchar(max)
            ,Mandatory bit
            ,[Date] bit
            ,[Time] bit
            ,Answer datetime
            ,SectionId uniqueidentifier
            ,Section nvarchar(250)
            ,OrderInSection int
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainAssetInspectionDateTimeQuestionDimension @assetInspectionDateTimeAnswerTable = @assetInspectionDateTimeAnswerTable;
        EXEC mart.ETL_LoadAssetInspectionDateTimeAnswerFact @assetInspectionDateTimeAnswerTable = @assetInspectionDateTimeAnswerTable;

        -- load the InspectionChecklistAnswers data

        DECLARE @assetInspectionChecklistAnswerTable mart.ETL_AssetInspectionChecklistAnswerTable;

        INSERT INTO @assetInspectionChecklistAnswerTable
        (
            InspectionId
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
        SELECT * FROM OPENJSON(@json, '$.InspectionChecklistAnswers')
        WITH
        (
            InspectionId uniqueidentifier
            ,ChecklistId uniqueidentifier
            ,OptionId uniqueidentifier
            ,Question nvarchar(max)
            ,[Value] nvarchar(250)
            ,Mandatory bit
            ,[Order] int
            ,SectionId uniqueidentifier
            ,Section nvarchar(250)
            ,OrderInSection int
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainAssetInspectionChecklistOptionDimension @assetInspectionChecklistAnswerTable = @assetInspectionChecklistAnswerTable;
        EXEC mart.ETL_LoadAssetInspectionChecklistAnswerFact @assetInspectionChecklistAnswerTable = @assetInspectionChecklistAnswerTable;

        -- load the InspectionBranchOptions data

        DECLARE @assetInspectionBranchOptionTable mart.ETL_AssetInspectionBranchOptionTable;

        INSERT INTO @assetInspectionBranchOptionTable
        (
            InspectionId
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
        SELECT * FROM OPENJSON(@json, '$.InspectionBranchOptions')
        WITH
        (
            InspectionId uniqueidentifier
            ,BranchId uniqueidentifier
            ,OptionId uniqueidentifier
            ,Branch nvarchar(max)
            ,[Value] nvarchar(250)
            ,[Order] int
            ,SectionId uniqueidentifier
            ,Section nvarchar(250)
            ,OrderInSection int
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainAssetInspectionBranchOptionDimension @assetInspectionBranchOptionTable = @assetInspectionBranchOptionTable;
        EXEC mart.ETL_LoadAssetInspectionBranchOptionFact @assetInspectionBranchOptionTable = @assetInspectionBranchOptionTable;

        -- load the InspectionScoredResponses data

        DECLARE @assetInspectionScoredResponseTable mart.ETL_AssetInspectionScoredResponseTable;

        INSERT INTO @assetInspectionScoredResponseTable
        (
            InspectionId
            ,BranchId
            ,OptionId
            ,Branch
            ,[Value]
            ,[Order]
            ,TotalScore
            ,TotalPotentialScore
            ,PercentageScore
            ,Defect
            ,GradingSetOptionId
            ,SectionId
            ,Section
            ,OrderInSection
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.InspectionScoredResponses')
        WITH
        (
            InspectionId uniqueidentifier
            ,BranchId uniqueidentifier
            ,OptionId uniqueidentifier
            ,Branch nvarchar(max)
            ,[Value] nvarchar(100)
            ,[Order] int
            ,TotalScore int
            ,TotalPotentialScore int
            ,PercentageScore decimal(7,6)
            ,Defect bit
            ,GradingSetOptionId uniqueidentifier
            ,SectionId uniqueidentifier
            ,Section nvarchar(250)
            ,OrderInSection int
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainAssetInspectionScoredResponseDimension @assetInspectionScoredResponseTable = @assetInspectionScoredResponseTable;
        EXEC mart.ETL_LoadAssetInspectionScoredResponseFact @assetInspectionScoredResponseTable = @assetInspectionScoredResponseTable;

        -- load the InspectionScoreSections data

        DECLARE @assetInspectionScoreSectionTable mart.ETL_AssetInspectionScoreSectionTable;

        INSERT INTO @assetInspectionScoreSectionTable
        (
            InspectionId
            ,SectionId
            ,Section
            ,DisplayScore
            ,[Order]
            ,TotalScore
            ,TotalPotentialScore
            ,AverageScore
            ,AveragePotentialScore
            ,PercentageScore
            ,Defects
            ,Passed
            ,GradingSetOptionId
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.InspectionScoreSections')
        WITH
        (
            InspectionId uniqueidentifier
            ,SectionId uniqueidentifier
            ,Section nvarchar(250)
            ,DisplayScore bit
            ,[Order] int
            ,TotalScore int
            ,TotalPotentialScore int
            ,AverageScore decimal(38,6)
            ,AveragePotentialScore decimal(38,6)
            ,PercentageScore decimal(7,6)
            ,Defects int
            ,Passed int
            ,GradingSetOptionId uniqueidentifier
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainAssetInspectionScoreSectionDimension @assetInspectionScoreSectionTable = @assetInspectionScoreSectionTable;
        EXEC mart.ETL_LoadAssetInspectionScoreSectionFact @assetInspectionScoreSectionTable = @assetInspectionScoreSectionTable;

        -- load the InspectionScoreTags data

        DECLARE @assetInspectionScoreTagTable mart.ETL_AssetInspectionScoreTagTable;

        INSERT INTO @assetInspectionScoreTagTable
        (
            InspectionId
            ,TagId
            ,TagVersion
            ,Tag
            ,TotalScore
            ,TotalPotentialScore
            ,AverageScore
            ,AveragePotentialScore
            ,PercentageScore
            ,Defects
            ,GradingSetOptionId
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.InspectionScoreTags')
        WITH
        (
            InspectionId uniqueidentifier
            ,TagId uniqueidentifier
            ,TagVersion int
            ,Tag nvarchar(250)
            ,TotalScore int
            ,TotalPotentialScore int
            ,AverageScore decimal(38,6)
            ,AveragePotentialScore decimal(38,6)
            ,PercentageScore decimal(7,6)
            ,Defects int
            ,GradingSetOptionId uniqueidentifier
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainAssetInspectionScoreTagDimension @assetInspectionScoreTagTable = @assetInspectionScoreTagTable;
        EXEC mart.ETL_LoadAssetInspectionScoreTagFact @assetInspectionScoreTagTable = @assetInspectionScoreTagTable;

        -- maintain the AssetObservation dimension table (observations linked to the extracted inspections)

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

        -- load the InspectionObservations link data

        DECLARE @inspectionObservationTable mart.ETL_AssetInspectionObservationTable;

        INSERT INTO @inspectionObservationTable
        (
            InspectionId
            ,ObservationId
            ,WorkflowComponentId
            ,WorkflowComponentTypeCode
            ,WorkflowComponentDescription
            ,[New]
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.InspectionObservations')
        WITH
        (
            InspectionId uniqueidentifier
            ,ObservationId uniqueidentifier
            ,WorkflowComponentId uniqueidentifier
            ,WorkflowComponentTypeCode int
            ,WorkflowComponentDescription nvarchar(max)
            ,[New] bit
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_LoadAssetInspectionObservationFact @inspectionObservationTable = @inspectionObservationTable;

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
