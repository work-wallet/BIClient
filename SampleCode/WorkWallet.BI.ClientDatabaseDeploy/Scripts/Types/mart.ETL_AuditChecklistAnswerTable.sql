DROP TYPE IF EXISTS mart.ETL_AuditChecklistAnswerTable;
GO

CREATE TYPE mart.ETL_AuditChecklistAnswerTable AS TABLE
(
    AuditId uniqueidentifier NOT NULL
    ,ChecklistId uniqueidentifier NOT NULL
    ,OptionId uniqueidentifier NOT NULL
    ,Question nvarchar(100) NOT NULL
    ,[Value] nvarchar(250) NOT NULL
    ,Mandatory bit NOT NULL
    ,[Order] int NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (AuditId, ChecklistId, OptionId)
);
GO
