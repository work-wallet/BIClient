DROP PROCEDURE IF EXISTS mart.ETL_LoadAuditScoreSectionFact;
GO

CREATE PROCEDURE mart.ETL_LoadAuditScoreSectionFact
    @auditScoreSectionTable mart.ETL_AuditScoreSectionTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO mart.AuditScoreSectionFact
    (
        Audit_key
        ,AuditScoreSection_key
        ,TotalScore
        ,TotalPotentialScore
        ,AverageScore
        ,AveragePotentialScore
        ,PercentageScore
        ,Flags
        ,AuditGradingSet_key
        ,Wallet_key
    )
    SELECT DISTINCT
        a.Audit_key
        ,s.AuditScoreSection_key
        ,x.TotalScore
        ,x.TotalPotentialScore
        ,x.AverageScore
        ,x.AveragePotentialScore
        ,x.PercentageScore
        ,x.Flags
        ,g.AuditGradingSetOption_key
        ,w.Wallet_key
    FROM
        @auditScoreSectionTable AS x
        INNER JOIN mart.[Audit] AS a ON x.AuditId = a.AuditId
        INNER JOIN mart.AuditType AS t ON a.AuditType_key = t.AuditType_key
        INNER JOIN mart.AuditScoreSection AS s ON t.AuditTypeId = s.AuditTypeId AND t.AuditTypeVersion = s.AuditTypeVersion AND x.SectionId =s.SectionId
        INNER JOIN mart.AuditGradingSetOption AS g ON x.GradingSetOptionId = g.GradingSetOptionId
        INNER JOIN mart.Wallet AS w ON x.WalletId = w.WalletId;

    PRINT 'INSERT mart.AuditScoreSectionFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
