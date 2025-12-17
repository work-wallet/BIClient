DROP TYPE IF EXISTS mart.ETL_PermitToWorkBranchOptionTable;
GO

CREATE TYPE mart.ETL_PermitToWorkBranchOptionTable AS TABLE
(
    PermitToWorkId uniqueidentifier NOT NULL
    ,BranchId uniqueidentifier NOT NULL
    ,OptionId uniqueidentifier NOT NULL
    ,Branch nvarchar(1000) NOT NULL
    ,[Value] nvarchar(250) NOT NULL
    ,[Order] int NOT NULL
    ,CategorySectionType nvarchar(50) NOT NULL
    ,Section nvarchar(100) NOT NULL
    ,SectionOrder int NOT NULL
    ,OrderInSection int NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (PermitToWorkId, BranchId, OptionId)
);
GO
