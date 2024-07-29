DROP PROCEDURE IF EXISTS mart.ETL_MaintainReportedIssueCategoryDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainReportedIssueCategoryDimension @reportedIssueCategoryTable mart.ETL_ReportedIssueCategoryTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.ReportedIssueCategory AS target
    USING (
        SELECT
            a.SubcategoryId,
            a.CategoryVersion,
            a.CategoryName,
            a.CategoryDescription,
            a.SubcategoryName,
            a.SubcategoryDescription,
            a.SubcategoryOrder,
            w.Wallet_key
        FROM
            @reportedIssueCategoryTable AS a
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON
        target.SubcategoryId = source.SubcategoryId
        AND target.CategoryVersion = source.CategoryVersion
    WHEN MATCHED AND (
            target.CategoryName <> source.CategoryName
            OR target.CategoryDescription <> source.CategoryDescription
            OR target.SubcategoryName <> source.SubcategoryName
            OR target.SubcategoryDescription <> source.SubcategoryDescription
            OR target.SubcategoryOrder <> source.SubcategoryOrder
            OR target.Wallet_key <> source.Wallet_key
        ) THEN
        UPDATE SET
            target.CategoryName = source.CategoryName,
            target.CategoryDescription = source.CategoryDescription,
            target.SubcategoryName = source.SubcategoryName,
            target.SubcategoryDescription = source.SubcategoryDescription,
            target.SubcategoryOrder = source.SubcategoryOrder,
            target.Wallet_key = source.Wallet_key,
            target._edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            SubcategoryId,
            CategoryVersion,
            CategoryName,
            CategoryDescription,
            SubcategoryName,
            SubcategoryDescription,
            SubcategoryOrder,
            Wallet_key
        )
        VALUES (
            source.SubcategoryId,
            source.CategoryVersion,
            source.CategoryName,
            source.CategoryDescription,
            source.SubcategoryName,
            source.SubcategoryDescription,
            source.SubcategoryOrder,
            source.Wallet_key
        );

    PRINT 'MERGE mart.ReportedIssueCategory, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
