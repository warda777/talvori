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
        "documentation preview only / no code now / no app route / no persistence / no assets / no automatic placement / no frame_started",
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
    draw_wrapped(draw, body, (x1 + 22, y1 + 76), body_font, INK, x2 - x1 - 44, 7)


def chip(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], label: str, fill: str, outline: str, fnt=SMALL) -> None:
    draw.rounded_rectangle(box, radius=14, fill=fill, outline=outline, width=2)
    tw, th = text_size(draw, label, fnt)
    x1, y1, x2, y2 = box
    draw.text((x1 + (x2 - x1 - tw) / 2, y1 + (y2 - y1 - th) / 2 - 1), label, font=fnt, fill=outline)


def arrow(draw: ImageDraw.ImageDraw, start: tuple[int, int], end: tuple[int, int], color: str = LINE) -> None:
    draw.line((*start, *end), fill=color, width=5)
    sx, sy = start
    ex, ey = end
    pts = [(ex, ey), (ex - 18, ey - 11), (ex - 18, ey + 11)] if ex >= sx else [(ex, ey), (ex + 18, ey - 11), (ex + 18, ey + 11)]
    draw.polygon(pts, fill=color)


def make_gate_scope() -> Path:
    img, draw = canvas(
        "M16-O Implementation Gate Scope Map",
        "This gate can approve a later isolated preview candidate, but it writes no code",
    )
    steps = [
        ("M16-N Scope", "semantic preview plan exists", BLUE, BLUE_D),
        ("M16-O Gate", "readiness check only", PURPLE, PURPLE_D),
        ("Explicit Approval", "separate user prompt required", AMBER, AMBER_D),
        ("Isolated Widget", "local preview file only later", GREEN, GREEN_D),
        ("Manual Review", "no commit until checked", MINT, MINT_D),
    ]
    x, y = 105, 345
    box_w, box_h, gap = 390, 190, 55
    for i, (title, body, fill, outline) in enumerate(steps):
        bx = x + i * (box_w + gap)
        card(draw, (bx, y, bx + box_w, y + box_h), title, body, fill, outline, body_font=SMALL)
        if i < len(steps) - 1:
            arrow(draw, (bx + box_w + 12, y + box_h // 2), (bx + box_w + gap - 12, y + box_h // 2))
    card(
        draw,
        (185, 760, 1095, 1080),
        "Gate decision",
        "Later code slice is theoretically possible only as a minimal isolated preview. M16-O itself does not create Dart files.",
        GREEN,
        GREEN_D,
    )
    card(
        draw,
        (1305, 760, 2215, 1080),
        "Hard stop",
        "No routing, no app integration, no real word routing, no persistence, no assets, no automatic placement, no Build-State.",
        RED,
        RED_D,
    )
    chip(draw, (600, 1210, 1800, 1270), "Result: possible later, not approved now", PANEL, BLUE_D)
    path = OUT / "01_implementation_gate_scope_map.png"
    img.save(path)
    return path


def make_allowed_blocked() -> Path:
    img, draw = canvas(
        "M16-O Allowed Later vs Blocked Now",
        "The later slice may be tiny and local; M16-O still creates only docs and previews",
    )
    card(
        draw,
        (130, 295, 1110, 1165),
        "Allowed later only after approval",
        "One isolated preview widget\nExample-word cards\nLocal in-memory selection\nContext/Sense display\nWord Type display\nSafety/Sensitive display\nCandidate ThemeIsland(s)\nRepresentation Decision\nPreview Only / Later Gate",
        GREEN,
        GREEN_D,
        body_font=BODY,
    )
    card(
        draw,
        (1290, 295, 2270, 1165),
        "Blocked now and in the later minimal slice",
        "Real routing implementation\nFinal data structure\nApp integration or route\nProduct navigation\nPersistence or DB writes\nSupabase writes\nAutomatic word placement\nBuild-Wheel implementation\nAssets\nBuild-State / frame_started",
        RED,
        RED_D,
        body_font=BODY,
    )
    chip(draw, (645, 1245, 1755, 1305), "M16-O is a gate, not an implementation prompt", PANEL, PURPLE_D)
    path = OUT / "02_allowed_later_vs_blocked_now.png"
    img.save(path)
    return path


def make_file_boundary() -> Path:
    img, draw = canvas(
        "M16-O Preview File Boundary Map",
        "Planned file names are hypothetical; no Flutter or Dart file is created in this block",
    )
    card(
        draw,
        (190, 295, 1045, 595),
        "Possible later widget",
        "lib/features/world/local_world/ui/widgets/word_semantics_decision_preview.dart\n\nPurpose: isolated local example-word preview.",
        BLUE,
        BLUE_D,
        body_font=SMALL,
    )
    card(
        draw,
        (1355, 295, 2210, 595),
        "Optional later launch target",
        "lib/features/world/local_world/ui/widgets/word_semantics_decision_preview_main.dart\n\nOnly after separate approval.",
        AMBER,
        AMBER_D,
        body_font=SMALL,
    )
    card(
        draw,
        (190, 760, 1045, 1085),
        "Must remain outside",
        "Home, onboarding, world routing, app navigation, config, persistence, Supabase, local DB, assets and tests.",
        RED,
        RED_D,
    )
    card(
        draw,
        (1355, 760, 2210, 1085),
        "Allowed behavior later",
        "Pure local state, select example card, show explanation, show safe output, reset/defer without storage.",
        GREEN,
        GREEN_D,
    )
    chip(draw, (540, 1235, 1860, 1295), "No export, no route and no integration from M16-O", PANEL, BLUE_D)
    path = OUT / "03_preview_file_boundary_map.png"
    img.save(path)
    return path


WORDS = [
    ("Haus", "prevents forced house start", "Context + Blueprint/Preview", "Plot/Build gate"),
    ("Garage", "prevents auto-home or vehicle logic", "ContextCard/Blueprint", "Vehicle/Plot gate"),
    ("Baum", "prevents nature clutter", "Backlog or Nature note", "Mobile clutter gate"),
    ("schwimmen", "prevents verb as object", "ActionChallenge/ContextCard", "Water/action gate"),
    ("Angst", "prevents object or pressure", "Companion/Context/Codex", "Sensitive UX gate"),
    ("lernen", "prevents forced school building", "Challenge/LearningMode", "Learning gate"),
    ("Messer", "prevents unsafe visible item", "ContainerItem/ContextCard", "Safety/container gate"),
    ("Polizei", "prevents auto station or bias", "ContextCard/Codex", "Policy gate"),
]


def make_guardrail_map() -> Path:
    img, draw = canvas(
        "M16-O Example Word Guardrail Map",
        "The later preview must teach why each word does not automatically become a world object",
    )
    x0, y0 = 105, 280
    card_w, card_h, gap_x, gap_y = 530, 255, 45, 55
    fills = [(BLUE, BLUE_D), (AMBER, AMBER_D), (MINT, MINT_D), (PURPLE, PURPLE_D), (RED, RED_D), (GREEN, GREEN_D), (GRAY, GRAY_D), (RED, RED_D)]
    for i, (word, prevents, output, gate) in enumerate(WORDS):
        row = i // 4
        col = i % 4
        x = x0 + col * (card_w + gap_x)
        y = y0 + row * (card_h + gap_y)
        fill, outline = fills[i]
        draw.rounded_rectangle((x, y, x + card_w, y + card_h), radius=20, fill=fill, outline=outline, width=4)
        draw_wrapped(draw, word, (x + 24, y + 18), H1, outline, card_w - 48, 5)
        draw_wrapped(draw, prevents, (x + 24, y + 82), SMALL, INK, card_w - 48, 5)
        chip(draw, (x + 24, y + 142, x + card_w - 24, y + 188), output, PANEL, outline, fnt=TINY)
        draw_wrapped(draw, gate, (x + 24, y + 205), TINY, outline, card_w - 48, 4)
    card(
        draw,
        (390, 1185, 2010, 1350),
        "Shared rule",
        "Every example stays explanatory and preview-only: no storage, no placement, no routing implementation, no Build-State.",
        GREEN,
        GREEN_D,
        body_font=SMALL,
    )
    path = OUT / "04_example_word_guardrail_map.png"
    img.save(path)
    return path


def make_contact_sheet(paths: list[Path]) -> Path:
    sheet_h = 1900
    sheet = Image.new("RGB", (W, sheet_h), BG)
    draw = ImageDraw.Draw(sheet)
    header(draw, "M16-O Contact Sheet", "Quick overview of word semantics preview implementation gate visuals")
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
        make_gate_scope(),
        make_allowed_blocked(),
        make_file_boundary(),
        make_guardrail_map(),
    ]
    contact = make_contact_sheet(paths)
    print("\n".join(str(path) for path in [contact, *paths]))


if __name__ == "__main__":
    main()
