DROP PROCEDURE IF EXISTS mart.ETL_ResetPPEStockAssignments;
GO

CREATE PROCEDURE mart.ETL_ResetPPEStockAssignments @walletId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    EXEC mart.ETL_ResetPPE @walletId;

END
GO
