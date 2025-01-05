DROP PROCEDURE IF EXISTS mart.ETL_MaintainAuditGroupDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainAuditGroupDimension @AuditTable mart.ETL_AuditTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.AuditGroup AS target
    USING (
        SELECT DISTINCT
            a.AuditGroup,
            w.Wallet_key
        FROM
            @AuditTable AS a
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON target.Wallet_key = source.Wallet_key AND target.AuditGroup = source.AuditGroup
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            AuditGroup,
            Wallet_key
        ) VALUES (
            source.AuditGroup,
            source.Wallet_key
        );

    PRINT 'MERGE mart.AuditGroup, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
