DROP TYPE IF EXISTS mart.ETL_AuditBranchOptionTable;
GO

CREATE TYPE mart.ETL_AuditBranchOptionTable AS TABLE
(
    AuditId uniqueidentifier NOT NULL
    ,BranchId uniqueidentifier NOT NULL
    ,OptionId uniqueidentifier NOT NULL
    ,Branch nvarchar(100) NOT NULL
    ,[Value] nvarchar(250) NOT NULL
    ,[Order] int NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (AuditId, BranchId, OptionId)
);
GO
