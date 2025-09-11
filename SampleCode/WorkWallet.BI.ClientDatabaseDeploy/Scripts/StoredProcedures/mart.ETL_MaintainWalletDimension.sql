DROP PROCEDURE IF EXISTS mart.ETL_MaintainWalletDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainWalletDimension @walletTable mart.ETL_WalletTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.Wallet AS target
    USING (
        SELECT
            a.WalletId
            ,a.Wallet
        FROM
            @walletTable AS a
    ) AS source
    ON target.WalletId = source.WalletId
    WHEN MATCHED AND (
        target.Wallet <> source.Wallet
    )
    THEN
        UPDATE SET
            Wallet = source.Wallet
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            WalletId
            ,Wallet
        ) VALUES (
            source.WalletId
            ,source.Wallet
        );

    PRINT 'MERGE mart.Wallet, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
