DROP PROCEDURE IF EXISTS mart.ETL_MaintainContactDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainContactDimension @contactTable mart.ETL_ContactTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.Contact AS target
    USING (
        SELECT
            a.ContactId,
            a.[Name],
            a.EmailAddress,
            a.CompanyName,
            w.Wallet_key
        FROM
            @contactTable AS a
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON target.ContactId = source.ContactId
    WHEN MATCHED AND (
        target.[Name] <> source.[Name]
        OR target.EmailAddress <> source.EmailAddress
        OR target.CompanyName <> source.CompanyName
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            [Name] = source.[Name],
            EmailAddress = source.EmailAddress,
            CompanyName = source.CompanyName,
            Wallet_key = source.Wallet_key,
            _edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            ContactId,
            [Name],
            EmailAddress,
            CompanyName,
            Wallet_key
        ) VALUES (
            source.ContactId,
            source.[Name],
            source.EmailAddress,
            source.CompanyName,
            source.Wallet_key
        );

    PRINT 'MERGE mart.Contact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
