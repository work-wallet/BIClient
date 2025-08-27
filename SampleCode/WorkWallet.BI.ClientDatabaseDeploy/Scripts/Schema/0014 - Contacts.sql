CREATE TABLE mart.Contact
(
    Contact_key int IDENTITY
    ,ContactId uniqueidentifier NOT NULL /* business key */
    ,[Name] nvarchar(max) NOT NULL
    ,EmailAddress nvarchar(max) NOT NULL
    ,CompanyName nvarchar(max) NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.Contact__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.Contact] PRIMARY KEY (Contact_key)
    ,CONSTRAINT [UQ_mart.Contact_ContactId] UNIQUE(ContactId)
    ,CONSTRAINT [FK_mart.Contact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

GO
