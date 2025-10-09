DROP PROCEDURE IF EXISTS mart.ETL_MaintainPPEStockDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainPPEStockDimension @ppeStockTable mart.ETL_PPEStockTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.PPEStock AS target
    USING (
        SELECT
            s.PPEStockId
            ,l.Location_key
            ,pt.PPEType_key
            ,s.StockQuantity
            ,s.WarningQuantity
            ,w.Wallet_key
        FROM
            @ppeStockTable AS s
            INNER JOIN mart.Wallet AS w ON s.WalletId = w.WalletId
            INNER JOIN mart.Location AS l ON s.LocationId = l.LocationId
            INNER JOIN mart.PPEType AS pt ON s.PPETypeId = pt.PPETypeId AND s.PPETypeVariantId = pt.PPETypeVariantId
    ) AS source
    ON target.PPEStockId = source.PPEStockId
    WHEN MATCHED AND (
        target.Location_key <> source.Location_key
        OR target.PPEType_key <> source.PPEType_key
        OR target.StockQuantity <> source.StockQuantity
        OR target.WarningQuantity IS DISTINCT FROM source.WarningQuantity
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            Location_key = source.Location_key
            ,PPEType_key = source.PPEType_key
            ,StockQuantity = source.StockQuantity
            ,WarningQuantity = source.WarningQuantity
            ,Wallet_key = source.Wallet_key
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            PPEStockId
            ,Location_key
            ,PPEType_key
            ,StockQuantity
            ,WarningQuantity
            ,Wallet_key
        ) VALUES (
            source.PPEStockId
            ,source.Location_key
            ,source.PPEType_key
            ,source.StockQuantity
            ,source.WarningQuantity
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.PPEStock, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
