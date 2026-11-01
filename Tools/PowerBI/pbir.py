"""Helpers for generating Power BI report (PBIR) definition files from Python.

The committed report files are the source of truth. These helpers create new pages and visuals, or restyle
a report in bulk, in the house style. Scripts that use them are throwaway (keep them in the agent's session
workspace, not the repo). Change an existing report with targeted edits: edit the visual.json directly, or
generate only the visuals being changed.

    import sys; sys.path.insert(0, "Tools/PowerBI")
    import pbir as p

    p.settings.measures_table = "Example Measures"
    p.settings.eyebrow = "WORK WALLET  ·  EXAMPLES"
    visuals = [
        p.header(PAGE, "Examples list", "Every example in the selected period."),
        p.date_slicer(PAGE, 956, 300, display="Created on", months=12),
        p.kpi_cards(PAGE, [(p.MS("Examples", "Total examples"), "Examples Trend Label", "Examples Trend Colour")]),
        p.table(PAGE, "table", p.MARGIN, p.BODY_Y, p.CONTENT_W, p.BODY_H, [p.C("Example", "Reference")], "Register"),
    ]
    p.write_page(REPORT_DIR, PAGE, "Examples list", visuals)

Safety: write_page() and apply_theme() refuse to write when the target has uncommitted changes, and
write_page() only writes the visuals it is given. Other visuals on the page are kept unless replace_all=True.

Visual names (folder names) are derived from uuid5(page id + key), so re-running produces the same files.
Output matches Power BI Desktop's saved form, so a Desktop save should leave generated files unchanged.
After any regeneration, check `git diff` shows only the intended changes.

Colours, fonts, type sizes and the theme file come from report_style.current (the Work Wallet house style by
default; see report_style.py). The layout constants below are the canvas grid.
"""
from __future__ import annotations

import json
import shutil
import uuid
from dataclasses import dataclass, field
from pathlib import Path

import report_style as rs
from _guard import require_clean

VC_SCHEMA = "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.14.0/schema.json"


@dataclass
class Settings:
    measures_table: str = "Measures"
    eyebrow: str | None = None  # header eyebrow text; None uses the style's eyebrow
    namespace: uuid.UUID = field(default_factory=lambda: uuid.UUID("0b8a3c1e-52f4-4f6e-8d4e-7a1c9e2b3d47"))


settings = Settings()

# ---------------------------------------------------------------------------------------- layout
# 1280 x 720 canvas. Header strip, KPI card row, then the body.
W, H = 1280, 720
MARGIN, GAP = 24, 12
CONTENT_W = W - 2 * MARGIN
HEADER_Y, HEADER_H = 8, 64
SLICER_Y, SLICER_H = 10, 58
KPI_Y, KPI_H = 80, 124
BODY_Y = KPI_Y + KPI_H + GAP
BODY_BOTTOM = H - 16
BODY_H = BODY_BOTTOM - BODY_Y

# Compact rhythm for dense pages (e.g. drillthrough detail pages with many small tables).
COMPACT_TOP, COMPACT_SUMMARY_H, COMPACT_GAP, COMPACT_BOTTOM = 74, 72, 8, 712

# Colour names kept for build scripts (p.INK, p.BAD, ...); they read the current style when used.
_STYLE_ALIASES = {"INK": "ink", "INK_2": "ink_2", "ACCENT": "accent", "GOOD": "good", "MID": "mid", "BAD": "bad",
                  "SEMIBOLD": "font_stack_semibold"}


def __getattr__(name):
    if name in _STYLE_ALIASES:
        return getattr(rs.current, _STYLE_ALIASES[name])
    raise AttributeError(f"module {__name__!r} has no attribute {name!r}")


def vid(*parts: str) -> str:
    """Stable 20-character visual name."""
    return uuid.uuid5(settings.namespace, "/".join(parts)).hex[:20]


# ------------------------------------------------------------------------------- expressions
def lit(v):
    return {"expr": {"Literal": {"Value": v}}}


def s(text: str):
    """String literal."""
    return lit("'" + text.replace("'", "''") + "'")


def b(v: bool):
    return lit("true" if v else "false")


def n(v):
    """Double literal (font sizes, widths, percentages)."""
    return lit(f"{v}D")


def i(v):
    """Integer literal (paddings, counts)."""
    return lit(f"{v}L")


def colour(hex_: str):
    return {"solid": {"color": s(hex_)}}


def colour_measure(name: str, entity: str | None = None):
    """'Field value' conditional colour: the measure returns a hex colour string."""
    return {"solid": {"color": {"expr": meas(name, entity)}}}


def col(entity: str, prop: str):
    return {"Column": {"Expression": {"SourceRef": {"Entity": entity}}, "Property": prop}}


def meas(prop: str, entity: str | None = None):
    return {"Measure": {"Expression": {"SourceRef": {"Entity": entity or settings.measures_table}}, "Property": prop}}


SUM, MIN = 0, 3
_AGG_NAMES = {SUM: "Sum", MIN: "Min"}


def agg(entity: str, prop: str, fn: int):
    return {"Aggregation": {"Expression": col(entity, prop), "Function": fn}}


def ref(f) -> str:
    """queryRef for a field expression, e.g. 'Table.Column', 'Min(Table.Column)'."""
    if "Column" in f:
        return f"{f['Column']['Expression']['SourceRef']['Entity']}.{f['Column']['Property']}"
    if "Measure" in f:
        return f"{f['Measure']['Expression']['SourceRef']['Entity']}.{f['Measure']['Property']}"
    a = f["Aggregation"]
    return f"{_AGG_NAMES[a['Function']]}({ref(a['Expression'])})"


def proj(f, display: str | None = None, active: bool | None = None):
    """Projection in Desktop's key order: field, queryRef, nativeQueryRef, active, displayName."""
    r = ref(f)
    p = {"field": f, "queryRef": r, "nativeQueryRef": display or r.split(".", 1)[1].rstrip(")")}
    if active is not None:
        p["active"] = active
    if display:
        p["displayName"] = display
    return p


def C(entity: str, prop: str, display: str | None = None):
    """Column projection."""
    return proj(col(entity, prop), display)


def MS(prop: str, display: str | None = None, entity: str | None = None):
    """Measure projection (defaults to the measures table)."""
    return proj(meas(prop, entity), display)


def A(entity: str, prop: str, fn: int, display: str | None = None):
    """Aggregated column projection, e.g. A('Example', 'Reference', MIN) for text cards."""
    return proj(agg(entity, prop, fn), display)


def props(**kw):
    return [{"properties": kw}]


def sel_props(selector, **kw):
    return {"properties": kw, "selector": selector}


DEFAULT = {"id": "default"}
ALL_DATA = {"data": [{"dataViewWildcard": {"matchingOption": 1}}]}


def title(text: str, subtitle: str | None = None, size: float | None = None, subtitle_measure: str | None = None):
    """Visual title and optional subtitle. subtitle_measure: a text measure for a dynamic subtitle (e.g. one
    that says 'None recorded in this period' so an empty visual explains itself)."""
    o = {"title": props(show=b(True), text=s(text), **({"fontSize": n(size)} if size else {}))}
    if subtitle_measure:
        o["subTitle"] = props(show=b(True), text={"expr": meas(subtitle_measure)})
    elif subtitle:
        o["subTitle"] = props(show=b(True), text=s(subtitle))
    return o


# ----------------------------------------------------------------------------------- visuals
def container(page, key, vtype, x, y, w, h, z, visual_extra, container_objects=None, filters=None, extra=None):
    """Generic visual container. z doubles as tab order. Written in Power BI Desktop's canonical form
    (key order, 'active' flags on hierarchical roles, whole-number positions) so Desktop saves don't churn."""
    v = {"visualType": vtype, **visual_extra}
    if not v.get("objects"):
        v.pop("objects", None)  # Desktop removes empty "objects": {}
    _set_active_flags(v.get("query", {}).get("queryState", {}))
    if container_objects:
        v["visualContainerObjects"] = container_objects
    if "syncGroup" in v:
        v["syncGroup"] = v.pop("syncGroup")
    v["drillFilterOtherVisuals"] = True
    d = {
        "$schema": VC_SCHEMA,
        "name": vid(page, key),
        "position": {k: _num(val) for k, val in {"x": x, "y": y, "z": z, "height": h, "width": w, "tabOrder": z}.items()},
        "visual": v,
    }
    if filters:
        d["filterConfig"] = {"filters": filters}
    if extra:
        d.update(extra)
    return d


def _num(v):
    """Positions in whole pixels. Desktop writes fractional numbers with up to 17 significant digits
    (e.g. 770.40000000000009) where Python writes 770.4000000000001, so fractions would churn on every save."""
    return int(round(v))


# Desktop marks the expanded level of hierarchical roles: first projection active, the rest inactive
# (unless a matrix is expanded, when every shown level is active).
_ACTIVE_ROLES = ("Category", "Rows", "Columns")


def _with_active(p, active: bool):
    rebuilt = {k: p[k] for k in ("field", "queryRef", "nativeQueryRef")}
    rebuilt["active"] = active
    rebuilt.update({k: v for k, v in p.items() if k not in rebuilt})
    return rebuilt


def _set_active_flags(query_state):
    for role in _ACTIVE_ROLES:
        projections = query_state.get(role, {}).get("projections", [])
        for idx, p in enumerate(projections):
            if "active" not in p:
                projections[idx] = _with_active(p, idx == 0)


def header(page, heading, subtitle, eyebrow: str | None = None, width=720):
    """Single textbox: small accent eyebrow, title and subtitle (sizes from the style)."""
    st = rs.current

    def run(text, size, weight=None, colour_=None, family=None):
        style = {"fontFamily": family or st.font, "fontSize": f"{size}pt", "color": colour_ or st.ink}
        if weight:
            style["fontWeight"] = weight
        return {"value": text, "textStyle": style}

    paragraphs = [
        {"textRuns": [run(eyebrow or settings.eyebrow or st.eyebrow, st.eyebrow_size, "bold", st.accent, st.font_semibold)]},
        {"textRuns": [run(heading, st.title_size, "bold", st.ink, st.font_semibold)]},
        {"textRuns": [run(subtitle, st.subtitle_size, None, st.ink_2)]},
    ]
    return container(page, "header", "textbox", MARGIN, HEADER_Y, width, HEADER_H, 100,
                     {"objects": {"general": props(paragraphs=paragraphs)}})


def date_slicer(page, x, w, display, months=None, years=None, entity="Date", prop="Slicer Date", sync_group=None):
    """Relative date slicer ('Last N months/years', including today). Defaults to Date[Slicer Date], which counts
    future dates as today, so upcoming (future-dated) records are included too."""
    duration, period, unit = (months, "Months", 2) if months else (years, "Years", 3)
    flt = {"Version": 2, "From": [{"Name": "d", "Entity": entity, "Type": 0}], "Where": [{"Condition": {"Between": {
        "Expression": {"Column": {"Expression": {"SourceRef": {"Source": "d"}}, "Property": prop}},
        "LowerBound": {"DateSpan": {"Expression": {"DateAdd": {"Expression": {"DateAdd": {
            "Expression": {"Now": {}}, "Amount": 1, "TimeUnit": 0}}, "Amount": -duration, "TimeUnit": unit}}, "TimeUnit": 0}},
        "UpperBound": {"DateSpan": {"Expression": {"Now": {}}, "TimeUnit": 0}}}}}]}
    return container(page, "slicer-date", "slicer", x, SLICER_Y, w, SLICER_H, 3000, {
        "query": {"queryState": {"Values": {"projections": [proj(col(entity, prop), display, active=True)]}}},
        "objects": {
            "data": props(mode=s("Relative"), relativeRange=s("Last"), relativeDuration=n(duration), relativePeriod=s(period)),
            "dateRange": props(includeToday=b(True)),
            "general": props(filter={"filter": flt}),
        },
        "syncGroup": {"groupName": sync_group or display, "fieldChanges": True, "filterChanges": True},
    })


def dropdown_slicer(page, key, entity, prop, display, x, w, z=3001):
    """Multi-select dropdown slicer with no saved selection."""
    return container(page, key, "slicer", x, SLICER_Y, w, SLICER_H, z, {
        "query": {"queryState": {"Values": {"projections": [proj(col(entity, prop), display, active=True)]}}},
        "objects": {"data": props(mode=s("Dropdown")), "selection": props(strictSingleSelect=b(False))},
    })


def kpi_cards(page, tiles, y=KPI_Y, h=KPI_H, key="kpis", value_size=None, padding=(10, 2, 14, 10), cell_padding=GAP):
    """One new-style card visual (cardVisual) holding a row of KPI tiles.

    tiles: list of (projection, reference_label_measure, reference_colour_measure[, value_font_size]).
    The reference label is a text measure shown under the value (e.g. '▲ 7% vs previous period');
    its font colour can come from a colour measure. padding = (top, bottom, left, right) of the callout.
    Reference label padding, if ever needed, is paddingTop/paddingBottom/paddingLeft/paddingRight on
    referenceLabel (not the *Margin names used by the padding object; Desktop drops those).
    """
    ref_labels = [sel_props(DEFAULT, backgroundShow=b(False), paddingIndividual=b(True))]
    projections, ref_values = [], []
    values = [sel_props(DEFAULT, fontSize=n(value_size or rs.current.kpi_value_size), labelDisplayUnits=n(1))]  # 1 = no "K"/"M" abbreviation
    for tile in tiles:
        p, label_measure, colour_measure_name = tile[:3]
        projections.append(p)
        if len(tile) > 3:
            values.append(sel_props({"metadata": p["queryRef"]}, fontSize=n(tile[3])))
        if label_measure:
            fid = f"field-{uuid.uuid5(settings.namespace, page + key + p['queryRef'])}"
            ref_labels.append({"properties": {"value": {"expr": meas(label_measure)}},
                               "selector": {"data": [{"dataViewWildcard": {"matchingOption": 0}}],
                                            "metadata": p["queryRef"], "id": fid, "order": 0}})
            if colour_measure_name:
                ref_values.append(sel_props({"metadata": p["queryRef"], "id": fid},
                                            valueFontColor=colour_measure(colour_measure_name)))
    objects = {
        # calloutSize = % of each tile given to label + value; the rest holds the reference label.
        "layout": props(orientation=n(2), maxTiles=i(len(tiles)), alignment=s("middle"), cellPadding=i(cell_padding),
                        calloutSize=n(62 if len(ref_labels) > 1 else 100)),
        "padding": [sel_props(DEFAULT, paddingIndividual=b(True), topMargin=i(padding[0]), bottomMargin=i(padding[1]),
                              leftMargin=i(padding[2]), rightMargin=i(padding[3]))],
        "value": values,
        "spacing": [sel_props(DEFAULT, verticalSpacing=i(2))],
        "referenceLabel": ref_labels,
    }
    if ref_values:
        objects["referenceLabelValue"] = ref_values
    return container(page, key, "cardVisual", MARGIN, y, CONTENT_W, h, 2000, {
        "query": {"queryState": {"Data": {"projections": projections}}},
        "objects": objects,
    })


def table(page, key, x, y, w, h, columns, title_text, subtitle=None, sort=None, widths=None, objects=None, z=1000,
          title_size=None, container_extra=None, filters=None, subtitle_measure=None):
    """Table (tableEx). sort: [(field, 'Ascending'|'Descending')]; widths: per-column px or None.
    A link_column() among the columns is shown as a link icon."""
    q = {"queryState": {"Values": {"projections": columns}}}
    if sort:
        q["sortDefinition"] = {"sort": [{"field": f, "direction": d} for f, d in sort]}
    obj = dict(objects or {})
    if any(c.get("displayName") == LINK_DISPLAY for c in columns):
        _set_url_icon(obj)
    if widths:
        obj["columnWidth"] = [sel_props({"metadata": c["queryRef"]}, value=n(wd)) for c, wd in zip(columns, widths) if wd]
        obj.setdefault("columnHeaders", props())  # Desktop adds an empty columnHeaders to tables with widths
    if "columnHeaders" in obj:
        obj["columnHeaders"] = obj.pop("columnHeaders")  # Desktop writes columnHeaders after columnWidth
    co = title(title_text, subtitle, title_size, subtitle_measure)
    co.update(container_extra or {})
    return container(page, key, "tableEx", x, y, w, h, z, {"query": q, "objects": obj}, co, filters=filters)


def image_grid(width=110, height=20):
    """Table 'grid' settings sizing in-cell images (SVG measures with dataCategory ImageUrl)."""
    return {"grid": props(imageHeight=n(height), imageWidth=n(width))}


# ------------------------------------------------------------------------- Work Wallet links
# Deep links back to the record in the Work Wallet portal. The model holds the URL in a calculated column
# with dataCategory WebUrl (tmdl.portal_url_column); a table shows it as a link icon in a 'Link' column, and a
# drillthrough page uses a button that opens the selected record's URL (link_button).
LINK_DISPLAY = "Link"
LINK_WIDTH = 50


def link_column(entity: str, prop: str = "Url"):
    """'Link' column for table(): shown as a link icon that opens the record in Work Wallet."""
    return C(entity, prop, LINK_DISPLAY)


def _set_url_icon(objects: dict):
    """Turns on 'URL icon' (values.urlIcon) so WebUrl columns show an icon rather than the address."""
    values = objects.get("values", [])
    general = next((v for v in values if "selector" not in v), None)
    if general is None:
        values.insert(0, {"properties": {"urlIcon": b(True)}})
    else:
        general["properties"]["urlIcon"] = b(True)
    rest = {k: v for k, v in objects.items() if k != "values"}
    objects.clear()
    objects.update({"values": values, **rest})  # Desktop writes values first


def add_link_column(visual_json: Path, entity: str, prop: str = "Url", width: int = LINK_WIDTH,
                    allow_dirty: bool = False) -> bool:
    """Adds a 'Link' column (link_column) to the end of an existing table visual, keeping any edits made in
    Desktop. If the table has fixed column widths, the other columns are narrowed in proportion so the table
    stays the same width. Returns False if the table already has the column."""
    visual_json = Path(visual_json)
    require_clean(visual_json, allow_dirty)
    v = json.loads(visual_json.read_text(encoding="utf-8-sig"))
    projections = v["visual"]["query"]["queryState"]["Values"]["projections"]
    new = link_column(entity, prop)
    if any(p_["queryRef"] == new["queryRef"] for p_ in projections):
        return False
    projections.append(new)
    objects = v["visual"].setdefault("objects", {})
    _set_url_icon(objects)
    widths = objects.get("columnWidth")
    if widths:
        def value(entry):
            return float(entry["properties"]["value"]["expr"]["Literal"]["Value"].rstrip("D"))
        total = sum(value(e) for e in widths)
        scale = (total - width) / total
        for e in widths:
            e["properties"]["value"] = n(round(value(e) * scale))
        widths.append(sel_props({"metadata": new["queryRef"]}, value=n(width)))
        if "columnHeaders" in objects:
            objects["columnHeaders"] = objects.pop("columnHeaders")
    write_json(visual_json, v)
    return True


def link_button(page, key, x, y, w, h, url_measure, label="Open in Work Wallet  ↗", entity=None, z=5100):
    """Button that opens a URL from a measure (e.g. SELECTEDVALUE of the record's Url column) in a new tab,
    for drillthrough pages about one record. Styled like back_button, to sit beside it in the header."""
    return container(page, key, "actionButton", x, y, w, h, z, {
        "objects": {
            "icon": [sel_props(DEFAULT, shapeType=s("blank")), {"properties": {"show": b(False)}}],
            **_outlined_button_style(label),
        }}, {"visualLink": props(show=b(True), type=s("WebUrl"), webUrl={"expr": meas(url_measure, entity)})},
        extra={"howCreated": "InsertVisualButton"})


def bar_chart(page, key, x, y, w, h, category, value, title_text, subtitle=None, fill=None, top_n=None, z=1100,
              filters=None):
    """Horizontal bar chart sorted by value descending; optional Top N filter on the category, plus any other
    visual-level filters (e.g. in_filter on a type)."""
    objects = {"labels": props(show=b(True)), "categoryAxis": props(maxMarginFactor=i(45)), "legend": props(show=b(False))}
    if fill:
        objects["dataPoint"] = [fill]
    filters = ([top_n_filter(category["field"], value["field"], top_n)] if top_n else []) + list(filters or [])
    return container(page, key, "clusteredBarChart", x, y, w, h, z, {
        "query": {"queryState": {"Category": {"projections": [category]}, "Y": {"projections": [value]}},
                  "sortDefinition": {"sort": [{"field": value["field"], "direction": "Descending"}]}},
        "objects": objects,
    }, title(title_text, subtitle), filters=filters or None)


def top_n_filter(category_field, order_measure_field, count):
    """Visual-level Top N filter on a column, ranked by a measure."""
    cat = category_field["Column"]
    entity, prop = cat["Expression"]["SourceRef"]["Entity"], cat["Property"]
    m = order_measure_field["Measure"]
    order = {"Measure": {"Expression": {"SourceRef": {"Source": "m"}}, "Property": m["Property"]}}
    return {
        "name": vid("topn", entity, prop),
        "field": category_field,
        "type": "TopN",
        "filter": {
            "Version": 2,
            "From": [{"Name": "subquery", "Expression": {"Subquery": {"Query": {
                "Version": 2,
                "From": [{"Name": "c", "Entity": entity, "Type": 0},
                         {"Name": "m", "Entity": m["Expression"]["SourceRef"]["Entity"], "Type": 0}],
                "Select": [{"Column": {"Expression": {"SourceRef": {"Source": "c"}}, "Property": prop}, "Name": "field"}],
                "OrderBy": [{"Direction": 2, "Expression": order}],
                "Top": count}}}, "Type": 2},
                {"Name": "c", "Entity": entity, "Type": 0}],
            "Where": [{"Condition": {"In": {
                "Expressions": [{"Column": {"Expression": {"SourceRef": {"Source": "c"}}, "Property": prop}}],
                "Table": {"SourceRef": {"Source": "subquery"}}}}}],
        },
    }


def in_filter(entity, prop, values: list):
    """Visual-level 'is one of' filter, e.g. in_filter('Status', 'Status', ["'Reported'"]). Values are PBIR
    literals: "'Text'" for text, '2L' for integers, 'true' for booleans. Filters show in the Filters pane, so
    filter on display names (readable), not codes; use codes in DAX."""
    return {
        "name": vid("in", entity, prop, *values),
        "field": col(entity, prop),
        "type": "Categorical",
        "filter": {"Version": 2, "From": [{"Name": "f", "Entity": entity, "Type": 0}],
                   "Where": [{"Condition": {"In": {
                       "Expressions": [{"Column": {"Expression": {"SourceRef": {"Source": "f"}}, "Property": prop}}],
                       "Values": [[{"Literal": {"Value": v}}] for v in values]}}}]},
        "howCreated": "User",
    }


def measure_filter(entity, measure, kind=">", value="0L"):
    """Visual-level measure filter, e.g. measure_filter('Issue Measures', 'Issues') keeps rows where [Issues] > 0.
    Use it on tables built only from dimension columns: without a measure nothing ties the rows to the
    page's filters (e.g. the selected issue), so every dimension row would be listed."""
    kinds = {"=": 0, ">": 1, ">=": 2, "<": 3, "<=": 4}
    return {
        "name": vid("measure", entity, measure, kind, value),
        "field": {"Measure": {"Expression": {"SourceRef": {"Entity": entity}}, "Property": measure}},
        "type": "Advanced",
        "filter": {"Version": 2, "From": [{"Name": "m", "Entity": entity, "Type": 0}],
                   "Where": [{"Condition": {"Comparison": {
                       "ComparisonKind": kinds[kind],
                       "Left": {"Measure": {"Expression": {"SourceRef": {"Source": "m"}}, "Property": measure}},
                       "Right": {"Literal": {"Value": value}}}}}]},
        "howCreated": "User",
    }


def page_header(page, heading, subtitle, date_display, months=12, dropdowns=(), eyebrow=None):
    """Header strip: the header textbox on the left and slicers right-aligned to the content edge, with the
    header narrowed so it never runs under the slicers. dropdowns: [(key, entity, prop, display), ...].
    date_display=None omits the date slicer (for pages showing current state, e.g. a register).
    Returns the visuals (header, date slicer, dropdown slicers)."""
    date_w, dd_w = 300, 184
    x = W - MARGIN
    dropdown_visuals = []
    for idx, (key, entity, prop, display) in enumerate(reversed(list(dropdowns))):
        x -= dd_w
        dropdown_visuals.insert(0, dropdown_slicer(page, key, entity, prop, display, x, dd_w, z=3001 + idx))
        x -= GAP
    if date_display is None:
        return [header(page, heading, subtitle, eyebrow, width=min(720, x + GAP - MARGIN - GAP))] + dropdown_visuals
    x -= date_w
    return [header(page, heading, subtitle, eyebrow, width=x - MARGIN - GAP),
            date_slicer(page, x, date_w, date_display, months=months)] + dropdown_visuals


def not_blank_filter(entity, prop):
    """Visual-level 'is not blank' filter."""
    return {
        "name": vid("notblank", entity, prop),
        "field": col(entity, prop),
        "type": "Advanced",
        "filter": {"Version": 2, "From": [{"Name": "d", "Entity": entity, "Type": 0}],
                   "Where": [{"Condition": {"Not": {"Expression": {"Comparison": {
                       "ComparisonKind": 0,
                       "Left": {"Column": {"Expression": {"SourceRef": {"Source": "d"}}, "Property": prop}},
                       "Right": {"Literal": {"Value": "null"}}}}}}}]},
        "howCreated": "User",
    }


def score_gradient(measure_name):
    """Fixed 0% (bad) / 50% / 100% (good) colour scale for 0-1 percentage measures: no business thresholds."""
    st = rs.current
    return {"solid": {"color": {"expr": {"FillRule": {
        "Input": meas(measure_name),
        "FillRule": {"linearGradient3": {
            "min": {"color": s(st.bad)["expr"], "value": n(0)["expr"]},
            "mid": {"color": s(st.mid)["expr"], "value": n(0.5)["expr"]},
            "max": {"color": s(st.good)["expr"], "value": n(1)["expr"]},
            "nullColoringStrategy": {"strategy": s("noColor")["expr"]}}}}}}}}


def count_gradient(measure_name, low=None, high=None):
    """Data-driven light-to-red scale for counts (heatmap cells); defaults to the style's heat_low and bad."""
    return {"solid": {"color": {"expr": {"FillRule": {
        "Input": meas(measure_name),
        "FillRule": {"linearGradient2": {
            "min": {"color": s(low or rs.current.heat_low)["expr"]},
            "max": {"color": s(high or rs.current.bad)["expr"]},
            "nullColoringStrategy": {"strategy": s("noColor")["expr"]}}}}}}}}


def drillthrough_button(page, key, x, y, w, h, target_page, label_measure):
    """Button that drills through using the current selection; Power BI enables it once a single value is selected.

    label_measure returns e.g. 'Select an item to view details' / 'View X details  ›'.
    Do not overlap it with the table it depends on: a selected visual is drawn on top and hides it.
    """
    st = rs.current
    states = [(DEFAULT, st.ink, st.surface), ({"id": "hover"}, st.button_hover, st.surface),
              ({"id": "disabled"}, st.button_disabled, st.button_disabled_text)]
    return container(page, key, "actionButton", x, y, w, h, 6000, {
        "objects": {
            "icon": [sel_props(DEFAULT, shapeType=s("blank")), {"properties": {"show": b(False)}}],
            "text": [{"properties": {"show": b(True)}}] + [
                sel_props(sel, text={"expr": meas(label_measure)}, fontColor=colour(tc), fontSize=n(st.drill_button_text_size),
                          fontFamily=s(st.font_stack_semibold))
                for sel, _, tc in states],
            "fill": [{"properties": {"show": b(True)}}] + [
                sel_props(sel, fillColor=colour(fc), transparency=n(0)) for sel, fc, _ in states],
            "outline": [{"properties": {"show": b(False)}}],
            "shape": [sel_props(DEFAULT, roundEdge=i(6))],
        }}, {"visualLink": props(show=b(True), type=s("Drillthrough"), drillthroughSection=s(target_page))},
        extra={"howCreated": "InsertVisualButton"})


def back_button(page, key="back", x=W - MARGIN - 150, y=22, w=150, h=36):
    """Back button for drillthrough pages (top right of the header)."""
    return container(page, key, "actionButton", x, y, w, h, 5000, {
        "objects": {
            "icon": [sel_props(DEFAULT, shapeType=s("blank")), {"properties": {"show": b(False)}}],
            **_outlined_button_style("←  Back"),
        }}, {"visualLink": props(show=b(True), type=s("Back"))}, extra={"howCreated": "InsertVisualButton"})


def _outlined_button_style(label):
    """White, outlined button text/outline/fill. 'show' must be set without a selector: a show inside the
    default-state entry is ignored and the button draws as a bare icon (or an empty box)."""
    st = rs.current
    return {
        "text": [{"properties": {"show": b(True)}},
                 sel_props(DEFAULT, text=s(label), fontColor=colour(st.ink), fontSize=n(st.button_text_size))],
        "outline": [{"properties": {"show": b(True)}}, sel_props(DEFAULT, lineColor=colour(st.outline), weight=n(1))],
        "fill": [{"properties": {"show": b(True)}}, sel_props(DEFAULT, fillColor=colour(st.surface))],
    }


# ------------------------------------------------------------------------------- more visuals
def matrix(page, key, x, y, w, h, rows, columns, values, title_text, subtitle=None, cell_colour=None,
           stepped=True, row_header_width=None, filters=None, sort=None, expanded=False, z=1000):
    """Matrix (pivotTable). rows/columns/values: lists of projections. cell_colour: a fill rule (e.g.
    count_gradient) applied to every value cell. Expand/collapse via the row headers (stepped layout).
    expanded=True opens every row level above the last by default (or pass a number of levels); this is
    level-wide, so it doesn't depend on the data. Rows must be plain columns, not hierarchy levels."""
    state = {"Rows": {"projections": rows}, "Values": {"projections": values}}
    if columns:
        state["Columns"] = {"projections": columns}
    q = {"queryState": state}
    if sort:
        q["sortDefinition"] = {"sort": [{"field": f, "direction": d} for f, d in sort]}
    objects = {"rowHeaders": props(stepped=b(stepped))}
    if cell_colour:
        objects["values"] = [sel_props({"data": [{"dataViewWildcard": {"matchingOption": 1}}], "metadata": v["queryRef"]},
                                       backColor=cell_colour) for v in values]
    if row_header_width:
        objects["columnWidth"] = [sel_props({"metadata": rows[0]["queryRef"]}, value=n(row_header_width))]
        objects["columnHeaders"] = props()  # Desktop adds this (after columnWidth) on save
        if columns:
            # ...and, when it rewrites the visual, writes the Columns role first.
            state = {"Columns": state["Columns"], "Rows": state["Rows"], "Values": state["Values"]}
            q["queryState"] = state
    visual = {"query": q}
    if expanded and len(rows) > 1:
        depth = len(rows) - 1 if expanded is True else min(int(expanded), len(rows) - 1)
        # "Expand all down" marks every shown level active and records level-wide (data-independent) states.
        rows = [_with_active(r, idx <= depth) for idx, r in enumerate(rows)]
        state["Rows"]["projections"] = rows
        levels = []
        for idx, r in enumerate(rows):
            level = {"queryRefs": [r["queryRef"]]}
            if idx >= depth:
                level["isCollapsed"] = True
            if idx < len(rows) - 1:
                level["identityKeys"] = [r["field"]]
            level["isPinned"] = True
            levels.append(level)
        visual["expansionStates"] = [{"roles": ["Rows"], "levels": levels, "root": {}}]
    visual["objects"] = objects
    return container(page, key, "pivotTable", x, y, w, h, z, visual, title(title_text, subtitle), filters=filters)


def column_chart(page, key, x, y, w, h, category, values, title_text, subtitle=None, series=None, line=None,
                 series_colours=None, legend=True, clustered=False, z=1000):
    """Stacked column chart by category (e.g. month), optionally split by a series and with a dashed line
    measure (e.g. a monthly average). series_colours: {value: hex} for a fixed palette (e.g. severity).
    clustered=True puts several measures side by side (e.g. raised vs closed) with a legend."""
    if line:
        vtype = "lineClusteredColumnComboChart" if clustered else "lineStackedColumnComboChart"
    else:
        vtype = "clusteredColumnChart" if clustered else "columnChart"
    state = {"Category": {"projections": [category]}, "Y": {"projections": values}}
    if series:
        state["Series"] = {"projections": [series]}
    if line:
        state["Y2"] = {"projections": [line]}
    objects = {"legend": props(show=b(legend and (bool(series) or len(values) > 1)), position=s("Top"))}
    if line:
        objects["lineStyles"] = props(strokeWidth=i(2), lineStyle=s("dashed"), showMarker=b(False))
        objects["valueAxis"] = props(secShow=b(False))
    if series and series_colours:
        objects["dataPoint"] = [series_colour(series["field"], value, hex_) for value, hex_ in series_colours.items()]
    return container(page, key, vtype, x, y, w, h, z, {
        "query": {"queryState": state, "sortDefinition": {"sort": [{"field": category["field"], "direction": "Ascending"}]}},
        "objects": objects}, title(title_text, subtitle))


def series_colour(series_field, value: str, hex_: str):
    """dataPoint entry fixing the colour of one series value (e.g. severity 'High' -> red)."""
    c = series_field["Column"]
    return {"properties": {"fill": colour(hex_)},
            "selector": {"data": [{"scopeId": {"Comparison": {"ComparisonKind": 0,
                                                              "Left": {"Column": c},
                                                              "Right": {"Literal": {"Value": "'" + value.replace("'", "''") + "'"}}}}}]}}


def text_card(page, key, x, y, w, h, value_proj, label=None, font_size=10, z=2000):
    """Single-tile card for a long text value (e.g. an issue overview), wrapped and left aligned."""
    return container(page, key, "cardVisual", x, y, w, h, z, {
        "query": {"queryState": {"Data": {"projections": [value_proj]}}},
        "objects": {
            "layout": props(orientation=n(2), maxTiles=i(1), alignment=s("top"), calloutSize=n(100)),
            "padding": [sel_props(DEFAULT, paddingIndividual=b(True), topMargin=i(8), bottomMargin=i(8),
                                  leftMargin=i(14), rightMargin=i(14))],
            "label": [sel_props(DEFAULT, show=b(bool(label)))],
            "value": [sel_props(DEFAULT, fontSize=n(font_size), textWrap=b(True), horizontalAlignment=s("left"),
                                fontFamily=s(rs.current.font_stack))],
            "accentBar": [sel_props(DEFAULT, show=b(False))],
        }})


# ------------------------------------------------------------------------------------ files
def write_json(path: Path, obj):
    """CRLF, two-space indent, no final line break: the form Power BI Desktop saves."""
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(obj, indent=2, ensure_ascii=False), encoding="utf-8", newline="\r\n")


def write_page(report_dir: Path, page_id: str, display_name: str, visuals: list[dict],
               replace_all: bool = False, allow_dirty: bool = False, page_filters: list | None = None) -> list[str]:
    """Writes the given visuals to a page and sets its display name. Keeps the page's filters and
    drillthrough binding.

    By default only the given visuals are (over)written, and any other visuals on the page are kept; their
    folder names are returned so the caller can check them. replace_all=True deletes every existing visual and
    clears page-level formatting (the theme supplies page background/outspace). Use it only when deliberately
    rebuilding a whole page. Refuses to run if the page has uncommitted changes, unless allow_dirty=True.
    page_filters: when given, replaces the page's filters (e.g. in_filter(...) on a status name); drillthrough
    filters are always kept. Pass [] to remove stale filters.
    """
    pdir = Path(report_dir) / "definition" / "pages" / page_id
    require_clean(pdir, allow_dirty)
    page = json.loads((pdir / "page.json").read_text(encoding="utf-8"))
    page["displayName"] = display_name
    if replace_all:
        page.pop("objects", None)
        shutil.rmtree(pdir / "visuals", ignore_errors=True)
    if page_filters is not None:
        kept_filters = [f for f in page.get("filterConfig", {}).get("filters", []) if f.get("howCreated") == "Drillthrough"]
        if kept_filters or page_filters:
            page["filterConfig"] = {**page.get("filterConfig", {}), "filters": kept_filters + list(page_filters)}
        else:
            page.pop("filterConfig", None)
    write_json(pdir / "page.json", page)
    for v in visuals:
        write_json(pdir / "visuals" / v["name"] / "visual.json", v)
    generated = {v["name"] for v in visuals}
    kept = sorted(d.name for d in (pdir / "visuals").iterdir() if d.is_dir() and d.name not in generated)
    if kept:
        print(f"{display_name}: kept {len(kept)} existing visual(s) not generated here: {', '.join(kept)}")
    for warning in find_overlaps(pdir):
        print(f"{display_name}: WARNING {warning}")
    return kept


def find_overlaps(page_dir: Path, tolerance: float = 0.5) -> list[str]:
    """Visuals on a page that overlap (textboxes excepted: the header deliberately sits under buttons on its
    subtitle line). A selected visual is drawn on top, so an overlapped button or slicer can't be clicked."""
    boxes = []
    for f in sorted(Path(page_dir).glob("visuals/*/visual.json")):
        v = json.loads(f.read_text(encoding="utf-8-sig"))
        vtype = v.get("visual", {}).get("visualType")
        if vtype and vtype != "textbox":
            p = v["position"]
            boxes.append((f"{vtype} {f.parent.name}", p["x"], p["y"], p["x"] + p["width"], p["y"] + p["height"]))
    found = []
    for i, a in enumerate(boxes):
        for b in boxes[i + 1:]:
            if (min(a[3], b[3]) - max(a[1], b[1]) > tolerance) and (min(a[4], b[4]) - max(a[2], b[2]) > tolerance):
                found.append(f"{a[0]} overlaps {b[0]}")
    return found


def apply_theme(report_dir: Path, theme_file: str | None = None, allow_dirty: bool = False,
                copy_from: Path | None = None):
    """Registers StaticResources/RegisteredResources/<theme_file> (default: the style's theme file) as the report's
    custom theme. copy_from: a report folder that already has the theme; it is copied unchanged (keeps every copy
    identical)."""
    theme_file = theme_file or rs.current.theme_file
    report_path = Path(report_dir) / "definition" / "report.json"
    require_clean(report_path, allow_dirty)
    if copy_from:
        src = Path(copy_from) / "StaticResources" / "RegisteredResources" / theme_file
        dst = Path(report_dir) / "StaticResources" / "RegisteredResources" / theme_file
        dst.parent.mkdir(parents=True, exist_ok=True)
        dst.write_bytes(src.read_bytes())
    report = json.loads(report_path.read_text(encoding="utf-8"))
    report["themeCollection"]["customTheme"] = {
        "name": theme_file,
        "reportVersionAtImport": {"visual": "2.4.0", "report": "3.0.0", "page": "2.3.0"},
        "type": "RegisteredResources",
    }
    packages = [p for p in report["resourcePackages"] if p["name"] != "RegisteredResources"]
    packages.append({"name": "RegisteredResources", "type": "RegisteredResources",
                     "items": [{"name": theme_file, "path": theme_file, "type": "CustomTheme"}]})
    report["resourcePackages"] = packages
    write_json(report_path, report)


PAGE_SCHEMA = "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/page/2.0.0/schema.json"


def create_page(report_dir: Path, page_id: str, display_name: str) -> bool:
    """Creates an empty 1280x720 page (and adds it to pages.json) if it doesn't exist. Returns True if created."""
    pdir = Path(report_dir) / "definition" / "pages" / page_id
    if (pdir / "page.json").exists():
        return False
    write_json(pdir / "page.json", {"$schema": PAGE_SCHEMA, "name": page_id, "displayName": display_name,
                                    "displayOption": "FitToPage", "height": H, "width": W})
    pages_path = Path(report_dir) / "definition" / "pages" / "pages.json"
    pages = json.loads(pages_path.read_text(encoding="utf-8"))
    pages["pageOrder"].append(page_id)
    write_json(pages_path, pages)
    return True


def delete_page(report_dir: Path, page_id: str, allow_dirty: bool = False) -> bool:
    """Deletes a page (e.g. one whose content has been folded into another page) and removes it from
    pages.json. Refuses if the page has uncommitted changes. Returns True if deleted."""
    pdir = Path(report_dir) / "definition" / "pages" / page_id
    if not pdir.exists():
        return False
    require_clean(pdir, allow_dirty)
    shutil.rmtree(pdir)
    pages_path = Path(report_dir) / "definition" / "pages" / "pages.json"
    pages = json.loads(pages_path.read_text(encoding="utf-8"))
    pages["pageOrder"] = [p for p in pages["pageOrder"] if p != page_id]
    if pages.get("activePageName") == page_id:
        pages["activePageName"] = pages["pageOrder"][0]
    write_json(pages_path, pages)
    return True


def set_page_order(report_dir: Path, page_ids: list[str], active: str | None = None):
    """Sets the page tab order (every existing page must be listed) and the page the report opens on."""
    pages_path = Path(report_dir) / "definition" / "pages" / "pages.json"
    pages = json.loads(pages_path.read_text(encoding="utf-8"))
    assert sorted(pages["pageOrder"]) == sorted(page_ids), "page_ids must list every page exactly once"
    pages["pageOrder"] = page_ids
    pages["activePageName"] = active or page_ids[0]
    write_json(pages_path, pages)


def set_drillthrough(report_dir: Path, page_id: str, entity: str, prop: str, hidden: bool = True):
    """Makes a page a drillthrough target on Entity[prop] (e.g. a record reference) and hides it from the
    page tabs (it is reached by drilling through, so it shouldn't be opened directly)."""
    path = Path(report_dir) / "definition" / "pages" / page_id / "page.json"
    page = json.loads(path.read_text(encoding="utf-8"))
    filter_name = vid("drillthrough-filter", page_id)
    page["filterConfig"] = {"filters": [{"name": filter_name, "field": col(entity, prop), "type": "Categorical",
                                         "howCreated": "Drillthrough"}]}
    page["pageBinding"] = {"name": vid("drillthrough-binding", page_id), "type": "Drillthrough",
                           "parameters": [{"name": vid("drillthrough-param", page_id), "boundFilter": filter_name,
                                           "fieldExpr": col(entity, prop)}]}
    if hidden:
        page["visibility"] = "HiddenInViewMode"
    write_json(path, page)


def remove_report_filters(report_dir: Path, entity: str, prop: str) -> int:
    """Removes report-level filters on Entity[prop] (e.g. a stale filter on a status display name). Returns the
    number removed."""
    path = Path(report_dir) / "definition" / "report.json"
    report = json.loads(path.read_text(encoding="utf-8"))
    filters = report.get("filterConfig", {}).get("filters", [])
    kept = [f for f in filters if f.get("field") != col(entity, prop)]
    if len(kept) != len(filters):
        report["filterConfig"]["filters"] = kept
        write_json(path, report)
    return len(filters) - len(kept)


def set_report_filter_not_in(report_dir: Path, entity: str, prop: str, values: list, key: str):
    """Report-level filter excluding values (e.g. deleted records) on every page. Use the display-name column,
    as users see it in the Filters pane: values are PBIR literals, e.g. ["'Deleted'"] for text."""
    _set_report_filter(report_dir, entity, prop, values, key, exclude=True)


def set_report_filter_in(report_dir: Path, entity: str, prop: str, values: list, key: str):
    """Report-level filter keeping only values on every page, e.g. a default that matches the Work Wallet
    portal (Active assets only). It shows in the Filters pane, so users can change or clear it."""
    _set_report_filter(report_dir, entity, prop, values, key, exclude=False)


def _set_report_filter(report_dir: Path, entity: str, prop: str, values: list, key: str, exclude: bool):
    path = Path(report_dir) / "definition" / "report.json"
    report = json.loads(path.read_text(encoding="utf-8"))
    condition = {"In": {
        "Expressions": [{"Column": {"Expression": {"SourceRef": {"Source": "r"}}, "Property": prop}}],
        "Values": [[{"Literal": {"Value": v}}] for v in values]}}
    if exclude:
        condition = {"Not": {"Expression": condition}}
    flt = {"name": vid("report-filter", key), "field": col(entity, prop), "type": "Categorical",
           "filter": {"Version": 2, "From": [{"Name": "r", "Entity": entity, "Type": 0}],
                      "Where": [{"Condition": condition}]},
           "howCreated": "User"}
    config = report.setdefault("filterConfig", {})
    config["filters"] = [f for f in config.get("filters", []) if f["name"] != flt["name"]] + [flt]
    write_json(path, report)
