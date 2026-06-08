from __future__ import annotations

from dataclasses import dataclass
from html import escape
from pathlib import Path
import xml.etree.ElementTree as ET

from PIL import Image, ImageDraw, ImageFont


OUT = Path(__file__).resolve().parent

W = 3000
H = 2200
BG = "#f8f9f4"
PANEL = "#ffffff"
INK = "#1f2c2a"
MUTED = "#66736d"
BORDER = "#d8e0d8"
ARROW = "#95a59f"
GREEN = "#68ad7a"
BLUE = "#68a6ca"
TEAL = "#5bb8aa"
YELLOW = "#d7ba59"
RED = "#d86f68"
PURPLE = "#8977c7"
GRAY = "#94a09b"
SVG_FONT = "Arial, Helvetica, sans-serif"
FOOTER = (
    "documentation research preview only / no implementation / no analytics / "
    "no push retention / no SRS or word_progress write / no BuildState / no frame_started"
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


F_TITLE = font(64, True)
F_SUB = font(31)
F_HEAD = font(34, True)
F_BODY = font(25)
F_SMALL = font(22)
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
        self.text(self.subtitle, 92, 176, F_SUB, MUTED, max_width=self.width - 184)
        self.line((92, self.height - 110), (self.width - 92, self.height - 110), BORDER, 2)
        self.text(FOOTER, 92, self.height - 76, F_FOOT, MUTED, max_width=self.width - 184)

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

    def label(self, box: tuple[int, int, int, int], text: str, color: str) -> None:
        x1, y1, x2, y2 = box
        self.rounded_rect(box, 22, color, color, 1)
        self.text(text, x1 + 22, y1 + 10, F_SMALL, "#ffffff", bold=True, max_width=x2 - x1 - 44)

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


def benchmark_matrix() -> None:
    g = Diagram(
        "Habit And Motivation Benchmark Matrix",
        "Research compares principles. Talvori keeps learning quality above retention pressure.",
    )
    entries = [
        ("Duolingo", "XP, streaks, daily goals, leagues, lessons.\nValue: easy habit and visible progress.\nRisk: FOMO, XP chase, league pressure.", GREEN),
        ("Brilliant", "Learn by doing, visual problems, direct feedback.\nValue: meaning through action.\nRisk: cognitive load if overused.", BLUE),
        ("Quizlet", "Flashcards, Learn, Test, Progress.\nValue: recall and user control.\nRisk: mass review and shallow cramming.", TEAL),
        ("Anki / Recall", "Spacing and retrieval practice.\nValue: long-term memory.\nRisk: review debt and SRS mutation.", PURPLE),
    ]
    x_positions = [130, 850, 1570, 2290]
    for x, (title, body, color) in zip(x_positions, entries):
        g.card((x, 350, x + 570, 820), title, body, color, body_font=F_SMALL)
    g.card(
        (180, 1040, 1370, 1450),
        "What Talvori can borrow",
        "Micro sessions, quick feedback, interactive meaning, recall moments, calm progress, user control, and measured learning quality.",
        YELLOW,
    )
    g.card(
        (1630, 1040, 2820, 1450),
        "What Talvori must not copy",
        "Streak guilt, push pressure, leaderboards, XP grinding, mandatory reviews, sensitive retention triggers, or analytics without privacy gates.",
        RED,
    )
    g.arrow((1370, 1245), (1630, 1245))
    g.card(
        (520, 1640, 2480, 1900),
        "MVP decision",
        "Use pressure-free learning moments and optional review. Block streak loss, leaderboard ranking, push retention, SRS writes, analytics, BuildState and frame_started.",
        GREEN,
        body_font=F_SMALL,
    )
    g.save("habit_motivation_benchmark_matrix")


def pressure_free_principles() -> None:
    g = Diagram(
        "Pressure-Free Retention Principles",
        "Habit supports voluntary return. It must never create guilt, loss anxiety or sensitive pressure.",
    )
    steps = [
        ("Learn", "Short voluntary learning moment.", GREEN),
        ("Gentle signal", "Small feedback, no build or persistence.", BLUE),
        ("Optional review", "Only if budget and relevance allow.", TEAL),
        ("Later allowed", "Skipping review has no penalty.", YELLOW),
        ("Calm return", "Pause is neutral, world does not decay.", PURPLE),
    ]
    x = 130
    for title, body, color in steps:
        g.card((x, 410, x + 440, 720), title, body, color, body_font=F_SMALL)
        if x < 2210:
            g.arrow((x + 440, 565), (x + 520, 565))
        x += 560
    blocked = [
        ("No streak guilt", "No loss message or duty chain."),
        ("No FOMO", "No countdown, timer, or pressure push."),
        ("No sensitive trigger", "Sensitive words never drive retention."),
        ("No forced review", "No decision after every word."),
        ("No world penalty", "No ruins, decay or punishment."),
        ("No analytics gate bypass", "Metrics stay privacy-gated."),
    ]
    cols = [190, 1040, 1890]
    ys = [1000, 1330]
    idx = 0
    for y in ys:
        for cx in cols:
            title, body = blocked[idx]
            g.card((cx, y, cx + 720, y + 250), title, body, RED, body_font=F_SMALL)
            idx += 1
    g.save("pressure_free_retention_principles")


def duolingo_risk_translation() -> None:
    g = Diagram(
        "Duolingo Risk Translation",
        "Duolingo is useful as a pressure audit: Talvori translates value, not pressure mechanics.",
    )
    rows = [
        ("XP", "Fast feedback and completion signal.", "Avoid XP chase. Use learning-quality feedback only."),
        ("Streak", "Habit visibility and return rhythm.", "No streak loss, guilt or repair economy in MVP."),
        ("Leagues", "Competition and social comparison.", "No leaderboard or ranking in MVP."),
        ("Daily goals", "Tiny start point and routine.", "Micro session yes. Daily duty no."),
        ("Streak freeze", "Protection against broken habit.", "Talvori treats pause as neutral by design."),
    ]
    y = 350
    for title, value, translation in rows:
        g.card((130, y, 770, y + 255), title, value, GREEN, body_font=F_SMALL)
        g.arrow((820, y + 128), (940, y + 128))
        g.card((980, y, 2870, y + 255), "Talvori translation", translation, BLUE, body_font=F_SMALL)
        y += 315
    g.save("duolingo_risk_translation")


def brilliant_quizlet_patterns() -> None:
    g = Diagram(
        "Brilliant And Quizlet Learning Patterns",
        "Interactive meaning and recall are useful only when they stay short, optional and reversible.",
    )
    g.card(
        (140, 360, 1360, 680),
        "Brilliant pattern",
        "Interactive problem -> visual explanation -> direct feedback -> small concept progress.",
        BLUE,
        body_font=F_SMALL,
    )
    g.card(
        (1640, 360, 2860, 680),
        "Quizlet pattern",
        "Flashcard or Learn mode -> recall attempt -> user-controlled repeat -> targeted practice.",
        TEAL,
        body_font=F_SMALL,
    )
    g.arrow((720, 680), (720, 850))
    g.arrow((2250, 680), (2250, 850))
    g.card(
        (140, 850, 1360, 1220),
        "Talvori use",
        "ContextCards, ActionChallenges and Companion explanations can make meaning active without creating BuildState.",
        GREEN,
        body_font=F_SMALL,
    )
    g.card(
        (1640, 850, 2860, 1220),
        "Talvori use",
        "Few voluntary recall moments can support learning without mass review or SRS writes.",
        GREEN,
        body_font=F_SMALL,
    )
    g.card(
        (360, 1470, 1260, 1790),
        "Risk to avoid",
        "Too much interaction becomes cognitive load or a hidden obligation.",
        RED,
        body_font=F_SMALL,
    )
    g.card(
        (1740, 1470, 2640, 1790),
        "Risk to avoid",
        "Large review queues turn motivation into homework debt.",
        RED,
        body_font=F_SMALL,
    )
    g.save("brilliant_quizlet_learning_patterns")


def talvori_rules() -> None:
    g = Diagram(
        "Talvori MVP Motivation Rules",
        "The first playable loop may motivate gently, but it cannot mutate learning state or world state.",
    )
    cards = [
        ("Micro session", "Offer a short voluntary next step.", GREEN),
        ("Few reviews", "Keep queue budget tiny. Later stays visible.", BLUE),
        ("No streak system", "No loss, freeze economy or guilt copy.", RED),
        ("No leaderboard", "Competition stays after MVP and gated.", RED),
        ("No SRS write", "Recall does not touch word_progress.", YELLOW),
        ("No analytics impl", "Metrics remain privacy-gated planning.", PURPLE),
        ("No sensitive retention", "Sensitive terms are never motivation hooks.", RED),
        ("No BuildState", "Feedback is not placement or frame_started.", TEAL),
    ]
    cols = [150, 820, 1490, 2160]
    ys = [350, 740]
    idx = 0
    for y in ys:
        for x in cols:
            title, body, color = cards[idx]
            g.card((x, y, x + 560, y + 280), title, body, color, body_font=F_SMALL)
            idx += 1
    g.card(
        (370, 1270, 2630, 1620),
        "MVP rule",
        "Learning -> optional gentle signal -> semantic outcome -> queue eligibility -> user choice or safe fallback. No push, no analytics, no automatic word placement, no BuildState.",
        GREEN,
        body_font=F_SMALL,
    )
    g.card(
        (620, 1760, 2380, 1945),
        "Research boundary",
        "M16-AI translates principles. It does not approve product mechanics, persistence, providers, metrics or app code.",
        GRAY,
        body_font=F_SMALL,
    )
    g.save("talvori_mvp_motivation_rules")


def contact_sheet() -> None:
    files = [
        "habit_motivation_benchmark_matrix.png",
        "pressure_free_retention_principles.png",
        "duolingo_risk_translation.png",
        "brilliant_quizlet_learning_patterns.png",
        "talvori_mvp_motivation_rules.png",
    ]
    cw, ch = 3800, 3550
    img = Image.new("RGB", (cw, ch), BG)
    d = ImageDraw.Draw(img)
    d.rounded_rectangle((48, 40, cw - 48, ch - 40), radius=30, fill=BG, outline=BORDER, width=2)
    d.text((96, 92), "M16-AI Habit Motivation Research Visuals", fill=INK, font=F_TITLE)
    d.text((96, 180), "Contact sheet with full-size documentation previews. PNG + SVG are generated for each diagram.", fill=MUTED, font=F_SUB)
    positions = [
        (130, 330),
        (1990, 330),
        (130, 1330),
        (1990, 1330),
        (1040, 2330),
    ]
    tw, th = 1650, 880
    svg: list[str] = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{cw}" height="{ch}" viewBox="0 0 {cw} {ch}">',
        f'<rect width="{cw}" height="{ch}" fill="{BG}"/>',
        f'<text x="96" y="156" font-family="{SVG_FONT}" font-size="{F_TITLE.size}" font-weight="700" fill="{INK}">M16-AI Habit Motivation Research Visuals</text>',
        f'<text x="96" y="226" font-family="{SVG_FONT}" font-size="{F_SUB.size}" fill="{MUTED}">Contact sheet with full-size documentation previews. PNG + SVG are generated for each diagram.</text>',
    ]
    for (x, y), filename in zip(positions, files):
        thumb = Image.open(OUT / filename)
        thumb.thumbnail((tw, th), Image.Resampling.LANCZOS)
        d.rounded_rectangle((x - 24, y - 24, x + tw + 24, y + th + 80), radius=24, fill=PANEL, outline=BORDER, width=2)
        ox = x + (tw - thumb.width) // 2
        oy = y + (th - thumb.height) // 2
        img.paste(thumb, (ox, oy))
        d.text((x, y + th + 28), filename, fill=INK, font=F_SMALL)
        svg.append(
            f'<rect x="{x - 24}" y="{y - 24}" width="{tw + 48}" height="{th + 104}" rx="24" fill="{PANEL}" stroke="{BORDER}" stroke-width="2"/>'
        )
        svg.append(f'<image href="{filename}" x="{x}" y="{y}" width="{tw}" height="{th}" preserveAspectRatio="xMidYMid meet"/>')
        svg.append(
            f'<text x="{x}" y="{y + th + 58}" font-family="{SVG_FONT}" font-size="{F_SMALL.size}" fill="{INK}">{escape(filename)}</text>'
        )
    d.line((96, ch - 120, cw - 96, ch - 120), fill=BORDER, width=2)
    d.text((96, ch - 84), FOOTER, fill=MUTED, font=F_FOOT)
    svg.append(f'<line x1="96" y1="{ch - 120}" x2="{cw - 96}" y2="{ch - 120}" stroke="{BORDER}" stroke-width="2"/>')
    svg.append(
        f'<text x="96" y="{ch - 60}" font-family="{SVG_FONT}" font-size="{F_FOOT.size}" fill="{MUTED}">{escape(FOOTER)}</text>'
    )
    svg.append("</svg>")
    img.save(OUT / "00_contact_sheet.png")
    svg_text = "\n".join(svg)
    (OUT / "00_contact_sheet.svg").write_text(svg_text, encoding="utf-8")
    ET.fromstring(svg_text)


def main() -> None:
    benchmark_matrix()
    pressure_free_principles()
    duolingo_risk_translation()
    brilliant_quizlet_patterns()
    talvori_rules()
    contact_sheet()


if __name__ == "__main__":
    main()
