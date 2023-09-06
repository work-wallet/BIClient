DROP PROCEDURE IF EXISTS mart.ETL_MaintainLocationDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainLocationDimension @locationTable mart.ETL_LocationTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    -- type 1 changes (do first, before inserting new)
    UPDATE mart.[Location]
    SET
        LocationTypeCode = a.LocationTypeCode
        ,LocationType = a.LocationType
        ,[Location] = a.[Location]
        ,CompanyId = a.CompanyId
        ,Company = a.Company
        ,SiteId = a.SiteId
        ,[Site] = a.[Site]
        ,AreaId = a.AreaId
        ,Area = a.Area
        ,JobId = a.JobId
        ,Job = a.Job
        ,SiteLocationId = a.SiteLocationId
        ,Department = a.Department
        ,Wallet_key = w.Wallet_key
        ,_edited = SYSUTCDATETIME()
    FROM
        @locationTable AS a
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        INNER JOIN mart.[Location] AS b ON a.LocationId = b.LocationId
    WHERE /* only where the data has changed */
        a.LocationTypeCode <> b.LocationTypeCode
        OR a.LocationType <> b.LocationType
        OR a.[Location] <> b.[Location]
        OR a.CompanyId <> b.CompanyId
        OR a.Company <> b.Company
        OR a.SiteId <> b.SiteId
        OR a.[Site] <> b.[Site]
        OR a.AreaId <> b.AreaId
        OR a.Area <> b.Area
        OR a.JobId <> b.JobId
        OR a.Job <> b.Job
        OR a.SiteLocationId <> b.SiteLocationId
        OR a.Department <> b.Department
        OR w.Wallet_key <> b.Wallet_key;

    PRINT 'UPDATE mart.[Location], number of rows = ' + CAST(@@ROWCOUNT AS varchar);

    -- insert missing entries
    INSERT INTO mart.[Location]
    (
        LocationId
        ,LocationTypeCode
        ,LocationType
        ,[Location]
        ,CompanyId
        ,Company
        ,SiteId
        ,[Site]
        ,AreaId
        ,Area
        ,JobId
        ,Job
        ,SiteLocationId
        ,Department
        ,Wallet_key
    )
    SELECT
        a.LocationId
        ,a.LocationTypeCode
        ,a.LocationType
        ,a.[Location]
        ,a.CompanyId
        ,a.Company
        ,a.SiteId
        ,a.[Site]
        ,a.AreaId
        ,a.Area
        ,a.JobId
        ,a.Job
        ,a.SiteLocationId
        ,a.Department
        ,w.Wallet_key
    FROM
        @locationTable AS a
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        LEFT OUTER JOIN mart.[Location] AS b ON a.LocationId = b.LocationId
    WHERE
        b.LocationId IS NULL;

    PRINT 'INSERT mart.[Location], number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
