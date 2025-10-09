DROP PROCEDURE IF EXISTS mart.ETL_LoadInductions;
GO

CREATE PROCEDURE mart.ETL_LoadInductions
    @json nvarchar(max)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION

        -- maintain the Wallet dimension table

        DECLARE @walletTable mart.ETL_WalletTable;

        INSERT INTO @walletTable
        (
            WalletId
            ,Wallet
        )
        SELECT * FROM OPENJSON(@json, '$.Wallets')
        WITH
        (
            WalletId uniqueidentifier
            ,Wallet nvarchar(50)
        );

        EXEC mart.ETL_MaintainWalletDimension @walletTable = @walletTable;

        -- maintain the Inductions table

        DECLARE @inductionTable mart.ETL_InductionTable;

        INSERT INTO @inductionTable
        (
            InductionId
            ,InductionVersion
            ,InductionName
            ,ValidForDays
            ,CreatedOn
            ,Active
            ,InductionStatusCode
            ,TestPassMark
            ,TestQuestionCount
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.Inductions')
        WITH
        (
            InductionId uniqueidentifier
            ,InductionVersion int
            ,InductionName nvarchar(100)
            ,ValidForDays int
            ,CreatedOn datetimeoffset(7)
            ,Active bit
            ,InductionStatusCode int
            ,TestPassMark int
            ,TestQuestionCount int
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainInductionDimension @inductionTable = @inductionTable;

        -- maintain the InductionTaken table

        DECLARE @inductionTakenTable mart.ETL_InductionTakenTable;

        INSERT INTO @inductionTakenTable
        (
            InductionTakenId
            ,InductionId
            ,InductionVersion
            ,ContactId
            ,[Name]
            ,CompanyName
            ,TakenOn
            ,CorrectTestQuestionCount
            ,InductionTakenStatusId
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.InductionsTaken')
        WITH
        (
            InductionTakenId uniqueidentifier
            ,InductionId uniqueidentifier
            ,InductionVersion int
            ,ContactId uniqueidentifier
            ,[Name] nvarchar(max)
            ,CompanyName nvarchar(max)
            ,TakenOn datetime
            ,CorrectTestQuestionCount int
            ,InductionTakenStatusId int
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainInductionTakenDimension @InductionTakenTable = @InductionTakenTable;

        EXEC mart.ETL_DeleteInductionFacts @inductionTakenTable = @inductionTakenTable;

        -- load the InductionCustomQuestions data

        DECLARE @inductionCustomQuestionTable mart.ETL_InductionCustomQuestionTable;

        INSERT INTO @inductionCustomQuestionTable
        (
            InductionTakenId
            ,AnswerId
            ,Title
            ,[Value]
            ,ValueId
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.InductionCustomQuestions')
        WITH
        (
            InductionTakenId uniqueidentifier
            ,AnswerId uniqueidentifier
            ,Title nvarchar(250)
            ,[Value] nvarchar(250)
            ,ValueId uniqueidentifier
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainInductionCustomQuestionDimension @inductionCustomQuestionTable = @inductionCustomQuestionTable;

        EXEC mart.ETL_LoadInductionCustomQuestionFact @inductionCustomQuestionTable = @inductionCustomQuestionTable;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;

        DECLARE @ErrorMessage NVARCHAR(4000);  
        DECLARE @ErrorSeverity INT;  
        DECLARE @ErrorState INT;  

        SELECT   
           @ErrorMessage = ERROR_MESSAGE(),  
           @ErrorSeverity = ERROR_SEVERITY(),  
           @ErrorState = ERROR_STATE();  

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
    END
GO
