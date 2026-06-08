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
MUTED = "#64736d"
BORDER = "#d6ded7"
GREEN = "#69ad78"
BLUE = "#67a7cb"
TEAL = "#58b8aa"
YELLOW = "#d7b95b"
RED = "#d96d67"
PURPLE = "#8979c7"
GRAY = "#8f9d98"
ARROW = "#8fa19a"
SVG_FONT = "Arial, Helvetica, sans-serif"
FOOTER = (
    "M16-AN gate only / no implementation / no route / no persistence / "
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
            (
                f'<svg xmlns="http://www.w3.org/2000/svg" width="{self.width}" '
                f'height="{self.height}" viewBox="0 0 {self.width} {self.height}">'
            ),
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
            f'<rect x="{x1}" y="{y1}" width="{x2 - x1}" height="{y2 - y1}" '
            f'rx="{radius}" ry="{radius}" fill="{fill}"{stroke}/>'
        )

    def line(
        self,
        start: tuple[int, int],
        end: tuple[int, int],
        color: str,
        width: int = 4,
    ) -> None:
        self.draw.line((*start, *end), fill=color, width=width)
        self.svg.append(
            f'<line x1="{start[0]}" y1="{start[1]}" x2="{end[0]}" y2="{end[1]}" '
            f'stroke="{color}" stroke-width="{width}" stroke-linecap="round"/>'
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
                f'<text x="{x}" y="{py + fnt.size}" font-family="{SVG_FONT}" '
                f'font-size="{fnt.size}" font-weight="{weight}" fill="{fill}">'
                f"{escape(line)}</text>"
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
        pad = 30
        self.rounded_rect(box, 20, PANEL, BORDER, 2)
        self.rounded_rect((x1, y1, x2, y1 + 16), 9, accent)
        title_end = self.text(
            title,
            x1 + pad,
            y1 + 38,
            title_font,
            INK,
            bold=True,
            max_width=x2 - x1 - 2 * pad,
        )
        self.text(
            body,
            x1 + pad,
            max(title_end + 14, y1 + 108),
            body_font,
            MUTED,
            max_width=x2 - x1 - 2 * pad,
        )

    def badge(self, x: int, y: int, text: str, fill: str) -> None:
        width = text_width(self.draw, text, F_SMALL) + 44
        self.rounded_rect((x, y, x + width, y + 54), 27, fill, None, 0)
        self.text(text, x + 22, y + 14, F_SMALL, "#ffffff", bold=True, max_width=width - 44)

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


def isolated_preview_boundary() -> None:
    g = Diagram(
        "Isolated Preview Boundary",
        "M16-AN prepares the Bank preview prompt, but does not create app code.",
    )
    g.card(
        (150, 360, 1120, 760),
        "Now: documentation gate",
        "Create rules, acceptance criteria, prompt draft and visuals only. No Flutter or Dart files in this slice.",
        BLUE,
        body_font=F_SMALL,
    )
    g.card(
        (1230, 360, 2200, 760),
        "Later: isolated preview",
        "A separately approved widget preview may show local Bank choice states with setState only.",
        TEAL,
        body_font=F_SMALL,
    )
    g.card(
        (2310, 360, 3250, 760),
        "Still blocked",
        "Route, navigation, persistence, SRS, assets, BuildState, frame_started and product mechanics.",
        RED,
        body_font=F_SMALL,
    )
    g.arrow((1130, 560), (1210, 560))
    g.arrow((2210, 560), (2290, 560))
    g.card(
        (250, 1060, 1560, 1430),
        "Allowed in M16-AN",
        "348 gate doc, documentation diagrams, PNG + SVG, Visual-QA, status and scope checks.",
        GREEN,
        body_font=F_SMALL,
    )
    g.card(
        (1840, 1060, 3150, 1430),
        "Not allowed in M16-AN",
        "No lib/, assets/, test/, integration_test/, route file, app entry, DB write or runtime configuration.",
        RED,
        body_font=F_SMALL,
    )
    g.card(
        (640, 1720, 2760, 2050),
        "Boundary sentence",
        "A documented gate is not an implementation approval. Code needs a separate prompt and explicit release.",
        PURPLE,
        body_font=F_SMALL,
    )
    g.save("isolated_preview_boundary")


def bank_meaning_puzzle_state_flow() -> None:
    g = Diagram(
        "Bank Meaning Puzzle State Flow",
        "One scene, three meanings, safe exits, no build or placement.",
    )
    steps = [
        ("Start", "Tali pauses at the river.\nThe word Bank appears in context.", BLUE),
        ("Choose Door", "Sitzbank\nGeldinstitut\nFlussufer", TEAL),
        ("Context Result", "Correct sense opens a ContextCard, Codex Discovery or tiny World Hint.", GREEN),
        ("Safe Exit", "Later, Codex, Backlog or Change.\nEnd without duty.", YELLOW),
    ]
    for idx, (title, body, color) in enumerate(steps):
        x = 180 + idx * 790
        g.card((x, 390, x + 610, 760), title, body, color, body_font=F_SMALL)
        if idx < len(steps) - 1:
            g.arrow((x + 620, 570), (x + 760, 570))
    g.card(
        (430, 1080, 1540, 1430),
        "Calm Retry",
        "A wrong choice says: the scene gives another clue. No shame, no loss, no world punishment.",
        PURPLE,
        body_font=F_SMALL,
    )
    g.card(
        (1860, 1080, 2970, 1430),
        "Meaning learned",
        "Bank is not one fixed object. Context decides whether it is bench, institution or river edge.",
        GREEN,
        body_font=F_SMALL,
    )
    g.card(
        (720, 1710, 2680, 2050),
        "Hard boundary",
        "The result is semantic clarity only: no SRS write, no placement, no BuildState, no asset, no frame_started.",
        RED,
        body_font=F_SMALL,
    )
    g.save("bank_meaning_puzzle_state_flow")


def play_first_preview_check() -> None:
    g = Diagram(
        "Play-First Preview Check",
        "The Bank preview must feel like a tiny game moment, not a vocabulary test.",
    )
    checks = [
        ("Game moment", "Choose the meaning door that fits the river scene.", GREEN),
        ("Curiosity", "Why is Bank near a river? The scene invites a tiny inference.", BLUE),
        ("Challenge", "Infer sense from context instead of translating a word.", TEAL),
        ("Reward feel", "The scene resolves and a ContextCard/Codex Discovery appears.", YELLOW),
        ("Learning result", "Context decides meaning; one word can have multiple homes.", GREEN),
        ("Not school-like", "No worksheet, no timer, no score chase, no Pflichtreview.", PURPLE),
        ("Pressure blocked", "No FOMO, Streak guilt, XP grind, loss, social pressure or punishment.", RED),
        ("Safe exits", "Later, Codex, Backlog, Change and end without duty.", GRAY),
    ]
    for idx, (title, body, color) in enumerate(checks):
        col = idx % 2
        row = idx // 2
        x = 180 + col * 1580
        y = 350 + row * 430
        g.card((x, y, x + 1420, y + 320), title, body, color, body_font=F_SMALL)
    g.save("play_first_preview_check")


def allowed_files_vs_blocked_files() -> None:
    g = Diagram(
        "Allowed Files vs Blocked Files",
        "M16-AN names future candidates but creates documentation only.",
    )
    g.card(
        (170, 360, 1540, 820),
        "Changed in this slice",
        "docs/world_design/348-isolated-bank-meaning-puzzle-preview-gate.md\n"
        "docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md\n"
        "docs/world_design/previews/m16_an_bank_meaning_puzzle_preview/",
        GREEN,
        body_font=F_TINY,
    )
    g.card(
        (1860, 360, 3230, 820),
        "Future file candidate only",
        "lib/features/world/local_world/ui/widgets/bank_meaning_puzzle_preview.dart\n\n"
        "May be created only by a later explicit implementation prompt.",
        BLUE,
        body_font=F_TINY,
    )
    g.card(
        (170, 1110, 1540, 1560),
        "Blocked paths now",
        "lib/\nassets/\ntest/\nintegration_test/\nApp routes\nHome screen\nData layer",
        RED,
        body_font=F_SMALL,
    )
    g.card(
        (1860, 1110, 3230, 1560),
        "Blocked effects",
        "No navigation, route, persistence, provider, Supabase, local DB, SRS write, asset, BuildState or frame_started.",
        RED,
        body_font=F_SMALL,
    )
    g.card(
        (610, 1840, 2790, 2110),
        "Rule",
        "A later isolated preview can be interactive. M16-AN itself stays documentation, prompt draft and Visual-QA.",
        PURPLE,
        body_font=F_SMALL,
    )
    g.save("allowed_files_vs_blocked_files")


def implementation_readiness_gate() -> None:
    g = Diagram(
        "Implementation Readiness Gate",
        "A later Bank preview code slice needs these gates before any Dart file exists.",
    )
    gates = [
        ("Read docs", "348, 347, 345, 331, 333, 337.", BLUE),
        ("Name files", "Only the isolated preview file may be changed.", TEAL),
        ("Play-first proof", "Game moment, curiosity, challenge and safe exits must be explicit.", GREEN),
        ("Stop rules", "No app, route, persistence, SRS, assets, BuildState, frame_started.", RED),
        ("Local behavior", "setState only; Bank choices, Calm Retry, ContextCard/Codex Discovery.", PURPLE),
        ("Checks", "format/analyze if code exists, diff check, status, scope check, no commit.", YELLOW),
    ]
    for idx, (title, body, color) in enumerate(gates):
        x = 170 + (idx % 3) * 1070
        y = 380 + (idx // 3) * 570
        g.card((x, y, x + 910, y + 400), title, body, color, body_font=F_SMALL)
    g.arrow((625, 810), (1230, 810))
    g.arrow((1695, 810), (2300, 810))
    g.arrow((2760, 810), (2760, 940))
    g.arrow((2300, 1380), (1695, 1380))
    g.arrow((1230, 1380), (625, 1380))
    g.card(
        (620, 1800, 2780, 2090),
        "Recommendation",
        "Next code slice should choose Option A: isolated local preview widget, no launch target unless separately released.",
        GREEN,
        body_font=F_SMALL,
    )
    g.save("implementation_readiness_gate")


def contact_sheet(stems: list[str]) -> None:
    width, height = 3600, 3900
    img = Image.new("RGB", (width, height), BG)
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle((50, 40, width - 50, height - 40), radius=30, fill=BG, outline=BORDER, width=2)
    draw.text((95, 90), "M16-AN Visual Contact Sheet", fill=INK, font=F_TITLE)
    draw.text(
        (95, 175),
        "PNG + SVG documentation previews for the isolated Bank Meaning Puzzle gate.",
        fill=MUTED,
        font=F_SUB,
    )
    svg: list[str] = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">',
        f'<rect width="{width}" height="{height}" fill="{BG}"/>',
        f'<rect x="50" y="40" width="{width - 100}" height="{height - 80}" rx="30" ry="30" fill="{BG}" stroke="{BORDER}" stroke-width="2"/>',
        f'<text x="95" y="152" font-family="{SVG_FONT}" font-size="{F_TITLE.size}" font-weight="700" fill="{INK}">M16-AN Visual Contact Sheet</text>',
        f'<text x="95" y="204" font-family="{SVG_FONT}" font-size="{F_SUB.size}" fill="{MUTED}">PNG + SVG documentation previews for the isolated Bank Meaning Puzzle gate.</text>',
    ]
    thumb_w, thumb_h = 1500, 940
    positions = [(170, 340), (1930, 340), (170, 1460), (1930, 1460), (170, 2580)]
    for idx, stem in enumerate(stems):
        x, y = positions[idx]
        source = Image.open(OUT / f"{stem}.png")
        source.thumbnail((thumb_w, thumb_h))
        frame = (x - 26, y - 26, x + thumb_w + 26, y + thumb_h + 94)
        draw.rounded_rectangle(frame, radius=24, fill=PANEL, outline=BORDER, width=2)
        paste_x = x + (thumb_w - source.width) // 2
        paste_y = y + (thumb_h - source.height) // 2
        img.paste(source, (paste_x, paste_y))
        draw.text((x, y + thumb_h + 24), f"{idx + 1}. {stem}", fill=INK, font=F_SMALL)
        svg.extend(
            [
                f'<rect x="{frame[0]}" y="{frame[1]}" width="{frame[2] - frame[0]}" height="{frame[3] - frame[1]}" rx="24" ry="24" fill="{PANEL}" stroke="{BORDER}" stroke-width="2"/>',
                f'<image href="{stem}.png" x="{paste_x}" y="{paste_y}" width="{source.width}" height="{source.height}"/>',
                f'<text x="{x}" y="{y + thumb_h + 48}" font-family="{SVG_FONT}" font-size="{F_SMALL.size}" fill="{INK}">{idx + 1}. {escape(stem)}</text>',
            ]
        )
    draw.text((95, height - 76), FOOTER, fill=MUTED, font=F_FOOT)
    svg.extend(
        [
            f'<text x="95" y="{height - 58}" font-family="{SVG_FONT}" font-size="{F_FOOT.size}" fill="{MUTED}">{escape(FOOTER)}</text>',
            "</svg>",
        ]
    )
    img.save(OUT / "00_contact_sheet.png")
    svg_text = "\n".join(svg)
    (OUT / "00_contact_sheet.svg").write_text(svg_text, encoding="utf-8")
    ET.fromstring(svg_text)


def main() -> None:
    stems = [
        "isolated_preview_boundary",
        "bank_meaning_puzzle_state_flow",
        "play_first_preview_check",
        "allowed_files_vs_blocked_files",
        "implementation_readiness_gate",
    ]
    isolated_preview_boundary()
    bank_meaning_puzzle_state_flow()
    play_first_preview_check()
    allowed_files_vs_blocked_files()
    implementation_readiness_gate()
    contact_sheet(stems)


if __name__ == "__main__":
    main()
