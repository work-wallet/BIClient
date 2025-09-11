DROP PROCEDURE IF EXISTS mart.ETL_MaintainPPEAssignmentDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainPPEAssignmentDimension @ppeAssignmentTable mart.ETL_PPEAssignmentTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.PPEAssignment AS target
    USING (
        SELECT
            a.PPEAssignmentId
            ,c.Contact_key AS AssignedToContact_key
            ,pt.PPEType_key
            ,a.AssignedOn
            ,a.ExpiredOn
            ,ps.PPEStatus_key
            ,afs.PPEStock_key AS AssignedFromPPEStock_key
            ,rts.PPEStock_key AS ReturnedToPPEStock_key
            ,rrs.PPEStock_key AS ReplacementRequestedFromPPEStock_key
            ,a.ReplacementRequestedOn
            ,w.Wallet_key
        FROM
            @ppeAssignmentTable AS a
            INNER JOIN mart.Contact AS c ON a.AssignedToContactId = c.ContactId
            INNER JOIN mart.PPEType AS pt ON a.PPETypeId = pt.PPETypeId AND a.PPETypeVariantId = pt.PPETypeVariantId
            INNER JOIN mart.PPEStatus AS ps ON a.PPEStatusCode = ps.PPEStatusCode
            LEFT JOIN mart.PPEStock AS afs ON a.AssignedFromStockId = afs.PPEStockId
            LEFT JOIN mart.PPEStock AS rts ON a.ReturnedToStockId = rts.PPEStockId
            LEFT JOIN mart.PPEStock AS rrs ON a.ReplacementRequestedFromStockId = rrs.PPEStockId
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON target.PPEAssignmentId = source.PPEAssignmentId
    WHEN MATCHED AND (
        target.AssignedToContact_key <> source.AssignedToContact_key
        OR target.PPEType_key <> source.PPEType_key
        OR target.AssignedOn <> source.AssignedOn
        OR target.ExpiredOn IS DISTINCT FROM source.ExpiredOn
        OR target.PPEStatus_key <> source.PPEStatus_key
        OR target.AssignedFromPPEStock_key IS DISTINCT FROM source.AssignedFromPPEStock_key
        OR target.ReturnedToPPEStock_key IS DISTINCT FROM source.ReturnedToPPEStock_key
        OR target.ReplacementRequestedFromPPEStock_key IS DISTINCT FROM source.ReplacementRequestedFromPPEStock_key
        OR target.ReplacementRequestedOn IS DISTINCT FROM source.ReplacementRequestedOn
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            AssignedToContact_key = source.AssignedToContact_key
            ,PPEType_key = source.PPEType_key
            ,AssignedOn = source.AssignedOn
            ,ExpiredOn = source.ExpiredOn
            ,PPEStatus_key = source.PPEStatus_key
            ,AssignedFromPPEStock_key = source.AssignedFromPPEStock_key
            ,ReturnedToPPEStock_key = source.ReturnedToPPEStock_key
            ,ReplacementRequestedFromPPEStock_key = source.ReplacementRequestedFromPPEStock_key
            ,ReplacementRequestedOn = source.ReplacementRequestedOn
            ,Wallet_key = source.Wallet_key
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            PPEAssignmentId
            ,AssignedToContact_key
            ,PPEType_key
            ,AssignedOn
            ,ExpiredOn
            ,PPEStatus_key
            ,AssignedFromPPEStock_key
            ,ReturnedToPPEStock_key
            ,ReplacementRequestedFromPPEStock_key
            ,ReplacementRequestedOn
            ,Wallet_key
        ) VALUES (
            source.PPEAssignmentId
            ,source.AssignedToContact_key
            ,source.PPEType_key
            ,source.AssignedOn
            ,source.ExpiredOn
            ,source.PPEStatus_key
            ,source.AssignedFromPPEStock_key
            ,source.ReturnedToPPEStock_key
            ,source.ReplacementRequestedFromPPEStock_key
            ,source.ReplacementRequestedOn
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.PPEAssignment, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
