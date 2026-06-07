from pathlib import Path
from PIL import Image, ImageDraw, ImageFont


OUT = Path(__file__).resolve().parent
W, H = 2400, 1500

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


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
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
H2 = font(26, True)
BODY = font(23)
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


def header(draw: ImageDraw.ImageDraw, title: str, subtitle: str) -> None:
    draw.text((90, 52), title, font=TITLE, fill=INK)
    draw.text((90, 128), subtitle, font=SUB, fill=MUTED)
    draw.line((90, 183, W - 90, 183), fill=LINE, width=3)


def footer(draw: ImageDraw.ImageDraw, height: int = H) -> None:
    y = height - 86
    draw.rounded_rectangle((90, y, W - 90, y + 54), radius=14, fill="#eee6d8", outline="#d6cdbc", width=2)
    draw.text(
        (115, y + 16),
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
    body_font=BODY,
) -> None:
    x1, y1, x2, y2 = box
    draw.rounded_rectangle(box, radius=20, fill=fill, outline=outline, width=4)
    draw_wrapped(draw, title, (x1 + 22, y1 + 18), H2, outline, x2 - x1 - 44, 5)
    draw_wrapped(draw, body, (x1 + 22, y1 + 68), body_font, INK, x2 - x1 - 44, 7)


def arrow(draw: ImageDraw.ImageDraw, start: tuple[int, int], end: tuple[int, int], color: str = LINE) -> None:
    draw.line((*start, *end), fill=color, width=5)
    sx, sy = start
    ex, ey = end
    if abs(ex - sx) >= abs(ey - sy):
        pts = [(ex, ey), (ex - 18, ey - 11), (ex - 18, ey + 11)] if ex >= sx else [(ex, ey), (ex + 18, ey - 11), (ex + 18, ey + 11)]
    else:
        pts = [(ex, ey), (ex - 11, ey - 18), (ex + 11, ey - 18)] if ey >= sy else [(ex, ey), (ex - 11, ey + 18), (ex + 11, ey + 18)]
    draw.polygon(pts, fill=color)


def chip(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], label: str, fill: str, outline: str, fnt=SMALL) -> None:
    draw.rounded_rectangle(box, radius=14, fill=fill, outline=outline, width=2)
    tw, th = text_size(draw, label, fnt)
    x1, y1, x2, y2 = box
    draw.text((x1 + (x2 - x1 - tw) / 2, y1 + (y2 - y1 - th) / 2 - 1), label, font=fnt, fill=outline)


def score_color(score: int) -> tuple[str, str]:
    if score >= 5:
        return GREEN, GREEN_D
    if score == 4:
        return MINT, MINT_D
    if score == 3:
        return AMBER, AMBER_D
    return RED, RED_D


CANDIDATES = [
    ("VillagePlotCapacity", [3, 4, 2, 3, 3, 4, 3, 3, 3], "too narrow"),
    ("GlobalThemeSelector", [3, 3, 2, 4, 4, 5, 4, 4, 3], "onboarding risk"),
    ("CoastHarborPreview", [3, 4, 2, 3, 2, 4, 3, 3, 4], "water risk"),
    ("WordSemanticsPreview", [5, 2, 5, 5, 5, 5, 5, 5, 4], "recommended"),
    ("BuildWheelPlan", [2, 4, 2, 3, 3, 4, 2, 2, 2], "too early"),
]


def make_candidate_matrix() -> Path:
    img, draw = canvas(
        "M16-M Candidate Comparison Matrix",
        "Five possible next preview slices scored against safety, semantics and value",
    )
    cols = ["Arch", "Game", "Misread", "M16-L", "Mobile", "No assets", "No auto", "No build", "Code value"]
    x0, y0 = 105, 255
    name_w, cell_w, row_h = 360, 155, 135
    table_w = name_w + cell_w * len(cols) + 250
    draw.rounded_rectangle((x0, y0, x0 + table_w, y0 + row_h * (len(CANDIDATES) + 1)), radius=18, fill=PANEL, outline=LINE, width=3)
    draw.text((x0 + 22, y0 + 45), "Candidate", font=H2, fill=INK)
    for j, col in enumerate(cols):
        cx = x0 + name_w + j * cell_w
        draw_wrapped(draw, col, (cx + 18, y0 + 35), SMALL, BLUE_D, cell_w - 35, 3)
    draw.text((x0 + name_w + cell_w * len(cols) + 24, y0 + 45), "Decision", font=H2, fill=INK)
    for i, (name, scores, decision) in enumerate(CANDIDATES):
        y = y0 + row_h * (i + 1)
        fill = "#fbf8f1" if i % 2 == 0 else "#f1eadc"
        draw.rectangle((x0 + 2, y, x0 + table_w - 2, y + row_h), fill=fill)
        draw_wrapped(draw, name, (x0 + 22, y + 42), SMALL, INK, name_w - 44, 4)
        for j, score in enumerate(scores):
            cx = x0 + name_w + j * cell_w
            sf, so = score_color(score)
            draw.rounded_rectangle((cx + 42, y + 38, cx + cell_w - 42, y + 83), radius=14, fill=sf, outline=so, width=2)
            tw, th = text_size(draw, str(score), SMALL)
            draw.text((cx + cell_w / 2 - tw / 2, y + 60 - th / 2), str(score), font=SMALL, fill=so)
        dx = x0 + name_w + cell_w * len(cols) + 24
        color = GREEN_D if decision == "recommended" else RED_D if "early" in decision or "risk" in decision else AMBER_D
        draw_wrapped(draw, decision, (dx, y + 42), SMALL, color, 205, 4)
    card(
        draw,
        (325, 1110, W - 325, 1275),
        "Decision",
        "Recommend WordSemanticsDecisionPreview: it best protects against automatic placement and false build-state inference before more visual world slices.",
        GREEN,
        GREEN_D,
        body_font=SMALL,
    )
    path = OUT / "01_candidate_comparison_matrix.png"
    img.save(path)
    return path


def make_risk_value_map() -> Path:
    img, draw = canvas(
        "M16-M Risk vs Value Map",
        "The safest next slice is not the flashiest one; it protects the next flashy one",
    )
    plot = (260, 285, 1480, 1120)
    draw.rounded_rectangle(plot, radius=22, fill=PANEL, outline=LINE, width=3)
    x1, y1, x2, y2 = plot
    draw.line((x1 + 120, y2 - 110, x2 - 80, y2 - 110), fill=INK, width=4)
    draw.line((x1 + 120, y2 - 110, x1 + 120, y1 + 80), fill=INK, width=4)
    draw.text((x1 + 670, y2 - 70), "Preview value", font=H2, fill=INK)
    draw.text((x1 + 20, y1 + 350), "Risk", font=H2, fill=INK)
    draw.text((x2 - 290, y2 - 95), "higher", font=SMALL, fill=MUTED)
    draw.text((x1 + 135, y1 + 90), "higher", font=SMALL, fill=MUTED)

    points = [
        ("Build\nWheel", 760, 500, RED, RED_D),
        ("Village", 900, 650, AMBER, AMBER_D),
        ("Global\nSelector", 1035, 710, BLUE, BLUE_D),
        ("Coast\nHarbor", 1190, 560, PURPLE, PURPLE_D),
        ("Word\nSemantics", 1295, 900, GREEN, GREEN_D),
    ]
    for label, px, py, fill, outline in points:
        draw.ellipse((px - 58, py - 58, px + 58, py + 58), fill=fill, outline=outline, width=4)
        draw_wrapped(draw, label, (px - 48, py - 24), TINY, outline, 96, 2)
    card(
        draw,
        (1580, 320, 2260, 500),
        "Sweet spot",
        "WordSemanticsDecisionPreview has high next-step value with the lowest implementation-misread risk.",
        GREEN,
        GREEN_D,
        body_font=SMALL,
    )
    card(
        draw,
        (1580, 590, 2260, 810),
        "Tempting but risky",
        "Coast/Harbor is visually strong, but water, dock, boat and mobile clutter gates are not ready for a next slice.",
        RED,
        RED_D,
        body_font=SMALL,
    )
    path = OUT / "02_risk_vs_value_map.png"
    img.save(path)
    return path


def make_recommended_flow() -> Path:
    img, draw = canvas(
        "M16-M Recommended Next Slice Flow",
        "WordSemanticsDecisionPreview turns M16-L into the next safe local preview candidate",
    )
    steps = [
        ("Read M16-L", "mandatory semantic filters", BLUE, BLUE_D),
        ("Example word", "Haus, Garage, schwimmen, Angst, Messer, Polizei", AMBER, AMBER_D),
        ("Decision path", "sense -> type -> safety -> representation", PURPLE, PURPLE_D),
        ("Safe outcome", "PlacementCandidate / Codex / Blueprint / Backlog / ContextCard", GREEN, GREEN_D),
        ("Later gate", "only after explicit prompt; no code now", RED, RED_D),
    ]
    x, y = 125, 390
    box_w, box_h, gap = 390, 190, 55
    for i, (title, body, fill, outline) in enumerate(steps):
        bx = x + i * (box_w + gap)
        card(draw, (bx, y, bx + box_w, y + box_h), title, body, fill, outline, body_font=SMALL)
        if i < len(steps) - 1:
            arrow(draw, (bx + box_w + 10, y + box_h // 2), (bx + box_w + gap - 12, y + box_h // 2))
    card(
        draw,
        (230, 785, 1120, 1065),
        "What it proves",
        "Talvori can show why a word is suggested, deferred or kept neutral before any island, plot, wheel, asset or build state appears.",
        GREEN,
        GREEN_D,
        body_font=BODY,
    )
    card(
        draw,
        (1280, 785, 2170, 1065),
        "What it blocks",
        "No automatic word placement, no route, no runtime config, no persistence, no assets, no Build Wheel code, no frame_started.",
        RED,
        RED_D,
        body_font=BODY,
    )
    path = OUT / "03_recommended_next_slice_flow.png"
    img.save(path)
    return path


def make_allowed_blocked() -> Path:
    img, draw = canvas(
        "M16-M Allowed vs Blocked Next Slice Scope",
        "This decision gate selects a direction; it does not implement the selected direction",
    )
    card(
        draw,
        (130, 280, 1110, 1115),
        "Allowed in M16-M",
        "Decision documentation\nCandidate comparison\nRisk/value visualization\nRecommended next preview candidate\nFuture-scope notes\nDocumentation PNG previews under docs/\nRoadmap/template status updates",
        GREEN,
        GREEN_D,
        body_font=BODY,
    )
    card(
        draw,
        (1290, 280, 2270, 1115),
        "Blocked in M16-M",
        "Flutter/Dart code\nApp integration or route\nNew page or navigation\nBuild-Wheel implementation\nTests or screenshots\nPersistence or runtime config\nAssets under assets/\nAutomatic word placement\nBuild-State or frame_started",
        RED,
        RED_D,
        body_font=BODY,
    )
    chip(draw, (760, 1190, 1640, 1250), "Recommendation: WordSemanticsDecisionPreview, preview only", PANEL, BLUE_D)
    path = OUT / "04_allowed_vs_blocked_next_slice_scope.png"
    img.save(path)
    return path


def make_contact_sheet(paths: list[Path]) -> Path:
    sheet_h = 1800
    sheet = Image.new("RGB", (W, sheet_h), BG)
    draw = ImageDraw.Draw(sheet)
    header(draw, "M16-M Contact Sheet", "Quick overview of next safe preview slice decision visuals")
    positions = [(130, 285), (1240, 285), (130, 995), (1240, 995)]
    thumb_max = (880, 550)
    card_w, card_h = 1000, 650
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
        make_candidate_matrix(),
        make_risk_value_map(),
        make_recommended_flow(),
        make_allowed_blocked(),
    ]
    contact = make_contact_sheet(paths)
    print("\n".join(str(path) for path in [contact, *paths]))


if __name__ == "__main__":
    main()
