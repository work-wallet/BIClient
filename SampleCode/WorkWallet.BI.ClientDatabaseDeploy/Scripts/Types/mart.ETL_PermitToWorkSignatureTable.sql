DROP TYPE IF EXISTS mart.ETL_PermitToWorkSignatureTable;
GO

CREATE TYPE mart.ETL_PermitToWorkSignatureTable AS TABLE
(
    PermitToWorkSignatureId uniqueidentifier NOT NULL
    ,PermitToWorkId uniqueidentifier NOT NULL
    ,[Name] nvarchar(max) NOT NULL
    ,ContactId uniqueidentifier NULL
    ,JobTitle nvarchar(50) NOT NULL
    ,[Description] nvarchar(max) NOT NULL
    ,SignedOn datetime NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (PermitToWorkSignatureId)
);
GO
