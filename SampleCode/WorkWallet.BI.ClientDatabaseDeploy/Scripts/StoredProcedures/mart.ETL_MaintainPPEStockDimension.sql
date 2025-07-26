DROP PROCEDURE IF EXISTS mart.ETL_MaintainPPEStockDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainPPEStockDimension @ppeStockTable mart.ETL_PPEStockTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.PPEStock AS target
    USING (
        SELECT
            s.PPEStockId,
            s.LocationId,
            s.PPETypeId,
            s.PPETypeVariantId,
            s.StockQuantity,
            s.WarningQuantity,
            w.Wallet_key
        FROM
            @ppeStockTable AS s
            INNER JOIN mart.Wallet AS w ON s.WalletId = w.WalletId
    ) AS source
    ON target.PPEStockId = source.PPEStockId
    WHEN MATCHED AND (
        target.LocationId <> source.LocationId
        OR target.PPETypeId <> source.PPETypeId
        OR target.PPETypeVariantId <> source.PPETypeVariantId
        OR target.StockQuantity <> source.StockQuantity
        OR target.WarningQuantity IS DISTINCT FROM source.WarningQuantity
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            LocationId = source.LocationId,
            PPETypeId = source.PPETypeId,
            PPETypeVariantId = source.PPETypeVariantId,
            StockQuantity = source.StockQuantity,
            WarningQuantity = source.WarningQuantity,
            Wallet_key = source.Wallet_key,
            _edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            PPEStockId,
            LocationId,
            PPETypeId,
            PPETypeVariantId,
            StockQuantity,
            WarningQuantity,
            Wallet_key
        ) VALUES (
            source.PPEStockId,
            source.LocationId,
            source.PPETypeId,
            source.PPETypeVariantId,
            source.StockQuantity,
            source.WarningQuantity,
            source.Wallet_key
        );

    PRINT 'MERGE mart.PPEStock, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
