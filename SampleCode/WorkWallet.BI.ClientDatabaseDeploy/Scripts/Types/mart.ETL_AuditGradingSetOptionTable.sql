DROP TYPE IF EXISTS mart.ETL_AuditGradingSetOptionTable;
GO

CREATE TYPE mart.ETL_AuditGradingSetOptionTable AS TABLE
(
    AuditId uniqueidentifier NOT NULL
    ,GradingSetOptionId uniqueidentifier NOT NULL
    ,GradingSetOption nvarchar(250) NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (AuditId, GradingSetOptionId)
);
GO
