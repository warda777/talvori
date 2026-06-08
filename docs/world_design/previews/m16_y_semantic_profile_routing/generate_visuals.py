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
    draw.text((x1 + 24, y1 + 30), title, font=title_font, fill=INK)
    draw_wrapped(draw, (x1 + 24, y1 + 82), body, body_font, x2 - x1 - 48)


def pill(draw: ImageDraw.ImageDraw, xy: tuple[int, int], label: str, color: str) -> None:
    x, y = xy
    tw, th = text_size(draw, label, SMALL)
    draw.rounded_rectangle((x, y, x + tw + 32, y + th + 18), radius=17, fill=color)
    draw.text((x + 16, y + 9), label, font=SMALL, fill="#ffffff")


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


def minimal_semantic_profile_fields() -> Path:
    img, draw = base(
        "Minimal Semantic Profile Fields",
        "MVP fields are conceptual guardrails. They are not a final data model, persistence plan or runtime config.",
    )
    fields = [
        ("Identity", "wordId/localWordRef, normalizedText, displayText, language", BLUE),
        ("Context", "contextHint, senseStatus, primaryWordType", GREEN),
        ("Risk", "safetyStatus, clutterRisk, confidenceBand", RED),
        ("Outcome", "candidateOutcomes, selectedOutcome, fallbackTarget", YELLOW),
        ("Review", "requiresUserChoice, reviewEligibility, notes", PURPLE),
    ]
    xs = [125, 570, 1015, 1460, 1905]
    for x, (title, body, color) in zip(xs, fields):
        card(draw, (x, 310, x + 365, 610), title, body, color, SMALL, H3)
    card(
        draw,
        (240, 790, 2160, 1035),
        "Field rules",
        "Fields may explain, classify, defer and select safe outcomes. They may not write data, mutate SRS, create routes, place objects, build assets or start frame_started.",
        RED,
    )
    pill(draw, (500, 1210), "concept only", BLUE)
    pill(draw, (820, 1210), "no final schema", RED)
    pill(draw, (1195, 1210), "no persistence", RED)
    pill(draw, (1570, 1210), "safe defaults", GREEN)
    out = OUT / "minimal_semantic_profile_fields.png"
    img.save(out)
    return out


def routing_priority_stack() -> Path:
    img, draw = base(
        "Routing Priority Stack",
        "Semantic conflicts resolve in a strict order before any theme, plot, reward or world feedback can be considered.",
    )
    items = [
        ("1 Safety / Sensitive", "Policy and safety win first.", RED),
        ("2 Context / Sense", "Context beats surface form.", BLUE),
        ("3 Word Type", "Noun, verb, emotion, tiny object, institution.", GREEN),
        ("4 Clutter / Mobile", "Depth and mobile readability can stop visibility.", YELLOW),
        ("5 Confidence", "Low/unknown confidence routes to fallback.", PURPLE),
        ("6 User Choice", "Choice helps, but cannot override safety.", TEAL),
        ("7 Theme / Plot Capability", "Capability is permission, not obligation.", BLUE),
        ("8 Reward / World Feedback", "Last step. No build, no placement.", GREEN),
    ]
    y = 265
    for title, body, color in items:
        card(draw, (300, y, 2100, y + 120), title, body, color, SMALL, H3)
        y += 150
    out = OUT / "routing_priority_stack.png"
    img.save(out)
    return out


def confidence_band_outcomes() -> Path:
    img, draw = base(
        "Confidence Band Outcomes",
        "Confidence limits visibility. Low or unknown confidence never creates placement, build state or persistence.",
    )
    rows = [
        ("high", "safe default or small optional review", "no automatic placement", GREEN),
        ("medium", "ContextCard, NeedsUserChoice, Backlog", "no final category", BLUE),
        ("low", "NeedsUserChoice, Backlog, CodexOnly", "no WorldCandidate pressure", YELLOW),
        ("unknown", "CodexOnly, Backlog, ContextCard, Later", "no visible world reaction", RED),
    ]
    xs = [130, 620, 1280, 1850]
    headers = ["Band", "Allowed reaction", "Blocked reaction", "Fallback rule"]
    widths = [410, 580, 490, 390]
    for x, width, header in zip(xs, widths, headers):
        card(draw, (x, 280, x + width, 420), header, "", BLUE, SMALL, H3)
    y = 500
    for band, allowed, blocked, color in rows:
        values = [band, allowed, blocked, "safe default wins"]
        for x, width, value in zip(xs, widths, values):
            draw.rounded_rectangle((x, y, x + width, y + 135), radius=18, fill=PANEL, outline=LINE, width=2)
            draw_wrapped(draw, (x + 22, y + 34), value, BODY, width - 44, INK if value == band else MUTED)
        draw.rounded_rectangle((130, y, 540, y + 10), radius=5, fill=color)
        y += 170
    card(
        draw,
        (360, 1270, 2040, 1410),
        "Low-confidence rule",
        "Low confidence routes to NeedsUserChoice, Backlog, CodexOnly or ContextCard. It never places, persists or builds.",
        RED,
        SMALL,
        H3,
    )
    out = OUT / "confidence_band_outcomes.png"
    img.save(out)
    return out


def word_type_to_outcome_map() -> Path:
    img, draw = base(
        "Word Type To Outcome Map",
        "Word type determines safe outcome families before ThemeIsland, plot capability or reward can speak.",
    )
    rows = [
        ("Noun", "WorldCandidate / ContainerItem / CodexOnly", "auto placement", BLUE),
        ("Verb / action", "ActionChallenge / ContextCard", "static object", GREEN),
        ("Adjective", "ContextCard / CodexOnly / modifier later", "own plot", TEAL),
        ("Emotion / abstract", "ContextCard / CodexOnly / SensitiveGated", "symbol pressure", PURPLE),
        ("TinyObject", "ContainerItem / Backlog / CodexOnly", "IslandView clutter", YELLOW),
        ("Institution", "SensitiveGated / ContextCard / CodexOnly", "reward or building", RED),
        ("Place / building", "NeedsUserChoice / WorldCandidate later", "default route", BLUE),
        ("Process / event", "ActionChallenge / Backlog", "BuildState", GREEN),
    ]
    y = 270
    for i, (typ, outcomes, blocked, color) in enumerate(rows):
        x = 140 if i % 2 == 0 else 1270
        yy = y + (i // 2) * 265
        card(draw, (x, yy, x + 990, yy + 205), typ, f"Preferred: {outcomes}\nBlocked: {blocked}", color, SMALL, H2)
    pill(draw, (520, 1380), "word type before theme", GREEN)
    pill(draw, (930, 1380), "no one-way routing", RED)
    pill(draw, (1320, 1380), "fallbacks are normal", BLUE)
    out = OUT / "word_type_to_outcome_map.png"
    img.save(out)
    return out


def conflict_resolution_flow() -> Path:
    img, draw = base(
        "Conflict Resolution Flow",
        "If filters disagree, Talvori exits through the safest path. Safety and low confidence never become world placement.",
    )
    steps = [
        ((120, 430, 455, 610), "Word arrives", "Context and source are inspected.", BLUE),
        ((600, 430, 935, 610), "Safety first", "Sensitive/policy can stop visibility.", RED),
        ((1080, 430, 1415, 610), "Sense + type", "Meaning and word type pick outcome families.", GREEN),
        ((1560, 430, 1895, 610), "Confidence gate", "Medium/low/unknown routes to fallback or review.", YELLOW),
        ((2040, 430, 2295, 610), "Safe result", "Outcome, queue, fallback or later gate.", PURPLE),
    ]
    for box, title, body, color in steps:
        card(draw, box, title, body, color, SMALL, H3)
    for i in range(len(steps) - 1):
        arrow(draw, (steps[i][0][2] + 25, 520), (steps[i + 1][0][0] - 25, 520))
    card(
        draw,
        (180, 840, 1050, 1085),
        "Stops visibility",
        "Sensitive risk, missing sense, tiny-object clutter, low confidence, full review budget.",
        RED,
    )
    card(
        draw,
        (1350, 840, 2220, 1085),
        "Allowed exits",
        "CodexOnly, ContextCard, Backlog, Later, Hide, ContainerItem, NeedsUserChoice, SensitiveGated.",
        GREEN,
    )
    card(
        draw,
        (430, 1260, 1970, 1400),
        "Never by conflict resolution",
        "No PlacementCandidate, no BuildState, no persistence, no assets, no frame_started.",
        RED,
        SMALL,
        H3,
    )
    out = OUT / "conflict_resolution_flow.png"
    img.save(out)
    return out


def contact_sheet(paths: Iterable[Path]) -> Path:
    paths = list(paths)
    cw, ch = 2600, 2800
    img = Image.new("RGB", (cw, ch), BG)
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle((60, 55, cw - 60, ch - 55), radius=34, fill="#fbfcf8", outline=LINE, width=3)
    draw.text((105, 95), "M16-Y Semantic Profile Routing Contact Sheet", font=TITLE, fill=INK)
    draw_wrapped(
        draw,
        (108, 172),
        "Documentation previews only. Verify text containment, spacing, footer clearance and overlap-free cards.",
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
        minimal_semantic_profile_fields(),
        routing_priority_stack(),
        confidence_band_outcomes(),
        word_type_to_outcome_map(),
        conflict_resolution_flow(),
    ]
    contact_sheet(paths)


if __name__ == "__main__":
    main()

