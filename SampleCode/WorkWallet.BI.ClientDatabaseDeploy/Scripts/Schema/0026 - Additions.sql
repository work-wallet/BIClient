-- Permits: add the Extended status enumeration value (back-fixed in 0006 script)
IF NOT EXISTS (SELECT 1 FROM mart.PermitStatus WHERE PermitStatusCode = 8)
BEGIN
    INSERT INTO mart.PermitStatus (PermitStatusCode, PermitStatus) VALUES (8, N'Extended');
END

-- Permits: add HasBeenExtended column to Permit table
-- (has been back-fixed in the 0006 script)
IF NOT EXISTS(select 1 from sys.columns where [Name] = N'HasBeenExtended' and Object_ID = Object_ID(N'mart.Permit'))
BEGIN

    ALTER TABLE
        mart.Permit
    ADD
        HasBeenExtended bit NOT NULL
        CONSTRAINT DF_Permit_HasBeenExtended DEFAULT 0 WITH VALUES;

    ALTER TABLE mart.Permit DROP CONSTRAINT DF_Permit_HasBeenExtended;

END

-- Actions: add AssignedToEmail column to Action table
-- (has been back-fixed in the 0007 script)
IF NOT EXISTS(select 1 from sys.columns where [Name] = N'AssignedToEmail' and Object_ID = Object_ID(N'mart.[Action]'))
BEGIN
    ALTER TABLE
        mart.[Action]
    ADD
        AssignedToEmail nvarchar(256) NOT NULL
        CONSTRAINT DF_Action_AssignedToEmail DEFAULT '[not captured when downloaded]' WITH VALUES;
    ALTER TABLE mart.[Action] DROP CONSTRAINT DF_Action_AssignedToEmail;
END

-- Assets: add IsSharedProperty column to the AssetProperty table
-- (has been back-fixed in the 0009 script)
IF NOT EXISTS(select 1 from sys.columns where [Name] = N'IsSharedProperty' and Object_ID = Object_ID(N'mart.AssetProperty'))
BEGIN

    ALTER TABLE
        mart.AssetProperty
    ADD
        IsSharedProperty bit NOT NULL
        CONSTRAINT DF_AssetProperty_IsSharedProperty DEFAULT 0 WITH VALUES;

    ALTER TABLE mart.AssetProperty DROP CONSTRAINT DF_AssetProperty_IsSharedProperty;

END

-- Assets: add unique constraint to enforce business key on AssetProperty table
-- (has been back-fixed in the 0009 script)
IF NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE [name] = N'UQ_mart.AssetProperty_Business_Key'
    AND [parent_object_id] = OBJECT_ID(N'mart.AssetProperty')
)
BEGIN
    ALTER TABLE mart.AssetProperty
    ADD CONSTRAINT [UQ_mart.AssetProperty_Business_Key] UNIQUE(AssetPropertyType_key, IsSharedProperty, Property, Wallet_key);
END

GO
