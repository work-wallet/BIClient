DROP PROCEDURE IF EXISTS mart.ETL_MaintainAssetInspectionScoreSectionDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainAssetInspectionScoreSectionDimension @assetInspectionScoreSectionTable mart.ETL_AssetInspectionScoreSectionTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.AssetInspectionScoreSection AS target
    USING (
        SELECT DISTINCT
            t.AssetInspectionType_key
            ,x.SectionId
            ,x.Section
            ,x.DisplayScore
            ,x.[Order]
            ,w.Wallet_key
        FROM
            @assetInspectionScoreSectionTable AS x
            INNER JOIN mart.AssetInspection AS i ON x.InspectionId = i.InspectionId
            INNER JOIN mart.AssetInspectionType AS t ON i.AssetInspectionType_key = t.AssetInspectionType_key
            INNER JOIN mart.Wallet AS w ON x.WalletId = w.WalletId
    ) AS source
    ON target.AssetInspectionType_key = source.AssetInspectionType_key AND target.SectionId = source.SectionId
    WHEN MATCHED AND (
        target.Section <> source.Section
        OR target.DisplayScore <> source.DisplayScore
        OR target.[Order] <> source.[Order]
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            Section = source.Section
            ,DisplayScore = source.DisplayScore
            ,[Order] = source.[Order]
            ,Wallet_key = source.Wallet_key
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            AssetInspectionType_key
            ,SectionId
            ,Section
            ,DisplayScore
            ,[Order]
            ,Wallet_key
        ) VALUES (
            source.AssetInspectionType_key
            ,source.SectionId
            ,source.Section
            ,source.DisplayScore
            ,source.[Order]
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.AssetInspectionScoreSection, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
