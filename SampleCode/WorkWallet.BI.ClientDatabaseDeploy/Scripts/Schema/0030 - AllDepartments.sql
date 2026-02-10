-- Add AllDepartments column to existing Location table
-- (has been back-fixed in the 0001 script)
IF NOT EXISTS(select 1 from sys.columns where [Name] = N'AllDepartments' and Object_ID = Object_ID(N'mart.Location'))
BEGIN

    ALTER TABLE
        mart.[Location]
    ADD
        AllDepartments nvarchar(max) NOT NULL
        CONSTRAINT DF_Location_AllDepartments DEFAULT '[not captured when downloaded]' WITH VALUES;

    ALTER TABLE mart.[Location] DROP CONSTRAINT DF_Location_AllDepartments;

END

GO