-- Permits: add additional fields to PermitChecklistAnswer table
-- (has been back-fixed in the 0006 script)
IF NOT EXISTS(select 1 from sys.columns where [Name] = N'Order' and Object_ID = Object_ID(N'mart.PermitChecklistAnswer'))
BEGIN
    ALTER TABLE
        mart.PermitChecklistAnswer
    ADD
        [Order] int NOT NULL
        CONSTRAINT DF_PermitChecklistAnswer_Order DEFAULT -1 WITH VALUES;
    ALTER TABLE mart.PermitChecklistAnswer DROP CONSTRAINT DF_PermitChecklistAnswer_Order;
END

IF NOT EXISTS(select 1 from sys.columns where [Name] = N'Section' and Object_ID = Object_ID(N'mart.PermitChecklistAnswer'))
BEGIN
    ALTER TABLE
        mart.PermitChecklistAnswer
    ADD
        Section nvarchar(100) NOT NULL
        CONSTRAINT DF_PermitChecklistAnswer_Section DEFAULT N'[not captured when downloaded]' WITH VALUES;
    ALTER TABLE mart.PermitChecklistAnswer DROP CONSTRAINT DF_PermitChecklistAnswer_Section;
END

IF NOT EXISTS(select 1 from sys.columns where [Name] = N'SectionOrder' and Object_ID = Object_ID(N'mart.PermitChecklistAnswer'))
BEGIN
    ALTER TABLE
        mart.PermitChecklistAnswer
    ADD
        SectionOrder int NOT NULL
        CONSTRAINT DF_PermitChecklistAnswer_SectionOrder DEFAULT -1 WITH VALUES;
    ALTER TABLE mart.PermitChecklistAnswer DROP CONSTRAINT DF_PermitChecklistAnswer_SectionOrder;
END

IF NOT EXISTS(select 1 from sys.columns where [Name] = N'OrderInSection' and Object_ID = Object_ID(N'mart.PermitChecklistAnswer'))
BEGIN
    ALTER TABLE
        mart.PermitChecklistAnswer
    ADD
        OrderInSection int NOT NULL
        CONSTRAINT DF_PermitChecklistAnswer_OrderInSection DEFAULT -1 WITH VALUES;
    ALTER TABLE mart.PermitChecklistAnswer DROP CONSTRAINT DF_PermitChecklistAnswer_OrderInSection;
END

-- Permits: drop _edited column from PermitChecklistAnswerFact if it exists
-- (has been back-fixed in the 0006 script)
IF EXISTS(select 1 from sys.columns where [Name] = N'_edited' and Object_ID = Object_ID(N'mart.PermitChecklistAnswerFact'))
BEGIN
    ALTER TABLE mart.PermitChecklistAnswerFact DROP COLUMN _edited;
END

-- Permits: create new tables for numeric questions, datetime questions, and branch options

CREATE TABLE mart.PermitNumericQuestion
(
    PermitNumericQuestion_key int IDENTITY
    ,QuestionId uniqueidentifier NOT NULL
    ,Question nvarchar(1000) NOT NULL
    ,Scale int NOT NULL
    ,Unit_key int NOT NULL
    ,CategorySectionType nvarchar(50) NOT NULL
    ,Section nvarchar(100) NOT NULL
    ,SectionOrder int NOT NULL
    ,OrderInSection int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.PermitNumericQuestion__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.PermitNumericQuestion] PRIMARY KEY (PermitNumericQuestion_key)
    ,CONSTRAINT [FK_mart.PermitNumericQuestion_mart.Unit_Unit_key] FOREIGN KEY(Unit_key) REFERENCES mart.Unit
    ,CONSTRAINT [FK_mart.PermitNumericQuestion_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.PermitNumericAnswerFact
(
    Permit_key int NOT NULL
    ,PermitNumericQuestion_key int NOT NULL
    ,Answer decimal(35,6) NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.PermitNumericAnswerFact__created] DEFAULT SYSUTCDATETIME()
    ,CONSTRAINT [PK_mart.PermitNumericAnswerFact] PRIMARY KEY (Permit_key, PermitNumericQuestion_key)
    ,CONSTRAINT [FK_mart.PermitNumericAnswerFact_mart.Permit_Permit_key] FOREIGN KEY(Permit_key) REFERENCES mart.Permit
    ,CONSTRAINT [FK_mart.PermitNumericAnswerFact_mart.PermitNumericQuestion_PermitNumericQuestion_key] FOREIGN KEY(PermitNumericQuestion_key) REFERENCES mart.PermitNumericQuestion
    ,CONSTRAINT [FK_mart.PermitNumericAnswerFact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.PermitDateTimeQuestion
(
    PermitDateTimeQuestion_key int IDENTITY
    ,QuestionId uniqueidentifier NOT NULL
    ,Question nvarchar(1000) NOT NULL
    ,[Date] bit NOT NULL
    ,[Time] bit NOT NULL
    ,CategorySectionType nvarchar(50) NOT NULL
    ,Section nvarchar(100) NOT NULL
    ,SectionOrder int NOT NULL
    ,OrderInSection int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.PermitDateTimeQuestion__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.PermitDateTimeQuestion] PRIMARY KEY (PermitDateTimeQuestion_key)
    ,CONSTRAINT [FK_mart.PermitDateTimeQuestion_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.PermitDateTimeAnswerFact
(
    Permit_key int NOT NULL
    ,PermitDateTimeQuestion_key int NOT NULL
    ,AnswerDateTime smalldatetime NULL -- allow null
    ,AnswerDate date NULL -- allow null
    ,AnswerTime time(0) NULL -- allow null
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.PermitDateTimeAnswerFact__created] DEFAULT SYSUTCDATETIME()
    ,CONSTRAINT [PK_mart.PermitDateTimeAnswerFact] PRIMARY KEY (Permit_key, PermitDateTimeQuestion_key)
    ,CONSTRAINT [FK_mart.PermitDateTimeAnswerFact_mart.Permit_Permit_key] FOREIGN KEY(Permit_key) REFERENCES mart.Permit
    ,CONSTRAINT [FK_mart.PermitDateTimeAnswerFact_mart.PermitDateTimeQuestion_PermitDateTimeQuestion_key] FOREIGN KEY(PermitDateTimeQuestion_key) REFERENCES mart.PermitDateTimeQuestion
    ,CONSTRAINT [FK_mart.PermitDateTimeAnswerFact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.PermitBranchOption
(
    PermitBranchOption_key int IDENTITY
    ,BranchId uniqueidentifier NOT NULL
    ,OptionId uniqueidentifier NOT NULL
    ,Branch nvarchar(1000) NOT NULL
    ,[Value] nvarchar(250) NOT NULL
    ,[Order] int NOT NULL
    ,CategorySectionType nvarchar(50) NOT NULL
    ,Section nvarchar(100) NOT NULL
    ,SectionOrder int NOT NULL
    ,OrderInSection int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.PermitBranchOption__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.PermitBranchOption] PRIMARY KEY (PermitBranchOption_key)
    ,CONSTRAINT [FK_mart.PermitBranchOption_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.PermitBranchOptionFact
(
    Permit_key int NOT NULL
    ,PermitBranchOption_key int NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.PermitBranchOptionFact__created] DEFAULT SYSUTCDATETIME()
    ,CONSTRAINT [PK_mart.PermitBranchOptionFact] PRIMARY KEY (Permit_key, PermitBranchOption_key)
    ,CONSTRAINT [FK_mart.PermitBranchOptionFact_mart.Permit_Permit_key] FOREIGN KEY(Permit_key) REFERENCES mart.Permit
    ,CONSTRAINT [FK_mart.PermitBranchOptionFact_mart.PermitBranchOption_PermitBranchOption_key] FOREIGN KEY(PermitBranchOption_key) REFERENCES mart.PermitBranchOption
    ,CONSTRAINT [FK_mart.PermitBranchOptionFact_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

GO
