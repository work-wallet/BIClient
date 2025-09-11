DROP PROCEDURE IF EXISTS mart.ETL_MaintainSafetyCardCategoryDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainSafetyCardCategoryDimension @safetyCardCategoryTable mart.ETL_SafetyCardCategoryTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.SafetyCardCategory AS target
    USING (
        SELECT
            a.SafetyCardCategoryId
            ,a.CategoryName
            ,a.CategoryReference
            ,w.Wallet_key
        FROM
            @safetyCardCategoryTable AS a
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON
        target.SafetyCardCategoryId = source.SafetyCardCategoryId
    WHEN MATCHED AND (
        target.CategoryName <> source.CategoryName
        OR target.CategoryReference <> source.CategoryReference
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            CategoryName = source.CategoryName
            ,CategoryReference = source.CategoryReference
            ,Wallet_key = source.Wallet_key
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            SafetyCardCategoryId
            ,CategoryName
            ,CategoryReference
            ,Wallet_key
        ) VALUES (
            source.SafetyCardCategoryId
            ,source.CategoryName
            ,source.CategoryReference
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.SafetyCardCategory, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
