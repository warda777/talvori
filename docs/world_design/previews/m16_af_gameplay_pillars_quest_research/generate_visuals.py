from __future__ import annotations

from dataclasses import dataclass
from html import escape
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


OUT = Path(__file__).resolve().parent

W = 2400
H = 1800
BG = "#f7f8f4"
PANEL = "#ffffff"
INK = "#20302c"
MUTED = "#64736e"
BORDER = "#d6dfd7"
ARROW = "#8ea29a"
GREEN = "#63ad7d"
BLUE = "#68a6ca"
TEAL = "#58b7ad"
RED = "#dc6f6a"
YELLOW = "#d8b64f"
PURPLE = "#8e7ac8"
FOOTER = (
    "documentation preview only / no code / no app route / no screenshots / "
    "no assets / no persistence / no social runtime"
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
F_HEAD = font(38, True)
F_BODY = font(28)
F_SMALL = font(24)
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
            words = (
                split_long_word(draw, raw_word, width, fnt)
                if text_width(draw, raw_word, fnt) > width
                else [raw_word]
            )
            for word in words:
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
        self.text(self.subtitle, 80, 162, F_SUB, MUTED, max_width=self.width - 160)
        self.line((80, self.height - 100), (self.width - 80, self.height - 100), BORDER, 2)
        self.text(FOOTER, 80, self.height - 65, F_FOOT, MUTED, max_width=self.width - 160)

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
        line_gap: int = 8,
    ) -> int:
        lines = wrap_lines(self.draw, text, max_width, fnt)
        line_height = fnt.size + line_gap
        for idx, line in enumerate(lines):
            py = y + idx * line_height
            self.draw.text((x, py), line, fill=fill, font=fnt)
            weight = "700" if bold else "400"
            svg_y = py + fnt.size
            self.svg.append(
                f'<text x="{x}" y="{svg_y}" font-family="{SVG_FONT}" font-size="{fnt.size}" font-weight="{weight}" fill="{fill}">{escape(line)}</text>'
            )
        return y + len(lines) * line_height

    def arrow(self, start: tuple[int, int], end: tuple[int, int], color: str = ARROW) -> None:
        self.line(start, end, color, 6)
        x1, y1 = start
        x2, y2 = end
        if abs(x2 - x1) >= abs(y2 - y1):
            if x2 >= x1:
                points = [(x2, y2), (x2 - 26, y2 - 16), (x2 - 26, y2 + 16)]
            else:
                points = [(x2, y2), (x2 + 26, y2 - 16), (x2 + 26, y2 + 16)]
        elif y2 >= y1:
            points = [(x2, y2), (x2 - 16, y2 - 26), (x2 + 16, y2 - 26)]
        else:
            points = [(x2, y2), (x2 - 16, y2 + 26), (x2 + 16, y2 + 26)]
        self.polygon(points, color)

    def card(
        self,
        box: tuple[int, int, int, int],
        title: str,
        body: str,
        accent: str,
        *,
        body_font: ImageFont.ImageFont = F_BODY,
        fill: str = PANEL,
    ) -> None:
        x1, y1, x2, y2 = box
        pad = 26
        self.rounded_rect(box, 18, fill, BORDER, 2)
        self.rounded_rect((x1, y1, x2, y1 + 13), 8, accent)
        title_end = self.text(
            title,
            x1 + pad,
            y1 + 34,
            F_HEAD,
            INK,
            bold=True,
            max_width=x2 - x1 - 2 * pad,
        )
        self.text(
            body,
            x1 + pad,
            max(title_end + 16, y1 + 96),
            body_font,
            MUTED,
            max_width=x2 - x1 - 2 * pad,
        )

    def pill(self, x: int, y: int, text: str, color: str) -> None:
        tw = text_width(self.draw, text, F_SMALL)
        box = (x, y, x + tw + 42, y + 42)
        self.rounded_rect(box, 21, color)
        self.text(text, x + 21, y + 8, F_SMALL, "#ffffff", max_width=tw + 4)

    def save(self, stem: str) -> None:
        self.img.save(OUT / f"{stem}.png")
        self.svg.append("</svg>")
        (OUT / f"{stem}.svg").write_text("\n".join(self.svg), encoding="utf-8")


def gameplay_pillars() -> None:
    g = Diagram(
        "Gameplay Pillars Overview",
        "Game feeling is allowed only when learning, safety, choice and reversible world feedback stay intact.",
    )
    pillars = [
        ("Learning opens options", "Learning can unlock a suggestion, not automatic placement or BuildState.", GREEN),
        ("Meaning before world", "Sense, word type, safety, clutter and confidence come before any visible reaction.", TEAL),
        ("Small choices", "Few relevant decisions beat mandatory lists and mass review.", BLUE),
        ("Visible progress, no pressure", "World feedback can motivate, but never punish, decay or demand.", YELLOW),
        ("Tali/Vori guides", "Companion explains and calms. It never decides, places, stores or pressures.", PURPLE),
    ]
    boxes = [
        (135, 300, 765, 580),
        (850, 300, 1480, 580),
        (1565, 300, 2195, 580),
        (320, 710, 1030, 1010),
        (1370, 710, 2050, 1010),
    ]
    for (title, body, color), box in zip(pillars, boxes):
        g.card(box, title, body, color)
    g.card(
        (360, 1190, 2040, 1445),
        "MVP interpretation",
        "A playful moment is safe only if Later, Codex, Backlog, Change and Hide remain available. The loop may feel alive, but it must not become a runtime quest engine, social pressure system, timer or build pipeline.",
        RED,
    )
    g.pill(510, 1540, "no auto placement", RED)
    g.pill(900, 1540, "no BuildState", RED)
    g.pill(1260, 1540, "no social runtime", RED)
    g.pill(1680, 1540, "no SRS writes", RED)
    g.save("gameplay_pillars_overview")


def mvp_quest_loop() -> None:
    g = Diagram(
        "MVP Quest / Challenge Loop",
        "Quest is a tiny optional learning moment, not a required mission, timer, engine or build action.",
    )
    steps = [
        ("Learn block", "practice or understand a word"),
        ("Semantic impulse", "Outcome, sense, safety and type"),
        ("Optional challenge", "only if budget and safety allow"),
        ("User choice", "Confirm, Change, Later, Codex, Backlog"),
        ("World feedback", "small preview or explanation"),
        ("Later gate", "implementation remains blocked"),
    ]
    colors = [GREEN, TEAL, BLUE, PURPLE, YELLOW, RED]
    x = 115
    y = 355
    w = 335
    gap = 45
    for i, (title, body) in enumerate(steps):
        box = (x + i * (w + gap), y, x + i * (w + gap) + w, y + 275)
        g.card(box, title, body, colors[i], body_font=F_SMALL)
        if i < len(steps) - 1:
            g.arrow((box[2] + 10, y + 138), (box[2] + gap - 12, y + 138))
    g.card(
        (210, 850, 1030, 1165),
        "Allowed",
        "Word Sense, ContextCard, ActionChallenge, Container Findability, Review Choice, WorldCandidate Explanation and Return After Pause as voluntary planning concepts.",
        GREEN,
    )
    g.card(
        (1350, 850, 2180, 1165),
        "Blocked",
        "Quest duty, streak guilt, sensitive triggers, auto placement, SRS or word_progress mutation, BuildState, timers, FOMO, social competition and quest engine code.",
        RED,
    )
    g.arrow((1060, 1010), (1325, 1010), RED)
    g.pill(590, 1365, "Later always allowed", BLUE)
    g.pill(990, 1365, "safe defaults stay normal", GREEN)
    g.pill(1450, 1365, "world feedback is preview only", YELLOW)
    g.save("mvp_quest_loop")


def challenge_matrix() -> None:
    g = Diagram(
        "Challenge Type Matrix",
        "Challenge categories clarify learning value while keeping runtime mechanics blocked.",
    )
    entries = [
        ("Word Sense", "multi-home words\nlearn: meaning choice\nblocks: default placement", TEAL),
        ("ContextCard", "abstract or unclear\nlearn: short context\nblocks: symbol duty", BLUE),
        ("ActionChallenge", "verbs and processes\nlearn: action use\nblocks: auto quest", GREEN),
        ("Container Findability", "tiny objects\nlearn: where it belongs\nblocks: object cloud", YELLOW),
        ("Review Choice", "few high-value decisions\nlearn: safe outcomes\nblocks: mass review", PURPLE),
        ("WorldCandidate Explain", "larger safe candidates\nlearn: candidate not build\nblocks: placement", RED),
        ("Return After Pause", "calm comeback\nlearn: continue gently\nblocks: guilt", BLUE),
        ("M16 rule stack", "M16-W outcomes, M16-X budget, M16-Y priority, M16-Z safety, M16-AC mobile and M16-AE world stop rules must all pass first.", RED),
    ]
    boxes = [
        (135, 300, 695, 545),
        (800, 300, 1360, 545),
        (1465, 300, 2025, 545),
        (135, 660, 695, 905),
        (800, 660, 1360, 905),
        (1465, 660, 2025, 905),
        (470, 1040, 1160, 1280),
        (1285, 1040, 2060, 1280),
    ]
    for entry, box in zip(entries, boxes):
        g.card(box, entry[0], entry[1], entry[2], body_font=F_SMALL)
    g.card(
        (320, 1405, 2080, 1645),
        "Safe reading",
        "Challenge means: a small optional learning prompt or explanation. It does not mean quest runtime, route, persistence, build, timer, social system or reward bridge.",
        GREEN,
    )
    g.save("challenge_type_matrix")


def fun_without_harm() -> None:
    g = Diagram(
        "Fun Without Learning Harm",
        "Engagement is welcome only when it protects learning, consent, safety and calm return.",
    )
    left = [
        ("Curiosity", "small open question"),
        ("Small goals", "one block, one optional choice"),
        ("Visible improvement", "preview or calm highlight"),
        ("Voluntary choice", "Later, Codex, Backlog, Change"),
        ("Surprise", "positive variation without pressure"),
    ]
    right = [
        ("FOMO", "timers, urgency, loss warning"),
        ("Streak guilt", "you lose progress language"),
        ("Sensitive trigger", "emotion/safety as motivation"),
        ("Pay pressure", "first wow behind paywall"),
        ("Social pressure", "leaderboard or war pressure"),
    ]
    left_boxes: list[tuple[int, int, int, int]] = []
    right_boxes: list[tuple[int, int, int, int]] = []
    for i, (title, body) in enumerate(left):
        box = (145, 285 + i * 230, 875, 455 + i * 230)
        left_boxes.append(box)
        g.card(box, title, body, GREEN, body_font=F_SMALL)
    center = (1000, 660, 1400, 1040)
    g.card(
        center,
        "Safe tension",
        "Meaning, choice, gentle progress and reversible feedback create play. Fear, loss, pressure and hidden writes do not.",
        BLUE,
    )
    for i, (title, body) in enumerate(right):
        box = (1560, 285 + i * 230, 2260, 455 + i * 230)
        right_boxes.append(box)
        g.card(box, title, body, RED, body_font=F_SMALL)
    for box in left_boxes:
        g.arrow((box[2] + 20, (box[1] + box[3]) // 2), (center[0] - 22, 850), GREEN)
    for box in right_boxes:
        g.arrow((box[0] - 20, (box[1] + box[3]) // 2), (center[2] + 22, 850), RED)
    g.pill(680, 1465, "no punishment", RED)
    g.pill(1040, 1465, "no decay", RED)
    g.pill(1340, 1465, "no forced choice", RED)
    g.save("fun_without_learning_harm")


def research_flow() -> None:
    g = Diagram(
        "Research To Talvori Principles",
        "Benchmark work prepares questions and principles. It does not copy mechanics or unlock runtime systems.",
    )
    g.card(
        (135, 300, 855, 630),
        "Duolingo research prep",
        "Habit, streaks, XP, leagues, daily goals, lesson progression and motivation language. Watch for guilt, pressure, FOMO and shallow XP chasing.",
        BLUE,
    )
    g.card(
        (1545, 300, 2265, 630),
        "Supercell / Clash prep",
        "Build progression, trade-offs, resources, timers, clans, social play, competition and balance. Watch for pay-to-win, war pressure and social pressure.",
        PURPLE,
    )
    center = (865, 765, 1535, 1075)
    g.card(
        center,
        "Translation template",
        "Observation -> Principle -> Talvori application -> Risk -> Decision -> affected M16-T IDs -> later gate before implementation.",
        TEAL,
    )
    g.arrow((855, 505), (850, 870), BLUE)
    g.arrow((1545, 505), (1540, 870), PURPLE)
    g.card(
        (300, 1275, 1040, 1515),
        "Allowed now",
        "Research questions, principle template, risk language and next-gate planning.",
        GREEN,
    )
    g.card(
        (1360, 1275, 2100, 1515),
        "Blocked now",
        "Blind copy, streak pressure, timers, economy, leaderboards, clans, PvP, quest engine, persistence or app integration.",
        RED,
    )
    g.arrow((1035, 1085), (705, 1260), GREEN)
    g.arrow((1365, 1085), (1735, 1260), RED)
    g.save("research_to_talvori_principles")


def contact_sheet(names: list[str]) -> None:
    cw, ch = 3200, 3600
    img = Image.new("RGB", (cw, ch), BG)
    d = ImageDraw.Draw(img)
    svg: list[str] = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{cw}" height="{ch}" viewBox="0 0 {cw} {ch}">',
        f'<rect width="{cw}" height="{ch}" fill="{BG}"/>',
        f'<rect x="55" y="45" width="{cw - 110}" height="{ch - 90}" rx="32" ry="32" fill="{BG}" stroke="{BORDER}" stroke-width="3"/>',
    ]
    d.rounded_rectangle((55, 45, cw - 55, ch - 45), radius=32, outline=BORDER, width=3, fill=BG)
    title = "M16-AF Gameplay Pillars / Quest Loop / Research Prep"
    subtitle = "Contact sheet for generated documentation visuals. No app screens, screenshots or assets."
    d.text((105, 100), title, fill=INK, font=font(58, True))
    d.text((105, 170), subtitle, fill=MUTED, font=font(32))
    svg.append(f'<text x="105" y="158" font-family="{SVG_FONT}" font-size="58" font-weight="700" fill="{INK}">{escape(title)}</text>')
    svg.append(f'<text x="105" y="208" font-family="{SVG_FONT}" font-size="32" fill="{MUTED}">{escape(subtitle)}</text>')
    thumb_w, thumb_h = 1320, 900
    positions = [(150, 320), (1730, 320), (150, 1390), (1730, 1390), (150, 2460)]
    for (name, (x, y)) in zip(names, positions):
        src = Image.open(OUT / f"{name}.png").convert("RGB")
        src.thumbnail((thumb_w, thumb_h), Image.Resampling.LANCZOS)
        frame = (x - 24, y - 24, x + thumb_w + 24, y + thumb_h + 92)
        d.rounded_rectangle(frame, radius=24, outline=BORDER, width=3, fill=PANEL)
        svg.append(
            f'<rect x="{frame[0]}" y="{frame[1]}" width="{frame[2] - frame[0]}" height="{frame[3] - frame[1]}" rx="24" ry="24" fill="{PANEL}" stroke="{BORDER}" stroke-width="3"/>'
        )
        tx = x + (thumb_w - src.width) // 2
        ty = y + (thumb_h - src.height) // 2
        img.paste(src, (tx, ty))
        svg.append(f'<image href="{name}.svg" x="{x}" y="{y}" width="{thumb_w}" height="{thumb_h}" preserveAspectRatio="xMidYMid meet"/>')
        label = f"{name}.png / {name}.svg"
        d.text((x, y + thumb_h + 34), label, fill=INK, font=font(25))
        svg.append(f'<text x="{x}" y="{y + thumb_h + 62}" font-family="{SVG_FONT}" font-size="25" fill="{INK}">{escape(label)}</text>')
    d.line((105, ch - 140, cw - 105, ch - 140), fill=BORDER, width=3)
    footer = "Visual-QA: text containment, readable previews, PNG + SVG, no overlaps, footer separation and no clipping checked."
    d.text((105, ch - 90), footer, fill=MUTED, font=font(24))
    svg.append(f'<line x1="105" y1="{ch - 140}" x2="{cw - 105}" y2="{ch - 140}" stroke="{BORDER}" stroke-width="3"/>')
    svg.append(f'<text x="105" y="{ch - 62}" font-family="{SVG_FONT}" font-size="24" fill="{MUTED}">{escape(footer)}</text>')
    svg.append("</svg>")
    img.save(OUT / "00_contact_sheet.png")
    (OUT / "00_contact_sheet.svg").write_text("\n".join(svg), encoding="utf-8")


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    gameplay_pillars()
    mvp_quest_loop()
    challenge_matrix()
    fun_without_harm()
    research_flow()
    contact_sheet(
        [
            "gameplay_pillars_overview",
            "mvp_quest_loop",
            "challenge_type_matrix",
            "fun_without_learning_harm",
            "research_to_talvori_principles",
        ]
    )


if __name__ == "__main__":
    main()
