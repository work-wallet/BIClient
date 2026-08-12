DROP TYPE IF EXISTS mart.ETL_AssetObservationNoteTable;
GO

CREATE TYPE mart.ETL_AssetObservationNoteTable AS TABLE
(
    ObservationId uniqueidentifier NOT NULL
    ,NoteId uniqueidentifier NOT NULL
    ,Notes nvarchar(max) NOT NULL
    ,CreatedOn datetimeoffset(7) NOT NULL
    ,CreatedByContactId uniqueidentifier NULL -- allow NULLs
    ,EditedOn datetimeoffset(7) NULL -- allow NULLs
    ,Deleted bit NOT NULL
    ,WalletId uniqueidentifier NOT NULL
    ,PRIMARY KEY (ObservationId, NoteId)
);
GO
