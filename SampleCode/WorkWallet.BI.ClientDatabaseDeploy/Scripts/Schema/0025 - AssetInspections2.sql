-- add Deleted column to AssetObservation table
-- (has been back-fixed in the 0023 script)
-- (this patch was applied before the general release of the Asset Inspections / Observations datasets)
IF NOT EXISTS(select 1 from sys.columns where [Name] = N'Deleted' and Object_ID = Object_ID(N'mart.AssetObservation'))
BEGIN

    ALTER TABLE
        mart.AssetObservation
    ADD
        Deleted bit NOT NULL
        CONSTRAINT DF_AssetObservation_Deleted DEFAULT 0 WITH VALUES;

    ALTER TABLE mart.AssetObservation DROP CONSTRAINT DF_AssetObservation_Deleted;

END
GO