DROP PROCEDURE IF EXISTS mart.ETL_LoadPermitChecklistAnswerFact;
GO

CREATE PROCEDURE mart.ETL_LoadPermitChecklistAnswerFact
    @permitToWorkChecklistAnswerTable mart.ETL_PermitToWorkChecklistAnswerTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    -- insert missing entries
    INSERT INTO mart.PermitChecklistAnswerFact
    (
        -- keys
        Permit_key
        ,PermitChecklistAnswer_key
        ,Wallet_key
        -- facts
    )
    SELECT DISTINCT
        -- keys
        p.Permit_key
        ,pca.PermitChecklistAnswer_key
        ,w.Wallet_key
        -- facts
    FROM
        @permitToWorkChecklistAnswerTable AS a
        INNER JOIN mart.Permit AS p ON a.PermitToWorkId = p.PermitId
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        INNER JOIN mart.PermitChecklistAnswer AS pca ON
            w.Wallet_key = pca.Wallet_key
            AND a.CategorySectionType = pca.CategorySectionType
            AND a.Question = pca.Question
            AND a.[Option] = pca.[Option];

    PRINT 'INSERT mart.PermitChecklistAnswerFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
