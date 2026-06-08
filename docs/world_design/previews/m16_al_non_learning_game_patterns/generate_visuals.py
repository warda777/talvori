from __future__ import annotations

from dataclasses import dataclass
from html import escape
from pathlib import Path
import xml.etree.ElementTree as ET

from PIL import Image, ImageDraw, ImageFont


OUT = Path(__file__).resolve().parent

W = 3400
H = 2550
BG = "#f8f9f4"
PANEL = "#ffffff"
INK = "#1e2b28"
MUTED = "#65726d"
BORDER = "#d7dfd8"
ARROW = "#93a39c"
GREEN = "#69ad78"
BLUE = "#67a7cb"
TEAL = "#59b7aa"
YELLOW = "#d6b95a"
RED = "#d96d67"
PURPLE = "#8979c7"
GRAY = "#8f9d98"
SVG_FONT = "Arial, Helvetica, sans-serif"
FOOTER = (
    "documentation deep research only / no implementation / no app integration / "
    "no FOMO or gacha / no BuildState / no frame_started"
)


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    candidates = [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/Library/Fonts/Arial Bold.ttf" if bold else "/Library/Fonts/Arial.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    ]
    for candidate in candidates:
        if Path(candidate).exists():
            return ImageFont.truetype(candidate, size=size)
    return ImageFont.load_default()


F_TITLE = font(62, True)
F_SUB = font(29)
F_HEAD = font(32, True)
F_BODY = font(24)
F_SMALL = font(20)
F_TINY = font(18)
F_FOOT = font(18)


def text_width(draw: ImageDraw.ImageDraw, text: str, fnt: ImageFont.ImageFont) -> int:
    box = draw.textbbox((0, 0), text, font=fnt)
    return box[2] - box[0]


def split_long_word(draw: ImageDraw.ImageDraw, word: str, width: int, fnt: ImageFont.ImageFont) -> list[str]:
    parts: list[str] = []
    current = ""
    for char in word:
        candidate = current + char
        if current and text_width(draw, candidate, fnt) > width:
            parts.append(current)
            current = char
        else:
            current = candidate
    if current:
        parts.append(current)
    return parts


def wrap_lines(draw: ImageDraw.ImageDraw, text: str, width: int, fnt: ImageFont.ImageFont) -> list[str]:
    lines: list[str] = []
    for paragraph in text.split("\n"):
        if paragraph == "":
            lines.append("")
            continue
        current = ""
        for raw_word in paragraph.split(" "):
            pieces = (
                split_long_word(draw, raw_word, width, fnt)
                if text_width(draw, raw_word, fnt) > width
                else [raw_word]
            )
            for word in pieces:
                candidate = word if not current else f"{current} {word}"
                if current and text_width(draw, candidate, fnt) > width:
                    lines.append(current)
                    current = word
                else:
                    current = candidate
        if current:
            lines.append(current)
    return lines


@dataclass
class Diagram:
    title: str
    subtitle: str
    width: int = W
    height: int = H

    def __post_init__(self) -> None:
        self.img = Image.new("RGB", (self.width, self.height), BG)
        self.draw = ImageDraw.Draw(self.img)
        self.svg: list[str] = [
            f'<svg xmlns="http://www.w3.org/2000/svg" width="{self.width}" height="{self.height}" viewBox="0 0 {self.width} {self.height}">',
            f'<rect width="{self.width}" height="{self.height}" fill="{BG}"/>',
        ]
        self.rounded_rect((48, 38, self.width - 48, self.height - 38), 30, BG, BORDER, 2)
        self.text(self.title, 92, 86, F_TITLE, INK, bold=True, max_width=self.width - 184)
        self.text(self.subtitle, 92, 174, F_SUB, MUTED, max_width=self.width - 184)
        self.line((92, self.height - 112), (self.width - 92, self.height - 112), BORDER, 2)
        self.text(FOOTER, 92, self.height - 78, F_FOOT, MUTED, max_width=self.width - 184)

    def rounded_rect(
        self,
        box: tuple[int, int, int, int],
        radius: int,
        fill: str,
        outline: str | None = None,
        width: int = 1,
    ) -> None:
        self.draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)
        x1, y1, x2, y2 = box
        stroke = f' stroke="{outline}" stroke-width="{width}"' if outline else ""
        self.svg.append(
            f'<rect x="{x1}" y="{y1}" width="{x2 - x1}" height="{y2 - y1}" rx="{radius}" ry="{radius}" fill="{fill}"{stroke}/>'
        )

    def line(self, start: tuple[int, int], end: tuple[int, int], color: str, width: int = 4) -> None:
        self.draw.line((*start, *end), fill=color, width=width)
        self.svg.append(
            f'<line x1="{start[0]}" y1="{start[1]}" x2="{end[0]}" y2="{end[1]}" stroke="{color}" stroke-width="{width}" stroke-linecap="round"/>'
        )

    def polygon(self, points: list[tuple[int, int]], fill: str) -> None:
        self.draw.polygon(points, fill=fill)
        pts = " ".join(f"{x},{y}" for x, y in points)
        self.svg.append(f'<polygon points="{pts}" fill="{fill}"/>')

    def text(
        self,
        text: str,
        x: int,
        y: int,
        fnt: ImageFont.ImageFont,
        fill: str,
        *,
        max_width: int,
        bold: bool = False,
        line_gap: int = 7,
    ) -> int:
        lines = wrap_lines(self.draw, text, max_width, fnt)
        line_height = fnt.size + line_gap
        for idx, line in enumerate(lines):
            py = y + idx * line_height
            self.draw.text((x, py), line, fill=fill, font=fnt)
            weight = "700" if bold else "400"
            self.svg.append(
                f'<text x="{x}" y="{py + fnt.size}" font-family="{SVG_FONT}" font-size="{fnt.size}" font-weight="{weight}" fill="{fill}">{escape(line)}</text>'
            )
        return y + len(lines) * line_height

    def card(
        self,
        box: tuple[int, int, int, int],
        title: str,
        body: str,
        accent: str,
        *,
        body_font: ImageFont.ImageFont = F_BODY,
        title_font: ImageFont.ImageFont = F_HEAD,
    ) -> None:
        x1, y1, x2, y2 = box
        pad = 28
        self.rounded_rect(box, 20, PANEL, BORDER, 2)
        self.rounded_rect((x1, y1, x2, y1 + 16), 9, accent)
        title_end = self.text(title, x1 + pad, y1 + 38, title_font, INK, bold=True, max_width=x2 - x1 - 2 * pad)
        self.text(body, x1 + pad, max(title_end + 14, y1 + 104), body_font, MUTED, max_width=x2 - x1 - 2 * pad)

    def arrow(self, start: tuple[int, int], end: tuple[int, int], color: str = ARROW) -> None:
        self.line(start, end, color, 6)
        x1, y1 = start
        x2, y2 = end
        if abs(x2 - x1) >= abs(y2 - y1):
            points = (
                [(x2, y2), (x2 - 28, y2 - 18), (x2 - 28, y2 + 18)]
                if x2 >= x1
                else [(x2, y2), (x2 + 28, y2 - 18), (x2 + 28, y2 + 18)]
            )
        else:
            points = (
                [(x2, y2), (x2 - 18, y2 - 28), (x2 + 18, y2 - 28)]
                if y2 >= y1
                else [(x2, y2), (x2 - 18, y2 + 28), (x2 + 18, y2 + 28)]
            )
        self.polygon(points, color)

    def save(self, stem: str) -> None:
        self.img.save(OUT / f"{stem}.png")
        self.svg.append("</svg>")
        svg_text = "\n".join(self.svg)
        (OUT / f"{stem}.svg").write_text(svg_text, encoding="utf-8")
        ET.fromstring(svg_text)


def pattern_matrix() -> None:
    g = Diagram(
        "Non-Learning Game Pattern Matrix",
        "Strong game feeling becomes Talvori learning value only after translation and gates.",
        height=2700,
    )
    games = [
        ("Minecraft", "Sandbox ownership\nExplore, build, survive\nTalvori: world possibility\nBlock: endless scope", GREEN),
        ("Roblox", "Modular experiences\nSocial variety\nTalvori: mini moments\nBlock: UGC/social drift", PURPLE),
        ("Block Blast", "Simple puzzle loop\nPlace, clear, retry\nTalvori: meaning puzzle\nBlock: no learning anchor", BLUE),
        ("Subway Surfers", "Fast action flow\nSwipe, dodge, collect\nTalvori: action moment\nBlock: endless pressure", TEAL),
        ("Candy Crush", "Level puzzle\nGoal, combo, retry\nTalvori: context puzzle\nBlock: booster/FOMO", YELLOW),
        ("Clash Royale", "Tactical duel\nDeck, timing, arena\nTalvori: small choice\nBlock: PvP/rank", RED),
        ("Honor of Kings", "Role teamplay\nMap, lane, mastery\nTalvori: word role\nBlock: team pressure", GRAY),
        ("Pokemon TCG Pocket", "Collection loop\nPack, card, deck\nTalvori: Codex discovery\nBlock: gacha/stamina", PURPLE),
    ]
    for i, (title, body, color) in enumerate(games):
        col = i % 4
        row = i // 4
        x = 120 + col * 810
        y = 340 + row * 600
        g.card((x, y, x + 690, y + 420), title, body, color, body_font=F_SMALL, title_font=font(30, True))
    g.card(
        (310, 1640, 1530, 2050),
        "Common safe pattern",
        "Clear action, small challenge, visible result, voluntary retry, growing ownership and safe exits.",
        GREEN,
        body_font=F_SMALL,
    )
    g.card(
        (1870, 1640, 3090, 2050),
        "Common danger pattern",
        "FOMO, gacha, rank, pay-to-progress, timers, social duty and mechanics without learning value.",
        RED,
        body_font=F_SMALL,
    )
    g.save("non_learning_game_pattern_matrix")


def curiosity_challenge_flow() -> None:
    g = Diagram(
        "Curiosity Challenge Flow Map",
        "The play loop must start with curiosity and end with safe learning feedback.",
    )
    steps = [
        ("Hook", "What is this?\nWhat fits here?", PURPLE),
        ("Tiny challenge", "Choose, place, dodge,\nmatch, explore.", BLUE),
        ("Meaning", "Sense, context,\noutcome, action.", TEAL),
        ("Feedback", "Visible result,\nnot BuildState.", GREEN),
        ("Exit", "Later, Codex,\nBacklog, Change.", YELLOW),
    ]
    xs = [180, 800, 1420, 2040, 2660]
    for x, (title, body, color) in zip(xs, steps):
        g.card((x, 440, x + 460, 780), title, body, color, body_font=F_SMALL)
    for x in xs[:-1]:
        g.arrow((x + 460, 610), (x + 620, 610))
    g.card(
        (240, 1050, 1530, 1440),
        "What keeps it playful",
        "The user acts before reading too much, sees feedback quickly, and can try again without shame.",
        GREEN,
        body_font=F_SMALL,
    )
    g.card(
        (1870, 1050, 3160, 1440),
        "What breaks it",
        "Questionnaire feeling, text wall, forced review, timer pressure, ranking and hidden monetization pressure.",
        RED,
        body_font=F_SMALL,
    )
    g.card(
        (640, 1740, 2760, 2010),
        "Talvori rule",
        "A learning moment is playable when curiosity drives a small safe action and the learning value appears as the consequence.",
        TEAL,
        body_font=F_SMALL,
    )
    g.save("curiosity_challenge_flow_map")


def session_hook_patterns() -> None:
    g = Diagram(
        "Session Hook Pattern Map",
        "One more round comes from clarity, curiosity and voluntary retry, not pressure.",
        height=2650,
    )
    hooks = [
        ("Short run", "Subway Surfers, Block Blast\nquick start and retry\nTalvori: micro moment", TEAL),
        ("Level goal", "Candy Crush\nclear board target\nTalvori: one sense goal", BLUE),
        ("Open idea", "Minecraft\nself-chosen next step\nTalvori: world hint", GREEN),
        ("Collection", "Pokemon TCG Pocket\nnew card curiosity\nTalvori: Codex discovery", PURPLE),
        ("Tactical choice", "Clash Royale\none decision matters\nTalvori: Choice Fork", RED),
        ("Role clarity", "Honor of Kings\nknow your role\nTalvori: word role", GRAY),
    ]
    for i, (title, body, color) in enumerate(hooks):
        col = i % 3
        row = i // 3
        x = 190 + col * 1030
        y = 380 + row * 560
        g.card((x, y, x + 840, y + 370), title, body, color, body_font=F_SMALL)
    g.card(
        (430, 1680, 1440, 2050),
        "Safe hook",
        "I want to see one more meaning, context or discovery because it is interesting.",
        GREEN,
        body_font=F_SMALL,
    )
    g.card(
        (1960, 1680, 2970, 2050),
        "Unsafe hook",
        "I must come back or I lose rank, packs, streak, event rewards or social standing.",
        RED,
        body_font=F_SMALL,
    )
    g.save("session_hook_pattern_map")


def safe_vs_dangerous() -> None:
    g = Diagram(
        "Safe Vs Dangerous Game Patterns For Talvori",
        "Play-first learning keeps the fun, but removes pressure and monetization traps.",
        height=2600,
    )
    safe = [
        "Meaning Puzzle",
        "Context Door",
        "Container Hunt",
        "Action Moment",
        "Codex Discovery",
        "Calm Retry",
        "Choice Fork",
        "World Hint",
    ]
    danger = [
        "FOMO event",
        "Gacha pull",
        "Pay-to-progress",
        "PvP ranking",
        "Clan duty",
        "Timer pressure",
        "Booster frustration",
        "Mechanic without learning",
    ]
    for i, item in enumerate(safe):
        y = 360 + i * 205
        g.card((170, y, 1440, y + 145), item, "Allowed only as pressure-free learning play.", GREEN, body_font=F_TINY, title_font=font(27, True))
    for i, item in enumerate(danger):
        y = 360 + i * 205
        g.card((1960, y, 3230, y + 145), item, "Blocked for MVP and not a productive mechanic.", RED, body_font=F_TINY, title_font=font(27, True))
    g.card(
        (760, 2150, 2640, 2360),
        "Boundary",
        "A pattern is safe only if it names learning value, preserves Later/Codex/Backlog/ContextCard, and cannot create BuildState or pressure.",
        YELLOW,
        body_font=F_SMALL,
    )
    g.save("safe_vs_dangerous_game_patterns_for_talvori")


def translation_matrix() -> None:
    g = Diagram(
        "Talvori Play-First Translation Matrix",
        "Game pattern -> Talvori play moment -> learning value -> blocked traps.",
        height=2700,
    )
    rows = [
        ("Sandbox", "World Hint", "Theme and meaning orientation", "No auto-build"),
        ("Puzzle", "Meaning Puzzle", "Sense and context", "No quiz skin"),
        ("Runner", "Action Moment", "Verb/action understanding", "No timer pressure"),
        ("Match level", "Context Door", "Goal-based context choice", "No booster FOMO"),
        ("Card collection", "Codex Discovery", "Recall and ownership", "No gacha"),
        ("Tactical duel", "Choice Fork", "Outcome/fallback judgment", "No PvP/rank"),
        ("MOBA role", "Word Role", "Word type clarity", "No team pressure"),
        ("Social variety", "Mini experience", "Different safe play moments", "No UGC/social drift"),
    ]
    headers = ["Pattern", "Talvori moment", "Learning value", "Blocked trap"]
    xs = [120, 880, 1660, 2440]
    widths = [640, 660, 660, 720]
    for x, w, h in zip(xs, widths, headers):
        g.card((x, 330, x + w, 470), h, "", GRAY, body_font=F_TINY, title_font=font(27, True))
    for i, row in enumerate(rows):
        y = 540 + i * 215
        colors = [PURPLE, BLUE, GREEN, RED]
        for x, w, text, color in zip(xs, widths, row, colors):
            g.card((x, y, x + w, y + 145), text, "", color, body_font=F_TINY, title_font=font(25, True))
    g.card(
        (520, 2260, 2880, 2450),
        "Implementation prompt rule",
        "Every future code slice must name the game pattern, the Talvori play moment, the learning value and the blocked pressure traps.",
        TEAL,
        body_font=F_SMALL,
    )
    g.save("talvori_play_first_translation_matrix")


def contact_sheet() -> None:
    files = [
        "non_learning_game_pattern_matrix.png",
        "curiosity_challenge_flow_map.png",
        "session_hook_pattern_map.png",
        "safe_vs_dangerous_game_patterns_for_talvori.png",
        "talvori_play_first_translation_matrix.png",
    ]
    cw, ch = 4300, 4500
    img = Image.new("RGB", (cw, ch), BG)
    draw = ImageDraw.Draw(img)
    svg: list[str] = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{cw}" height="{ch}" viewBox="0 0 {cw} {ch}">',
        f'<rect width="{cw}" height="{ch}" fill="{BG}"/>',
    ]
    title = "M16-AL Non-Learning Game Patterns Contact Sheet"
    draw.text((120, 90), title, fill=INK, font=F_TITLE)
    svg.append(f'<text x="120" y="{90 + F_TITLE.size}" font-family="{SVG_FONT}" font-size="{F_TITLE.size}" font-weight="700" fill="{INK}">{escape(title)}</text>')
    slots = [(160, 260), (2200, 260), (160, 1620), (2200, 1620), (1180, 2980)]
    thumb_w, thumb_h = 1840, 1050
    for name, (x, y) in zip(files, slots):
        src = Image.open(OUT / name)
        src.thumbnail((thumb_w, thumb_h), Image.Resampling.LANCZOS)
        frame = (x - 24, y - 24, x + thumb_w + 24, y + thumb_h + 112)
        draw.rounded_rectangle(frame, radius=24, fill=PANEL, outline=BORDER, width=2)
        svg.append(
            f'<rect x="{frame[0]}" y="{frame[1]}" width="{frame[2]-frame[0]}" height="{frame[3]-frame[1]}" rx="24" ry="24" fill="{PANEL}" stroke="{BORDER}" stroke-width="2"/>'
        )
        px = x + (thumb_w - src.width) // 2
        py = y + (thumb_h - src.height) // 2
        img.paste(src, (px, py))
        draw.text((x, y + thumb_h + 34), name, fill=MUTED, font=F_SMALL)
        svg.append(f'<text x="{x}" y="{y + thumb_h + 34 + F_SMALL.size}" font-family="{SVG_FONT}" font-size="{F_SMALL.size}" fill="{MUTED}">{escape(name)}</text>')
    footer = "docs-only contact sheet / no app screen / no screenshot / no asset / PNG plus SVG"
    draw.line((120, ch - 150, cw - 120, ch - 150), fill=BORDER, width=2)
    draw.text((120, ch - 105), footer, fill=MUTED, font=F_FOOT)
    svg.append(f'<line x1="120" y1="{ch - 150}" x2="{cw - 120}" y2="{ch - 150}" stroke="{BORDER}" stroke-width="2"/>')
    svg.append(f'<text x="120" y="{ch - 105 + F_FOOT.size}" font-family="{SVG_FONT}" font-size="{F_FOOT.size}" fill="{MUTED}">{escape(footer)}</text>')
    svg.append("</svg>")
    img.save(OUT / "00_contact_sheet.png")
    svg_text = "\n".join(svg)
    (OUT / "00_contact_sheet.svg").write_text(svg_text, encoding="utf-8")
    ET.fromstring(svg_text)


def main() -> None:
    pattern_matrix()
    curiosity_challenge_flow()
    session_hook_patterns()
    safe_vs_dangerous()
    translation_matrix()
    contact_sheet()


if __name__ == "__main__":
    main()
