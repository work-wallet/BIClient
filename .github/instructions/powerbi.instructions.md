---
description: "Use when creating, redesigning or editing the Power BI sample reports and semantic models (.pbip, PBIR visual.json, TMDL measures, report theme), or when publishing them to a Power BI workspace to review changes interactively."
applyTo: "PowerBISamples/**, Tools/PowerBI/**"
---

# Power BI Sample Reports

## Purpose

The samples under `PowerBISamples/` serve two audiences. Every change must work for both:

- **Work Wallet**: demonstrates reporting capabilities to customers.
- **Customers**: a baseline to copy and customise into their own reports, against their own wallet's data.

## Source of truth

- **The committed report and model files are the source of truth**: the `.Report` PBIR JSON, the `.SemanticModel` TMDL and the theme. Power BI Desktop, manual edits and generated output all change the same files.
- **Build scripts are throwaway.** A session may write a script that uses `Tools/PowerBI/pbir.py` / `tmdl.py` to build or restyle a report. Keep it in the session workspace and don't commit it. Once its output is committed, the script is stale.
- **Change existing reports with targeted edits.** Edit the `visual.json` / `.tmdl` directly, or generate only the visuals being changed. Only rebuild a whole page when restyling it, and pass `replace_all=True` explicitly.
- **Rebuilds must not lose edits.** Before rebuilding pages from a script, check the script reproduces the committed files: run it first and `git diff` must be empty. Carry any differences into the script, then make the intended change.
- **The helpers are safe by default.** They refuse to write over uncommitted changes. `write_page` only writes the visuals it is given and keeps the rest. The TMDL writers refuse to replace an existing file without `overwrite=True`.

## Working with any wallet

The samples are developed against a demo wallet, but must not depend on it.

- **Never hard-code wallet data** in measures or visuals: no names, IDs, answer texts, locations or record types.
- **Codes in DAX, names in filters**:
  - Measures and calculated columns match statuses and types by code (see `ReferenceData.md`), not by display name. Codes are stable; names can differ from the reference list (e.g. "Decomissioned", "InProgress") or be reworded later.
  - Report, page and visual filters use the display-name column (e.g. `Status` is not "Deleted"), because users see them in the Filters pane and must be able to read and change them. Check each name in the data first (with DAX), and use the name that matches the code you mean.
  - True/false flag filters (e.g. "Is Latest is True") are readable as they are.
- **Identify people by id, never by name alone**:
  - Count, rank, match or group people (and anything else with an id) by a key such as `Contact_key` or `ContactId`. Different people often share a name, and one person's name can change. The demo wallet has both: two Adam Civvals at different companies, and a contact whose cards were issued under an earlier name.
  - Where the export has no id (a name typed on a record, or an Actions assignee), fall back to the most specific combination available, e.g. name plus employer, or name plus email.
  - For tables that list people, add a display column that is unique per person. Show the name, then add the company, then the email or "not a contact", only as far as needed to tell same-name people apart (see `'Safety Card'[Recipient]`). Otherwise the visual merges them into one row.
  - Companies have no id in the exports, so counting distinct company names is the best available.
- **Use colours the wallet provides** (e.g. grading set colours) rather than fixed thresholds. Where a scale is needed, use a neutral fixed scale (e.g. 0%–100%), not business thresholds.
- **Handle sentinel values.** Scores, potentials and percentages use `-1` for "not scored"; exclude them (`>= 0`) from sums and averages.
- **Handle ties.** `TOPN(1, …)` returns every tied row, so never use it to pick "the" top item. Use the tie-aware leader pattern (`Name (+n tied)`).
- **Don't rely on optional product features.** If a wallet may not use a feature (e.g. flagged answers), give the user a fallback, such as a slicer that switches what is counted.
- **Default filters and slicers may use demo values**, as consumers are expected to reset them. Prefer no saved selection where the page still makes sense.
- **Match the Work Wallet portal's defaults** so the report's numbers agree with what users see in Work Wallet. For example, the portal's Assets page shows Active assets by default. Check the portal page for the module and mirror its default with an editable report-level filter on the status name (`pbir.set_report_filter_in`). Tell users on the page when the filter hides records (e.g. a KPI label "7 more with other statuses (see Filters)").
  - Compare the portal's headline figures with the report's KPIs (e.g. PPE: available stock, assigned PPE, require replacement). If they already agree, no default filter is needed. Use the portal's wording for those tiles so the two read the same.
  - How the portal defines its tiles. Its "last 12 months" matches the reports' default date slicer.

    | Module | Portal tile | Definition |
    | --- | --- | --- |
    | Actions | Open actions | Status Open or In Progress, raised in the last 12 months, not deleted |
    | Actions | Overdue actions | Open, and the due date and time has passed (an action due today is overdue) |
    | Actions | Average close out days | Average days from raised to closed, for closed actions raised in the last 12 months |
    | Safety Cards | Total safety cards, Red cards | Active cards reported in the last 12 months |
    | Safety Cards | Assigned categories | Distinct categories on those cards |
    | Inductions | Enrolled individuals | Each person's latest attempt at each induction, across all induction statuses |
    | Inductions | Valid inductions % | Latest attempts that are valid and not expiring within 30 days, divided by enrolled individuals |
- **Check edge cases with DAX** before publishing: empty periods, a single item, ties, and data without the optional feature.
- **Explain empty data on the page.** Pages for optional features (e.g. investigation answers a wallet doesn't record) should say so, e.g. with a subtitle measure ("None recorded in this period"), rather than show empty visuals.

## Semantic model conventions

- **Date table**: one calculated, marked `Date` table per model (`tmdl.date_table`).
  - Relate it from a hidden, date-only calculated column on the main table, e.g. `DATE ( YEAR ( x ), MONTH ( x ), DAY ( x ) )`, not from a date/time column.
  - Date slicers, monthly axes (`Date[Year Month]`, sorted by `Month Start`) and previous-period measures all use it.
  - Relative date slicers use `Date[Slicer Date]` (`MIN ( Date, TODAY () )`). Future dates count as today, so "Last 12 months" also includes upcoming, future-dated records such as planned audits. Charts keep using the real date columns.
  - **Several fact tables can share one Date table** (e.g. inspections by inspected date and defects by raised date). Each relationship must have only one filter path from `Date`. A both-directions relationship between the facts (or via a shared dimension) makes the new relationship ambiguous, and Power BI rejects it. Make the fact-to-dimension relationship single-direction first, and check the pages that relied on it.
  - Add a second date (e.g. closed date) as an **inactive** relationship and use it in measures with `USERELATIONSHIP` ("closed in the period").
- **Current-state pages** (registers, open items, current assignments) aren't filtered by date, so they have no date slicer (`page_header(..., date_display=None)`). Their age bands and "as at" values are calculated columns, evaluated at refresh; say "as at the last data refresh" in the subtitle.
- **Measures table**: `<Module> Measures`, with display folders: one per topic (e.g. counts, scores, issues), plus Previous Period, Labels, Formatting and Images.
  - Hide helper measures: previous-period values, KPI labels, colours.
  - Give every visible measure a `///` description.
  - Avoid `%` and other symbols in measure names; the model doc generator turns them into `_`.
- **Previous period** is the same number of days immediately before the selected range (`tmdl.previous_period`). The range is capped at today, so upcoming records don't lengthen it. Pair it with:
  - a label: `pct_change_label` for counts, `pts_change_label` for 0–1 percentages;
  - a colour (`trend_colour`) that agrees with the label. Set `higher_is_good=False` for counts of problems. Set `zero_is_comparable=True` with `pts_change_label`, because a previous 0% is a real score.
- **Labels must handle empty periods.** `FORMAT ( BLANK (), … )` returns an empty string, giving fragments such as " completion rate". Return `BLANK ()` (or a "No … in this period" text) when the value being described is blank or zero.
- **Colours in DAX** come from hidden `Colour Good` / `Colour Bad` / `Colour Neutral` measures (`tmdl.semantic_colours`) that match the theme. Don't scatter hex values through measures.
- **In-cell SVG measures** (bars, badges):
  - Set `dataCategory: ImageUrl`.
  - Escape text from data, starting with `%` → `%25` (the image is a `data:` URL), then `#` → `%23`. XML-escape `&`, `<` and `'`.
  - Check colours from data are valid hex (`LEN = 7`) before using them.
- **Tables drop a row when every measure in it is blank.**
  - For rows that must still show, return a placeholder such as `"–"` instead of blank.
  - The reverse also applies: a measure that never returns blank (e.g. one that falls back to a parent-level value) pulls in unrelated dimension rows. Return `BLANK ()` when the row has no facts (`ISEMPTY ( Fact )`).
- **`ISINSCOPE` checks must cover every column a visual might group by**, e.g. both a raw question column and its order-prefixed variant.
- **Placeholder and excluded data**:
  - Some date columns use `1899-12-30` for "no date" rather than blank, others `1900-01-01`. Calculated columns should treat dates on or before `1900-01-02` as blank. Check existing calculated columns too: a duration using a placeholder end date goes hugely negative (e.g. an ended assignment with no end date).
  - When profiling, count blanks and placeholders separately: `BLANK () <= DATE ( 1900, 1, 1 )` is true in DAX, so a "before 1900" count includes real blanks.
  - Exclude records with a Deleted status with a report-level filter on the status name (`pbir.set_report_filter_not_in`), and by code in measures that ignore report filters. Some modules use a `Deleted` flag or "draft" (not finalised) flag instead; exclude those too.
  - Remove stale report-level filters on display names (`pbir.remove_report_filters`), and replace stale page filters when rebuilding a page (`write_page(..., page_filters=[...])`).
  - Give blank grouping values a label in a calculated column (e.g. `"(No company)"`), so matrix rows aren't blank.
  - When codes don't sort in display order (e.g. `-1` for "not set"), sort by a hidden order column.
- **Single-record (detail) pages**:
  - Read the record's attributes with measures such as `IF ( HASONEVALUE ( Fact[Key] ), MAXX ( Fact, RELATED ( Dim[Name] ) ) )`, not `MIN ( Dim[Name] )`. With single-direction relationships a dimension isn't filtered by the record, so `MIN` shows the right value only when a drillthrough happens to pass that column too (and is wrong from a URL filter or another source visual).
  - Tables built only from dimension columns aren't tied to the record either, and list every dimension row. Add a measure filter (`pbir.measure_filter`, e.g. `[Issues] > 0`) unless the relationships cross-filter both ways.
  - Keep these record-level measures (and their colour measures) for the record's tiles only. Measures used for conditional formatting are part of a table's query, so keep table colour measures cheap (`SELECTEDVALUE` of the grouped column). A colour measure that read the fact row made a register table with several dimension columns evaluate every combination and fail with "Query has exceeded the available resources".
- **Text labels**: avoid "1 hours"-style plurals; use wording such as "within an hour", "the same day" and "the next day" for small values.
- **Date formats**: give date and date/time columns explicit formats (`dd/mm/yyyy`, `dd/mm/yyyy hh:nn`). `Short Date`, `General Date` and `Long Date` follow the viewer's locale, so the service shows US dates (10/27/2026, AM/PM) to many viewers.
- **Zero vs blank**: a KPI tile shows `--` for blank. Add `+ 0` when zero is the meaningful answer (e.g. "Serious, awaiting investigation"), but only in measures used by cards, because a measure that is never blank pulls every row into tables.
- **DAX gotchas**:
  - Don't name variables after DAX functions or keywords (e.g. `TopCount`, `Text`, `Top`, `Current`, `LastDate`, `Name`). The whole query fails with "Failed to resolve name 'SYNTAXERROR'", and `Test-PbiMeasures` lists every measure using one.
  - Quote table names that are also DAX keywords or functions in queries and measures: `'Date'`, `'Status'`, `'Property'`, `'Action'`.
  - `MEDIANX` over a date difference needs a numeric expression (`( a - b ) * 1.0`).
- **Long text for KPI tiles** (e.g. a question) is truncated in the measure (`tmdl.truncate_label`, about 45 characters).
- **New tables** need three things:
  - a `ref table` line in `model.tmdl`;
  - their relationships in `relationships.tmdl`;
  - a node on a page in `diagramLayout.json`, so the model doc generator documents them. Edit `diagramLayout.json` additively and keep its existing number formatting.

## Report design conventions

The canvas is 1280 × 720. The constants live in `Tools/PowerBI/pbir.py`.

- **Theme**: `StaticResources/RegisteredResources/WorkWallet.json`.
  - Copy it unchanged from a report that already uses it, register it with `pbir.apply_theme`, and keep every copy identical.
  - Put formatting in the theme, not on individual visuals (page background, card tiles, table headers, slicers).
- **Navigation**: no in-canvas navigation menus. Users switch pages with the Power BI page tabs, Pages pane or app navigation.
- **Header** (`pbir.header`, x 24, y 8, 720 × 64; or `pbir.page_header`, which also places the slicers and narrows the header so it never runs under them): one textbox holding:
  - an 8pt accent eyebrow (`WORK WALLET  ·  <MODULE>`);
  - an 18pt title;
  - a 9pt grey subtitle saying what the page shows.
- **Slicers**: top right, y 10, height 58, right-aligned to x 1256, 12px apart. Date slicers are about 300 wide and dropdowns about 180.
  - When a dimension is shared by several fact tables (e.g. an action list covering both stock and assignment actions), limit each page's dropdown to the relevant values with a visual-level filter on the slicer, by name.
  - Use relative date slicers on `Date[Slicer Date]`, in one sync group per report.
  - Slicers in a sync group share one selection, so give them all the same default period. Otherwise the period a user sees depends on which page they opened first.
- **KPI row** (`pbir.kpi_cards`): one card visual (`cardVisual`) at y 80, height 124, holding four tiles.
  - Each tile shows a label, an 18pt value, and a reference label (a text measure, optionally coloured by a colour measure).
  - Use 13pt for text-valued tiles (names).
  - Values show in full (`labelDisplayUnits` 1, set by `kpi_cards`). Cards otherwise abbreviate to "1K" / "1.95K", which hides real figures once a wallet has more than 1,000 records.
  - Always use four tiles. With fewer, the tiles stretch and the page no longer fits (the service zooms out and visuals overflow). If a page has only three natural KPIs, add a relevant related one.
- **Body**: y 216 to 704, with 24px side margins and 12px gaps.
- **Dense detail pages** (e.g. drillthrough targets with many tables) use the compact rhythm:
  - summary cards at y 74, height 72, 8px gaps, ending at y 712;
  - 12pt summary values with no wrapping, and at most six tiles (about 200px each);
  - long values (locations, "name (company)", free text) in wrapping text cards (`pbir.text_card`, 9pt), because multi-tile cards truncate rather than wrap. Make a text card at least 72px tall: below that, the value under the label is clipped and the card looks empty;
  - 9pt titles and 6/10px padding on small tables, with column widths (`widths=`) that fit the container (about its width minus 36px), so there's no horizontal scrollbar.
- **Names**: sentence case for page names, visual titles and column display names.
- **Drillthrough**:
  - Keep the target page's drillthrough binding and a Back button (`pbir.back_button`).
  - On the source page, add a drillthrough button (`pbir.drillthrough_button`) whose text comes from a measure: "Select an item…" until one row is selected, then "View X details  ›".
  - Place it outside other visuals (e.g. on the header subtitle line). A selected visual is drawn on top and hides anything overlapping it.
  - With three or more dropdowns, the slicers reach far enough left to cover the subtitle line: end the button before the first slicer's x. `write_page` prints a warning for overlapping visuals (`pbir.find_overlaps`); fix every one before publishing.
  - Bind to a unique column. If the record has no unique reference, bind to its unique `Url` column (as the existing samples do) and show a readable reference in the button text.
  - Check uniqueness with DAX (`DISTINCTCOUNT` against `COUNTROWS`). For people, the same person can be a contact at several companies; binding to name and email groups their records, which is usually what a "person's" page needs. List every company on the page.
- **Links to Work Wallet** (deep links to the record in the portal), wherever a table lists records that have a portal page, and on each record's drillthrough page:
  - Model: a `Url` calculated column with `dataCategory: WebUrl` on the record's table (`tmdl.portal_url_column`). Use `https://portal.work-wallet.com` for every region. URLs carry no wallet id: the portal opens them in the user's selected wallet.
  - Wrap ids in `LOWER()`. Paths ignore case, but a `#fragment` must match the portal's lower-case element id exactly. Return blank for deleted records (by status code), which the portal can't show.
  - Tables: a "Link" column shown as a link icon (`pbir.link_column` in a new table, `pbir.add_link_column` for an existing one, which keeps Desktop edits and narrows the other columns to fit).
  - Drillthrough pages: an "Open in Work Wallet  ↗" button (`pbir.link_button`) left of the Back button, with its URL from a hidden `<Record> Link` measure (`SELECTEDVALUE ( Record[Url] )`, display folder "Links").
  - Portal paths, from `mart.ETL_Extract*` ids:

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
    | Action | The record it was raised on (`TargetId`), scrolled to the action; the portal has no page for a single action. Audit and issue: the record's path + `?tab=actions#{ActionId}`. Asset: `/Company/Assets/{TargetId}/Detail?tab=actions#{ActionId}`. Briefing: `/Users/Briefings/{TargetId}/Detail?tab=actions#{ActionId}`. Safety card: `/Users/SafetyCardReporting/{TargetId}/Detail#{ActionId}`. |
- **Charts and tables**:
  - Rank with visual-level Top N filters (`pbir.top_n_filter`).
  - A table's sort only applies to a field that is in the table. To sort by a measure (e.g. "most warnings first"), include it as a column.
  - Use colour scales for heatmap matrices (`score_gradient` for 0–1 percentages, `count_gradient` for counts).
  - Open matrix row levels by default (`pbir.matrix(..., expanded=True)`, or a number of levels). A collapsed matrix shows a few top-level rows and a lot of empty space. The expansion is level-wide, so it doesn't depend on the data.
  - Fix colours for fixed lists (e.g. severity) by code with `series_colours` / colour measures; let the theme colour everything else.
  - Size in-cell images with table `grid` `imageWidth` / `imageHeight`, and make the column about 15px wider than the image.
  - Avoid donut charts and other visuals that become unreadable when a wallet has many categories.

## PBIR formatting lessons

- **Theme objects need a selector for cardVisual.** Every visual-level object in the `cardVisual` section of a theme needs `"$id": "default"`; container objects (`background`, `border`, `dropShadow`, `title`, `padding`) don't.
- **Card visual layout:**
  - Tiles split 50/50 between the callout (label + value) and the reference label by default, which clips the label. Set `layout.calloutSize` (62 with reference labels, 100 without).
  - Pad the callout with the `padding` object, which uses `paddingIndividual` plus `topMargin` / `bottomMargin` / `leftMargin` / `rightMargin`. Set `spacing.verticalSpacing` to 2.
  - Reference label padding uses different property names: `paddingIndividual` plus `paddingTop` / `paddingBottom` / `paddingLeft` / `paddingRight`. Desktop silently drops `*Margin` names on `referenceLabel`.
- **Slicer fonts:** relative date slicer inputs ignore text size settings (they render at about 8pt). Set slicer `items` (and `date`) text to 8pt in the theme so dropdowns match.
- **Drillthrough button:** `visualContainerObjects.visualLink` has `type 'Drillthrough'` and `drillthroughSection` set to the target page name. Style the default, hover and disabled states via selectors `{"id": "default" | "hover" | "disabled"}`.
- **Button `show` needs its own entry.** Put `show` for a button's `text`, `outline` and `fill` in an entry with no selector, and the styling in the `{"id": "default"}` entry. A `show` inside the default entry is ignored, and the button draws as a bare icon or an empty box.
- **Web URL button:** `visualLink` `type 'WebUrl'` with `webUrl` set to a measure expression (`pbir.link_button`). The service opens it in a new tab.
- **Conditional colour from a measure** ("field value") is `{"solid": {"color": {"expr": {"Measure": …}}}}` (`pbir.colour_measure`).
- **Expanded matrix rows** need both parts of Desktop's "expand all down" form, or the service shows the matrix collapsed:
  - `"active": true` on every shown `Rows` projection;
  - `expansionStates` with one entry per row level (`isCollapsed: true` only on levels left closed, `identityKeys` on all but the last) and `"root": {}`.

  Per-member `root.children` toggles depend on the data, so don't use them.

## Power BI Desktop round-trips

Saving in Power BI Desktop rewrites files into its own form. Expect this after every Desktop save.

### What a Desktop save changes

- **JSON files** (`visual.json`, `page.json`, `report.json`, the theme):
  - The final line break is removed, so git shows whole-file changes that are whitespace only. Use `git diff --ignore-cr-at-eol` to see the real changes.
  - Visual `$schema` versions are bumped (e.g. `visualContainer/2.4.0` → `2.14.0`).
  - `"active": true` is added to `Category`, `Rows` and `Columns` projections. Lower matrix row levels get `false`.
  - Whole numbers lose their `.0` (e.g. `802.0` → `802`).
  - Fractional numbers are written with up to 17 significant digits (e.g. `770.40000000000009`, where Python writes `770.4000000000001`). Keep positions in whole pixels.
  - Empty `"objects": {}` blocks are removed.
  - An empty `"columnHeaders": [{ "properties": {} }]` entry is added (after `columnWidth`) to tables with column widths, and to matrices with a row header width. `pbir.table` (`widths=`) and `pbir.matrix` (`row_header_width=`) already write it.
  - When it rewrites a matrix, the query roles are written `Columns`, `Rows`, `Values`. Matrices it doesn't touch keep their order, so this isn't a reliable rule; `pbir.matrix` matches it for matrices with a row header width.
- **Unsupported properties are silently dropped.** Examples seen so far:
  - `referenceLabel` `*Margin` padding;
  - gauge callout font size;
  - button outline corner radius.

  A dropped property means it is unsupported or misnamed, so fix the generator rather than re-adding it.
- **TMDL**:
  - Table-level properties are reordered (`lineageTag` before `dataCategory`).
  - Measures can move to a different position in the table file. Measures added to a table since the last Desktop save are moved to the end of the table (after the existing ones).
  - `relationships.tmdl` ends with a blank line (`tmdl.add_relationship` writes it).
  - Names are quoted only when they contain spaces or special characters (`Action.'Raised Date'`, not `'Action'.'Raised Date'`), even when the name is a DAX keyword that must be quoted inside DAX expressions. Pass unquoted table names to `tmdl.add_relationship` unless they contain spaces.
  - Content is otherwise unchanged.
- **`diagramLayout.json`** can show as modified in `git status` with no content change (a timestamp-only touch); it clears itself.
- **`cultures/*.tmdl` (Q&A linguistic metadata) is generated by Desktop.** It holds synonyms built from field and display names, so it changes when fields are added or renamed, or a visual's display name moves to another field. Never edit it by hand or with the helpers; commit it with the Desktop save.

### How to handle it

- **Commit a Desktop save on its own**, with no other edits (e.g. "Power BI Desktop save (no functional change)"), so later diffs show only real changes.
- **Review a Desktop save structurally**, comparing property by property against the last commit (ignore whitespace and ordering). Then publish it and check the affected pages still render as before.
- **Don't overwrite the user's Desktop edits.** Commit a Desktop save before regenerating anything (the helpers refuse to write over uncommitted changes). If a rebuild script no longer reproduces the committed files, carry the differences into the script first.
- **Generate files in Desktop's form** (no final line break, current schema versions, whole-pixel positions, `active` flags, no empty `objects`). `pbir.py` and `tmdl.py` already do this, so regenerating after a Desktop save should give no differences. If a Desktop save still changes generated files, update the tools to match.

## Applying the design to a report

A repeatable sequence for bringing a sample report up to this design:

1. **Review the existing report.** List each page's visuals and fields, and keep what users rely on. A short throwaway script that prints each page's visuals, fields and filters (from the PBIR JSON) is quicker than opening pages one by one.
2. **Profile the data with DAX before designing**:
   - status and type code distributions (e.g. how many records are Deleted), and whether the codes match `ReferenceData.md` (they don't always);
   - placeholder dates, blank names or companies, "not set" codes;
   - which tables are empty in the dev wallet (optional features), so those pages are designed to explain empty data;
   - relationship cross-filter directions (they decide whether dimension-only tables follow the page's filters);
   - how the product behaves, before treating something as a problem. For example, time-limited permits are closed automatically at expiry, so "closed after expiry" is only a failure for permits that need a manual close-out. Check timestamps (e.g. close time minus expiry) to confirm.
   - whether the extract has the product's own status-history flags (e.g. "has been expired"). Prefer them to comparing dates: dates can be in different time zones, or miss later changes such as an extension.
3. **Model**: add the `Date` table, relationship and measures table (`tmdl.py`). Publish, refresh once, then run `Test-PbiMeasures`, and check the values with `Get-PbiMeasureValues` (default period with the report-level filters, an empty period, one record).
4. **Report**: copy the theme (`pbir.apply_theme(copy_from=...)`). Keep existing page names (ids) where a page is kept, so links and bookmarks still work. Fold pages that are a single filtered table (e.g. one page per action) into a broader page with a dropdown, and delete them (`pbir.delete_page`). Set the report-level filters, page order and drillthrough targets (`set_report_filter_not_in`, `set_page_order`, `set_drillthrough`).
5. **Publish and check every page in the browser**, including the drillthrough (select a row, click the button, then Back) and a record reached by URL filter.
6. **Finish**: model docs, CHANGELOG, then the user's Power BI Desktop save (see [Finishing](#finishing)).

## Developing interactively in an agent session

The loop: edit files, publish to a dev workspace (seconds), check measures with DAX, then check the rendered pages in the integrated browser.

### One-off setup (by the user)

- Create a dedicated development workspace. A Pro workspace is enough.
- Publish the sample model and report to it once from Power BI Desktop, and set the data source credentials in the service.
- Sign the Azure CLI in to the workspace's tenant: `az login --tenant <tenant> --allow-no-subscriptions`.
- Give the agent the workspace URL, from which it can read the IDs.
- Keep workspace, report and model IDs in the session only. Never commit them.

### Edit, publish, verify

- **Edit** (see [Source of truth](#source-of-truth)):
  - For small changes, edit the JSON/TMDL directly.
  - For new pages or a restyle, write a throwaway build script in the session workspace using `pbir.py` / `tmdl.py`.
  - Once a model change is committed or published, make further model changes with the additive helpers (`tmdl.add_columns`, `tmdl.upsert_measures`, …) or the edit tool, not by re-running a whole-model script.
  - Edit scripts and files with the edit tool. Don't rewrite them with ad hoc Python piped through PowerShell, which has truncated a file before failing.
  - Stable visual names and lineage tags keep diffs to real changes.
  - When files are edited by hand, create them with CRLF line endings and tab-indented TMDL (as Desktop does).
- **Publish** with `Tools/PowerBI/PowerBIDev.ps1`:
  - `Publish-PbiReport` for layout changes (it rebinds the report to the published model).
  - `Publish-PbiSemanticModel` for model changes.
  - Measure-only changes need no refresh.
  - Refresh (`Invoke-PbiRefresh -Wait`) after adding tables, columns or calculated tables.
- **Refresh limits**: Pro workspaces allow 8 API-triggered refreshes in any rolling 24 hours ("exceeded the amount of requests"), so only refresh when needed. The error says "Retry in 120 seconds", but retrying doesn't help until the oldest of the 8 is 24 hours old; check the model's refresh history. When the limit is hit, ask the user to use "Refresh now" on the semantic model in the service; manual refreshes aren't counted.
- **Verify measures** after every model change:
  - `Test-PbiMeasures -TmdlPath '<...>/<Module> Measures.tmdl'` evaluates every measure in the file and lists any that fail.
  - Use `Invoke-PbiDax` with `CALCULATETABLE ( ROW ( … ), <filters> )` to test specific contexts (a date range, one record, ties), or `Get-PbiMeasureValues -Filters …` to list every measure's value in one context. DAX errors arrive in the response body of a successful HTTP call; `Invoke-PbiDax` raises them.

### Checking pages in the browser

- **Open a page**: `https://app.powerbi.com/groups/<workspaceId>/reports/<reportId>/<pageName>?experience=power-bi&chromeless=1`.
  - The user signs in once in the integrated browser.
  - `chromeless=1` hides the service chrome.
- **Filter by URL** to reach a specific record: `&filter=Table/Column eq 'value'`, encoding spaces in names as `_x0020_`. The URL filter is added to the viewer's persisted state, including filters carried by an earlier drillthrough (such as the date range), so a record outside that state shows blank.
- **Allow time to render**: wait about 15 seconds after navigating. Reload after each publish, because the browser caches the report. A plain reload can still show the previous version; navigate to the URL with a throwaway query parameter (e.g. `&nocache=<timestamp>`) to force a fresh load.
- **Slicers remember the viewer's last selection** (persistent filters), so a changed default won't show until you click "Reset to default". That button is in the full view; it isn't available with `chromeless=1`.
- **The tab must be visible to render.** If visuals measure zero size or the canvas is blank, ask the user to bring the browser tab into view.
- **Screenshots can be stale.** Prefer saving the live render to a file with Playwright, `page.screenshot({ path })`, then viewing the file. Confirm details by measuring the live page with `page.evaluate`:
  - element positions (`getBoundingClientRect`) and computed font sizes;
  - card tiles are `.small-multiples-grid-cell-content`, tables are `[role="grid"]`.
- **Full canvas**: `page.setViewportSize({ width: 1700, height: 1000 })` shows the whole canvas.
- **Test interactions** with Playwright: click a table row (`getByText(...).click()` or `page.mouse.click(x, y)`), click buttons, and right-click → Drill through. A button's own label can intercept locator clicks; click it by position instead.
  - Clicking a selected row again deselects it, and clicking a header re-sorts the table. Click a body cell once (locate it with `[role=gridcell][data-query-ref="Table.Column"]`), then check the button text changed before clicking it.

### Finishing

- **Regenerate the model docs** after model changes: `dotnet run --project Tools/WorkWallet.BI.PowerBIModelDocGenerator/WorkWallet.BI.PowerBIModelDocGenerator.csproj`. CI runs it with `-- --check`.
- **Update `CHANGELOG.md`** at a high level (the audience is report consumers).
- **Ask the user to open the `.pbip` in Power BI Desktop, refresh and save.** This updates the local data cache and validates the files in Desktop. Then compare the diff before committing.

## Tools

- **`Tools/PowerBI/PowerBIDev.ps1`**: dot-source it, then use:
  - `Get-PbiItems`
  - `Publish-PbiSemanticModel`
  - `Publish-PbiReport`
  - `Export-PbiDefinition` (downloads a published definition)
  - `Invoke-PbiRefresh`
  - `Invoke-PbiDax` (raises DAX errors with a readable message)
  - `Test-PbiMeasures` (evaluates every measure in a measures `.tmdl`)
  - `Get-PbiMeasureValues` (lists every measure's value in one filter context)
- **`Tools/PowerBI/pbir.py`**: report builders and the layout constants. It covers:
  - header (`header`, `page_header`), date and dropdown slicers, the KPI card row, text cards, tables, matrices (optionally expanded), bar and column charts (stacked, or `clustered=True` for side-by-side measures);
  - Top N, not-blank, "is one of" (`in_filter`) and measure (`measure_filter`) filters, gradients, fixed series colours;
  - drillthrough, Back and "Open in Work Wallet" (`link_button`) buttons, and Work Wallet link columns (`link_column`, `add_link_column`);
  - pages and report settings: `create_page`, `delete_page`, `set_page_order`, `set_drillthrough` (a hidden drillthrough target), `set_report_filter_in` / `set_report_filter_not_in`, `remove_report_filters`;
  - `write_page` (writes only the given visuals, keeping other visuals, page filters and drillthrough bindings; `replace_all=True` rebuilds the page; `page_filters=` replaces the page filters) and `apply_theme` (`copy_from=` copies the theme from another report).
- **`Tools/PowerBI/tmdl.py`**:
  - new tables: the `MeasuresTable` builder and the `Date` table; the writers need `overwrite=True` to replace an existing file;
  - additive edits to an existing model: `add_columns` (`replace=True` updates existing calculated columns in place), `upsert_measures` (replaces by name in place, keeping lineage tags, or inserts), `set_sort_by`, `add_table_refs`, `add_relationship`, `add_diagram_page`, and `portal_url_column` (a Work Wallet `Url` column for `add_columns`);
  - DAX patterns: previous period, change labels, trend colours, tie-aware leader, truncation, semantic colours.
- **`Tools/PowerBI/_guard.py`**: the shared check that stops the helpers writing over uncommitted changes (`allow_dirty=True` overrides it).
- **`Tools/WorkWallet.BI.PowerBIModelDocGenerator`**: generates `PowerBISamplesModels.md` and `PowerBISamplesModels/*.md` from the TMDL and `diagramLayout.json`. Never edit its output by hand.
- **Prerequisites**: Azure CLI, Python 3, the .NET SDK, and the integrated browser with its Playwright tools.
