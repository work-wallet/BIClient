DROP PROCEDURE IF EXISTS mart.ETL_LoadAuditScoreTagFact;
GO

CREATE PROCEDURE mart.ETL_LoadAuditScoreTagFact
    @auditScoreTagTable mart.ETL_AuditScoreTagTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO mart.AuditScoreTagFact
    (
        Audit_key
        ,AuditScoreTag_key
        ,TotalScore
        ,TotalPotentialScore
        ,AverageScore
        ,AveragePotentialScore
        ,PercentageScore
        ,Flags
        ,GradingSetOption_key
        ,Wallet_key
    )
    SELECT DISTINCT
        a.Audit_key
        ,t.AuditScoreTag_key
        ,x.TotalScore
        ,x.TotalPotentialScore
        ,x.AverageScore
        ,x.AveragePotentialScore
        ,x.PercentageScore
        ,x.Flags
        ,gso.GradingSetOption_key
        ,w.Wallet_key
    FROM
        @auditScoreTagTable AS x
        INNER JOIN mart.[Audit] AS a ON x.AuditId = a.AuditId
        INNER JOIN mart.AuditScoreTag AS t ON x.TagId = t.TagId AND x.TagVersion = t.TagVersion
        INNER JOIN mart.GradingSetOption AS gso ON x.GradingSetOptionId = gso.GradingSetOptionId
        INNER JOIN mart.Wallet AS w ON x.WalletId = w.WalletId;

    PRINT 'INSERT mart.AuditScoreTagFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
