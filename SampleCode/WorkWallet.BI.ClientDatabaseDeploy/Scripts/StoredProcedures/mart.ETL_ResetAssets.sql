DROP PROCEDURE IF EXISTS mart.ETL_ResetAssets;
GO

CREATE PROCEDURE mart.ETL_ResetAssets @walletId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    -- get the Wallet_key
    DECLARE @wallet_key int;
    SELECT @wallet_key = Wallet_key FROM mart.Wallet WHERE WalletId = @walletId;

    DECLARE @rows int = 0;

    DELETE FROM mart.AssetAssignmentFact WHERE Wallet_key = @wallet_key;
    SET @rows = @rows + @@ROWCOUNT;

    DELETE FROM mart.AssetAssignment WHERE Wallet_key = @wallet_key;
    SET @rows = @rows + @@ROWCOUNT;

    DELETE FROM mart.AssetPropertyFact WHERE Wallet_key = @wallet_key;
    SET @rows = @rows + @@ROWCOUNT;

    DELETE FROM mart.AssetProperty WHERE Wallet_key = @wallet_key;
    SET @rows = @rows + @@ROWCOUNT;

    -- Note: Asset dimension itself is NOT deleted - it's shared with AssetInspections and AssetObservations
    -- See also mart.ETL_ResetAssetCommon

    PRINT 'RESET (deleting old data), total number of rows deleted = ' + CAST(@rows AS varchar);

END
GO
