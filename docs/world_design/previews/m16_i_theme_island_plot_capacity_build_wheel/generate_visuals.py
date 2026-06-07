from __future__ import annotations

from pathlib import Path
from textwrap import wrap

from PIL import Image, ImageDraw, ImageFont


OUT_DIR = Path(__file__).resolve().parent
WIDTH = 2400
HEIGHT = 1500

BG = "#f7f4ec"
INK = "#243033"
MUTED = "#66706e"
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
MINT = "#cfeee4"
MINT_DARK = "#3f7766"


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    candidates = [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf"
        if bold
        else "/System/Library/Fonts/Supplemental/Arial.ttf",
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
FONT_SECTION = font(30, True)
FONT_BODY = font(22)
FONT_SMALL = font(18)
FONT_TINY = font(15)
FONT_FOOTER = font(21, True)


def text_lines(text: str, width: int) -> list[str]:
    out: list[str] = []
    for part in text.split("\n"):
        out.extend(wrap(part, width=width) if part else [""])
    return out


def canvas(title: str, subtitle: str) -> tuple[Image.Image, ImageDraw.ImageDraw]:
    image = Image.new("RGB", (WIDTH, HEIGHT), BG)
    draw = ImageDraw.Draw(image)
    draw.text((90, 52), title, fill=INK, font=FONT_TITLE)
    draw.text((92, 122), subtitle, fill=MUTED, font=FONT_SUBTITLE)
    draw.line((90, 176, WIDTH - 90, 176), fill=LINE, width=3)
    return image, draw


def footer(draw: ImageDraw.ImageDraw) -> None:
    text = (
        "documentation preview only / no code / no assets / no persistence / "
        "no route / no build state / no frame_started"
    )
    draw.rounded_rectangle(
        (90, HEIGHT - 94, WIDTH - 90, HEIGHT - 42),
        radius=18,
        fill="#ebe4d7",
        outline=LINE,
        width=2,
    )
    draw.text((116, HEIGHT - 81), text, fill=INK, font=FONT_FOOTER)


def panel(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    title: str,
    body: list[str],
    fill: str,
    outline: str,
    wrap_width: int,
    title_font: ImageFont.FreeTypeFont = FONT_SECTION,
    body_font: ImageFont.FreeTypeFont = FONT_BODY,
) -> None:
    x1, y1, x2, y2 = box
    draw.rounded_rectangle(box, radius=24, fill=fill, outline=outline, width=4)
    draw.text((x1 + 24, y1 + 22), title, fill=outline, font=title_font)
    y = y1 + 72
    for item in body:
        if item.startswith("!"):
            item_text = item[1:]
            prefix = "!"
            color = RED_DARK
        else:
            item_text = item
            prefix = "-"
            color = INK
        draw.text((x1 + 26, y), prefix, fill=color, font=body_font)
        lines = text_lines(item_text, wrap_width)
        for idx, line in enumerate(lines):
            draw.text((x1 + 54, y + idx * 28), line, fill=INK, font=body_font)
        y += max(1, len(lines)) * 28 + 10
        if y > y2 - 34:
            break


def card(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    title: str,
    subtitle: str,
    fill: str,
    outline: str,
) -> None:
    x1, y1, x2, y2 = box
    draw.rounded_rectangle(box, radius=22, fill=fill, outline=outline, width=3)
    draw.text((x1 + 20, y1 + 20), title, fill=outline, font=FONT_BODY)
    y = y1 + 58
    for line in text_lines(subtitle, 23):
        draw.text((x1 + 20, y), line, fill=INK, font=FONT_SMALL)
        y += 23


def arrow(
    draw: ImageDraw.ImageDraw,
    start: tuple[int, int],
    end: tuple[int, int],
    color: str = LINE,
) -> None:
    draw.line((*start, *end), fill=color, width=5)
    ex, ey = end
    sx, _ = start
    if ex >= sx:
        points = [(ex, ey), (ex - 16, ey - 10), (ex - 16, ey + 10)]
    else:
        points = [(ex, ey), (ex + 16, ey - 10), (ex + 16, ey + 10)]
    draw.polygon(points, fill=color)


def theme_pipeline() -> Path:
    image, draw = canvas(
        "M16-I Theme To Plot Capacity Pipeline",
        "Theme need defines plots, sizes, island capacity, and in-place wheel planning",
    )
    steps = [
        ("Theme", "Dorf / Zuhause / Alltag", BLUE, BLUE_DARK),
        ("Required Plots", "home, garden, path, nature, utility", GREEN, GREEN_DARK),
        ("Plot Sizes", "small / medium / large / very large", YELLOW, YELLOW_DARK),
        ("Island Capacity", "layout grows from theme demand", MINT, MINT_DARK),
        ("Slot Layout", "exchangeable plot slots", VIOLET, VIOLET_DARK),
        ("User Selects Plot", "highlight only", BLUE, BLUE_DARK),
        ("Build Wheel Overlay", "same view, preview only", GREEN, GREEN_DARK),
    ]
    x = 90
    y = 300
    w = 288
    h = 170
    gap = 45
    boxes = []
    for idx, (title, body, fill, outline) in enumerate(steps):
        x1 = x + idx * (w + gap)
        box = (x1, y, x1 + w, y + h)
        boxes.append(box)
        card(draw, box, title, body, fill, outline)
    for left, right in zip(boxes, boxes[1:]):
        arrow(draw, (left[2] + 8, y + h // 2), (right[0] - 8, y + h // 2))

    panel(
        draw,
        (120, 650, 1120, 1130),
        "What This Fixes",
        [
            "ThemeIsland is not a tiny fixed island.",
            "Plot count comes from the theme need.",
            "Plot size differs by element: house is not a beet.",
            "Slots stay exchangeable or configurable.",
        ],
        GREEN,
        GREEN_DARK,
        50,
    )
    panel(
        draw,
        (1280, 650, 2280, 1130),
        "Still Blocked",
        [
            "No automatic word placement.",
            "No direct build execution.",
            "No persistence or runtime config.",
            "No assets and no frame_started.",
        ],
        RED,
        RED_DARK,
        50,
    )
    footer(draw)
    path = OUT_DIR / "01_theme_to_plot_capacity_pipeline.png"
    image.save(path)
    return path


def village_map() -> Path:
    image, draw = canvas(
        "M16-I Village Plot Capacity Map",
        "Example: Dorf / Zuhause / Alltag needs different plot types and sizes",
    )
    island = (350, 280, 2050, 1120)
    draw.rounded_rectangle(island, radius=220, fill="#dcefdc", outline=GREEN_DARK, width=5)
    draw.rounded_rectangle((430, 360, 1970, 1040), radius=170, fill="#edf7e8", outline="#a8c8a6", width=3)
    plots = [
        ((620, 430, 960, 650), "Haus", "gross", GREEN_DARK),
        ((1010, 385, 1280, 560), "Vorhof", "mittel", BLUE_DARK),
        ((1360, 420, 1630, 595), "Garage", "mittel", YELLOW_DARK),
        ((590, 710, 930, 920), "Garten", "gross", MINT_DARK),
        ((990, 690, 1290, 915), "Beet/Feld", "mittel/gross", GREEN_DARK),
        ((1390, 700, 1645, 900), "Baum/Natur", "klein/mittel", VIOLET_DARK),
        ((850, 925, 1540, 1020), "Weg / Platz", "verbindend", BLUE_DARK),
        ((1690, 610, 1880, 850), "Erweiterung", "reserve", RED_DARK),
    ]
    for box, title, size, outline in plots:
        x1, y1, x2, y2 = box
        draw.rounded_rectangle(box, radius=28, fill=PANEL, outline=outline, width=4)
        draw.text((x1 + 18, y1 + 18), title, fill=outline, font=FONT_BODY)
        draw.text((x1 + 18, y1 + 54), size, fill=INK, font=FONT_SMALL)

    draw.text((420, 250), "Island size follows plot demand, not fixed slot count.", fill=INK, font=FONT_SECTION)
    panel(
        draw,
        (110, 1138, 2290, 1355),
        "Village Capacity Rule",
        [
            "House needs more space than garage or carport.",
            "Garden and field need flexible area logic.",
            "Path/square connects, it is not a normal building plot.",
            "Nature plot must avoid decoration clutter.",
        ],
        BLUE,
        BLUE_DARK,
        112,
        FONT_BODY,
        FONT_SMALL,
    )
    footer(draw)
    path = OUT_DIR / "02_village_plot_capacity_map.png"
    image.save(path)
    return path


def build_wheel_flow() -> Path:
    image, draw = canvas(
        "M16-I In-Place Build Wheel Flow",
        "Plot selection opens an overlay in the same view: no new page, no route, preview only",
    )
    steps = [
        ("Tap Plot", "user chooses a slot", BLUE, BLUE_DARK),
        ("Plot Highlight", "local visual focus", GREEN, GREEN_DARK),
        ("Wheel Popup", "same view overlay", VIOLET, VIOLET_DARK),
        ("Choose Candidate", "house / garden / path etc.", YELLOW, YELLOW_DARK),
        ("Preview Only", "no build state", GREEN, GREEN_DARK),
        ("Later Gate or Cancel", "confirm later / dismiss", RED, RED_DARK),
    ]
    x = 110
    y = 300
    w = 330
    h = 180
    gap = 55
    boxes = []
    for idx, (title, body, fill, outline) in enumerate(steps):
        x1 = x + idx * (w + gap)
        box = (x1, y, x1 + w, y + h)
        boxes.append(box)
        card(draw, box, title, body, fill, outline)
    for left, right in zip(boxes, boxes[1:]):
        arrow(draw, (left[2] + 8, y + h // 2), (right[0] - 8, y + h // 2))

    wheel_center = (WIDTH // 2, 860)
    draw.ellipse(
        (wheel_center[0] - 210, wheel_center[1] - 210, wheel_center[0] + 210, wheel_center[1] + 210),
        fill="#fdfbf3",
        outline=VIOLET_DARK,
        width=5,
    )
    candidates = ["Haus", "Garage", "Garten", "Beet", "Baum", "Vorhof", "Weg", "Cancel"]
    positions = [
        (0, -160),
        (113, -113),
        (160, 0),
        (113, 113),
        (0, 160),
        (-113, 113),
        (-160, 0),
        (-113, -113),
    ]
    for label, (dx, dy) in zip(candidates, positions):
        cx = wheel_center[0] + dx
        cy = wheel_center[1] + dy
        draw.rounded_rectangle((cx - 74, cy - 34, cx + 74, cy + 34), radius=22, fill=BLUE, outline=BLUE_DARK, width=3)
        tw = draw.textlength(label, font=FONT_SMALL)
        draw.text((cx - tw / 2, cy - 11), label, fill=INK, font=FONT_SMALL)
    draw.text((wheel_center[0] - 70, wheel_center[1] - 14), "Overlay", fill=VIOLET_DARK, font=FONT_BODY)

    panel(
        draw,
        (150, 1148, 2250, 1305),
        "Wheel Rule",
        ["same island view, abortable, no hard routing, no persistence, no build state, no frame_started"],
        GREEN,
        GREEN_DARK,
        110,
        FONT_BODY,
        FONT_SMALL,
    )
    footer(draw)
    path = OUT_DIR / "03_in_place_build_wheel_flow.png"
    image.save(path)
    return path


def allowed_blocked() -> Path:
    image, draw = canvas(
        "M16-I Allowed vs Blocked Plot Build Scope",
        "Planning boundary for plot selection and in-place build wheel concept",
    )
    panel(
        draw,
        (120, 290, 1120, 1185),
        "Allowed In M16-I",
        [
            "theme-to-plot capacity planning",
            "plot size and exchangeability matrix",
            "in-place overlay / wheel concept",
            "wheel candidate preview only",
            "slot select and deselect as UX rule",
            "documentation PNGs under docs/",
        ],
        GREEN,
        GREEN_DARK,
        50,
    )
    panel(
        draw,
        (1280, 290, 2280, 1185),
        "Blocked In M16-I",
        [
            "real build or build-wheel implementation",
            "persistence, Supabase, local DB",
            "assets or files under assets/",
            "automatic word placement",
            "route, new page, app integration",
            "build state and frame_started",
        ],
        RED,
        RED_DARK,
        50,
    )
    footer(draw)
    path = OUT_DIR / "04_allowed_vs_blocked_plot_build_scope.png"
    image.save(path)
    return path


def contact_sheet(paths: list[Path]) -> Path:
    image = Image.new("RGB", (2400, 1600), BG)
    draw = ImageDraw.Draw(image)
    draw.text((90, 50), "M16-I Theme Island Plot Capacity Contact Sheet", fill=INK, font=FONT_TITLE)
    draw.text((92, 120), "Documentation previews only: no code, no assets, no build state", fill=MUTED, font=FONT_SUBTITLE)
    thumb_w = 980
    thumb_h = 612
    positions = [(120, 230), (1280, 230), (120, 920), (1280, 920)]
    for path, (x, y) in zip(paths, positions):
        thumb = Image.open(path).resize((thumb_w, thumb_h))
        draw.rounded_rectangle((x - 10, y - 10, x + thumb_w + 10, y + thumb_h + 10), radius=22, fill=PANEL, outline=LINE, width=3)
        image.paste(thumb, (x, y))
        draw.text((x, y + thumb_h + 22), path.name, fill=INK, font=FONT_SMALL)
    out = OUT_DIR / "00_contact_sheet.png"
    image.save(out)
    return out


def main() -> None:
    paths = [
        theme_pipeline(),
        village_map(),
        build_wheel_flow(),
        allowed_blocked(),
    ]
    paths.insert(0, contact_sheet(paths))
    for path in paths:
        print(path.name)


if __name__ == "__main__":
    main()
