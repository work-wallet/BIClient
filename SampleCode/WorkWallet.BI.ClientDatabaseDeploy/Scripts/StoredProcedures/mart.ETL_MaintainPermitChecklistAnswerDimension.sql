DROP PROCEDURE IF EXISTS mart.ETL_MaintainPermitChecklistAnswerDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainPermitChecklistAnswerDimension @permitToWorkChecklistAnswerTable mart.ETL_PermitToWorkChecklistAnswerTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.PermitChecklistAnswer AS target
    USING (
        SELECT DISTINCT
            a.CategorySectionType
            ,a.Question
            ,a.[Option]
            ,w.Wallet_key
        FROM
            @permitToWorkChecklistAnswerTable AS a
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON
        target.Wallet_key = source.Wallet_key
        AND target.Question = source.Question
        AND target.[Option] = source.[Option]
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            CategorySectionType
            ,Question
            ,[Option]
            ,Wallet_key
        ) VALUES (
            source.CategorySectionType
            ,source.Question
            ,source.[Option]
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.PermitChecklistAnswer, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
