DROP PROCEDURE IF EXISTS mart.ETL_LoadPPEGroupFact;
GO

CREATE PROCEDURE mart.ETL_LoadPPEGroupFact
    @ppeTypeGroupTable mart.ETL_PPETypeGroupTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO mart.PPEGroupFact
    (
        PPEType_key
        ,PPEGroup_key
        ,Wallet_key
    )
    SELECT DISTINCT
        pt.PPEType_key
        ,pg.PPEGroup_key
        ,w.Wallet_key
    FROM
        @ppeTypeGroupTable AS ptg
        INNER JOIN mart.Wallet AS w ON ptg.WalletId = w.WalletId
        INNER JOIN mart.PPEType AS pt ON ptg.PPETypeId = pt.PPETypeId
        INNER JOIN mart.PPEGroup AS pg ON ptg.PPEGroupId = pg.PPEGroupId;

    PRINT 'INSERT mart.PPEGroupFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
