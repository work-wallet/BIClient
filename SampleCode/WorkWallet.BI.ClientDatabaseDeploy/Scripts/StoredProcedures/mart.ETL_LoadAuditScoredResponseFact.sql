DROP PROCEDURE IF EXISTS mart.ETL_LoadAuditScoredResponseFact;
GO

CREATE PROCEDURE mart.ETL_LoadAuditScoredResponseFact
    @auditScoredResponseTable mart.ETL_AuditScoredResponseTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO mart.AuditScoredResponseFact
    (
        Audit_key
        ,AuditScoredResponse_key
        ,TotalScore
        ,TotalPotentialScore
        ,PercentageScore
        ,Flag
        ,GradingSetOption_key
        ,Wallet_key
    )
    SELECT DISTINCT
        a.Audit_key
        ,o.AuditScoredResponse_key
        ,x.TotalScore
        ,x.TotalPotentialScore
        ,x.PercentageScore
        ,x.Flag
        ,gso.GradingSetOption_key
        ,w.Wallet_key
    FROM
        @auditScoredResponseTable AS x
        INNER JOIN mart.[Audit] AS a ON x.AuditId = a.AuditId
        INNER JOIN mart.AuditScoredResponse AS o ON x.BranchId = o.BranchId AND x.OptionId = o.OptionId
        INNER JOIN mart.GradingSetOption AS gso ON x.GradingSetOptionId = gso.GradingSetOptionId
        INNER JOIN mart.Wallet AS w ON x.WalletId = w.WalletId;

    PRINT 'INSERT mart.AuditScoredResponseFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
