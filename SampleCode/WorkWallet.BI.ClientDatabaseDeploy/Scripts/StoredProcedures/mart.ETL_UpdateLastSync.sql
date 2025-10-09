DROP PROCEDURE IF EXISTS mart.ETL_UpdateLastSync;
GO

CREATE PROCEDURE mart.ETL_UpdateLastSync(@walletId uniqueidentifier, @logType AS nvarchar(255), @synchronizationVersion AS bigint, @rowsProcessed AS int)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRANSACTION;
    
    /* remove IsLatest flag from previous status */
    UPDATE mart.ETL_ChangeDetection
    SET
        IsLatest = 0
    WHERE
        WalletId = @walletId
        AND LogType = @logType
        AND IsLatest = 1;

    /* update change detection status */
    INSERT INTO mart.ETL_ChangeDetection
    (
        WalletId
        ,LogType
        ,IsLatest
        ,LastProcessedTime
        ,LastSynchronizationVersion
        ,RowsProcessed
    )
    VALUES
    (
        @walletId
        ,@logType
        ,1
        ,SYSDATETIMEOFFSET()
        ,@synchronizationVersion
        ,@rowsProcessed
    );
    
    COMMIT TRANSACTION;
END
GO