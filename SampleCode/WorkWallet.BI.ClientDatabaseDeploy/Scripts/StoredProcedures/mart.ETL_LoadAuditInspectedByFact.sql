DROP PROCEDURE IF EXISTS mart.ETL_LoadAuditInspectedByFact;
GO

CREATE PROCEDURE mart.ETL_LoadAuditInspectedByFact
    @auditInspectedByTable mart.ETL_AuditInspectedByTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO mart.AuditInspectedByFact
    (
        Audit_key
        ,Contact_key
        ,Wallet_key
    )
    SELECT DISTINCT
        a.Audit_key
        ,c.Contact_key
        ,w.Wallet_key
    FROM
        @auditInspectedByTable AS x
        INNER JOIN mart.[Audit] AS a ON x.AuditId = a.AuditId
        INNER JOIN mart.Contact AS c ON x.ContactId = c.ContactId
        INNER JOIN mart.Wallet AS w ON x.WalletId = w.WalletId;

    PRINT 'INSERT mart.AuditInspectedByFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
