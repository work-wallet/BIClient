# Power BI Samples - Semantic Models

For convenience, entity-relationship diagrams for the Power BI semantic models used in the
sample reports are presented here. They give a sense of what data is available in each
semantic model and how the tables relate, without installing Power BI Desktop or having a
Power BI licence.

Each diagram corresponds to one page of the Power BI Desktop model view for that semantic
model (the built-in "All tables" page is skipped, since it is overwhelming). The Wallet
dimension table is omitted from every diagram for clarity. Dashed lines indicate an
inactive relationship. Each column is prefixed with its kind instead of its data type:

| Prefix | Meaning |
| --- | --- |
| `attr` | Plain source column |
| `calc` | DAX calculated column |
| `measure` | DAX measure |
| `agg` | Source column with a non-default implicit aggregation (e.g. sum) |

## Actions

[Actions diagrams](PowerBISamplesModels/Actions.md)

* [Actions - Main](PowerBISamplesModels/Actions.md#actions---main)

## Assets

[Assets diagrams](PowerBISamplesModels/Assets.md)

* [Assets - Main](PowerBISamplesModels/Assets.md#assets---main)
* [Assets - Assignment](PowerBISamplesModels/Assets.md#assets---assignment)
* [Assets - Property](PowerBISamplesModels/Assets.md#assets---property)
* [Assets - Inspection](PowerBISamplesModels/Assets.md#assets---inspection)
* [Assets - Observation](PowerBISamplesModels/Assets.md#assets---observation)
* [Assets - Inspection Observation](PowerBISamplesModels/Assets.md#assets---inspection-observation)
* [Assets - Inspected By](PowerBISamplesModels/Assets.md#assets---inspected-by)
* [Assets - Scored Response](PowerBISamplesModels/Assets.md#assets---scored-response)
* [Assets - Score Section](PowerBISamplesModels/Assets.md#assets---score-section)
* [Assets - Score Tag](PowerBISamplesModels/Assets.md#assets---score-tag)
* [Assets - Numeric Answer](PowerBISamplesModels/Assets.md#assets---numeric-answer)
* [Assets - Date Time Answer](PowerBISamplesModels/Assets.md#assets---date-time-answer)
* [Assets - Checklist Answer](PowerBISamplesModels/Assets.md#assets---checklist-answer)
* [Assets - Branch Option](PowerBISamplesModels/Assets.md#assets---branch-option)

## Audits

[Audits diagrams](PowerBISamplesModels/Audits.md)

* [Audits - Main](PowerBISamplesModels/Audits.md#audits---main)
* [Audits - Inspected By](PowerBISamplesModels/Audits.md#audits---inspected-by)
* [Audits - Scored Response](PowerBISamplesModels/Audits.md#audits---scored-response)
* [Audits - Score Section](PowerBISamplesModels/Audits.md#audits---score-section)
* [Audits - Score Tag](PowerBISamplesModels/Audits.md#audits---score-tag)
* [Audits - Numeric Answer](PowerBISamplesModels/Audits.md#audits---numeric-answer)
* [Audits - Date Time Answer](PowerBISamplesModels/Audits.md#audits---date-time-answer)
* [Audits - Checklist Answer](PowerBISamplesModels/Audits.md#audits---checklist-answer)
* [Audits - Branch Option](PowerBISamplesModels/Audits.md#audits---branch-option)

## Inductions

[Inductions diagrams](PowerBISamplesModels/Inductions.md)

* [Inductions - Main](PowerBISamplesModels/Inductions.md#inductions---main)

## PPE

[PPE diagrams](PowerBISamplesModels/PPE.md)

* [PPE - Stock](PowerBISamplesModels/PPE.md#ppe---stock)
* [PPE - Stock History](PowerBISamplesModels/PPE.md#ppe---stock-history)
* [PPE - Assignments](PowerBISamplesModels/PPE.md#ppe---assignments)
* [PPE - Properties](PowerBISamplesModels/PPE.md#ppe---properties)

## Permits

[Permits diagrams](PowerBISamplesModels/Permits.md)

* [Permits - Main](PowerBISamplesModels/Permits.md#permits---main)
* [Permits - Numeric Answer](PowerBISamplesModels/Permits.md#permits---numeric-answer)
* [Permits - Date Time Answer](PowerBISamplesModels/Permits.md#permits---date-time-answer)
* [Permits - Checklist Answer](PowerBISamplesModels/Permits.md#permits---checklist-answer)
* [Permits - Branch Option](PowerBISamplesModels/Permits.md#permits---branch-option)
* [Permits - Signed By](PowerBISamplesModels/Permits.md#permits---signed-by)

## Reported Issues

[Reported Issues diagrams](PowerBISamplesModels/ReportedIssues.md)

* [Reported Issues - Main](PowerBISamplesModels/ReportedIssues.md#reported-issues---main)
* [Reported Issues - Body Part](PowerBISamplesModels/ReportedIssues.md#reported-issues---body-part)
* [Reported Issues - Branch Option](PowerBISamplesModels/ReportedIssues.md#reported-issues---branch-option)
* [Reported Issues - Option Select](PowerBISamplesModels/ReportedIssues.md#reported-issues---option-select)
* [Reported Issues - Person](PowerBISamplesModels/ReportedIssues.md#reported-issues---person)
* [Reported Issues - Root Cause Analysis](PowerBISamplesModels/ReportedIssues.md#reported-issues---root-cause-analysis)
* [Reported Issues - Investigation Team](PowerBISamplesModels/ReportedIssues.md#reported-issues---investigation-team)

## Safety Cards

[Safety Cards diagrams](PowerBISamplesModels/SafetyCards.md)

* [Safety Cards - Main](PowerBISamplesModels/SafetyCards.md#safety-cards---main)

## For Maintainers

This file and the linked pages under `PowerBISamplesModels/` are auto-generated - do not
edit them by hand. Update the relevant `.SemanticModel` project(s) in Power BI Desktop
(including adding/arranging diagram pages), then regenerate the docs by running:

```powershell
dotnet run --project Tools/WorkWallet.BI.PowerBIModelDocGenerator/WorkWallet.BI.PowerBIModelDocGenerator.csproj
```

To check whether the docs are stale without regenerating them (for example, before
opening a pull request), add `-- --check`. This is also what the GitHub ruleset's CI
check (`.github/workflows/ci.yml`) runs on every push/PR, failing if the docs are out of
date:

```powershell
dotnet run --project Tools/WorkWallet.BI.PowerBIModelDocGenerator/WorkWallet.BI.PowerBIModelDocGenerator.csproj -- --check
```
