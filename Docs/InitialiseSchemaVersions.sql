-- Only run this script on an existing (legacy) installation that predates August 2023.
-- See README.md in the root of the repository.

IF (NOT EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'dbo' 
                 AND  TABLE_NAME = 'SchemaVersions'))
BEGIN

    CREATE TABLE dbo.SchemaVersions
    (
        Id int IDENTITY(1,1) NOT NULL
        ,ScriptName nvarchar(255) NOT NULL
        ,Applied datetime NOT NULL
        CONSTRAINT PK_SchemaVersions_Id2 PRIMARY KEY CLUSTERED 
        (
            Id ASC
        )
    );

    IF (EXISTS (SELECT *
                    FROM INFORMATION_SCHEMA.TABLES 
                    WHERE TABLE_SCHEMA = 'mart' 
                    AND  TABLE_NAME = 'ETL_ChangeDetection'))
    BEGIN
        INSERT INTO dbo.SchemaVersions
        (
            ScriptName
            ,Applied
        )
        VALUES
            (N'WorkWallet.BI.ClientDatabaseDeploy.Scripts.Schema.0001 - Common.sql', GETDATE());
    END

    IF EXISTS(SELECT 1 FROM sys.columns WHERE [Name] = N'Department' AND Object_ID = Object_ID(N'mart.Location'))
    BEGIN
        INSERT INTO dbo.SchemaVersions
        (
            ScriptName
            ,Applied
        )
        VALUES
            (N'WorkWallet.BI.ClientDatabaseDeploy.Scripts.Schema.0002 - CommonPatch.sql', GETDATE());
    END

    IF (EXISTS (SELECT *
                    FROM INFORMATION_SCHEMA.TABLES 
                    WHERE TABLE_SCHEMA = 'mart' 
                    AND  TABLE_NAME = 'SiteAudit'))
    BEGIN
        INSERT INTO dbo.SchemaVersions
        (
            ScriptName
            ,Applied
        )
        VALUES
            (N'WorkWallet.BI.ClientDatabaseDeploy.Scripts.Schema.0003 - SiteAudits.sql', GETDATE());
    END

    IF (EXISTS (SELECT *
                    FROM INFORMATION_SCHEMA.TABLES 
                    WHERE TABLE_SCHEMA = 'mart' 
                    AND  TABLE_NAME = 'ReportedIssue'))
    BEGIN
        INSERT INTO dbo.SchemaVersions
        (
            ScriptName
            ,Applied
        )
        VALUES
            (N'WorkWallet.BI.ClientDatabaseDeploy.Scripts.Schema.0004 - ReportedIssues.sql', GETDATE());
    END

END

GO
