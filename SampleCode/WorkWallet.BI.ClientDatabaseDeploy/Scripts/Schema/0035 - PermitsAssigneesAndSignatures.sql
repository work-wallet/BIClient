-- Permits: add PermitAssigneeFact and PermitSignatureFact tables to capture
-- the new PermitAssignees and PermitSignatures arrays from the API.

-- Step 1: create mart.PermitAssigneeFact table.

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE [name] = N'PermitAssigneeFact' AND [schema_id] = SCHEMA_ID(N'mart'))
BEGIN

    CREATE TABLE mart.PermitAssigneeFact
    (
        Permit_key int NOT NULL
        ,Contact_key int NOT NULL
        ,Wallet_key int NOT NULL
        ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.PermitAssigneeFact__created] DEFAULT SYSUTCDATETIME()
        ,_edited datetime2(7) NULL
        ,CONSTRAINT [PK_mart.PermitAssigneeFact] PRIMARY KEY (Permit_key, Contact_key)
        ,CONSTRAINT [FK_mart.PermitAssigneeFact_mart.Permit_Permit_key] FOREIGN KEY (Permit_key) REFERENCES mart.Permit
        ,CONSTRAINT [FK_mart.PermitAssigneeFact_mart.Contact_Contact_key] FOREIGN KEY (Contact_key) REFERENCES mart.Contact
        ,CONSTRAINT [FK_mart.PermitAssigneeFact_mart.Wallet_Wallet_key] FOREIGN KEY (Wallet_key) REFERENCES mart.Wallet
    );

END

GO

-- Step 2: create mart.PermitSignatureFact table.

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE [name] = N'PermitSignatureFact' AND [schema_id] = SCHEMA_ID(N'mart'))
BEGIN

    CREATE TABLE mart.PermitSignatureFact
    (
        PermitSignatureId uniqueidentifier NOT NULL /* business key */
        ,Permit_key int NOT NULL
        ,[Name] nvarchar(max) NOT NULL
        ,Contact_key int NULL -- nullable; null for free-text signatories
        ,JobTitle nvarchar(50) NOT NULL
        ,[Description] nvarchar(max) NOT NULL
        ,SignedOn datetime NULL -- nullable; null if not provided by client at time of signing
        ,Wallet_key int NOT NULL
        ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.PermitSignatureFact__created] DEFAULT SYSUTCDATETIME()
        ,_edited datetime2(7) NULL
        ,CONSTRAINT [PK_mart.PermitSignatureFact] PRIMARY KEY (PermitSignatureId)
        ,CONSTRAINT [UQ_mart.PermitSignatureFact_PermitSignatureId] UNIQUE (PermitSignatureId)
        ,CONSTRAINT [FK_mart.PermitSignatureFact_mart.Permit_Permit_key] FOREIGN KEY (Permit_key) REFERENCES mart.Permit
        ,CONSTRAINT [FK_mart.PermitSignatureFact_mart.Contact_Contact_key] FOREIGN KEY (Contact_key) REFERENCES mart.Contact
        ,CONSTRAINT [FK_mart.PermitSignatureFact_mart.Wallet_Wallet_key] FOREIGN KEY (Wallet_key) REFERENCES mart.Wallet
    );

END

GO
