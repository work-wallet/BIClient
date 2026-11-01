"""House style tokens for the report builders (pbir.py) and the model helpers (tmdl.py).

Colours, fonts, type sizes and the theme file live here, so a project with a different brand changes them in one
place instead of in the builders. WORK_WALLET is the default and matches the WorkWallet.json report theme. Keep
a style and its theme in step: a custom style needs its own theme file, named in theme_file.

    import report_style as rs
    rs.use(rs.Style(accent="#0063B1", eyebrow="CONTOSO", theme_file="Contoso.json"))

    # or start from the Work Wallet style and change a few tokens
    rs.use(rs.WORK_WALLET.with_(accent="#0063B1"))

The canvas grid (1280 x 720, margins, header/KPI/body positions) is in pbir.py's layout constants. The written
style guide is .github/instructions/powerbi-style.instructions.md.
"""
from __future__ import annotations

from dataclasses import dataclass, replace


@dataclass(frozen=True)
class Style:
    # Text
    ink: str = "#1E2B37"  # primary text, titles, the drillthrough button
    ink_2: str = "#4A5568"  # secondary text (subtitles)
    accent: str = "#C9901A"  # header eyebrow
    # Semantic colours: Colour Good / Bad / Neutral measures, gradients, fixed series colours
    good: str = "#2E9E6B"
    mid: str = "#ECB232"
    bad: str = "#D6493A"
    neutral: str = "#4A5568"
    heat_low: str = "#FDEBC8"  # light end of count heatmaps (the dark end is bad)
    # Surfaces and buttons
    surface: str = "#FFFFFF"
    outline: str = "#C9D1DA"
    button_hover: str = "#2C3B49"
    button_disabled: str = "#EEF0F3"
    button_disabled_text: str = "#8592A0"
    # Fonts: textbox runs take a family name, visual objects a CSS font stack
    font: str = "Segoe UI"
    font_semibold: str = "Segoe UI Semibold"
    font_stack: str = "'Segoe UI', wf_segoe-ui_normal, helvetica, arial, sans-serif"
    font_stack_semibold: str = "'Segoe UI Semibold', wf_segoe-ui_semibold, helvetica, arial, sans-serif"
    # Type sizes (pt)
    eyebrow_size: int = 8
    title_size: int = 18
    subtitle_size: int = 9
    kpi_value_size: int = 18
    button_text_size: int = 10
    drill_button_text_size: int = 9
    # Branding
    eyebrow: str = "WORK WALLET"  # header eyebrow; reports usually set pbir.settings.eyebrow to "<BRAND>  ·  <MODULE>"
    theme_file: str = "WorkWallet.json"  # StaticResources/RegisteredResources/<theme_file>

    def with_(self, **changes) -> "Style":
        """A copy with some tokens changed."""
        return replace(self, **changes)


WORK_WALLET = Style()
current: Style = WORK_WALLET


def use(style: Style) -> Style:
    """Makes style the one the builders use from now on (for this Python process)."""
    global current
    current = style
    return style
