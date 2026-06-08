from __future__ import annotations

from pathlib import Path
from typing import Iterable

from PIL import Image, ImageDraw, ImageFont


OUT = Path(__file__).resolve().parent
W, H = 2400, 1600
BG = "#f5f7f2"
INK = "#22302d"
MUTED = "#66756f"
PANEL = "#ffffff"
LINE = "#d5ded5"
GREEN = "#6eb58a"
BLUE = "#70a8c7"
YELLOW = "#dfbf63"
RED = "#d9746f"
PURPLE = "#9989c7"
TEAL = "#63b8ad"
FOOTER = "documentation preview only / no code / no assets / no implementation"


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


TITLE = font(56, True)
SUB = font(27)
H2 = font(32, True)
H3 = font(25, True)
BODY = font(23)
SMALL = font(20)
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
    draw.rounded_rectangle((58, 48, W - 58, H - 58), radius=34, fill="#fbfcf8", outline=LINE, width=3)
    draw.text((100, 88), title, font=TITLE, fill=INK)
    draw_wrapped(draw, (102, 165), subtitle, SUB, W - 204, MUTED, 8)
    draw.line((100, H - 118, W - 100, H - 118), fill=LINE, width=2)
    draw.text((100, H - 86), FOOTER, font=TINY, fill=MUTED)
    return img, draw


def card(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    title: str,
    body: str,
    color: str,
    body_font: ImageFont.ImageFont = BODY,
    title_font: ImageFont.ImageFont = H2,
) -> None:
    x1, y1, x2, y2 = box
    draw.rounded_rectangle(box, radius=24, fill=PANEL, outline=LINE, width=3)
    draw.rounded_rectangle((x1, y1, x2, y1 + 14), radius=9, fill=color)
    draw.text((x1 + 26, y1 + 32), title, font=title_font, fill=INK)
    draw_wrapped(draw, (x1 + 26, y1 + 84), body, body_font, x2 - x1 - 52)


def pill(draw: ImageDraw.ImageDraw, xy: tuple[int, int], label: str, color: str, fill: str = "#ffffff") -> None:
    x, y = xy
    tw, th = text_size(draw, label, SMALL)
    draw.rounded_rectangle((x, y, x + tw + 34, y + th + 20), radius=18, fill=color)
    draw.text((x + 17, y + 10), label, font=SMALL, fill=fill)


def arrow(draw: ImageDraw.ImageDraw, start: tuple[int, int], end: tuple[int, int], color: str = "#879891") -> None:
    draw.line((start, end), fill=color, width=6)
    sx, sy = start
    ex, ey = end
    if abs(ex - sx) >= abs(ey - sy):
        sign = 1 if ex > sx else -1
        draw.polygon([(ex, ey), (ex - sign * 22, ey - 14), (ex - sign * 22, ey + 14)], fill=color)
    else:
        sign = 1 if ey > sy else -1
        draw.polygon([(ex, ey), (ex - 14, ey - sign * 22), (ex + 14, ey - sign * 22)], fill=color)


def reward_budget_limits() -> Path:
    img, draw = base(
        "Reward Budget Limits",
        "MVP rewards stay small, optional and reversible. They motivate without forcing reviews, placement or build state.",
    )
    cards = [
        ((120, 285, 650, 505), "Soft learning feedback", "After a learning action or small block. Calm signal, no streak guilt.", GREEN),
        ((735, 285, 1265, 505), "World suggestions", "At most 0-2 active suggestions per session. Always optional.", BLUE),
        ((1350, 285, 1880, 505), "Review decisions", "Only a few active decisions. Never after every word.", TEAL),
        ((430, 640, 960, 860), "Sensitive words", "No retention trigger, reward, decoration or pressure mechanic.", RED),
        ((1045, 640, 1575, 860), "World feedback", "Only after user choice and later gate. Preview or fallback only.", YELLOW),
        ((1660, 640, 2190, 860), "Ignored review", "No penalty. Later, Codex, Backlog or Hide remain safe.", PURPLE),
    ]
    for box, title, body, color in cards:
        card(draw, box, title, body, color)
    card(
        draw,
        (250, 1070, 2150, 1245),
        "Blocked reward shortcuts",
        "No reward spam. No required decisions. No loss warnings. No automatic word placement. No BuildState. No frame_started.",
        RED,
    )
    pill(draw, (560, 1345), "motivation without pressure", GREEN)
    pill(draw, (960, 1345), "few active suggestions", BLUE)
    pill(draw, (1335, 1345), "no automatic placement", RED)
    out = OUT / "reward_budget_limits.png"
    img.save(out)
    return out


def review_queue_session_budget() -> Path:
    img, draw = base(
        "Review Queue Session Budget",
        "The queue is a small decision window, not a 20,000-word inbox and not a decision after every word.",
    )
    steps = [
        ((110, 430, 475, 630), "Learning / import block", "Words arrive from learning or import.", BLUE),
        ((590, 430, 955, 630), "Eligibility", "Only ambiguous, risky or relevant items enter.", YELLOW),
        ((1070, 430, 1435, 630), "Budget gate", "0-3 active decisions per session.", GREEN),
        ((1550, 430, 1915, 630), "Few review cards", "Confirm, Change, Later, Codex, Backlog, Hide.", TEAL),
        ((2030, 430, 2295, 630), "Safe end", "Fallback or gated preview only.", PURPLE),
    ]
    for box, title, body, color in steps:
        card(draw, box, title, body, color, SMALL, H3)
    for i in range(len(steps) - 1):
        arrow(draw, (steps[i][0][2] + 25, 530), (steps[i + 1][0][0] - 25, 530))
    card(
        draw,
        (160, 850, 1090, 1110),
        "Show review when",
        "High risk, high learning relevance, unclear sense, user asks, import summary, budget available.",
        GREEN,
    )
    card(
        draw,
        (1310, 850, 2240, 1110),
        "Do not show review when",
        "Safe default is enough, budget is full, sensitive context is not ready, user is returning after a pause.",
        RED,
    )
    pill(draw, (625, 1280), "Later always allowed", BLUE)
    pill(draw, (1015, 1280), "no mass review", RED)
    pill(draw, (1355, 1280), "no question after every word", RED)
    out = OUT / "review_queue_session_budget.png"
    img.save(out)
    return out


def queue_priority_matrix() -> Path:
    img, draw = base(
        "Queue Priority Matrix",
        "Risk, learning relevance, confidence, user goal, sensitive flags and clutter decide what becomes visible.",
    )
    headers = ["Factor", "High priority", "Low priority", "Gate"]
    xs = [110, 620, 1130, 1640]
    widths = [450, 450, 450, 620]
    for x, width, header in zip(xs, widths, headers):
        card(draw, (x, 270, x + width, 410), header, "", BLUE, SMALL, H3)
    rows = [
        ("Risk", "wrong output could harm", "safe Codex works", "Safety before visibility"),
        ("Learning", "active or repeated word", "low relevance", "Learning before retention"),
        ("Confidence", "multiple senses", "clear default", "Low confidence never places"),
        ("User goal", "explicit focus", "no current goal", "Signal, not pressure"),
        ("Sensitive", "policy risk", "ordinary term", "Never reward/decor"),
        ("Clutter", "tiny or dense object", "large readable concept", "Mobile first"),
    ]
    y = 465
    for i, row in enumerate(rows):
        for x, width, value in zip(xs, widths, row):
            draw.rounded_rectangle((x, y, x + width, y + 105), radius=18, fill=PANEL, outline=LINE, width=2)
            fill = INK if x == xs[0] else MUTED
            draw_wrapped(draw, (x + 22, y + 26), value, BODY, width - 44, fill)
        color = RED if i in (0, 4) else YELLOW if i in (2, 5) else GREEN
        draw.rounded_rectangle((1640, y, 2260, y + 10), radius=5, fill=color)
        y += 132
    card(
        draw,
        (310, 1280, 2090, 1410),
        "Conflict order",
        "Safety / Sensitive -> Sense / Context -> Clutter / Mobile -> Learning relevance -> User goal -> World readiness -> Session budget",
        PURPLE,
        SMALL,
        H3,
    )
    out = OUT / "queue_priority_matrix.png"
    img.save(out)
    return out


def safe_defaults_flow() -> Path:
    img, draw = base(
        "Safe Defaults Flow",
        "When a word is not ready for visible world feedback, it exits safely without placement, build state or persistence.",
    )
    card(draw, (120, 520, 515, 720), "Semantic outcome", "Word type, sense, safety and clutter are checked first.", BLUE, SMALL, H3)
    group = (660, 270, 1770, 1020)
    draw.rounded_rectangle(group, radius=28, fill="#fbfcf8", outline=LINE, width=3)
    draw.text((group[0] + 32, group[1] + 30), "Safe default options", font=H2, fill=INK)
    draw_wrapped(
        draw,
        (group[0] + 32, group[1] + 80),
        "Each option can explain, defer, hide, contain or backlog. None can place.",
        SMALL,
        group[2] - group[0] - 64,
    )
    default_cards = [
        ((720, 390, 1025, 525), "CodexOnly", "explain / learn", GREEN),
        ((1110, 390, 1415, 525), "ContextCard", "clarify sense", BLUE),
        ((1500, 390, 1710, 525), "Later", "defer", PURPLE),
        ((720, 615, 1025, 750), "Backlog", "wait for gate", YELLOW),
        ((1110, 615, 1415, 750), "ContainerItem", "depth fallback", TEAL),
        ((1500, 615, 1710, 750), "SensitiveGated", "policy first", RED),
        ((975, 835, 1435, 960), "Hide", "remove from active queue", PURPLE),
    ]
    for box, title, body, color in default_cards:
        card(draw, box, title, body, color, SMALL, H3)
    card(
        draw,
        (1955, 520, 2290, 720),
        "Safe ending",
        "No placement, no persistence, no BuildState, no frame_started.",
        RED,
        SMALL,
        H3,
    )
    arrow(draw, (540, 620), (630, 620))
    arrow(draw, (1800, 620), (1925, 620))
    card(
        draw,
        (420, 1230, 1980, 1370),
        "Default rule",
        "A default may explain, defer, hide, contain or backlog. It may never create visible placement.",
        RED,
        SMALL,
        H3,
    )
    out = OUT / "safe_defaults_flow.png"
    img.save(out)
    return out


def anti_pressure_rules() -> Path:
    img, draw = base(
        "Anti-Pressure Rules",
        "Talvori can motivate through calm feedback and optional choices, while pressure mechanics stay blocked.",
    )
    allowed = [
        "soft learning feedback",
        "voluntary suggestion",
        "Later always available",
        "neutral comeback after pause",
        "small reversible signal after gate",
    ]
    blocked = [
        "streak guilt",
        "decay or ruins as punishment",
        "required decision",
        "loss warning",
        "sensitive retention trigger",
        "automatic placement",
    ]
    card(draw, (130, 280, 1120, 1240), "Allowed calm loop", "", GREEN)
    y = 395
    for item in allowed:
        pill(draw, (210, y), item, GREEN)
        y += 120
    card(draw, (1280, 280, 2270, 1240), "Blocked pressure loop", "", RED)
    y = 395
    for item in blocked:
        pill(draw, (1360, y), item, RED)
        y += 105
    card(
        draw,
        (450, 1320, 1950, 1430),
        "Pause rule",
        "Returning users are welcomed neutrally. No loss, no shame, no forced review.",
        BLUE,
        SMALL,
        H3,
    )
    out = OUT / "anti_pressure_rules.png"
    img.save(out)
    return out


def contact_sheet(paths: Iterable[Path]) -> Path:
    paths = list(paths)
    cw, ch = 2600, 2800
    img = Image.new("RGB", (cw, ch), BG)
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle((60, 55, cw - 60, ch - 55), radius=34, fill="#fbfcf8", outline=LINE, width=3)
    draw.text((105, 95), "M16-X Reward Queue Control Contact Sheet", font=TITLE, fill=INK)
    draw_wrapped(
        draw,
        (108, 172),
        "All diagrams are documentation previews. Check text containment, spacing, footer clearance and overlap-free cards.",
        SUB,
        cw - 216,
    )
    thumb_w, thumb_h = 1000, 640
    x_positions = [155, 1445]
    y_positions = [295, 990, 1685]
    for index, path in enumerate(paths):
        row = index // 2
        col = index % 2
        x = x_positions[col]
        y = y_positions[row]
        with Image.open(path) as source:
            source.thumbnail((thumb_w, thumb_h), Image.Resampling.LANCZOS)
            tx = x + (thumb_w - source.width) // 2
            ty = y + 42 + (thumb_h - source.height) // 2
            draw.rounded_rectangle((x - 24, y, x + thumb_w + 24, y + thumb_h + 92), radius=24, fill=PANEL, outline=LINE, width=3)
            draw.text((x, y + 15), path.name, font=SMALL, fill=INK)
            img.paste(source, (tx, ty))
    footer_y = ch - 120
    draw.line((110, footer_y - 28, cw - 110, footer_y - 28), fill=LINE, width=2)
    draw.text((110, footer_y), FOOTER, font=TINY, fill=MUTED)
    out = OUT / "00_contact_sheet.png"
    img.save(out)
    return out


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    paths = [
        reward_budget_limits(),
        review_queue_session_budget(),
        queue_priority_matrix(),
        safe_defaults_flow(),
        anti_pressure_rules(),
    ]
    contact_sheet(paths)


if __name__ == "__main__":
    main()
