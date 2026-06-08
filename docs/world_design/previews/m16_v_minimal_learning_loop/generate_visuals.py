from __future__ import annotations

from pathlib import Path
from typing import Iterable

from PIL import Image, ImageDraw, ImageFont


OUT = Path(__file__).resolve().parent
W, H = 2200, 1400
BG = "#f6f7f2"
INK = "#22302c"
MUTED = "#66746f"
GREEN = "#78b88a"
BLUE = "#74a7c7"
YELLOW = "#e3c36b"
RED = "#d97871"
PANEL = "#ffffff"
LINE = "#d7ddd4"
FOOTER = "documentation preview only / no code / no assets / no implementation"


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/Library/Fonts/Arial Bold.ttf" if bold else "/Library/Fonts/Arial.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    ]
    for path in candidates:
        try:
            return ImageFont.truetype(path, size=size)
        except OSError:
            continue
    return ImageFont.load_default()


TITLE = font(58, True)
SUB = font(28)
H2 = font(34, True)
BODY = font(25)
SMALL = font(21)
TINY = font(18)


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
    fill: str = INK,
    spacing: int = 8,
) -> int:
    x, y = xy
    for line in wrap(draw, text, fnt, width):
        draw.text((x, y), line, font=fnt, fill=fill)
        y += text_size(draw, line or " ", fnt)[1] + spacing
    return y


def base(title: str, subtitle: str) -> tuple[Image.Image, ImageDraw.ImageDraw]:
    img = Image.new("RGB", (W, H), BG)
    d = ImageDraw.Draw(img)
    d.rounded_rectangle((58, 48, W - 58, H - 58), radius=36, fill="#fbfcf8", outline=LINE, width=3)
    d.text((100, 92), title, font=TITLE, fill=INK)
    draw_wrapped(d, (102, 168), subtitle, SUB, W - 204, MUTED, 8)
    d.line((100, H - 112, W - 100, H - 112), fill=LINE, width=2)
    d.text((100, H - 82), FOOTER, font=TINY, fill=MUTED)
    return img, d


def card(
    d: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    title: str,
    body: str,
    color: str,
    body_font: ImageFont.ImageFont = BODY,
    title_font: ImageFont.ImageFont = H2,
) -> None:
    x1, y1, x2, y2 = box
    d.rounded_rectangle(box, radius=26, fill=PANEL, outline=LINE, width=3)
    d.rounded_rectangle((x1, y1, x2, y1 + 14), radius=10, fill=color)
    d.text((x1 + 28, y1 + 32), title, font=title_font, fill=INK)
    draw_wrapped(d, (x1 + 28, y1 + 88), body, body_font, x2 - x1 - 56, MUTED, 8)


def arrow(d: ImageDraw.ImageDraw, start: tuple[int, int], end: tuple[int, int], color: str = "#8f9a96") -> None:
    d.line((start, end), fill=color, width=6)
    ex, ey = end
    sx, sy = start
    if abs(ex - sx) >= abs(ey - sy):
        sign = 1 if ex > sx else -1
        pts = [(ex, ey), (ex - sign * 24, ey - 14), (ex - sign * 24, ey + 14)]
    else:
        sign = 1 if ey > sy else -1
        pts = [(ex, ey), (ex - 14, ey - sign * 24), (ex + 14, ey - sign * 24)]
    d.polygon(pts, fill=color)


def badge(d: ImageDraw.ImageDraw, xy: tuple[int, int], label: str, color: str) -> None:
    x, y = xy
    tw, th = text_size(d, label, SMALL)
    d.rounded_rectangle((x, y, x + tw + 36, y + th + 22), radius=18, fill=color, outline="#ffffff", width=2)
    d.text((x + 18, y + 11), label, font=SMALL, fill="#ffffff")


def minimal_learning_loop() -> Path:
    img, d = base(
        "M16-V Minimal Playable Learning Loop",
        "A small playable loop connects learning, semantics, voluntary choice and reversible world feedback.",
    )
    boxes = [
        (120, 280, 470, 520, "Learn or review", "User learns or repeats one word in context.", GREEN),
        (560, 280, 910, 520, "Learning event", "A learning event exists, but it does not write world state.", BLUE),
        (1000, 280, 1350, 520, "Semantic check", "Sense, word type, safety and outcome are checked.", YELLOW),
        (1440, 280, 1790, 520, "Suggestion", "Safe proposal, Codex, Backlog or ContextCard.", BLUE),
        (400, 700, 750, 940, "User choice", "Confirm, Change, Later, Codex or Backlog. No forced decision.", GREEN),
        (840, 700, 1190, 940, "World feedback", "Small, reversible, preview-only signal.", YELLOW),
        (1280, 700, 1630, 940, "Tali/Vori optional", "Explains calmly, never pressures and never decides.", BLUE),
    ]
    for x1, y1, x2, y2, t, b, c in boxes:
        card(d, (x1, y1, x2, y2), t, b, c)
    arrow(d, (470, 400), (560, 400))
    arrow(d, (910, 400), (1000, 400))
    arrow(d, (1350, 400), (1440, 400))
    arrow(d, (1615, 520), (580, 700))
    arrow(d, (750, 820), (840, 820))
    arrow(d, (1190, 820), (1280, 820))
    badge(d, (140, 1085), "no automatic placement", RED)
    badge(d, (570, 1085), "no build state", RED)
    badge(d, (875, 1085), "no persistence", RED)
    badge(d, (1195, 1085), "reversible feedback only", GREEN)
    out = OUT / "minimal_learning_loop.png"
    img.save(out)
    return out


def event_separation_contract() -> Path:
    img, d = base(
        "Event Separation Contract",
        "Learning, semantics, reward, world feedback and persistence remain separate event families.",
    )
    xs = [120, 520, 920, 1320, 1720]
    titles = ["Learning", "Semantics", "Reward", "World feedback", "Persistence"]
    bodies = [
        "Exercise or review creates a learning event. It may ask semantics for a proposal.",
        "Context, sense, word type and safety produce outcome candidates.",
        "A reward event may offer gentle progress, never pressure or punishment.",
        "Only voluntary choice may create small reversible preview feedback.",
        "Blocked in M16-V. Needs data, migration, privacy and undo gates.",
    ]
    colors = [GREEN, BLUE, YELLOW, GREEN, RED]
    for x, t, b, c in zip(xs, titles, bodies, colors):
        card(d, (x, 300, x + 330, 840), t, b, c, SMALL, H2)
    for i in range(4):
        arrow(d, (xs[i] + 330, 570), (xs[i + 1], 570))
    card(
        d,
        (280, 965, 1920, 1135),
        "Hard boundary",
        "UI taps, previews and highlights do not create learning progress, reward, placement, build state or persistence.",
        RED,
        BODY,
        H2,
    )
    out = OUT / "event_separation_contract.png"
    img.save(out)
    return out


def learning_to_world_no_auto_placement() -> Path:
    img, d = base(
        "Learning-to-World: No Auto Placement",
        "Learning progress opens possibilities. It never places, builds or persists world state by itself.",
    )
    card(d, (130, 300, 930, 590), "Allowed path", "Learning progress -> semantic check -> safe proposal or fallback -> voluntary user choice -> preview-only world feedback.", GREEN)
    card(d, (1270, 300, 2070, 590), "Blocked path", "Learning progress -> automatic placement -> build state -> persistence. This path is not allowed.", RED)
    arrow(d, (930, 445), (1270, 445), "#b4aaa3")
    d.line((1080, 300, 1120, 590), fill=RED, width=12)
    d.line((1120, 300, 1080, 590), fill=RED, width=12)
    card(d, (250, 750, 725, 1010), "Safe outputs", "CodexOnly\nContextCard\nBacklog\nNeedsUserChoice", BLUE, SMALL)
    card(d, (865, 750, 1335, 1010), "World candidate", "Only a candidate. User can confirm, change or postpone.", YELLOW, SMALL)
    card(d, (1475, 750, 1950, 1010), "Still blocked", "Build-Wheel\nBuild-State\nframe_started\nDB writes", RED, SMALL)
    out = OUT / "learning_to_world_no_auto_placement.png"
    img.save(out)
    return out


def mvp_word_outcome_taxonomy() -> Path:
    img, d = base(
        "MVP Word Outcome Taxonomy",
        "The MVP has seven safe outcomes. None of them means automatic visible placement.",
    )
    items = [
        ("CodexOnly", "Neutral learning or explanation without world object.", BLUE),
        ("WorldCandidate", "A possible world suggestion after context and user choice.", GREEN),
        ("ContainerItem", "Small object goes to depth, container, Codex or Backlog.", YELLOW),
        ("ActionChallenge", "Verb or action becomes a challenge or context, not an object.", GREEN),
        ("ContextCard", "Sense, abstract meaning or example stays in a card.", BLUE),
        ("SensitiveGated", "Policy, opt-in or neutral fallback before any visual.", RED),
        ("NeedsUserChoice", "Multi-home or uncertain word waits for choice.", YELLOW),
    ]
    positions = [
        (120, 300, 620, 510),
        (700, 300, 1200, 510),
        (1280, 300, 1780, 510),
        (410, 590, 910, 800),
        (990, 590, 1490, 800),
        (1570, 590, 2070, 800),
        (700, 880, 1500, 1090),
    ]
    for box, (title, body, color) in zip(positions, items):
        card(d, box, title, body, color, SMALL, H2)
    badge(d, (770, 1160), "Taxonomy is not a final data model", RED)
    out = OUT / "mvp_word_outcome_taxonomy.png"
    img.save(out)
    return out


def review_queue_minimal_flow() -> Path:
    img, d = base(
        "Minimal Review Queue",
        "Only a few relevant decisions are shown. The queue prevents mass review and automatic placement.",
    )
    card(d, (150, 300, 520, 540), "Candidate", "A word needs context, choice, safety or fallback.", BLUE)
    card(d, (650, 300, 1020, 540), "Queue filter", "Risk, learning relevance, confidence and session budget.", YELLOW)
    card(d, (1150, 300, 1520, 540), "Small queue", "Few cards per session. No 20.000 decision list.", GREEN)
    card(d, (1650, 300, 2020, 540), "User decides", "Optional and reversible.", GREEN)
    arrow(d, (520, 420), (650, 420))
    arrow(d, (1020, 420), (1150, 420))
    arrow(d, (1520, 420), (1650, 420))
    outcomes = [
        ("Later", "defer"),
        ("Codex", "learn only"),
        ("Backlog", "wait for gate"),
        ("Confirm", "preview only"),
        ("Change", "choose better sense"),
    ]
    x = 180
    for label, desc in outcomes:
        card(d, (x, 760, x + 330, 980), label, desc, BLUE if label != "Confirm" else GREEN, SMALL, H2)
        x += 390
    badge(d, (360, 1110), "no forced review", RED)
    badge(d, (755, 1110), "no placement", RED)
    badge(d, (1075, 1110), "no persistence", RED)
    badge(d, (1405, 1110), "few choices only", GREEN)
    out = OUT / "review_queue_minimal_flow.png"
    img.save(out)
    return out


def contact_sheet(paths: Iterable[Path]) -> Path:
    paths = list(paths)
    img = Image.new("RGB", (2400, 2550), BG)
    d = ImageDraw.Draw(img)
    d.text((90, 70), "M16-V Minimal Learning Loop Visuals", font=TITLE, fill=INK)
    d.text((92, 145), "Contact sheet / documentation preview only", font=SUB, fill=MUTED)
    thumb_w, thumb_h = 1000, 560
    coords = [(120, 250), (1280, 250), (120, 950), (1280, 950), (700, 1650)]
    for path, (x, y) in zip(paths, coords):
        src = Image.open(path).convert("RGB")
        src.thumbnail((thumb_w, thumb_h), Image.LANCZOS)
        frame = (x - 24, y - 24, x + thumb_w + 24, y + thumb_h + 82)
        d.rounded_rectangle(frame, radius=28, fill=PANEL, outline=LINE, width=3)
        img.paste(src, (x + (thumb_w - src.width) // 2, y))
        label = path.name
        d.text((x, y + thumb_h + 28), label, font=SMALL, fill=INK)
    d.line((90, 2455, 2310, 2455), fill=LINE, width=2)
    d.text((90, 2485), FOOTER, font=TINY, fill=MUTED)
    out = OUT / "00_contact_sheet.png"
    img.save(out)
    return out


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    paths = [
        minimal_learning_loop(),
        event_separation_contract(),
        learning_to_world_no_auto_placement(),
        mvp_word_outcome_taxonomy(),
        review_queue_minimal_flow(),
    ]
    contact_sheet(paths)
    for path in [OUT / "00_contact_sheet.png", *paths]:
        print(path.name)


if __name__ == "__main__":
    main()
