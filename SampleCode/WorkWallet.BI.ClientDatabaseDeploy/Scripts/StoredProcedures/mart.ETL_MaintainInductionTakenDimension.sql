DROP PROCEDURE IF EXISTS mart.ETL_MaintainInductionTakenDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainInductionTakenDimension @InductionTakenTable mart.ETL_InductionTakenTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    -- type 1 changes (do first, before inserting new)
    UPDATE mart.InductionTaken
    SET
        Induction_key = i.Induction_key
        ,ContactId = a.ContactId
        ,[Name] = a.[Name]
        ,CompanyName = a.CompanyName
        ,TakenOn = a.TakenOn
        ,CorrectTestQuestionCount = a.CorrectTestQuestionCount
        ,InductionTakenStatus_key = its.InductionTakenStatus_key
        ,Wallet_key = w.Wallet_key
        ,_edited = SYSUTCDATETIME()
    FROM
        @InductionTakenTable AS a
        INNER JOIN mart.Induction AS i ON
            a.InductionId = i.InductionId
            AND a.InductionVersion = i.InductionVersion
        INNER JOIN mart.InductionTakenStatus AS its ON a.InductionTakenStatusId = its.InductionTakenStatusCode
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        LEFT OUTER JOIN mart.InductionTaken AS b ON a.InductionTakenId = b.InductionTakenId
    WHERE /* only where the data has changed */
        i.Induction_key <> b.Induction_key
        OR a.ContactId <> b.ContactId
        OR a.[Name] <> b.[Name]
        OR a.CompanyName <> b.CompanyName
        OR a.TakenOn <> b.TakenOn
        OR a.CorrectTestQuestionCount <> b.CorrectTestQuestionCount
        OR its.InductionTakenStatus_key <> b.InductionTakenStatus_key
        OR w.Wallet_key <> b.Wallet_key;

    PRINT 'UPDATE mart.InductionTaken, number of rows = ' + CAST(@@ROWCOUNT AS varchar);

    -- insert missing entries
    INSERT INTO mart.InductionTaken
    (
        InductionTakenId
        ,Induction_key
        ,ContactId
        ,[Name]
        ,CompanyName
        ,TakenOn
        ,CorrectTestQuestionCount
        ,InductionTakenStatus_key
        ,Wallet_key
    )
    SELECT
        a.InductionTakenId
        ,i.Induction_key
        ,a.ContactId
        ,a.[Name]
        ,a.CompanyName
        ,a.TakenOn
        ,a.CorrectTestQuestionCount
        ,its.InductionTakenStatus_key
        ,w.Wallet_key
    FROM
        @InductionTakenTable AS a
        INNER JOIN mart.Induction AS i ON
            a.InductionId = i.InductionId
            AND a.InductionVersion = i.InductionVersion
        INNER JOIN mart.InductionTakenStatus AS its ON a.InductionTakenStatusId = its.InductionTakenStatusCode
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        LEFT OUTER JOIN mart.InductionTaken AS b ON a.InductionTakenId = b.InductionTakenId
    WHERE
        b.InductionTakenId IS NULL;

    PRINT 'INSERT mart.InductionTaken, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
