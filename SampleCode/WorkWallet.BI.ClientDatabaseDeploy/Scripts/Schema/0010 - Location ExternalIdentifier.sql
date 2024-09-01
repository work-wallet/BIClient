-- add ExternalIdentifier column to the Location table
IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE [Name] = N'ExternalIdentifier' AND Object_ID = Object_ID(N'mart.Location'))
BEGIN
    ALTER TABLE mart.[Location]
    ADD ExternalIdentifier nvarchar(255) NOT NULL
    CONSTRAINT DF_Location_ExternalIdentifier DEFAULT N'' WITH VALUES;
END

GO
