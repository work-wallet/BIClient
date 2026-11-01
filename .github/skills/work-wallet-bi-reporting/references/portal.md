# Work Wallet Portal: Matching Figures and Deep Links

## Match the portal's figures

Users compare report figures with what they see in Work Wallet, so the reports should agree with the portal.

- **Mirror the portal's defaults.** For example, the portal's Assets page shows Active assets by default. Check the portal page for the module and mirror its default with an editable report-level filter on the status name (`pbir.set_report_filter_in`), and say on the page when it hides records.
- **Compare the headline figures** with the report's KPIs. If they already agree, no default filter is needed. Use the portal's wording for those tiles so the two read the same.
- The portal's "last 12 months" matches a "Last 12 months" relative date slicer on the record's main date.

How the portal defines its tiles:

| Module | Portal tile | Definition |
| --- | --- | --- |
| Actions | Open actions | Status Open or In Progress, raised in the last 12 months, not deleted |
| Actions | Overdue actions | Open, and the due date and time has passed (an action due today is overdue) |
| Actions | Average close out days | Average days from raised to closed, for closed actions raised in the last 12 months |
| Assets | (asset list) | Active assets by default |
| PPE | Available stock, Assigned PPE, Require replacement | Items in stock; items currently issued (status Assigned); issued items past the end of their lifespan or with a replacement requested |
| Safety Cards | Total safety cards, Red cards | Active cards reported in the last 12 months |
| Safety Cards | Assigned categories | Distinct categories on those cards |
| Inductions | Enrolled individuals | Each person's latest attempt at each induction, across all induction statuses |
| Inductions | Valid inductions % | Latest attempts that are valid and not expiring within 30 days, divided by enrolled individuals |

## Deep links to the portal

Link each record a report lists to its page in the portal: a "Link" column in tables, and an "Open in Work Wallet" button on the record's drillthrough page.

- **Model**: a `Url` calculated column with `dataCategory: WebUrl` on the record's table (`tmdl.portal_url_column`).
- **Host**: `https://portal.work-wallet.com` for every region.
- **No wallet id**: URLs carry no wallet id, so the portal opens them in the user's selected wallet. Users who belong to several wallets must select the right one first.
- **Wrap ids in `LOWER()`.** The ids in the data are upper case. Paths ignore case, but a `#fragment` must match the portal's lower-case element id exactly.
- **Return blank for deleted records** (by status code or flag), which the portal can't show.
- **Detail pages**: the button's URL comes from a hidden `<Record> Link` measure, `SELECTEDVALUE ( Record[Url] )` in display folder "Links" (`pbir.link_button`).

Paths, using ids from the extract:

| Record | Path |
| --- | --- |
| Asset | `/Company/Assets/{AssetId}/Detail` |
| Asset inspection | `/Company/Assets/{AssetId}/Detail/Inspections/{InspectionId}` |
| Audit | `/HealthAndSafety/Audit/{AuditId}` |
| Induction | `/Users/Inductions/Detail/{InductionId}` |
| Induction attempt | `/Users/Inductions/Detail/{InductionId}/ReviewInduction/{InductionTakenId}` |
| Permit | `/HealthAndSafety/PermitToWork/{PermitId}` |
| Reported issue | `/HealthAndSafety/IssueReporting/{ReportedIssueId}` |
| Safety card | `/Users/SafetyCardReporting/{SafetyCardId}/Detail` |

**Actions** have no page of their own. An action links to the record it was raised on (`TargetId`, by `ActionTypeCode`), scrolled to the action:

| Raised on | Path |
| --- | --- |
| Audit (1) | `/HealthAndSafety/Audit/{TargetId}?tab=actions#{ActionId}` |
| Issue (2) | `/HealthAndSafety/IssueReporting/{TargetId}?tab=actions#{ActionId}` |
| Safety card (4) | `/Users/SafetyCardReporting/{TargetId}/Detail#{ActionId}` |
| Asset (8) | `/Company/Assets/{TargetId}/Detail?tab=actions#{ActionId}` |
| Briefing (16) | `/Users/Briefings/{TargetId}/Detail?tab=actions#{ActionId}` |

Deleted and orphaned actions have no link; deleted actions may have no `TargetId`.
