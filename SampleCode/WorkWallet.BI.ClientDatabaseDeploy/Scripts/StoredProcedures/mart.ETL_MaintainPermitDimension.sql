DROP PROCEDURE IF EXISTS mart.ETL_MaintainPermitDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainPermitDimension @permitToWorkTable mart.ETL_PermitToWorkTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.Permit AS target
    USING (
        SELECT
            a.PermitToWorkId
            ,a.PermitToWorkReference
            ,pc.PermitCategory_key
            ,l.Location_key
            ,a.[Description]
            ,a.IssuedToCompanyId
            ,a.IssuedToCompany
            ,a.IssuedOn
            ,a.IssuedForMinutes
            ,a.IssuedExpiry
            ,a.ClosedOn
            ,ps.PermitStatus_key
            ,a.HasBeenExpired
            ,a.HasBeenClosed
            ,w.Wallet_key
        FROM
            @permitToWorkTable AS a
            INNER JOIN mart.PermitCategory AS pc ON a.CategoryId = pc.CategoryId AND a.CategoryVersion = pc.CategoryVersion
            INNER JOIN mart.[Location] AS l ON a.SiteLocationId = l.LocationId
            INNER JOIN mart.PermitStatus AS ps ON a.StatusId = ps.PermitStatusCode
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON target.PermitId = source.PermitToWorkId
    WHEN MATCHED AND (
        target.PermitReference <> source.PermitToWorkReference
        OR target.PermitCategory_key <> source.PermitCategory_key
        OR target.Location_key <> source.Location_key
        OR target.PermitDescription <> source.[Description]
        OR target.IssuedToCompanyId <> source.IssuedToCompanyId
        OR target.IssuedToCompany <> source.IssuedToCompany
        OR target.IssuedOn <> source.IssuedOn
        OR target.IssuedForMinutes <> source.IssuedForMinutes
        OR target.IssuedExpiry <> source.IssuedExpiry
        OR target.ClosedOn <> source.ClosedOn
        OR target.PermitStatus_key <> source.PermitStatus_key
        OR target.HasBeenExpired <> source.HasBeenExpired
        OR target.HasBeenClosed <> source.HasBeenClosed
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            PermitReference = source.PermitToWorkReference
            ,PermitCategory_key = source.PermitCategory_key
            ,Location_key = source.Location_key
            ,PermitDescription = source.[Description]
            ,IssuedToCompanyId = source.IssuedToCompanyId
            ,IssuedToCompany = source.IssuedToCompany
            ,IssuedOn = source.IssuedOn
            ,IssuedForMinutes = source.IssuedForMinutes
            ,IssuedExpiry = source.IssuedExpiry
            ,ClosedOn = source.ClosedOn
            ,PermitStatus_key = source.PermitStatus_key
            ,HasBeenExpired = source.HasBeenExpired
            ,HasBeenClosed = source.HasBeenClosed
            ,Wallet_key = source.Wallet_key
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            PermitId
            ,PermitReference
            ,PermitCategory_key
            ,Location_key
            ,PermitDescription
            ,IssuedToCompanyId
            ,IssuedToCompany
            ,IssuedOn
            ,IssuedForMinutes
            ,IssuedExpiry
            ,ClosedOn
            ,PermitStatus_key
            ,HasBeenExpired
            ,HasBeenClosed
            ,Wallet_key
        ) VALUES (
            source.PermitToWorkId
            ,source.PermitToWorkReference
            ,source.PermitCategory_key
            ,source.Location_key
            ,source.[Description]
            ,source.IssuedToCompanyId
            ,source.IssuedToCompany
            ,source.IssuedOn
            ,source.IssuedForMinutes
            ,source.IssuedExpiry
            ,source.ClosedOn
            ,source.PermitStatus_key
            ,source.HasBeenExpired
            ,source.HasBeenClosed
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.Permit, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
