DROP PROCEDURE IF EXISTS mart.ETL_MaintainLocationDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainLocationDimension @locationTable mart.ETL_LocationTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.[Location] AS target
    USING (
        SELECT
            a.LocationId,
            a.LocationTypeCode,
            a.LocationType,
            a.[Location],
            a.CompanyId,
            a.Company,
            a.SiteId,
            a.[Site],
            a.AreaId,
            a.Area,
            a.JobId,
            a.Job,
            a.SiteLocationId,
            a.Department,
            a.ExternalIdentifier,
            w.Wallet_key
        FROM
            @locationTable AS a
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON target.LocationId = source.LocationId
    WHEN MATCHED AND (
        target.LocationTypeCode <> source.LocationTypeCode
        OR target.LocationType <> source.LocationType
        OR target.[Location] <> source.[Location]
        OR target.CompanyId <> source.CompanyId
        OR target.Company <> source.Company
        OR target.SiteId <> source.SiteId
        OR target.[Site] <> source.[Site]
        OR target.AreaId <> source.AreaId
        OR target.Area <> source.Area
        OR target.JobId <> source.JobId
        OR target.Job <> source.Job
        OR target.SiteLocationId <> source.SiteLocationId
        OR target.Department <> source.Department
        OR target.ExternalIdentifier <> source.ExternalIdentifier
        OR target.Wallet_key <> source.Wallet_key
    ) THEN
        UPDATE SET
            target.LocationTypeCode = source.LocationTypeCode,
            target.LocationType = source.LocationType,
            target.[Location] = source.[Location],
            target.CompanyId = source.CompanyId,
            target.Company = source.Company,
            target.SiteId = source.SiteId,
            target.[Site] = source.[Site],
            target.AreaId = source.AreaId,
            target.Area = source.Area,
            target.JobId = source.JobId,
            target.Job = source.Job,
            target.SiteLocationId = source.SiteLocationId,
            target.Department = source.Department,
            target.ExternalIdentifier = source.ExternalIdentifier,
            target.Wallet_key = source.Wallet_key,
            target._edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            LocationId,
            LocationTypeCode,
            LocationType,
            [Location],
            CompanyId,
            Company,
            SiteId,
            [Site],
            AreaId,
            Area,
            JobId,
            Job,
            SiteLocationId,
            Department,
            ExternalIdentifier,
            Wallet_key
        )
        VALUES (
            source.LocationId,
            source.LocationTypeCode,
            source.LocationType,
            source.[Location],
            source.CompanyId,
            source.Company,
            source.SiteId,
            source.[Site],
            source.AreaId,
            source.Area,
            source.JobId,
            source.Job,
            source.SiteLocationId,
            source.Department,
            source.ExternalIdentifier,
            source.Wallet_key
        );

    PRINT 'MERGE mart.[Location], number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
