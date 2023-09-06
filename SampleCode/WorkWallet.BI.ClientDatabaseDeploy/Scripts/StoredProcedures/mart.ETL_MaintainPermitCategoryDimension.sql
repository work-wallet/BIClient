DROP PROCEDURE IF EXISTS mart.ETL_MaintainPermitCategoryDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainPermitCategoryDimension @permitToWorkCategoryTable mart.ETL_PermitToWorkCategoryTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    -- type 1 changes (do first, before inserting new)
    UPDATE mart.PermitCategory
    SET
        CategoryName = a.CategoryName
        ,ExpiryTypeId = a.ExpiryTypeId
        ,ExpiryType = a.ExpiryType
        ,ValidityPeriodId = a.ValidityPeriodId
        ,ValidityPeriod = a.ValidityPeriod
        ,ValidityPeriodMinutes = a.ValidityPeriodMinutes
        ,IssueTypeId = a.IssueTypeId
        ,IssueType = a.IssueType
        ,Wallet_key = w.Wallet_key
        ,_edited = SYSUTCDATETIME()
    FROM
        @permitToWorkCategoryTable AS a
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        INNER JOIN mart.PermitCategory AS b ON
            a.CategoryId = b.CategoryId
            AND a.CategoryVersion = b.CategoryVersion
    WHERE /* only where the data has changed */
        a.CategoryName <> b.CategoryName
        OR a.ExpiryTypeId <> b.ExpiryTypeId
        OR a.ExpiryType <> b.ExpiryType
        OR a.ValidityPeriodId <> b.ValidityPeriodId
        OR a.ValidityPeriod <> b.ValidityPeriod
        OR a.ValidityPeriodMinutes <> b.ValidityPeriodMinutes
        OR a.IssueTypeId <> b.IssueTypeId
        OR a.IssueType <> b.IssueType
        OR w.Wallet_key <> b.Wallet_key;

    PRINT 'UPDATE mart.PermitCategory, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

    -- insert missing entries
    INSERT INTO mart.PermitCategory
    (
        CategoryId
        ,CategoryVersion
        ,CategoryName
        ,ExpiryTypeId
        ,ExpiryType
        ,ValidityPeriodId
        ,ValidityPeriod
        ,ValidityPeriodMinutes
        ,IssueTypeId
        ,IssueType
        ,Wallet_key
    )
    SELECT
        a.CategoryId
        ,a.CategoryVersion
        ,a.CategoryName
        ,a.ExpiryTypeId
        ,a.ExpiryType
        ,a.ValidityPeriodId
        ,a.ValidityPeriod
        ,a.ValidityPeriodMinutes
        ,a.IssueTypeId
        ,a.IssueType
        ,w.Wallet_key
    FROM
        @permitToWorkCategoryTable AS a
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        LEFT OUTER JOIN mart.PermitCategory AS b ON
            a.CategoryId = b.CategoryId
            AND a.CategoryVersion = b.CategoryVersion
    WHERE
        b.CategoryId IS NULL;

    PRINT 'INSERT mart.PermitCategory, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
