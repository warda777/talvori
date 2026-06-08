from __future__ import annotations

from dataclasses import dataclass
from html import escape
from pathlib import Path
import xml.etree.ElementTree as ET

from PIL import Image, ImageDraw, ImageFont


OUT = Path(__file__).resolve().parent

W = 3200
H = 2350
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
    "documentation research prep only / no implementation / no app integration / "
    "no auto placement / no BuildState / no frame_started"
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
F_HEAD = font(34, True)
F_BODY = font(25)
F_SMALL = font(21)
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

    def pill(self, box: tuple[int, int, int, int], text: str, color: str) -> None:
        x1, y1, x2, y2 = box
        self.rounded_rect(box, 28, color, None, 0)
        self.text(text, x1 + 26, y1 + 17, F_SMALL, "#ffffff", bold=True, max_width=x2 - x1 - 52)

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


def play_first_doctrine() -> None:
    g = Diagram(
        "Play-First Learning Doctrine",
        "Talvori is a game whose play actions create learning value.",
    )
    xs = [150, 660, 1170, 1680, 2190, 2700]
    items = [
        ("Play", "Curiosity, challenge, discovery, choice.", PURPLE),
        ("Meaning", "Sense and context become visible.", BLUE),
        ("Choice", "User can confirm, change or choose Later.", TEAL),
        ("Feedback", "Small safe response, no pressure.", GREEN),
        ("World", "Possibility, not placement.", YELLOW),
        ("Learning", "Benefit happens through play.", RED),
    ]
    for x, (title, body, color) in zip(xs, items):
        g.card((x, 370, x + 360, 720), title, body, color, body_font=F_SMALL)
    for x in xs[:-1]:
        g.arrow((x + 360, 545), (x + 500, 545))
    g.card(
        (210, 950, 1480, 1330),
        "Not a vocabulary trainer with game decoration",
        "Every exercise needs a play moment. Every play moment needs a learning anchor. The user should feel curiosity first, not homework first.",
        GREEN,
        body_font=F_SMALL,
    )
    g.card(
        (1720, 950, 2990, 1330),
        "Hard stop rules",
        "No auto placement, no BuildState, no frame_started, no persistence, no timer pressure, no streak guilt, no forced review.",
        RED,
        body_font=F_SMALL,
    )
    checks = [
        "Game moment?",
        "Curiosity?",
        "Small challenge?",
        "Rewarding feedback?",
        "Learning value?",
        "No exercise feeling?",
        "No pressure?",
        "Safe exits?",
    ]
    x = 350
    y = 1590
    for idx, label in enumerate(checks):
        g.pill((x, y, x + 570, y + 72), label, [PURPLE, BLUE, TEAL, GREEN][idx % 4])
        x += 620
        if idx == 3:
            x = 350
            y = 1710
    g.save("play_first_doctrine")


def game_pattern_to_learning_bridge() -> None:
    g = Diagram(
        "Game Pattern To Learning Bridge",
        "Game patterns become Talvori learning moments only after safety and anti-pressure translation.",
    )
    left = [
        ("Puzzle", "solve a pattern"),
        ("Explorer path", "find where meaning fits"),
        ("Container hunt", "locate a small object"),
        ("Action beat", "perform or imagine an action"),
        ("Collection", "discover a codex entry"),
    ]
    right = [
        ("Sense", "understand meaning"),
        ("Context", "apply a sentence"),
        ("Outcome", "choose safe representation"),
        ("Verb", "learn action use"),
        ("Recall", "remember through discovery"),
    ]
    for i, (title, body) in enumerate(left):
        y = 360 + i * 260
        g.card((140, y, 770, y + 185), title, body, PURPLE, body_font=F_SMALL)
    for i, (title, body) in enumerate(right):
        y = 360 + i * 260
        g.card((2430, y, 3060, y + 185), title, body, GREEN, body_font=F_SMALL)
    center = [
        ("Translate", "What is the Talvori play moment?"),
        ("Guard", "Safety, sense, clutter, pressure."),
        ("Exit", "Later, Codex, Backlog, ContextCard."),
    ]
    for i, (title, body) in enumerate(center):
        y = 500 + i * 360
        g.card((1160, y, 2040, y + 235), title, body, [BLUE, RED, TEAL][i], body_font=F_SMALL)
    for i in range(5):
        y = 452 + i * 260
        g.arrow((770, y), (1160, 610 if i < 2 else 970 if i < 4 else 1330))
        g.arrow((2040, 610 if i < 2 else 970 if i < 4 else 1330), (2430, y))
    g.card(
        (520, 1850, 2680, 2070),
        "Bridge rule",
        "No game pattern is copied directly. It must become a pressure-free meaning, choice or discovery moment that preserves all existing Talvori gates.",
        YELLOW,
        body_font=F_SMALL,
    )
    g.save("game_pattern_to_learning_bridge")


def game_benchmark_pattern_matrix() -> None:
    g = Diagram(
        "Game Benchmark Pattern Matrix",
        "Non-learning games are research candidates for play feeling, not mechanics to copy.",
        height=2500,
    )
    columns = [
        ("Sandbox", "Minecraft, Roblox\nWorld, creation, social variety\nTalvori: discovery and ownership\nAvoid: endless scope, unsafe UGC", GREEN),
        ("Puzzle", "Block Blast, Candy Crush\nPattern, level goal, quick retry\nTalvori: meaning puzzle\nAvoid: grind, pay/FOMO", BLUE),
        ("Action", "Subway Surfers\nFlow, reflex, short round\nTalvori: action moment\nAvoid: timer stress", TEAL),
        ("Progression", "Clash of Clans\nBase, choices, long goals\nTalvori: world possibility\nAvoid: timers, war pressure", YELLOW),
        ("Competition", "Clash Royale, Honor of Kings\nSkill, rank, team role\nTalvori: later fairness research\nAvoid: ranking shame", RED),
        ("Collection", "Pokemon TCG Pocket\nCollection, deck, surprise\nTalvori: Codex discovery\nAvoid: gacha and FOMO", PURPLE),
    ]
    for i, (title, body, color) in enumerate(columns):
        x = 120 + i * 505
        g.card((x, 340, x + 430, 1030), title, body, color, body_font=F_SMALL, title_font=font(30, True))
    g.card(
        (180, 1260, 1510, 1670),
        "MVP relevant patterns",
        "Meaning Puzzle, Context Door, Codex Discovery, Calm Comeback and Choice Fork can support play-first learning without social or economy scope.",
        GREEN,
        body_font=F_SMALL,
    )
    g.card(
        (1690, 1260, 3020, 1670),
        "Post-MVP or blocked patterns",
        "Competitive ranking, clans, gacha, timers, economy and social pressure remain research-only until their own gates exist.",
        RED,
        body_font=F_SMALL,
    )
    g.card(
        (460, 1920, 2740, 2170),
        "Research prep status",
        "M16-AK names patterns and questions. It does not complete deep research for all games, and it does not approve runtime mechanics.",
        TEAL,
        body_font=F_SMALL,
    )
    g.save("game_benchmark_pattern_matrix")


def talvori_play_moment_types() -> None:
    g = Diagram(
        "Talvori Play Moment Types",
        "MVP-near play moments turn learning into choice, discovery and safe feedback.",
        height=2550,
    )
    types = [
        ("Meaning Puzzle", "Resolve sense.\nExample: Bank meaning.\nNo default building.", BLUE),
        ("Context Door", "Sentence opens direction.\nExample: home vs coast.\nNo route.", TEAL),
        ("Micro Quest", "Tali/Vori asks optional question.\nNo pressure.", PURPLE),
        ("Container Hunt", "Find where tiny item belongs.\nNo island clutter.", GREEN),
        ("Action Moment", "Verb becomes action idea.\nNo forced quest.", YELLOW),
        ("World Hint", "Small safe response.\nNo BuildState.", RED),
        ("Codex Discovery", "Collection with explanation.\nNo 20k cards.", BLUE),
        ("Calm Comeback", "Return without guilt.\nNo streak loss.", TEAL),
        ("Choice Fork", "Confirm, Change, Later.\nNo Pflichtreview.", PURPLE),
        ("Tiny Mystery", "Small curiosity hook.\nNo hidden required object.", GREEN),
    ]
    for i, (title, body, color) in enumerate(types):
        col = i % 5
        row = i // 5
        x = 130 + col * 600
        y = 340 + row * 650
        g.card((x, y, x + 500, y + 465), title, body, color, body_font=F_SMALL, title_font=font(29, True))
    g.card(
        (420, 1760, 2780, 2090),
        "Every play moment needs exits",
        "Later, Codex, Backlog, ContextCard, Hide and SensitiveGated are part of the play design. They are not failure states.",
        YELLOW,
        body_font=F_SMALL,
    )
    g.save("talvori_play_moment_types")


def playtest_questions() -> None:
    g = Diagram(
        "Playtest Questions For The First Playable Loop",
        "Future MVP tests must check play feeling before celebrating learning mechanics.",
        height=2500,
    )
    questions = [
        ("Play feeling", "Did this feel like playing?"),
        ("Learning moment", "When did you notice you learned?"),
        ("Curiosity", "Did you want to continue voluntarily?"),
        ("School feeling", "What felt boring or like homework?"),
        ("Stress", "Did anything feel forced or stressful?"),
        ("World logic", "Did you understand why the world reacted?"),
        ("Errors", "Did mistakes feel safe?"),
        ("Exit", "Were Later, Codex or Backlog easy to find?"),
    ]
    for i, (title, body) in enumerate(questions):
        col = i % 4
        row = i // 4
        x = 180 + col * 740
        y = 390 + row * 410
        g.card((x, y, x + 610, y + 300), title, body, [GREEN, BLUE, TEAL, PURPLE][col], body_font=F_SMALL)
    g.card(
        (250, 1420, 1460, 1790),
        "Pass signal",
        "A user can explain the game moment, feels safe after errors, and wants one more tiny discovery without pressure.",
        GREEN,
        body_font=F_SMALL,
    )
    g.card(
        (1740, 1420, 2950, 1790),
        "Fail signal",
        "The screen feels like quiz work, text reading, compulsory review, XP chasing, timer stress or world confusion.",
        RED,
        body_font=F_SMALL,
    )
    g.card(
        (480, 2050, 2720, 2220),
        "No implementation release",
        "Playtest criteria are planning checks. They do not create analytics, persistence, tests, routes or runtime mechanics.",
        YELLOW,
        body_font=F_SMALL,
    )
    g.save("playtest_questions")


def contact_sheet() -> None:
    files = [
        "play_first_doctrine.png",
        "game_pattern_to_learning_bridge.png",
        "game_benchmark_pattern_matrix.png",
        "talvori_play_moment_types.png",
        "playtest_questions.png",
    ]
    cw, ch = 4100, 4300
    img = Image.new("RGB", (cw, ch), BG)
    draw = ImageDraw.Draw(img)
    svg: list[str] = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{cw}" height="{ch}" viewBox="0 0 {cw} {ch}">',
        f'<rect width="{cw}" height="{ch}" fill="{BG}"/>',
    ]
    title = "M16-AK Play-First Learning Visual Contact Sheet"
    draw.text((120, 90), title, fill=INK, font=F_TITLE)
    svg.append(f'<text x="120" y="{90 + F_TITLE.size}" font-family="{SVG_FONT}" font-size="{F_TITLE.size}" font-weight="700" fill="{INK}">{escape(title)}</text>')
    slots = [
        (160, 260),
        (2110, 260),
        (160, 1560),
        (2110, 1560),
        (1135, 2860),
    ]
    thumb_w, thumb_h = 1760, 1000
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
        svg.append(
            f'<text x="{x}" y="{y + thumb_h + 72 + F_TINY.size}" font-family="{SVG_FONT}" font-size="{F_TINY.size}" fill="{MUTED}">PNG preview plus SVG source generated from the same layout.</text>'
        )
    footer = "docs-only contact sheet / no app screen / no screenshot / no asset / all diagrams checked for containment"
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
    play_first_doctrine()
    game_pattern_to_learning_bridge()
    game_benchmark_pattern_matrix()
    talvori_play_moment_types()
    playtest_questions()
    contact_sheet()


if __name__ == "__main__":
    main()
