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

    -- TODO

    PRINT 'RESET (deleting old data), total number of rows deleted = ' + CAST(@rows AS varchar);

END
GO
