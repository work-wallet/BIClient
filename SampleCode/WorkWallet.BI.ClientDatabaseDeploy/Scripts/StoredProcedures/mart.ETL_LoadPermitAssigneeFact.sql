DROP PROCEDURE IF EXISTS mart.ETL_LoadPermitAssigneeFact;
GO

CREATE PROCEDURE mart.ETL_LoadPermitAssigneeFact
    @permitToWorkAssigneeTable mart.ETL_PermitToWorkAssigneeTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    -- insert missing entries
    INSERT INTO mart.PermitAssigneeFact
    (
        -- keys
        Permit_key
        ,Contact_key
        ,Wallet_key
        -- facts
    )
    SELECT DISTINCT
        -- keys
        p.Permit_key
        ,c.Contact_key
        ,w.Wallet_key
        -- facts
    FROM
        @permitToWorkAssigneeTable AS a
        INNER JOIN mart.Permit AS p ON a.PermitToWorkId = p.PermitId
        INNER JOIN mart.Contact AS c ON a.ContactId = c.ContactId
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId;

    PRINT 'INSERT mart.PermitAssigneeFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
