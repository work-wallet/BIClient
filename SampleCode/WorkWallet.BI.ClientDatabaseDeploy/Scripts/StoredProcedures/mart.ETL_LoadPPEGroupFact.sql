DROP PROCEDURE IF EXISTS mart.ETL_LoadPPEGroupFact;
GO

CREATE PROCEDURE mart.ETL_LoadPPEGroupFact
    @ppeTypeGroupTable mart.ETL_PPETypeGroupTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    -- Get the distinct PPEType_keys from the input to scope the MERGE
    DECLARE @ppeTypeKeys TABLE (PPEType_key int PRIMARY KEY);
    INSERT INTO @ppeTypeKeys (PPEType_key)
    SELECT DISTINCT pt.PPEType_key
    FROM @ppeTypeGroupTable AS ptg
    INNER JOIN mart.PPEType AS pt ON ptg.PPETypeId = pt.PPETypeId;

    MERGE mart.PPEGroupFact AS target
    USING (
        SELECT DISTINCT
            pt.PPEType_key
            ,pg.PPEGroup_key
            ,w.Wallet_key
        FROM
            @ppeTypeGroupTable AS ptg
            INNER JOIN mart.Wallet AS w ON ptg.WalletId = w.WalletId
            INNER JOIN mart.PPEType AS pt ON ptg.PPETypeId = pt.PPETypeId
            INNER JOIN mart.PPEGroup AS pg ON ptg.PPEGroupId = pg.PPEGroupId
    ) AS source
    ON target.PPEType_key = source.PPEType_key 
        AND target.PPEGroup_key = source.PPEGroup_key
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            PPEType_key
            ,PPEGroup_key
            ,Wallet_key
        ) VALUES (
            source.PPEType_key
            ,source.PPEGroup_key
            ,source.Wallet_key
        )
    WHEN NOT MATCHED BY SOURCE AND target.PPEType_key IN (SELECT PPEType_key FROM @ppeTypeKeys)
    THEN
        DELETE;

    PRINT 'MERGE mart.PPEGroupFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
