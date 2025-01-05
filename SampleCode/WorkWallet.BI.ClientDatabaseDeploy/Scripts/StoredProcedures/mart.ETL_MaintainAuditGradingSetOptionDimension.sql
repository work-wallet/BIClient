DROP PROCEDURE IF EXISTS mart.ETL_MaintainAuditGradingSetOptionDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainAuditGradingSetOptionDimension @auditGradingSetOptionTable mart.ETL_AuditGradingSetOptionTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.AuditGradingSetOption AS target
    USING (
        SELECT DISTINCT
            o.GradingSetOptionId,
            t.GradingSet,
            o.GradingSetOption,
            w.Wallet_key
        FROM
            @auditGradingSetOptionTable AS o
            INNER JOIN mart.[Audit] AS a ON o.AuditId = a.AuditId
            INNER JOIN mart.AuditType AS t ON a.AuditType_key = t.AuditType_key
            INNER JOIN mart.Wallet AS w ON o.WalletId = w.WalletId
    ) AS source
    ON target.GradingSetOptionId = source.GradingSetOptionId
    WHEN MATCHED AND (
        target.GradingSet <> source.GradingSet
        OR target.GradingSetOption <> source.GradingSetOption
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            GradingSet = source.GradingSet,
            GradingSetOption = source.GradingSetOption,
            Wallet_key = source.Wallet_key,
            _edited = SYSUTCDATETIME()    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            GradingSetOptionId,
            GradingSet,
            GradingSetOption,
            Wallet_key
        ) VALUES (
            source.GradingSetOptionId,
            source.GradingSet,
            source.GradingSetOption,
            source.Wallet_key
        );

    PRINT 'MERGE mart.AuditGradingSetOption, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
