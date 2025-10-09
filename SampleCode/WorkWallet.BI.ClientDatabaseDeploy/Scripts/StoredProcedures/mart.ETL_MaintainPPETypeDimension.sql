DROP PROCEDURE IF EXISTS mart.ETL_MaintainPPETypeDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainPPETypeDimension @ppeTypeTable mart.ETL_PPETypeTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.PPEType AS target
    USING (
        SELECT
            a.PPETypeId
            ,a.PPETypeVariantId
            ,a.[Type]
            ,a.Variant
            ,a.VariantOrder
            ,a.LifespanDays
            ,a.[Value]
            ,a.TypeDeleted
            ,a.VariantDeleted
            ,w.Wallet_key        
        FROM
            @ppeTypeTable AS a
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON target.PPETypeId = source.PPETypeId AND target.PPETypeVariantId = source.PPETypeVariantId
    WHEN MATCHED AND (
        target.[Type] <> source.[Type]
        OR target.Variant IS DISTINCT FROM source.Variant
        OR target.VariantOrder IS DISTINCT FROM source.VariantOrder
        OR target.LifespanDays IS DISTINCT FROM source.LifespanDays
        OR target.[Value] IS DISTINCT FROM source.[Value]
        OR target.TypeDeleted <> source.TypeDeleted
        OR target.VariantDeleted <> source.VariantDeleted
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            [Type] = source.[Type]
            ,Variant = source.Variant
            ,VariantOrder = source.VariantOrder
            ,LifespanDays = source.LifespanDays
            ,[Value] = source.[Value]
            ,TypeDeleted = source.TypeDeleted
            ,VariantDeleted = source.VariantDeleted
            ,Wallet_key = source.Wallet_key
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            PPETypeId
            ,PPETypeVariantId
            ,[Type]
            ,Variant
            ,VariantOrder
            ,LifespanDays
            ,[Value]
            ,TypeDeleted
            ,VariantDeleted
            ,Wallet_key
        ) VALUES (
            source.PPETypeId
            ,source.PPETypeVariantId
            ,source.[Type]
            ,source.Variant
            ,source.VariantOrder
            ,source.LifespanDays
            ,source.[Value]
            ,source.TypeDeleted
            ,source.VariantDeleted
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.PPEType, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
