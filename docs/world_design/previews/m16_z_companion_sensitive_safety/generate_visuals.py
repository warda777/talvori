from __future__ import annotations

from pathlib import Path
from typing import Iterable

from PIL import Image, ImageDraw, ImageFont


OUT = Path(__file__).resolve().parent
W, H = 2400, 1650
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
FOOTER = "documentation preview only / no code / no screenshots / no assets / no app integration"


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


def companion_policy_boundaries() -> Path:
    img, draw = base(
        "Companion Policy Boundaries",
        "Tali/Vori may explain and soften decisions. They never decide, pressure, advise medically or trigger world systems.",
    )
    card(
        draw,
        (140, 285, 1120, 1000),
        "Allowed companion role",
        "Explaining companion\nOptional suggester\nContext helper\nGentle return hint\nNeutral Codex/ContextCard explanation\nLater is always acceptable",
        GREEN,
    )
    card(
        draw,
        (1280, 285, 2260, 1000),
        "Blocked companion role",
        "No decision automation\nNo pressure or guilt\nNo medical, legal or psychological advice\nNo reward trigger\nNo placement, persistence or learning-progress trigger",
        RED,
    )
    card(
        draw,
        (345, 1130, 2055, 1325),
        "Policy rule",
        "Companion language may orient the user. It cannot override Safety, create Reward, place words, start BuildState, persist data or mutate SRS/word_progress.",
        BLUE,
        SMALL,
        H3,
    )
    out = OUT / "companion_policy_boundaries.png"
    img.save(out)
    return out


def companion_speaking_moments() -> Path:
    img, draw = base(
        "Companion Speaking Moments",
        "Speaking moments are budgeted and optional. Silence is valid when learning flow, sensitivity or review budget needs quiet.",
    )
    allowed = [
        ("After learning block", "one gentle optional note"),
        ("Uncertainty", "explain context or sense"),
        ("NeedsUserChoice", "show choices without pressure"),
        ("Return after pause", "neutral welcome back"),
        ("Sensitive / abstract", "Codex, ContextCard, Later, Hide"),
        ("Voluntary review", "brief orientation"),
    ]
    blocked = [
        ("After every word", "too much interruption"),
        ("Queue budget full", "no review pressure"),
        ("Sensitive without opt-in", "stay quiet or safe fallback"),
        ("Ignored review", "no nagging"),
        ("User only wants to learn", "do not interrupt"),
        ("Retention trigger", "no guilt, fear or FOMO"),
    ]
    y = 295
    for i, (title, body) in enumerate(allowed):
        x = 130 + (i % 2) * 510
        yy = y + (i // 2) * 255
        card(draw, (x, yy, x + 455, yy + 190), title, body, GREEN, SMALL, H3)
    for i, (title, body) in enumerate(blocked):
        x = 1290 + (i % 2) * 510
        yy = y + (i // 2) * 255
        card(draw, (x, yy, x + 455, yy + 190), title, body, RED, SMALL, H3)
    pill(draw, (575, 1265), "allowed: optional and calm", GREEN)
    pill(draw, (1255, 1265), "blocked: pressure and overload", RED)
    out = OUT / "companion_speaking_moments.png"
    img.save(out)
    return out


def return_after_pause_flow() -> Path:
    img, draw = base(
        "Return After Pause Flow",
        "A pause never creates loss, decay, guilt or required review. Talvori resumes calmly and lets the user continue.",
    )
    steps = [
        ("Pause", "no world decay", BLUE),
        ("Return", "neutral welcome", GREEN),
        ("Optional hint", "short and skippable", TEAL),
        ("Continue learning", "no mandatory review", GREEN),
        ("Later gate", "review only when wanted", PURPLE),
    ]
    boxes = []
    x = 130
    for title, body, color in steps:
        box = (x, 400, x + 375, 630)
        boxes.append(box)
        card(draw, box, title, body, color, SMALL, H3)
        x += 455
    for left, right in zip(boxes, boxes[1:]):
        arrow(draw, (left[2] + 22, 515), (right[0] - 22, 515))
    card(
        draw,
        (250, 820, 2150, 1115),
        "Blocked return patterns",
        "No guilt. No loss warning. No world ruin. No streak debt. No sensitive retention trigger. No forced decision. No SRS or word_progress mutation from return copy.",
        RED,
    )
    card(
        draw,
        (500, 1220, 1900, 1365),
        "Copy principle",
        "Welcome back. We continue calmly.",
        GREEN,
        BODY,
        H3,
    )
    out = OUT / "return_after_pause_flow.png"
    img.save(out)
    return out


def sensitive_representation_ladder() -> Path:
    img, draw = base(
        "Sensitive Representation Ladder",
        "Sensitive content exits through the safest available rung. Visible world representation needs a later dedicated gate.",
    )
    rungs = [
        ("1 Not active", "do not surface"),
        ("2 Hide", "user can avoid"),
        ("3 Later", "voluntary delay"),
        ("4 CodexOnly", "neutral explanation"),
        ("5 ContextCard", "context without object"),
        ("6 Backlog", "park safely"),
        ("7 SensitiveGated", "requires policy gate"),
        ("8 Opt-in later", "separate future approval"),
    ]
    y = 275
    for i, (title, body) in enumerate(rungs):
        x = 170 + (i % 4) * 535
        yy = y + (i // 4) * 335
        card(draw, (x, yy, x + 450, yy + 230), title, body, BLUE if i < 4 else PURPLE, SMALL, H3)
    card(
        draw,
        (350, 1050, 2050, 1275),
        "Blocked without own gate",
        "No sensitive object, building, decoration, reward, placement, asset, BuildState or frame_started. Safety wins before user choice, capability and reward.",
        RED,
        SMALL,
        H3,
    )
    out = OUT / "sensitive_representation_ladder.png"
    img.save(out)
    return out


def forbidden_pressure_copy() -> Path:
    img, draw = base(
        "Forbidden Pressure Copy",
        "Talvori copy must avoid shame, fear, forced choice, false advice and sensitive retention triggers.",
    )
    forbidden = [
        "You failed.",
        "You lose progress.",
        "You must decide now.",
        "Your world decays if you pause.",
        "Sensitive words as rewards.",
        "Medical/legal/psychological advice.",
    ]
    safe = [
        "Calm return language.",
        "Later is always possible.",
        "Codex and ContextCard are normal.",
        "Errors are learning signals.",
        "No negative world reaction.",
        "Sensitive topics stay neutral.",
    ]
    card(draw, (130, 290, 1110, 1210), "Forbidden patterns", "\n".join(forbidden), RED)
    card(draw, (1290, 290, 2270, 1210), "Safe copy principles", "\n".join(safe), GREEN)
    pill(draw, (410, 1320), "no guilt", RED)
    pill(draw, (720, 1320), "no forced review", RED)
    pill(draw, (1110, 1320), "no false advice", RED)
    pill(draw, (1500, 1320), "neutral and optional", GREEN)
    out = OUT / "forbidden_pressure_copy.png"
    img.save(out)
    return out


def contact_sheet(paths: Iterable[Path]) -> Path:
    paths = list(paths)
    cw, ch = 2600, 3000
    img = Image.new("RGB", (cw, ch), BG)
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle((55, 45, cw - 55, ch - 55), radius=34, fill=SURFACE, outline=LINE, width=3)
    draw.text((100, 85), "M16-Z Companion Sensitive Safety", font=TITLE, fill=INK)
    draw_wrapped(
        draw,
        (102, 160),
        "Contact sheet for documentation previews. Each thumbnail is generated art, not an app screenshot or asset.",
        SUB,
        cw - 204,
        MUTED,
        8,
    )
    thumb_w, thumb_h = 1040, 715
    x_positions = [145, 1415]
    y_positions = [290, 1140, 1990]
    for index, path in enumerate(paths):
        x = x_positions[index % 2]
        y = y_positions[index // 2]
        with Image.open(path) as source:
            thumb = source.copy()
            thumb.thumbnail((thumb_w, thumb_h))
            frame = (x - 20, y - 20, x + thumb_w + 20, y + thumb_h + 70)
            draw.rounded_rectangle(frame, radius=24, fill=PANEL, outline=LINE, width=3)
            px = x + (thumb_w - thumb.width) // 2
            py = y + (thumb_h - thumb.height) // 2
            img.paste(thumb, (px, py))
            draw_wrapped(draw, (x, y + thumb_h + 20), path.name, SMALL, thumb_w, INK, 5)
    draw.line((100, ch - 132, cw - 100, ch - 132), fill=LINE, width=2)
    draw.text((100, ch - 96), FOOTER, font=TINY, fill=MUTED)
    out = OUT / "00_contact_sheet.png"
    img.save(out)
    return out


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    paths = [
        companion_policy_boundaries(),
        companion_speaking_moments(),
        return_after_pause_flow(),
        sensitive_representation_ladder(),
        forbidden_pressure_copy(),
    ]
    contact_sheet(paths)


if __name__ == "__main__":
    main()
