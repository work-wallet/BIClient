DROP TYPE IF EXISTS mart.ETL_AssetInspectionChecklistAnswerTable;
GO

CREATE TYPE mart.ETL_AssetInspectionChecklistAnswerTable AS TABLE
(
    InspectionId uniqueidentifier NOT NULL
    ,ChecklistId uniqueidentifier NOT NULL
    ,OptionId uniqueidentifier NOT NULL
    ,Question nvarchar(max) NOT NULL
    ,[Value] nvarchar(250) NOT NULL
    ,Mandatory bit NOT NULL
    ,[Order] int NOT NULL
    ,SectionId uniqueidentifier NOT NULL
    ,Section nvarchar(250) NOT NULL
    ,OrderInSection int NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (InspectionId, ChecklistId, OptionId)
);
GO
