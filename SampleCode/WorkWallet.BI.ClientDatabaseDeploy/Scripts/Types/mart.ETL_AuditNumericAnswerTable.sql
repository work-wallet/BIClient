DROP TYPE IF EXISTS mart.ETL_AuditNumericAnswerTable;
GO

CREATE TYPE mart.ETL_AuditNumericAnswerTable AS TABLE
(
    AuditId uniqueidentifier NOT NULL
    ,QuestionId uniqueidentifier NOT NULL
    ,Question nvarchar(500) NOT NULL
    ,Mandatory bit NOT NULL
    ,Scale int NOT NULL
    ,UnitCode int NOT NULL
    ,Answer decimal(35,6) NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (AuditId, QuestionId)
);
GO
