DROP PROCEDURE IF EXISTS mart.ETL_MaintainPermitDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainPermitDimension @permitToWorkTable mart.ETL_PermitToWorkTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    -- type 1 changes (do first, before inserting new)
    UPDATE mart.Permit
    SET
        PermitReference = a.PermitToWorkReference
        ,PermitCategory_key = pc.PermitCategory_key
        ,Location_key = l.Location_key
        ,PermitDescription = a.[Description]
        ,IssuedToCompanyId = a.IssuedToCompanyId
        ,IssuedToCompany = a.IssuedToCompany
        ,IssuedOn = a.IssuedOn
        ,IssuedForMinutes = a.IssuedForMinutes
        ,IssuedExpiry = a.IssuedExpiry
        ,ClosedOn = a.ClosedOn
        ,PermitStatus_key = ps.PermitStatus_key
        ,HasBeenExpired = a.HasBeenExpired
        ,HasBeenClosed = a.HasBeenClosed
        ,Wallet_key = w.Wallet_key
        ,_edited = SYSUTCDATETIME()
    FROM
        @permitToWorkTable AS a
        INNER JOIN mart.PermitCategory AS pc ON
            a.CategoryId = pc.CategoryId
            AND a.CategoryVersion = pc.CategoryVersion
        INNER JOIN mart.[Location] AS l ON a.SiteLocationId = l.LocationId
        INNER JOIN mart.PermitStatus AS ps ON a.StatusId = ps.PermitStatusCode
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        LEFT OUTER JOIN mart.Permit AS b ON a.PermitToWorkId = b.PermitId
    WHERE /* only where the data has changed */
        a.PermitToWorkReference <> b.PermitReference
        OR pc.PermitCategory_key <> b.PermitCategory_key
        OR l.Location_key <> b.Location_key
        OR a.[Description] <> b.PermitDescription
        OR a.IssuedToCompanyId <> b.IssuedToCompanyId
        OR a.IssuedToCompany <> b.IssuedToCompany
        OR a.IssuedOn <> b.IssuedOn
        OR a.IssuedForMinutes <> b.IssuedForMinutes
        OR a.IssuedExpiry <> b.IssuedExpiry
        OR a.ClosedOn <> b.ClosedOn
        OR ps.PermitStatus_key <> b.PermitStatus_key
        OR a.HasBeenExpired <> b.HasBeenExpired
        OR a.HasBeenClosed <> b.HasBeenClosed
        OR w.Wallet_key <> b.Wallet_key;

    PRINT 'UPDATE mart.Permit, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

    -- insert missing entries
    INSERT INTO mart.Permit
    (
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
    )
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
        INNER JOIN mart.PermitCategory AS pc ON
            a.CategoryId = pc.CategoryId
            AND a.CategoryVersion = pc.CategoryVersion
        INNER JOIN mart.[Location] AS l ON a.SiteLocationId = l.LocationId
        INNER JOIN mart.PermitStatus AS ps ON a.StatusId = ps.PermitStatusCode
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        LEFT OUTER JOIN mart.Permit AS b ON a.PermitToWorkId = b.PermitId
    WHERE
        b.PermitId IS NULL;

    PRINT 'INSERT mart.Permit, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
