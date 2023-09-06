DROP PROCEDURE IF EXISTS mart.ETL_MaintainPermitChecklistAnswerDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainPermitChecklistAnswerDimension @permitToWorkChecklistAnswerTable mart.ETL_PermitToWorkChecklistAnswerTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    -- insert missing entries
    INSERT INTO mart.PermitChecklistAnswer
    (
        CategorySectionType
        ,Question
        ,[Option]
        ,Wallet_key
    )
    SELECT DISTINCT
        a.CategorySectionType
        ,a.Question
        ,a.[Option]
        ,w.Wallet_key
    FROM
        @permitToWorkChecklistAnswerTable AS a
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        LEFT OUTER JOIN mart.PermitChecklistAnswer AS b ON
            w.Wallet_key = b.Wallet_key
            AND a.Question = b.Question
            AND a.[Option] = b.[Option]
    WHERE
        b.Question IS NULL;

    PRINT 'INSERT mart.PermitChecklistAnswer, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
