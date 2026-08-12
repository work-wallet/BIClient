DROP PROCEDURE IF EXISTS mart.ETL_MaintainAssetObservationDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainAssetObservationDimension @observationTable mart.ETL_AssetObservationTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.AssetObservation AS target
    USING (
        SELECT
            o.ObservationId
            ,a.Asset_key
            ,s.AssetObservationStatus_key
            ,o.ObservedOn
            ,observer.Contact_key AS ObservedByContact_key
            ,o.Deleted
            ,o.ClosedOn
            ,closer.Contact_key AS ClosedByContact_key
            ,o.ClosureNotes
            ,o.IsFinalised
            ,w.Wallet_key
        FROM
            @observationTable AS o
            INNER JOIN mart.Asset AS a ON o.AssetId = a.AssetId
            INNER JOIN mart.AssetObservationStatus AS s ON o.ObservationStatusCode = s.AssetObservationStatusCode
            LEFT JOIN mart.Contact AS observer ON o.ObservedByContactId = observer.ContactId
            LEFT JOIN mart.Contact AS closer ON o.ClosedByContactId = closer.ContactId
            INNER JOIN mart.Wallet AS w ON o.WalletId = w.WalletId
    ) AS source
    ON target.ObservationId = source.ObservationId
    WHEN MATCHED AND (
        target.Asset_key <> source.Asset_key
        OR target.AssetObservationStatus_key <> source.AssetObservationStatus_key
        OR target.ObservedOn <> source.ObservedOn
        OR target.ObservedByContact_key IS DISTINCT FROM source.ObservedByContact_key
        OR target.Deleted <> source.Deleted
        OR target.ClosedOn IS DISTINCT FROM source.ClosedOn
        OR target.ClosedByContact_key IS DISTINCT FROM source.ClosedByContact_key
        OR target.ClosureNotes <> source.ClosureNotes
        OR target.IsFinalised <> source.IsFinalised
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            Asset_key = source.Asset_key
            ,AssetObservationStatus_key = source.AssetObservationStatus_key
            ,ObservedOn = source.ObservedOn
            ,ObservedByContact_key = source.ObservedByContact_key
            ,Deleted = source.Deleted
            ,ClosedOn = source.ClosedOn
            ,ClosedByContact_key = source.ClosedByContact_key
            ,ClosureNotes = source.ClosureNotes
            ,IsFinalised = source.IsFinalised
            ,Wallet_key = source.Wallet_key
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            ObservationId
            ,Asset_key
            ,AssetObservationStatus_key
            ,ObservedOn
            ,ObservedByContact_key
            ,Deleted
            ,ClosedOn
            ,ClosedByContact_key
            ,ClosureNotes
            ,IsFinalised
            ,Wallet_key
        ) VALUES (
            source.ObservationId
            ,source.Asset_key
            ,source.AssetObservationStatus_key
            ,source.ObservedOn
            ,source.ObservedByContact_key
            ,source.Deleted
            ,source.ClosedOn
            ,source.ClosedByContact_key
            ,source.ClosureNotes
            ,source.IsFinalised
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.AssetObservation, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
