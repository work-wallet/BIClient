DROP PROCEDURE IF EXISTS mart.ETL_MaintainAssetAssignmentDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainAssetAssignmentDimension @assetAssignmentTable mart.ETL_AssetAssignmentTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.AssetAssignment AS target
    USING (
        SELECT DISTINCT
            a.AssignmentType
            ,aat.AssetAssignmentType_key
            ,a.AssignedTo
            ,c.Contact_key
            ,a.CompanyId
            ,a.Company
            ,a.SiteId
            ,a.[Site]
            ,w.Wallet_key
        FROM
            @assetAssignmentTable AS a
            INNER JOIN mart.AssetAssignmentType AS aat ON a.AssignmentType = aat.AssetAssignmentType
            LEFT JOIN mart.Contact AS c ON a.AssignedToContactId = c.ContactId
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON
        target.AssetAssignmentType_key = source.AssetAssignmentType_key
        AND target.Wallet_key = source.Wallet_key
        AND
        (
            -- Site assignment matches on CompanyId and SiteId
            (
                source.AssignmentType = N'Site'
                AND target.CompanyId = source.CompanyId
                AND target.SiteId = source.SiteId
            )
            OR
            -- User assignment matches on Contact_key (preferred) or falls back to AssignedTo for legacy records.
            -- Transitional logic: if target.Contact_key is NULL (legacy data), match on AssignedTo to allow
            -- the MERGE to update the record with the new Contact_key. Once Contact_key is populated in target,
            -- future matches will use Contact_key only, ensuring stable identity even if AssignedTo name changes.
            (
                source.AssignmentType = N'User'
                AND
                (
                    target.Contact_key IS NOT DISTINCT FROM source.Contact_key
                    OR
                    (
                        target.Contact_key IS NULL
                        AND target.AssignedTo = source.AssignedTo
                    )
                )
            )
            -- Unassigned assignment matches on Wallet_key only
            OR
            (
                source.AssignmentType = N'Unassigned'
            )
        )
    WHEN MATCHED AND
        (
            target.AssignedTo <> source.AssignedTo
            OR target.Contact_key IS DISTINCT FROM source.Contact_key
            OR target.CompanyId <> source.CompanyId
            OR target.Company <> source.Company
            OR target.SiteId <> source.SiteId
            OR target.[Site] <> source.[Site]
        )
    THEN
        UPDATE SET
            AssignedTo = source.AssignedTo
            ,Contact_key = source.Contact_key
            ,CompanyId = source.CompanyId
            ,Company = source.Company
            ,SiteId = source.SiteId
            ,[Site] = source.[Site]
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            AssetAssignmentType_key
            ,AssignedTo
            ,Contact_key
            ,CompanyId
            ,Company
            ,SiteId
            ,[Site]
            ,Wallet_key
        ) VALUES (
            source.AssetAssignmentType_key
            ,source.AssignedTo
            ,source.Contact_key
            ,source.CompanyId
            ,source.Company
            ,source.SiteId
            ,source.[Site]
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.AssetAssignment, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

END
GO
