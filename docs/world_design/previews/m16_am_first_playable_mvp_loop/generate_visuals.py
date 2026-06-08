from __future__ import annotations

from dataclasses import dataclass
from html import escape
from pathlib import Path
import xml.etree.ElementTree as ET

from PIL import Image, ImageDraw, ImageFont


OUT = Path(__file__).resolve().parent

BG = "#f8f9f4"
PANEL = "#ffffff"
INK = "#1e2b28"
MUTED = "#65726d"
BORDER = "#d7dfd8"
GREEN = "#69ad78"
BLUE = "#67a7cb"
TEAL = "#59b7aa"
YELLOW = "#d6b95a"
RED = "#d96d67"
PURPLE = "#8979c7"
GRAY = "#8f9d98"
ARROW = "#93a39c"
SVG_FONT = "Arial, Helvetica, sans-serif"
FOOTER = (
    "documentation gate only / no implementation / no app integration / "
    "no SRS write / no BuildState / no frame_started"
)


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    candidates = [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf"
        if bold
        else "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/Library/Fonts/Arial Bold.ttf" if bold else "/Library/Fonts/Arial.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
        if bold
        else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    ]
    for candidate in candidates:
        if Path(candidate).exists():
            return ImageFont.truetype(candidate, size=size)
    return ImageFont.load_default()


F_TITLE = font(62, True)
F_SUB = font(29)
F_HEAD = font(31, True)
F_BODY = font(24)
F_SMALL = font(20)
F_TINY = font(18)
F_FOOT = font(18)


def text_width(draw: ImageDraw.ImageDraw, text: str, fnt: ImageFont.ImageFont) -> int:
    box = draw.textbbox((0, 0), text, font=fnt)
    return box[2] - box[0]


def split_long_word(
    draw: ImageDraw.ImageDraw, word: str, width: int, fnt: ImageFont.ImageFont
) -> list[str]:
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


def wrap_lines(
    draw: ImageDraw.ImageDraw, text: str, width: int, fnt: ImageFont.ImageFont
) -> list[str]:
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
    width: int = 3400
    height: int = 2550

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
        title_end = self.text(
            title, x1 + pad, y1 + 38, title_font, INK, bold=True, max_width=x2 - x1 - 2 * pad
        )
        self.text(body, x1 + pad, max(title_end + 14, y1 + 108), body_font, MUTED, max_width=x2 - x1 - 2 * pad)

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


def first_playable_loop_flow() -> None:
    g = Diagram(
        "First Playable MVP Loop Flow",
        "The first minute is a Bank meaning puzzle: play action first, learning as the result.",
    )
    steps = [
        ("Start", "User starts a tiny optional play moment.\nNo daily duty.", PURPLE),
        ("Situation", "Tali/Vori sets a curious Bank scene.\nNo quiz framing.", BLUE),
        ("Context Door", "Choose the meaning door:\nbench / finance / river edge.", TEAL),
        ("Feedback", "ContextCard or Codex Discovery.\nNo score pressure.", GREEN),
        ("Safe Exit", "Later, Codex, Backlog, Change.\nEnd without duty.", YELLOW),
    ]
    for idx, (title, body, color) in enumerate(steps):
        x = 120 + idx * 650
        g.card((x, 380, x + 510, 720), title, body, color, body_font=F_SMALL)
        if idx < len(steps) - 1:
            g.arrow((x + 520, 550), (x + 625, 550))
    g.card(
        (260, 1020, 1540, 1390),
        "Allowed result",
        "Small meaning clarity, Codex Discovery, ContextCard or tiny World Hint as preview/fallback.",
        GREEN,
        body_font=F_SMALL,
    )
    g.card(
        (1860, 1020, 3140, 1390),
        "Blocked result",
        "No BuildState, placement, asset, SRS write, route, app integration, timer or XP grind.",
        RED,
        body_font=F_SMALL,
    )
    g.card(
        (710, 1690, 2690, 2040),
        "Loop decision",
        "Best first MVP loop: Meaning Puzzle + Context Door with Bank. It proves play-first semantics without opening build, asset, water, social or sensitive scope.",
        TEAL,
        body_font=F_SMALL,
    )
    g.save("first_playable_loop_flow")


def play_first_check() -> None:
    g = Diagram(
        "Play-First Check For MVP Loop",
        "Every answer must describe a game moment before it describes learning value.",
        height=2700,
    )
    items = [
        ("Game moment", "Choose the right meaning door in a tiny scene.", PURPLE),
        ("Curiosity", "Same word, three possible worlds. Which one reacts?", BLUE),
        ("Challenge", "Read context, infer sense, choose safely.", TEAL),
        ("Reward feel", "Meaning lights up; Codex becomes clearer.", GREEN),
        ("Learning value", "Sense and context before world reaction.", GREEN),
        ("Not school", "No vocabulary test, no worksheet, no text wall.", YELLOW),
        ("Pressure blocked", "No timer, streak, XP grind, FOMO, rank or forced review.", RED),
        ("Safe exits", "Later, Codex, Backlog, ContextCard, Change.", GRAY),
    ]
    for idx, (title, body, color) in enumerate(items):
        col = idx % 4
        row = idx // 4
        x = 130 + col * 800
        y = 360 + row * 520
        g.card((x, y, x + 660, y + 340), title, body, color, body_font=F_SMALL)
    g.card(
        (430, 1580, 2970, 2010),
        "Implementation-prompt rule",
        "Any later code prompt must name: pattern, Talvori play moment, learning value, blocked traps, safe exits and unchanged stop rules before creating files.",
        TEAL,
        body_font=F_SMALL,
    )
    g.save("play_first_check_for_mvp_loop")


def first_minute_sequence() -> None:
    g = Diagram(
        "First Minute Sequence",
        "Sixty seconds of play-first meaning clarity with no forced follow-up.",
        height=2750,
    )
    rows = [
        ("0-5s", "Start", "User opens tiny optional moment.\nCan leave with no loss.", PURPLE),
        ("5-12s", "Scene", "Tali/Vori gives one Bank scene.\nCompanion stays optional.", BLUE),
        ("12-25s", "Doors", "Bench / finance / river edge.\nContext beats surface.", TEAL),
        ("25-40s", "Choice", "User picks a door.\nChange and Later stay visible.", GREEN),
        ("40-50s", "Feedback", "Meaning is clarified.\nNo score or SRS write.", YELLOW),
        ("50-58s", "Signal", "Codex Discovery or World Hint.\nPreview/fallback only.", GREEN),
        ("58-60s", "Exit", "One more, Codex, Later or end.\nNo duty.", GRAY),
    ]
    for idx, (time, title, body, color) in enumerate(rows):
        y = 340 + idx * 260
        g.card((160, y, 520, y + 170), time, title, color, body_font=F_SMALL, title_font=font(28, True))
        g.card((680, y, 3180, y + 170), title, body, color, body_font=F_SMALL, title_font=font(28, True))
        if idx < len(rows) - 1:
            g.arrow((500, y + 176), (500, y + 248))
    g.save("first_minute_sequence")


def game_moment_mapping() -> None:
    g = Diagram(
        "Game Moment To Learning Mapping",
        "The loop is playable only if each action has learning value and safe defaults.",
        height=2850,
    )
    headers = [("Play action", GRAY), ("Learning value", BLUE), ("Outcome", TEAL), ("Blocked", RED)]
    for idx, (title, color) in enumerate(headers):
        x = 120 + idx * 810
        g.card((x, 330, x + 690, 460), title, "", color, body_font=F_TINY)
    rows = [
        ("Choose door", "Sense in context", "NeedsUserChoice -> ContextCard", "Default world object"),
        ("Confirm meaning", "Multi-sense clarity", "Codex Discovery", "SRS write / score pressure"),
        ("Correct door", "Error as information", "Calm Retry", "Shame / world loss"),
        ("View World Hint", "World as possibility", "Preview/fallback", "Placement / BuildState"),
        ("End round", "Voluntary flow", "Later / end", "Forced streak / timer"),
    ]
    for r, row in enumerate(rows):
        y = 560 + r * 350
        for c, text in enumerate(row):
            x = 120 + c * 810
            color = [PURPLE, BLUE, TEAL, RED][c]
            g.card((x, y, x + 690, y + 230), text, "", color, body_font=F_TINY, title_font=font(27, True))
    g.card(
        (510, 2360, 2890, 2590),
        "Mapping rule",
        "A later implementation may not create a task unless it can fill all four columns: play action, learning value, safe outcome and blocked trap.",
        GREEN,
        body_font=F_SMALL,
    )
    g.save("game_moment_to_learning_mapping")


def allowed_vs_blocked() -> None:
    g = Diagram(
        "Allowed Vs Blocked MVP Loop Scope",
        "M16-AM decides the first loop shape, but keeps implementation and production mechanics blocked.",
        height=2650,
    )
    allowed = [
        "Meaning Puzzle",
        "Context Door",
        "Bank example",
        "Tali/Vori optional hint",
        "ContextCard",
        "Codex Discovery",
        "World Hint as preview",
        "Later / Codex / Backlog / Change",
    ]
    blocked = [
        "Flutter/Dart code",
        "Route or new page",
        "Persistence / DB writes",
        "SRS or word_progress write",
        "Auto placement",
        "BuildState / frame_started",
        "Assets under assets/",
        "Timer / XP / social / gacha",
    ]
    for idx, text in enumerate(allowed):
        y = 350 + idx * 210
        g.card((160, y, 1510, y + 135), text, "Allowed only as documentation/planning.", GREEN, body_font=F_TINY, title_font=font(26, True))
    for idx, text in enumerate(blocked):
        y = 350 + idx * 210
        g.card((1890, y, 3240, y + 135), text, "Blocked until separate explicit gate.", RED, body_font=F_TINY, title_font=font(26, True))
    g.card(
        (580, 2130, 2820, 2350),
        "Hard boundary",
        "The first MVP loop may feel playable in documentation, but it remains a gate. No productive mechanic is released.",
        YELLOW,
        body_font=F_SMALL,
    )
    g.save("allowed_vs_blocked_mvp_loop")


def contact_sheet() -> None:
    stems = [
        "first_playable_loop_flow",
        "play_first_check_for_mvp_loop",
        "first_minute_sequence",
        "game_moment_to_learning_mapping",
        "allowed_vs_blocked_mvp_loop",
    ]
    width, height = 4300, 4500
    img = Image.new("RGB", (width, height), BG)
    draw = ImageDraw.Draw(img)
    draw.text((120, 90), "M16-AM First Playable MVP Loop Contact Sheet", fill=INK, font=font(56, True))
    positions = [(130, 260), (2200, 260), (130, 1480), (2200, 1480), (1120, 2700)]
    thumb_w, thumb_h = 1720, 950
    svg = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">',
        f'<rect width="{width}" height="{height}" fill="{BG}"/>',
        f'<text x="120" y="150" font-family="{SVG_FONT}" font-size="56" font-weight="700" fill="{INK}">M16-AM First Playable MVP Loop Contact Sheet</text>',
    ]
    for stem, (x, y) in zip(stems, positions):
        draw.rounded_rectangle((x, y, x + thumb_w + 100, y + thumb_h + 150), radius=24, fill=PANEL, outline=BORDER, width=2)
        source = Image.open(OUT / f"{stem}.png").convert("RGB")
        source.thumbnail((thumb_w, thumb_h))
        px = x + 50 + (thumb_w - source.width) // 2
        py = y + 45
        img.paste(source, (px, py))
        draw.text((x + 50, y + thumb_h + 82), f"{stem}.png", fill=MUTED, font=F_SMALL)
        svg.append(
            f'<rect x="{x}" y="{y}" width="{thumb_w + 100}" height="{thumb_h + 150}" rx="24" ry="24" fill="{PANEL}" stroke="{BORDER}" stroke-width="2"/>'
        )
        svg.append(
            f'<image href="{stem}.png" x="{px}" y="{py}" width="{source.width}" height="{source.height}"/>'
        )
        svg.append(
            f'<text x="{x + 50}" y="{y + thumb_h + 106}" font-family="{SVG_FONT}" font-size="20" fill="{MUTED}">{escape(stem)}.png</text>'
        )
    draw.line((120, height - 155, width - 120, height - 155), fill=BORDER, width=2)
    draw.text((120, height - 105), "docs-only contact sheet / no app screen / no screenshot / PNG plus SVG", fill=MUTED, font=F_FOOT)
    svg.append(f'<line x1="120" y1="{height - 155}" x2="{width - 120}" y2="{height - 155}" stroke="{BORDER}" stroke-width="2"/>')
    svg.append(
        f'<text x="120" y="{height - 82}" font-family="{SVG_FONT}" font-size="18" fill="{MUTED}">docs-only contact sheet / no app screen / no screenshot / PNG plus SVG</text>'
    )
    svg.append("</svg>")
    img.save(OUT / "00_contact_sheet.png")
    svg_text = "\n".join(svg)
    (OUT / "00_contact_sheet.svg").write_text(svg_text, encoding="utf-8")
    ET.fromstring(svg_text)


def main() -> None:
    first_playable_loop_flow()
    play_first_check()
    first_minute_sequence()
    game_moment_mapping()
    allowed_vs_blocked()
    contact_sheet()


if __name__ == "__main__":
    main()
