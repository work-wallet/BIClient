DROP PROCEDURE IF EXISTS mart.ETL_ResetAssetObservations;
GO

CREATE PROCEDURE mart.ETL_ResetAssetObservations @walletId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    -- get the Wallet_key
    DECLARE @wallet_key int;
    SELECT @wallet_key = Wallet_key FROM mart.Wallet WHERE WalletId = @walletId;

    DECLARE @rows int = 0;

    -- Note: AssetInspectionObservationFact links inspections and observations
    -- When resetting observations, we need to delete those links
    DELETE FROM mart.AssetInspectionObservationFact WHERE Wallet_key = @wallet_key;
    SET @rows = @rows + @@ROWCOUNT;

    DELETE FROM mart.AssetObservation WHERE Wallet_key = @wallet_key;
    SET @rows = @rows + @@ROWCOUNT;

    PRINT 'RESET (deleting old data), total number of rows deleted = ' + CAST(@rows AS varchar);

END
GO
