# Assets

[<- Back to index](../PowerBISamplesModels.md)

## Assets - Main

```mermaid
---
config:
  theme: neutral
  er:
    useMaxWidth: false
---
erDiagram
    "Asset" {
        attr AssetType
        attr Reference
        attr AssetName
        attr AssetNotes
        attr CreatedOn
        calc AssetCount
        calc Asset
        calc OpenDefects
        calc LatestAssignedTo
        calc LastInspectionDate
        calc DefectiveCount
        calc AssignedCount
        calc UnassignedCount
        calc Url
    }
    "Asset Status" {
        attr AssetStatus
    }
    "Asset" }o--|| "Asset Status" : "AssetStatus_key"
```

## Assets - Assignment

```mermaid
---
config:
  theme: neutral
  er:
    useMaxWidth: false
---
erDiagram
    "Asset" {
        attr AssetType
        attr Reference
        attr AssetName
        attr AssetNotes
        attr CreatedOn
        calc AssetCount
        calc Asset
        calc OpenDefects
        calc LatestAssignedTo
        calc LastInspectionDate
        calc DefectiveCount
        calc AssignedCount
        calc UnassignedCount
        calc Url
    }
    "Assignment Fact" {
        attr From
        attr IsLatest
        attr To
        calc Days
        attr AssignmentNumber
    }
    "Assignment Type" {
        attr AssignmentType
    }
    "Assignment" {
        attr AssignedTo
        attr Company
        attr Site
    }
    "Contact" {
        attr ContactName
        attr Email
        attr Company
    }
    "Assignment" }o--|| "Assignment Type" : "AssetAssignmentType_key"
    "Assignment Fact" }o--|| "Asset" : "Asset_key"
    "Assignment Fact" }o--|| "Assignment" : "AssetAssignment_key"
    "Assignment" }o--|| "Contact" : "Contact_key"
```

## Assets - Property

```mermaid
---
config:
  theme: neutral
  er:
    useMaxWidth: false
---
erDiagram
    "Asset" {
        attr AssetType
        attr Reference
        attr AssetName
        attr AssetNotes
        attr CreatedOn
        calc AssetCount
        calc Asset
        calc OpenDefects
        calc LatestAssignedTo
        calc LastInspectionDate
        calc DefectiveCount
        calc AssignedCount
        calc UnassignedCount
        calc Url
    }
    "Property Fact" {
        attr PropertyValue
    }
    "Property" {
        attr Property
        attr IsSharedProperty
    }
    "Property Type" {
        attr PropertyType
    }
    "Property" }o--|| "Property Type" : "AssetPropertyType_key"
    "Property Fact" }o--|| "Asset" : "Asset_key"
    "Property Fact" }o--|| "Property" : "AssetProperty_key"
```

## Assets - Inspection

```mermaid
---
config:
  theme: neutral
  er:
    useMaxWidth: false
---
erDiagram
    "Inspection" {
        calc InspectionCount
        calc DefectsRaised
        attr InspectedOn
        agg Score
        agg PotentialScore
        attr AverageScore
        attr AveragePotentialScore
        attr PercentageScore
        agg Defects
        attr Passed
        attr ExternalIdentifier
        attr InspectedByCompany
        attr InProgressStatusDate
        attr ReadyForReviewStatusDate
        attr CompleteStatusDate
        attr ArchivedStatusDate
        calc ScoreDisplay
        calc InspectedBy
        calc Url
    }
    "Asset" {
        attr AssetType
        attr Reference
        attr AssetName
        attr AssetNotes
        attr CreatedOn
        calc AssetCount
        calc Asset
        calc OpenDefects
        calc LatestAssignedTo
        calc LastInspectionDate
        calc DefectiveCount
        calc AssignedCount
        calc UnassignedCount
        calc Url
    }
    "Inspection Type" {
        attr InspectionType
        attr InspectionTypeDescription
        attr ScoringEnabled
        attr DisplayPercentage
        attr DisplayTotalScore
        attr DisplayAverageScore
        attr GradingSet
        attr GradingSetIsPercentage
        attr GradingSetIsScore
    }
    "Inspection Status" {
        attr InspectionStatus
    }
    "Inspection Grading Set Option" {
        attr InspectionGradingSet
        attr InspectionGrading
        attr InspectionGradingValue
        attr InspectionGradingColour
        attr InspectionGradingSetIsPercentage
        attr InspectionGradingSetIsScore
    }
    "Inspection" }o--|| "Asset" : "Asset_key"
    "Inspection" }o--|| "Inspection Status" : "AssetInspectionStatus_key"
    "Inspection" }o--|| "Inspection Type" : "AssetInspectionType_key"
    "Inspection" }o--|| "Inspection Grading Set Option" : "GradingSetOption_key"
```

## Assets - Observation

```mermaid
---
config:
  theme: neutral
  er:
    useMaxWidth: false
---
erDiagram
    "Asset" {
        attr AssetType
        attr Reference
        attr AssetName
        attr AssetNotes
        attr CreatedOn
        calc AssetCount
        calc Asset
        calc OpenDefects
        calc LatestAssignedTo
        calc LastInspectionDate
        calc DefectiveCount
        calc AssignedCount
        calc UnassignedCount
        calc Url
    }
    "Observation" {
        attr ObservedOn
        attr ClosedOn
        attr ClosureNotes
        calc ObservationCount
        calc OpenDefectCount
        calc ClosedDefectCount
        calc DefectCount
        attr Deleted
        calc ObservationNotes
        attr IsFinalised
        calc NewDefectCount
    }
    "Observation Status" {
        attr ObservationStatus
    }
    "Observation Note" {
        attr Notes
        attr CreatedOn
        attr EditedOn
        attr Deleted
    }
    "Contact" {
        attr ContactName
        attr Email
        attr Company
    }
    "Observation" }o--|| "Observation Status" : "AssetObservationStatus_key"
    "Observation" }o--|| "Asset" : "Asset_key"
    "Observation" }o..|| "Contact" : "ClosedByContact_key"
    "Observation" }o--|| "Contact" : "ObservedByContact_key"
    "Observation Note" }o..|| "Contact" : "CreatedByContact_key"
    "Observation Note" }o--|| "Observation" : "AssetObservation_key"
```

## Assets - Inspection Observation

```mermaid
---
config:
  theme: neutral
  er:
    useMaxWidth: false
---
erDiagram
    "Inspection Observation Fact" {
        attr New
        attr WorkflowComponent
        calc RecordedDefectCount
    }
    "Observation" {
        attr ObservedOn
        attr ClosedOn
        attr ClosureNotes
        calc ObservationCount
        calc OpenDefectCount
        calc ClosedDefectCount
        calc DefectCount
        attr Deleted
        calc ObservationNotes
        attr IsFinalised
        calc NewDefectCount
    }
    "Inspection" {
        calc InspectionCount
        calc DefectsRaised
        attr InspectedOn
        agg Score
        agg PotentialScore
        attr AverageScore
        attr AveragePotentialScore
        attr PercentageScore
        agg Defects
        attr Passed
        attr ExternalIdentifier
        attr InspectedByCompany
        attr InProgressStatusDate
        attr ReadyForReviewStatusDate
        attr CompleteStatusDate
        attr ArchivedStatusDate
        calc ScoreDisplay
        calc InspectedBy
        calc Url
    }
    "Inspection Workflow Component Type" {
        attr WorkflowComponentType
    }
    "Inspection Observation Fact" }o--|| "Inspection" : "AssetInspection_key"
    "Inspection Observation Fact" }o..|| "Observation" : "AssetObservation_key"
    "Inspection Observation Fact" }o--|| "Inspection Workflow Component Type" : "InspectionWorkflowComponentType_key"
```

## Assets - Inspected By

```mermaid
---
config:
  theme: neutral
  er:
    useMaxWidth: false
---
erDiagram
    "Inspection" {
        calc InspectionCount
        calc DefectsRaised
        attr InspectedOn
        agg Score
        agg PotentialScore
        attr AverageScore
        attr AveragePotentialScore
        attr PercentageScore
        agg Defects
        attr Passed
        attr ExternalIdentifier
        attr InspectedByCompany
        attr InProgressStatusDate
        attr ReadyForReviewStatusDate
        attr CompleteStatusDate
        attr ArchivedStatusDate
        calc ScoreDisplay
        calc InspectedBy
        calc Url
    }
    "Inspected By Fact" {
        calc InspectedByCount
    }
    "Contact" {
        attr ContactName
        attr Email
        attr Company
    }
    "Inspected By Fact" }o--|| "Contact" : "Contact_key"
    "Inspected By Fact" }o--|| "Inspection" : "AssetInspection_key"
```

## Assets - Scored Response

```mermaid
---
config:
  theme: neutral
  er:
    useMaxWidth: false
---
erDiagram
    "Inspection" {
        calc InspectionCount
        calc DefectsRaised
        attr InspectedOn
        agg Score
        agg PotentialScore
        attr AverageScore
        attr AveragePotentialScore
        attr PercentageScore
        agg Defects
        attr Passed
        attr ExternalIdentifier
        attr InspectedByCompany
        attr InProgressStatusDate
        attr ReadyForReviewStatusDate
        attr CompleteStatusDate
        attr ArchivedStatusDate
        calc ScoreDisplay
        calc InspectedBy
        calc Url
    }
    "Scored Response Fact" {
        agg Score
        agg PotentialScore
        attr PercentageScore
        attr Defect
        calc ScoreResponseCount
        calc ScoreDisplay
    }
    "Scored Response" {
        attr ScoredResponseQuestion
        attr ScoredResponseAnswer
        attr Section
        calc Question
        calc Response
    }
    "Scored Response Grading Set Option" {
        attr ScoredResponseGradingSet
        attr ScoredResponseGrading
        attr ScoredResponseGradingValue
        attr ScoredResponseGradingColour
        attr ScoredResponseGradingSetIsPercentage
        attr ScoredResponseGradingSetIsScore
    }
    "Scored Response Fact" }o--|| "Scored Response" : "AssetInspectionScoredResponse_key"
    "Scored Response Fact" }o--|| "Inspection" : "AssetInspection_key"
    "Scored Response Fact" }o--|| "Scored Response Grading Set Option" : "GradingSetOption_key"
```

## Assets - Score Section

```mermaid
---
config:
  theme: neutral
  er:
    useMaxWidth: false
---
erDiagram
    "Inspection" {
        calc InspectionCount
        calc DefectsRaised
        attr InspectedOn
        agg Score
        agg PotentialScore
        attr AverageScore
        attr AveragePotentialScore
        attr PercentageScore
        agg Defects
        attr Passed
        attr ExternalIdentifier
        attr InspectedByCompany
        attr InProgressStatusDate
        attr ReadyForReviewStatusDate
        attr CompleteStatusDate
        attr ArchivedStatusDate
        calc ScoreDisplay
        calc InspectedBy
        calc Url
    }
    "Score Section Fact" {
        agg Score
        agg PotentialScore
        attr AverageScore
        attr AveragePotentialScore
        attr PercentageScore
        agg Defects
        attr Passed
        calc ScoreSectionCount
        calc ScoreDisplay
    }
    "Score Section" {
        attr Section
        attr DisplayScore
        calc ScoreSectionCount
    }
    "Score Section Grading Set Option" {
        attr ScoreSectionGradingSet
        attr ScoreSectionGrading
        attr ScoreSectionGradingValue
        attr ScoreSectionGradingColour
        attr ScoreSectionGradingSetIsPercentage
        attr ScoreSectionGradingSetIsScore
    }
    "Score Section Fact" }o--|| "Score Section" : "AssetInspectionScoreSection_key"
    "Score Section Fact" }o--|| "Score Section Grading Set Option" : "GradingSetOption_key"
    "Score Section Fact" }o--|| "Inspection" : "AssetInspection_key"
```

## Assets - Score Tag

```mermaid
---
config:
  theme: neutral
  er:
    useMaxWidth: false
---
erDiagram
    "Inspection" {
        calc InspectionCount
        calc DefectsRaised
        attr InspectedOn
        agg Score
        agg PotentialScore
        attr AverageScore
        attr AveragePotentialScore
        attr PercentageScore
        agg Defects
        attr Passed
        attr ExternalIdentifier
        attr InspectedByCompany
        attr InProgressStatusDate
        attr ReadyForReviewStatusDate
        attr CompleteStatusDate
        attr ArchivedStatusDate
        calc ScoreDisplay
        calc InspectedBy
        calc Url
    }
    "Score Tag Fact" {
        agg Score
        agg PotentialScore
        attr AverageScore
        attr AveragePotentialScore
        attr PercentageScore
        agg Defects
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
    "Score Tag Fact" }o--|| "Score Tag" : "AssetInspectionScoreTag_key"
    "Score Tag Fact" }o--|| "Inspection" : "AssetInspection_key"
    "Score Tag Fact" }o--|| "Score Tag Grading Set Option" : "GradingSetOption_key"
```

## Assets - Numeric Answer

```mermaid
---
config:
  theme: neutral
  er:
    useMaxWidth: false
---
erDiagram
    "Inspection" {
        calc InspectionCount
        calc DefectsRaised
        attr InspectedOn
        agg Score
        agg PotentialScore
        attr AverageScore
        attr AveragePotentialScore
        attr PercentageScore
        agg Defects
        attr Passed
        attr ExternalIdentifier
        attr InspectedByCompany
        attr InProgressStatusDate
        attr ReadyForReviewStatusDate
        attr CompleteStatusDate
        attr ArchivedStatusDate
        calc ScoreDisplay
        calc InspectedBy
        calc Url
    }
    "Numeric Answer Fact" {
        agg NumericAnswer
        calc NumericAnswerCount
    }
    "Numeric Question" {
        attr NumericQuestion
        attr Mandatory
        attr Scale
        attr Section
        calc Question
        calc Unit
        calc UnitAcronym
    }
    "Unit" {
    }
    "Numeric Answer Fact" }o--|| "Numeric Question" : "AssetInspectionNumericQuestion_key"
    "Numeric Answer Fact" }o--|| "Inspection" : "AssetInspection_key"
    "Numeric Question" }o--|| "Unit" : "Unit_key"
```

## Assets - Date Time Answer

```mermaid
---
config:
  theme: neutral
  er:
    useMaxWidth: false
---
erDiagram
    "Inspection" {
        calc InspectionCount
        calc DefectsRaised
        attr InspectedOn
        agg Score
        agg PotentialScore
        attr AverageScore
        attr AveragePotentialScore
        attr PercentageScore
        agg Defects
        attr Passed
        attr ExternalIdentifier
        attr InspectedByCompany
        attr InProgressStatusDate
        attr ReadyForReviewStatusDate
        attr CompleteStatusDate
        attr ArchivedStatusDate
        calc ScoreDisplay
        calc InspectedBy
        calc Url
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
    "Date Time Answer Fact" }o--|| "Date Time Question" : "AssetInspectionDateTimeQuestion_key"
    "Date Time Answer Fact" }o--|| "Inspection" : "AssetInspection_key"
```

## Assets - Checklist Answer

```mermaid
---
config:
  theme: neutral
  er:
    useMaxWidth: false
---
erDiagram
    "Inspection" {
        calc InspectionCount
        calc DefectsRaised
        attr InspectedOn
        agg Score
        agg PotentialScore
        attr AverageScore
        attr AveragePotentialScore
        attr PercentageScore
        agg Defects
        attr Passed
        attr ExternalIdentifier
        attr InspectedByCompany
        attr InProgressStatusDate
        attr ReadyForReviewStatusDate
        attr CompleteStatusDate
        attr ArchivedStatusDate
        calc ScoreDisplay
        calc InspectedBy
        calc Url
    }
    "Checklist Answer Fact" {
        calc ChecklistAnswerCount
    }
    "Checklist Option" {
        attr ChecklistQuestion
        attr ChecklistAnswer
        attr Mandatory
        attr Section
        calc Question
        calc Answer
    }
    "Checklist Answer Fact" }o--|| "Checklist Option" : "AssetInspectionChecklistOption_key"
    "Checklist Answer Fact" }o--|| "Inspection" : "AssetInspection_key"
```

## Assets - Branch Option

```mermaid
---
config:
  theme: neutral
  er:
    useMaxWidth: false
---
erDiagram
    "Inspection" {
        calc InspectionCount
        calc DefectsRaised
        attr InspectedOn
        agg Score
        agg PotentialScore
        attr AverageScore
        attr AveragePotentialScore
        attr PercentageScore
        agg Defects
        attr Passed
        attr ExternalIdentifier
        attr InspectedByCompany
        attr InProgressStatusDate
        attr ReadyForReviewStatusDate
        attr CompleteStatusDate
        attr ArchivedStatusDate
        calc ScoreDisplay
        calc InspectedBy
        calc Url
    }
    "Branch Option Fact" {
        calc BranchOptionCount
    }
    "Branch Option" {
        attr Branch
        attr BranchOption
        attr Section
        calc Option
        calc Question
    }
    "Branch Option Fact" }o--|| "Branch Option" : "AssetInspectionBranchOption_key"
    "Branch Option Fact" }o--|| "Inspection" : "AssetInspection_key"
```
