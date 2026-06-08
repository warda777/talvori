from __future__ import annotations

from pathlib import Path
from typing import Iterable

from PIL import Image, ImageDraw, ImageFont


OUT = Path(__file__).resolve().parent
W, H = 2400, 1700
BG = "#f6f7f2"
SURFACE = "#fbfcf8"
PANEL = "#ffffff"
INK = "#22302d"
MUTED = "#66756f"
LINE = "#d7ded5"
GREEN = "#6eb58a"
BLUE = "#70a8c7"
YELLOW = "#d8b95c"
RED = "#d9746f"
PURPLE = "#9989c7"
TEAL = "#63b8ad"
FOOTER = "documentation preview only / no code / no screenshots / no assets / no SRS or word_progress changes"


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
    draw.line((100, H - 122, W - 100, H - 122), fill=LINE, width=2)
    draw.text((100, H - 88), FOOTER, font=TINY, fill=MUTED)
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
    draw.text((x1 + 26, y1 + 30), title, font=title_font, fill=INK)
    draw_wrapped(draw, (x1 + 26, y1 + 84), body, body_font, x2 - x1 - 52)


def pill(draw: ImageDraw.ImageDraw, xy: tuple[int, int], label: str, color: str) -> None:
    x, y = xy
    tw, th = text_size(draw, label, SMALL)
    draw.rounded_rectangle((x, y, x + tw + 34, y + th + 18), radius=17, fill=color)
    draw.text((x + 17, y + 9), label, font=SMALL, fill="#ffffff")


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


def learning_state_boundaries() -> Path:
    img, draw = base(
        "Learning State Boundaries",
        "MVP learning states describe learning meaning only. They are not SRS values, word_progress writes or world placement.",
    )
    states = [
        ("imported", "arrived, not learned", BLUE),
        ("seen", "looked at once", BLUE),
        ("practiced", "used in learning", GREEN),
        ("unsure", "needs calm support", YELLOW),
        ("contextRich", "context can help sense", TEAL),
        ("understood", "understood in context", GREEN),
        ("reviewCandidate", "may enter queue", PURPLE),
        ("worldFeedbackEligible", "proposal only", PURPLE),
        ("blockedBySafety", "safe fallback wins", RED),
        ("parked", "later or backlog", YELLOW),
    ]
    for i, (title, body, color) in enumerate(states):
        x = 120 + (i % 5) * 455
        y = 300 + (i // 5) * 285
        card(draw, (x, y, x + 365, y + 205), title, body, color, SMALL, H3)
    card(
        draw,
        (300, 1020, 2100, 1260),
        "Boundary rule",
        "A learning state may allow explanation, safe fallback, queue eligibility or a voluntary proposal. It cannot mutate SRS, write word_progress, place a word, create BuildState or persist data.",
        RED,
        SMALL,
        H3,
    )
    out = OUT / "learning_state_boundaries.png"
    img.save(out)
    return out


def srs_word_progress_firewall() -> Path:
    img, draw = base(
        "SRS / word_progress Firewall",
        "Learning-state planning sits outside existing SRS and word_progress semantics until a dedicated migration and test gate exists.",
    )
    card(draw, (140, 340, 760, 790), "MVP learning states", "imported\nseen\npracticed\nunsure\nunderstood\nparked", GREEN)
    card(draw, (1660, 340, 2260, 790), "Protected systems", "SRS values\nword_progress\nexisting learning data\nmigration scope", RED)
    arrow(draw, (790, 565), (1615, 565), RED)
    card(
        draw,
        (900, 455, 1500, 700),
        "Firewall",
        "No writes. No migration. No UI event mutation. No reward mutation. No review confirm mutation.",
        RED,
        SMALL,
        H3,
    )
    card(
        draw,
        (350, 1030, 2050, 1260),
        "Later only with own gate",
        "Any SRS or word_progress change needs a dedicated SRS, migration, rollback and test gate. M16-AA does not provide that gate.",
        BLUE,
        SMALL,
        H3,
    )
    out = OUT / "srs_word_progress_firewall.png"
    img.save(out)
    return out


def learning_vs_semantics_matrix() -> Path:
    img, draw = base(
        "Learning vs Semantics Matrix",
        "Learning status and semantic status are separate axes. A learned word can remain CodexOnly; a high-confidence word can still be unlearned.",
    )
    headers = ["Learning signal", "Semantic signal", "Safe reading", "Blocked shortcut"]
    xs = [115, 675, 1240, 1810]
    widths = [480, 480, 500, 440]
    for x, width, header in zip(xs, widths, headers):
        card(draw, (x, 285, x + width, 420), header, "", BLUE, SMALL, H3)
    rows = [
        ("understood", "CodexOnly", "learned, not built", "Codex -> object"),
        ("unsure", "low confidence", "ContextCard or Later", "error -> penalty"),
        ("imported", "high confidence", "profile only", "import -> placement"),
        ("practiced often", "SensitiveGated", "safe fallback", "practice -> reward"),
        ("world eligible", "WorldCandidate", "proposal only", "candidate -> BuildState"),
    ]
    y = 500
    for row in rows:
        for x, width, value in zip(xs, widths, row):
            draw.rounded_rectangle((x, y, x + width, y + 135), radius=18, fill=PANEL, outline=LINE, width=2)
            draw_wrapped(draw, (x + 22, y + 34), value, BODY, width - 44, INK if x == xs[0] else MUTED)
        y += 165
    pill(draw, (500, 1360), "two axes", BLUE)
    pill(draw, (850, 1360), "no auto route", RED)
    pill(draw, (1240, 1360), "safe fallback normal", GREEN)
    out = OUT / "learning_vs_semantics_matrix.png"
    img.save(out)
    return out


def learning_reward_queue_world_separation() -> Path:
    img, draw = base(
        "Learning / Reward / Queue / World Separation",
        "Each layer may pass a safe signal forward. No layer may secretly become placement, persistence or SRS mutation.",
    )
    steps = [
        ("Learning state", "fachlicher Zustand", BLUE),
        ("Reward signal", "small optional signal", GREEN),
        ("Review queue", "budgeted decision", PURPLE),
        ("World feedback", "preview only", TEAL),
        ("Later gate", "persistence/build blocked", RED),
    ]
    boxes = []
    x = 130
    for title, body, color in steps:
        box = (x, 410, x + 375, 640)
        boxes.append(box)
        card(draw, box, title, body, color, SMALL, H3)
        x += 455
    for left, right in zip(boxes, boxes[1:]):
        arrow(draw, (left[2] + 22, 525), (right[0] - 22, 525))
    card(
        draw,
        (250, 860, 2150, 1115),
        "Blocked crossovers",
        "Reward cannot upgrade learning. Review confirm cannot write SRS. World feedback cannot place, persist, build, create assets or start frame_started.",
        RED,
        SMALL,
        H3,
    )
    out = OUT / "learning_reward_queue_world_separation.png"
    img.save(out)
    return out


def ai_provider_privacy_gate() -> Path:
    img, draw = base(
        "AI Provider and Privacy Gate",
        "Context and sentence data can be private. Classification stays local/rule-based by default until provider and privacy gates exist.",
    )
    card(
        draw,
        (140, 315, 1060, 875),
        "Safe default now",
        "Local/rule-based planning\nNo provider calls\nNo context storage\nNo hidden classification writes\nLow confidence -> fallback or queue",
        GREEN,
    )
    card(
        draw,
        (1320, 315, 2260, 875),
        "Blocked without gate",
        "External provider use\nPrivate ContextHint storage\nCost, bias or model dependency\nSending sentence/import context\nAI result -> placement",
        RED,
    )
    card(
        draw,
        (340, 1060, 2060, 1290),
        "Later governance gate",
        "A future gate must define provider choice, privacy, cost, bias, confidence, fallback, user control and auditability before any AI classification integration.",
        BLUE,
        SMALL,
        H3,
    )
    out = OUT / "ai_provider_privacy_gate.png"
    img.save(out)
    return out


def contact_sheet(paths: Iterable[Path]) -> Path:
    paths = list(paths)
    cw, ch = 2600, 3000
    img = Image.new("RGB", (cw, ch), BG)
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle((55, 45, cw - 55, ch - 55), radius=34, fill=SURFACE, outline=LINE, width=3)
    draw.text((100, 85), "M16-AA Learning States SRS Boundary", font=TITLE, fill=INK)
    draw_wrapped(
        draw,
        (102, 160),
        "Contact sheet for documentation previews. Generated diagrams only, not app screenshots or assets.",
        SUB,
        cw - 204,
        MUTED,
        8,
    )
    thumb_w, thumb_h = 1040, 725
    x_positions = [145, 1415]
    y_positions = [290, 1140, 1990]
    for index, path in enumerate(paths):
        x = x_positions[index % 2]
        y = y_positions[index // 2]
        with Image.open(path) as source:
            thumb = source.copy()
            thumb.thumbnail((thumb_w, thumb_h))
            frame = (x - 20, y - 20, x + thumb_w + 20, y + thumb_h + 72)
            draw.rounded_rectangle(frame, radius=24, fill=PANEL, outline=LINE, width=3)
            px = x + (thumb_w - thumb.width) // 2
            py = y + (thumb_h - thumb.height) // 2
            img.paste(thumb, (px, py))
            draw_wrapped(draw, (x, y + thumb_h + 22), path.name, SMALL, thumb_w, INK, 5)
    draw.line((100, ch - 132, cw - 100, ch - 132), fill=LINE, width=2)
    draw.text((100, ch - 96), FOOTER, font=TINY, fill=MUTED)
    out = OUT / "00_contact_sheet.png"
    img.save(out)
    return out


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    paths = [
        learning_state_boundaries(),
        srs_word_progress_firewall(),
        learning_vs_semantics_matrix(),
        learning_reward_queue_world_separation(),
        ai_provider_privacy_gate(),
    ]
    contact_sheet(paths)


if __name__ == "__main__":
    main()
