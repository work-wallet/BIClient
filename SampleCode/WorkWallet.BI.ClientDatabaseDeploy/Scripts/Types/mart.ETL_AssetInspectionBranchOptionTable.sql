DROP TYPE IF EXISTS mart.ETL_AssetInspectionBranchOptionTable;
GO

CREATE TYPE mart.ETL_AssetInspectionBranchOptionTable AS TABLE
(
    InspectionId uniqueidentifier NOT NULL
    ,BranchId uniqueidentifier NOT NULL
    ,OptionId uniqueidentifier NOT NULL
    ,Branch nvarchar(max) NOT NULL
    ,[Value] nvarchar(250) NOT NULL
    ,[Order] int NOT NULL
    ,SectionId uniqueidentifier NOT NULL
    ,Section nvarchar(250) NOT NULL
    ,OrderInSection int NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (InspectionId, BranchId, OptionId)
);
GO
