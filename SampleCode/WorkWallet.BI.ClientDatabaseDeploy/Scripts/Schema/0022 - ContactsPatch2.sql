-- add Contact_key column to AssetAssignment table
-- (has been back-fixed in the 0009 script)
IF NOT EXISTS(select 1 from sys.columns where [Name] = N'Contact_key' and Object_ID = Object_ID(N'mart.AssetAssignment'))
BEGIN

    ALTER TABLE
        mart.AssetAssignment
    ADD
        Contact_key int NULL; -- allow NULLs

END
GO

-- add Contact_key column to InductionTaken table
-- (has been back-fixed in the 0005 script)
IF NOT EXISTS(select 1 from sys.columns where [Name] = N'Contact_key' and Object_ID = Object_ID(N'mart.InductionTaken'))
BEGIN

    ALTER TABLE
        mart.InductionTaken
    ADD
        Contact_key int NULL; -- allow NULLs (data from older versions of the API did not process contacts, will never be NULL for new data)

END
GO

-- add ReportedByContact_key column to ReportedIssue table
-- (has been back-fixed in the 0004 script)
IF NOT EXISTS(select 1 from sys.columns where [Name] = N'ReportedByContact_key' and Object_ID = Object_ID(N'mart.ReportedIssue'))
BEGIN

    ALTER TABLE
        mart.ReportedIssue
    ADD
        ReportedByContact_key int NULL; -- allow NULLs (data from older versions of the API did not process contacts, will never be NULL for new data)

END
GO

-- add EmployeeContact_key column to SafetyCard table
-- (has been back-fixed in the 0012 script)
IF NOT EXISTS(select 1 from sys.columns where [Name] = N'EmployeeContact_key' and Object_ID = Object_ID(N'mart.SafetyCard'))
BEGIN

    ALTER TABLE
        mart.SafetyCard
    ADD
        EmployeeContact_key int NULL; -- allow NULLs

END
GO
