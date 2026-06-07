from __future__ import annotations

from pathlib import Path
from textwrap import wrap

from PIL import Image, ImageDraw, ImageFont


OUT_DIR = Path(__file__).resolve().parent
WIDTH = 2200
HEIGHT = 1400
BG = "#f7f4ec"
INK = "#243033"
MUTED = "#687170"
LINE = "#cbc2b3"
PANEL = "#fffdf8"
GREEN = "#dff0df"
GREEN_DARK = "#47744a"
BLUE = "#dcebf5"
BLUE_DARK = "#426b86"
YELLOW = "#f8edc8"
YELLOW_DARK = "#806b36"
RED = "#f4dddc"
RED_DARK = "#8d4f4e"
VIOLET = "#eadff4"
VIOLET_DARK = "#694f82"


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
FONT_SECTION = font(32, True)
FONT_BODY = font(23)
FONT_SMALL = font(19)
FONT_FOOTER = font(22, True)


def lines(text: str, width: int) -> list[str]:
    out: list[str] = []
    for part in text.split("\n"):
        out.extend(wrap(part, width=width) if part else [""])
    return out


def canvas(title: str, subtitle: str) -> tuple[Image.Image, ImageDraw.ImageDraw]:
    image = Image.new("RGB", (WIDTH, HEIGHT), BG)
    draw = ImageDraw.Draw(image)
    draw.text((90, 54), title, fill=INK, font=FONT_TITLE)
    draw.text((92, 124), subtitle, fill=MUTED, font=FONT_SUBTITLE)
    draw.line((90, 176, WIDTH - 90, 176), fill=LINE, width=3)
    return image, draw


def footer(draw: ImageDraw.ImageDraw) -> None:
    text = "documentation preview only / no code / no assets / no persistence / no frame_started"
    draw.rounded_rectangle((90, HEIGHT - 94, WIDTH - 90, HEIGHT - 42), radius=18, fill="#ebe4d7", outline=LINE, width=2)
    draw.text((116, HEIGHT - 81), text, fill=INK, font=FONT_FOOTER)


def panel(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    title: str,
    body: list[str],
    fill: str,
    outline: str,
    wrap_width: int,
    title_size: ImageFont.FreeTypeFont = FONT_SECTION,
) -> None:
    x1, y1, x2, y2 = box
    draw.rounded_rectangle(box, radius=24, fill=fill, outline=outline, width=4)
    draw.text((x1 + 28, y1 + 24), title, fill=outline, font=title_size)
    y = y1 + 80
    for item in body:
        draw.text((x1 + 30, y), "-", fill=INK, font=FONT_BODY)
        for idx, line in enumerate(lines(item, wrap_width)):
            draw.text((x1 + 58, y + idx * 30), line, fill=INK, font=FONT_BODY)
        y += max(1, len(lines(item, wrap_width))) * 30 + 13
        if y > y2 - 34:
            break


def arrow(draw: ImageDraw.ImageDraw, start: tuple[int, int], end: tuple[int, int], color: str = LINE) -> None:
    draw.line((*start, *end), fill=color, width=6)
    ex, ey = end
    sx, _ = start
    if ex >= sx:
        points = [(ex, ey), (ex - 18, ey - 12), (ex - 18, ey + 12)]
    else:
        points = [(ex, ey), (ex + 18, ey - 12), (ex + 18, ey + 12)]
    draw.polygon(points, fill=color)


def candidate_map() -> Path:
    image, draw = canvas(
        "M16-A First World Element Candidate Map",
        "Compare tiny world-element candidates without releasing code, assets, or build states",
    )
    candidates = [
        ("Neutral Plot Marker", GREEN, GREEN_DARK, ["Value: first visible world place", "Risk: may feel technical", "No assets, no persistence", "Recommended next slice"]),
        ("Foundation Indicator", BLUE, BLUE_DARK, ["Value: links focus to later suggestions", "Risk: not a build element", "No word placement", "Not candidate 1"]),
        ("Build Preview Area", YELLOW, YELLOW_DARK, ["Value: visible future space", "Risk: can read as build state", "Keep abstract", "Second-best candidate"]),
        ("Plot / Build Card", RED, RED_DARK, ["Value: product-like interaction", "Risk: looks integrated", "No build menu now", "Later gate"]),
        ("Plot Anchor Greybox", VIOLET, VIOLET_DARK, ["Value: architecture-safe", "Risk: dry for users", "Good for review", "Not first wow"]),
    ]
    x_positions = [100, 520, 940, 1360, 1780]
    for x, (title, fill, outline, body) in zip(x_positions, candidates):
        panel(draw, (x, 280, x + 340, 1038), title, body, fill, outline, 22, FONT_BODY)

    draw.rounded_rectangle((100, 1095, 2100, 1210), radius=24, fill=PANEL, outline=LINE, width=3)
    draw.text((130, 1124), "Decision", fill=INK, font=FONT_SECTION)
    decision = "Pick Neutral Plot Marker first: visible world progress, no building decision, no assets, no persistence, no automatic placement, no frame_started."
    for idx, line in enumerate(lines(decision, 112)):
        draw.text((315, 1128 + idx * 28), line, fill=INK, font=FONT_BODY)
    footer(draw)
    path = OUT_DIR / "01_first_world_element_candidate_map.png"
    image.save(path)
    return path


def recommended_flow() -> Path:
    image, draw = canvas(
        "M16-A Recommended Next Slice Flow",
        "Move from focus preview toward first visible world element without integration",
    )
    steps = [
        ("Foundation Choice done", "local focus preview remains separate", BLUE, BLUE_DARK),
        ("First visible world element", "neutral plot marker", GREEN, GREEN_DARK),
        ("Local preview only", "no app route or Home integration", YELLOW, YELLOW_DARK),
        ("Manual review", "device, copy, and scope check", BLUE, BLUE_DARK),
        ("Later integration gate", "only after explicit approval", RED, RED_DARK),
    ]
    y = 325
    x = 105
    w = 360
    h = 210
    gap = 55
    boxes = []
    for i, (title, body, fill, outline) in enumerate(steps):
        x1 = x + i * (w + gap)
        box = (x1, y, x1 + w, y + h)
        boxes.append(box)
        panel(draw, box, title, [body], fill, outline, 24, FONT_BODY)
    for left, right in zip(boxes, boxes[1:]):
        arrow(draw, (left[2] + 8, y + h // 2), (right[0] - 8, y + h // 2))

    panel(
        draw,
        (145, 705, 1015, 1070),
        "Must Stay True",
        ["no assets", "no persistence", "no runtime config", "no automatic placement", "no frame_started"],
        GREEN,
        GREEN_DARK,
        39,
    )
    panel(
        draw,
        (1185, 705, 2055, 1070),
        "Must Not Happen",
        ["no Foundation Choice as build menu", "no buildings", "no productive route", "no Reward Bridge", "no build states"],
        RED,
        RED_DARK,
        39,
    )
    footer(draw)
    path = OUT_DIR / "02_recommended_next_slice_flow.png"
    image.save(path)
    return path


def allowed_blocked_scope() -> Path:
    image, draw = canvas(
        "M16-A Allowed vs Blocked World Element Scope",
        "Tiny local world-element slice boundaries before any implementation prompt",
    )
    panel(
        draw,
        (105, 290, 1035, 1128),
        "Allowed Next Tiny Slice",
        [
            "neutral local plot marker",
            "abstract build-preview surface",
            "visible world place, not a building",
            "manual local preview only",
            "small mobile-friendly shape",
            "no final layout meaning",
        ],
        GREEN,
        GREEN_DARK,
        43,
    )
    panel(
        draw,
        (1165, 290, 2095, 1128),
        "Blocked Scope",
        [
            "buildings or final island image",
            "frame_started or any build state",
            "real assets or files under assets/",
            "persistence, Supabase, local DB",
            "Reward Bridge or automatic word placement",
            "runtime config, feature flags, app route",
        ],
        RED,
        RED_DARK,
        43,
    )
    draw.rounded_rectangle((800, 195, 1400, 255), radius=26, fill=YELLOW, outline=YELLOW_DARK, width=4)
    label = "Scope first, code only after explicit approval"
    tw = draw.textlength(label, font=FONT_BODY)
    draw.text((1100 - tw / 2, 210), label, fill=YELLOW_DARK, font=FONT_BODY)
    footer(draw)
    path = OUT_DIR / "03_allowed_vs_blocked_world_element_scope.png"
    image.save(path)
    return path


def contact_sheet(paths: list[Path]) -> Path:
    image = Image.new("RGB", (2200, 1500), BG)
    draw = ImageDraw.Draw(image)
    draw.text((90, 48), "M16-A First World Element Slice Contact Sheet", fill=INK, font=FONT_TITLE)
    draw.text((92, 116), "Documentation previews only: no code, no assets, no frame_started", fill=MUTED, font=FONT_SUBTITLE)
    thumb_w = 620
    thumb_h = 394
    positions = [(90, 210), (780, 210), (1470, 210)]
    for path, (x, y) in zip(paths, positions):
        thumb = Image.open(path).resize((thumb_w, thumb_h))
        draw.rounded_rectangle((x - 10, y - 10, x + thumb_w + 10, y + thumb_h + 10), radius=22, fill=PANEL, outline=LINE, width=3)
        image.paste(thumb, (x, y))
        draw.text((x, y + thumb_h + 26), path.name, fill=INK, font=FONT_SMALL)

    panel(
        draw,
        (240, 760, 1960, 1248),
        "M16-A Recommendation",
        [
            "next code candidate: neutral local plot marker",
            "second option: abstract local build-preview surface",
            "not candidate 1: Foundation Choice as build menu",
            "blocked: buildings, real assets, persistence, automatic placement, frame_started",
        ],
        BLUE,
        BLUE_DARK,
        85,
    )
    footer(draw)
    out = OUT_DIR / "00_contact_sheet.png"
    image.save(out)
    return out


def main() -> None:
    paths = [candidate_map(), recommended_flow(), allowed_blocked_scope()]
    contact_sheet(paths)


if __name__ == "__main__":
    main()
