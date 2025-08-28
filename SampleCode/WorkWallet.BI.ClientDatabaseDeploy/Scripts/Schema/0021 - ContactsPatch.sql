-- add columns EmailAddress and CompanyName to Contact table
-- (has been back-fixed in the 0014 script)
IF NOT EXISTS(select 1 from sys.columns where [Name] = N'EmailAddress' and Object_ID = Object_ID(N'mart.Contact'))
BEGIN

    ALTER TABLE
        mart.Contact
    ADD
        EmailAddress nvarchar(max) NOT NULL
        CONSTRAINT DF_Contact_EmailAddress DEFAULT N'[not captured when downloaded]' WITH VALUES;

    ALTER TABLE mart.Contact DROP CONSTRAINT DF_Contact_EmailAddress;

END

IF NOT EXISTS(select 1 from sys.columns where [Name] = N'CompanyName' and Object_ID = Object_ID(N'mart.Contact'))
BEGIN

    ALTER TABLE
        mart.Contact
    ADD
        CompanyName nvarchar(max) NOT NULL
        CONSTRAINT DF_Contact_CompanyName DEFAULT N'[not captured when downloaded]' WITH VALUES;

    ALTER TABLE mart.Contact DROP CONSTRAINT DF_Contact_CompanyName;

END
GO
