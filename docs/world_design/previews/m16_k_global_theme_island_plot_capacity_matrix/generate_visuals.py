from pathlib import Path
from PIL import Image, ImageDraw, ImageFont


OUT = Path(__file__).resolve().parent
W, H = 2400, 1500

BG = "#f6f1e8"
INK = "#243336"
MUTED = "#6d7776"
LINE = "#cfc6b6"
PANEL = "#fffdf8"
GREEN = "#dcefdc"
GREEN_D = "#3f7b4b"
BLUE = "#dcebf4"
BLUE_D = "#3d7190"
SAND = "#f4e7c2"
SAND_D = "#8a7132"
PURPLE = "#e7ddf1"
PURPLE_D = "#70548d"
RED = "#f2d8d8"
RED_D = "#98514f"
MINT = "#d9eee7"
MINT_D = "#397c70"
GRAY = "#ece7dd"
GRAY_D = "#776f64"


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    names = [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    ]
    for name in names:
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()


TITLE = font(58, True)
SUB = font(30)
H1 = font(34, True)
H2 = font(27, True)
BODY = font(24)
SMALL = font(20)
FOOT = font(21, True)


def text_size(draw: ImageDraw.ImageDraw, text: str, fnt: ImageFont.ImageFont) -> tuple[int, int]:
    box = draw.textbbox((0, 0), text, font=fnt)
    return box[2] - box[0], box[3] - box[1]


def wrap(draw: ImageDraw.ImageDraw, text: str, fnt: ImageFont.ImageFont, max_width: int) -> list[str]:
    lines: list[str] = []
    for raw in text.split("\n"):
        words = raw.split()
        if not words:
            lines.append("")
            continue
        line = words[0]
        for word in words[1:]:
            test = f"{line} {word}"
            if text_size(draw, test, fnt)[0] <= max_width:
                line = test
            else:
                lines.append(line)
                line = word
        lines.append(line)
    return lines


def draw_wrapped(
    draw: ImageDraw.ImageDraw,
    text: str,
    xy: tuple[int, int],
    fnt: ImageFont.ImageFont,
    fill: str,
    max_width: int,
    line_gap: int = 8,
) -> int:
    x, y = xy
    for line in wrap(draw, text, fnt, max_width):
        draw.text((x, y), line, font=fnt, fill=fill)
        y += text_size(draw, line or " ", fnt)[1] + line_gap
    return y


def header(draw: ImageDraw.ImageDraw, title: str, subtitle: str) -> None:
    draw.text((90, 55), title, font=TITLE, fill=INK)
    draw.text((90, 130), subtitle, font=SUB, fill=MUTED)
    draw.line((90, 185, W - 90, 185), fill=LINE, width=3)


def footer(draw: ImageDraw.ImageDraw) -> None:
    y = H - 85
    draw.rounded_rectangle((90, y, W - 90, y + 52), radius=14, fill="#eee6d8", outline="#d6cdbc", width=2)
    draw.text(
        (115, y + 15),
        "documentation preview only / no code / no assets / no route / no persistence / no build state / no frame_started",
        font=FOOT,
        fill=INK,
    )


def canvas(title: str, subtitle: str) -> tuple[Image.Image, ImageDraw.ImageDraw]:
    img = Image.new("RGB", (W, H), BG)
    draw = ImageDraw.Draw(img)
    header(draw, title, subtitle)
    footer(draw)
    return img, draw


def card(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    title: str,
    body: str,
    fill: str,
    outline: str,
    title_color: str | None = None,
) -> None:
    x1, y1, x2, y2 = box
    draw.rounded_rectangle(box, radius=20, fill=fill, outline=outline, width=4)
    draw_wrapped(draw, title, (x1 + 22, y1 + 20), H2, title_color or outline, x2 - x1 - 44, 6)
    draw_wrapped(draw, body, (x1 + 22, y1 + 68), BODY, INK, x2 - x1 - 44, 8)


def chip(draw: ImageDraw.ImageDraw, xy: tuple[int, int], label: str, fill: str, outline: str, w: int = 190) -> None:
    x, y = xy
    draw.rounded_rectangle((x, y, x + w, y + 42), radius=18, fill=fill, outline=outline, width=2)
    tw, th = text_size(draw, label, SMALL)
    draw.text((x + (w - tw) / 2, y + (42 - th) / 2 - 1), label, font=SMALL, fill=outline)


def arrow(draw: ImageDraw.ImageDraw, start: tuple[int, int], end: tuple[int, int], color: str = LINE) -> None:
    draw.line((*start, *end), fill=color, width=5)
    ex, ey = end
    sx, sy = start
    if ex >= sx:
        pts = [(ex, ey), (ex - 18, ey - 11), (ex - 18, ey + 11)]
    else:
        pts = [(ex, ey), (ex + 18, ey - 11), (ex + 18, ey + 11)]
    draw.polygon(pts, fill=color)


def make_category_map() -> Path:
    img, draw = canvas(
        "M16-K Global Category To Plot Family Map",
        "All documented ThemeIsland categories become their own capacity profiles",
    )

    groups = [
        ("Foundation", "Zuhause / Alltag\nSchule / Lernen\nGarten / Natur", "home, school, garden, path, container", GREEN, GREEN_D),
        ("Expansion 1", "Essen / Cafe\nEinkauf / Versorgung\nLand / Farm", "food, market, farm, storage, yard", SAND, SAND_D),
        ("Expansion 2", "Kueste / Meer / Hafen\nOutdoor / Sport\nNatur / Berge", "water, dock, beach, nature, activity", PURPLE, PURPLE_D),
        ("System-heavy", "Stadt / Verkehr\nArbeit / Industrie\nTechnik / Digital", "hub, road, vehicle, workshop, tech", BLUE, BLUE_D),
        ("Sensitive / Special", "Gesundheit / Notfall\nKultur / Verwaltung\nReligion / Politik / Gericht / Polizei", "codex, context, policy gate", RED, RED_D),
    ]
    x = 95
    y = 265
    gap = 34
    box_w = 420
    for title, cats, families, fill, outline in groups:
        card(draw, (x, y, x + box_w, y + 440), title, cats, fill, outline)
        draw_wrapped(draw, "Plot families:", (x + 22, y + 250), SMALL, MUTED, box_w - 44, 4)
        chips = [p.strip() for p in families.split(",")]
        cx, cy = x + 22, y + 285
        for i, label in enumerate(chips[:5]):
            chip(draw, (cx + (i % 2) * 190, cy + (i // 2) * 50), label, PANEL, outline, 175)
        x += box_w + gap

    card(
        draw,
        (250, 1040, W - 250, 1230),
        "Global capacity rule",
        "M16-J village slots are one example only. Each category needs its own slot count, size mix, connectors, depth and gates before any later preview slice.",
        BLUE,
        BLUE_D,
    )

    path = OUT / "01_global_category_to_plot_family_map.png"
    img.save(path)
    return path


def make_size_mix() -> Path:
    img, draw = canvas(
        "M16-K ThemeIsland Size Mix Comparison",
        "Different categories require different plot counts, sizes, connectors and depth",
    )

    rows = [
        ("Dorf / Zuhause", "5-8", [("medium", 2), ("large", 2), ("path", 1), ("container", 1)], GREEN_D),
        ("Kueste / Hafen", "8-12", [("water", 3), ("large", 2), ("dock", 2), ("container", 1)], PURPLE_D),
        ("Farm / Land", "8-12", [("large", 4), ("very large", 2), ("path", 1), ("reserve", 1)], SAND_D),
        ("Stadt / Zentrum", "12+", [("hub", 2), ("path", 4), ("medium", 3), ("public", 2)], BLUE_D),
        ("Schule / Lernen", "5-8", [("medium", 2), ("interior", 2), ("container", 2), ("yard", 1)], GREEN_D),
        ("Garten / Natur", "3-8", [("small", 2), ("medium", 2), ("large", 2), ("reserve", 1)], MINT_D),
    ]

    legend = {
        "small": (MINT, MINT_D, 56),
        "medium": (GREEN, GREEN_D, 86),
        "large": (SAND, SAND_D, 116),
        "very large": (RED, RED_D, 146),
        "path": (BLUE, BLUE_D, 160),
        "dock": (PURPLE, PURPLE_D, 110),
        "water": (BLUE, BLUE_D, 130),
        "container": (GRAY, GRAY_D, 118),
        "reserve": (PANEL, GRAY_D, 96),
        "hub": (SAND, SAND_D, 120),
        "public": (PURPLE, PURPLE_D, 110),
        "interior": (GRAY, GRAY_D, 100),
        "yard": (MINT, MINT_D, 92),
    }

    y = 260
    for name, count, mix, color in rows:
        draw.text((120, y + 20), name, font=H2, fill=color)
        draw.text((120, y + 60), f"planned min: {count}", font=SMALL, fill=MUTED)
        x = 450
        for label, n in mix:
            fill, outline, width = legend[label]
            for _ in range(n):
                draw.rounded_rectangle((x, y + 15, x + width, y + 75), radius=12, fill=fill, outline=outline, width=3)
                tw, th = text_size(draw, label, SMALL)
                draw.text((x + (width - tw) / 2, y + 35 - th / 2), label, font=SMALL, fill=outline)
                x += width + 14
        draw.line((110, y + 105, W - 110, y + 105), fill="#ded6c8", width=2)
        y += 140

    card(
        draw,
        (230, 1135, W - 230, 1275),
        "Planning note",
        "Counts are rough planning bands, not final data. A later preview must prove readability on mobile before any implementation gate.",
        RED,
        RED_D,
    )
    path = OUT / "02_theme_island_size_mix_comparison.png"
    img.save(path)
    return path


def make_coast_example() -> Path:
    img, draw = canvas(
        "M16-K Coast / Harbor Plot Capacity Example",
        "Water, beach and dock families cannot be reduced to village slots",
    )

    # Island / water composition.
    draw.rounded_rectangle((165, 285, 2140, 1035), radius=70, fill="#d8eef4", outline=BLUE_D, width=5)
    draw.text((210, 315), "Water area", font=H2, fill=BLUE_D)
    draw.rounded_rectangle((360, 480, 1980, 1000), radius=90, fill="#f4e5bb", outline=SAND_D, width=4)
    draw.text((420, 515), "Beach / coast edge", font=H2, fill=SAND_D)
    draw.rounded_rectangle((750, 420, 930, 800), radius=16, fill=GRAY, outline=GRAY_D, width=4)
    draw.text((775, 450), "Pier", font=H2, fill=GRAY_D)
    draw.rounded_rectangle((990, 350, 1310, 540), radius=26, fill=PANEL, outline=PURPLE_D, width=4)
    draw_wrapped(draw, "Boat slot\ntravel gated", (1015, 385), BODY, INK, 270, 6)
    draw.rounded_rectangle((1340, 595, 1660, 770), radius=26, fill=PANEL, outline=GREEN_D, width=4)
    draw_wrapped(draw, "Harbor storage\ncontainer gated", (1365, 625), BODY, INK, 270, 6)
    draw.rounded_rectangle((1680, 780, 1930, 940), radius=26, fill=PANEL, outline=SAND_D, width=4)
    draw_wrapped(draw, "Market / fish stand\noptional", (1705, 815), BODY, INK, 205, 6)
    draw.rounded_rectangle((480, 800, 720, 930), radius=26, fill=PANEL, outline=PURPLE_D, width=4)
    draw_wrapped(draw, "Rock / edge\nclutter gate", (505, 825), BODY, INK, 190, 6)
    draw.rounded_rectangle((1660, 390, 1890, 550), radius=26, fill=PANEL, outline=RED_D, width=4)
    draw_wrapped(draw, "Reserve\nlater only", (1685, 430), BODY, INK, 180, 6)

    card(
        draw,
        (180, 1090, 1085, 1265),
        "Required families",
        "water surface, beach edge, pier/dock, boat slot, harbor container, optional market, edge rocks, reserve.",
        BLUE,
        BLUE_D,
    )
    card(
        draw,
        (1205, 1090, 2210, 1265),
        "Hard gates",
        "no water logic, no boat system, no assets, no Build-Wheel code, no persistence, no frame_started.",
        RED,
        RED_D,
    )
    path = OUT / "03_coast_harbor_plot_capacity_example.png"
    img.save(path)
    return path


def make_allowed_blocked() -> Path:
    img, draw = canvas(
        "M16-K Global Allowed vs Blocked Scope",
        "The matrix broadens planning before any category-specific preview slice",
    )

    card(
        draw,
        (120, 295, 1120, 1110),
        "Allowed Now",
        "- collect documented categories\n- derive plot-capacity profiles\n- compare size mixes\n- create documentation visuals\n- keep M16-J as village example\n- prepare later preview candidates",
        GREEN,
        GREEN_D,
    )
    card(
        draw,
        (1280, 295, 2280, 1110),
        "Blocked Now",
        "- Flutter / Dart changes\n- app integration or route\n- Build-Wheel code\n- assets or files under assets/\n- persistence or runtime config\n- automatic word placement\n- build state or frame_started",
        RED,
        RED_D,
    )
    arrow(draw, (1138, 704), (1260, 704))
    draw.text((1070, 735), "next decision later", font=SMALL, fill=MUTED)

    card(
        draw,
        (395, 1170, 2005, 1300),
        "M16-J handling",
        "Do not delete and do not commit as the narrow next candidate. M16-K supplements it with global category profiles first.",
        BLUE,
        BLUE_D,
    )
    path = OUT / "04_global_allowed_vs_blocked_scope.png"
    img.save(path)
    return path


def make_contact_sheet(paths: list[Path]) -> Path:
    thumbs = []
    for path in paths:
        img = Image.open(path).convert("RGB")
        img.thumbnail((1080, 675))
        thumbs.append((path, img.copy()))

    sheet = Image.new("RGB", (2400, 1500), BG)
    draw = ImageDraw.Draw(sheet)
    header(draw, "M16-K Contact Sheet", "Global ThemeIsland plot capacity documentation previews")
    positions = [(90, 260), (1230, 260), (90, 900), (1230, 900)]
    for (path, img), (x, y) in zip(thumbs, positions):
        draw.rounded_rectangle((x - 12, y - 12, x + 1092, y + 612), radius=18, fill=PANEL, outline=LINE, width=2)
        sheet.paste(img, (x, y))
        draw.text((x, y + 615), path.name, font=SMALL, fill=INK)
    footer(draw)
    out = OUT / "00_contact_sheet.png"
    sheet.save(out)
    return out


def main() -> None:
    paths = [
        make_category_map(),
        make_size_mix(),
        make_coast_example(),
        make_allowed_blocked(),
    ]
    contact = make_contact_sheet(paths)
    for path in [contact, *paths]:
        print(path.name)


if __name__ == "__main__":
    main()
