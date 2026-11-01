# Semantic Model Conventions (TMDL and DAX)

## Date table

- One calculated, marked `Date` table per model (`tmdl.date_table` / `tmdl.write_date_table`).
- Relate it from a hidden, date-only calculated column on the main table, e.g. `DATE ( YEAR ( x ), MONTH ( x ), DAY ( x ) )`, not from a date/time column.
- Date slicers, monthly axes (`Date[Year Month]`, sorted by `Month Start`) and previous-period measures all use it.
- Relative date slicers use `Date[Slicer Date]` (`MIN ( Date, TODAY () )`). Future dates count as today, so "Last 12 months" also includes upcoming, future-dated records (e.g. planned audits). Charts keep using the real date columns.
- **Several fact tables can share one Date table** (e.g. inspections by inspected date and defects by raised date). Each relationship must have only one filter path from `Date`. A both-directions relationship between the facts (or via a shared dimension) makes the new relationship ambiguous, and Power BI rejects it. Make the fact-to-dimension relationship single-direction first, and check the pages that relied on it.
- **A fact related to another dated fact needs its own date table.** E.g. actions related to their audit: `Date → Audit → Action` is already a path, so `Action → Date` would be ambiguous. Add a role-playing date table (`tmdl.write_date_table(..., name="Action Date")`, previous periods with `tmdl.previous_period(..., date_table="Action Date")`) and give its slicer its own sync group. Pages for that fact must not have a `Date` slicer, which would filter it through the related fact.
- Add a second date (e.g. closed date) as an **inactive** relationship and use it in measures with `USERELATIONSHIP` ("closed in the period").
- **Current-state pages** (registers, open items, current assignments) aren't filtered by date, so they have no date slicer (`page_header(..., date_display=None)`). Their age bands and "as at" values are calculated columns, evaluated at refresh.

## Measures table

- `<Module> Measures`, with display folders: one per topic (e.g. counts, scores, issues), plus Previous Period, Labels, Formatting, Images and Links.
- Hide helper measures: previous-period values, KPI labels, colours, links.
- Give every visible measure a `///` description.
- Avoid `%` and other symbols in measure names; documentation generators turn them into `_`.
- **Measure names are unique across the whole model**, not per table. When adding a second measures table (e.g. `Action Measures` in the Audits model), reuse existing helpers such as `Colour Good` and rename clashes (e.g. `Monthly Average Actions Line`).

## Previous period and trend labels

- **Previous period** is the same number of days immediately before the selected range (`tmdl.previous_period`). The range is capped at today, so upcoming records don't lengthen it.
- Pair it with:
  - a label: `pct_change_label` for counts, `pts_change_label` for 0–1 percentages;
  - a colour (`trend_colour`) that agrees with the label. Set `higher_is_good=False` for counts of problems. Set `zero_is_comparable=True` with `pts_change_label`, because a previous 0% is a real score.
- **Labels must handle empty periods.** `FORMAT ( BLANK (), … )` returns an empty string, giving fragments such as " completion rate". Return `BLANK ()` (or a "No … in this period" text) when the value being described is blank or zero.
- **Colours in DAX** come from hidden `Colour Good` / `Colour Bad` / `Colour Neutral` measures (`tmdl.semantic_colours`, values from the report style). Don't scatter hex values through measures.
- **Long text for KPI tiles** (e.g. a question) is truncated in the measure (`tmdl.truncate_label`, about 45 characters).

## Values, blanks and ties

- **Handle ties.** `TOPN(1, …)` returns every tied row, so never use it to pick "the" top item. Use the tie-aware leader pattern (`tmdl.leader`, `Name (+n tied)`).
- **Tables drop a row when every measure in it is blank.**
  - For rows that must still show, return a placeholder such as `"–"` instead of blank.
  - The reverse also applies: a measure that never returns blank (e.g. one that falls back to a parent-level value) pulls in unrelated dimension rows. Return `BLANK ()` when the row has no facts (`ISEMPTY ( Fact )`).
- **Zero vs blank**: a KPI tile shows `--` for blank. Add `+ 0` when zero is the meaningful answer (e.g. "Serious, awaiting investigation"), but only in measures used by cards, because a measure that is never blank pulls every row into tables.
- **`ISINSCOPE` checks must cover every column a visual might group by**, e.g. both a raw question column and its order-prefixed variant.
- **Give blank grouping values a label** in a calculated column (e.g. `"(No company)"`), so matrix rows aren't blank.
- **Sort by a hidden order column** when codes don't sort in display order (e.g. `-1` for "not set").
- **Identify records by key, not by display text.** Count, rank and group people (and anything else with an id) by its key. Different people share names, and names change. For tables that list people, add a display column that is unique per person (the name, plus the company, then an email, only as far as needed to tell same-name people apart). Otherwise the visual merges them into one row.

## Single-record (detail) pages

- Read the record's attributes with measures such as `IF ( HASONEVALUE ( Fact[Key] ), MAXX ( Fact, RELATED ( Dim[Name] ) ) )`, not `MIN ( Dim[Name] )`. With single-direction relationships a dimension isn't filtered by the record, so `MIN` shows the right value only when a drillthrough happens to pass that column too (and is wrong from a URL filter or another source visual).
- Tables built only from dimension columns aren't tied to the record either, and list every dimension row. Add a measure filter (`pbir.measure_filter`, e.g. `[Issues] > 0`) unless the relationships cross-filter both ways.
- Keep record-level measures (and their colour measures) for the record's tiles only. Measures used for conditional formatting are part of a table's query, so keep table colour measures cheap (`SELECTEDVALUE` of the grouped column). A colour measure that read the fact row made a register table with several dimension columns evaluate every combination and fail with "Query has exceeded the available resources".
- **A table grouped by a name can cover several codes** when names repeat (e.g. Inductions 'Passed' is codes 1 and 4), and `SELECTEDVALUE` of the code is then blank. Colour by the set of codes instead: `ISEMPTY ( EXCEPT ( VALUES ( Dim[Code] ), { … } ) )`.

## In-cell SVG measures (bars, badges)

- Set `dataCategory: ImageUrl`.
- Escape text from data, starting with `%` → `%25` (the image is a `data:` URL), then `#` → `%23`. XML-escape `&`, `<` and `'`.
- Check colours from data are valid hex (`LEN = 7`) before using them.

## Formats

- Give date and date/time columns explicit formats (the report style's, e.g. `dd/mm/yyyy`). `Short Date`, `General Date` and `Long Date` follow the viewer's locale, so the service shows US dates (10/27/2026, AM/PM) to many viewers.

## DAX gotchas

- Don't name variables after DAX functions or keywords (e.g. `TopCount`, `Text`, `Top`, `Current`, `LastDate`, `Name`). The whole query fails with "Failed to resolve name 'SYNTAXERROR'", and `Test-PbiMeasures` lists every measure using one.
- Quote table names that are also DAX keywords or functions in queries and measures: `'Date'`, `'Status'`, `'Property'`, `'Action'`.
- `MEDIANX` over a date difference needs a numeric expression (`( a - b ) * 1.0`).
- When profiling, `BLANK () <= DATE ( 1900, 1, 1 )` is true, so a "before 1900" count includes real blanks. Count blanks and placeholders separately.

## New tables

New tables need three things:

- a `ref table` line in `model.tmdl` (`tmdl.add_table_refs`);
- their relationships in `relationships.tmdl` (`tmdl.add_relationship`);
- a node on a page in `diagramLayout.json` (`tmdl.add_diagram_page`), so model documentation generators include them. Edit `diagramLayout.json` additively and keep its existing number formatting.
