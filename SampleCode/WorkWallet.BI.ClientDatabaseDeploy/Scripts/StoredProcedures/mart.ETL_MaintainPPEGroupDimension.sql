DROP PROCEDURE IF EXISTS mart.ETL_MaintainPPEGroupDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainPPEGroupDimension @ppeGroupTable mart.ETL_PPEGroupTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.PPEGroup AS target
    USING (
        SELECT
            a.PPEGroupId
            ,a.PPEGroup
            ,a.Active
            ,w.Wallet_key        
        FROM
            @ppeGroupTable AS a
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON target.PPEGroupId = source.PPEGroupId
    WHEN MATCHED AND (
        target.PPEGroup <> source.PPEGroup
        OR target.Active <> source.Active
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            PPEGroup = source.PPEGroup
            ,Active = source.Active
            ,Wallet_key = source.Wallet_key
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            PPEGroupId
            ,PPEGroup
            ,Active
            ,Wallet_key
        ) VALUES (
            source.PPEGroupId
            ,source.PPEGroup
            ,source.Active
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.PPEGroup, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
