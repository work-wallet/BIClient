DROP PROCEDURE IF EXISTS mart.ETL_LoadAudits;
GO

CREATE PROCEDURE mart.ETL_LoadAudits
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

        -- maintain the Location dimension

        DECLARE @locationTable mart.ETL_LocationTable;

        INSERT INTO @locationTable
        (
            LocationId
            ,LocationTypeCode
            ,LocationType
            ,[Location]
            ,CompanyId
            ,Company
            ,SiteId
            ,[Site]
            ,AreaId
            ,Area
            ,JobId
            ,Job
            ,SiteLocationId
            ,Department
            ,ExternalIdentifier
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.Locations')
        WITH
        (
            LocationId uniqueidentifier
            ,LocationTypeCode int
            ,LocationType nvarchar(50)
            ,[Location] nvarchar(max)
            ,CompanyId uniqueidentifier
            ,Company nvarchar(max)
            ,SiteId uniqueidentifier
            ,[Site] nvarchar(max)
            ,AreaId uniqueidentifier
            ,[Area] nvarchar(255)
            ,JobId uniqueidentifier
            ,Job nvarchar(50)
            ,SiteLocationId uniqueidentifier
            ,Department nvarchar(30)
            ,ExternalIdentifier nvarchar(255)
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainLocationDimension @locationTable = @locationTable;

        -- maintain AuditType dimension

        DECLARE @auditTypeTable mart.ETL_AuditTypeTable;

        INSERT INTO @auditTypeTable
        (
            AuditTypeId
            ,AuditTypeVersion
            ,AuditType
            ,[Description]
            ,ScoringEnabled
            ,DisplayPercentage
            ,DisplayTotalScore
            ,DisplayAverageScore
            ,GradingSet
            ,GradingSetIsPercentage
            ,GradingSetIsScore
            ,ReportingEnabled
            ,ReportingAbbreviation
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.AuditTypes')
        WITH
        (
            AuditTypeId uniqueidentifier
            ,AuditTypeVersion int
            ,AuditType nvarchar(500)
            ,[Description] nvarchar(2000)
            ,ScoringEnabled bit
            ,DisplayPercentage bit
            ,DisplayTotalScore bit
            ,DisplayAverageScore bit
            ,GradingSet nvarchar(100)
            ,GradingSetIsPercentage bit
            ,GradingSetIsScore bit
            ,ReportingEnabled bit
            ,ReportingAbbreviation nvarchar(4)
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainAuditTypeDimension @auditTypeTable = @auditTypeTable;

        -- maintain Audit dimension

        DECLARE @auditTable mart.ETL_AuditTable;

        INSERT INTO @auditTable
        (
            AuditId
            ,Reference
            ,AuditReference
            ,AuditGroupId
            ,AuditGroup
            ,AuditStatusCode
            ,AuditTypeId
            ,AuditTypeVersion
            ,LocationId
            ,InspectedOn
            ,[Description]
            ,TotalScore
            ,TotalPotentialScore
            ,AverageScore
            ,AveragePotentialScore
            ,PercentageScore
            ,Flags
            ,GradingSetOption
            ,ExternalIdentifier
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.Audits')
        WITH
        (
            AuditId uniqueidentifier
            ,Reference int
            ,AuditReference nvarchar(50)
            ,AuditGroupId uniqueidentifier
            ,AuditGroup nvarchar(40)
            ,AuditStatusCode int
            ,AuditTypeId uniqueidentifier
            ,AuditTypeVersion int
            ,LocationId uniqueidentifier
            ,InspectedOn datetime
            ,[Description] nvarchar(max)
            ,TotalScore int
            ,TotalPotentialScore int
            ,AverageScore decimal(38,6)
            ,AveragePotentialScore decimal(38,6)
            ,PercentageScore decimal(7,6)
            ,Flags int
            ,GradingSetOption nvarchar(250)
            ,ExternalIdentifier nvarchar(255)
            ,WalletId uniqueidentifier
        );

        EXEC mart.ETL_MaintainAuditGroupDimension @auditTable = @auditTable;
        EXEC mart.ETL_MaintainAuditDimension @auditTable = @auditTable;

        EXEC mart.ETL_DeleteAuditFacts @auditTable = @auditTable;

        -- maintain AuditInspectedBy dimension

        DECLARE @auditInspectedByTable mart.ETL_AuditInspectedByTable;
        DECLARE @contactTable mart.ETL_ContactTable;

        INSERT INTO @auditInspectedByTable
        (
            AuditId
            ,ContactId
            ,[Name]
            ,WalletId
        )
        SELECT * FROM OPENJSON(@json, '$.AuditInspectors')
        WITH
        (
            AuditId uniqueidentifier
            ,ContactId uniqueidentifier
            ,[Name] nvarchar(max)
            ,WalletId uniqueidentifier
        );

        INSERT INTO @contactTable
        (
            ContactId
            ,[Name]
            ,WalletId
        )
        SELECT DISTINCT
            ContactId
            ,[Name]
            ,WalletId
        FROM @auditInspectedByTable;

        EXEC mart.ETL_MaintainContactDimension @contactTable = @contactTable;
        EXEC mart.ETL_LoadAuditInspectedByFact @auditInspectedByTable = @auditInspectedByTable;

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
