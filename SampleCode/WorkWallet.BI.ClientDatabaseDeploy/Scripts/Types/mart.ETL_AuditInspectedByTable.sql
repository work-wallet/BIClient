DROP TYPE IF EXISTS mart.ETL_AuditInspectedByTable;
GO

CREATE TYPE mart.ETL_AuditInspectedByTable AS TABLE
(
    AuditId uniqueidentifier NOT NULL
    ,ContactId uniqueidentifier NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (AuditId, ContactId)
);
GO
