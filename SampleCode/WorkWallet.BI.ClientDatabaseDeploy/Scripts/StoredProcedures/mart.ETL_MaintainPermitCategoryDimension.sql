DROP PROCEDURE IF EXISTS mart.ETL_MaintainPermitCategoryDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainPermitCategoryDimension @permitToWorkCategoryTable mart.ETL_PermitToWorkCategoryTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.PermitCategory AS target
    USING (
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
    ) AS source
    ON
        target.CategoryId = source.CategoryId
        AND target.CategoryVersion = source.CategoryVersion
    WHEN MATCHED AND (
        target.CategoryName <> source.CategoryName
        OR target.ExpiryTypeId <> source.ExpiryTypeId
        OR target.ExpiryType <> source.ExpiryType
        OR target.ValidityPeriodId <> source.ValidityPeriodId
        OR target.ValidityPeriod <> source.ValidityPeriod
        OR target.ValidityPeriodMinutes <> source.ValidityPeriodMinutes
        OR target.IssueTypeId <> source.IssueTypeId
        OR target.IssueType <> source.IssueType
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            CategoryName = source.CategoryName
            ,ExpiryTypeId = source.ExpiryTypeId
            ,ExpiryType = source.ExpiryType
            ,ValidityPeriodId = source.ValidityPeriodId
            ,ValidityPeriod = source.ValidityPeriod
            ,ValidityPeriodMinutes = source.ValidityPeriodMinutes
            ,IssueTypeId = source.IssueTypeId
            ,IssueType = source.IssueType
            ,Wallet_key = source.Wallet_key
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
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
        ) VALUES (
            source.CategoryId
            ,source.CategoryVersion
            ,source.CategoryName
            ,source.ExpiryTypeId
            ,source.ExpiryType
            ,source.ValidityPeriodId
            ,source.ValidityPeriod
            ,source.ValidityPeriodMinutes
            ,source.IssueTypeId
            ,source.IssueType
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.PermitCategory, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
