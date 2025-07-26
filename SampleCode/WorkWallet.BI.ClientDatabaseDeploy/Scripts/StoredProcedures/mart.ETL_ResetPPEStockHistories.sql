DROP PROCEDURE IF EXISTS mart.ETL_ResetPPEStockHistories;
GO

CREATE PROCEDURE mart.ETL_ResetPPEStockHistories @walletId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    EXEC mart.ETL_ResetPPE @walletId;

END
GO
