from __future__ import annotations

from pathlib import Path
from typing import Iterable

from PIL import Image, ImageDraw, ImageFont


OUT = Path(__file__).resolve().parent
W, H = 2400, 1600
BG = "#f6f7f2"
INK = "#22302c"
MUTED = "#65746e"
PANEL = "#ffffff"
LINE = "#d6ddd3"
GREEN = "#75b889"
BLUE = "#76a9c9"
YELLOW = "#e3c36b"
RED = "#d87670"
PURPLE = "#9b8cc7"
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


TITLE = font(58, True)
SUB = font(28)
H2 = font(32, True)
H3 = font(26, True)
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
    d = ImageDraw.Draw(img)
    d.rounded_rectangle((58, 48, W - 58, H - 58), radius=34, fill="#fbfcf8", outline=LINE, width=3)
    d.text((100, 90), title, font=TITLE, fill=INK)
    draw_wrapped(d, (102, 165), subtitle, SUB, W - 204, MUTED, 8)
    d.line((100, H - 118, W - 100, H - 118), fill=LINE, width=2)
    d.text((100, H - 86), FOOTER, font=TINY, fill=MUTED)
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
    d.rounded_rectangle(box, radius=24, fill=PANEL, outline=LINE, width=3)
    d.rounded_rectangle((x1, y1, x2, y1 + 14), radius=9, fill=color)
    d.text((x1 + 26, y1 + 32), title, font=title_font, fill=INK)
    draw_wrapped(d, (x1 + 26, y1 + 84), body, body_font, x2 - x1 - 52)


def arrow(d: ImageDraw.ImageDraw, start: tuple[int, int], end: tuple[int, int]) -> None:
    d.line((start, end), fill="#8c9994", width=6)
    ex, ey = end
    sx, sy = start
    if abs(ex - sx) >= abs(ey - sy):
        sign = 1 if ex > sx else -1
        d.polygon([(ex, ey), (ex - sign * 24, ey - 15), (ex - sign * 24, ey + 15)], fill="#8c9994")
    else:
        sign = 1 if ey > sy else -1
        d.polygon([(ex, ey), (ex - 15, ey - sign * 24), (ex + 15, ey - sign * 24)], fill="#8c9994")


def badge(d: ImageDraw.ImageDraw, xy: tuple[int, int], label: str, color: str) -> None:
    x, y = xy
    tw, th = text_size(d, label, SMALL)
    d.rounded_rectangle((x, y, x + tw + 34, y + th + 20), radius=17, fill=color)
    d.text((x + 17, y + 10), label, font=SMALL, fill="#ffffff")


def word_outcome_decision_matrix() -> Path:
    img, d = base(
        "Word Outcome Decision Matrix",
        "Word type, risk, clutter, sense clarity and user choice route each word to a safe MVP outcome.",
    )
    headers = ["Signal", "Risk filter", "Primary outcome", "Fallback / stop"]
    x = [110, 650, 1190, 1730]
    for xi, h in zip(x, headers):
        card(d, (xi, 270, xi + 480, 420), h, "", BLUE, SMALL, H3)
    rows = [
        ("Abstract", "low visual fit", "CodexOnly", "ContextCard"),
        ("Large object", "needs context", "WorldCandidate", "NeedsUserChoice"),
        ("Tiny object", "clutter high", "ContainerItem", "Codex/Backlog"),
        ("Verb/action", "not static", "ActionChallenge", "ContextCard"),
        ("Sensitive", "policy risk", "SensitiveGated", "Codex/Hide"),
        ("Multi-home", "sense unclear", "NeedsUserChoice", "Later/Change"),
    ]
    y = 470
    for i, row in enumerate(rows):
        color = GREEN if i in (1, 3) else YELLOW if i in (2, 5) else BLUE if i == 0 else RED
        for xi, val in zip(x, row):
            d.rounded_rectangle((xi, y, xi + 480, y + 115), radius=18, fill=PANEL, outline=LINE, width=2)
            draw_wrapped(d, (xi + 22, y + 30), val, BODY, 420, INK if xi == x[2] else MUTED)
        d.rounded_rectangle((1190, y, 1670, y + 10), radius=5, fill=color)
        y += 145
    badge(d, (340, 1380), "no automatic placement", RED)
    badge(d, (770, 1380), "outcome first", GREEN)
    badge(d, (1080, 1380), "user choice when unclear", BLUE)
    out = OUT / "word_outcome_decision_matrix.png"
    img.save(out)
    return out


def outcome_cards_overview() -> Path:
    img, d = base(
        "Minimal Word Outcome Cards",
        "Seven MVP outcomes define safe reactions without final routing, persistence, assets or build state.",
    )
    items = [
        ("CodexOnly", "Explain and learn. No world object.", BLUE),
        ("WorldCandidate", "Possible world suggestion. User choice and later gate.", GREEN),
        ("ContainerItem", "Small object goes to depth, container, Codex or Backlog.", YELLOW),
        ("ActionChallenge", "Verb/action becomes challenge or context, not static object.", GREEN),
        ("ContextCard", "Sense, example or abstract meaning without symbol pressure.", BLUE),
        ("SensitiveGated", "Policy, opt-in and neutral fallback before visuals.", RED),
        ("NeedsUserChoice", "Multi-home, low confidence or unclear sense needs choice.", PURPLE),
    ]
    boxes = [
        (120, 280, 650, 475),
        (730, 280, 1260, 475),
        (1340, 280, 1870, 475),
        (430, 560, 960, 755),
        (1040, 560, 1570, 755),
        (1650, 560, 2180, 755),
        (735, 840, 1665, 1035),
    ]
    for box, (title, body, color) in zip(boxes, items):
        card(d, box, title, body, color, SMALL, H2)
    card(
        d,
        (420, 1160, 1980, 1310),
        "Shared boundary",
        "Every outcome may suggest, explain, defer or ask. No outcome places, builds, persists, creates assets or starts frame_started.",
        RED,
    )
    out = OUT / "outcome_cards_overview.png"
    img.save(out)
    return out


def queue_exit_rules() -> Path:
    img, d = base(
        "Review Queue Exit Rules",
        "Queue exits are safe endings for small decisions. They do not create placement, persistence or build state.",
    )
    items = [
        ("Later", "Defer decision. No penalty, no pressure.", BLUE),
        ("Codex", "Learn/explain without world object.", GREEN),
        ("Backlog", "Wait for context, gate, island or depth.", YELLOW),
        ("Confirm", "Accept as preview possibility only.", GREEN),
        ("Change", "Choose better sense, category or outcome.", BLUE),
        ("Hide", "Remove from active review view. No data loss without gate.", PURPLE),
    ]
    positions = [
        (150, 300, 690, 520),
        (930, 300, 1470, 520),
        (1710, 300, 2250, 520),
        (150, 720, 690, 940),
        (930, 720, 1470, 940),
        (1710, 720, 2250, 940),
    ]
    for box, (title, body, color) in zip(positions, items):
        card(d, box, title, body, color)
    arrow(d, (690, 410), (930, 410))
    arrow(d, (1470, 410), (1710, 410))
    arrow(d, (690, 830), (930, 830))
    arrow(d, (1470, 830), (1710, 830))
    badge(d, (580, 1180), "no mass decisions", RED)
    badge(d, (940, 1180), "few choices", GREEN)
    badge(d, (1235, 1180), "reversible", BLUE)
    out = OUT / "queue_exit_rules.png"
    img.save(out)
    return out


def reward_vs_placement_boundaries() -> Path:
    img, d = base(
        "Reward vs Placement Boundaries",
        "Reward, proposal, PlacementCandidate and BuildState must not collapse into one hidden side effect.",
    )
    boxes = [
        (120, 330, 570, 650, "Reward", "Gentle signal: learning made something possible.", GREEN),
        (720, 330, 1170, 650, "Proposal", "Visible possibility. User can confirm, change or defer.", BLUE),
        (1320, 330, 1770, 650, "PlacementCandidate", "Later technical candidate after user choice and gate.", YELLOW),
        (1920, 330, 2270, 650, "BuildState", "Blocked. No build, no frame_started, no persistence.", RED),
    ]
    for box in boxes:
        card(d, box[:4], box[4], box[5], box[6], SMALL)
    arrow(d, (570, 490), (720, 490))
    arrow(d, (1170, 490), (1320, 490))
    arrow(d, (1770, 490), (1920, 490))
    d.line((1845, 315, 1845, 675), fill=RED, width=10)
    d.line((1875, 315, 1875, 675), fill=RED, width=10)
    card(
        d,
        (300, 850, 2100, 1080),
        "Boundary rule",
        "Reward can open a voluntary proposal. Proposal can become a later candidate only after user choice and gate. BuildState and frame_started remain blocked.",
        RED,
    )
    badge(d, (610, 1230), "reward is signal", GREEN)
    badge(d, (920, 1230), "proposal is possibility", BLUE)
    badge(d, (1320, 1230), "build state blocked", RED)
    out = OUT / "reward_vs_placement_boundaries.png"
    img.save(out)
    return out


def example_words_outcome_map() -> Path:
    img, d = base(
        "Example Words Outcome Map",
        "Examples show that one word can route to fallback, choice, context or candidate without automatic placement.",
    )
    items = [
        ("Haus", "NeedsUserChoice", "multi-home / no default house"),
        ("Garage", "NeedsUserChoice", "home, vehicle or city"),
        ("Baum", "WorldCandidate", "with clutter gate"),
        ("schwimmen", "ActionChallenge", "water/safety action"),
        ("Angst", "SensitiveGated", "emotion, no reward"),
        ("lernen", "ActionChallenge", "not school building"),
        ("Messer", "ContainerItem", "safety + small object"),
        ("Polizei", "SensitiveGated", "public institution"),
        ("Freiheit", "CodexOnly", "abstract concept"),
        ("Schluessel", "ContainerItem", "tiny object"),
        ("kochen", "ActionChallenge", "verb/action"),
        ("Bank", "NeedsUserChoice", "seat, money, river"),
    ]
    colors = {
        "CodexOnly": BLUE,
        "WorldCandidate": GREEN,
        "ContainerItem": YELLOW,
        "ActionChallenge": GREEN,
        "ContextCard": BLUE,
        "SensitiveGated": RED,
        "NeedsUserChoice": PURPLE,
    }
    start_x, start_y = 110, 280
    cell_w, cell_h = 500, 210
    gap_x, gap_y = 68, 45
    for idx, (word, outcome, note) in enumerate(items):
        col = idx % 4
        row = idx // 4
        x = start_x + col * (cell_w + gap_x)
        y = start_y + row * (cell_h + gap_y)
        card(d, (x, y, x + cell_w, y + cell_h), word, f"{outcome}\n{note}", colors[outcome], SMALL, H2)
    card(
        d,
        (320, 1185, 2080, 1335),
        "Shared result",
        "Examples may be learned and reviewed. None places itself, creates assets, writes progress, starts BuildState or frame_started.",
        RED,
    )
    out = OUT / "example_words_outcome_map.png"
    img.save(out)
    return out


def contact_sheet(paths: Iterable[Path]) -> Path:
    paths = list(paths)
    img = Image.new("RGB", (2600, 2700), BG)
    d = ImageDraw.Draw(img)
    d.text((90, 70), "M16-W Word Outcome Detail Gate Visuals", font=TITLE, fill=INK)
    d.text((92, 145), "Contact sheet / documentation preview only", font=SUB, fill=MUTED)
    thumb_w, thumb_h = 1080, 620
    coords = [(120, 260), (1400, 260), (120, 1020), (1400, 1020), (760, 1780)]
    for path, (x, y) in zip(paths, coords):
        src = Image.open(path).convert("RGB")
        src.thumbnail((thumb_w, thumb_h), Image.LANCZOS)
        d.rounded_rectangle((x - 26, y - 26, x + thumb_w + 26, y + thumb_h + 90), radius=28, fill=PANEL, outline=LINE, width=3)
        img.paste(src, (x + (thumb_w - src.width) // 2, y))
        d.text((x, y + thumb_h + 32), path.name, font=SMALL, fill=INK)
    d.line((90, 2605, 2510, 2605), fill=LINE, width=2)
    d.text((90, 2635), FOOTER, font=TINY, fill=MUTED)
    out = OUT / "00_contact_sheet.png"
    img.save(out)
    return out


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    paths = [
        word_outcome_decision_matrix(),
        outcome_cards_overview(),
        queue_exit_rules(),
        reward_vs_placement_boundaries(),
        example_words_outcome_map(),
    ]
    contact_sheet(paths)
    for path in [OUT / "00_contact_sheet.png", *paths]:
        print(path.name)


if __name__ == "__main__":
    main()
