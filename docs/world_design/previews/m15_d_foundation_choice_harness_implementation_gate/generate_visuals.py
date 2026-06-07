from __future__ import annotations

from pathlib import Path
import math

from PIL import Image, ImageDraw, ImageFont


OUT_DIR = Path(__file__).resolve().parent
W, H = 2200, 1400

BG = "#f5f6f1"
CARD = "#ffffff"
INK = "#26323a"
MUTED = "#657179"
LINE = "#c8d0cc"
GREEN = "#2f7a50"
GREEN_SOFT = "#dcefdc"
BLUE = "#2e5d8d"
BLUE_SOFT = "#dce9f6"
AMBER = "#956b14"
AMBER_SOFT = "#f5e8c6"
RED = "#9f3b34"
RED_SOFT = "#f1d8d6"
PURPLE = "#66508f"
PURPLE_SOFT = "#e6def3"
GRAY = "#59666d"
GRAY_SOFT = "#edf0f0"

FOOTER = "documentation preview only / no code now / no tests / no screenshots / no app route"


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    candidates = [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/System/Library/Fonts/Supplemental/Helvetica Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Helvetica.ttf",
        "/Library/Fonts/Arial Bold.ttf" if bold else "/Library/Fonts/Arial.ttf",
    ]
    for candidate in candidates:
        path = Path(candidate)
        if path.exists():
            return ImageFont.truetype(str(path), size)
    return ImageFont.load_default(size)


F_TITLE = font(52, True)
F_SUB = font(28)
F_H2 = font(34, True)
F_H3 = font(26, True)
F_BODY = font(24)
F_SMALL = font(20)
F_FOOTER = font(20)


def text_size(draw: ImageDraw.ImageDraw, text: str, fnt: ImageFont.ImageFont) -> tuple[int, int]:
    box = draw.textbbox((0, 0), text, font=fnt)
    return box[2] - box[0], box[3] - box[1]


def wrap_lines(draw: ImageDraw.ImageDraw, text: str, fnt: ImageFont.ImageFont, max_w: int) -> list[str]:
    lines: list[str] = []
    for paragraph in str(text).split("\n"):
        current = ""
        for word in paragraph.split():
            probe = word if not current else f"{current} {word}"
            if text_size(draw, probe, fnt)[0] <= max_w:
                current = probe
            else:
                if current:
                    lines.append(current)
                current = word
        if current:
            lines.append(current)
    return lines or [""]


def draw_wrapped(
    draw: ImageDraw.ImageDraw,
    x: int,
    y: int,
    text: str,
    fnt: ImageFont.ImageFont,
    fill: str,
    max_w: int,
    max_h: int | None = None,
    gap: int = 8,
) -> int:
    line_h = text_size(draw, "Ag", fnt)[1] + gap
    lines = wrap_lines(draw, text, fnt, max_w)
    if max_h is not None:
        max_lines = max(1, max_h // line_h)
        if len(lines) > max_lines:
            lines = lines[:max_lines]
            last = lines[-1]
            while text_size(draw, f"{last}...", fnt)[0] > max_w and len(last) > 4:
                last = last[:-1]
            lines[-1] = f"{last}..."
    for line in lines:
        draw.text((x, y), line, font=fnt, fill=fill)
        y += line_h
    return y


def canvas(title: str, subtitle: str) -> tuple[Image.Image, ImageDraw.ImageDraw]:
    img = Image.new("RGB", (W, H), BG)
    draw = ImageDraw.Draw(img)
    draw.text((85, 54), title, font=F_TITLE, fill=INK)
    draw.text((88, 120), subtitle, font=F_SUB, fill=MUTED)
    draw.line((85, 178, W - 85, 178), fill=LINE, width=2)
    draw.text((85, H - 70), FOOTER, font=F_FOOTER, fill=MUTED)
    return img, draw


def card(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    title: str,
    body: str,
    accent: str,
    soft: str,
    footer: str | None = None,
) -> None:
    x, y, w, h = box
    draw.rounded_rectangle((x, y, x + w, y + h), radius=12, fill=CARD, outline=accent, width=3)
    draw.rectangle((x, y, x + w, y + 22), fill=soft)
    draw_wrapped(draw, x + 24, y + 38, title, F_H3, accent, w - 48, max_h=72)
    body_max_h = h - 174 if footer else h - 124
    draw_wrapped(draw, x + 24, y + 106, body, F_SMALL, INK, w - 48, max_h=body_max_h)
    if footer:
        fy = y + h - 62
        draw.rounded_rectangle((x + 22, fy, x + w - 22, y + h - 20), radius=8, fill=soft, outline=accent, width=2)
        draw_wrapped(draw, x + 36, fy + 10, footer, F_SMALL, accent, w - 72, max_h=30)


def panel(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    title: str,
    items: list[str],
    accent: str,
    soft: str,
    footer: str | None = None,
) -> None:
    x, y, w, h = box
    draw.rounded_rectangle((x, y, x + w, y + h), radius=12, fill=CARD, outline=accent, width=3)
    draw.rectangle((x, y, x + w, y + 22), fill=soft)
    draw_wrapped(draw, x + 30, y + 46, title, F_H2, accent, w - 60, max_h=82)
    yy = y + 120
    for item in items:
        draw.ellipse((x + 34, yy + 10, x + 46, yy + 22), fill=accent)
        yy = draw_wrapped(draw, x + 64, yy, item, F_BODY, INK, w - 100, max_h=64)
        yy += 12
    if footer:
        fy = y + h - 76
        draw.rounded_rectangle((x + 28, fy, x + w - 28, y + h - 24), radius=8, fill=soft, outline=accent, width=2)
        draw_wrapped(draw, x + 44, fy + 14, footer, F_SMALL, accent, w - 88, max_h=34)


def arrow(draw: ImageDraw.ImageDraw, start: tuple[int, int], end: tuple[int, int], color: str = MUTED) -> None:
    x1, y1 = start
    x2, y2 = end
    draw.line((x1, y1, x2, y2), fill=color, width=4)
    angle = math.atan2(y2 - y1, x2 - x1)
    size = 16
    points = [
        (x2, y2),
        (x2 - size * math.cos(angle - 0.45), y2 - size * math.sin(angle - 0.45)),
        (x2 - size * math.cos(angle + 0.45), y2 - size * math.sin(angle + 0.45)),
    ]
    draw.polygon(points, fill=color)


def make_01() -> None:
    img, draw = canvas(
        "M15-D Harness Implementation Gate Map",
        "Implementation gate only: no harness, no tests, no screenshots, no app route",
    )
    steps = [
        ("M15-C Gate", "Harness is useful in theory, but not released.", BLUE, BLUE_SOFT),
        ("M15-D Gate", "Checks whether a tiny later slice could be released.", PURPLE, PURPLE_SOFT),
        ("Explicit User Approval", "Separate future implementation prompt required.", AMBER, AMBER_SOFT),
        ("Isolated Harness Slice", "Would render preview locally without navigation.", GREEN, GREEN_SOFT),
        ("Manual Review", "Device and copy review first; tests only if later approved.", GREEN, GREEN_SOFT),
        ("No Integration", "No Home, onboarding, world routing, app route, or persistence.", RED, RED_SOFT),
    ]
    x0, y0 = 92, 250
    w, h, gap = 310, 218, 26
    for i, (title, body, accent, soft) in enumerate(steps):
        x = x0 + i * (w + gap)
        card(draw, (x, y0, w, h), title, body, accent, soft)
        if i < len(steps) - 1:
            arrow(draw, (x + w, y0 + h // 2), (x + w + gap - 4, y0 + h // 2))

    panel(
        draw,
        (130, 590, 560, 455),
        "Allowed Later Only",
        [
            "Local wrapper or demo surface.",
            "FoundationChoicePreview rendered without navigation.",
            "Small phone portrait as first design case.",
            "No screenshots or tests unless a later prompt says so.",
        ],
        GREEN,
        GREEN_SOFT,
        "Only after explicit approval.",
    )
    panel(
        draw,
        (820, 590, 560, 455),
        "Missing Decisions",
        [
            "Exact isolated entry point.",
            "Whether copy changes before harness.",
            "Whether screenshots are ever allowed.",
            "Whether tests are ever allowed.",
        ],
        AMBER,
        AMBER_SOFT,
        "M15-D resolves none as code.",
    )
    panel(
        draw,
        (1510, 590, 500, 455),
        "Blocked Now",
        [
            "No Flutter/Dart changes.",
            "No app route or product navigation.",
            "No tests, golden tests, or screenshots.",
            "No persistence, config, assets, or frame_started.",
        ],
        RED,
        RED_SOFT,
        "No code now.",
    )
    draw.rounded_rectangle((130, 1150, 2010, 1260), radius=10, fill=RED_SOFT, outline=RED, width=3)
    draw_wrapped(
        draw,
        162,
        1179,
        "Gate result: a future isolated harness slice can be theoretically releasable, but M15-D itself releases no harness implementation, no tests, no screenshots, and no app integration.",
        F_BODY,
        RED,
        1810,
        max_h=62,
    )
    img.save(OUT_DIR / "01_harness_implementation_gate_map.png", "PNG", optimize=True)


def make_02() -> None:
    img, draw = canvas(
        "M15-D Allowed vs Blocked Harness Scope",
        "Later isolated harness boundaries for FoundationChoicePreview",
    )
    panel(
        draw,
        (130, 250, 850, 780),
        "Allowed Later Isolated Harness",
        [
            "One local preview wrapper or demo surface.",
            "FoundationChoicePreview shown without navigation.",
            "Small Phone Portrait visible as first design case.",
            "Manual visual review of text containment, tap targets, Safe Exit, later-changeable note, and Tali/Vori card.",
            "No tests or screenshots unless separately approved later.",
        ],
        GREEN,
        GREEN_SOFT,
        "Potential future slice only.",
    )
    panel(
        draw,
        (1220, 250, 850, 780),
        "Blocked Product / App Scope",
        [
            "Home, onboarding, world routing, app route, or product navigation.",
            "Persistence, Supabase, local DB, runtime config, or feature flags.",
            "Tests, widget tests, golden tests, or screenshots from this gate.",
            "Assets, asset files under assets/, automatic word placement, Reward Bridge, frame_started, or build states.",
        ],
        RED,
        RED_SOFT,
        "No app or asset release.",
    )

    draw.rounded_rectangle((230, 1110, 1970, 1236), radius=10, fill=AMBER_SOFT, outline=AMBER, width=3)
    draw_wrapped(
        draw,
        260,
        1140,
        "Copy decision: 'Lernfokus lokal merken' is acceptable for the isolated preview and not blocking for a future harness, but should be reviewed before integration. Suggested later wording: 'Lernfokus lokal anzeigen'.",
        F_BODY,
        AMBER,
        1680,
        max_h=70,
    )
    img.save(OUT_DIR / "02_allowed_vs_blocked_harness_scope.png", "PNG", optimize=True)


def make_contact_sheet() -> None:
    sources = [
        ("01_harness_implementation_gate_map.png", "Harness Implementation Gate"),
        ("02_allowed_vs_blocked_harness_scope.png", "Allowed vs Blocked Scope"),
    ]
    sheet = Image.new("RGB", (2200, 950), BG)
    draw = ImageDraw.Draw(sheet)
    draw.text((85, 54), "M15-D Contact Sheet", font=F_TITLE, fill=INK)
    draw.text((88, 120), "Documentation previews for harness implementation gate", font=F_SUB, fill=MUTED)
    draw.line((85, 178, 2115, 178), fill=LINE, width=2)
    thumb_w, thumb_h = 900, 572
    for i, (filename, title) in enumerate(sources):
        img = Image.open(OUT_DIR / filename).convert("RGB")
        img.thumbnail((thumb_w, thumb_h))
        x = 150 + i * 1010
        y = 245
        draw.rounded_rectangle((x - 18, y - 54, x + thumb_w + 18, y + thumb_h + 42), radius=10, fill=CARD, outline=LINE, width=2)
        draw.text((x, y - 42), title, font=F_H3, fill=INK)
        sheet.paste(img, (x, y))
    draw.text((85, 890), FOOTER, font=F_FOOTER, fill=MUTED)
    sheet.save(OUT_DIR / "00_contact_sheet.png", "PNG", optimize=True)


if __name__ == "__main__":
    make_01()
    make_02()
    make_contact_sheet()
