DROP TYPE IF EXISTS mart.ETL_PermitToWorkAssigneeTable;
GO

CREATE TYPE mart.ETL_PermitToWorkAssigneeTable AS TABLE
(
    PermitToWorkId uniqueidentifier NOT NULL
    ,ContactId uniqueidentifier NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (PermitToWorkId, ContactId)
);
GO
