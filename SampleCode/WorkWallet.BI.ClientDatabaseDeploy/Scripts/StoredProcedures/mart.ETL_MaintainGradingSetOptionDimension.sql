DROP PROCEDURE IF EXISTS mart.ETL_MaintainGradingSetOptionDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainGradingSetOptionDimension @gradingSetOptionTable mart.ETL_GradingSetOptionTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.GradingSetOption AS target
    USING (
        SELECT DISTINCT
            o.GradingSetId
            ,o.GradingSetVersion
            ,o.GradingSetOptionId
            ,o.GradingSet
            ,o.GradingSetOption
            ,o.[Value]
            ,o.ColourHex
            ,o.GradingSetIsPercentage
            ,o.GradingSetIsScore
            ,w.Wallet_key
        FROM
            @gradingSetOptionTable AS o
            INNER JOIN mart.Wallet AS w ON o.WalletId = w.WalletId
    ) AS source
    ON target.GradingSetId = source.GradingSetId AND target.GradingSetVersion = source.GradingSetVersion AND target.GradingSetOptionId = source.GradingSetOptionId
    WHEN MATCHED AND (
        target.GradingSet <> source.GradingSet
        OR target.GradingSetOption <> source.GradingSetOption
        OR target.[Value] <> source.[Value]
        OR target.ColourHex <> source.ColourHex
        OR target.GradingSetIsPercentage <> source.GradingSetIsPercentage
        OR target.GradingSetIsScore <> source.GradingSetIsScore
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            GradingSet = source.GradingSet
            ,GradingSetOption = source.GradingSetOption
            ,[Value] = source.[Value]
            ,ColourHex = source.ColourHex
            ,GradingSetIsPercentage = source.GradingSetIsPercentage
            ,GradingSetIsScore = source.GradingSetIsScore
            ,Wallet_key = source.Wallet_key
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            GradingSetId
            ,GradingSetVersion
            ,GradingSetOptionId
            ,GradingSet
            ,GradingSetOption
            ,[Value]
            ,ColourHex
            ,GradingSetIsPercentage
            ,GradingSetIsScore
            ,Wallet_key
        ) VALUES (
            source.GradingSetId
            ,source.GradingSetVersion
            ,source.GradingSetOptionId
            ,source.GradingSet
            ,source.GradingSetOption
            ,source.[Value]
            ,source.ColourHex
            ,source.GradingSetIsPercentage
            ,source.GradingSetIsScore
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.GradingSetOption, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
