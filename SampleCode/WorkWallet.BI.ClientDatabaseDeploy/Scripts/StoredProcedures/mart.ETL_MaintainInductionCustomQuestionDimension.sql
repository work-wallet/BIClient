DROP PROCEDURE IF EXISTS mart.ETL_MaintainInductionCustomQuestionDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainInductionCustomQuestionDimension @inductionCustomQuestionTable mart.ETL_InductionCustomQuestionTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.InductionCustomQuestion AS target
    USING (
        SELECT DISTINCT
            a.Title
            ,a.[Value]
            ,w.Wallet_key
        FROM
            @inductionCustomQuestionTable AS a
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON
        target.Wallet_key = source.Wallet_key
        AND target.Title = source.Title
        AND target.[Value] = source.[Value]
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            Title
            ,[Value]
            ,Wallet_key
        )
        VALUES (
            source.Title
            ,source.[Value]
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.InductionCustomQuestion, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
