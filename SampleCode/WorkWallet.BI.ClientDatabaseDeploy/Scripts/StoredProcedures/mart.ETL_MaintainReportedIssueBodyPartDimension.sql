DROP PROCEDURE IF EXISTS mart.ETL_MaintainReportedIssueBodyPartDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainReportedIssueBodyPartDimension @reportedIssueBodyPartTable mart.ETL_ReportedIssueBodyPartTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    -- insert missing entries
    INSERT INTO mart.ReportedIssueBodyPart
    (
        ReportedIssueBodyPartEnum_key
        ,Question
        ,Wallet_key
    )
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
        LEFT OUTER JOIN mart.ReportedIssueBodyPart AS b ON
            w.Wallet_key = b.Wallet_key
            AND e.ReportedIssueBodyPartEnum_key = b.ReportedIssueBodyPartEnum_key
            AND a.Question = b.Question
    WHERE
        b.ReportedIssueBodyPartEnum_key IS NULL;

    PRINT 'INSERT mart.ReportedIssueBodyPart, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
