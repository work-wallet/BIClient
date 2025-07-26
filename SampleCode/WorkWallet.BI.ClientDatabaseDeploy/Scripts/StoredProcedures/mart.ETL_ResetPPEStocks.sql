DROP PROCEDURE IF EXISTS mart.ETL_ResetPPEStocks;
GO

CREATE PROCEDURE mart.ETL_ResetPPEStocks @walletId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    EXEC mart.ETL_ResetPPE @walletId;

END
GO
