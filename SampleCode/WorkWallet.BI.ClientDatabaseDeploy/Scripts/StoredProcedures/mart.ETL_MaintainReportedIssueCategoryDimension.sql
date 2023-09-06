DROP PROCEDURE IF EXISTS mart.ETL_MaintainReportedIssueCategoryDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainReportedIssueCategoryDimension @reportedIssueCategoryTable mart.ETL_ReportedIssueCategoryTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    -- type 1 changes (do first, before inserting new)
    UPDATE mart.ReportedIssueCategory
    SET
        CategoryName = a.CategoryName
        ,CategoryDescription = a.CategoryDescription
        ,SubcategoryName = a.SubcategoryName
        ,SubcategoryDescription = a.SubcategoryDescription
        ,SubcategoryOrder = a.SubcategoryOrder
        ,Wallet_key = w.Wallet_key
        ,_edited = SYSUTCDATETIME()
    FROM
        @reportedIssueCategoryTable AS a
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        INNER JOIN mart.ReportedIssueCategory AS b ON
            a.SubcategoryId = b.SubcategoryId
            AND a.CategoryVersion = b.CategoryVersion
    WHERE /* only where the data has changed */
        a.CategoryName <> b.CategoryName
        OR a.CategoryDescription <> b.CategoryDescription
        OR a.SubcategoryName <> b.SubcategoryName
        OR a.SubcategoryDescription <> b.SubcategoryDescription
        OR a.SubcategoryOrder <> b.SubcategoryOrder
        OR w.Wallet_key <> b.Wallet_key;

    PRINT 'UPDATE mart.ReportedIssueCategory, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

    -- insert missing entries
    INSERT INTO mart.ReportedIssueCategory
    (
        SubcategoryId
        ,CategoryVersion
        ,CategoryName
        ,CategoryDescription
        ,SubcategoryName
        ,SubcategoryDescription
        ,SubcategoryOrder
        ,Wallet_key
    )
    SELECT
        a.SubcategoryId
        ,a.CategoryVersion
        ,a.CategoryName
        ,a.CategoryDescription
        ,a.SubcategoryName
        ,a.SubcategoryDescription
        ,a.SubcategoryOrder
        ,w.Wallet_key
    FROM
        @reportedIssueCategoryTable AS a
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        LEFT OUTER JOIN mart.ReportedIssueCategory AS b ON
            a.SubcategoryId = b.SubcategoryId
            AND a.CategoryVersion = b.CategoryVersion
    WHERE
        b.SubcategoryId IS NULL;

    PRINT 'INSERT mart.ReportedIssueCategory, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
