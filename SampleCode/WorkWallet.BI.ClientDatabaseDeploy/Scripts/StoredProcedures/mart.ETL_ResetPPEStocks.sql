DROP PROCEDURE IF EXISTS mart.ETL_ResetPPEStocks;
GO

CREATE PROCEDURE mart.ETL_ResetPPEStocks @walletId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    /* Do nothing - the PPE stock tables are also used for PPEStockHistories and PPEStockAssignments,
       so not safe to delete them.
       See also mart.ETL_ResetPPECommon */

END
GO
