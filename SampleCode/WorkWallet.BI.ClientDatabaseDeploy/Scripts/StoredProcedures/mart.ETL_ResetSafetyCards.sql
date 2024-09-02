DROP PROCEDURE IF EXISTS mart.ETL_ResetSafetyCards;
GO

CREATE PROCEDURE mart.ETL_ResetSafetyCards @walletId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    -- get the Wallet_key
    DECLARE @wallet_key int;
    SELECT @wallet_key = Wallet_key FROM mart.Wallet WHERE WalletId = @walletId;

    DECLARE @rows int = 0;

    DELETE FROM mart.SafetyCard WHERE Wallet_key = @wallet_key;
    SET @rows = @rows + @@ROWCOUNT;

    DELETE FROM mart.SafetyCardCategory WHERE Wallet_key = @wallet_key;
    SET @rows = @rows + @@ROWCOUNT;

    PRINT 'RESET (deleting old data), total number of rows deleted = ' + CAST(@rows AS varchar);

END
GO
