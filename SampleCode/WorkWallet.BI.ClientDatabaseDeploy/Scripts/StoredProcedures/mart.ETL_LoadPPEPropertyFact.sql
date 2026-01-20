DROP PROCEDURE IF EXISTS mart.ETL_LoadPPEPropertyFact;
GO

CREATE PROCEDURE mart.ETL_LoadPPEPropertyFact
    @ppePropertyTable mart.ETL_PPETypePropertyTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    -- Get the distinct PPETypeIds from the input to scope the MERGE
    DECLARE @ppeTypeIds TABLE (PPETypeId uniqueidentifier PRIMARY KEY);
    INSERT INTO @ppeTypeIds (PPETypeId)
    SELECT DISTINCT PPETypeId FROM @ppePropertyTable;

    MERGE mart.PPEPropertyFact AS target
    USING (
        SELECT DISTINCT
            p.PPETypeId
            ,pp.PPEProperty_key
            ,p.[Value]
            ,w.Wallet_key
        FROM
            @ppePropertyTable AS p
            INNER JOIN mart.Wallet AS w ON p.WalletId = w.WalletId
            INNER JOIN mart.PPEPropertyType AS ppt ON p.PropertyType = ppt.PPEPropertyType
            INNER JOIN mart.PPEProperty AS pp ON ppt.PPEPropertyType_key = pp.PPEPropertyType_key AND p.Property = pp.Property AND w.Wallet_key = pp.Wallet_key
    ) AS source
    ON target.PPETypeId = source.PPETypeId 
        AND target.PPEProperty_key = source.PPEProperty_key
    WHEN MATCHED AND target.[Value] <> source.[Value]
    THEN
        UPDATE SET
            [Value] = source.[Value]
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            PPETypeId
            ,PPEProperty_key
            ,[Value]
            ,Wallet_key
        ) VALUES (
            source.PPETypeId
            ,source.PPEProperty_key
            ,source.[Value]
            ,source.Wallet_key
        )
    WHEN NOT MATCHED BY SOURCE AND target.PPETypeId IN (SELECT PPETypeId FROM @ppeTypeIds)
    THEN
        DELETE;

    PRINT 'MERGE mart.PPEPropertyFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
