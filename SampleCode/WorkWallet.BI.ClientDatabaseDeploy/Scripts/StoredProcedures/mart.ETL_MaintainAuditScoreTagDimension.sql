DROP PROCEDURE IF EXISTS mart.ETL_MaintainAuditScoreTagDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainAuditScoreTagDimension @auditScoreTagTable mart.ETL_AuditScoreTagTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.AuditScoreTag AS target
    USING (
        SELECT DISTINCT
            x.TagId
            ,x.TagVersion
            ,x.Tag
            ,w.Wallet_key
        FROM
            @auditScoreTagTable AS x
            INNER JOIN mart.Wallet AS w ON x.WalletId = w.WalletId
    ) AS source
    ON target.TagId = source.TagId AND target.TagVersion = source.TagVersion
    WHEN MATCHED AND (
        target.Tag <> source.Tag
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            Tag = source.Tag
            ,Wallet_key = source.Wallet_key
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            TagId
            ,TagVersion
            ,Tag
            ,Wallet_key
        ) VALUES (
            source.TagId
            ,source.TagVersion
            ,source.Tag
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.AuditScoreTag, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
