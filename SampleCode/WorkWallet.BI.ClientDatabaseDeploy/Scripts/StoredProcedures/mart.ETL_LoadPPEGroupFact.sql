DROP PROCEDURE IF EXISTS mart.ETL_LoadPPEGroupFact;
GO

CREATE PROCEDURE mart.ETL_LoadPPEGroupFact
    @ppeTypeGroupTable mart.ETL_PPETypeGroupTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    -- Get the distinct PPETypeIds from the input to scope the MERGE
    DECLARE @ppeTypeIds TABLE (PPETypeId uniqueidentifier PRIMARY KEY);
    INSERT INTO @ppeTypeIds (PPETypeId)
    SELECT DISTINCT PPETypeId FROM @ppeTypeGroupTable;

    MERGE mart.PPEGroupFact AS target
    USING (
        SELECT DISTINCT
            ptg.PPETypeId
            ,pg.PPEGroup_key
            ,w.Wallet_key
        FROM
            @ppeTypeGroupTable AS ptg
            INNER JOIN mart.Wallet AS w ON ptg.WalletId = w.WalletId
            INNER JOIN mart.PPEGroup AS pg ON ptg.PPEGroupId = pg.PPEGroupId
    ) AS source
    ON target.PPETypeId = source.PPETypeId 
        AND target.PPEGroup_key = source.PPEGroup_key
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            PPETypeId
            ,PPEGroup_key
            ,Wallet_key
        ) VALUES (
            source.PPETypeId
            ,source.PPEGroup_key
            ,source.Wallet_key
        )
    WHEN NOT MATCHED BY SOURCE AND target.PPETypeId IN (SELECT PPETypeId FROM @ppeTypeIds)
    THEN
        DELETE;

    PRINT 'MERGE mart.PPEGroupFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
