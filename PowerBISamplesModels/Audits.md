# Audits

[<- Back to index](../PowerBISamplesModels.md)

## Audits - Main

```mermaid
---
config:
  theme: neutral
  er:
    useMaxWidth: false
---
erDiagram
    "Audit" {
        attr Reference
        attr AuditReference
        attr InspectedOn
        agg Score
        agg PotentialScore
        attr AverageScore
        attr AveragePotentialScore
        attr PercentageScore
        agg Flags
        attr ExternalIdentifier
        calc ConductedBy
        calc ScoreDisplay
        calc AuditCount
        attr PlannedStatusDate
        attr ReportInProgressStatusDate
        attr ReadyForReviewStatusDate
        attr CompleteStatusDate
        attr ClosedStatusDate
    }
    "Audit Type" {
        attr AuditType
        attr AuditTypeDescription
        attr ScoringEnabled
        attr DisplayPercentage
        attr DisplayTotalScore
        attr DisplayAverageScore
        attr GradingSet
        attr GradingSetIsPercentage
        attr GradingSetIsScore
        attr ReportingEnabled
        attr ReportingAbbreviation
        attr GradingSetId
        attr GradingSetVersion
    }
    "Audit Group" {
        attr AuditGroup
    }
    "Audit Status" {
        attr AuditStatus
    }
    "Location" {
        attr LocationType
        attr Location
        attr Company
        attr Site
        attr Area
        attr Job
        attr Department
        attr LocationExternalIdentifier
        attr AllDepartments
        attr SiteStatus
    }
    "Audit Grading Set Option" {
        attr AuditGradingSet
        attr AuditGrading
        attr AuditGradingValue
        attr AuditGradingColour
        attr AuditGradingSetIsPercentage
        attr AuditGradingSetIsScore
    }
    "Audit" }o--|| "Audit Group" : "AuditGroup_key"
    "Audit" }o--|| "Audit Status" : "AuditStatus_key"
    "Audit" }o--|| "Audit Type" : "AuditType_key"
    "Audit" }o--|| "Location" : "Location_key"
    "Audit" }o--|| "Audit Grading Set Option" : "GradingSetOption_key"
```

## Audits - Inspected By

```mermaid
---
config:
  theme: neutral
  er:
    useMaxWidth: false
---
erDiagram
    "Audit" {
        attr Reference
        attr AuditReference
        attr InspectedOn
        agg Score
        agg PotentialScore
        attr AverageScore
        attr AveragePotentialScore
        attr PercentageScore
        agg Flags
        attr ExternalIdentifier
        calc ConductedBy
        calc ScoreDisplay
        calc AuditCount
        attr PlannedStatusDate
        attr ReportInProgressStatusDate
        attr ReadyForReviewStatusDate
        attr CompleteStatusDate
        attr ClosedStatusDate
    }
    "Inspected By Fact" {
        calc InspectedByCount
    }
    "Contact" {
        attr ContactName
        attr Email
        attr Company
    }
    "Inspected By Fact" }o--|| "Audit" : "Audit_key"
    "Inspected By Fact" }o--|| "Contact" : "Contact_key"
```

## Audits - Scored Response

```mermaid
---
config:
  theme: neutral
  er:
    useMaxWidth: false
---
erDiagram
    "Audit" {
        attr Reference
        attr AuditReference
        attr InspectedOn
        agg Score
        agg PotentialScore
        attr AverageScore
        attr AveragePotentialScore
        attr PercentageScore
        agg Flags
        attr ExternalIdentifier
        calc ConductedBy
        calc ScoreDisplay
        calc AuditCount
        attr PlannedStatusDate
        attr ReportInProgressStatusDate
        attr ReadyForReviewStatusDate
        attr CompleteStatusDate
        attr ClosedStatusDate
    }
    "Scored Response" {
        attr ScoredResponseQuestion
        attr ScoredResponseAnswer
        calc Response
        attr Section
        calc Question
    }
    "Scored Response Fact" {
        agg Score
        agg PotentialScore
        attr PercentageScore
        attr Flag
        calc ScoreResponseCount
        calc ScoreDisplay
    }
    "Scored Response Grading Set Option" {
        attr ScoredResponseGradingSet
        attr ScoredResponseGrading
        attr ScoredResponseGradingValue
        attr ScoredResponseGradingColour
        attr ScoredResponseGradingSetIsPercentage
        attr ScoredResponseGradingSetIsScore
    }
    "Scored Response Fact" }o--|| "Audit" : "Audit_key"
    "Scored Response Fact" }o--|| "Scored Response Grading Set Option" : "GradingSetOption_key"
    "Scored Response Fact" }o--|| "Scored Response" : "AuditScoredResponse_key"
```

## Audits - Score Section

```mermaid
---
config:
  theme: neutral
  er:
    useMaxWidth: false
---
erDiagram
    "Audit" {
        attr Reference
        attr AuditReference
        attr InspectedOn
        agg Score
        agg PotentialScore
        attr AverageScore
        attr AveragePotentialScore
        attr PercentageScore
        agg Flags
        attr ExternalIdentifier
        calc ConductedBy
        calc ScoreDisplay
        calc AuditCount
        attr PlannedStatusDate
        attr ReportInProgressStatusDate
        attr ReadyForReviewStatusDate
        attr CompleteStatusDate
        attr ClosedStatusDate
    }
    "Score Section Fact" {
        agg Score
        agg PotentialScore
        attr AverageScore
        attr AveragePotentialScore
        attr PercentageScore
        agg Flags
        calc ScoreSectionCount
        calc ScoreDisplay
    }
    "Score Section Grading Set Option" {
        attr ScoreSectionGradingSet
        attr ScoreSectionGrading
        attr ScoreSectionGradingValue
        attr ScoreSectionGradingColour
        attr ScoreSectionGradingSetIsPercentage
        attr ScoreSectionGradingSetIsScore
    }
    "Score Section" {
        attr Section
        attr DisplayScore
    }
    "Score Section Fact" }o--|| "Audit" : "Audit_key"
    "Score Section Fact" }o--|| "Score Section Grading Set Option" : "GradingSetOption_key"
    "Score Section Fact" }o--|| "Score Section" : "AuditScoreSection_key"
```

## Audits - Score Tag

```mermaid
---
config:
  theme: neutral
  er:
    useMaxWidth: false
---
erDiagram
    "Audit" {
        attr Reference
        attr AuditReference
        attr InspectedOn
        agg Score
        agg PotentialScore
        attr AverageScore
        attr AveragePotentialScore
        attr PercentageScore
        agg Flags
        attr ExternalIdentifier
        calc ConductedBy
        calc ScoreDisplay
        calc AuditCount
        attr PlannedStatusDate
        attr ReportInProgressStatusDate
        attr ReadyForReviewStatusDate
        attr CompleteStatusDate
        attr ClosedStatusDate
    }
    "Score Tag Fact" {
        agg Score
        agg PotentialScore
        attr AverageScore
        attr AveragePotentialScore
        attr PercentageScore
        agg Flags
        calc ScoreTagCount
        calc ScoreDisplay
    }
    "Score Tag" {
        attr Tag
    }
    "Score Tag Grading Set Option" {
        attr ScoreTagGradingSet
        attr ScoreTagGrading
        attr ScoreTagGradingValue
        attr ScoreTagGradingColour
        attr ScoreTagGradingSetIsPercentage
        attr ScoreTagGradingSetIsScore
    }
    "Score Tag Fact" }o--|| "Score Tag" : "AuditScoreTag_key"
    "Score Tag Fact" }o--|| "Audit" : "Audit_key"
    "Score Tag Fact" }o--|| "Score Tag Grading Set Option" : "GradingSetOption_key"
```

## Audits - Numeric Answer

```mermaid
---
config:
  theme: neutral
  er:
    useMaxWidth: false
---
erDiagram
    "Audit" {
        attr Reference
        attr AuditReference
        attr InspectedOn
        agg Score
        agg PotentialScore
        attr AverageScore
        attr AveragePotentialScore
        attr PercentageScore
        agg Flags
        attr ExternalIdentifier
        calc ConductedBy
        calc ScoreDisplay
        calc AuditCount
        attr PlannedStatusDate
        attr ReportInProgressStatusDate
        attr ReadyForReviewStatusDate
        attr CompleteStatusDate
        attr ClosedStatusDate
    }
    "Numeric Answer Fact" {
        agg NumericAnswer
        calc NumericAnswerCount
    }
    "Numeric Question" {
        attr NumericQuestion
        attr Mandatory
        attr Scale
        calc Unit
        calc UnitAcronym
        attr Section
        calc Question
    }
    "Unit" {
    }
    "Numeric Question" }o--|| "Unit" : "Unit_key"
    "Numeric Answer Fact" }o--|| "Audit" : "Audit_key"
    "Numeric Answer Fact" }o--|| "Numeric Question" : "AuditNumericQuestion_key"
```

## Audits - Date Time Answer

```mermaid
---
config:
  theme: neutral
  er:
    useMaxWidth: false
---
erDiagram
    "Audit" {
        attr Reference
        attr AuditReference
        attr InspectedOn
        agg Score
        agg PotentialScore
        attr AverageScore
        attr AveragePotentialScore
        attr PercentageScore
        agg Flags
        attr ExternalIdentifier
        calc ConductedBy
        calc ScoreDisplay
        calc AuditCount
        attr PlannedStatusDate
        attr ReportInProgressStatusDate
        attr ReadyForReviewStatusDate
        attr CompleteStatusDate
        attr ClosedStatusDate
    }
    "Date Time Answer Fact" {
        attr DateandTimeAnswer
        attr DateAnswer
        attr TimeAnswer
        calc DateTimeAnswerCount
    }
    "Date Time Question" {
        attr DateTimeQuestion
        attr Mandatory
        attr Date
        attr Time
        attr Section
        calc Question
    }
    "Date Time Answer Fact" }o--|| "Date Time Question" : "AuditDateTimeQuestion_key"
    "Date Time Answer Fact" }o--|| "Audit" : "Audit_key"
```

## Audits - Checklist Answer

```mermaid
---
config:
  theme: neutral
  er:
    useMaxWidth: false
---
erDiagram
    "Audit" {
        attr Reference
        attr AuditReference
        attr InspectedOn
        agg Score
        agg PotentialScore
        attr AverageScore
        attr AveragePotentialScore
        attr PercentageScore
        agg Flags
        attr ExternalIdentifier
        calc ConductedBy
        calc ScoreDisplay
        calc AuditCount
        attr PlannedStatusDate
        attr ReportInProgressStatusDate
        attr ReadyForReviewStatusDate
        attr CompleteStatusDate
        attr ClosedStatusDate
    }
    "Checklist Answer Fact" {
        calc ChecklistAnswerCount
    }
    "Checklist Option" {
        attr ChecklistQuestion
        attr ChecklistAnswer
        attr Mandatory
        calc Answer
        attr Section
        calc Question
    }
    "Checklist Answer Fact" }o--|| "Audit" : "Audit_key"
    "Checklist Answer Fact" }o--|| "Checklist Option" : "AuditChecklistOption_key"
```

## Audits - Branch Option

```mermaid
---
config:
  theme: neutral
  er:
    useMaxWidth: false
---
erDiagram
    "Audit" {
        attr Reference
        attr AuditReference
        attr InspectedOn
        agg Score
        agg PotentialScore
        attr AverageScore
        attr AveragePotentialScore
        attr PercentageScore
        agg Flags
        attr ExternalIdentifier
        calc ConductedBy
        calc ScoreDisplay
        calc AuditCount
        attr PlannedStatusDate
        attr ReportInProgressStatusDate
        attr ReadyForReviewStatusDate
        attr CompleteStatusDate
        attr ClosedStatusDate
    }
    "Branch Option Fact" {
        calc BranchOptionCount
    }
    "Branch Option" {
        attr Branch
        attr BranchOption
        calc Option
        attr Section
        calc Question
    }
    "Branch Option Fact" }o--|| "Audit" : "Audit_key"
    "Branch Option Fact" }o--|| "Branch Option" : "AuditBranchOption_key"
```
