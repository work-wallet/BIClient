DROP PROCEDURE IF EXISTS mart.ETL_ResetAudits;
GO

CREATE PROCEDURE mart.ETL_ResetAudits @walletId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    -- get the Wallet_key
    DECLARE @wallet_key int;
    SELECT @wallet_key = Wallet_key FROM mart.Wallet WHERE WalletId = @walletId;

    DECLARE @rows int = 0;

    DELETE FROM mart.AuditDateTimeAnswerFact WHERE Wallet_key = @wallet_key;
    SET @rows = @rows + @@ROWCOUNT;

    DELETE FROM mart.AuditDateTimeQuestion WHERE Wallet_key = @wallet_key;
    SET @rows = @rows + @@ROWCOUNT;

    DELETE FROM mart.AuditNumericAnswerFact WHERE Wallet_key = @wallet_key;
    SET @rows = @rows + @@ROWCOUNT;

    DELETE FROM mart.AuditNumericQuestion WHERE Wallet_key = @wallet_key;
    SET @rows = @rows + @@ROWCOUNT;

    DELETE FROM mart.AuditInspectedByFact WHERE Wallet_key = @wallet_key;
    SET @rows = @rows + @@ROWCOUNT;

    DELETE FROM mart.[Audit] WHERE Wallet_key = @wallet_key;
    SET @rows = @rows + @@ROWCOUNT;

    DELETE FROM mart.AuditGroup WHERE Wallet_key = @wallet_key;
    SET @rows = @rows + @@ROWCOUNT;

    DELETE FROM mart.AuditType WHERE Wallet_key = @wallet_key;
    SET @rows = @rows + @@ROWCOUNT;

    PRINT 'RESET (deleting old data), total number of rows deleted = ' + CAST(@rows AS varchar);

END
GO
