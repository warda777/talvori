from __future__ import annotations

from pathlib import Path
import textwrap

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
FOOTER = "documentation preview only / no app integration / no assets / no frame_started"


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


F_TITLE = font(54, True)
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
    draw_wrapped(draw, x + 28, y + 42, title, F_H2, accent, w - 56, max_h=82)
    yy = y + 116
    for item in items:
        draw.ellipse((x + 32, yy + 10, x + 44, yy + 22), fill=accent)
        yy = draw_wrapped(draw, x + 62, yy, item, F_BODY, INK, w - 92, max_h=64)
        yy += 14
    if footer:
        fy = y + h - 76
        draw.rounded_rectangle((x + 28, fy, x + w - 28, y + h - 26), radius=8, fill=soft, outline=accent, width=2)
        draw_wrapped(draw, x + 44, fy + 14, footer, F_SMALL, accent, w - 88, max_h=40)


def step_box(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    title: str,
    body: str,
    accent: str,
    soft: str,
) -> None:
    x, y, w, h = box
    draw.rounded_rectangle((x, y, x + w, y + h), radius=10, fill=CARD, outline=accent, width=3)
    draw.rectangle((x, y, x + w, y + 16), fill=soft)
    draw_wrapped(draw, x + 22, y + 32, title, F_H3, accent, w - 44, max_h=70)
    draw_wrapped(draw, x + 22, y + 88, body, F_SMALL, INK, w - 44, max_h=h - 110)


def arrow(draw: ImageDraw.ImageDraw, start: tuple[int, int], end: tuple[int, int], color: str = MUTED) -> None:
    x1, y1 = start
    x2, y2 = end
    draw.line((x1, y1, x2, y2), fill=color, width=4)
    if x2 >= x1:
        points = [(x2, y2), (x2 - 18, y2 - 10), (x2 - 18, y2 + 10)]
    else:
        points = [(x2, y2), (x2 + 18, y2 - 10), (x2 + 18, y2 + 10)]
    draw.polygon(points, fill=color)


def make_scope_review_map() -> None:
    img = Image.new("RGB", (W, H), BG)
    draw = ImageDraw.Draw(img)

    draw.text((85, 54), "M15-B Foundation Choice Code Scope Review", font=F_TITLE, fill=INK)
    draw.text((88, 120), "Isolated preview widget review and visual harness plan", font=F_SUB, fill=MUTED)
    draw.line((85, 178, W - 85, 178), fill=LINE, width=2)

    steps = [
        ("Widget exists", "One Flutter preview file only", GREEN, GREEN_SOFT),
        ("Isolated", "No route, export, or app entry", GREEN, GREEN_SOFT),
        ("Local state only", "setState for preview selection", BLUE, BLUE_SOFT),
        ("No integration", "No Home, onboarding, or world routing", AMBER, AMBER_SOFT),
        ("No persistence", "No DB, Supabase, SRS, or config", RED, RED_SOFT),
        ("No assets", "Material icons only; no assets folder changes", PURPLE, PURPLE_SOFT),
        ("No frame_started", "No build state or construction flow", RED, RED_SOFT),
    ]

    x0, y0 = 90, 240
    w, h = 275, 190
    gap = 20
    for i, (title, body, accent, soft) in enumerate(steps):
        x = x0 + i * (w + gap)
        step_box(draw, (x, y0, w, h), title, body, accent, soft)
        if i < len(steps) - 1:
            arrow(draw, (x + w, y0 + h // 2), (x + w + gap - 4, y0 + h // 2))

    panel(
        draw,
        (115, 560, 620, 560),
        "Review Decision",
        [
            "Scope-conformant isolated minimal slice.",
            "No external references to FoundationChoicePreview.",
            "Dart analyzer for the preview file is expected before closeout.",
            "Minor copy note: 'lokal merken' should be checked before any integration.",
        ],
        GREEN,
        GREEN_SOFT,
        "Accepted as local preview code; no further release inferred.",
    )

    panel(
        draw,
        (790, 560, 620, 560),
        "Later Visual Harness",
        [
            "Small phone portrait first.",
            "Check text containment, tap targets, Safe Exit, and visible 'later changeable' note.",
            "Confirm Tali/Vori card does not overlay buttons or cards.",
            "Screenshots or widget tests only after a separate explicit prompt.",
        ],
        BLUE,
        BLUE_SOFT,
        "Plan only; no harness implementation in M15-B.",
    )

    panel(
        draw,
        (1465, 560, 420, 560),
        "Hard Stops",
        [
            "No app integration.",
            "No persistence or runtime config.",
            "No tests or screenshots.",
            "No assets under assets/.",
            "No automatic word placement.",
            "No frame_started.",
        ],
        RED,
        RED_SOFT,
        "No implementation release.",
    )

    draw.rounded_rectangle((115, 1182, W - 115, 1284), radius=10, fill=AMBER_SOFT, outline=AMBER, width=3)
    note = (
        "Documentation preview only: this map reviews the already isolated widget and plans a later visual "
        "harness. It is not an app screen, not a screenshot, not a game asset, and not a route or release."
    )
    draw_wrapped(draw, 145, 1210, note, F_BODY, AMBER, W - 290, max_h=64)

    draw.text((85, H - 70), FOOTER, font=F_FOOTER, fill=MUTED)
    img.save(OUT_DIR / "01_code_scope_review_map.png", "PNG", optimize=True)


if __name__ == "__main__":
    make_scope_review_map()
