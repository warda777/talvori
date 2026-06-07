from __future__ import annotations

from pathlib import Path
from textwrap import wrap

from PIL import Image, ImageDraw, ImageFont


OUT_DIR = Path(__file__).resolve().parent
WIDTH = 2200
HEIGHT = 1400
BG = "#f7f3ea"
INK = "#243033"
MUTED = "#667272"
PANEL = "#fffdf8"
LINE = "#cfc7b8"
GREEN = "#dff1df"
GREEN_DARK = "#47744a"
RED = "#f5dfdd"
RED_DARK = "#8b4e4b"
BLUE = "#dcebf5"
BLUE_DARK = "#426b86"
YELLOW = "#f8edc8"
YELLOW_DARK = "#7b6734"


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    candidates = [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
        "/Library/Fonts/Arial.ttf",
    ]
    for candidate in candidates:
        try:
            return ImageFont.truetype(candidate, size=size)
        except OSError:
            continue
    return ImageFont.load_default()


FONT_TITLE = font(54, True)
FONT_SUBTITLE = font(27)
FONT_SECTION = font(34, True)
FONT_BODY = font(25)
FONT_SMALL = font(21)
FONT_FOOTER = font(22, True)


def canvas(title: str, subtitle: str) -> tuple[Image.Image, ImageDraw.ImageDraw]:
    image = Image.new("RGB", (WIDTH, HEIGHT), BG)
    draw = ImageDraw.Draw(image)
    draw.text((90, 56), title, fill=INK, font=FONT_TITLE)
    draw.text((92, 126), subtitle, fill=MUTED, font=FONT_SUBTITLE)
    draw.line((90, 175, WIDTH - 90, 175), fill=LINE, width=3)
    return image, draw


def footer(draw: ImageDraw.ImageDraw) -> None:
    text = "documentation preview only / no code now / no tests / no screenshots / no app route"
    draw.rounded_rectangle((90, HEIGHT - 92, WIDTH - 90, HEIGHT - 42), radius=18, fill="#ebe3d4", outline=LINE, width=2)
    draw.text((116, HEIGHT - 80), text, fill=INK, font=FONT_FOOTER)


def text_lines(text: str, chars: int) -> list[str]:
    lines: list[str] = []
    for part in text.split("\n"):
        if not part:
            lines.append("")
        else:
            lines.extend(wrap(part, width=chars))
    return lines


def panel(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    title: str,
    bullets: list[str],
    fill: str,
    accent: str,
    chars: int,
) -> None:
    x1, y1, x2, y2 = box
    draw.rounded_rectangle(box, radius=24, fill=fill, outline=accent, width=4)
    draw.text((x1 + 30, y1 + 26), title, fill=accent, font=FONT_SECTION)
    y = y1 + 88
    for bullet in bullets:
        wrapped = text_lines(bullet, chars)
        draw.text((x1 + 34, y), "-", fill=INK, font=FONT_BODY)
        for i, line in enumerate(wrapped):
            draw.text((x1 + 62, y + i * 32), line, fill=INK, font=FONT_BODY)
        y += max(1, len(wrapped)) * 32 + 16
        if y > y2 - 36:
            break


def pill(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], text: str, fill: str, outline: str) -> None:
    draw.rounded_rectangle(box, radius=28, fill=fill, outline=outline, width=3)
    x1, y1, x2, y2 = box
    lines = text_lines(text, 17)
    total = len(lines) * 27
    y = y1 + ((y2 - y1) - total) // 2
    for line in lines:
        tw = draw.textlength(line, font=FONT_SMALL)
        draw.text((x1 + ((x2 - x1) - tw) / 2, y), line, fill=INK, font=FONT_SMALL)
        y += 27


def arrow(draw: ImageDraw.ImageDraw, start: tuple[int, int], end: tuple[int, int], color: str = LINE) -> None:
    draw.line((start[0], start[1], end[0], end[1]), fill=color, width=6)
    ex, ey = end
    sx, sy = start
    if ex >= sx:
        points = [(ex, ey), (ex - 18, ey - 12), (ex - 18, ey + 12)]
    else:
        points = [(ex, ey), (ex + 18, ey - 12), (ex + 18, ey + 12)]
    draw.polygon(points, fill=color)


def scope_boundary() -> Path:
    image, draw = canvas(
        "M15-D2 Harness Prompt Scope Boundary",
        "Prompt draft only: prepare a later isolated harness prompt without implementation",
    )

    draw.rounded_rectangle((880, 205, 1320, 272), radius=26, fill=YELLOW, outline=YELLOW_DARK, width=4)
    center = "NO CODE NOW"
    tw = draw.textlength(center, font=FONT_SECTION)
    draw.text((1100 - tw / 2, 220), center, fill=YELLOW_DARK, font=FONT_SECTION)

    panel(
        draw,
        (100, 320, 1038, 1142),
        "Allowed Later Harness Prompt Scope",
        [
            "isolated local preview or demo surface",
            "render FoundationChoicePreview without navigation",
            "Small Phone Portrait as first visible lead case",
            "manual review of safe exit, later-changeable note and Tali/Vori collision",
            "dart format and dart analyze only after a later approved implementation",
            "no commit until checked",
        ],
        GREEN,
        GREEN_DARK,
        43,
    )

    panel(
        draw,
        (1162, 320, 2100, 1142),
        "Blocked App / Product Scope",
        [
            "no Flutter or Dart changes from M15-D2",
            "no app route, Home integration, Onboarding integration or World routing",
            "no tests, widget tests, screenshots or golden tests",
            "no persistence, Supabase writes, local DB writes or runtime config",
            "no assets, automatic word placement, build state or frame_started",
            "no implementation release from this prompt draft",
        ],
        RED,
        RED_DARK,
        43,
    )

    footer(draw)
    path = OUT_DIR / "01_harness_prompt_scope_boundary.png"
    image.save(path)
    return path


def execution_flow() -> Path:
    image, draw = canvas(
        "M15-D2 Later Harness Prompt Execution Flow",
        "M15-D2 documents a future prompt; the draft itself executes nothing",
    )

    steps = [
        ("Prompt Draft", "M15-D2 writes the future prompt only", BLUE, BLUE_DARK),
        ("Explicit User Approval", "Andreas must approve a separate implementation prompt", YELLOW, YELLOW_DARK),
        ("Read Structure", "inspect existing widget and surrounding folders first", BLUE, BLUE_DARK),
        ("List Files", "name exact files before any edit", BLUE, BLUE_DARK),
        ("Implement Isolated Harness", "local preview wrapper only, no route", GREEN, GREEN_DARK),
        ("Analyze", "format/analyze changed Dart only after approval", BLUE, BLUE_DARK),
        ("Diff Check", "git diff --check and git status --short", BLUE, BLUE_DARK),
        ("No Commit", "stop for review; no automatic commit", RED, RED_DARK),
    ]

    x = 120
    y = 275
    w = 435
    h = 176
    gap_x = 92
    gap_y = 110
    positions: list[tuple[int, int, int, int]] = []
    for i, (title, body, fill, outline) in enumerate(steps):
        row = i // 4
        col = i % 4
        x1 = x + col * (w + gap_x)
        y1 = y + row * (h + gap_y)
        positions.append((x1, y1, x1 + w, y1 + h))
        draw.rounded_rectangle((x1, y1, x1 + w, y1 + h), radius=24, fill=fill, outline=outline, width=4)
        draw.text((x1 + 24, y1 + 20), title, fill=outline, font=FONT_SECTION)
        yy = y1 + 74
        for line in text_lines(body, 30):
            draw.text((x1 + 24, yy), line, fill=INK, font=FONT_SMALL)
            yy += 27

    for i in range(3):
        arrow(draw, (positions[i][2] + 8, positions[i][1] + h // 2), (positions[i + 1][0] - 8, positions[i + 1][1] + h // 2))
    arrow(draw, (positions[3][0] + w // 2, positions[3][3] + 8), (positions[7][0] + w // 2, positions[7][1] - 8))
    for i in range(7, 4, -1):
        arrow(draw, (positions[i][0] - 8, positions[i][1] + h // 2), (positions[i - 1][2] + 8, positions[i - 1][1] + h // 2))

    draw.rounded_rectangle((120, 945, 2080, 1132), radius=26, fill=PANEL, outline=LINE, width=3)
    draw.text((152, 976), "Hard stops inside the later prompt", fill=INK, font=FONT_SECTION)
    stops = [
        "no app route",
        "no integration",
        "no persistence",
        "no tests",
        "no screenshots",
        "no assets",
        "no frame_started",
    ]
    px = 152
    for stop in stops:
        pill(draw, (px, 1042, px + 245, 1104), stop, RED, RED_DARK)
        px += 272

    footer(draw)
    path = OUT_DIR / "02_harness_prompt_execution_flow.png"
    image.save(path)
    return path


def contact_sheet(paths: list[Path]) -> Path:
    thumb_w = 980
    thumb_h = 624
    image = Image.new("RGB", (2200, 950), BG)
    draw = ImageDraw.Draw(image)
    draw.text((90, 48), "M15-D2 Harness Prompt Draft Contact Sheet", fill=INK, font=FONT_TITLE)
    draw.text((92, 116), "Documentation previews only: no implementation, no tests, no screenshots", fill=MUTED, font=FONT_SUBTITLE)
    x = 90
    for path in paths:
        thumb = Image.open(path).resize((thumb_w, thumb_h))
        draw.rounded_rectangle((x - 10, 205 - 10, x + thumb_w + 10, 205 + thumb_h + 10), radius=22, fill=PANEL, outline=LINE, width=3)
        image.paste(thumb, (x, 205))
        draw.text((x, 850), path.name, fill=INK, font=FONT_SMALL)
        x += thumb_w + 60
    footer(draw)
    out = OUT_DIR / "00_contact_sheet.png"
    image.save(out)
    return out


def main() -> None:
    paths = [scope_boundary(), execution_flow()]
    contact_sheet(paths)


if __name__ == "__main__":
    main()
