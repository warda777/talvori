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
FONT_FOOTER = font(21, True)


def lines(text: str, width: int) -> list[str]:
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
        "documentation preview only / no code / no assets / no route / "
        "no persistence / no build state / no frame_started"
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
) -> None:
    x1, y1, x2, y2 = box
    draw.rounded_rectangle(box, radius=24, fill=fill, outline=outline, width=4)
    draw.text((x1 + 24, y1 + 22), title, fill=outline, font=FONT_SECTION)
    y = y1 + 74
    for item in body:
        draw.text((x1 + 26, y), "-", fill=INK, font=FONT_BODY)
        item_lines = lines(item, wrap_width)
        for idx, line in enumerate(item_lines):
            draw.text((x1 + 54, y + idx * 28), line, fill=INK, font=FONT_BODY)
        y += max(1, len(item_lines)) * 28 + 11
        if y > y2 - 36:
            break


def card(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    title: str,
    subtitle: str,
    fill: str,
    outline: str,
    title_font: ImageFont.FreeTypeFont = FONT_BODY,
) -> None:
    x1, y1, x2, y2 = box
    draw.rounded_rectangle(box, radius=22, fill=fill, outline=outline, width=4)
    draw.text((x1 + 18, y1 + 18), title, fill=outline, font=title_font)
    y = y1 + 56
    for line in lines(subtitle, 22):
        draw.text((x1 + 18, y), line, fill=INK, font=FONT_SMALL)
        y += 23


def arrow(draw: ImageDraw.ImageDraw, start: tuple[int, int], end: tuple[int, int]) -> None:
    draw.line((*start, *end), fill=LINE, width=5)
    ex, ey = end
    sx, _ = start
    if ex >= sx:
        points = [(ex, ey), (ex - 16, ey - 10), (ex - 16, ey + 10)]
    else:
        points = [(ex, ey), (ex + 16, ey - 10), (ex + 16, ey + 10)]
    draw.polygon(points, fill=LINE)


def slot_size_map() -> Path:
    image, draw = canvas(
        "M16-J Village Slot Size Map",
        "Local preview idea: many abstract slots, different sizes, no buildings or assets",
    )
    island = (280, 260, 2120, 1090)
    draw.rounded_rectangle(island, radius=240, fill="#dcefdc", outline=GREEN_DARK, width=5)
    draw.rounded_rectangle((365, 340, 2035, 1005), radius=170, fill="#eef8ea", outline="#a8c8a6", width=3)
    draw.text((390, 238), "Slots are abstract and exchangeable. Labels describe capacity, not fixed buildings.", fill=INK, font=FONT_BODY)
    plots = [
        ((550, 410, 910, 650), "Haus-Slot", "gross", GREEN_DARK),
        ((980, 390, 1260, 570), "Vorhof", "mittel", BLUE_DARK),
        ((1370, 410, 1655, 585), "Garage", "mittel", YELLOW_DARK),
        ((520, 725, 910, 930), "Garten", "gross/flex", MINT_DARK),
        ((990, 690, 1320, 930), "Beet/Feld", "mittel/gross", GREEN_DARK),
        ((1420, 700, 1690, 900), "Baum/Natur", "klein/mittel", VIOLET_DARK),
        ((760, 930, 1580, 1030), "Weg / Platz", "verbindend", BLUE_DARK),
        ((1760, 590, 1960, 840), "Reserve", "spaeter", RED_DARK),
    ]
    for box, title, size, outline in plots:
        fill = PANEL if title != "Weg / Platz" else BLUE
        card(draw, box, title, size, fill, outline)

    panel(
        draw,
        (120, 1150, 2280, 1332),
        "Preview Rule",
        [
            "VillagePlotCapacityPreview would show capacity only: sizes, slots, connector, highlight.",
            "No final island graphic, no fixed building occupancy, no assets, no build state.",
        ],
        BLUE,
        BLUE_DARK,
        112,
    )
    footer(draw)
    path = OUT_DIR / "01_village_slot_size_map.png"
    image.save(path)
    return path


def exchangeability_flow() -> Path:
    image, draw = canvas(
        "M16-J Slot Exchangeability Flow",
        "Local selection stays on the same preview surface; wheel remains later",
    )
    steps = [
        ("Slot wählen", "local selection only", BLUE, BLUE_DARK),
        ("Slot Highlight", "selected capacity area", GREEN, GREEN_DARK),
        ("Wheel später", "not implemented now", VIOLET, VIOLET_DARK),
        ("Candidate Preview", "abstract possibility", YELLOW, YELLOW_DARK),
        ("Cancel / Deselect", "back to neutral slots", RED, RED_DARK),
    ]
    x = 150
    y = 320
    w = 360
    h = 180
    gap = 85
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
        (190, 720, 1100, 1135),
        "Exchangeability",
        [
            "Slots are capacity surfaces, not fixed buildings.",
            "A later wheel can propose compatible candidates.",
            "User can cancel or deselect without saving.",
        ],
        GREEN,
        GREEN_DARK,
        46,
    )
    panel(
        draw,
        (1300, 720, 2210, 1135),
        "Hard Limits",
        [
            "no route",
            "no persistence",
            "no build state",
            "no automatic word placement",
            "no frame_started",
        ],
        RED,
        RED_DARK,
        46,
    )
    footer(draw)
    path = OUT_DIR / "02_slot_exchangeability_flow.png"
    image.save(path)
    return path


def allowed_blocked() -> Path:
    image, draw = canvas(
        "M16-J Allowed vs Blocked Village Preview Scope",
        "Boundary for a future local multi-slot preview candidate",
    )
    panel(
        draw,
        (120, 290, 1120, 1185),
        "Allowed Later Preview",
        [
            "local abstract slot preview",
            "visible size comparison",
            "slot highlight and deselect",
            "connector path / square surface",
            "exchangeable capacity labels",
            "no fixed building occupancy",
        ],
        GREEN,
        GREEN_DARK,
        50,
    )
    panel(
        draw,
        (1280, 290, 2280, 1185),
        "Blocked Scope",
        [
            "buildings or final island art",
            "assets or files under assets/",
            "Build-Wheel code",
            "persistence or runtime config",
            "automatic word placement",
            "build state or frame_started",
        ],
        RED,
        RED_DARK,
        50,
    )
    footer(draw)
    path = OUT_DIR / "03_allowed_vs_blocked_village_preview_scope.png"
    image.save(path)
    return path


def contact_sheet(paths: list[Path]) -> Path:
    image = Image.new("RGB", (2400, 1500), BG)
    draw = ImageDraw.Draw(image)
    draw.text((90, 50), "M16-J Village Plot Capacity Contact Sheet", fill=INK, font=FONT_TITLE)
    draw.text((92, 120), "Documentation previews only: no code, no assets, no route, no build state", fill=MUTED, font=FONT_SUBTITLE)
    thumb_w = 680
    thumb_h = 425
    positions = [(115, 240), (860, 240), (1605, 240)]
    for path, (x, y) in zip(paths, positions):
        thumb = Image.open(path).resize((thumb_w, thumb_h))
        draw.rounded_rectangle((x - 10, y - 10, x + thumb_w + 10, y + thumb_h + 10), radius=22, fill=PANEL, outline=LINE, width=3)
        image.paste(thumb, (x, y))
        draw.text((x, y + thumb_h + 24), path.name, fill=INK, font=FONT_SMALL)
    panel(
        draw,
        (240, 825, 2160, 1225),
        "M16-J Recommendation",
        [
            "Next later code candidate: VillagePlotCapacityPreview.",
            "It should show abstract multi-slot capacity, not buildings.",
            "Compact Local World Surface remains a single-place prototype.",
            "Build-Wheel stays later and separate.",
        ],
        BLUE,
        BLUE_DARK,
        98,
    )
    footer(draw)
    out = OUT_DIR / "00_contact_sheet.png"
    image.save(out)
    return out


def main() -> None:
    paths = [slot_size_map(), exchangeability_flow(), allowed_blocked()]
    paths.insert(0, contact_sheet(paths))
    for path in paths:
        print(path.name)


if __name__ == "__main__":
    main()
