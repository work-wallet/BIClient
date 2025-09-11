DROP PROCEDURE IF EXISTS mart.ETL_MaintainReportedIssueBodyPartDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainReportedIssueBodyPartDimension @reportedIssueBodyPartTable mart.ETL_ReportedIssueBodyPartTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.ReportedIssueBodyPart AS target
    USING (
        SELECT DISTINCT
            e.ReportedIssueBodyPartEnum_key
            ,a.Question
            ,w.Wallet_key
        FROM
            @reportedIssueBodyPartTable AS a
            INNER JOIN mart.ReportedIssueBodyPartEnum AS e ON
                -- bitwise AND to expand the bit-masked enum
                (a.BodyParts & POWER(CAST(2 AS bigint), e.MaskIndex)) <> 0
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON
        target.ReportedIssueBodyPartEnum_key = source.ReportedIssueBodyPartEnum_key
        AND target.Question = source.Question
        AND target.Wallet_key = source.Wallet_key
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            ReportedIssueBodyPartEnum_key
            ,Question
            ,Wallet_key
        )
        VALUES (
            source.ReportedIssueBodyPartEnum_key
            ,source.Question
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.ReportedIssueBodyPart, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
