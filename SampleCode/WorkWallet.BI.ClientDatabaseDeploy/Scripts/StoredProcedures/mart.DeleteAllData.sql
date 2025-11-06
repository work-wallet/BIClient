DROP PROCEDURE IF EXISTS mart.DeleteAllData;
GO

CREATE PROCEDURE mart.DeleteAllData
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        PRINT 'Starting database deletion...';
        -- Note: Using DELETE instead of TRUNCATE because TRUNCATE cannot be used
        -- on tables referenced by foreign key constraints, even when disabled.

    -- ========================================
    -- Actions Dataset
    -- ========================================
    PRINT 'Deleting Actions dataset tables...';
    
    DELETE FROM mart.ActionUpdate;
    DELETE FROM mart.Action;

    -- ========================================
    -- Assets Dataset
    -- ========================================
    PRINT 'Deleting Assets dataset tables...';
    
    DELETE FROM mart.AssetPropertyFact;
    DELETE FROM mart.AssetAssignmentFact;
    DELETE FROM mart.AssetProperty;
    DELETE FROM mart.AssetAssignment;
    -- Note: Asset dimension is shared - truncated in Common section

    -- ========================================
    -- AssetInspections Dataset
    -- ========================================
    PRINT 'Deleting AssetInspections dataset tables...';
    
    DELETE FROM mart.AssetInspectionPropertyFact;
    DELETE FROM mart.AssetInspectionChecklistItemFact;
    DELETE FROM mart.AssetInspectionObservationFact;
    DELETE FROM mart.AssetInspectionProperty;
    DELETE FROM mart.AssetInspectionChecklistItem;
    DELETE FROM mart.AssetInspection;

    -- ========================================
    -- AssetObservations Dataset
    -- (No dataset-specific tables - observations handled in Common section)
    -- ========================================
    PRINT 'Deleting AssetObservations dataset tables...';
    -- Note: AssetObservation dimension is shared - truncated in Common section

    -- ========================================
    -- Audits Dataset
    -- ========================================
    PRINT 'Deleting Audits dataset tables...';
    
    DELETE FROM mart.AuditBranchOptionFact;
    DELETE FROM mart.AuditChecklistAnswerFact;
    DELETE FROM mart.AuditDateTimeAnswerFact;
    DELETE FROM mart.AuditInspectedByFact;
    DELETE FROM mart.AuditNumericAnswerFact;
    DELETE FROM mart.AuditScoredResponseFact;
    DELETE FROM mart.AuditScoreSectionFact;
    DELETE FROM mart.AuditScoreTagFact;
    DELETE FROM mart.AuditBranchOption;
    DELETE FROM mart.AuditChecklistOption;
    DELETE FROM mart.AuditDateTimeQuestion;
    DELETE FROM mart.AuditNumericQuestion;
    DELETE FROM mart.AuditScoredResponse;
    DELETE FROM mart.AuditScoreSection;
    DELETE FROM mart.AuditScoreTag;
    DELETE FROM mart.Audit;
    DELETE FROM mart.AuditType;
    DELETE FROM mart.AuditGroup;

    -- ========================================
    -- Inductions Dataset
    -- ========================================
    PRINT 'Deleting Inductions dataset tables...';
    
    DELETE FROM mart.InductionCustomQuestionFact;
    DELETE FROM mart.InductionCustomQuestion;
    DELETE FROM mart.InductionTaken;
    DELETE FROM mart.Induction;

    -- ========================================
    -- Permits Dataset
    -- ========================================
    PRINT 'Deleting Permits dataset tables...';
    
    DELETE FROM mart.PermitChecklistAnswerFact;
    DELETE FROM mart.PermitChecklistAnswer;
    DELETE FROM mart.Permit;
    DELETE FROM mart.PermitCategory;

    -- ========================================
    -- PPE Datasets (PPEAssignments, PPEStockHistories, PPEStocks)
    -- ========================================
    PRINT 'Deleting PPE dataset tables...';
    
    DELETE FROM mart.PPEAssignmentHistory;
    DELETE FROM mart.PPEAssignment;
    DELETE FROM mart.PPEStockHistory;
    DELETE FROM mart.PPEStock;
    DELETE FROM mart.PPEType;

    -- ========================================
    -- ReportedIssues Dataset
    -- ========================================
    PRINT 'Deleting ReportedIssues dataset tables...';
    
    DELETE FROM mart.ReportedIssueBodyPartFact;
    DELETE FROM mart.ReportedIssueBranchOptionFact;
    DELETE FROM mart.ReportedIssueOptionSelectFact;
    DELETE FROM mart.ReportedIssuePersonFact;
    DELETE FROM mart.ReportedIssueRootCauseAnalysisFact;
    DELETE FROM mart.ReportedIssueBodyPart;
    DELETE FROM mart.ReportedIssueBranchOption;
    DELETE FROM mart.ReportedIssueOptionSelect;
    DELETE FROM mart.ReportedIssuePerson;
    DELETE FROM mart.ReportedIssue;
    DELETE FROM mart.ReportedIssueCategory;

    -- ========================================
    -- SafetyCards Dataset
    -- ========================================
    PRINT 'Deleting SafetyCards dataset tables...';
    
    DELETE FROM mart.SafetyCard;
    DELETE FROM mart.SafetyCardCategory;

    -- ========================================
    -- Common/Shared Dimensions
    -- ========================================
    PRINT 'Deleting shared dimension tables...';
    
    -- Shared across AssetInspections and AssetObservations
    DELETE FROM mart.AssetObservation;
    
    -- Shared across Assets, AssetInspections, and AssetObservations
    DELETE FROM mart.Asset;
    
    -- Shared dimensions
    DELETE FROM mart.Contact;
    DELETE FROM mart.GradingSetOption;
    DELETE FROM mart.Location;
    DELETE FROM mart.Wallet;

    -- ========================================
    -- Lookup/Reference Tables (Not Truncated)
    -- ========================================
    -- These tables contain reference data loaded at schema creation time
    -- and should NOT be truncated:
    PRINT 'Skipping lookup/reference tables (contain static reference data)...';
    -- - mart.ActionPriority
    -- - mart.ActionStatus
    -- - mart.ActionType
    -- - mart.AssetAssignmentType
    -- - mart.AssetObservationStatus
    -- - mart.AssetPropertyType
    -- - mart.AssetStatus
    -- - mart.AuditStatus
    -- - mart.InductionStatus
    -- - mart.InductionTakenStatus
    -- - mart.PermitStatus
    -- - mart.PPEAction
    -- - mart.PPEStatus
    -- - mart.ReportedIssueBodyPartEnum
    -- - mart.ReportedIssueRootCauseAnalysisType
    -- - mart.ReportedIssueSeverity
    -- - mart.ReportedIssueStatus
    -- - mart.SafetyCardOccupationRole
    -- - mart.SafetyCardStatus
    -- - mart.SafetyCardType
    -- - mart.Unit

    -- ========================================
    -- Tracking Table
    -- ========================================
    PRINT 'Deleting tracking table...';
    DELETE FROM mart.ETL_ChangeDetection;

        PRINT 'Database deletion completed successfully.';

    END TRY
    BEGIN CATCH
        
        -- Re-throw the error to notify caller
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END
GO
