DROP PROCEDURE IF EXISTS mart.ETL_MaintainAuditTypeDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainAuditTypeDimension @auditTypeTable mart.ETL_AuditTypeTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.AuditType AS target
    USING (
        SELECT
            a.AuditTypeId
            ,a.AuditTypeVersion
            ,a.AuditType
            ,a.[Description]
            ,a.ScoringEnabled
            ,a.DisplayPercentage
            ,a.DisplayTotalScore
            ,a.DisplayAverageScore
            ,a.GradingSetId
            ,a.GradingSetVersion
            ,a.GradingSet
            ,a.GradingSetIsPercentage
            ,a.GradingSetIsScore
            ,a.ReportingEnabled
            ,a.ReportingAbbreviation
            ,w.Wallet_key
        FROM
            @auditTypeTable AS a
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON target.AuditTypeId = source.AuditTypeId AND target.AuditTypeVersion = source.AuditTypeVersion
    WHEN MATCHED AND (
        target.AuditType <> source.AuditType
        OR target.[Description] <> source.[Description]
        OR target.ScoringEnabled <> source.ScoringEnabled
        OR target.DisplayPercentage <> source.DisplayPercentage
        OR target.DisplayTotalScore <> source.DisplayTotalScore
        OR target.DisplayAverageScore <> source.DisplayAverageScore
        OR target.GradingSetId <> source.GradingSetId
        OR target.GradingSetVersion <> source.GradingSetVersion
        OR target.GradingSet <> source.GradingSet
        OR target.GradingSetIsPercentage <> source.GradingSetIsPercentage
        OR target.GradingSetIsScore <> source.GradingSetIsScore
        OR target.ReportingEnabled <> source.ReportingEnabled
        OR target.ReportingAbbreviation <> source.ReportingAbbreviation
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            AuditType = source.AuditType
            ,[Description] = source.[Description]
            ,ScoringEnabled = source.ScoringEnabled
            ,DisplayPercentage = source.DisplayPercentage
            ,DisplayTotalScore = source.DisplayTotalScore
            ,DisplayAverageScore = source.DisplayAverageScore
            ,GradingSetId = source.GradingSetId
            ,GradingSetVersion = source.GradingSetVersion
            ,GradingSet = source.GradingSet
            ,GradingSetIsPercentage = source.GradingSetIsPercentage
            ,GradingSetIsScore = source.GradingSetIsScore
            ,ReportingEnabled = source.ReportingEnabled
            ,ReportingAbbreviation = source.ReportingAbbreviation
            ,Wallet_key = source.Wallet_key
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            AuditTypeId
            ,AuditTypeVersion
            ,AuditType
            ,[Description]
            ,ScoringEnabled
            ,DisplayPercentage
            ,DisplayTotalScore
            ,DisplayAverageScore
            ,GradingSetId
            ,GradingSetVersion
            ,GradingSet
            ,GradingSetIsPercentage
            ,GradingSetIsScore
            ,ReportingEnabled
            ,ReportingAbbreviation
            ,Wallet_key
        ) VALUES (
            source.AuditTypeId
            ,source.AuditTypeVersion
            ,source.AuditType
            ,source.[Description]
            ,source.ScoringEnabled
            ,source.DisplayPercentage
            ,source.DisplayTotalScore
            ,source.DisplayAverageScore
            ,source.GradingSetId
            ,source.GradingSetVersion
            ,source.GradingSet
            ,source.GradingSetIsPercentage
            ,source.GradingSetIsScore
            ,source.ReportingEnabled
            ,source.ReportingAbbreviation
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.AuditType, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
