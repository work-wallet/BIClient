DROP PROCEDURE IF EXISTS mart.ETL_MaintainPPEAssignmentHistoryDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainPPEAssignmentHistoryDimension @ppeAssignmentHistoryTable mart.ETL_PPEAssignmentHistoryTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.PPEAssignmentHistory AS target
    USING (
        SELECT
            h.PPEAssignmentHistoryId
            ,a.PPEAssignment_key
            ,pa.PPEAction_key
            ,c.Contact_key AS ActionedByContact_key
            ,h.ActionedOn
            ,w.Wallet_key
        FROM
            @ppeAssignmentHistoryTable AS h
            INNER JOIN mart.PPEAssignment AS a ON h.PPEAssignmentId = a.PPEAssignmentId
            INNER JOIN mart.PPEAction AS pa ON h.PPEActionCode = pa.PPEActionCode
            LEFT JOIN mart.Contact AS c ON h.ActionedByContactId = c.ContactId
            INNER JOIN mart.Wallet AS w ON h.WalletId = w.WalletId
    ) AS source
    ON target.PPEAssignmentHistoryId = source.PPEAssignmentHistoryId
    WHEN MATCHED AND (
        target.PPEAssignment_key <> source.PPEAssignment_key
        OR target.PPEAction_key <> source.PPEAction_key
        OR target.ActionedByContact_key IS DISTINCT FROM source.ActionedByContact_key
        OR target.ActionedOn <> source.ActionedOn
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            PPEAssignment_key = source.PPEAssignment_key
            ,PPEAction_key = source.PPEAction_key
            ,ActionedByContact_key = source.ActionedByContact_key
            ,ActionedOn = source.ActionedOn
            ,Wallet_key = source.Wallet_key
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            PPEAssignmentHistoryId
            ,PPEAssignment_key
            ,PPEAction_key
            ,ActionedByContact_key
            ,ActionedOn
            ,Wallet_key
        ) VALUES (
            source.PPEAssignmentHistoryId
            ,source.PPEAssignment_key
            ,source.PPEAction_key
            ,source.ActionedByContact_key
            ,source.ActionedOn
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.PPEAssignmentHistory, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
