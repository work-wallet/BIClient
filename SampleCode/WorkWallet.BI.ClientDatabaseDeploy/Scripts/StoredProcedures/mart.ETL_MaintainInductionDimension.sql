DROP PROCEDURE IF EXISTS mart.ETL_MaintainInductionDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainInductionDimension @InductionTable mart.ETL_InductionTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    -- type 1 changes (do first, before inserting new)
    UPDATE mart.Induction
    SET
        InductionName = a.InductionName
        ,ValidForDays = a.ValidForDays
        ,CreatedOn = a.CreatedOn
        ,Active = a.Active
        ,InductionStatus_key = istat.InductionStatus_key
        ,TestPassMark = a.TestPassMark
        ,TestQuestionCount = a.TestQuestionCount
        ,Wallet_key = w.Wallet_key
        ,_edited = SYSUTCDATETIME()
    FROM
        @InductionTable AS a
        INNER JOIN mart.InductionStatus AS istat ON a.InductionStatusCode = istat.InductionStatusCode
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        LEFT OUTER JOIN mart.Induction AS b ON a.InductionId = b.InductionId
    WHERE /* only where the data has changed */
        a.InductionName <> b.InductionName
        OR a.ValidForDays <> b.ValidForDays
        OR a.CreatedOn <> b.CreatedOn
        OR a.Active <> b.Active
        OR istat.InductionStatus_key <> b.InductionStatus_key
        OR a.TestPassMark <> b.TestPassMark
        OR a.TestQuestionCount <> b.TestQuestionCount
        OR w.Wallet_key <> b.Wallet_key;

    PRINT 'UPDATE mart.Induction, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

    -- insert missing entries
    INSERT INTO mart.Induction
    (
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
        LEFT OUTER JOIN mart.Induction AS b ON
            a.InductionId = b.InductionId
            AND a.InductionVersion = b.InductionVersion
    WHERE
        b.InductionId IS NULL;

    PRINT 'INSERT mart.Induction, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
