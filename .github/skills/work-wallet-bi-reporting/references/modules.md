# Work Wallet Module Behaviour

Product behaviour that affects how a report should count or judge records. Status and type codes are in `ReferenceData.md`; check them against the data, because they don't always match.

## Actions

- Statuses: Draft 0, Open 1, In Progress 2, Closed 4. There is no code 3, so test for 4, not "anything else".
- **Open** is status 1 or 2. **Overdue** is open with a due date and time that has passed (an action due today is overdue).
- There is no closed-date field. The best source is the latest update that closed the action. Actions closed without an update have no close date, so time-to-close and on-time measures leave them out; say so on the page.
- An action belongs to the record it was raised on (`TargetId`, by `ActionTypeCode`: audit, issue, safety card, asset, briefing).
- Exclude deleted (`Is Deleted`) and orphaned (`Is Orphaned`, the parent record is gone) actions.
- **In a module's report** (the Audits, ReportedIssues, SafetyCards and Assets samples have an `Action` table), relate actions to the record by `TargetId` = the record's id (e.g. `AuditId`) and wallet, not by `TargetReference`: references can repeat. Older actions can point at records the module's extract doesn't hold (e.g. audits and safety cards from before the current module), so they have no record. Report-level filters on the record (e.g. Active safety cards or assets) also filter its actions.

## Assets

- The portal's asset list shows Active assets by default.
- Inspections are similar to audits (scored, graded questions). Defects (observations) have their own statuses, plus `Deleted` and `IsFinalised` (draft) flags; exclude deleted and unfinalised defects.

## Audits

- Scores, potentials and percentages use `-1` for "not scored"; exclude them (`>= 0`) from sums and averages.
- Grading sets define each wallet's grades and colours. Use the wallet's grading colours rather than fixed score thresholds.
- Planned audits can be future-dated.

## Inductions

- A person's current status at an induction comes from their **latest attempt**, by taken date, ignoring Deleted (9) attempts.
- An induction's versions share its `InductionId`. Names aren't unique across inductions, so group attempts by `InductionId`, not by name.
- **Expiry** is the taken date plus the induction's `ValidForDays`, compared with today (UTC). **Expiring soon** means within 30 days.
- Passed (1), Completed (2) and the "expiring soon" codes (4, 5) are successful. Expired (6) is a successful attempt whose validity has run out. Failed (3) and Rejected (8) are not passed: they never show as expiring soon, and Rejected never shows as expired.
- Only an in-date passed or completed latest attempt counts as currently inducted.
- **Invalid (7)** is worked out by the portal (a later version has "previous versions invalid" set) and is never exported; see `ReferenceData.md`.

## Permits

- Each permit category has an expiry type (`Category[ExpiryTypeId]`):
  - **Timelapse (1)**: Work Wallet closes the permit automatically at expiry, so ending at expiry is on time.
  - **CloseOut**: at expiry the permit is set to Expired and stays open until someone closes it. Closed after expiry is late.
- **Has Been Expired** and **Has Been Extended** come from the permit's status history. Prefer them to comparing dates: expiry is calculated in the wallet's time zone and uses the extended expiry if the permit was extended, while the extract has the original expiry.

## PPE

- The portal's headline tiles are Available stock, Assigned PPE and Require replacement.
- Stock and assignment histories share one action list (e.g. issued, returned, transferred); limit each page's dropdown to the actions relevant to it.

## Reported Issues

- Investigation answers (numeric, date/time, sign-offs) are grouped by question wording, so answers to the same question compare across issues even after the investigation process is edited.
- Investigation features are optional; pages for them must explain when a wallet records none.

## Safety Cards

- The portal shows Active cards.
- A card's recipient is a Work Wallet contact (`EmployeeContactId`) or a name typed on the card. Count people by contact, and by name plus employer for typed names.
