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

GO
