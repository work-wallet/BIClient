DROP PROCEDURE IF EXISTS mart.ETL_LoadPPEPropertyFact;
GO

CREATE PROCEDURE mart.ETL_LoadPPEPropertyFact
    @ppePropertyTable mart.ETL_PPETypePropertyTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO mart.PPEPropertyFact
    (
        PPETypeId
        ,PPEProperty_key
        ,[Value]
        ,Wallet_key
    )
    SELECT DISTINCT
        p.PPETypeId
        ,pp.PPEProperty_key
        ,p.[Value]
        ,w.Wallet_key
    FROM
        @ppePropertyTable AS p
        INNER JOIN mart.Wallet AS w ON p.WalletId = w.WalletId
        INNER JOIN mart.PPEPropertyType AS ppt ON p.PropertyType = ppt.PPEPropertyType
        INNER JOIN mart.PPEProperty AS pp ON ppt.PPEPropertyType_key = pp.PPEPropertyType_key AND p.Property = pp.Property AND w.Wallet_key = pp.Wallet_key;

    PRINT 'INSERT mart.PPEPropertyFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
