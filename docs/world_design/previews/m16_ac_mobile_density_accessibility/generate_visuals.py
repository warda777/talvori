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
MUTED = "#65746f"
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
H2 = font(32, True)
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
    x1, y1, x2, y2 = box
    draw.rounded_rectangle(box, radius=22, fill=PANEL, outline=LINE, width=3)
    draw.rounded_rectangle((x1, y1, x2, y1 + 13), radius=8, fill=color)
    draw.text((x1 + 24, y1 + 28), title, font=title_font, fill=INK)
    draw_wrapped(draw, (x1 + 24, y1 + 74), body, body_font, x2 - x1 - 48)


def pill(draw: ImageDraw.ImageDraw, xy: tuple[int, int], label: str, color: str) -> None:
    x, y = xy
    tw, th = text_size(draw, label, SMALL)
    draw.rounded_rectangle((x, y, x + tw + 34, y + th + 18), radius=17, fill=color)
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


def mobile_density_budget() -> Path:
    img, draw = base(
        "Mobile Density Budget",
        "Planning values for future MVP screens: few active decisions, few labels, clear exits and no object clouds.",
    )
    items = [
        ("Review cards", "0-3 active decisions per session\n1 dominant card per screen\nLater always visible", BLUE),
        ("Companion hints", "0-1 active hint\nshort, optional, closeable\nnot after every word", GREEN),
        ("World proposals", "0-2 active proposals\npreview only\nno placement", PURPLE),
        ("World labels", "0-3 focused labels\nmore only on focus or A11y\nno debug label cloud", TEAL),
        ("TinyObject hints", "0-2 overview hints\n3-5 focused container objects\nno minipixel mass", YELLOW),
        ("Touch and text", "44 x 44 pt planning target\n12-16 px card gaps\nreadable text hierarchy", RED),
    ]
    x0, y0 = 125, 320
    card_w, card_h = 680, 260
    gap_x, gap_y = 70, 60
    for i, (title, body, color) in enumerate(items):
        col = i % 3
        row = i // 3
        x = x0 + col * (card_w + gap_x)
        y = y0 + row * (card_h + gap_y)
        card(draw, (x, y, x + card_w, y + card_h), title, body, color, BODY, H2)
    card(
        draw,
        (320, 1120, 2080, 1345),
        "If a screen needs more",
        "Use depth, container, pagination, filter, Codex, Backlog or Review Queue. More content on the same layer is not the safe answer.",
        RED,
    )
    pill(draw, (540, 1510), "small phone first", BLUE)
    pill(draw, (930, 1510), "Later / Close reachable", GREEN)
    pill(draw, (1390, 1510), "no auto placement", RED)
    out = OUT / "mobile_density_budget.png"
    img.save(out)
    return out


def landmark_to_detail_hierarchy() -> Path:
    img, draw = base(
        "Landmark To Detail Hierarchy",
        "Mobile world readability starts with large orientation points. Tiny objects move deeper into containers, Codex or Backlog.",
    )
    steps = [
        ("1. Landmark", "large orientation\nisland / region", BLUE),
        ("2. Plot family", "theme area\npath / garden / home", GREEN),
        ("3. Plot / area", "focused learning place\nnot build state", TEAL),
        ("4. Container", "few small objects\nfocus room", PURPLE),
        ("5. Detail / Codex", "meaning, context\nfindability", YELLOW),
    ]
    boxes = []
    x0, y0 = 120, 465
    for i, (title, body, color) in enumerate(steps):
        x = x0 + i * 455
        box = (x, y0, x + 360, y0 + 250)
        boxes.append(box)
        card(draw, box, title, body, color)
    for left, right in zip(boxes, boxes[1:]):
        arrow(draw, (left[2] + 18, y0 + 125), (right[0] - 18, y0 + 125))
    card(
        draw,
        (290, 920, 2110, 1165),
        "TinyObject rule",
        "Keys, spoons, pencils, tools and sensitive small objects do not become permanent IslandView objects. They need depth, grouping, Codex, Backlog or ContextCard.",
        RED,
    )
    card(
        draw,
        (520, 1325, 1880, 1505),
        "World overview rule",
        "The overview must stay a readable world, not an object cloud or label cloud.",
        GREEN,
    )
    out = OUT / "landmark_to_detail_hierarchy.png"
    img.save(out)
    return out


def overlay_rules_mobile() -> Path:
    img, draw = base(
        "Overlay Rules On Mobile",
        "Review cards, Companion bubbles and ContextCards must help, not cover the learning or world interaction.",
    )
    items = [
        ("Review card", "one clear question\nfew exits\nLater visible", BLUE),
        ("Companion bubble", "short optional hint\ncloseable\nnot constant", GREEN),
        ("ContextCard", "sense help\nshort explanation\nCodex / Backlog", TEAL),
        ("SensitiveGated", "neutral tone\nLater / Hide / Codex\nno drama", RED),
        ("Footer / labels", "readable\nnot over content\nnot permanent cloud", YELLOW),
        ("Exit actions", "Close / Later / Deselect\nfinger-friendly\nnever hidden", PURPLE),
    ]
    x0, y0 = 130, 315
    card_w, card_h = 670, 260
    for i, (title, body, color) in enumerate(items):
        x = x0 + (i % 3) * 740
        y = y0 + (i // 3) * 330
        card(draw, (x, y, x + card_w, y + card_h), title, body, color, BODY, H2)
    card(
        draw,
        (330, 1110, 2070, 1350),
        "Blocked overlay behavior",
        "No permanent covering overlays, no text walls, no hidden exit, no pressure language, no Companion and Review fighting for attention on a small screen.",
        RED,
    )
    out = OUT / "overlay_rules_mobile.png"
    img.save(out)
    return out


def accessibility_gate_checklist() -> Path:
    img, draw = base(
        "Accessibility Gate Checklist",
        "Future product UI needs a dedicated device and A11y gate. M16-AC defines the required checks, not implementation.",
    )
    items = [
        ("Text size", "scales without breaking cards\nno tiny gray essentials", BLUE),
        ("Contrast", "text, chips, disabled states\nreadable on mobile", GREEN),
        ("Tap targets", "44 x 44 pt planning target\nClose / Later reachable", TEAL),
        ("Semantics", "screenreader labels for cards\ncontainer path and exits", PURPLE),
        ("Reduced motion", "pulses, glow, wheel, feedback\nmust be reducible", YELLOW),
        ("Not color-only", "status uses text/icon/shape too\nnot hue alone", BLUE),
        ("Error tolerance", "wrong tap has no penalty\nLater is safe", GREEN),
        ("One-hand use", "important actions near reach\nno top-only exit", RED),
    ]
    x0, y0 = 120, 315
    card_w, card_h = 510, 240
    gap_x, gap_y = 55, 55
    for i, (title, body, color) in enumerate(items):
        x = x0 + (i % 4) * (card_w + gap_x)
        y = y0 + (i // 4) * (card_h + gap_y)
        card(draw, (x, y, x + card_w, y + card_h), title, body, color)
    card(
        draw,
        (360, 1120, 2040, 1370),
        "Gate boundary",
        "This checklist does not create tests, widgets, routes, screenshots or runtime configuration. Product UI needs a later implementation and verification gate.",
        RED,
    )
    out = OUT / "accessibility_gate_checklist.png"
    img.save(out)
    return out


def depth_container_levels() -> Path:
    img, draw = base(
        "Depth / Container Levels",
        "Depth is a fachliches model for readability and findability. It is not a build state, data structure or route.",
    )
    levels = [
        ("Level 0", "World / Island overview\nlandmarks, few proposals", BLUE),
        ("Level 1", "ThemeIsland / region\nplot family", GREEN),
        ("Level 2", "Plot / building / area\nfocused place, no BuildState", TEAL),
        ("Level 3", "Room / zone / container\n3-5 focus objects", PURPLE),
        ("Level 4", "Detail / Codex / ContextCard\nmeaning and path", YELLOW),
    ]
    x0, y0 = 180, 325
    card_w, card_h = 410, 250
    boxes = []
    for i, (title, body, color) in enumerate(levels):
        x = x0 + i * 440
        box = (x, y0, x + card_w, y0 + card_h)
        boxes.append(box)
        card(draw, box, title, body, color)
    for left, right in zip(boxes, boxes[1:]):
        arrow(draw, (left[2] + 12, y0 + 125), (right[0] - 12, y0 + 125))
    card(
        draw,
        (250, 810, 1050, 1075),
        "Allowed",
        "orientation\nfocus\ngrouping\nCodex / Backlog\nlater findability",
        GREEN,
        BODY,
        H2,
    )
    card(
        draw,
        (1350, 810, 2150, 1075),
        "Blocked",
        "BuildState\nframe_started\npersistence\nroute\nasset generation",
        RED,
        BODY,
        H2,
    )
    arrow(draw, (1080, 940), (1320, 940), RED)
    card(
        draw,
        (360, 1275, 2040, 1485),
        "Container is focus, not inventory",
        "A drawer, pencil case, navigation kit or bed is used to reduce clutter and support learning. It is not a dump of every known object.",
        BLUE,
    )
    out = OUT / "depth_container_levels.png"
    img.save(out)
    return out


def nested_object_findability_flow() -> Path:
    img, draw = base(
        "Nested Object Findability Flow",
        "Small or hidden learning objects may move deeper, but they must remain findable through safe references.",
    )
    steps = [
        ("Word appears", "key / spoon / pencil / tool", BLUE),
        ("Outcome check", "ContainerItem\nContextCard\nSensitiveGated", TEAL),
        ("Safe reference", "Codex\nBacklog\nContainer path", GREEN),
        ("User context", "Review Queue\nTali/Vori explanation\nLater", PURPLE),
        ("Later gate", "data model\nsearch\npersistence\nA11y", RED),
    ]
    boxes = []
    x0, y0 = 145, 430
    for i, (title, body, color) in enumerate(steps):
        x = x0 + i * 430
        box = (x, y0, x + 360, y0 + 250)
        boxes.append(box)
        card(draw, box, title, body, color)
    for left, right in zip(boxes, boxes[1:]):
        arrow(draw, (left[2] + 16, y0 + 125), (right[0] - 16, y0 + 125))
    card(
        draw,
        (250, 880, 1050, 1145),
        "Findable examples",
        "School -> desk -> pencil case -> pencil\nKitchen -> drawer -> spoon\nHarbor -> navigation kit -> compass",
        GREEN,
    )
    card(
        draw,
        (1350, 880, 2150, 1145),
        "Blocked shortcuts",
        "Invisible required object\nIsland minipixel\nhidden placement\nDB write\nforced review",
        RED,
    )
    card(
        draw,
        (510, 1330, 1890, 1515),
        "M16-AC rule",
        "Objects can be hidden from the overview, but not lost from learning. Codex, Backlog, path or Review must preserve findability.",
        BLUE,
    )
    out = OUT / "nested_object_findability_flow.png"
    img.save(out)
    return out


def contact_sheet(paths: Iterable[Path]) -> Path:
    paths = list(paths)
    cw, ch = 2500, 2400
    img = Image.new("RGB", (cw, ch), BG)
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle((58, 48, cw - 58, ch - 58), radius=34, fill=SURFACE, outline=LINE, width=3)
    draw.text((100, 88), "M16-AC Contact Sheet", font=TITLE, fill=INK)
    draw_wrapped(
        draw,
        (102, 164),
        "Mobile density, landmark hierarchy, overlay rules, accessibility gate, depth levels and findability.",
        SUB,
        cw - 204,
    )
    thumb_w, thumb_h = 660, 430
    x_positions = [130, 910, 1690]
    y_positions = [315, 900]
    for idx, path in enumerate(paths):
        row = idx // 3
        col = idx % 3
        x = x_positions[col]
        y = y_positions[row]
        frame = (x - 18, y - 18, x + thumb_w + 18, y + thumb_h + 78)
        draw.rounded_rectangle(frame, radius=20, fill=PANEL, outline=LINE, width=3)
        thumb = Image.open(path).convert("RGB")
        thumb.thumbnail((thumb_w, thumb_h))
        tx = x + (thumb_w - thumb.width) // 2
        ty = y + (thumb_h - thumb.height) // 2
        img.paste(thumb, (tx, ty))
        draw_wrapped(draw, (x, y + thumb_h + 22), path.name, SMALL, thumb_w, INK, 6)
    card(
        draw,
        (330, 1585, 2170, 1795),
        "Visual-QA checklist",
        "Text containment, inner padding, card spacing, no overlap, footer separation and no cropped content checked manually after generation.",
        GREEN,
    )
    draw.line((100, ch - 126, cw - 100, ch - 126), fill=LINE, width=2)
    draw.text((100, ch - 90), FOOTER, font=TINY, fill=MUTED)
    out = OUT / "00_contact_sheet.png"
    img.save(out)
    return out


def main() -> None:
    paths = [
        mobile_density_budget(),
        landmark_to_detail_hierarchy(),
        overlay_rules_mobile(),
        accessibility_gate_checklist(),
        depth_container_levels(),
        nested_object_findability_flow(),
    ]
    contact_sheet(paths)
    for path in [OUT / "00_contact_sheet.png", *paths]:
        print(path)


if __name__ == "__main__":
    main()
