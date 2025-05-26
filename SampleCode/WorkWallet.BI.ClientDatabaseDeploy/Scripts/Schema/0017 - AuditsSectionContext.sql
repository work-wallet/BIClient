-- add additional columns for the audit section context
-- (has been back-fixed in the 0015 script)

IF NOT EXISTS(select 1 from sys.columns where [Name] = N'Section' and Object_ID = Object_ID(N'mart.AuditNumericQuestion'))
BEGIN

    ALTER TABLE
        mart.AuditNumericQuestion
    ADD
        Section nvarchar(250) NOT NULL CONSTRAINT DF_mart_AuditNumericQuestion_Section DEFAULT N'[not captured when downloaded]'
        ,OrderInSection int NOT NULL CONSTRAINT DF_mart_AuditNumericQuestion_OrderInSection DEFAULT -1;

    ALTER TABLE mart.AuditNumericQuestion DROP CONSTRAINT DF_mart_AuditNumericQuestion_Section;
    ALTER TABLE mart.AuditNumericQuestion DROP CONSTRAINT DF_mart_AuditNumericQuestion_OrderInSection;

END

IF NOT EXISTS(select 1 from sys.columns where [Name] = N'Section' and Object_ID = Object_ID(N'mart.AuditDateTimeQuestion'))
BEGIN

    ALTER TABLE
        mart.AuditDateTimeQuestion
    ADD
        Section nvarchar(250) NOT NULL CONSTRAINT DF_mart_AuditDateTimeQuestion_Section DEFAULT N'[not captured when downloaded]'
        ,OrderInSection int NOT NULL CONSTRAINT DF_mart_AuditDateTimeQuestion_OrderInSection DEFAULT -1;

    ALTER TABLE mart.AuditDateTimeQuestion DROP CONSTRAINT DF_mart_AuditDateTimeQuestion_Section;
    ALTER TABLE mart.AuditDateTimeQuestion DROP CONSTRAINT DF_mart_AuditDateTimeQuestion_OrderInSection;

END

IF NOT EXISTS(select 1 from sys.columns where [Name] = N'Section' and Object_ID = Object_ID(N'mart.AuditChecklistOption'))
BEGIN

    ALTER TABLE
        mart.AuditChecklistOption
    ADD
        Section nvarchar(250) NOT NULL CONSTRAINT DF_mart_AuditChecklistOption_Section DEFAULT N'[not captured when downloaded]'
        ,OrderInSection int NOT NULL CONSTRAINT DF_mart_AuditChecklistOption_OrderInSection DEFAULT -1;

    ALTER TABLE mart.AuditChecklistOption DROP CONSTRAINT DF_mart_AuditChecklistOption_Section;
    ALTER TABLE mart.AuditChecklistOption DROP CONSTRAINT DF_mart_AuditChecklistOption_OrderInSection;

END

IF NOT EXISTS(select 1 from sys.columns where [Name] = N'Section' and Object_ID = Object_ID(N'mart.AuditBranchOption'))
BEGIN

    ALTER TABLE
        mart.AuditBranchOption
    ADD
        Section nvarchar(250) NOT NULL CONSTRAINT DF_mart_AuditBranchOption_Section DEFAULT N'[not captured when downloaded]'
        ,OrderInSection int NOT NULL CONSTRAINT DF_mart_AuditBranchOption_OrderInSection DEFAULT -1;

    ALTER TABLE mart.AuditBranchOption DROP CONSTRAINT DF_mart_AuditBranchOption_Section;
    ALTER TABLE mart.AuditBranchOption DROP CONSTRAINT DF_mart_AuditBranchOption_OrderInSection;

END

IF NOT EXISTS(select 1 from sys.columns where [Name] = N'Section' and Object_ID = Object_ID(N'mart.AuditScoredResponse'))
BEGIN

    ALTER TABLE
        mart.AuditScoredResponse
    ADD
        Section nvarchar(250) NOT NULL CONSTRAINT DF_mart_AuditScoredResponse_Section DEFAULT N'[not captured when downloaded]'
        ,OrderInSection int NOT NULL CONSTRAINT DF_mart_AuditScoredResponse_OrderInSection DEFAULT -1;

    ALTER TABLE mart.AuditScoredResponse DROP CONSTRAINT DF_mart_AuditScoredResponse_Section;
    ALTER TABLE mart.AuditScoredResponse DROP CONSTRAINT DF_mart_AuditScoredResponse_OrderInSection;

END

GO
