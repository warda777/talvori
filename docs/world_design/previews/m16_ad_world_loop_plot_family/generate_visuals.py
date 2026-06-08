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


def world_loop_gate_flow() -> Path:
    img, draw = base(
        "World Loop Gate Flow",
        "World progress is curated and gated. Learning, reward and UI taps can prepare options, but they never build directly.",
    )
    steps = [
        ("Learning Event", "practice / repeat / see word\nno SRS mutation here", BLUE),
        ("Semantic Outcome", "sense, type, safety\nMVP outcome only", GREEN),
        ("Review / Choice", "small budget\nLater always safe", TEAL),
        ("Safe Feedback", "preview signal\ncontext or fallback", PURPLE),
        ("World Candidate", "possible world relation\nnot placement", YELLOW),
        ("Plot Family", "capability match\nnot slot fill", GREEN),
        ("BuildChoice", "later voluntary option\nnot BuildState", BLUE),
        ("Later Gate", "data, asset, undo\napp integration later", RED),
        ("Reversible", "change sense, plot,\noutcome or choice", PURPLE),
    ]
    boxes = []
    x0, y0 = 135, 315
    card_w, card_h = 635, 205
    gap_x, gap_y = 105, 110
    for i, (title, body, color) in enumerate(steps):
        col = i % 3
        row = i // 3
        x = x0 + col * (card_w + gap_x)
        y = y0 + row * (card_h + gap_y)
        box = (x, y, x + card_w, y + card_h)
        boxes.append(box)
        card(draw, box, title, body, color, BODY, H2)
    for i in range(len(boxes) - 1):
        a = boxes[i]
        b = boxes[i + 1]
        if i % 3 != 2:
            arrow(draw, (a[2] + 18, (a[1] + a[3]) // 2), (b[0] - 18, (b[1] + b[3]) // 2))
        else:
            arrow(draw, ((a[0] + a[2]) // 2, a[3] + 22), ((b[0] + b[2]) // 2, b[1] - 22))
    card(
        draw,
        (330, 1365, 2070, 1565),
        "Hard boundary",
        "No learning event, reward or UI tap may create placement, persistence, BuildState, asset generation or frame_started.",
        RED,
        BODY,
        H2,
    )
    out = OUT / "world_loop_gate_flow.png"
    img.save(out)
    return out


def plot_family_matrix() -> Path:
    img, draw = base(
        "Generic Plot Family Matrix",
        "Plot families are reusable planning buckets. They are not fixed buildings, assets or automatic slot assignments.",
    )
    families = [
        ("dwelling / home", "home, rooms, privacy\nNeedsUserChoice", BLUE),
        ("garden / nature", "plants, trees, calm\nclutter gate", GREEN),
        ("learning / school", "learning place\nnot auto school", TEAL),
        ("food / kitchen", "kitchen, cafe, tools\ncontainer risk", YELLOW),
        ("travel / movement", "paths, vehicle context\nno route system", PURPLE),
        ("work / craft", "workshop, tools\nno production loop", BLUE),
        ("water / harbor", "coast, swim, pier\nwater safety gate", TEAL),
        ("public / civic", "institutions\npolicy gated", RED),
        ("health / emergency", "sensitive support\nno advice / reward", RED),
        ("culture / social", "meeting, culture\nsocial gate", GREEN),
        ("technology", "digital, devices\nprivacy gate", PURPLE),
        ("container / storage", "small items\nfindability path", YELLOW),
        ("action / challenge", "verbs, sequences\nnot object", BLUE),
        ("abstract / context", "emotion, abstract\nContextCard", TEAL),
    ]
    x0, y0 = 120, 300
    card_w, card_h = 495, 170
    gap_x, gap_y = 70, 42
    for i, (title, body, color) in enumerate(families):
        col = i % 4
        row = i // 4
        x = x0 + col * (card_w + gap_x)
        y = y0 + row * (card_h + gap_y)
        card(draw, (x, y, x + card_w, y + card_h), title, body, color, SMALL, H3)
    card(
        draw,
        (320, 1320, 2080, 1515),
        "Shared rule",
        "A family can host candidates only after sense, safety, clutter, confidence, user choice and a later implementation gate. It never creates BuildState or assets.",
        RED,
        BODY,
        H2,
    )
    out = OUT / "plot_family_matrix.png"
    img.save(out)
    return out


def capability_not_placement() -> Path:
    img, draw = base(
        "Capability Is Not Placement",
        "A plot capability permits future consideration. It does not fill a slot, place a word or start construction.",
    )
    allowed = [
        ("Word Outcome", "WorldCandidate or fallback\nnot a build command", BLUE),
        ("Plot Family", "candidate family\ncan be changed", GREEN),
        ("Capability Check", "allowed function\npermission only", TEAL),
        ("User Choice", "Later / Change / Confirm\nbudgeted review", PURPLE),
        ("Preview Only", "non-persistent signal\nreversible", YELLOW),
        ("Later Gate", "data, undo, asset,\napp and tests later", RED),
    ]
    boxes = []
    x0, y0 = 140, 370
    card_w, card_h = 330, 220
    for i, (title, body, color) in enumerate(allowed):
        x = x0 + i * 365
        box = (x, y0, x + card_w, y0 + card_h)
        boxes.append(box)
        card(draw, box, title, body, color, SMALL, H3)
    for left, right in zip(boxes, boxes[1:]):
        arrow(draw, (left[2] + 16, y0 + 110), (right[0] - 16, y0 + 110))
    card(
        draw,
        (180, 780, 1080, 1120),
        "Allowed reading",
        "core_plot may allow home, garden or learning. That means maybe later, not now, and not automatically.",
        GREEN,
        BODY,
        H2,
    )
    card(
        draw,
        (1320, 780, 2220, 1120),
        "Blocked shortcut",
        "word -> capability -> slot filled -> asset -> BuildState -> frame_started is forbidden.",
        RED,
        BODY,
        H2,
    )
    arrow(draw, (1115, 950), (1280, 950), RED)
    pill(draw, (555, 1325), "permission", GREEN)
    pill(draw, (910, 1325), "user choice", BLUE)
    pill(draw, (1265, 1325), "preview only", PURPLE)
    pill(draw, (1635, 1325), "no placement", RED)
    out = OUT / "capability_not_placement.png"
    img.save(out)
    return out


def buildchoice_boundary_model() -> Path:
    img, draw = base(
        "BuildChoice Boundary Model",
        "BuildChoice is a future voluntary choice boundary. It is not BuildState, placement, persistence, route, asset or wheel code.",
    )
    card(
        draw,
        (620, 315, 1780, 535),
        "BuildChoice",
        "future voluntary option: Candidate, Preview, Later, Cancel, Change or Confirm later. It stays non-persistent until a later gate.",
        BLUE,
        BODY,
        H2,
    )
    allowed = [
        ("Candidate", "possible option", GREEN),
        ("Preview", "non-persistent", TEAL),
        ("Later", "safe delay", PURPLE),
        ("Cancel", "no penalty", YELLOW),
        ("Change", "sense / plot / outcome", GREEN),
        ("Confirm later", "only after own gate", BLUE),
    ]
    x0, y0 = 160, 720
    for i, (title, body, color) in enumerate(allowed):
        x = x0 + (i % 3) * 740
        y = y0 + (i // 3) * 245
        box = (x, y, x + 620, y + 175)
        card(draw, box, title, body, color)
    card(
        draw,
        (410, 1340, 1990, 1525),
        "Blocked meanings",
        "BuildState, placement, persistence, asset generation, app route, wheel code and frame_started stay blocked.",
        RED,
        BODY,
        H2,
    )
    out = OUT / "buildchoice_boundary_model.png"
    img.save(out)
    return out


def undo_reversibility_flow() -> Path:
    img, draw = base(
        "Undo And Reversibility Flow",
        "Every semantic or world-facing choice must remain explainable and changeable before product persistence exists.",
    )
    items = [
        ("Original choice", "sense, outcome,\nplot family or candidate", BLUE),
        ("New context", "user learns more\nor safety changes", YELLOW),
        ("Change request", "Change / Later\nor Review", PURPLE),
        ("Safe recalculation", "safety first\nthen sense", GREEN),
        ("Non-breaking result", "ContextCard,\nBacklog or new Candidate", TEAL),
    ]
    boxes = []
    x0, y0 = 160, 450
    card_w, card_h = 385, 230
    for i, (title, body, color) in enumerate(items):
        x = x0 + i * 440
        box = (x, y0, x + card_w, y0 + card_h)
        boxes.append(box)
        card(draw, box, title, body, color, SMALL, H3)
    for left, right in zip(boxes, boxes[1:]):
        arrow(draw, (left[2] + 18, y0 + 115), (right[0] - 18, y0 + 115))
    dims = [
        ("Sense", "Bank / Haus / Messer", BLUE),
        ("Outcome", "WorldCandidate -> CodexOnly", GREEN),
        ("Plot family", "home -> transport", TEAL),
        ("ThemeIsland", "village -> coast", PURPLE),
        ("BuildChoice", "Cancel / Later / Change", YELLOW),
        ("Sensitive", "policy wins immediately", RED),
    ]
    x0, y0 = 260, 930
    for i, (title, body, color) in enumerate(dims):
        x = x0 + (i % 3) * 640
        y = y0 + (i // 3) * 230
        card(draw, (x, y, x + 540, y + 170), title, body, color)
    out = OUT / "undo_reversibility_flow.png"
    img.save(out)
    return out


def semantic_reclassification_safety_flow() -> Path:
    img, draw = base(
        "Semantic Reclassification Safety Flow",
        "Changed meaning must not damage user decisions. Sensitive reclassification wins over world desire immediately.",
    )
    top = [
        ("Word has old reading", "example: bank as bench\nor house as home", BLUE),
        ("New signal arrives", "context, user change,\nprovider update later", YELLOW),
        ("Reclassify safely", "safety -> sense -> type\nno write", GREEN),
        ("Choose safe output", "ContextCard, Backlog,\nNeedsUserChoice", TEAL),
    ]
    boxes = []
    x0, y0 = 185, 390
    card_w, card_h = 465, 225
    for i, (title, body, color) in enumerate(top):
        x = x0 + i * 540
        box = (x, y0, x + card_w, y0 + card_h)
        boxes.append(box)
        card(draw, box, title, body, color, SMALL, H3)
    for left, right in zip(boxes, boxes[1:]):
        arrow(draw, (left[2] + 18, y0 + 112), (right[0] - 18, y0 + 112))
    card(
        draw,
        (230, 850, 1130, 1160),
        "Safety wins",
        "If a word becomes sensitive, world desire, reward, user choice and capability cannot override it.",
        RED,
        BODY,
        H2,
    )
    card(
        draw,
        (1270, 850, 2170, 1160),
        "No migration shortcut",
        "Reclassification does not create DB writes, asset changes, build state or hidden placement without a later gate.",
        PURPLE,
        BODY,
        H2,
    )
    card(
        draw,
        (480, 1340, 1920, 1515),
        "Safe defaults",
        "CodexOnly, ContextCard, Backlog, Later, Hide and SensitiveGated are valid outcomes when confidence or safety changes.",
        GREEN,
        BODY,
        H2,
    )
    out = OUT / "semantic_reclassification_safety_flow.png"
    img.save(out)
    return out


def contact_sheet(paths: Iterable[Path]) -> Path:
    items = list(paths)
    sheet_w, sheet_h = 2500, 2100
    img = Image.new("RGB", (sheet_w, sheet_h), BG)
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle((60, 50, sheet_w - 60, sheet_h - 60), radius=34, fill=SURFACE, outline=LINE, width=3)
    draw.text((110, 92), "M16-AD World Loop / Plot Family Visuals", font=TITLE, fill=INK)
    draw_wrapped(
        draw,
        (112, 168),
        "Contact sheet for documentation previews. No app screens, no screenshots, no assets and no implementation.",
        SUB,
        sheet_w - 224,
    )
    thumb_w, thumb_h = 700, 455
    x0, y0 = 150, 300
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
        label = path.name
        draw_wrapped(draw, (x, y + thumb_h + 28), label, SMALL, thumb_w, INK)
    draw.line((110, sheet_h - 130, sheet_w - 110, sheet_h - 130), fill=LINE, width=2)
    draw.text((110, sheet_h - 92), FOOTER, font=TINY, fill=MUTED)
    out = OUT / "00_contact_sheet.png"
    img.save(out)
    return out


def main() -> None:
    paths = [
        world_loop_gate_flow(),
        plot_family_matrix(),
        capability_not_placement(),
        buildchoice_boundary_model(),
        undo_reversibility_flow(),
        semantic_reclassification_safety_flow(),
    ]
    contact_sheet(paths)
    for path in [OUT / "00_contact_sheet.png", *paths]:
        print(path)


if __name__ == "__main__":
    main()
