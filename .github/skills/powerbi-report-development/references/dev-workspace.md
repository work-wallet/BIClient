# Developing Against a Power BI Workspace

The loop: edit files, publish to a development workspace (seconds), check measures with DAX, then check the rendered pages in the integrated browser.

## One-off setup (by the user)

- Create a dedicated development workspace. A Pro workspace is enough.
- Publish the model and report to it once from Power BI Desktop, and set the data source credentials in the service.
- Sign the Azure CLI in to the workspace's tenant: `az login --tenant <tenant> --allow-no-subscriptions`.
- Give the agent the workspace URL, from which it can read the IDs (`Get-PbiItems` lists the reports and models).
- Keep workspace, report and model IDs in the session only. Never commit them.

## Publish

Dot-source `Tools/PowerBI/PowerBIDev.ps1`, then:

- `Publish-PbiReport` for layout changes (it rebinds the report to the published model).
- `Publish-PbiSemanticModel` for model changes.
- Measure-only changes need no refresh.
- Refresh (`Invoke-PbiRefresh -Wait`) after adding tables, columns or calculated tables.
- **Refresh limits**: Pro workspaces allow 8 API-triggered refreshes per model in any rolling 24 hours ("exceeded the amount of requests"), so only refresh when needed. The error says "Retry in 120 seconds", but retrying doesn't help until the oldest of the 8 is 24 hours old; check the model's refresh history. When the limit is hit, ask the user to use "Refresh now" on the semantic model in the service; manual refreshes aren't counted.
- Publishing several reports in a row can also hit the Fabric API's short-term rate limit; wait about two minutes and continue.

## Verify measures

After every model change:

- `Test-PbiMeasures -TmdlPath '<...>/<Module> Measures.tmdl'` evaluates every measure in the file and lists any that fail.
- `Invoke-PbiDax` with `CALCULATETABLE ( ROW ( … ), <filters> )` tests specific contexts (a date range, one record, ties, the report-level filters).
- `Get-PbiMeasureValues -Filters …` lists every measure's value in one context.
- DAX errors arrive in the response body of a successful HTTP call; `Invoke-PbiDax` raises them.

## Check pages in the browser

- **Open a page**: `https://app.powerbi.com/groups/<workspaceId>/reports/<reportId>/<pageName>?experience=power-bi&chromeless=1`. The user signs in once in the integrated browser; `chromeless=1` hides the service chrome.
- **Filter by URL** to reach a specific record: `&filter=Table/Column eq 'value'`, encoding spaces in names as `_x0020_`. The URL filter is added to the viewer's persisted state, including filters carried by an earlier drillthrough (such as the date range), so a record outside that state shows blank.
- **Allow time to render**: wait about 15 seconds after navigating, and take a second screenshot if the first shows grey placeholders. Reload after each publish, because the browser caches the report. A plain reload can still show the previous version; navigate to the URL with a throwaway query parameter (e.g. `&nocache=<timestamp>`) to force a fresh load.
- **Slicers remember the viewer's last selection** (persistent filters), so a changed default won't show until you click "Reset to default". That button is in the full view; it isn't available with `chromeless=1`.
- **The tab must be visible to render.** If visuals measure zero size or the canvas is blank, ask the user to bring the browser tab into view.
- **Screenshots can be stale.** Prefer saving the live render to a file with Playwright, `page.screenshot({ path })`, then viewing the file. Confirm details by measuring the live page with `page.evaluate`:
  - element positions (`getBoundingClientRect`) and computed font sizes;
  - card tiles are `.small-multiples-grid-cell-content`, tables are `[role="grid"]`.
- **Full canvas**: `page.setViewportSize({ width: 1700, height: 1000 })` shows the whole canvas.
- **Test interactions** with Playwright: click a table row (`getByText(...).click()` or `page.mouse.click(x, y)`), click buttons, and right-click → Drill through. A button's own label can intercept locator clicks; click it by position instead.
  - Clicking a selected row again deselects it, and clicking a header re-sorts the table. Click a body cell once (locate it with `[role=gridcell][data-query-ref="Table.Column"]`), then check the button text changed before clicking it.
- **Links that leave the report** (link columns, web URL buttons) open a new tab, which Playwright clicks inside the report frame don't capture reliably. Check the URL with DAX instead (`SELECTEDVALUE` of the `Url` column for one record), then open that URL directly.
