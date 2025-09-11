DROP PROCEDURE IF EXISTS mart.ETL_MaintainAuditScoreSectionDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainAuditScoreSectionDimension @auditScoreSectionTable mart.ETL_AuditScoreSectionTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.AuditScoreSection AS target
    USING (
        SELECT DISTINCT
            a.AuditType_key
            ,x.SectionId
            ,x.Section
            ,x.DisplayScore
            ,x.[Order]
            ,w.Wallet_key
        FROM
            @auditScoreSectionTable AS x
            INNER JOIN mart.[Audit] AS a ON x.AuditId = a.AuditId
            INNER JOIN mart.Wallet AS w ON x.WalletId = w.WalletId
    ) AS source
    ON target.AuditType_key = source.AuditType_key AND target.SectionId = source.SectionId
    WHEN MATCHED AND (
        target.Section <> source.Section
        OR target.DisplayScore <> source.DisplayScore
        OR target.[Order] <> source.[Order]
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            Section = source.Section
            ,DisplayScore = source.DisplayScore
            ,[Order] = source.[Order]
            ,Wallet_key = source.Wallet_key
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            AuditType_key
            ,SectionId
            ,Section
            ,DisplayScore
            ,[Order]
            ,Wallet_key
        ) VALUES (
            source.AuditType_key
            ,source.SectionId
            ,source.Section
            ,source.DisplayScore
            ,source.[Order]
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.AuditScoreSection, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
