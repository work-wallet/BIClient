DROP PROCEDURE IF EXISTS mart.ETL_MaintainInductionDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainInductionDimension @InductionTable mart.ETL_InductionTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.Induction AS target
    USING (
        SELECT
            a.InductionId
            ,a.InductionVersion
            ,a.InductionName
            ,a.ValidForDays
            ,a.CreatedOn
            ,a.Active
            ,istat.InductionStatus_key
            ,a.TestPassMark
            ,a.TestQuestionCount
            ,w.Wallet_key
        FROM
            @InductionTable AS a
            INNER JOIN mart.InductionStatus AS istat ON a.InductionStatusCode = istat.InductionStatusCode
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON
        target.InductionId = source.InductionId
        AND target.InductionVersion = source.InductionVersion
    WHEN MATCHED AND (
        target.InductionName <> source.InductionName
        OR target.ValidForDays <> source.ValidForDays
        OR target.CreatedOn <> source.CreatedOn
        OR target.Active <> source.Active
        OR target.InductionStatus_key <> source.InductionStatus_key
        OR target.TestPassMark <> source.TestPassMark
        OR target.TestQuestionCount <> source.TestQuestionCount
        OR target.Wallet_key <> source.Wallet_key
    ) THEN
        UPDATE SET
            InductionName = source.InductionName
            ,ValidForDays = source.ValidForDays
            ,CreatedOn = source.CreatedOn
            ,Active = source.Active
            ,InductionStatus_key = source.InductionStatus_key
            ,TestPassMark = source.TestPassMark
            ,TestQuestionCount = source.TestQuestionCount
            ,Wallet_key = source.Wallet_key
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            InductionId
            ,InductionVersion
            ,InductionName
            ,ValidForDays
            ,CreatedOn
            ,Active
            ,InductionStatus_key
            ,TestPassMark
            ,TestQuestionCount
            ,Wallet_key
        )
        VALUES (
            source.InductionId
            ,source.InductionVersion
            ,source.InductionName
            ,source.ValidForDays
            ,source.CreatedOn
            ,source.Active
            ,source.InductionStatus_key
            ,source.TestPassMark
            ,source.TestQuestionCount
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.Induction, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
