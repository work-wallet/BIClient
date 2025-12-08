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
            ,o.Details
            ,o.ActionTaken
            ,aostat.AssetObservationStatus_key
            ,o.ObservedOn
            ,o.ObservedBy
            ,o.Deleted
            ,o.ClosedOn
            ,o.ClosedBy
            ,o.ClosureNotes
            ,w.Wallet_key
        FROM
            @observationTable AS o
            INNER JOIN mart.Asset AS a ON o.AssetId = a.AssetId
            INNER JOIN mart.AssetObservationStatus AS aostat ON o.ObservationStatusCode = aostat.AssetObservationStatusCode
            INNER JOIN mart.Wallet AS w ON o.WalletId = w.WalletId
    ) AS source
    ON target.ObservationId = source.ObservationId
    WHEN MATCHED AND (
        target.Asset_key <> source.Asset_key
        OR target.Details <> source.Details
        OR target.ActionTaken <> source.ActionTaken
        OR target.AssetObservationStatus_key <> source.AssetObservationStatus_key
        OR target.ObservedOn <> source.ObservedOn
        OR target.ObservedBy <> source.ObservedBy
        OR target.Deleted <> source.Deleted
        OR target.ClosedOn IS DISTINCT FROM source.ClosedOn
        OR target.ClosedBy <> source.ClosedBy
        OR target.ClosureNotes <> source.ClosureNotes
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            Asset_key = source.Asset_key
            ,Details = source.Details
            ,ActionTaken = source.ActionTaken
            ,AssetObservationStatus_key = source.AssetObservationStatus_key
            ,ObservedOn = source.ObservedOn
            ,ObservedBy = source.ObservedBy
            ,Deleted = source.Deleted
            ,ClosedOn = source.ClosedOn
            ,ClosedBy = source.ClosedBy
            ,ClosureNotes = source.ClosureNotes
            ,Wallet_key = source.Wallet_key
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            ObservationId
            ,Asset_key
            ,Details
            ,ActionTaken
            ,AssetObservationStatus_key
            ,ObservedOn
            ,ObservedBy
            ,Deleted
            ,ClosedOn
            ,ClosedBy
            ,ClosureNotes
            ,Wallet_key
        ) VALUES (
            source.ObservationId
            ,source.Asset_key
            ,source.Details
            ,source.ActionTaken
            ,source.AssetObservationStatus_key
            ,source.ObservedOn
            ,source.ObservedBy
            ,source.Deleted
            ,source.ClosedOn
            ,source.ClosedBy
            ,source.ClosureNotes
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.AssetObservation, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

END
GO
