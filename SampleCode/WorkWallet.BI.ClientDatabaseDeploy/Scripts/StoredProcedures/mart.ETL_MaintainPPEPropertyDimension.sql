DROP PROCEDURE IF EXISTS mart.ETL_MaintainPPEPropertyDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainPPEPropertyDimension @ppePropertyTable mart.ETL_PPETypePropertyTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.PPEProperty AS target
    USING (
        SELECT DISTINCT
            ppt.PPEPropertyType_key
            ,p.Property
            ,p.DisplayOrder
            ,w.Wallet_key
        FROM
            @ppePropertyTable AS p
            INNER JOIN mart.PPEPropertyType AS ppt ON p.PropertyType = ppt.PPEPropertyType
            INNER JOIN mart.Wallet AS w ON p.WalletId = w.WalletId
    ) AS source
    ON
        target.PPEPropertyType_key = source.PPEPropertyType_key
        AND target.Property = source.Property
        AND target.Wallet_key = source.Wallet_key
    WHEN MATCHED THEN
        UPDATE SET
            DisplayOrder = source.DisplayOrder
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            PPEPropertyType_key
            ,Property
            ,DisplayOrder
            ,Wallet_key
        ) VALUES (
            source.PPEPropertyType_key
            ,source.Property
            ,source.DisplayOrder
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.PPEProperty, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

END
GO
