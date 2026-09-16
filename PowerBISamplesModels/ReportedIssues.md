# Reported Issues

[<- Back to index](../PowerBISamplesModels.md)

## Reported Issues - Main

```mermaid
---
config:
  theme: neutral
  er:
    useMaxWidth: false
---
erDiagram
    "Issue" {
        attr IssueReference
        attr OccurredOn
        attr ReportedOn
        attr IssueOverview
        attr CloseDate
        calc IssueCount
        calc ReportedBy
        attr UnderInvestigationDate
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
    "Severity" {
        attr Severity
    }
    "Status" {
        attr Status
    }
    "Category" {
        attr Category
        attr CategoryDescription
        attr Subcategory
        attr SubcategoryDescription
    }
    "Contact" {
        attr ContactName
        attr Email
        attr Company
    }
    "Issue" }o--|| "Location" : "Location_key"
    "Issue" }o--|| "Category" : "ReportedIssueCategory_key"
    "Issue" }o--|| "Severity" : "ReportedIssueSeverity_key"
    "Issue" }o--|| "Status" : "ReportedIssueStatus_key"
    "Issue" }o--|| "Contact" : "ReportedByContact_key"
```

## Reported Issues - Body Part

```mermaid
---
config:
  theme: neutral
  er:
    useMaxWidth: false
---
erDiagram
    "Issue" {
        attr IssueReference
        attr OccurredOn
        attr ReportedOn
        attr IssueOverview
        attr CloseDate
        calc IssueCount
        calc ReportedBy
        attr UnderInvestigationDate
    }
    "Body Part Fact" {
        calc BodyPartCount
        calc WorkflowStage_BodyPart_
    }
    "Body Part" {
        attr BodyPartQuestion
    }
    "Body Part Enum" {
        attr BodyPartGroup
        attr BodyPart
    }
    "Body Part" }o--|| "Body Part Enum" : "ReportedIssueBodyPartEnum_key"
    "Body Part Fact" }o--|| "Issue" : "ReportedIssue_key"
    "Body Part Fact" }o--|| "Body Part" : "ReportedIssueBodyPart_key"
```

## Reported Issues - Branch Option

```mermaid
---
config:
  theme: neutral
  er:
    useMaxWidth: false
---
erDiagram
    "Issue" {
        attr IssueReference
        attr OccurredOn
        attr ReportedOn
        attr IssueOverview
        attr CloseDate
        calc IssueCount
        calc ReportedBy
        attr UnderInvestigationDate
    }
    "Branch Option Fact" {
        calc BranchOptionCount
        calc WorkflowStage_BranchOption_
    }
    "Branch Option" {
        attr Branch
        attr BranchOption
    }
    "Branch Option Fact" }o--|| "Branch Option" : "ReportedIssueBranchOption_key"
    "Branch Option Fact" }o--|| "Issue" : "ReportedIssue_key"
```

## Reported Issues - Option Select

```mermaid
---
config:
  theme: neutral
  er:
    useMaxWidth: false
---
erDiagram
    "Issue" {
        attr IssueReference
        attr OccurredOn
        attr ReportedOn
        attr IssueOverview
        attr CloseDate
        calc IssueCount
        calc ReportedBy
        attr UnderInvestigationDate
    }
    "Option Select Fact" {
        calc OptionSelectCount
        attr Investigation
        calc WorkflowStage_OptionSelect_
    }
    "Option Select" {
        attr OptionQuestion
        attr Option
    }
    "Option Select Fact" }o--|| "Issue" : "ReportedIssue_key"
    "Option Select Fact" }o--|| "Option Select" : "ReportedIssueOptionSelect_key"
```

## Reported Issues - Person

```mermaid
---
config:
  theme: neutral
  er:
    useMaxWidth: false
---
erDiagram
    "Issue" {
        attr IssueReference
        attr OccurredOn
        attr ReportedOn
        attr IssueOverview
        attr CloseDate
        calc IssueCount
        calc ReportedBy
        attr UnderInvestigationDate
    }
    "Person Fact" {
        calc PersonCount
        attr Investigation
        calc WorkflowStage_Person_
    }
    "Person" {
        attr PersonQuestion
        attr Person
    }
    "Person Fact" }o--|| "Issue" : "ReportedIssue_key"
    "Person Fact" }o--|| "Person" : "ReportedIssuePerson_key"
```

## Reported Issues - Root Cause Analysis

```mermaid
---
config:
  theme: neutral
  er:
    useMaxWidth: false
---
erDiagram
    "Issue" {
        attr IssueReference
        attr OccurredOn
        attr ReportedOn
        attr IssueOverview
        attr CloseDate
        calc IssueCount
        calc ReportedBy
        attr UnderInvestigationDate
    }
    "Root Cause Analysis Fact" {
        attr RootCauseAnalysis
        attr RootCauseAnalysisDescription
    }
    "Root Cause Analysis Type" {
        attr RootCauseAnalysisType
    }
    "Root Cause Analysis Fact" }o--|| "Issue" : "ReportedIssue_key"
    "Root Cause Analysis Fact" }o--|| "Root Cause Analysis Type" : "ReportedIssueRootCauseAnalysisType_key"
```

## Reported Issues - Investigation Team

```mermaid
---
config:
  theme: neutral
  er:
    useMaxWidth: false
---
erDiagram
    "Issue" {
        attr IssueReference
        attr OccurredOn
        attr ReportedOn
        attr IssueOverview
        attr CloseDate
        calc IssueCount
        calc ReportedBy
        attr UnderInvestigationDate
    }
    "Investigation Team Fact" {
    }
    "Investigation Team Contact" {
        attr ContactName
        attr Email
        attr Company
    }
    "Lead Investigator Contact" {
        attr ContactName
        attr Email
        attr Company
    }
    "Investigation Team Fact" }o--|| "Issue" : "ReportedIssue_key"
    "Investigation Team Fact" }o--|| "Investigation Team Contact" : "Contact_key"
    "Issue" }o--|| "Lead Investigator Contact" : "LeadInvestigatorContact_key"
```
