DROP PROCEDURE IF EXISTS mart.ETL_LoadReportedIssueSignatureFact;
GO

CREATE PROCEDURE mart.ETL_LoadReportedIssueSignatureFact
    @reportedIssueSignatureTable mart.ETL_ReportedIssueSignatureTable READONLY
    ,@investigation bit
AS
BEGIN
    SET NOCOUNT ON;

    -- insert signatures (facts are deleted for the reported issue before this runs)
    INSERT INTO mart.ReportedIssueSignatureFact
    (
        -- keys
        ReportedIssueSignatureId
        ,Investigation
        ,ReportedIssue_key
        ,SignatureId
        ,ReportedIssuePersonOptionType_key
        ,Contact_key
        ,Wallet_key
        -- facts
        ,[Name]
        ,JobTitle
        ,[Description]
        ,SignedOn
    )
    SELECT
        -- keys
        a.ReportedIssueSignatureId
        ,@investigation
        ,ri.ReportedIssue_key
        ,a.SignatureId
        ,pot.ReportedIssuePersonOptionType_key
        ,c.Contact_key -- NULL for 'Other' (typed-in) signatories
        ,w.Wallet_key
        -- facts
        ,a.[Name]
        ,a.JobTitle
        ,a.[Description]
        ,a.SignedOn
    FROM
        @reportedIssueSignatureTable AS a
        INNER JOIN mart.ReportedIssue AS ri ON a.ReportedIssueId = ri.ReportedIssueId
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        INNER JOIN mart.ReportedIssuePersonOptionType AS pot ON a.PersonOptionTypeCode = pot.PersonOptionTypeCode
        LEFT JOIN mart.Contact AS c ON a.ContactId = c.ContactId;

    PRINT 'INSERT mart.ReportedIssueSignatureFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
