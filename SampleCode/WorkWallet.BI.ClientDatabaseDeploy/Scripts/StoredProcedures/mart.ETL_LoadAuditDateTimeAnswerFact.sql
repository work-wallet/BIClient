DROP PROCEDURE IF EXISTS mart.ETL_LoadAuditDateTimeAnswerFact;
GO

CREATE PROCEDURE mart.ETL_LoadAuditDateTimeAnswerFact
    @auditDateTimeAnswerTable mart.ETL_AuditDateTimeAnswerTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO mart.AuditDateTimeAnswerFact
    (
        Audit_key
        ,AuditDateTimeQuestion_key
        ,AnswerDateTime
        ,AnswerDate
        ,AnswerTime
        ,Wallet_key
    )
    SELECT DISTINCT
        a.Audit_key
        ,q.AuditDateTimeQuestion_key
        ,CASE WHEN q.[Date] = 1 AND q.[Time] = 1 THEN x.Answer ELSE NULL END AS AnswerDateTime
        ,CASE WHEN q.[Date] = 1 THEN x.Answer ELSE NULL END AS AnswerDate
        ,CASE WHEN q.[Time] = 1 THEN x.Answer ELSE NULL END AS AnswerTime
        ,w.Wallet_key
    FROM
        @auditDateTimeAnswerTable AS x
        INNER JOIN mart.[Audit] AS a ON x.AuditId = a.AuditId
        INNER JOIN mart.AuditDateTimeQuestion AS q ON x.QuestionId = q.QuestionId
        INNER JOIN mart.Wallet AS w ON x.WalletId = w.WalletId;

    PRINT 'INSERT mart.AuditDateTimeAnswerFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
