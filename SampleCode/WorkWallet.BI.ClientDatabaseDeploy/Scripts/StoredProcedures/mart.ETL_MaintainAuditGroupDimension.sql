DROP PROCEDURE IF EXISTS mart.ETL_MaintainAuditGroupDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainAuditGroupDimension @auditTable mart.ETL_AuditTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.AuditGroup AS target
    USING (
        SELECT DISTINCT
            a.AuditGroupId
            ,a.AuditGroup
            ,w.Wallet_key
        FROM
            @auditTable AS a
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON target.AuditGroupId = source.AuditGroupId
    WHEN MATCHED AND (
        target.AuditGroup <> source.AuditGroup
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            AuditGroup = source.AuditGroup
            ,Wallet_key = source.Wallet_key
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            AuditGroupId
            ,AuditGroup
            ,Wallet_key
        ) VALUES (
            source.AuditGroupId
            ,source.AuditGroup
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.AuditGroup, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
