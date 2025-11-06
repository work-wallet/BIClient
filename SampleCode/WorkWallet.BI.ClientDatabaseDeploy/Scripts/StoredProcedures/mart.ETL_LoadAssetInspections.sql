DROP PROCEDURE IF EXISTS mart.ETL_LoadAssetInspections;
GO

CREATE PROCEDURE mart.ETL_LoadAssetInspections
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

        -- maintain the AssetInspection dimension table

        DECLARE @inspectionTable mart.ETL_AssetInspectionTable;

        INSERT INTO @inspectionTable
        (
            AssetId
            ,InspectionId
            ,InspectionTypeId
            ,InspectionType
            ,InspectionDate
            ,InspectedBy
            ,Deleted
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.Inspections')
        WITH
        (
            AssetId uniqueidentifier
            ,InspectionId uniqueidentifier
            ,InspectionTypeId uniqueidentifier
            ,InspectionType nvarchar(75)
            ,InspectionDate datetime
            ,InspectedBy nvarchar(81)
            ,Deleted bit
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainAssetInspectionDimension @inspectionTable = @inspectionTable;

        -- maintain the AssetInspectionChecklistItem dimension table
        -- Note: ChecklistDisplayOrder is extracted from the API but deliberately not maintained in the dimension table.
        -- Different inspection types can have the same checklist in different display orders, so the order is 
        -- context-dependent and not an attribute of the checklist itself. ChecklistItemDisplayOrder is maintained
        -- as it represents the canonical order within a checklist.

        DECLARE @checklistItemTable mart.ETL_AssetInspectionChecklistItemTable;

        INSERT INTO @checklistItemTable
        (
            AssetId
            ,InspectionId
            ,ChecklistId
            ,ChecklistName
            ,ChecklistDisplayOrder
            ,ChecklistItemId
            ,ChecklistItemName
            ,ChecklistItemDisplayOrder
            ,Response
            ,ResponseText
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.ChecklistItemStatuses')
        WITH
        (
            AssetId uniqueidentifier
            ,InspectionId uniqueidentifier
            ,ChecklistId uniqueidentifier
            ,ChecklistName nvarchar(250)
            ,ChecklistDisplayOrder int
            ,ChecklistItemId uniqueidentifier
            ,ChecklistItemName nvarchar(250)
            ,ChecklistItemDisplayOrder int
            ,Response int
            ,ResponseText nvarchar(64)
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainAssetInspectionChecklistItemDimension @checklistItemTable = @checklistItemTable;

        -- maintain the AssetInspectionProperty dimension table
        -- Note: PropertyId and DisplayOrder are not extracted from the source API to maintain consistency
        -- with the existing mart.AssetProperty table design, which uses Property name as the business key.

        DECLARE @inspectionPropertyTable mart.ETL_AssetInspectionPropertyTable;

        INSERT INTO @inspectionPropertyTable
        (
            AssetId
            ,InspectionId
            ,Property
            ,PropertyType
            ,[Value]
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.InspectionProperties')
        WITH
        (
            AssetId uniqueidentifier
            ,InspectionId uniqueidentifier
            ,Property nvarchar(250)
            ,PropertyType nvarchar(20)
            ,[Value] nvarchar(max)
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainAssetInspectionPropertyDimension @inspectionPropertyTable = @inspectionPropertyTable;

        -- maintain the AssetObservation dimension table

        DECLARE @observationTable mart.ETL_AssetObservationTable;

        INSERT INTO @observationTable
        (
            AssetId
            ,ObservationId
            ,Details
            ,ActionTaken
            ,ObservationStatusCode
            ,ObservedOn
            ,ObservedBy
            ,Deleted
            ,ClosedOn
            ,ClosedBy
            ,ClosureNotes
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.Observations')
        WITH
        (
            AssetId uniqueidentifier
            ,ObservationId uniqueidentifier
            ,Details nvarchar(max)
            ,ActionTaken nvarchar(max)
            ,ObservationStatusCode int
            ,ObservedOn datetimeoffset(7)
            ,ObservedBy nvarchar(81)
            ,Deleted bit
            ,ClosedOn datetimeoffset(7)
            ,ClosedBy nvarchar(81)
            ,ClosureNotes nvarchar(max)
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainAssetObservationDimension @observationTable = @observationTable;

        -- delete existing facts for the inspections being loaded

        EXEC mart.ETL_DeleteAssetInspectionFacts @inspectionTable = @inspectionTable;

        -- load AssetInspectionPropertyFact

        EXEC mart.ETL_LoadAssetInspectionPropertyFact @inspectionPropertyTable = @inspectionPropertyTable;

        -- load AssetInspectionChecklistItemFact

        EXEC mart.ETL_LoadAssetInspectionChecklistItemFact @checklistItemTable = @checklistItemTable;

        -- load AssetInspectionObservationFact

        DECLARE @inspectionObservationTable mart.ETL_AssetInspectionObservationTable;

        INSERT INTO @inspectionObservationTable
        (
            InspectionId
            ,ObservationId
            ,ChecklistItemId
            ,[New]
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.InspectionObservations')
        WITH
        (
            InspectionId uniqueidentifier
            ,ObservationId uniqueidentifier
            ,ChecklistItemId uniqueidentifier
            ,[New] bit
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_LoadAssetInspectionObservationFact @inspectionObservationTable = @inspectionObservationTable;

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO
