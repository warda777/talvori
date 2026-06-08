from __future__ import annotations

from pathlib import Path
from typing import Iterable

from PIL import Image, ImageDraw, ImageFont


OUT = Path(__file__).resolve().parent
W, H = 2400, 1900
BG = "#f6f7f2"
SURFACE = "#fbfcf8"
PANEL = "#ffffff"
INK = "#23302d"
MUTED = "#64746f"
LINE = "#d7ded5"
GREEN = "#69ad84"
BLUE = "#6ea6c8"
YELLOW = "#d7b85f"
RED = "#d97670"
PURPLE = "#9987c5"
TEAL = "#61b8ad"
FOOTER = "documentation preview only / no code / no app route / no screenshots / no assets / no persistence"


def font(size: int, bold: bool = False) -> ImageFont.ImageFont:
    paths = [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/Library/Fonts/Arial Bold.ttf" if bold else "/Library/Fonts/Arial.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    ]
    for path in paths:
        try:
            return ImageFont.truetype(path, size=size)
        except OSError:
            pass
    return ImageFont.load_default()


TITLE = font(54, True)
SUB = font(27)
H2 = font(31, True)
H3 = font(24, True)
BODY = font(22)
SMALL = font(19)
TINY = font(17)


def text_size(draw: ImageDraw.ImageDraw, text: str, fnt: ImageFont.ImageFont) -> tuple[int, int]:
    box = draw.textbbox((0, 0), text, font=fnt)
    return box[2] - box[0], box[3] - box[1]


def wrap(draw: ImageDraw.ImageDraw, text: str, fnt: ImageFont.ImageFont, width: int) -> list[str]:
    lines: list[str] = []
    for raw in text.split("\n"):
        words = raw.split()
        if not words:
            lines.append("")
            continue
        line = words[0]
        for word in words[1:]:
            candidate = f"{line} {word}"
            if text_size(draw, candidate, fnt)[0] <= width:
                line = candidate
            else:
                lines.append(line)
                line = word
        lines.append(line)
    return lines


def draw_wrapped(
    draw: ImageDraw.ImageDraw,
    xy: tuple[int, int],
    text: str,
    fnt: ImageFont.ImageFont,
    width: int,
    fill: str = MUTED,
    spacing: int = 7,
) -> int:
    x, y = xy
    for line in wrap(draw, text, fnt, width):
        draw.text((x, y), line, font=fnt, fill=fill)
        y += text_size(draw, line or " ", fnt)[1] + spacing
    return y


def base(title: str, subtitle: str) -> tuple[Image.Image, ImageDraw.ImageDraw]:
    img = Image.new("RGB", (W, H), BG)
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle((58, 48, W - 58, H - 58), radius=34, fill=SURFACE, outline=LINE, width=3)
    draw.text((100, 88), title, font=TITLE, fill=INK)
    draw_wrapped(draw, (102, 164), subtitle, SUB, W - 204, MUTED, 8)
    draw.line((100, H - 126, W - 100, H - 126), fill=LINE, width=2)
    draw.text((100, H - 90), FOOTER, font=TINY, fill=MUTED)
    return img, draw


def card(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    title: str,
    body: str,
    color: str,
    body_font: ImageFont.ImageFont = SMALL,
    title_font: ImageFont.ImageFont = H3,
) -> None:
    x1, y1, x2, _ = box
    draw.rounded_rectangle(box, radius=22, fill=PANEL, outline=LINE, width=3)
    draw.rounded_rectangle((x1, y1, x2, y1 + 13), radius=8, fill=color)
    draw.text((x1 + 24, y1 + 28), title, font=title_font, fill=INK)
    draw_wrapped(draw, (x1 + 24, y1 + 74), body, body_font, x2 - x1 - 48)


def pill(draw: ImageDraw.ImageDraw, xy: tuple[int, int], label: str, color: str) -> None:
    x, y = xy
    tw, th = text_size(draw, label, SMALL)
    draw.rounded_rectangle((x, y, x + tw + 34, y + th + 18), radius=18, fill=color)
    draw.text((x + 17, y + 9), label, font=SMALL, fill="#ffffff")


def arrow(draw: ImageDraw.ImageDraw, start: tuple[int, int], end: tuple[int, int], color: str = "#899891") -> None:
    draw.line((start, end), fill=color, width=6)
    sx, sy = start
    ex, ey = end
    if abs(ex - sx) >= abs(ey - sy):
        sign = 1 if ex > sx else -1
        draw.polygon([(ex, ey), (ex - sign * 24, ey - 15), (ex - sign * 24, ey + 15)], fill=color)
    else:
        sign = 1 if ey > sy else -1
        draw.polygon([(ex, ey), (ex - 15, ey - sign * 24), (ex + 15, ey - sign * 24)], fill=color)


def capability_stop_rule() -> Path:
    img, draw = base(
        "Capability Stop Rule",
        "Capability is permission only. It must be repeated as a stop rule in every later Plot, World or BuildChoice slice.",
    )
    allowed = [
        ("Outcome", "Candidate or safe fallback", BLUE),
        ("Plot family", "possible planning family", GREEN),
        ("Capability", "permission only", TEAL),
        ("User choice", "Later / Change / Confirm", PURPLE),
        ("Preview only", "non-persistent", YELLOW),
        ("Later gate", "data, asset, app, tests", RED),
    ]
    x0, y0 = 120, 350
    card_w, card_h = 335, 210
    boxes = []
    for i, (title, body, color) in enumerate(allowed):
        x = x0 + i * 370
        box = (x, y0, x + card_w, y0 + card_h)
        boxes.append(box)
        card(draw, box, title, body, color, SMALL, H3)
    for left, right in zip(boxes, boxes[1:]):
        arrow(draw, (left[2] + 16, y0 + 105), (right[0] - 16, y0 + 105))
    blocked = [
        ("No placement", "never fills slot", RED),
        ("No BuildState", "no foundation or frame", RED),
        ("No asset", "no generated art", RED),
        ("No persistence", "no DB write", RED),
        ("No frame_started", "hard blocked", RED),
    ]
    x0, y0 = 205, 820
    for i, (title, body, color) in enumerate(blocked):
        x = x0 + i * 400
        card(draw, (x, y0, x + 330, y0 + 165), title, body, color)
    card(
        draw,
        (360, 1245, 2040, 1445),
        "Safe uncertainty rule",
        "If capability, sense, clutter, safety or confidence is unclear, Talvori chooses Backlog, CodexOnly, ContextCard or Later.",
        GREEN,
        BODY,
        H2,
    )
    out = OUT / "capability_stop_rule.png"
    img.save(out)
    return out


def theme_island_resizing_flow() -> Path:
    img, draw = base(
        "ThemeIsland Resizing Flow",
        "Resizing is adaptability, not migration. It plans growth, reserve and reordering without writing world state.",
    )
    steps = [
        ("New pressure", "new theme / many words\npolicy change", BLUE),
        ("Assess impact", "capacity, clutter,\nsafety, sense", GREEN),
        ("Plan adjustment", "grow, reserve,\nreorder, split, move", TEAL),
        ("Protect choices", "explain old decisions\nkeep change path", PURPLE),
        ("Later gate", "migration, data,\nassets only later", RED),
    ]
    boxes = []
    x0, y0 = 140, 430
    card_w, card_h = 390, 230
    for i, (title, body, color) in enumerate(steps):
        x = x0 + i * 440
        box = (x, y0, x + card_w, y0 + card_h)
        boxes.append(box)
        card(draw, box, title, body, color, SMALL, H3)
    for left, right in zip(boxes, boxes[1:]):
        arrow(draw, (left[2] + 18, y0 + 115), (right[0] - 18, y0 + 115))
    cases = [
        ("Grow", "category gets bigger", GREEN),
        ("Reserve", "future plot family", BLUE),
        ("Reorder", "better readability", TEAL),
        ("Split", "sensitive or too dense", PURPLE),
        ("Move to Depth", "tiny objects deeper", YELLOW),
        ("Change mapping", "user chooses again", GREEN),
    ]
    x0, y0 = 260, 920
    for i, (title, body, color) in enumerate(cases):
        x = x0 + (i % 3) * 640
        y = y0 + (i // 3) * 220
        card(draw, (x, y, x + 540, y + 160), title, body, color)
    card(
        draw,
        (520, 1450, 1880, 1585),
        "Blocked",
        "No automatic re-fill, no migration, no persistence, no asset, no BuildState and no frame_started.",
        RED,
        BODY,
        H2,
    )
    out = OUT / "theme_island_resizing_flow.png"
    img.save(out)
    return out


def tinyobject_container_rule() -> Path:
    img, draw = base(
        "TinyObject / Container Rule",
        "Small objects stay findable without becoming their own plot, island pixel cloud or asset queue.",
    )
    examples = [
        ("Schluessel", "ContainerItem\nCodex / Backlog", BLUE),
        ("Messer", "Container + Safety\nor SensitiveGated", RED),
        ("Loeffel", "kitchen drawer\n3-5 focus objects", YELLOW),
        ("Bleistift", "school -> case\ndetail path", GREEN),
        ("Samen", "beet / Backlog\nno growth loop", TEAL),
        ("Werkzeug", "toolbox / workbench\nno tool cloud", PURPLE),
        ("Tasse", "kitchen / Codex\nContextCard optional", BLUE),
        ("Small items", "Container, Codex,\nLater or Backlog", GREEN),
    ]
    x0, y0 = 115, 315
    card_w, card_h = 505, 180
    for i, (title, body, color) in enumerate(examples):
        x = x0 + (i % 4) * 560
        y = y0 + (i // 4) * 250
        card(draw, (x, y, x + card_w, y + card_h), title, body, color)
    card(
        draw,
        (250, 925, 1030, 1220),
        "Allowed",
        "ContainerItem, CodexOnly, Backlog, ContextCard, Later and later findability path.",
        GREEN,
        BODY,
        H2,
    )
    card(
        draw,
        (1370, 925, 2150, 1220),
        "Blocked",
        "Own plot, permanent IslandView minipixel, container dump, asset mass, BuildState or persistence.",
        RED,
        BODY,
        H2,
    )
    arrow(draw, (1065, 1070), (1330, 1070), RED)
    pill(draw, (560, 1430), "landmarks before details", BLUE)
    pill(draw, (960, 1430), "containers are focus rooms", GREEN)
    pill(draw, (1430, 1430), "no object cloud", RED)
    out = OUT / "tinyobject_container_rule.png"
    img.save(out)
    return out


def sensitive_safe_asset_ladder() -> Path:
    img, draw = base(
        "Sensitive-Safe Asset Ladder",
        "Sensitive content may be learned, but it does not automatically become a symbol, decoration, reward or asset.",
    )
    ladder = [
        ("Hide", "do not show actively", BLUE),
        ("Later", "always allowed", GREEN),
        ("CodexOnly", "neutral learning path", TEAL),
        ("ContextCard", "short safe context", PURPLE),
        ("SensitiveGated", "policy and opt-in", YELLOW),
        ("Asset Gate Later", "only if neutral\nand reviewed", RED),
    ]
    x0, y0 = 155, 395
    card_w, card_h = 330, 210
    boxes = []
    for i, (title, body, color) in enumerate(ladder):
        x = x0 + i * 370
        box = (x, y0, x + card_w, y0 + card_h)
        boxes.append(box)
        card(draw, box, title, body, color)
    for left, right in zip(boxes, boxes[1:]):
        arrow(draw, (left[2] + 16, y0 + 105), (right[0] - 16, y0 + 105))
    examples = [
        ("Polizei", "no station as reward", RED),
        ("Angst", "no drama symbol", PURPLE),
        ("Krankheit", "no medical advice", RED),
        ("Gericht", "policy first", YELLOW),
        ("Religion", "no generic symbol", TEAL),
        ("Krieg", "no quest / deco", RED),
        ("Notfall", "neutral context", BLUE),
    ]
    x0, y0 = 145, 850
    for i, (title, body, color) in enumerate(examples):
        x = x0 + (i % 4) * 545
        y = y0 + (i // 4) * 225
        card(draw, (x, y, x + 480, y + 155), title, body, color)
    card(
        draw,
        (380, 1420, 2020, 1585),
        "M16-AE boundary",
        "No asset files, no automatic asset derivation, no sensitive decoration and no symbol duty. A later asset gate is mandatory.",
        RED,
        BODY,
        H2,
    )
    out = OUT / "sensitive_safe_asset_ladder.png"
    img.save(out)
    return out


def remaining_world_rules_summary() -> Path:
    img, draw = base(
        "Remaining World Rules Summary",
        "The remaining world-near rules are now bound as stop rules before future implementation prompts.",
    )
    rules = [
        ("Word Outcome", "Candidate\nnot Placement", BLUE),
        ("Plot Family", "permission frame\nnot duty", GREEN),
        ("Capability", "possibility\nnot Build", TEAL),
        ("BuildChoice", "choice option\nnot BuildState", PURPLE),
        ("Resizing", "adaptability\nnot migration", YELLOW),
        ("TinyObject", "Container / Depth\nnot plot", BLUE),
        ("Sensitive", "Gate / fallback\nnot symbol", RED),
        ("Asset", "own gate\nnot semantics result", RED),
    ]
    x0, y0 = 135, 330
    card_w, card_h = 500, 190
    for i, (title, body, color) in enumerate(rules):
        x = x0 + (i % 4) * 560
        y = y0 + (i // 4) * 275
        card(draw, (x, y, x + card_w, y + card_h), title, body, color, BODY, H2)
    card(
        draw,
        (310, 1010, 1040, 1300),
        "Closed by M16-AE",
        "M16T-WORLD-004, M16T-UNDO-003, M16T-DEPTH-003 and M16T-ASSET-003 are documented as planning rules.",
        GREEN,
        BODY,
        H2,
    )
    card(
        draw,
        (1360, 1010, 2090, 1300),
        "Still blocked",
        "World code, app integration, route, persistence, assets, auto-placement, BuildState, frame_started and tests.",
        RED,
        BODY,
        H2,
    )
    pill(draw, (580, 1460), "no code", RED)
    pill(draw, (910, 1460), "no assets", RED)
    pill(draw, (1250, 1460), "no persistence", RED)
    pill(draw, (1650, 1460), "no frame_started", RED)
    out = OUT / "remaining_world_rules_summary.png"
    img.save(out)
    return out


def contact_sheet(paths: Iterable[Path]) -> Path:
    items = list(paths)
    sheet_w, sheet_h = 2500, 1950
    img = Image.new("RGB", (sheet_w, sheet_h), BG)
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle((60, 50, sheet_w - 60, sheet_h - 60), radius=34, fill=SURFACE, outline=LINE, width=3)
    draw.text((110, 92), "M16-AE Resizing / Remaining Rules Visuals", font=TITLE, fill=INK)
    draw_wrapped(
        draw,
        (112, 168),
        "Contact sheet for documentation previews. No app screens, no screenshots, no assets and no implementation.",
        SUB,
        sheet_w - 224,
    )
    thumb_w, thumb_h = 700, 455
    x0, y0 = 150, 310
    gap_x, gap_y = 90, 170
    for i, path in enumerate(items):
        row = i // 3
        col = i % 3
        x = x0 + col * (thumb_w + gap_x)
        y = y0 + row * (thumb_h + gap_y)
        with Image.open(path) as source:
            thumb = source.copy()
            thumb.thumbnail((thumb_w, thumb_h), Image.LANCZOS)
        frame = (x - 10, y - 10, x + thumb_w + 10, y + thumb_h + 10)
        draw.rounded_rectangle(frame, radius=22, fill=PANEL, outline=LINE, width=3)
        tx = x + (thumb_w - thumb.width) // 2
        ty = y + (thumb_h - thumb.height) // 2
        img.paste(thumb, (tx, ty))
        draw_wrapped(draw, (x, y + thumb_h + 28), path.name, SMALL, thumb_w, INK)
    draw.line((110, sheet_h - 130, sheet_w - 110, sheet_h - 130), fill=LINE, width=2)
    draw.text((110, sheet_h - 92), FOOTER, font=TINY, fill=MUTED)
    out = OUT / "00_contact_sheet.png"
    img.save(out)
    return out


def main() -> None:
    paths = [
        capability_stop_rule(),
        theme_island_resizing_flow(),
        tinyobject_container_rule(),
        sensitive_safe_asset_ladder(),
        remaining_world_rules_summary(),
    ]
    contact_sheet(paths)
    for path in [OUT / "00_contact_sheet.png", *paths]:
        print(path)


if __name__ == "__main__":
    main()
