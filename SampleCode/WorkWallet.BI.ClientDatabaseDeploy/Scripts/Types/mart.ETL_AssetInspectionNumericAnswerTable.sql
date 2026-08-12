DROP TYPE IF EXISTS mart.ETL_AssetInspectionNumericAnswerTable;
GO

CREATE TYPE mart.ETL_AssetInspectionNumericAnswerTable AS TABLE
(
    InspectionId uniqueidentifier NOT NULL
    ,QuestionId uniqueidentifier NOT NULL
    ,Question nvarchar(max) NOT NULL
    ,Mandatory bit NOT NULL
    ,Scale int NOT NULL
    ,UnitCode int NOT NULL
    ,Answer decimal(35,6) NOT NULL
    ,SectionId uniqueidentifier NOT NULL
    ,Section nvarchar(250) NOT NULL
    ,OrderInSection int NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (InspectionId, QuestionId)
);
GO
