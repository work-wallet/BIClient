DROP PROCEDURE IF EXISTS mart.ETL_LoadPermitDateTimeAnswerFact;
GO

CREATE PROCEDURE mart.ETL_LoadPermitDateTimeAnswerFact
    @permitToWorkDateTimeAnswerTable mart.ETL_PermitToWorkDateTimeAnswerTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO mart.PermitDateTimeAnswerFact
    (
        Permit_key
        ,PermitDateTimeQuestion_key
        ,AnswerDateTime
        ,AnswerDate
        ,AnswerTime
        ,Wallet_key
    )
    SELECT DISTINCT
        p.Permit_key
        ,q.PermitDateTimeQuestion_key
        ,CASE WHEN q.[Date] = 1 AND q.[Time] = 1 THEN x.Answer ELSE NULL END AS AnswerDateTime
        ,CASE WHEN q.[Date] = 1 THEN x.Answer ELSE NULL END AS AnswerDate
        ,CASE WHEN q.[Time] = 1 THEN x.Answer ELSE NULL END AS AnswerTime
        ,w.Wallet_key
    FROM
        @permitToWorkDateTimeAnswerTable AS x
        INNER JOIN mart.Permit AS p ON x.PermitToWorkId = p.PermitId
        INNER JOIN mart.PermitDateTimeQuestion AS q ON x.QuestionId = q.QuestionId
        INNER JOIN mart.Wallet AS w ON x.WalletId = w.WalletId;

    PRINT 'INSERT mart.PermitDateTimeAnswerFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
