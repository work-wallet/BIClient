# Reported Issues

[<- Back to index](../PowerBISamplesModels.md)

## Reported Issues - Main

```mermaid
---
config:
  theme: neutral
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
        calc InvestigationStartedOn
        calc ClosedOn
        calc HoursToReport
        calc DaysToStartInvestigation
        calc DaysToClose
        calc AgeBand
        calc Url
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
        calc CompanyName
        calc SiteName
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
    "Issue" }o..|| "Contact" : "LeadInvestigatorContact_key"
```

## Reported Issues - Body Part

```mermaid
---
config:
  theme: neutral
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
        calc InvestigationStartedOn
        calc ClosedOn
        calc HoursToReport
        calc DaysToStartInvestigation
        calc DaysToClose
        calc AgeBand
        calc Url
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
        calc InvestigationStartedOn
        calc ClosedOn
        calc HoursToReport
        calc DaysToStartInvestigation
        calc DaysToClose
        calc AgeBand
        calc Url
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
        calc InvestigationStartedOn
        calc ClosedOn
        calc HoursToReport
        calc DaysToStartInvestigation
        calc DaysToClose
        calc AgeBand
        calc Url
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
        calc InvestigationStartedOn
        calc ClosedOn
        calc HoursToReport
        calc DaysToStartInvestigation
        calc DaysToClose
        calc AgeBand
        calc Url
    }
    "Person Fact" {
        calc PersonCount
        attr Investigation
        calc WorkflowStage_Person_
        attr EnteredFirstName
        attr EnteredLastName
        attr EnteredEmail
        calc Name
        calc Email
    }
    "Person" {
        attr PersonQuestion
        attr Person
    }
    "Person Option Type" {
        attr PersonOptionType
    }
    "Person Contact" {
        attr ContactName
        attr Email
        attr Company
    }
    "Person Fact" }o--|| "Issue" : "ReportedIssue_key"
    "Person Fact" }o--|| "Person" : "ReportedIssuePerson_key"
    "Person Fact" }o--|| "Person Option Type" : "ReportedIssuePersonOptionType_key"
    "Person Fact" }o--|| "Person Contact" : "Contact_key"
```

## Reported Issues - Root Cause Analysis

```mermaid
---
config:
  theme: neutral
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
        calc InvestigationStartedOn
        calc ClosedOn
        calc HoursToReport
        calc DaysToStartInvestigation
        calc DaysToClose
        calc AgeBand
        calc Url
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
        calc InvestigationStartedOn
        calc ClosedOn
        calc HoursToReport
        calc DaysToStartInvestigation
        calc DaysToClose
        calc AgeBand
        calc Url
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

## Reported Issues - Numeric Answer

```mermaid
---
config:
  theme: neutral
---
erDiagram
    "Numeric Answer Fact" {
        agg NumericAnswer
        calc WorkflowStage_NumericAnswer_
    }
    "Numeric Question" {
        attr Question
        attr Scale
        calc Unit
        calc UnitAcronym
    }
    "Issue" {
        attr IssueReference
        attr OccurredOn
        attr ReportedOn
        attr IssueOverview
        attr CloseDate
        calc IssueCount
        calc ReportedBy
        attr UnderInvestigationDate
        calc InvestigationStartedOn
        calc ClosedOn
        calc HoursToReport
        calc DaysToStartInvestigation
        calc DaysToClose
        calc AgeBand
        calc Url
    }
    "Unit" {
    }
    "Numeric Answer Fact" }o--|| "Numeric Question" : "ReportedIssueNumericQuestion_key"
    "Numeric Answer Fact" }o--|| "Issue" : "ReportedIssue_key"
    "Numeric Question" }o--|| "Unit" : "Unit_key"
```

## Reported Issues - Date Time Answer

```mermaid
---
config:
  theme: neutral
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
        calc InvestigationStartedOn
        calc ClosedOn
        calc HoursToReport
        calc DaysToStartInvestigation
        calc DaysToClose
        calc AgeBand
        calc Url
    }
    "Date Time Question" {
        attr Question
        attr Date
        attr Time
    }
    "Date Time Answer Fact" {
        attr DateandTimeAnswer
        attr DateAnswer
        attr TimeAnswer
        calc WorkflowStage_DateTimeAnswer_
        calc DateTimeAnswerCount
    }
    "Date Time Answer Fact" }o--|| "Date Time Question" : "ReportedIssueDateTimeQuestion_key"
    "Date Time Answer Fact" }o--|| "Issue" : "ReportedIssue_key"
```

## Reported Issues - Signature

```mermaid
---
config:
  theme: neutral
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
        calc InvestigationStartedOn
        calc ClosedOn
        calc HoursToReport
        calc DaysToStartInvestigation
        calc DaysToClose
        calc AgeBand
        calc Url
    }
    "Signature Contact" {
        attr ContactName
        attr Email
        attr Company
    }
    "Signature Fact" {
        attr Investigation
        attr Name
        attr JobTitle
        attr SignatureDescription
        attr SignedOn
        calc WorkflowStage_Signature_
    }
    "Signature Person Option Type" {
        attr PersonOptionType
    }
    "Signature Fact" }o--|| "Issue" : "ReportedIssue_key"
    "Signature Fact" }o--|| "Signature Contact" : "Contact_key"
    "Signature Fact" }o--|| "Signature Person Option Type" : "ReportedIssuePersonOptionType_key"
```

## Reported Issues - Date and Measures

```mermaid
---
config:
  theme: neutral
---
erDiagram
    "Date" {
        attr Date
        calc Year
        calc Month
        calc MonthStart
        calc YearMonth
        calc SlicerDate
    }
    "Issue" {
        attr IssueReference
        attr OccurredOn
        attr ReportedOn
        attr IssueOverview
        attr CloseDate
        calc IssueCount
        calc ReportedBy
        attr UnderInvestigationDate
        calc InvestigationStartedOn
        calc ClosedOn
        calc HoursToReport
        calc DaysToStartInvestigation
        calc DaysToClose
        calc AgeBand
        calc Url
    }
    "Issue Measures" {
        measure Issues
        measure OpenIssues
        measure UnderInvestigation
        measure ClosedIssues
        measure ClosureRate
        measure SeriousIssues
        measure SeriousShare
        measure MonthlyAverageIssues
        measure MonthlyAverageLine
        measure MostCommonCategory
        measure LocationsWithIssues
        measure TopLocation
        measure MedianHoursToReport
        measure AverageDaysToStartInvestigation
        measure AverageDaysToClose
        measure OpenOver30Days
        measure SeriousAwaitingInvestigation
        measure IssuesWithRootCauseAnalysis
        measure RootCauseIssues
        measure ImmediateCauseIssues
        measure TopRootCause
        measure TopImmediateCause
        measure InjuryReports
        measure InjuredBodyParts
        measure SeriousInjuryReports
        measure MostAffectedBodyPart
        measure MostAffectedBodyArea
        measure PeopleRecorded
        measure IssuesWithPeople
        measure PeopleTypedInShare
        measure MostCommonPersonQuestion
        measure NumericAnswers
        measure NumericTotal
        measure NumericAverage
        measure NumericHighest
        measure IssuesWithNumericAnswers
        measure DateTimeAnswers
        measure AverageHoursAfterOccurrence
        measure Signatures
        measure Signed
        measure AwaitingSignature
        measure AverageDaysToSign
    }
    "Issue" }o--|| "Date" : "Occurred Date"
```

## Reported Issues - Actions

```mermaid
---
config:
  theme: neutral
---
erDiagram
    "Action Update" {
        attr Comments
        attr Deleted
        attr CreatedOn
        calc ActionUpdateStatus
    }
    "Action" {
        attr TargetReference
        attr Title
        attr Description
        attr Name
        attr Email
        attr CreatedOn
        calc DueDate
        calc ClosedOn
        calc DaysToClose
        calc ClosedOnTime
        calc DaysOverdue
        calc OverdueBand
        calc Assignee
        calc Url
    }
    "Action Status" {
        attr ActionStatus
    }
    "Action Priority" {
        attr ActionPriority
    }
    "Action Date" {
        attr Date
        calc Year
        calc Month
        calc MonthStart
        calc YearMonth
        calc SlicerDate
    }
    "Issue" {
        attr IssueReference
        attr OccurredOn
        attr ReportedOn
        attr IssueOverview
        attr CloseDate
        calc IssueCount
        calc ReportedBy
        attr UnderInvestigationDate
        calc InvestigationStartedOn
        calc ClosedOn
        calc HoursToReport
        calc DaysToStartInvestigation
        calc DaysToClose
        calc AgeBand
        calc Url
    }
    "Action Measures" {
        measure Actions
        measure OpenActions
        measure ClosedActions
        measure DraftActions
        measure OverdueActions
        measure SeriousOverdueActions
        measure SeriousOpenActions
        measure AverageDaysOverdue
        measure OldestOverdueDays
        measure ActionsWithoutDueDate
        measure IssueOpenActions
        measure Assignees
        measure MonthlyAverageActions
        measure MonthlyAverageActionsLine
        measure MostOverdueAssignee
        measure ActionsClosed
        measure ActionAverageDaysToClose
        measure ClosedOnTime
        measure ClosedWithDueDate
        measure OnTimeRate
        measure ActionClosureRate
        measure Updates
        measure ActionsWithUpdates
        measure AverageCloseOutDays
        measure IssuesWithActions
        measure IssuesWithOpenActions
    }
    "Action" }o--|| "Issue" : "ReportedIssue_key"
    "Action" }o--|| "Action Priority" : "ActionPriority_key"
    "Action" }o--|| "Action Status" : "ActionStatus_key"
    "Action Update" }o--|| "Action" : "Action_key"
    "Action Update" }o..|| "Action Status" : "ActionStatus_key"
    "Action" }o--|| "Action Date" : "Raised Date"
    "Action" }o..|| "Action Date" : "Closed Date"
```
