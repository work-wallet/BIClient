DROP PROCEDURE IF EXISTS mart.ETL_LoadPermitSignatureFact;
GO

CREATE PROCEDURE mart.ETL_LoadPermitSignatureFact
    @permitToWorkSignatureTable mart.ETL_PermitToWorkSignatureTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    -- insert signatures (facts are deleted for the permit before this runs)
    INSERT INTO mart.PermitSignatureFact
    (
        -- keys
        PermitSignatureId
        ,Permit_key
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
        a.PermitToWorkSignatureId
        ,p.Permit_key
        ,c.Contact_key -- NULL for free-text signatories
        ,w.Wallet_key
        -- facts
        ,a.[Name]
        ,a.JobTitle
        ,a.[Description]
        ,a.SignedOn
    FROM
        @permitToWorkSignatureTable AS a
        INNER JOIN mart.Permit AS p ON a.PermitToWorkId = p.PermitId
        LEFT JOIN mart.Contact AS c ON a.ContactId = c.ContactId
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId;

    PRINT 'INSERT mart.PermitSignatureFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
