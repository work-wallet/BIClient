---
description: "Work Wallet house style for Power BI reports: theme, 1280x720 page grid, header and eyebrow, slicer placement, four-tile KPI row, compact detail pages, colours, fonts, wording, date formats and button looks. Use when designing, laying out or restyling report pages or visuals, or changing the report theme or Tools/PowerBI/report_style.py. A project with a different brand replaces this file and the style tokens."
applyTo: "PowerBISamples/**, Tools/PowerBI/**"
---

# Work Wallet Report Style

This is the house style for the Work Wallet sample reports. It covers how reports look, not how they work: the mechanics (PBIR, TMDL, DAX) are in the `powerbi-report-development` skill.

A report with a different brand (e.g. a customer's own) replaces three things together:

- this file;
- the style tokens (`Tools/PowerBI/report_style.py`: `report_style.use(...)`);
- the theme file (`StaticResources/RegisteredResources/<theme>.json`).

## Theme and tokens

- **Theme**: `StaticResources/RegisteredResources/WorkWallet.json`. Copy it unchanged from a report that already uses it (`pbir.apply_theme(copy_from=...)`) and keep every copy identical.
- **Put formatting in the theme**, not on individual visuals (page background, card tiles, table headers, slicers). Set slicer `items` (and `date`) text to 8pt in the theme, to match relative date slicers, which ignore text size settings.
- **Style tokens** (`report_style.WORK_WALLET`) hold the colours, fonts and type sizes that the builders and the `Colour Good` / `Colour Bad` / `Colour Neutral` measures use. They must match the theme.

  | Token | Value | Used for |
  | --- | --- | --- |
  | `ink` / `ink_2` | `#1E2B37` / `#4A5568` | Text / secondary text (subtitles) |
  | `accent` | `#C9901A` | Header eyebrow |
  | `good` / `mid` / `bad` | `#2E9E6B` / `#ECB232` / `#D6493A` | Favourable / middle / unfavourable |
  | `neutral` | `#4A5568` | No change, or nothing to compare with |
  | Font | Segoe UI (Semibold for titles, eyebrow and buttons) | All text |

## Page layout

- **Canvas** 1280 × 720 (`pbir.W`, `pbir.H`), 24px side margins, 12px gaps. The layout constants are in `Tools/PowerBI/pbir.py`.
- **No in-canvas navigation menus.** Users switch pages with the Power BI page tabs, Pages pane or app navigation.
- **Header** (`pbir.header`, x 24, y 8, 720 × 64; or `pbir.page_header`, which also places the slicers and narrows the header so it never runs under them): one textbox holding
  - an 8pt accent eyebrow, `WORK WALLET  ·  <MODULE>` (`pbir.settings.eyebrow`);
  - an 18pt title;
  - a 9pt grey subtitle saying what the page shows. On current-state pages (no date slicer), say "as at the last data refresh".
- **Slicers**: top right, y 10, height 58, right-aligned to x 1256, 12px apart. Date slicers are about 300 wide, dropdowns about 180.
  - Relative date slicers ("Last 12 months" by default), in one sync group per report, all with the same default period.
- **KPI row** (`pbir.kpi_cards`): one card visual at y 80, height 124, with **four tiles**.
  - Each tile has a label, an 18pt value (13pt for text values such as names) and a reference label, usually the trend against the previous period (`▲ 7% vs previous period`), coloured good or bad.
  - Values show in full (1,347, not 1.35K).
  - Always four tiles: with fewer, the tiles stretch and the page no longer fits. If a page has only three natural KPIs, add a relevant related one.
- **Body**: y 216 to 704.
- **Dense detail pages** (drillthrough targets with many tables) use the compact rhythm:
  - summary cards at y 74, height 72, 8px gaps, ending at y 712, with 12pt values and at most six tiles (about 200px each);
  - long values (locations, "name (company)", free text) in wrapping text cards (`pbir.text_card`, 9pt, at least 72px tall);
  - 9pt titles and 6/10px padding on small tables, with column widths that fit the container (about its width minus 36px).

## Visuals

- **Names**: sentence case for page names, visual titles and column display names.
- **Colours**:
  - Semantic colours for good, bad and neutral, from the tokens (in DAX, the `Colour …` measures).
  - Fixed lists (e.g. severity, card colour) get fixed colours by code. Let the theme colour everything else.
  - Heatmaps: `score_gradient` (bad, mid, good across 0–100%) for percentages, `count_gradient` (light to bad) for counts.
  - Prefer colours the data provides (e.g. a wallet's grading set colours) to fixed thresholds.
- **Avoid donut charts** and other visuals that become unreadable with many categories. Rank with bar charts limited to a Top N.
- **Drillthrough button** (`pbir.drillthrough_button`): dark, on the header subtitle line, reading "Select an item…" until one row is selected, then "View X details  ›".
- **Detail page header buttons**: "Open in Work Wallet  ↗" (`pbir.link_button`) to the left of "←  Back" (`pbir.back_button`), both white and outlined, top right.
- **Link columns**: headed "Link", shown as a link icon, the last column of a table.

## Wording and formats

- **Dates**: `dd/mm/yyyy`, and `dd/mm/yyyy hh:nn` for date/times (UK).
- **Numbers**: counts as whole numbers with thousands separators (`#,0`), averages to one decimal place (`#,0.0`), percentages as `0%`.
- **Plain, present-tense labels.** Avoid "1 hours"-style plurals; use "within an hour", "the same day" and "the next day" for small values.
- **Empty data**: say so on the page (e.g. "None recorded in this period") rather than show an empty visual.
