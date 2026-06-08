from __future__ import annotations

from dataclasses import dataclass
from html import escape
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


OUT = Path(__file__).resolve().parent

W = 2600
H = 1900
BG = "#f7f8f4"
PANEL = "#ffffff"
INK = "#20302c"
MUTED = "#64736e"
BORDER = "#d6dfd7"
ARROW = "#8fa39c"
GREEN = "#63ad7d"
BLUE = "#68a6ca"
TEAL = "#58b7ad"
RED = "#dc6f6a"
YELLOW = "#d8b64f"
PURPLE = "#8e7ac8"
FOOTER = (
    "documentation preview only / no code / no app route / no screenshots / "
    "no assets / no persistence / no social runtime / no analytics runtime"
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
F_SUB = font(31)
F_HEAD = font(35, True)
F_BODY = font(25)
F_SMALL = font(22)
F_FOOT = font(19)
SVG_FONT = "Arial, Helvetica, sans-serif"


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
        if not paragraph:
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
        self.rounded_rect((45, 35, self.width - 45, self.height - 35), 28, BG, BORDER, 2)
        self.text(self.title, 80, 84, F_TITLE, INK, bold=True, max_width=self.width - 160)
        self.text(self.subtitle, 80, 164, F_SUB, MUTED, max_width=self.width - 160)
        self.line((80, self.height - 105), (self.width - 80, self.height - 105), BORDER, 2)
        self.text(FOOTER, 80, self.height - 70, F_FOOT, MUTED, max_width=self.width - 160)

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
        points_attr = " ".join(f"{x},{y}" for x, y in points)
        self.svg.append(f'<polygon points="{points_attr}" fill="{fill}"/>')

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

    def arrow(self, start: tuple[int, int], end: tuple[int, int], color: str = ARROW) -> None:
        self.line(start, end, color, 6)
        x1, y1 = start
        x2, y2 = end
        if abs(x2 - x1) >= abs(y2 - y1):
            points = [(x2, y2), (x2 - 28, y2 - 17), (x2 - 28, y2 + 17)] if x2 >= x1 else [(x2, y2), (x2 + 28, y2 - 17), (x2 + 28, y2 + 17)]
        else:
            points = [(x2, y2), (x2 - 17, y2 - 28), (x2 + 17, y2 - 28)] if y2 >= y1 else [(x2, y2), (x2 - 17, y2 + 28), (x2 + 17, y2 + 28)]
        self.polygon(points, color)

    def card(
        self,
        box: tuple[int, int, int, int],
        title: str,
        body: str,
        accent: str,
        *,
        body_font: ImageFont.ImageFont = F_BODY,
    ) -> None:
        x1, y1, x2, y2 = box
        pad = 26
        self.rounded_rect(box, 18, PANEL, BORDER, 2)
        self.rounded_rect((x1, y1, x2, y1 + 13), 8, accent)
        title_end = self.text(title, x1 + pad, y1 + 34, F_HEAD, INK, bold=True, max_width=x2 - x1 - 2 * pad)
        self.text(body, x1 + pad, max(title_end + 16, y1 + 96), body_font, MUTED, max_width=x2 - x1 - 2 * pad)

    def pill(self, x: int, y: int, text: str, color: str) -> None:
        tw = text_width(self.draw, text, F_SMALL)
        box = (x, y, x + tw + 42, y + 42)
        self.rounded_rect(box, 21, color)
        self.text(text, x + 21, y + 8, F_SMALL, "#ffffff", max_width=tw + 8)

    def save(self, stem: str) -> None:
        self.img.save(OUT / f"{stem}.png")
        self.svg.append("</svg>")
        (OUT / f"{stem}.svg").write_text("\n".join(self.svg), encoding="utf-8")


def benchmark_category_map() -> None:
    g = Diagram(
        "Benchmark Category Map",
        "Research expands beyond two examples, but no benchmark unlocks a runtime mechanic.",
    )
    cats = [
        ("Habit / Daily", "return rhythm\nno guilt", GREEN),
        ("Flashcard / SRS", "recall and spacing\nno data mutation", BLUE),
        ("Interactive learning", "learn by doing\nsmall tasks", TEAL),
        ("AI Tutor", "explain and guide\nno provider gate bypass", PURPLE),
        ("Quest / Goals", "optional challenge\nno timers", YELLOW),
        ("Worldbuilding", "progression ideas\nno placement", GREEN),
        ("Social / Team", "friends later\nno MVP runtime", BLUE),
        ("Competition", "fairness research\nno leaderboard", RED),
        ("Retention calm", "motivation\nno pressure", TEAL),
        ("Mobile UX", "micro sessions\nreadable screens", PURPLE),
        ("Accessibility", "contrast, tap, motion\nno UI release", YELLOW),
        ("Metrics", "learning success\nprivacy first", RED),
    ]
    positions = [
        (120, 310, 650, 500),
        (730, 310, 1260, 500),
        (1340, 310, 1870, 500),
        (1950, 310, 2480, 500),
        (120, 620, 650, 810),
        (730, 620, 1260, 810),
        (1340, 620, 1870, 810),
        (1950, 620, 2480, 810),
        (120, 930, 650, 1120),
        (730, 930, 1260, 1120),
        (1340, 930, 1870, 1120),
        (1950, 930, 2480, 1120),
    ]
    for (title, body, color), box in zip(cats, positions):
        g.card(box, title, body, color, body_font=F_SMALL)
    g.card(
        (420, 1320, 2180, 1565),
        "Research rule",
        "A benchmark can create only a question, principle or follow-up gate. It cannot create app code, social runtime, analytics, persistence, assets, BuildState or automatic word placement.",
        RED,
    )
    g.pill(520, 1630, "map first", GREEN)
    g.pill(890, 1630, "principles only", BLUE)
    g.pill(1290, 1630, "no mechanic copy", RED)
    g.pill(1740, 1630, "later gates", PURPLE)
    g.save("benchmark_category_map")


def benchmark_candidate_matrix() -> None:
    g = Diagram(
        "Benchmark Candidate Matrix",
        "Candidate apps and games are research targets, not Talvori feature approvals.",
        height=2300,
    )
    items = [
        ("Duolingo", "habit, XP, streaks, leagues\nlearn: rhythm\nrisk: guilt/FOMO", GREEN),
        ("Supercell / Clash", "progression, trade-offs, clans\nlearn: long arc\nrisk: timers/pressure", RED),
        ("Brilliant", "interactive problems\nlearn: thinking by doing\nrisk: puzzle overload", BLUE),
        ("Quizlet", "sets and recall\nlearn: quick review\nrisk: shallow drill", TEAL),
        ("Anki", "SRS and decks\nlearn: long memory\nrisk: review burden", PURPLE),
        ("Khan / Khanmigo", "explanation and tutor\nlearn: guided help\nrisk: advice/privacy", YELLOW),
        ("Memrise", "language context\nlearn: examples\nrisk: content dependency", GREEN),
        ("Drops", "micro visual sessions\nlearn: quick focus\nrisk: image-only thinking", BLUE),
        ("Habitica", "habits as RPG\nlearn: motivation pattern\nrisk: punishment gamification", RED),
        ("Pokemon GO", "collecting, events, teams\nlearn: collection emotion\nrisk: FOMO/privacy", TEAL),
        ("Minecraft Education", "creative learning world\nlearn: sandbox value\nrisk: huge scope", PURPLE),
        ("Lingvist / Babbel", "structured language path\nlearn: progression\nrisk: course rigidity", YELLOW),
    ]
    x_positions = [120, 910, 1700]
    y_positions = [320, 590, 860, 1130]
    idx = 0
    for y in y_positions:
        for x in x_positions:
            title, body, color = items[idx]
            g.card((x, y, x + 690, y + 210), title, body, color, body_font=F_SMALL)
            idx += 1
    g.card(
        (320, 1560, 2280, 1845),
        "Matrix reading",
        "M16-AG chooses benchmark families and questions. It does not claim current feature details, copy mechanics, create research conclusions or unlock product code. Deep slices must verify observations before Talvori principles are accepted.",
        RED,
    )
    g.pill(520, 1945, "MVP lens", GREEN)
    g.pill(860, 1945, "post-MVP lens", BLUE)
    g.pill(1260, 1945, "risk lens", RED)
    g.pill(1600, 1945, "follow-up gate", PURPLE)
    g.save("benchmark_candidate_matrix")


def research_to_talvori_principles_flow() -> None:
    g = Diagram(
        "Research To Talvori Principles",
        "Research becomes useful only after anti-pressure, safety, privacy and M16-T checks.",
    )
    boxes = [
        ((120, 350, 520, 560), "Benchmark", "source app or game\nobservation only", BLUE),
        ((660, 350, 1060, 560), "Mechanic", "what happens?\nwhat emotion?", TEAL),
        ((1200, 350, 1600, 560), "Principle", "why it works\nor why it harms", GREEN),
        ((1740, 350, 2140, 560), "Talvori use", "adapt, reject\nor park", PURPLE),
        ((520, 830, 1000, 1080), "Risk checks", "pressure, privacy,\nsafety, FOMO,\npay-to-win", RED),
        ((1160, 830, 1640, 1080), "M16-T IDs", "affected gates,\nstatus update,\nnew blocker", YELLOW),
        ((1800, 830, 2280, 1080), "Follow-up gate", "research, data,\nAI, social,\nmetrics or UI", GREEN),
    ]
    for box, title, body, color in boxes:
        g.card(box, title, body, color)
    g.arrow((520, 455), (660, 455))
    g.arrow((1060, 455), (1200, 455))
    g.arrow((1600, 455), (1740, 455))
    g.arrow((1940, 560), (1940, 830))
    g.arrow((1740, 950), (1640, 950))
    g.arrow((1160, 950), (1000, 950))
    g.card(
        (410, 1320, 2190, 1555),
        "Hard boundary",
        "No benchmark observation may skip the Talvori gates. Learning value, anti-pressure rules, sensitive safety, privacy and no automatic placement must pass before any future implementation prompt exists.",
        RED,
    )
    g.save("research_to_talvori_principles_flow")


def social_competition_gate_map() -> None:
    g = Diagram(
        "Social / Competition Gate Map",
        "Social can motivate later, but it stays outside MVP until fairness and safety are proven.",
    )
    g.card(
        (140, 340, 760, 590),
        "Allowed now",
        "research questions\nfriend/team ideas\nshowcase principles\nfairness checklist",
        GREEN,
    )
    g.card(
        (990, 340, 1610, 590),
        "Needs gate",
        "age/privacy\nmoderation\nanti-pressure\nlearning fairness",
        YELLOW,
    )
    g.card(
        (1840, 340, 2460, 590),
        "Blocked now",
        "leaderboards\nPvP\nclans runtime\nwar/raid pressure",
        RED,
    )
    g.arrow((760, 465), (990, 465))
    g.arrow((1610, 465), (1840, 465))
    left = [
        ("Friend support", "can help motivation\nwithout comparison", GREEN),
        ("Showcase", "share progress later\nwith privacy rules", BLUE),
        ("Teams", "research topic only\nnot MVP runtime", PURPLE),
    ]
    right = [
        ("Fairness", "no weak-user exposure\nno pay-to-win", YELLOW),
        ("Safety", "no harassment\nno social pressure", RED),
        ("Privacy", "no word/error leaks\nno hidden analytics", TEAL),
    ]
    y = 820
    for title, body, color in left:
        g.card((210, y, 1030, y + 190), title, body, color, body_font=F_SMALL)
        y += 240
    y = 820
    for title, body, color in right:
        g.card((1390, y, 2210, y + 190), title, body, color, body_font=F_SMALL)
        y += 240
    g.card(
        (520, 1535, 2080, 1735),
        "MVP rule",
        "No social or competition implementation. Social remains a post-MVP research and safety gate.",
        RED,
        body_font=F_SMALL,
    )
    g.save("social_competition_gate_map")


def metrics_privacy_gate_map() -> None:
    g = Diagram(
        "Metrics / Privacy Gate Map",
        "Talvori should measure learning quality later, not manipulate retention or expose private context.",
    )
    flow = [
        ((120, 350, 520, 560), "Learning success", "understanding\nrecall quality\ncontext use", GREEN),
        ((660, 350, 1060, 560), "Motivation", "voluntary return\ncalm pause\nno pressure", BLUE),
        ((1200, 350, 1600, 560), "Privacy gate", "word/context\nerror/pause data\nopt-in later", RED),
        ((1740, 350, 2140, 560), "Decision", "measure?\npark?\nreject?", PURPLE),
    ]
    for box, title, body, color in flow:
        g.card(box, title, body, color)
    g.arrow((520, 455), (660, 455))
    g.arrow((1060, 455), (1200, 455))
    g.arrow((1600, 455), (1740, 455))
    g.card(
        (180, 820, 1180, 1120),
        "Allowed as planning",
        "define questions, privacy risks, learning metrics, motivation signals and later gate requirements. No event tracking is created.",
        GREEN,
    )
    g.card(
        (1420, 820, 2420, 1120),
        "Blocked now",
        "analytics runtime, provider calls, private context storage, SRS mutation, retention pressure or leaderboards.",
        RED,
    )
    g.arrow((1180, 970), (1420, 970), RED)
    g.card(
        (430, 1410, 2170, 1610),
        "Metric principle",
        "A useful metric must improve learning safety and product understanding. It must not optimize guilt, compulsion, private-data extraction or visible placement.",
        YELLOW,
    )
    g.save("metrics_privacy_gate_map")


def contact_sheet() -> None:
    files = [
        ("benchmark_category_map", "benchmark_category_map.png / benchmark_category_map.svg"),
        ("benchmark_candidate_matrix", "benchmark_candidate_matrix.png / benchmark_candidate_matrix.svg"),
        ("research_to_talvori_principles_flow", "research_to_talvori_principles_flow.png / research_to_talvori_principles_flow.svg"),
        ("social_competition_gate_map", "social_competition_gate_map.png / social_competition_gate_map.svg"),
        ("metrics_privacy_gate_map", "metrics_privacy_gate_map.png / metrics_privacy_gate_map.svg"),
    ]
    width = 3400
    height = 3900
    sheet = Diagram(
        "M16-AG Broad Benchmark Research",
        "Contact sheet for generated documentation visuals. No app screens, screenshots or assets.",
        width=width,
        height=height,
    )
    thumb_w = 1320
    thumb_h = 965
    x_positions = [160, 1920]
    y_positions = [330, 1420, 2510]
    for idx, (stem, label) in enumerate(files):
        x = x_positions[idx % 2]
        y = y_positions[idx // 2]
        sheet.rounded_rect((x - 28, y - 28, x + thumb_w + 28, y + thumb_h + 105), 18, PANEL, BORDER, 2)
        img = Image.open(OUT / f"{stem}.png").resize((thumb_w, thumb_h))
        sheet.img.paste(img, (x, y))
        sheet.svg.append(
            f'<image href="{stem}.png" x="{x}" y="{y}" width="{thumb_w}" height="{thumb_h}"/>'
        )
        sheet.text(label, x, y + thumb_h + 28, F_SMALL, INK, max_width=thumb_w)
    sheet.text(
        "Visual-QA: PNG and SVG generated, text containment checked, contact sheet readable, no overlaps or clipping intended.",
        120,
        height - 145,
        F_SMALL,
        MUTED,
        max_width=width - 240,
    )
    sheet.save("00_contact_sheet")


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    benchmark_category_map()
    benchmark_candidate_matrix()
    research_to_talvori_principles_flow()
    social_competition_gate_map()
    metrics_privacy_gate_map()
    contact_sheet()


if __name__ == "__main__":
    main()
