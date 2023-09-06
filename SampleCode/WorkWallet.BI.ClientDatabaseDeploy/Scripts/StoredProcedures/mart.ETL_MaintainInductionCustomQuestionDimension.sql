DROP PROCEDURE IF EXISTS mart.ETL_MaintainInductionCustomQuestionDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainInductionCustomQuestionDimension @inductionCustomQuestionTable mart.ETL_InductionCustomQuestionTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    -- insert missing entries
    INSERT INTO mart.InductionCustomQuestion
    (
        Title
        ,[Value]
        ,Wallet_key
    )
    SELECT DISTINCT
        a.Title
        ,a.[Value]
        ,w.Wallet_key
    FROM
        @inductionCustomQuestionTable AS a
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        LEFT OUTER JOIN mart.InductionCustomQuestion AS b ON
            w.Wallet_key = b.Wallet_key
            AND a.Title = b.Title
            AND a.[Value] = b.[Value]
    WHERE
        b.Title IS NULL;

    PRINT 'INSERT mart.InductionCustomQuestion, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
