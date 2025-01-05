DROP PROCEDURE IF EXISTS mart.ETL_LoadAuditBranchOptionFact;
GO

CREATE PROCEDURE mart.ETL_LoadAuditBranchOptionFact
    @auditBranchOptionTable mart.ETL_AuditBranchOptionTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO mart.AuditBranchOptionFact
    (
        Audit_key
        ,AuditBranchOption_key
        ,Wallet_key
    )
    SELECT DISTINCT
        a.Audit_key
        ,o.AuditBranchOption_key
        ,w.Wallet_key
    FROM
        @auditBranchOptionTable AS x
        INNER JOIN mart.[Audit] AS a ON x.AuditId = a.AuditId
        INNER JOIN mart.AuditBranchOption AS o ON x.BranchId = o.BranchId AND x.OptionId = o.OptionId
        INNER JOIN mart.Wallet AS w ON x.WalletId = w.WalletId;

    PRINT 'INSERT mart.AuditBranchOptionFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
