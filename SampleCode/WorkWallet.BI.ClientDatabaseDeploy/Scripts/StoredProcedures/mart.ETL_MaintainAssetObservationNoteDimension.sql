DROP PROCEDURE IF EXISTS mart.ETL_MaintainAssetObservationNoteDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainAssetObservationNoteDimension @observationNoteTable mart.ETL_AssetObservationNoteTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.AssetObservationNote AS target
    USING (
        SELECT
            n.NoteId
            ,o.AssetObservation_key
            ,n.Notes
            ,n.CreatedOn
            ,author.Contact_key AS CreatedByContact_key
            ,n.EditedOn
            ,n.Deleted
            ,w.Wallet_key
        FROM
            @observationNoteTable AS n
            INNER JOIN mart.AssetObservation AS o ON n.ObservationId = o.ObservationId
            LEFT JOIN mart.Contact AS author ON n.CreatedByContactId = author.ContactId
            INNER JOIN mart.Wallet AS w ON n.WalletId = w.WalletId
    ) AS source
    ON target.NoteId = source.NoteId
    WHEN MATCHED AND (
        target.AssetObservation_key <> source.AssetObservation_key
        OR target.Notes <> source.Notes
        OR target.CreatedOn <> source.CreatedOn
        OR target.CreatedByContact_key IS DISTINCT FROM source.CreatedByContact_key
        OR target.EditedOn IS DISTINCT FROM source.EditedOn
        OR target.Deleted <> source.Deleted
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            AssetObservation_key = source.AssetObservation_key
            ,Notes = source.Notes
            ,CreatedOn = source.CreatedOn
            ,CreatedByContact_key = source.CreatedByContact_key
            ,EditedOn = source.EditedOn
            ,Deleted = source.Deleted
            ,Wallet_key = source.Wallet_key
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            NoteId
            ,AssetObservation_key
            ,Notes
            ,CreatedOn
            ,CreatedByContact_key
            ,EditedOn
            ,Deleted
            ,Wallet_key
        ) VALUES (
            source.NoteId
            ,source.AssetObservation_key
            ,source.Notes
            ,source.CreatedOn
            ,source.CreatedByContact_key
            ,source.EditedOn
            ,source.Deleted
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.AssetObservationNote, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
