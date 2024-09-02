-- add ExternalIdentifier column to the Location table (has been back-fixed in the 0001 script)
IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE [Name] = N'ExternalIdentifier' AND Object_ID = Object_ID(N'mart.Location'))
BEGIN
    ALTER TABLE mart.[Location]
    ADD ExternalIdentifier nvarchar(255) NOT NULL
    CONSTRAINT DF_Location_ExternalIdentifier DEFAULT N'' WITH VALUES;

	ALTER TABLE mart.[Location] DROP CONSTRAINT DF_Location_ExternalIdentifier;
END

GO
