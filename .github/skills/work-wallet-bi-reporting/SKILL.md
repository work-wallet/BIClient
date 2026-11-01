---
name: work-wallet-bi-reporting
description: "Work Wallet data and portal knowledge for Power BI reports built on the Work Wallet BI Client data mart (mart schema): status and type codes, placeholder dates, -1 'not scored' values, deleted and orphaned records, identifying people and companies, deep links back to the Work Wallet portal, matching the portal's headline figures, and how each module behaves (Actions, Assets, Audits, Inductions, Permits, PPE, Reported Issues, Safety Cards). Use when designing measures, filters or pages over Work Wallet data, in the sample reports or a bespoke customer report."
---

# Work Wallet BI Reporting

What a report needs to know about Work Wallet data, beyond general Power BI practice (the `powerbi-report-development` skill). The data comes from the BI Extract API through the BI Client's stored procedures into the `mart` schema.

## Sources

- **`ReferenceData.md`**: status and type codes for every module.
- **`SampleJSONFromAPI.md`**: the extract's fields, with notes on placeholder values.
- [Module behaviour](./references/modules.md): how each module's records should be counted and judged.
- [Portal](./references/portal.md): the portal's headline figures, and deep-link paths.

## Rules

- **Codes in DAX, names in filters.** Measures and calculated columns match statuses and types by code, not display name. Codes are stable; names can differ from the reference list (e.g. "Decomissioned", "InProgress") or be reworded later. Filters users can see use the display name. Profile the codes first: the data doesn't always match `ReferenceData.md`.
- **Exclude deleted records.**
  - Use a report-level filter on the status name (Status is not "Deleted"). Measures that ignore report filters need the same exclusion by code.
  - Some modules use flags instead: Actions `Is Deleted` and `Is Orphaned`, Asset defects `Deleted`, and not finalised (draft) records. Exclude those too.
- **Placeholder dates**: some date columns use `1899-12-30` for "no date" rather than blank, others `1900-01-01`. Treat dates on or before `1900-01-02` as blank in calculated columns, including in durations: an end date that is a placeholder makes a duration hugely negative.
- **"Not scored" is `-1`** for scores, potentials and percentages; exclude it (`>= 0`) from sums and averages. Other "not set" codes are also `-1` (e.g. `OccupationRoleCode`); sort them with an order column.
- **People**: identify people by `Contact_key` / `ContactId`, never by name alone. Different people share names, and names change.
  - Where the extract has no id (a name typed on a record, or an Actions assignee), use the most specific combination available: name plus employer, or name plus email.
  - For tables that list people, add a display column that is unique per person (e.g. `'Safety Card'[Recipient]`).
  - The same person can be a contact at several companies. A "person's" drillthrough page usually wants all their records, so bind it to name and email and list every company on the page.
- **Companies have no id** in the extracts, so counting distinct company names is the best available.
- **Use the wallet's own settings** (e.g. grading set colours and grades) rather than fixed thresholds. Where a scale is needed, use a neutral fixed scale (0%–100%), not business thresholds.
- **Optional features**: many features are optional per wallet (e.g. flagged answers, investigation answers, signatures). Pages for them must work, and explain themselves, when a wallet records none.
- **Match the portal** where users will compare figures: its default filters, its headline tile definitions and its wording ([portal](./references/portal.md)).
- **Link back to the portal** from record lists and detail pages ([portal](./references/portal.md)).

## Samples and bespoke reports

- **Sample reports** (this repo's `PowerBISamples/`) must work with any wallet. They never hard-code wallet data; see the repo's `powerbi.instructions.md`.
- **A bespoke report for one customer** can use that wallet's own values (e.g. a site list, a grading threshold the customer asked for). It should still match by code and identify people by id, so it keeps working when names change.
