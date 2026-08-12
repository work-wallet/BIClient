DROP TYPE IF EXISTS mart.ETL_AssetInspectionDateTimeAnswerTable;
GO

CREATE TYPE mart.ETL_AssetInspectionDateTimeAnswerTable AS TABLE
(
    InspectionId uniqueidentifier NOT NULL
    ,QuestionId uniqueidentifier NOT NULL
    ,Question nvarchar(max) NOT NULL
    ,Mandatory bit NOT NULL
    ,[Date] bit NOT NULL
    ,[Time] bit NOT NULL
    ,Answer datetime NOT NULL
    ,SectionId uniqueidentifier NOT NULL
    ,Section nvarchar(250) NOT NULL
    ,OrderInSection int NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (InspectionId, QuestionId)
);
GO
