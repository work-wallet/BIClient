DROP PROCEDURE IF EXISTS mart.ETL_LoadInductionCustomQuestionFact;
GO

CREATE PROCEDURE mart.ETL_LoadInductionCustomQuestionFact
    @inductionCustomQuestionTable mart.ETL_InductionCustomQuestionTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    -- insert missing entries
    INSERT INTO mart.InductionCustomQuestionFact
    (
        -- keys
        InductionTaken_key
        ,InductionCustomQuestion_key
        ,Wallet_key
        -- facts
    )
    SELECT DISTINCT
        -- keys
        it.InductionTaken_key
        ,icq.InductionCustomQuestion_key
        ,w.Wallet_key
        -- facts
    FROM
        @inductionCustomQuestionTable AS a
        INNER JOIN mart.InductionTaken AS it ON a.InductionTakenId = it.InductionTakenId
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        INNER JOIN mart.InductionCustomQuestion AS icq ON
            w.Wallet_key = icq.Wallet_key
            AND a.Title = icq.Title
            AND a.[Value] = icq.[Value];

    PRINT 'INSERT mart.InductionCustomQuestionFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
