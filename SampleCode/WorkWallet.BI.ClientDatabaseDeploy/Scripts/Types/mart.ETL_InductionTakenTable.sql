DROP TYPE IF EXISTS mart.ETL_InductionTakenTable;
GO

CREATE TYPE mart.ETL_InductionTakenTable AS TABLE
(
    InductionTakenId uniqueidentifier NOT NULL
    ,InductionId uniqueidentifier NOT NULL
    ,InductionVersion int NOT NULL
    ,ContactId uniqueidentifier NOT NULL
    ,[Name] nvarchar(max) NOT NULL
    ,CompanyName nvarchar(max) NOT NULL
    ,TakenOn datetime NOT NULL
    ,CorrectTestQuestionCount int NOT NULL
    ,InductionTakenStatusId int NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (TakenOn, InductionTakenId) -- putting TakenOn first to order the data load
);
GO