DROP PROCEDURE IF EXISTS mart.ETL_MaintainAuditScoredResponseDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainAuditScoredResponseDimension @auditScoredResponseTable mart.ETL_AuditScoredResponseTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.AuditScoredResponse AS target
    USING (
        SELECT DISTINCT
            a.BranchId,
            a.OptionId,
            a.Branch,
            a.[Value],
            a.[Order],
            w.Wallet_key
        FROM
            @auditScoredResponseTable AS a
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON target.BranchId = source.BranchId AND target.OptionId = source.OptionId
    WHEN MATCHED AND (
        target.Branch <> source.Branch
        OR target.[Value] <> source.[Value]
        OR target.[Order] <> source.[Order]
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            Branch = source.Branch,
            [Value] = source.[Value],
            [Order] = source.[Order],
            Wallet_key = source.Wallet_key,
            _edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            BranchId,
            OptionId,
            Branch,
            [Value],
            [Order],
            Wallet_key
        ) VALUES (
            source.BranchId,
            source.OptionId,
            source.Branch,
            source.[Value],
            source.[Order],
            source.Wallet_key
        );

    PRINT 'MERGE mart.AuditScoredResponse, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
