DROP PROCEDURE IF EXISTS mart.ETL_LoadReportedIssueBodyPartFact;
GO

CREATE PROCEDURE mart.ETL_LoadReportedIssueBodyPartFact
    @reportedIssueBodyPartTable mart.ETL_ReportedIssueBodyPartTable READONLY
    ,@investigation bit
AS
BEGIN
    SET NOCOUNT ON;

    -- insert missing entries
    INSERT INTO mart.ReportedIssueBodyPartFact
    (
        -- keys
        ReportedIssue_key
        ,ReportedIssueBodyPart_key
        ,Investigation
        ,Wallet_key
        -- facts
    )
    SELECT DISTINCT
        -- keys
        ri.ReportedIssue_key
        ,ribp.ReportedIssueBodyPart_key
        ,@investigation
        ,w.Wallet_key
        -- facts
    FROM
        @reportedIssueBodyPartTable AS a
        INNER JOIN mart.ReportedIssueBodyPartEnum AS e ON
            -- bitwise AND to expand the bit-masked enum
            (a.BodyParts & POWER(CAST(2 AS bigint), e.MaskIndex)) <> 0
        INNER JOIN mart.ReportedIssue AS ri ON a.ReportedIssueId = ri.ReportedIssueId
        INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
        INNER JOIN mart.ReportedIssueBodyPart AS ribp ON
            w.Wallet_key = ribp.Wallet_key
            AND e.ReportedIssueBodyPartEnum_key = ribp.ReportedIssueBodyPartEnum_key
            AND a.Question = ribp.Question;

    PRINT 'INSERT mart.ReportedIssueBodyPartFact, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
