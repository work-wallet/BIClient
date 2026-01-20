DROP TYPE IF EXISTS mart.ETL_PermitToWorkNumericAnswerTable;
GO

CREATE TYPE mart.ETL_PermitToWorkNumericAnswerTable AS TABLE
(
    PermitToWorkId uniqueidentifier NOT NULL
    ,QuestionId uniqueidentifier NOT NULL
    ,Question nvarchar(1000) NOT NULL
    ,Mandatory bit NOT NULL
    ,Scale int NOT NULL
    ,UnitCode int NOT NULL
    ,Answer decimal(35,6) NOT NULL
    ,CategorySectionTypeId int NOT NULL
    ,CategorySectionType nvarchar(50) NOT NULL
    ,SectionId uniqueidentifier NOT NULL
    ,Section nvarchar(100) NOT NULL
    ,SectionOrder int NOT NULL
    ,OrderInSection int NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (PermitToWorkId, QuestionId)
);
GO
