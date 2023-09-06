DROP TYPE IF EXISTS mart.ETL_InductionCustomQuestionTable;
GO

CREATE TYPE mart.ETL_InductionCustomQuestionTable AS TABLE
(
    InductionTakenId uniqueidentifier NOT NULL
    ,AnswerId uniqueidentifier NOT NULL
    ,Title nvarchar(250) NOT NULL
    ,[Value] nvarchar(250) NOT NULL
    ,ValueId uniqueidentifier NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (InductionTakenId, AnswerId, ValueId)
);
GO