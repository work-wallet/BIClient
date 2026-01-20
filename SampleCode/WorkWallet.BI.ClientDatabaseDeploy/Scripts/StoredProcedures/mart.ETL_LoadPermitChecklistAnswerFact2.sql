DROP PROCEDURE IF EXISTS mart.ETL_LoadPermitChecklistAnswerFact2;
GO

CREATE PROCEDURE mart.ETL_LoadPermitChecklistAnswerFact2
    @permitToWorkChecklistAnswerTable mart.ETL_PermitToWorkChecklistAnswerTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO mart.PermitChecklistAnswerFact2
    (
        Permit_key
        ,PermitChecklistOption_key
        ,Wallet_key
    )
    SELECT DISTINCT
        p.Permit_key
        ,o.PermitChecklistOption_key
        ,w.Wallet_key
    FROM
        @permitToWorkChecklistAnswerTable AS x
        INNER JOIN mart.Permit AS p ON x.PermitToWorkId = p.PermitId
        INNER JOIN mart.PermitChecklistOption AS o ON x.ChecklistId = o.ChecklistId AND x.OptionId = o.OptionId
        INNER JOIN mart.Wallet AS w ON x.WalletId = w.WalletId;

    PRINT 'INSERT mart.PermitChecklistAnswerFact2, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
