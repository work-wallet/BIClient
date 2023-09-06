DROP PROCEDURE IF EXISTS mart.ETL_MaintainWalletDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainWalletDimension @walletTable mart.ETL_WalletTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    -- type 1 changes (do first, before inserting new)
    UPDATE mart.Wallet
    SET
        Wallet = a.Wallet
        ,_edited = SYSUTCDATETIME()
    FROM
        @walletTable AS a
        INNER JOIN mart.Wallet AS b ON a.WalletId = b.WalletId
    WHERE /* only where the data has changed */
        a.Wallet <> b.Wallet;

    PRINT 'UPDATE mart.Wallet, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

    -- insert missing entries
    INSERT INTO mart.Wallet
    (
        WalletId
        ,Wallet
    )
    SELECT
        a.WalletId
        ,a.Wallet
    FROM
        @walletTable AS a
        LEFT OUTER JOIN mart.Wallet AS b ON a.WalletId = b.WalletId
    WHERE
        b.WalletId IS NULL;

    PRINT 'INSERT mart.Wallet, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
