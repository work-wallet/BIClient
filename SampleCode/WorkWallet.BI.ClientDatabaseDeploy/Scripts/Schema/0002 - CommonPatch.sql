-- add Department column to the Location table (was not included in initial release, though is in the 0001 script)
IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE [Name] = N'Department' AND Object_ID = Object_ID(N'mart.Location'))
BEGIN
    ALTER TABLE mart.[Location]
    ADD Department nvarchar(30) NOT NULL
    CONSTRAINT DF_Location_Department DEFAULT N'' WITH VALUES;
END

GO
