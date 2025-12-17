DROP TYPE IF EXISTS mart.ETL_PermitToWorkChecklistAnswerTable;
GO

CREATE TYPE mart.ETL_PermitToWorkChecklistAnswerTable AS TABLE
(
    PermitToWorkId uniqueidentifier NOT NULL
    ,ChecklistId uniqueidentifier NOT NULL
    ,OptionId uniqueidentifier NOT NULL
    ,Question nvarchar(1000) NOT NULL
    ,[Option] nvarchar(250) NOT NULL
    ,[Order] int NOT NULL
    ,CategorySectionType nvarchar(50) NOT NULL
    ,Section nvarchar(100) NOT NULL
    ,SectionOrder int NOT NULL
    ,OrderInSection int NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (PermitToWorkId, ChecklistId, OptionId)
);
GO