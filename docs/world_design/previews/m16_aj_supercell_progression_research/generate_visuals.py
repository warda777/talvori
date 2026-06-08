from __future__ import annotations

from dataclasses import dataclass
from html import escape
from pathlib import Path
import xml.etree.ElementTree as ET

from PIL import Image, ImageDraw, ImageFont


OUT = Path(__file__).resolve().parent

W = 3100
H = 2250
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
    "documentation research preview only / no implementation / no economy / "
    "no timers / no social or competition release / no BuildState / no frame_started"
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
F_SUB = font(30)
F_HEAD = font(34, True)
F_BODY = font(25)
F_SMALL = font(22)
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


def progression_pattern_matrix() -> None:
    g = Diagram(
        "Supercell Progression Pattern Matrix",
        "Clash patterns are useful research, but Talvori translates only safe principles.",
    )
    entries = [
        ("Base progression", "Visible long-term growth.\nTalvori value: owned world feeling.\nRisk: BuildState and grind.", GREEN),
        ("Resources / upgrades", "Gold, elixir, gems, builders, magic items.\nValue: planning.\nRisk: timers and pay-to-progress.", YELLOW),
        ("Trade-offs", "Meaningful choices and strategic depth.\nValue: ownership.\nRisk: irreversible or unfair choices.", BLUE),
        ("Clans / wars", "Group goals, coordination, rewards.\nValue: belonging.\nRisk: war pressure and blame.", RED),
    ]
    xs = [120, 860, 1600, 2340]
    for x, (title, body, color) in zip(xs, entries):
        g.card((x, 350, x + 610, 800), title, body, color, body_font=F_SMALL)
    g.card(
        (250, 1020, 1450, 1390),
        "Talvori can learn",
        "Long-term ownership, visible possibility, small meaningful choices, belonging after privacy gates, and fair progression language.",
        GREEN,
        body_font=F_SMALL,
    )
    g.card(
        (1650, 1020, 2850, 1390),
        "Talvori must block",
        "Economy, timers, clan duty, leaderboards, raids, pay-to-win, world decay, social pressure, BuildState and frame_started.",
        RED,
        body_font=F_SMALL,
    )
    g.arrow((1450, 1205), (1650, 1205))
    g.card(
        (530, 1640, 2570, 1910),
        "MVP boundary",
        "Progression is semantic: learning opens a safe option. The user may choose Later, Codex, Backlog or Preview Only. Nothing builds.",
        TEAL,
        body_font=F_SMALL,
    )
    g.save("supercell_progression_pattern_matrix")


def clash_risk_translation() -> None:
    g = Diagram(
        "Clash Risk Translation To Talvori",
        "Strong progression patterns become Talvori stop rules before they become features.",
    )
    rows = [
        ("Timer", "Creates return pressure and waiting loops.", "No timer, upgrade time or FOMO in MVP."),
        ("Clan war", "Creates team goal and possible blame.", "No war, raid, team duty or group guilt."),
        ("Leaderboard", "Creates rank motivation and exposure.", "No ranking or league before fairness gate."),
        ("Resource scarcity", "Creates planning and grind.", "No resource bottleneck as learning brake."),
        ("Pay-to-progress", "Accelerates progression through purchases.", "No money-based progress in first MVP."),
    ]
    y = 330
    for title, risk, rule in rows:
        g.card((120, y, 810, y + 265), title, risk, RED, body_font=F_SMALL)
        g.arrow((860, y + 134), (980, y + 134))
        g.card((1020, y, 2980, y + 265), "Talvori translation", rule, GREEN, body_font=F_SMALL)
        y += 320
    g.save("clash_risk_translation_to_talvori")


def progression_without_pressure() -> None:
    g = Diagram(
        "Progression Without Pressure Rules",
        "Talvori can feel like growth without borrowing timers, economy or competitive pressure.",
    )
    steps = [
        ("Learn", "A word or context is practiced.", GREEN),
        ("Meaning", "Sense and outcome become clearer.", BLUE),
        ("Candidate", "A safe optional world possibility appears.", TEAL),
        ("Choice", "Later, Codex, Backlog, Change or Preview.", YELLOW),
        ("Gate", "Build, persistence and assets stay separate.", PURPLE),
    ]
    x = 120
    for title, body, color in steps:
        g.card((x, 380, x + 480, 700), title, body, color, body_font=F_SMALL)
        if x < 2360:
            g.arrow((x + 480, 540), (x + 560, 540))
        x += 600
    blocked = [
        ("No timer", "No upgrade countdown or return deadline."),
        ("No economy", "No resource scarcity as learning throttle."),
        ("No decay", "World does not punish pauses."),
        ("No auto-build", "Candidate is never BuildState."),
        ("No pay-to-win", "Money cannot replace learning."),
        ("No social pressure", "No team blame or ranking."),
    ]
    cols = [170, 1080, 1990]
    ys = [980, 1320]
    idx = 0
    for y in ys:
        for cx in cols:
            title, body = blocked[idx]
            g.card((cx, y, cx + 780, y + 255), title, body, RED, body_font=F_SMALL)
            idx += 1
    g.save("progression_without_pressure_rules")


def social_safety_gate() -> None:
    g = Diagram(
        "Social Competition Safety Gate",
        "Social can help belonging later. It must first pass privacy, fairness, safety and anti-pressure gates.",
    )
    left = [
        ("Potential value", "Friends, voluntary showcase, small reactions, private help, co-op without ranking."),
        ("Learning risk", "Tempo beats understanding, errors become public, pauses look like failure."),
        ("Privacy risk", "Words, context hints, sensitive flags and review choices can be private."),
    ]
    y = 350
    for title, body in left:
        g.card((120, y, 1180, y + 300), title, body, BLUE if y == 350 else RED, body_font=F_SMALL)
        y += 390
    gates = [
        ("Opt-in", "Nothing visible by default."),
        ("Privacy", "No private word or context sharing."),
        ("Fairness", "No ranking by time, age or prior skill."),
        ("Safety", "Sensitive terms never compete."),
        ("Moderation", "Social spaces need abuse controls."),
        ("Anti-pressure", "No team guilt, no war duty."),
    ]
    cols = [1390, 2170]
    ys = [350, 700, 1050]
    idx = 0
    for yy in ys:
        for x in cols:
            title, body = gates[idx]
            g.card((x, yy, x + 650, yy + 260), title, body, GREEN if idx < 2 else YELLOW, body_font=F_SMALL)
            idx += 1
    g.card(
        (600, 1580, 2500, 1880),
        "MVP decision",
        "No clans, wars, leaderboards, leagues, PvP, social ranking or group pressure. Social remains after MVP and gated.",
        RED,
        body_font=F_SMALL,
    )
    g.save("social_competition_safety_gate")


def post_mvp_social_boundary() -> None:
    g = Diagram(
        "Talvori Post-MVP Social Boundary",
        "The safe path is friends and belonging first, competition much later and only after explicit gates.",
    )
    g.card(
        (150, 350, 760, 720),
        "MVP",
        "Solo learning loop, optional review, small world feedback, no social pressure.",
        GREEN,
        body_font=F_SMALL,
    )
    g.arrow((760, 535), (900, 535))
    g.card(
        (940, 350, 1550, 720),
        "After MVP",
        "Voluntary friends, reactions, showcase, privacy controls and no ranking.",
        BLUE,
        body_font=F_SMALL,
    )
    g.arrow((1550, 535), (1690, 535))
    g.card(
        (1730, 350, 2340, 720),
        "Later gate",
        "Team or co-op ideas only after fairness, safety, moderation and privacy.",
        YELLOW,
        body_font=F_SMALL,
    )
    g.arrow((2340, 535), (2480, 535))
    g.card(
        (2520, 350, 3030, 720),
        "Still blocked",
        "Clan wars, PvP, leagues, ranking, pressure and sensitive competition.",
        RED,
        body_font=F_SMALL,
    )
    rules = [
        ("Private by default", "Words, mistakes, context hints and pauses stay private."),
        ("No weaker learner shame", "No ranking by speed, volume or error count."),
        ("No team penalty", "Pause or Later cannot hurt friends or groups."),
        ("No sensitive sharing", "SensitiveGated stays out of social surfaces."),
        ("No paid advantage", "Money cannot buy learning or social rank."),
        ("No BuildState shortcut", "Social cannot trigger build, placement or frame_started."),
    ]
    cols = [180, 1110, 2040]
    ys = [1010, 1350]
    idx = 0
    for y in ys:
        for x in cols:
            title, body = rules[idx]
            g.card((x, y, x + 820, y + 250), title, body, PURPLE if idx < 3 else TEAL, body_font=F_SMALL)
            idx += 1
    g.save("talvori_post_mvp_social_boundary")


def contact_sheet() -> None:
    files = [
        "supercell_progression_pattern_matrix.png",
        "clash_risk_translation_to_talvori.png",
        "progression_without_pressure_rules.png",
        "social_competition_safety_gate.png",
        "talvori_post_mvp_social_boundary.png",
    ]
    cw, ch = 3900, 3600
    img = Image.new("RGB", (cw, ch), BG)
    d = ImageDraw.Draw(img)
    d.rounded_rectangle((48, 40, cw - 48, ch - 40), radius=30, fill=BG, outline=BORDER, width=2)
    d.text((96, 92), "M16-AJ Supercell Progression Research Visuals", fill=INK, font=F_TITLE)
    d.text((96, 180), "Contact sheet with full-size documentation previews. PNG + SVG are generated for each diagram.", fill=MUTED, font=F_SUB)
    positions = [
        (130, 330),
        (2020, 330),
        (130, 1340),
        (2020, 1340),
        (1075, 2350),
    ]
    tw, th = 1700, 890
    svg: list[str] = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{cw}" height="{ch}" viewBox="0 0 {cw} {ch}">',
        f'<rect width="{cw}" height="{ch}" fill="{BG}"/>',
        f'<text x="96" y="154" font-family="{SVG_FONT}" font-size="{F_TITLE.size}" font-weight="700" fill="{INK}">M16-AJ Supercell Progression Research Visuals</text>',
        f'<text x="96" y="226" font-family="{SVG_FONT}" font-size="{F_SUB.size}" fill="{MUTED}">Contact sheet with full-size documentation previews. PNG + SVG are generated for each diagram.</text>',
    ]
    for (x, y), filename in zip(positions, files):
        thumb = Image.open(OUT / filename)
        thumb.thumbnail((tw, th), Image.Resampling.LANCZOS)
        d.rounded_rectangle((x - 24, y - 24, x + tw + 24, y + th + 82), radius=24, fill=PANEL, outline=BORDER, width=2)
        ox = x + (tw - thumb.width) // 2
        oy = y + (th - thumb.height) // 2
        img.paste(thumb, (ox, oy))
        d.text((x, y + th + 30), filename, fill=INK, font=F_SMALL)
        svg.append(
            f'<rect x="{x - 24}" y="{y - 24}" width="{tw + 48}" height="{th + 106}" rx="24" fill="{PANEL}" stroke="{BORDER}" stroke-width="2"/>'
        )
        svg.append(f'<image href="{filename}" x="{x}" y="{y}" width="{tw}" height="{th}" preserveAspectRatio="xMidYMid meet"/>')
        svg.append(
            f'<text x="{x}" y="{y + th + 60}" font-family="{SVG_FONT}" font-size="{F_SMALL.size}" fill="{INK}">{escape(filename)}</text>'
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
    progression_pattern_matrix()
    clash_risk_translation()
    progression_without_pressure()
    social_safety_gate()
    post_mvp_social_boundary()
    contact_sheet()


if __name__ == "__main__":
    main()
