DROP TYPE IF EXISTS mart.ETL_AuditDateTimeAnswerTable;
GO

CREATE TYPE mart.ETL_AuditDateTimeAnswerTable AS TABLE
(
    AuditId uniqueidentifier NOT NULL
    ,QuestionId uniqueidentifier NOT NULL
    ,Question nvarchar(500) NOT NULL
    ,Mandatory bit NOT NULL
    ,[Date] bit NOT NULL
    ,[Time] bit NOT NULL
    ,Answer datetime NOT NULL
    ,SectionId uniqueidentifier NOT NULL
    ,Section nvarchar(250) NOT NULL
    ,OrderInSection int NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (AuditId, QuestionId)
);
GO
