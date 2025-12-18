DROP PROCEDURE IF EXISTS mart.ETL_LoadPermitNumericAnswerFact;
GO

CREATE PROCEDURE mart.ETL_LoadPermitNumericAnswerFact
    @permitToWorkNumericAnswerTable mart.ETL_PermitToWorkNumericAnswerTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO mart.PermitNumericAnswerFact
    (
        Permit_key
        ,PermitNumericQuestion_key
        ,Answer
        ,Wallet_key
    )
    SELECT DISTINCT
        p.Permit_key
        ,q.PermitNumericQuestion_key
        ,x.Answer
        ,w.Wallet_key
    FROM
        @permitToWorkNumericAnswerTable AS x
        INNER JOIN mart.Permit AS p ON x.PermitToWorkId = p.PermitId
        INNER JOIN mart.PermitNumericQuestion AS q ON x.QuestionId = q.QuestionId
        INNER JOIN mart.Wallet AS w ON x.WalletId = w.WalletId;

    PRINT 'INSERT mart.PermitNumericAnswerFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
