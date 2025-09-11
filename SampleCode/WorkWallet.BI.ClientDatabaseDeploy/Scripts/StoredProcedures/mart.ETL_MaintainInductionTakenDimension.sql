DROP PROCEDURE IF EXISTS mart.ETL_MaintainInductionTakenDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainInductionTakenDimension @InductionTakenTable mart.ETL_InductionTakenTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.InductionTaken AS target
    USING (
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
            INNER JOIN mart.Induction AS i ON a.InductionId = i.InductionId AND a.InductionVersion = i.InductionVersion
            INNER JOIN mart.InductionTakenStatus AS its ON a.InductionTakenStatusId = its.InductionTakenStatusCode
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON target.InductionTakenId = source.InductionTakenId
    WHEN MATCHED AND (
        target.Induction_key <> source.Induction_key
        OR target.ContactId <> source.ContactId
        OR target.[Name] <> source.[Name]
        OR target.CompanyName <> source.CompanyName
        OR target.TakenOn <> source.TakenOn
        OR target.CorrectTestQuestionCount <> source.CorrectTestQuestionCount
        OR target.InductionTakenStatus_key <> source.InductionTakenStatus_key
        OR target.Wallet_key <> source.Wallet_key
    ) THEN
        UPDATE SET
            target.Induction_key = source.Induction_key
            ,target.ContactId = source.ContactId
            ,target.[Name] = source.[Name]
            ,target.CompanyName = source.CompanyName
            ,target.TakenOn = source.TakenOn
            ,target.CorrectTestQuestionCount = source.CorrectTestQuestionCount
            ,target.InductionTakenStatus_key = source.InductionTakenStatus_key
            ,target.Wallet_key = source.Wallet_key
            ,target._edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
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
        VALUES (
            source.InductionTakenId
            ,source.Induction_key
            ,source.ContactId
            ,source.[Name]
            ,source.CompanyName
            ,source.TakenOn
            ,source.CorrectTestQuestionCount
            ,source.InductionTakenStatus_key
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.InductionTaken, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
