DROP TYPE IF EXISTS mart.ETL_AssetInspectionChecklistItemTable;
GO

CREATE TYPE mart.ETL_AssetInspectionChecklistItemTable AS TABLE
(
    AssetId uniqueidentifier NOT NULL
    ,InspectionId uniqueidentifier NOT NULL
    ,ChecklistId uniqueidentifier NOT NULL
    ,ChecklistName nvarchar(250) NOT NULL
    ,ChecklistDisplayOrder int NOT NULL
    ,ChecklistItemId uniqueidentifier NOT NULL
    ,ChecklistItemName nvarchar(250) NOT NULL
    ,ChecklistItemDisplayOrder int NOT NULL
    ,Response int NOT NULL
    ,ResponseText nvarchar(64) NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (InspectionId, ChecklistItemId)
);
GO
