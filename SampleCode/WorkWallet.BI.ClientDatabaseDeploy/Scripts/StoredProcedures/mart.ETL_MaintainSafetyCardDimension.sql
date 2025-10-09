DROP PROCEDURE IF EXISTS mart.ETL_MaintainSafetyCardDimension;
GO

CREATE PROCEDURE mart.ETL_MaintainSafetyCardDimension @safetyCardTable mart.ETL_SafetyCardTable READONLY
AS
BEGIN
    SET NOCOUNT ON;

    MERGE mart.SafetyCard AS target
    USING (
        SELECT
            a.SafetyCardId
            ,a.SafetyCardReference
            ,sct.SafetyCardType_key
            ,a.ReportedByUser
            ,a.ReportedDateTime
            ,scc.SafetyCardCategory_key
            ,a.Employer
            ,a.Employee
            ,a.InductionNumber
            ,a.ReportDetails
            ,scs.SafetyCardStatus_key
            ,a.HasSignature
            ,a.SignatureDate
            ,a.Occupation
            ,scor.SafetyCardOccupationRole_key
            ,l.Location_key
            ,a.ExternalIdentifier
            ,w.Wallet_key
        FROM
            @safetyCardTable AS a
            INNER JOIN mart.SafetyCardType AS sct ON a.SafetyCardTypeCode = sct.SafetyCardTypeCode
            INNER JOIN mart.SafetyCardCategory AS scc ON a.SafetyCardCategoryId = scc.SafetyCardCategoryId
            INNER JOIN mart.SafetyCardStatus AS scs ON a.SafetyCardStatusCode = scs.SafetyCardStatusCode
            INNER JOIN mart.SafetyCardOccupationRole AS scor ON a.OccupationRoleCode = scor.OccupationRoleCode
            INNER JOIN mart.[Location] AS l ON a.LocationId = l.LocationId
            INNER JOIN mart.Wallet AS w ON a.WalletId = w.WalletId
    ) AS source
    ON target.SafetyCardId = source.SafetyCardId
    WHEN MATCHED AND (
        target.SafetyCardReference <> source.SafetyCardReference
        OR target.SafetyCardType_key <> source.SafetyCardType_key
        OR target.ReportedByUser <> source.ReportedByUser
        OR target.ReportedDateTime <> source.ReportedDateTime
        OR target.SafetyCardCategory_key <> source.SafetyCardCategory_key
        OR target.Employer <> source.Employer
        OR target.Employee <> source.Employee
        OR target.InductionNumber <> source.InductionNumber
        OR target.ReportDetails <> source.ReportDetails
        OR target.SafetyCardStatus_key <> source.SafetyCardStatus_key
        OR target.HasSignature <> source.HasSignature
        OR target.SignatureDate <> source.SignatureDate
        OR target.Occupation <> source.Occupation
        OR target.SafetyCardOccupationRole_key <> source.SafetyCardOccupationRole_key
        OR target.Location_key <> source.Location_key
        OR target.ExternalIdentifier <> source.ExternalIdentifier
        OR target.Wallet_key <> source.Wallet_key
    )
    THEN
        UPDATE SET
            SafetyCardReference = source.SafetyCardReference
            ,SafetyCardType_key = source.SafetyCardType_key
            ,ReportedByUser = source.ReportedByUser
            ,ReportedDateTime = source.ReportedDateTime
            ,SafetyCardCategory_key = source.SafetyCardCategory_key
            ,Employer = source.Employer
            ,Employee = source.Employee
            ,InductionNumber = source.InductionNumber
            ,ReportDetails = source.ReportDetails
            ,SafetyCardStatus_key = source.SafetyCardStatus_key
            ,HasSignature = source.HasSignature
            ,Occupation = source.Occupation
            ,SafetyCardOccupationRole_key = source.SafetyCardOccupationRole_key
            ,Location_key = source.Location_key
            ,ExternalIdentifier = source.ExternalIdentifier
            ,Wallet_key = source.Wallet_key
            ,_edited = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            SafetyCardId
            ,SafetyCardReference
            ,SafetyCardType_key
            ,ReportedByUser
            ,ReportedDateTime
            ,SafetyCardCategory_key
            ,Employer
            ,Employee
            ,InductionNumber
            ,ReportDetails
            ,SafetyCardStatus_key
            ,HasSignature
            ,SignatureDate
            ,Occupation
            ,SafetyCardOccupationRole_key
            ,Location_key
            ,ExternalIdentifier
            ,Wallet_key
        ) VALUES (
            source.SafetyCardId
            ,source.SafetyCardReference
            ,source.SafetyCardType_key
            ,source.ReportedByUser
            ,source.ReportedDateTime
            ,source.SafetyCardCategory_key
            ,source.Employer
            ,source.Employee
            ,source.InductionNumber
            ,source.ReportDetails
            ,source.SafetyCardStatus_key
            ,source.HasSignature
            ,source.SignatureDate
            ,source.Occupation
            ,source.SafetyCardOccupationRole_key
            ,source.Location_key
            ,source.ExternalIdentifier
            ,source.Wallet_key
        );

    PRINT 'MERGE mart.SafetyCard, number of rows = ' + CAST(@@ROWCOUNT AS varchar);
END
GO
