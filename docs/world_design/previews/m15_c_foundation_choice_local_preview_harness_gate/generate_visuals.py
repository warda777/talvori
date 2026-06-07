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

FOOTER = "documentation preview only / no integration / no tests / no screenshots / no persistence"


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
    result: list[str] = []
    for paragraph in str(text).split("\n"):
        current = ""
        for word in paragraph.split():
            probe = word if not current else f"{current} {word}"
            if text_size(draw, probe, fnt)[0] <= max_w:
                current = probe
            else:
                if current:
                    result.append(current)
                current = word
        if current:
            result.append(current)
    return result or [""]


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
    draw_wrapped(draw, x + 24, y + 38, title, F_H3, accent, w - 48, max_h=70)
    body_max_h = h - 174 if footer else h - 124
    draw_wrapped(draw, x + 24, y + 104, body, F_SMALL, INK, w - 48, max_h=body_max_h)
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
) -> None:
    x, y, w, h = box
    draw.rounded_rectangle((x, y, x + w, y + h), radius=12, fill=CARD, outline=accent, width=3)
    draw.rectangle((x, y, x + w, y + 22), fill=soft)
    draw_wrapped(draw, x + 28, y + 44, title, F_H2, accent, w - 56, max_h=80)
    yy = y + 116
    for item in items:
        draw.ellipse((x + 32, yy + 10, x + 44, yy + 22), fill=accent)
        yy = draw_wrapped(draw, x + 62, yy, item, F_BODY, INK, w - 96, max_h=64)
        yy += 12


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
        "M15-C Harness Gate Map",
        "Isolated FoundationChoicePreview harness candidate: plan only",
    )
    steps = [
        ("Isolated Widget", "Existing preview widget only; no route or export.", GREEN, GREEN_SOFT),
        ("Local Harness Candidate", "Would render locally for review, not as user feature.", BLUE, BLUE_SOFT),
        ("Device Checks", "Small phone first; standard and large phone later.", BLUE, BLUE_SOFT),
        ("Copy Checks", "Verify local-only and reversible wording.", AMBER, AMBER_SOFT),
        ("Accessibility Checks", "Text containment, tap targets, color independence.", PURPLE, PURPLE_SOFT),
        ("Later Approval / Blocked", "Separate prompt required; blocked if integration is inferred.", RED, RED_SOFT),
    ]
    x0, y0 = 90, 250
    w, h, gap = 310, 210, 26
    for i, (title, body, accent, soft) in enumerate(steps):
        x = x0 + i * (w + gap)
        card(draw, (x, y0, w, h), title, body, accent, soft)
        if i < len(steps) - 1:
            arrow(draw, (x + w, y0 + h // 2), (x + w + gap - 4, y0 + h // 2))

    panel(
        draw,
        (130, 590, 590, 470),
        "Allowed Later",
        [
            "Render FoundationChoicePreview in isolation.",
            "Inspect small phone portrait before integration.",
            "Check Safe Exit, later-changeable note, and local selection.",
            "Use manual/visual checks first; tests only by later approval.",
        ],
        GREEN,
        GREEN_SOFT,
    )
    panel(
        draw,
        (805, 590, 590, 470),
        "Required Gates",
        [
            "Separate harness prompt before any implementation.",
            "Explicit screenshot or test approval before those outputs.",
            "No app route, no onboarding route, no Home integration.",
            "No persistence, runtime config, assets, or word placement.",
        ],
        BLUE,
        BLUE_SOFT,
    )
    panel(
        draw,
        (1480, 590, 520, 470),
        "Blocked Now",
        [
            "No Flutter/Dart changes in M15-C.",
            "No tests, widget tests, or screenshots.",
            "No app integration or routing.",
            "No frame_started, build state, or assets.",
        ],
        RED,
        RED_SOFT,
    )
    draw.rounded_rectangle((130, 1155, 2000, 1258), radius=10, fill=AMBER_SOFT, outline=AMBER, width=3)
    draw_wrapped(
        draw,
        160,
        1184,
        "Gate decision: a later isolated local preview harness is theoretically useful, but M15-C itself releases no harness, no tests, no screenshots, and no integration.",
        F_BODY,
        AMBER,
        1810,
        max_h=58,
    )
    img.save(OUT_DIR / "01_harness_gate_map.png", "PNG", optimize=True)


def make_02() -> None:
    img, draw = canvas(
        "M15-C Device Check Scope Map",
        "Later local harness device coverage, not screenshots or tests",
    )
    devices = [
        ("Small Phone Portrait", "Primary risk case. Check stacked cards, Safe Exit, later-changeable note, and no Tali/Vori collision.", GREEN, GREEN_SOFT, "first gate"),
        ("Standard Phone Portrait", "Normal phone read. Check text weight, tap spacing, and selection visibility.", BLUE, BLUE_SOFT, "later check"),
        ("Large Phone Portrait", "More room. Keep the preview simple and avoid adding extra complexity.", BLUE, BLUE_SOFT, "optional"),
        ("Landscape Later", "Height is tight. Treat as risk case, not initial release condition.", AMBER, AMBER_SOFT, "later risk"),
        ("Tablet Optional", "May look too sparse or too wide. Only after phone flow is stable.", PURPLE, PURPLE_SOFT, "optional"),
    ]
    x_positions = [100, 520, 940, 1360, 1780]
    for x, (title, body, accent, soft, foot) in zip(x_positions, devices):
        card(draw, (x, 245, 330, 405), title, body, accent, soft, foot)

    checks = [
        ("Text containment", "Banner, intro, cards, buttons, result panel stay inside frames.", GREEN, GREEN_SOFT),
        ("Tap targets", "Cards, confirm button, and Safe Exit remain separated and tappable.", BLUE, BLUE_SOFT),
        ("Safe Exit", "Spaeter entscheiden remains visible and calm.", AMBER, AMBER_SOFT),
        ("Later-changeable note", "Reversibility remains visible; choice is not final.", PURPLE, PURPLE_SOFT),
        ("Tali/Vori collision", "Intro card must not overlay cards, buttons, or result panel.", RED, RED_SOFT),
        ("Local selection", "Selection remains in memory only; no persistence or config.", GRAY, GRAY_SOFT),
    ]
    x_positions_2 = [110, 455, 800, 1145, 1490, 1835]
    for x, (title, body, accent, soft) in zip(x_positions_2, checks):
        card(draw, (x, 760, 300, 285), title, body, accent, soft)

    draw.rounded_rectangle((120, 1158, 2030, 1266), radius=10, fill=RED_SOFT, outline=RED, width=3)
    draw_wrapped(
        draw,
        150,
        1186,
        "Blocked in M15-C: no screenshots, no widget tests, no route, no onboarding integration, no persistence, no runtime config, no assets, no automatic word placement, no frame_started.",
        F_BODY,
        RED,
        1850,
        max_h=62,
    )
    img.save(OUT_DIR / "02_device_check_scope_map.png", "PNG", optimize=True)


def make_contact_sheet() -> None:
    sources = [
        ("01_harness_gate_map.png", "Harness Gate Map"),
        ("02_device_check_scope_map.png", "Device Check Scope"),
    ]
    thumb_w, thumb_h = 900, 572
    sheet = Image.new("RGB", (2200, 950), BG)
    draw = ImageDraw.Draw(sheet)
    draw.text((85, 54), "M15-C Contact Sheet", font=F_TITLE, fill=INK)
    draw.text((88, 120), "Documentation previews for the local preview harness gate", font=F_SUB, fill=MUTED)
    draw.line((85, 178, 2115, 178), fill=LINE, width=2)
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
