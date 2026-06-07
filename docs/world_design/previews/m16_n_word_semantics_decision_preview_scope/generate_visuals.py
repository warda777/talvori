from pathlib import Path
from PIL import Image, ImageDraw, ImageFont


OUT = Path(__file__).resolve().parent
W, H = 2400, 1600

BG = "#f6f1e8"
PANEL = "#fffdf8"
INK = "#243336"
MUTED = "#66706e"
LINE = "#cec4b2"
GREEN = "#dcefdc"
GREEN_D = "#3f7b4b"
BLUE = "#dcebf4"
BLUE_D = "#3d7190"
AMBER = "#f4e7c2"
AMBER_D = "#8a7132"
RED = "#f2d8d8"
RED_D = "#98514f"
PURPLE = "#e7ddf1"
PURPLE_D = "#70548d"
MINT = "#d9eee7"
MINT_D = "#397c70"
GRAY = "#ece7dd"
GRAY_D = "#776f64"


def font(size: int, bold: bool = False) -> ImageFont.ImageFont:
    candidates = [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    ]
    for name in candidates:
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()


TITLE = font(54, True)
SUB = font(30)
H1 = font(34, True)
H2 = font(27, True)
BODY = font(22)
SMALL = font(19)
TINY = font(16)
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
    line_gap: int = 7,
) -> int:
    x, y = xy
    for line in wrap(draw, text, fnt, max_width):
        draw.text((x, y), line, font=fnt, fill=fill)
        y += text_size(draw, line or " ", fnt)[1] + line_gap
    return y


def header(draw: ImageDraw.ImageDraw, title: str, subtitle: str, width: int = W) -> None:
    draw.text((90, 52), title, font=TITLE, fill=INK)
    draw.text((90, 128), subtitle, font=SUB, fill=MUTED)
    draw.line((90, 183, width - 90, 183), fill=LINE, width=3)


def footer(draw: ImageDraw.ImageDraw, height: int = H, width: int = W) -> None:
    y = height - 86
    draw.rounded_rectangle((90, y, width - 90, y + 54), radius=14, fill="#eee6d8", outline="#d6cdbc", width=2)
    draw.text(
        (115, y + 16),
        "documentation preview only / no code / no assets / no route / no persistence / no automatic placement / no frame_started",
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
    body_font=BODY,
    title_font=H2,
) -> None:
    x1, y1, x2, y2 = box
    draw.rounded_rectangle(box, radius=20, fill=fill, outline=outline, width=4)
    draw_wrapped(draw, title, (x1 + 22, y1 + 18), title_font, outline, x2 - x1 - 44, 5)
    draw_wrapped(draw, body, (x1 + 22, y1 + 74), body_font, INK, x2 - x1 - 44, 7)


def chip(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], label: str, fill: str, outline: str, fnt=SMALL) -> None:
    draw.rounded_rectangle(box, radius=14, fill=fill, outline=outline, width=2)
    tw, th = text_size(draw, label, fnt)
    x1, y1, x2, y2 = box
    draw.text((x1 + (x2 - x1 - tw) / 2, y1 + (y2 - y1 - th) / 2 - 1), label, font=fnt, fill=outline)


def arrow(draw: ImageDraw.ImageDraw, start: tuple[int, int], end: tuple[int, int], color: str = LINE) -> None:
    draw.line((*start, *end), fill=color, width=5)
    sx, sy = start
    ex, ey = end
    if abs(ex - sx) >= abs(ey - sy):
        pts = [(ex, ey), (ex - 18, ey - 11), (ex - 18, ey + 11)] if ex >= sx else [(ex, ey), (ex + 18, ey - 11), (ex + 18, ey + 11)]
    else:
        pts = [(ex, ey), (ex - 11, ey - 18), (ex + 11, ey - 18)] if ey >= sy else [(ex, ey), (ex - 11, ey + 18), (ex + 11, ey + 18)]
    draw.polygon(pts, fill=color)


def make_pipeline() -> Path:
    img, draw = canvas(
        "M16-N Word Semantics Preview Pipeline",
        "A word becomes a safe preview decision before any world, plot or build state exists",
    )
    steps = [
        ("Word / Intent", "user word or phrase"),
        ("Context / Sense", "ask when meaning is unclear"),
        ("Word Type", "noun, verb, emotion, tiny object"),
        ("Safety Check", "sensitive or abstract gate"),
        ("Theme Candidates", "one or more islands"),
        ("Plot / Depth", "plot, interior, container or none"),
        ("Representation", "choose safe output"),
        ("User Choice", "confirm, defer or inspect"),
        ("Preview Only", "no storage or placement"),
        ("Later Gate", "separate approval required"),
    ]
    colors = [(BLUE, BLUE_D), (MINT, MINT_D), (AMBER, AMBER_D), (RED, RED_D), (PURPLE, PURPLE_D)]
    x0, y0 = 110, 300
    box_w, box_h, gap_x, gap_y = 400, 170, 40, 130
    centers: list[tuple[int, int]] = []
    for i, (title, body) in enumerate(steps):
        row = i // 5
        col = i % 5
        x = x0 + col * (box_w + gap_x)
        y = y0 + row * (box_h + gap_y)
        fill, outline = colors[i % len(colors)]
        card(draw, (x, y, x + box_w, y + box_h), title, body, fill, outline, body_font=SMALL)
        centers.append((x + box_w // 2, y + box_h // 2))
    for i in range(4):
        arrow(draw, (centers[i][0] + box_w // 2 - 15, centers[i][1]), (centers[i + 1][0] - box_w // 2 + 15, centers[i + 1][1]))
    arrow(draw, (centers[4][0], centers[4][1] + box_h // 2 + 12), (centers[9][0], centers[9][1] - box_h // 2 - 12))
    for i in range(9, 5, -1):
        arrow(draw, (centers[i][0] - box_w // 2 + 15, centers[i][1]), (centers[i - 1][0] + box_w // 2 - 15, centers[i - 1][1]))
    card(
        draw,
        (280, 1135, 2120, 1305),
        "Core rule",
        "Not every word is built, not every word receives a plot, not every word belongs to one category, and no word is automatically placed.",
        GREEN,
        GREEN_D,
        body_font=BODY,
    )
    path = OUT / "01_word_semantics_preview_pipeline.png"
    img.save(path)
    return path


EXAMPLES = [
    ("Haus", "Home, city, farm, coast", "Multi-home. User/context choice before any building candidate."),
    ("Garage", "Home, traffic, city", "Not automatically home. Utility or vehicle context first."),
    ("Baum", "Nature, city park, farm", "Nature/decor/clutter gate before visible placement."),
    ("schwimmen", "Water, leisure, sport", "ActionChallenge or ContextCard. No building."),
    ("Angst", "Emotion / feeling", "Companion, ContextCard or Codex. No object or pressure."),
    ("lernen", "Action / learning mode", "Challenge or LearningMode. School is not automatic."),
    ("Messer", "Kitchen, tool, container", "Safety/context gate. Possible ContainerItem only."),
    ("Polizei", "Public institution", "Policy gate. No automatic police station."),
]


def make_example_cards() -> Path:
    img, draw = canvas(
        "M16-N Example Word Decision Cards",
        "Each example shows why the preview must decide before it visualizes",
    )
    x0, y0 = 115, 285
    card_w, card_h, gap_x, gap_y = 520, 300, 45, 70
    fills = [(BLUE, BLUE_D), (AMBER, AMBER_D), (MINT, MINT_D), (PURPLE, PURPLE_D), (RED, RED_D), (GREEN, GREEN_D), (GRAY, GRAY_D), (RED, RED_D)]
    for i, (word, candidates, decision) in enumerate(EXAMPLES):
        row = i // 4
        col = i % 4
        x = x0 + col * (card_w + gap_x)
        y = y0 + row * (card_h + gap_y)
        fill, outline = fills[i]
        draw.rounded_rectangle((x, y, x + card_w, y + card_h), radius=20, fill=fill, outline=outline, width=4)
        draw_wrapped(draw, word, (x + 24, y + 18), H1, outline, card_w - 48, 5)
        chip(draw, (x + 24, y + 86, x + card_w - 24, y + 132), candidates, PANEL, outline, fnt=SMALL)
        draw_wrapped(draw, decision, (x + 24, y + 158), BODY, INK, card_w - 48, 8)
    card(
        draw,
        (430, 1270, 1970, 1395),
        "Preview stance",
        "The card result is a visible explanation, not a route, data structure, placement, build wheel or saved world action.",
        GREEN,
        GREEN_D,
        body_font=SMALL,
    )
    path = OUT / "02_example_word_decision_cards.png"
    img.save(path)
    return path


def make_outputs_map() -> Path:
    img, draw = canvas(
        "M16-N Representation Outputs Map",
        "A safe decision can end in many outputs; visible placement is only one candidate",
    )
    card(
        draw,
        (770, 275, 1630, 445),
        "Representation Decision",
        "Choose the safest preview outcome after context, word type, safety, theme and depth checks.",
        PURPLE,
        PURPLE_D,
        body_font=SMALL,
    )
    chip(draw, (785, 505, 1615, 565), "Output lanes below are alternatives, not automatic placement", PANEL, PURPLE_D)
    outputs = [
        ("PlacementCandidate", "Visible option only after user choice; still no final runtime structure.", GREEN, GREEN_D),
        ("Blueprint", "Future plan when object or building context is not ready.", BLUE, BLUE_D),
        ("Codex", "Learn or explain without visible placement.", MINT, MINT_D),
        ("Backlog", "Wait for island, sense, safety, depth or user decision.", GRAY, GRAY_D),
        ("ContextCard", "Neutral explanation for abstract, sensitive or unclear terms.", AMBER, AMBER_D),
        ("ActionChallenge", "For verbs and sequences; not a static object.", PURPLE, PURPLE_D),
        ("ContainerItem", "Small object inside depth/container, not permanent island clutter.", RED, RED_D),
    ]
    positions = [
        (140, 585),
        (720, 585),
        (1300, 585),
        (1880, 585),
        (430, 980),
        (1010, 980),
        (1590, 980),
    ]
    for (title, body, fill, outline), (x, y) in zip(outputs, positions):
        card(draw, (x, y, x + 440, y + 250), title, body, fill, outline, body_font=SMALL)
    chip(draw, (650, 1335, 1750, 1395), "All outputs remain preview-only until a separate later gate", PANEL, BLUE_D)
    path = OUT / "03_representation_outputs_map.png"
    img.save(path)
    return path


def make_allowed_blocked() -> Path:
    img, draw = canvas(
        "M16-N Allowed vs Blocked Word Semantics Scope",
        "This block defines a preview scope; it does not implement the preview",
    )
    card(
        draw,
        (130, 290, 1110, 1160),
        "Allowed in M16-N",
        "Scope documentation\nExample-word decisions\nPipeline definition\nRepresentation outputs\nDocumentation PNG previews\nVisual quality review\nRoadmap/template notes\nFuture minimal-scope planning",
        GREEN,
        GREEN_D,
        body_font=BODY,
    )
    card(
        draw,
        (1290, 290, 2270, 1160),
        "Blocked in M16-N",
        "Flutter/Dart code\nApp integration or route\nNew page or navigation\nReal routing implementation\nFinal data structure\nPersistence or runtime config\nAssets under assets/\nAutomatic word placement\nBuild-Wheel implementation\nBuild-State or frame_started",
        RED,
        RED_D,
        body_font=BODY,
    )
    chip(draw, (675, 1245, 1725, 1305), "Next possible code only after explicit user approval", PANEL, BLUE_D)
    path = OUT / "04_allowed_vs_blocked_word_semantics_scope.png"
    img.save(path)
    return path


def make_contact_sheet(paths: list[Path]) -> Path:
    sheet_h = 1900
    sheet = Image.new("RGB", (W, sheet_h), BG)
    draw = ImageDraw.Draw(sheet)
    header(draw, "M16-N Contact Sheet", "Quick overview of word semantics decision preview scope visuals")
    positions = [(130, 285), (1240, 285), (130, 1015), (1240, 1015)]
    thumb_max = (880, 560)
    card_w, card_h = 1000, 675
    for path, (x, y) in zip(paths, positions):
        img = Image.open(path).convert("RGB")
        img.thumbnail(thumb_max)
        draw.rounded_rectangle((x - 18, y - 18, x - 18 + card_w, y - 18 + card_h), radius=20, fill=PANEL, outline=LINE, width=3)
        sheet.paste(img, (x, y))
        draw_wrapped(draw, path.name, (x, y + img.height + 25), SMALL, INK, card_w - 60, 4)
    footer(draw, sheet_h)
    out = OUT / "00_contact_sheet.png"
    sheet.save(out)
    return out


def main() -> None:
    paths = [
        make_pipeline(),
        make_example_cards(),
        make_outputs_map(),
        make_allowed_blocked(),
    ]
    contact = make_contact_sheet(paths)
    print("\n".join(str(path) for path in [contact, *paths]))


if __name__ == "__main__":
    main()
