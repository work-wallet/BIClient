-- Missing FK constraints omitted from earlier schema scripts.
-- These are additive fixes with no data impact.

-- Step 1: add missing FK constraints related to contacts omitted in 0022.

IF NOT EXISTS(SELECT 1 FROM sys.foreign_keys WHERE [name] = N'FK_mart.AssetAssignment_mart.Contact_Contact_key' AND parent_object_id = OBJECT_ID(N'mart.AssetAssignment'))
BEGIN

    ALTER TABLE mart.AssetAssignment
    ADD CONSTRAINT [FK_mart.AssetAssignment_mart.Contact_Contact_key]
        FOREIGN KEY (Contact_key) REFERENCES mart.Contact (Contact_key);

END

GO

IF NOT EXISTS(SELECT 1 FROM sys.foreign_keys WHERE [name] = N'FK_mart.InductionTaken_mart.Contact_Contact_key' AND parent_object_id = OBJECT_ID(N'mart.InductionTaken'))
BEGIN

    ALTER TABLE mart.InductionTaken
    ADD CONSTRAINT [FK_mart.InductionTaken_mart.Contact_Contact_key]
        FOREIGN KEY (Contact_key) REFERENCES mart.Contact (Contact_key);

END

GO

IF NOT EXISTS(SELECT 1 FROM sys.foreign_keys WHERE [name] = N'FK_mart.ReportedIssue_mart.Contact_ReportedByContact_key' AND parent_object_id = OBJECT_ID(N'mart.ReportedIssue'))
BEGIN

    ALTER TABLE mart.ReportedIssue
    ADD CONSTRAINT [FK_mart.ReportedIssue_mart.Contact_ReportedByContact_key]
        FOREIGN KEY (ReportedByContact_key) REFERENCES mart.Contact (Contact_key);

END

GO

IF NOT EXISTS(SELECT 1 FROM sys.foreign_keys WHERE [name] = N'FK_mart.SafetyCard_mart.Contact_EmployeeContact_key' AND parent_object_id = OBJECT_ID(N'mart.SafetyCard'))
BEGIN

    ALTER TABLE mart.SafetyCard
    ADD CONSTRAINT [FK_mart.SafetyCard_mart.Contact_EmployeeContact_key]
        FOREIGN KEY (EmployeeContact_key) REFERENCES mart.Contact (Contact_key);

END

GO

-- Step 2: add missing FK constraints for Audit_key omitted from audit fact tables in 0015.

IF NOT EXISTS(SELECT 1 FROM sys.foreign_keys WHERE [name] = N'FK_mart.AuditNumericAnswerFact_mart.Audit_Audit_key' AND parent_object_id = OBJECT_ID(N'mart.AuditNumericAnswerFact'))
BEGIN
    ALTER TABLE mart.AuditNumericAnswerFact
    ADD CONSTRAINT [FK_mart.AuditNumericAnswerFact_mart.Audit_Audit_key]
        FOREIGN KEY (Audit_key) REFERENCES mart.[Audit] (Audit_key);
END

GO

IF NOT EXISTS(SELECT 1 FROM sys.foreign_keys WHERE [name] = N'FK_mart.AuditDateTimeAnswerFact_mart.Audit_Audit_key' AND parent_object_id = OBJECT_ID(N'mart.AuditDateTimeAnswerFact'))
BEGIN
    ALTER TABLE mart.AuditDateTimeAnswerFact
    ADD CONSTRAINT [FK_mart.AuditDateTimeAnswerFact_mart.Audit_Audit_key]
        FOREIGN KEY (Audit_key) REFERENCES mart.[Audit] (Audit_key);
END

GO

IF NOT EXISTS(SELECT 1 FROM sys.foreign_keys WHERE [name] = N'FK_mart.AuditChecklistAnswerFact_mart.Audit_Audit_key' AND parent_object_id = OBJECT_ID(N'mart.AuditChecklistAnswerFact'))
BEGIN
    ALTER TABLE mart.AuditChecklistAnswerFact
    ADD CONSTRAINT [FK_mart.AuditChecklistAnswerFact_mart.Audit_Audit_key]
        FOREIGN KEY (Audit_key) REFERENCES mart.[Audit] (Audit_key);
END

GO

IF NOT EXISTS(SELECT 1 FROM sys.foreign_keys WHERE [name] = N'FK_mart.AuditBranchOptionFact_mart.Audit_Audit_key' AND parent_object_id = OBJECT_ID(N'mart.AuditBranchOptionFact'))
BEGIN
    ALTER TABLE mart.AuditBranchOptionFact
    ADD CONSTRAINT [FK_mart.AuditBranchOptionFact_mart.Audit_Audit_key]
        FOREIGN KEY (Audit_key) REFERENCES mart.[Audit] (Audit_key);
END

GO

IF NOT EXISTS(SELECT 1 FROM sys.foreign_keys WHERE [name] = N'FK_mart.AuditScoredResponseFact_mart.Audit_Audit_key' AND parent_object_id = OBJECT_ID(N'mart.AuditScoredResponseFact'))
BEGIN
    ALTER TABLE mart.AuditScoredResponseFact
    ADD CONSTRAINT [FK_mart.AuditScoredResponseFact_mart.Audit_Audit_key]
        FOREIGN KEY (Audit_key) REFERENCES mart.[Audit] (Audit_key);
END

GO

IF NOT EXISTS(SELECT 1 FROM sys.foreign_keys WHERE [name] = N'FK_mart.AuditScoreSection_mart.AuditType_AuditType_key' AND parent_object_id = OBJECT_ID(N'mart.AuditScoreSection'))
BEGIN
    ALTER TABLE mart.AuditScoreSection
    ADD CONSTRAINT [FK_mart.AuditScoreSection_mart.AuditType_AuditType_key]
        FOREIGN KEY (AuditType_key) REFERENCES mart.AuditType (AuditType_key);
END

GO

IF NOT EXISTS(SELECT 1 FROM sys.foreign_keys WHERE [name] = N'FK_mart.AuditScoreSectionFact_mart.Audit_Audit_key' AND parent_object_id = OBJECT_ID(N'mart.AuditScoreSectionFact'))
BEGIN
    ALTER TABLE mart.AuditScoreSectionFact
    ADD CONSTRAINT [FK_mart.AuditScoreSectionFact_mart.Audit_Audit_key]
        FOREIGN KEY (Audit_key) REFERENCES mart.[Audit] (Audit_key);
END

GO

IF NOT EXISTS(SELECT 1 FROM sys.foreign_keys WHERE [name] = N'FK_mart.AuditScoreTagFact_mart.Audit_Audit_key' AND parent_object_id = OBJECT_ID(N'mart.AuditScoreTagFact'))
BEGIN
    ALTER TABLE mart.AuditScoreTagFact
    ADD CONSTRAINT [FK_mart.AuditScoreTagFact_mart.Audit_Audit_key]
        FOREIGN KEY (Audit_key) REFERENCES mart.[Audit] (Audit_key);
END

GO

-- Step 3: add missing FK constraint for TransferredFromPPEStock_key omitted in 0020.

IF NOT EXISTS(SELECT 1 FROM sys.foreign_keys WHERE [name] = N'FK_mart.PPEStockHistory_mart.PPEStock_TransferredFromPPEStock_key' AND parent_object_id = OBJECT_ID(N'mart.PPEStockHistory'))
BEGIN
    ALTER TABLE mart.PPEStockHistory
    ADD CONSTRAINT [FK_mart.PPEStockHistory_mart.PPEStock_TransferredFromPPEStock_key]
        FOREIGN KEY (TransferredFromPPEStock_key) REFERENCES mart.PPEStock (PPEStock_key);
END

GO
