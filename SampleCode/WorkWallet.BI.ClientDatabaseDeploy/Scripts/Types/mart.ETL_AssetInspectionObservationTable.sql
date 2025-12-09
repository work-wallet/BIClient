DROP TYPE IF EXISTS mart.ETL_AssetInspectionObservationTable;
GO

CREATE TYPE mart.ETL_AssetInspectionObservationTable AS TABLE
(
    InspectionId uniqueidentifier NOT NULL
    ,ObservationId uniqueidentifier NOT NULL
    ,ChecklistItemId uniqueidentifier NULL -- allow NULLs
    ,[New] bit NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (InspectionId, ObservationId)
);
GO
