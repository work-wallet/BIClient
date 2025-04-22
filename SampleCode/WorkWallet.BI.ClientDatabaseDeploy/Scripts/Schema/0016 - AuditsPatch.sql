-- increase the maximum length for Section (AuditScoreSection table)
-- (has been back-fixed in the 0015 script)
IF NOT EXISTS(select 1 from sys.columns where [Name] = N'Section' and Object_ID = Object_ID(N'mart.AuditScoreSection') and max_length = 500)
BEGIN

    ALTER TABLE
        mart.AuditScoreSection
    ALTER COLUMN
        Section nvarchar(250) NOT NULL;

END
GO
