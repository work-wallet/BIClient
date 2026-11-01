---
name: powerbi-report-development
description: "Build, redesign or edit Power BI reports and semantic models saved as PBIP projects (PBIR visual.json, TMDL tables and measures), with the Tools/PowerBI helpers (pbir.py, tmdl.py, PowerBIDev.ps1). Use for report makeovers, new pages, measures, Date tables, drillthrough, KPI cards, links, publishing to a development workspace, checking measures with DAX, checking rendered pages in the browser, and handling Power BI Desktop saves."
---

# Power BI Report Development

How to change Power BI reports and models kept as PBIP files, and check the result against a real Power BI workspace. It works for any PBIP project; project rules (a repo's `*.instructions.md`), the report style and the data's own rules (e.g. the `work-wallet-bi-reporting` skill) sit on top.

## Ground rules

- **The committed files are the source of truth**: the `.Report` PBIR JSON, the `.SemanticModel` TMDL and the theme. Power BI Desktop, manual edits and generated output all change the same files.
- **Build scripts are throwaway.** A session may write a script that uses `pbir.py` / `tmdl.py` to build or restyle a report. Keep it in the session workspace, not the repo. Once its output is committed, the script is stale.
- **Change existing reports with targeted edits.** Edit the `visual.json` / `.tmdl` directly, or generate only the visuals being changed. Rebuild a whole page only when restyling it, passing `replace_all=True` explicitly.
- **Rebuilds must not lose edits.** Before rebuilding pages from a script, run it first: `git diff` must be empty. Carry any differences into the script, then make the intended change.
- **Once a model change is committed or published**, make further model changes with the additive helpers (`tmdl.add_columns`, `tmdl.upsert_measures`, …) or the edit tool, not by re-running a whole-model script.
- **The helpers are safe by default.** They refuse to write over uncommitted changes (`allow_dirty=True` overrides). `write_page` only writes the visuals it is given and keeps the rest. The TMDL writers refuse to replace an existing file without `overwrite=True`.
- **File form**: CRLF line endings and tab-indented TMDL, as Desktop writes. Edit files with the edit tool; don't rewrite them with ad hoc Python piped through PowerShell, which has truncated a file before failing.

## Procedure: redesign or extend a report

1. **Review the existing report.** List each page's visuals, fields and filters, and keep what users rely on. A short throwaway script that prints these from the PBIR JSON is quicker than opening pages one by one.
2. **Profile the data with DAX before designing** (`Invoke-PbiDax`, see [dev workspace](./references/dev-workspace.md)):
   - code distributions (statuses, types) and whether they match the reference lists;
   - placeholder dates, blank names or companies, "not set" codes;
   - which tables are empty (optional features), so those pages explain empty data;
   - relationship cross-filter directions (they decide whether dimension-only tables follow the page's filters);
   - how the product behaves before treating something as a problem, and whether the data has the product's own status-history flags (prefer them to comparing dates).
3. **Model**: add the `Date` table, its relationship and the measures table (`tmdl.py`); see [model conventions](./references/model-conventions.md). Publish, refresh once, run `Test-PbiMeasures`, and check values with `Get-PbiMeasureValues` (the default period with the report-level filters, an empty period, one record). Check edge cases: empty periods, a single item, ties, and data without the optional feature.
4. **Report**: apply the theme (`pbir.apply_theme(copy_from=...)`) and lay pages out in the report style; see [report mechanics](./references/report-mechanics.md).
   - Keep existing page names (ids) where a page is kept, so links and bookmarks still work.
   - Fold pages that are a single filtered table into a broader page with a dropdown, and delete them (`pbir.delete_page`).
   - Set the report-level filters, page order and drillthrough targets (`set_report_filter_not_in`, `set_page_order`, `set_drillthrough`).
   - Fix every overlap warning that `write_page` prints.
5. **Publish and check every page in the browser**, including the drillthrough (select a row, click the button, then Back) and a record reached by URL filter.
6. **Finish**:
   - run the project's own finishing steps (docs, changelog);
   - ask the user to open the `.pbip` in Power BI Desktop, refresh and save, which validates the files in Desktop;
   - review that save and commit it on its own ([Desktop round-trips](./references/desktop-round-trips.md)).

## References

- [Model conventions](./references/model-conventions.md): Date table, measures table, previous period, labels, blanks and ties, detail pages, SVG measures, DAX gotchas, new tables.
- [Report mechanics](./references/report-mechanics.md): filters and slicers, cards, tables and matrices, drillthrough and buttons, links, theme.
- [Desktop round-trips](./references/desktop-round-trips.md): what a Desktop save changes and how to handle it.
- [Dev workspace](./references/dev-workspace.md): setup, publishing, refresh limits, verifying measures, checking pages in the browser.

## Tools (`Tools/PowerBI/`)

Copy the whole folder with this skill. The Python modules import each other.

- **`PowerBIDev.ps1`** (dot-source it):
  - finding and publishing: `Get-PbiItems`, `Publish-PbiSemanticModel`, `Publish-PbiReport`, `Export-PbiDefinition`, `Invoke-PbiRefresh`;
  - querying: `Invoke-PbiDax` (raises DAX errors with a readable message);
  - checking measures: `Test-PbiMeasures` (evaluates every measure in a measures `.tmdl`), `Get-PbiMeasureValues` (every measure's value in one filter context).
- **`pbir.py`**: report builders and the layout constants (the canvas grid).
  - **Page parts**: header (`header`, `page_header`), date and dropdown slicers, the KPI card row, text cards, tables, matrices (optionally expanded), bar and column charts.
  - **Filters and colours**: Top N, not-blank, `in_filter` and `measure_filter` filters; gradients; fixed series colours.
  - **Buttons and links**: drillthrough, Back and web-URL (`link_button`) buttons; link columns (`link_column`, `add_link_column`).
  - **Pages and report settings**: `create_page`, `delete_page`, `set_page_order`, `set_drillthrough`, `set_report_filter_in` / `set_report_filter_not_in`, `remove_report_filters`.
  - **Writing files**: `write_page` writes only the given visuals, keeping other visuals, page filters and drillthrough bindings; `replace_all=True` rebuilds the page and `page_filters=` replaces its filters. `apply_theme` registers the theme.
- **`tmdl.py`**: model helpers.
  - **New tables**: `MeasuresTable` and the `Date` table (`write_date_table`).
  - **Additive edits**: `add_columns` (`replace=True` updates in place), `upsert_measures`, `set_sort_by`, `add_table_refs`, `add_relationship`, `add_diagram_page`, `portal_url_column`.
  - **DAX patterns**: `previous_period`, `pct_change_label` / `pts_change_label`, `trend_colour`, `leader`, `truncate_label`, `semantic_colours`.
- **`report_style.py`**: the style tokens (colours, fonts, type sizes, eyebrow, theme file) the builders use. `report_style.use(Style(...))` switches to another brand for the rest of the session.
- **`_guard.py`**: the check that stops the helpers writing over uncommitted changes.
- **Prerequisites**: Azure CLI, Python 3, and the integrated browser with its Playwright tools.
