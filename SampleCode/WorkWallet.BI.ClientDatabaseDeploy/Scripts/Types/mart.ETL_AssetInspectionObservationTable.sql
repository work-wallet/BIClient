DROP TYPE IF EXISTS mart.ETL_AssetInspectionObservationTable;
GO

CREATE TYPE mart.ETL_AssetInspectionObservationTable AS TABLE
(
    InspectionId uniqueidentifier NOT NULL
    ,ObservationId uniqueidentifier NOT NULL
    ,WorkflowComponentId uniqueidentifier NULL -- allow NULLs (observation not linked to a specific workflow component)
    ,WorkflowComponentTypeCode int NULL -- allow NULLs (null whenever WorkflowComponentId is null)
    ,WorkflowComponentDescription nvarchar(max) NOT NULL -- empty string when WorkflowComponentId is null
    ,[New] bit NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (InspectionId, ObservationId)
);
GO
