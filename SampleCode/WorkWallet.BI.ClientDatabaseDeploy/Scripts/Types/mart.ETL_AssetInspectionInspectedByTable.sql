DROP TYPE IF EXISTS mart.ETL_AssetInspectionInspectedByTable;
GO

CREATE TYPE mart.ETL_AssetInspectionInspectedByTable AS TABLE
(
    InspectionId uniqueidentifier NOT NULL
    ,ContactId uniqueidentifier NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (InspectionId, ContactId)
);
GO
