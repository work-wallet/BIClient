DROP PROCEDURE IF EXISTS mart.ETL_MaintainAuditChecklistOptionDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainAuditChecklistOptionDimension @auditChecklistAnswerTable mart.ETL_AuditChecklistAnswerTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.AuditChecklistOption AS target
    USING (
        SELECT DISTINCT
            a.ChecklistId,
            a.OptionId,
            a.Question,
            a.[Value],
            a.Mandatory,
            a.[Order],
            w.Wallet_key
        FROM
            @auditChecklistAnswerTable AS a
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON target.ChecklistId = source.ChecklistId AND target.OptionId = source.OptionId
    WHEN MATCHED AND (
        target.Question <> source.Question
        OR target.[Value] <> source.[Value]
        OR target.Mandatory <> source.Mandatory
        OR target.[Order] <> source.[Order]
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            Question = source.Question,
            [Value] = source.[Value],
            Mandatory = source.Mandatory,
            [Order] = source.[Order],
            Wallet_key = source.Wallet_key,
            _edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            ChecklistId,
            OptionId,
            Question,
            [Value],
            Mandatory,
            [Order],
            Wallet_key
        ) VALUES (
            source.ChecklistId,
            source.OptionId,
            source.Question,
            source.[Value],
            source.Mandatory,
            source.[Order],
            source.Wallet_key
        );

    PRINT 'MERGE mart.AuditChecklistOption, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
