DROP PROCEDURE IF EXISTS mart.ETL_LoadPermitBranchOptionFact;
GO

CREATE PROCEDURE mart.ETL_LoadPermitBranchOptionFact
    @permitToWorkBranchOptionTable mart.ETL_PermitToWorkBranchOptionTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO mart.PermitBranchOptionFact
    (
        Permit_key
        ,PermitBranchOption_key
        ,Wallet_key
    )
    SELECT DISTINCT
        p.Permit_key
        ,o.PermitBranchOption_key
        ,w.Wallet_key
    FROM
        @permitToWorkBranchOptionTable AS x
        INNER JOIN mart.Permit AS p ON x.PermitToWorkId = p.PermitId
        INNER JOIN mart.PermitBranchOption AS o ON x.BranchId = o.BranchId AND x.OptionId = o.OptionId
        INNER JOIN mart.Wallet AS w ON x.WalletId = w.WalletId;

    PRINT 'INSERT mart.PermitBranchOptionFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
