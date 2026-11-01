# Report (PBIR) Mechanics

How report features work in the PBIR files and the Power BI service. What they look like is the report style's job (e.g. `.github/instructions/powerbi-style.instructions.md`).

## Filters and slicers

- **Report, page and visual filters use display-name columns** (e.g. `Status` is not "Deleted"), because users see them in the Filters pane and must be able to read and change them. Measures match by code. Check each name in the data first (with DAX). True/false flag filters (e.g. "Is Latest is True") are readable as they are.
- Report-level filters: `pbir.set_report_filter_in` / `set_report_filter_not_in`. Remove stale ones on display names with `pbir.remove_report_filters`, and replace stale page filters when rebuilding a page (`write_page(..., page_filters=[...])`).
- **Default filters that hide records**: tell users on the page (e.g. a KPI label "7 more with other statuses (see Filters)").
- **Slicers in a sync group share one selection**, so give them all the same default period. Otherwise the period a user sees depends on which page they opened first.
- When a dimension is shared by several fact tables (e.g. an action list covering both stock and assignment actions), limit each page's dropdown to the relevant values with a visual-level filter on the slicer, by name.
- **Don't rely on optional features.** If some data may not exist (e.g. flagged answers), give the user a fallback, such as a slicer that switches what is counted, and explain empty data on the page (a subtitle measure).

## Cards

- **Card values abbreviate** to "1K" / "1.95K" unless `labelDisplayUnits` is 1 (`kpi_cards` sets it).
- **Fixed tile count**: a card visual with fewer tiles than planned stretches them, and the page no longer fits (the service zooms out and visuals overflow). Keep the tile count the layout expects.
- **Layout**: tiles split 50/50 between the callout (label + value) and the reference label by default, which clips the label. Set `layout.calloutSize` (62 with reference labels, 100 without).
- **Padding**: pad the callout with the `padding` object, which uses `paddingIndividual` plus `topMargin` / `bottomMargin` / `leftMargin` / `rightMargin`. Set `spacing.verticalSpacing` to 2. Reference label padding uses `paddingIndividual` plus `paddingTop` / `paddingBottom` / `paddingLeft` / `paddingRight`; Desktop silently drops `*Margin` names on `referenceLabel`.
- **Text cards** truncate in multi-tile cards rather than wrap. Use a single-tile text card (`pbir.text_card`) for long values, at least 72px tall: below that, the value under the label is clipped and the card looks empty.
- **Theme objects need a selector for cardVisual.** Every visual-level object in the `cardVisual` section of a theme needs `"$id": "default"`; container objects (`background`, `border`, `dropShadow`, `title`, `padding`) don't.

## Tables, matrices and charts

- Rank with visual-level Top N filters (`pbir.top_n_filter`).
- A table's sort only applies to a field that is in the table. To sort by a measure (e.g. "most warnings first"), include it as a column.
- Fix table column widths (`widths=`) to fit the container (about its width minus 36px), so there's no horizontal scrollbar.
- Size in-cell images with table `grid` `imageWidth` / `imageHeight`, and make the column about 15px wider than the image.
- **Conditional colour from a measure** ("field value") is `{"solid": {"color": {"expr": {"Measure": …}}}}` (`pbir.colour_measure`). Fixed colours for fixed lists are set per value (`series_colours`, `pbir.series_colour`).
- **Open matrix row levels by default** (`pbir.matrix(..., expanded=True)`, or a number of levels). A collapsed matrix shows a few top-level rows and a lot of empty space. Both parts of Desktop's "expand all down" form are needed, or the service shows the matrix collapsed:
  - `"active": true` on every shown `Rows` projection;
  - `expansionStates` with one entry per row level (`isCollapsed: true` only on levels left closed, `identityKeys` on all but the last) and `"root": {}`.

  Per-member `root.children` toggles depend on the data, so don't use them.

## Drillthrough and buttons

- Keep the target page's drillthrough binding (`pbir.set_drillthrough`, a hidden page) and a Back button (`pbir.back_button`).
- On the source page, add a drillthrough button (`pbir.drillthrough_button`) whose text comes from a measure that changes once one row is selected. Its `visualContainerObjects.visualLink` has `type 'Drillthrough'` and `drillthroughSection` set to the target page name; style the `default`, `hover` and `disabled` states via `{"id": …}` selectors.
- **Place buttons outside other visuals.** A selected visual is drawn on top and hides anything overlapping it. With three or more dropdowns, the slicers reach far enough left to cover the header subtitle line: end the button before the first slicer's x. `write_page` prints a warning for overlapping visuals (`pbir.find_overlaps`); fix every one before publishing.
- **Bind to a unique column.** If the record has no unique reference, bind to a unique column such as its `Url` and show a readable reference in the button text. Check uniqueness with DAX (`DISTINCTCOUNT` against `COUNTROWS`).
- **Button `show` needs its own entry.** Put `show` for a button's `text`, `outline` and `fill` in an entry with no selector, and the styling in the `{"id": "default"}` entry. A `show` inside the default entry is ignored, and the button draws as a bare icon or an empty box.
- **Web URL button**: `visualLink` `type 'WebUrl'` with `webUrl` set to a measure expression (`pbir.link_button`). The service opens it in a new tab.
- **Link columns**: a `Url` column with `dataCategory: WebUrl`, shown as an icon with table `values` `urlIcon: true` (`pbir.link_column`, or `pbir.add_link_column` for an existing table, which keeps Desktop edits and narrows the other columns to fit).

## Theme

- Register the theme with `pbir.apply_theme` (`copy_from=` copies it unchanged from another report). Put formatting in the theme rather than on visuals.
- **Slicer fonts**: relative date slicer inputs ignore text size settings (they render at about 8pt). Set slicer `items` (and `date`) text to 8pt in the theme so dropdowns match.
