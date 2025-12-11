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
GO
