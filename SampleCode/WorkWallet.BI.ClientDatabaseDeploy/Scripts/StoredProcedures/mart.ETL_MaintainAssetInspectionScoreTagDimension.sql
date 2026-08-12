DROP PROCEDURE IF EXISTS mart.ETL_MaintainAssetInspectionScoreTagDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainAssetInspectionScoreTagDimension @assetInspectionScoreTagTable mart.ETL_AssetInspectionScoreTagTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.AssetInspectionScoreTag AS target
    USING (
        SELECT DISTINCT
            a.TagId
            ,a.TagVersion
            ,a.Tag
            ,w.Wallet_key
        FROM
            @assetInspectionScoreTagTable AS a
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON target.TagId = source.TagId AND target.TagVersion = source.TagVersion
    WHEN MATCHED AND (
        target.Tag <> source.Tag
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            Tag = source.Tag
            ,Wallet_key = source.Wallet_key
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            TagId
            ,TagVersion
            ,Tag
            ,Wallet_key
        ) VALUES (
            source.TagId
            ,source.TagVersion
            ,source.Tag
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.AssetInspectionScoreTag, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
