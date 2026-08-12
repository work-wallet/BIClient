DROP PROCEDURE IF EXISTS mart.ETL_LoadAssetInspectionBranchOptionFact;
GO

CREATE PROCEDURE mart.ETL_LoadAssetInspectionBranchOptionFact
    @assetInspectionBranchOptionTable mart.ETL_AssetInspectionBranchOptionTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO mart.AssetInspectionBranchOptionFact
    (
        AssetInspection_key
        ,AssetInspectionBranchOption_key
        ,Wallet_key
    )
    SELECT DISTINCT
        i.AssetInspection_key
        ,o.AssetInspectionBranchOption_key
        ,w.Wallet_key
    FROM
        @assetInspectionBranchOptionTable AS x
        INNER JOIN mart.AssetInspection AS i ON x.InspectionId = i.InspectionId
        INNER JOIN mart.AssetInspectionBranchOption AS o ON x.BranchId = o.BranchId AND x.OptionId = o.OptionId
        INNER JOIN mart.Wallet AS w ON x.WalletId = w.WalletId;

    PRINT 'INSERT mart.AssetInspectionBranchOptionFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
