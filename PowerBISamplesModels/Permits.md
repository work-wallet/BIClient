# Permits

[<- Back to index](../PowerBISamplesModels.md)

## Permits - Main

```mermaid
---
config:
  theme: neutral
---
erDiagram
    "Permit" {
        attr PermitReference
        attr Permit
        attr IssuedToCompany
        attr IssuedOn
        attr IssuedForMinutes
        attr IssuedExpiry
        attr ClosedOn
        attr HasBeenExpired
        attr HasBeenClosed
        calc PermitCount
        attr HasBeenExtended
        calc Assignees
        calc Signatories
    }
    "Status" {
        attr Status
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
    "Category" {
        attr CategoryVersion
        attr Category
        attr Expiry
        attr ValidityPeriod
        attr ValidityPeriodMinutes
        attr IssueType
    }
    "Assignee Fact" {
    }
    "Contact" {
        attr ContactName
        attr Email
        attr Company
    }
    "Permit" }o--|| "Location" : "Location_key"
    "Permit" }o--|| "Category" : "PermitCategory_key"
    "Permit" }o--|| "Status" : "PermitStatus_key"
    "Assignee Fact" }o--|| "Contact" : "Contact_key"
    "Assignee Fact" }o--|| "Permit" : "Permit_key"
```

## Permits - Numeric Answer

```mermaid
---
config:
  theme: neutral
---
erDiagram
    "Numeric Answer Fact" {
        agg NumericAnswer
        calc NumericAnswerCount
    }
    "Numeric Question" {
        attr NumericQuestion
        attr Mandatory
        attr Scale
        attr SectionType
        attr Section
        calc Question
        calc Unit
        calc UnitAcronym
    }
    "Unit" {
    }
    "Permit" {
        attr PermitReference
        attr Permit
        attr IssuedToCompany
        attr IssuedOn
        attr IssuedForMinutes
        attr IssuedExpiry
        attr ClosedOn
        attr HasBeenExpired
        attr HasBeenClosed
        calc PermitCount
        attr HasBeenExtended
        calc Assignees
        calc Signatories
    }
    "Numeric Question" }o--|| "Unit" : "Unit_key"
    "Numeric Answer Fact" }o--|| "Permit" : "Permit_key"
    "Numeric Answer Fact" }o--|| "Numeric Question" : "PermitNumericQuestion_key"
```

## Permits - Date Time Answer

```mermaid
---
config:
  theme: neutral
---
erDiagram
    "Permit" {
        attr PermitReference
        attr Permit
        attr IssuedToCompany
        attr IssuedOn
        attr IssuedForMinutes
        attr IssuedExpiry
        attr ClosedOn
        attr HasBeenExpired
        attr HasBeenClosed
        calc PermitCount
        attr HasBeenExtended
        calc Assignees
        calc Signatories
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
        attr SectionType
        attr Section
        calc Question
    }
    "Date Time Answer Fact" }o--|| "Date Time Question" : "PermitDateTimeQuestion_key"
    "Date Time Answer Fact" }o--|| "Permit" : "Permit_key"
```

## Permits - Checklist Answer

```mermaid
---
config:
  theme: neutral
---
erDiagram
    "Permit" {
        attr PermitReference
        attr Permit
        attr IssuedToCompany
        attr IssuedOn
        attr IssuedForMinutes
        attr IssuedExpiry
        attr ClosedOn
        attr HasBeenExpired
        attr HasBeenClosed
        calc PermitCount
        attr HasBeenExtended
        calc Assignees
        calc Signatories
    }
    "Checklist Answer Fact" {
        calc ChecklistAnswerCount
    }
    "Checklist Option" {
        attr ChecklistQuestion
        attr ChecklistAnswer
        attr Mandatory
        attr SectionType
        attr Section
        calc Answer
        calc Question
    }
    "Checklist Answer Fact" }o--|| "Permit" : "Permit_key"
    "Checklist Answer Fact" }o--|| "Checklist Option" : "PermitChecklistOption_key"
```

## Permits - Branch Option

```mermaid
---
config:
  theme: neutral
---
erDiagram
    "Branch Option Fact" {
        calc BranchOptionCount
    }
    "Branch Option" {
        attr Branch
        attr BranchOption
        attr SectionType
        attr Section
        calc Option
        calc Question
    }
    "Permit" {
        attr PermitReference
        attr Permit
        attr IssuedToCompany
        attr IssuedOn
        attr IssuedForMinutes
        attr IssuedExpiry
        attr ClosedOn
        attr HasBeenExpired
        attr HasBeenClosed
        calc PermitCount
        attr HasBeenExtended
        calc Assignees
        calc Signatories
    }
    "Branch Option Fact" }o--|| "Branch Option" : "PermitBranchOption_key"
    "Branch Option Fact" }o--|| "Permit" : "Permit_key"
```

## Permits - Signed By

```mermaid
---
config:
  theme: neutral
---
erDiagram
    "Permit" {
        attr PermitReference
        attr Permit
        attr IssuedToCompany
        attr IssuedOn
        attr IssuedForMinutes
        attr IssuedExpiry
        attr ClosedOn
        attr HasBeenExpired
        attr HasBeenClosed
        calc PermitCount
        attr HasBeenExtended
        calc Assignees
        calc Signatories
    }
    "Signed By Contact" {
        attr ContactName
        attr Email
        attr Company
    }
    "Signature Fact" {
        attr SignedBy
        attr JobTitle
        attr SignedAt
        attr SignatureDescription
    }
    "Signature Fact" }o--|| "Permit" : "Permit_key"
    "Signature Fact" }o--|| "Signed By Contact" : "Contact_key"
```
