DROP PROCEDURE IF EXISTS mart.ETL_MaintainPPEStockHistoryDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainPPEStockHistoryDimension @ppeStockHistoryTable mart.ETL_PPEStockHistoryTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.PPEStockHistory AS target
    USING (
        SELECT
            s.PPEStockHistoryId
            ,ps.PPEStock_key
            ,pa.PPEAction_key
            ,tps.PPEStock_key AS TransferredFromPPEStock_key
            ,s.StockQuantity
            ,c.Contact_key AS ActionedByContact_key
            ,s.ActionedOn
            ,s.Notes
            ,w.Wallet_key
        FROM
            @ppeStockHistoryTable AS s
            INNER JOIN mart.PPEStock AS ps ON s.PPEStockId = ps.PPEStockId
            INNER JOIN mart.PPEAction AS pa ON s.PPEActionCode = pa.PPEActionCode
            LEFT JOIN mart.PPEStock AS tps ON s.TransferredFromStockId = tps.PPEStockId
            LEFT JOIN mart.Contact AS c ON s.ActionedByContactId = c.ContactId
            INNER JOIN mart.Wallet AS w ON s.WalletId = w.WalletId
    ) AS source
    ON target.PPEStockHistoryId = source.PPEStockHistoryId
    WHEN MATCHED AND (
        target.PPEStock_key <> source.PPEStock_key
        OR target.PPEAction_key <> source.PPEAction_key
        OR target.TransferredFromPPEStock_key IS DISTINCT FROM source.TransferredFromPPEStock_key
        OR target.StockQuantity <> source.StockQuantity
        OR target.ActionedByContact_key IS DISTINCT FROM source.ActionedByContact_key
        OR target.ActionedOn <> source.ActionedOn
        OR target.Notes IS DISTINCT FROM source.Notes
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            PPEStock_key = source.PPEStock_key
            ,PPEAction_key = source.PPEAction_key
            ,TransferredFromPPEStock_key = source.TransferredFromPPEStock_key
            ,StockQuantity = source.StockQuantity
            ,ActionedByContact_key = source.ActionedByContact_key
            ,ActionedOn = source.ActionedOn
            ,Notes = source.Notes
            ,Wallet_key = source.Wallet_key
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            PPEStockHistoryId
            ,PPEStock_key
            ,PPEAction_key
            ,TransferredFromPPEStock_key
            ,StockQuantity
            ,ActionedByContact_key
            ,ActionedOn
            ,Notes
            ,Wallet_key
        ) VALUES (
            source.PPEStockHistoryId
            ,source.PPEStock_key
            ,source.PPEAction_key
            ,source.TransferredFromPPEStock_key
            ,source.StockQuantity
            ,source.ActionedByContact_key
            ,source.ActionedOn
            ,source.Notes
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.PPEStockHistory, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
