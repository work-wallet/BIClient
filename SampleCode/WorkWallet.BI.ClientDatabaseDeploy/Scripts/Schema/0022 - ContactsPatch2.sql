-- add Contact_key column to AssetAssignment table
-- (has been back-fixed in the 009 script)
IF NOT EXISTS(select 1 from sys.columns where [Name] = N'Contact_key' and Object_ID = Object_ID(N'mart.AssetAssignment'))
BEGIN

    ALTER TABLE
        mart.AssetAssignment
    ADD
        Contact_key int NULL; -- allow NULLs

END
GO
