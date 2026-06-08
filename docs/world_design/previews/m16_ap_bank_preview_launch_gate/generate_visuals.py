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
    "M16-AP launch gate only / no code / no route / no app integration / "
    "no persistence / no BuildState / no frame_started"
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


def launch_option_matrix() -> None:
    g = Diagram(
        "Launch Option Matrix",
        "Only a future isolated run target is safe enough for local visibility.",
    )
    options = [
        ("Option A", "Separate preview_main.dart\nLocal flutter run -t\nNo route, no app wiring\nRecommended", GREEN),
        ("Option B", "No launch file\nSafest, but not visible\nKeeps widget code-only\nUseful if launch is too early", BLUE),
        ("Option C", "Temporary app hook\nTouches app flow risk\nNeeds own integration gate\nBlocked now", RED),
    ]
    for idx, (title, body, color) in enumerate(options):
        x = 170 + idx * 1075
        g.card((x, 390, x + 910, 850), title, body, color, body_font=F_SMALL)
    g.card(
        (360, 1180, 3040, 1540),
        "Decision",
        "Recommend Option A for a later slice: create only bank_meaning_puzzle_preview_main.dart with MaterialApp(home: BankMeaningPuzzlePreview()).",
        GREEN,
        body_font=F_SMALL,
    )
    g.card(
        (620, 1810, 2780, 2100),
        "Still not product integration",
        "A local launch target is a manual sandbox entry, not a route, screen registration, Home entry, provider, data path or app navigation.",
        PURPLE,
        body_font=F_SMALL,
    )
    g.save("launch_option_matrix")


def isolated_launch_boundary() -> None:
    g = Diagram(
        "Isolated Launch Boundary",
        "The launch target may make the widget visible, but nothing productive may attach to it.",
    )
    steps = [
        ("Existing widget", "BankMeaningPuzzlePreview\nAlready isolated\nMaterial only", BLUE),
        ("Future local main", "Widgets binding\nMaterialApp home\nManual flutter run -t", TEAL),
        ("Visible preview", "Scene, choices, Calm Retry\nSafe exits, guardrails", GREEN),
        ("No product effect", "No route, no persistence\nNo SRS, no BuildState", RED),
    ]
    for idx, (title, body, color) in enumerate(steps):
        x = 150 + idx * 800
        g.card((x, 410, x + 630, 820), title, body, color, body_font=F_SMALL)
        if idx < len(steps) - 1:
            g.arrow((x + 640, 610), (x + 780, 610))
    g.card(
        (390, 1160, 1510, 1550),
        "Allowed future launch",
        "Only a local preview entrypoint, not imported by the app. It starts the existing widget directly.",
        GREEN,
        body_font=F_SMALL,
    )
    g.card(
        (1890, 1160, 3010, 1550),
        "Blocked boundary crossing",
        "No Home, router, navigation, provider, data layer, assets, tests or integration hooks.",
        RED,
        body_font=F_SMALL,
    )
    g.card(
        (700, 1840, 2700, 2120),
        "Gate rule",
        "If a later slice touches anything except the isolated launch file, it is no longer M16-AP-safe.",
        PURPLE,
        body_font=F_SMALL,
    )
    g.save("isolated_launch_boundary")


def allowed_vs_blocked_launch_files() -> None:
    g = Diagram(
        "Allowed vs Blocked Launch Files",
        "The future launch slice has one possible file and many hard no-go paths.",
    )
    g.card(
        (170, 360, 1540, 820),
        "Already exists",
        "lib/features/world/local_world/ui/widgets/bank_meaning_puzzle_preview.dart\n\nDo not alter unless the later prompt explicitly allows it.",
        BLUE,
        body_font=F_TINY,
    )
    g.card(
        (1860, 360, 3230, 820),
        "Future allowed file",
        "lib/features/world/local_world/ui/widgets/bank_meaning_puzzle_preview_main.dart\n\nOnly after separate implementation approval.",
        GREEN,
        body_font=F_TINY,
    )
    g.card(
        (170, 1130, 1540, 1570),
        "Blocked lib paths",
        "lib/main.dart\nApp router\nHome screen\nNavigation\nProvider\nData layer\nSupabase access",
        RED,
        body_font=F_SMALL,
    )
    g.card(
        (1860, 1130, 3230, 1570),
        "Blocked non-lib paths",
        "assets/\ntest/\nintegration_test/\nScreenshots\nRuntime config\nPersistence files",
        RED,
        body_font=F_SMALL,
    )
    g.card(
        (680, 1840, 2720, 2110),
        "Scope check",
        "A later launch slice should show exactly one new Dart file plus clean assets/test/integration_test status.",
        PURPLE,
        body_font=F_SMALL,
    )
    g.save("allowed_vs_blocked_launch_files")


def launch_acceptance_gate() -> None:
    g = Diagram(
        "Launch Acceptance Gate",
        "The later local startpoint must pass every gate before it can be reviewed.",
    )
    checks = [
        ("Read docs", "328, 336, 348, 347, 345, 346 and the preview widget.", BLUE),
        ("Create one file", "Only bank_meaning_puzzle_preview_main.dart.", TEAL),
        ("Keep local", "MaterialApp(home: BankMeaningPuzzlePreview()).", GREEN),
        ("No wiring", "No route, Home, router, provider or app import.", RED),
        ("No effects", "No persistence, SRS, assets, BuildState or frame_started.", RED),
        ("Verify", "format, analyze new file, diff check, status, scope check.", YELLOW),
    ]
    for idx, (title, body, color) in enumerate(checks):
        x = 170 + (idx % 3) * 1070
        y = 380 + (idx // 3) * 570
        g.card((x, y, x + 910, y + 400), title, body, color, body_font=F_SMALL)
    g.arrow((625, 810), (1230, 810))
    g.arrow((1695, 810), (2300, 810))
    g.arrow((2760, 810), (2760, 940))
    g.arrow((2300, 1380), (1695, 1380))
    g.arrow((1230, 1380), (625, 1380))
    g.card(
        (620, 1810, 2780, 2090),
        "Acceptance result",
        "If any gate fails, keep the preview widget code-only and do not create a launch target.",
        PURPLE,
        body_font=F_SMALL,
    )
    g.save("launch_acceptance_gate")


def play_first_launch_check() -> None:
    g = Diagram(
        "Play-First Launch Check",
        "The launch must preserve the game moment already proven in the widget.",
    )
    checks = [
        ("Scene", "Am Fluss macht Tali kurz Pause.", GREEN),
        ("Choices", "Sitzbank, Geldinstitut, Flussufer.", BLUE),
        ("Local action", "User chooses the meaning door locally.", TEAL),
        ("Feedback", "Context clarity, not score or XP.", YELLOW),
        ("Safe exits", "Later, Codex, Backlog, Change.", PURPLE),
        ("No pressure", "No timer, streak, review duty or vocabulary-test framing.", RED),
    ]
    for idx, (title, body, color) in enumerate(checks):
        x = 170 + (idx % 3) * 1070
        y = 430 + (idx // 2 if False else idx // 3) * 610
        g.card((x, y, x + 910, y + 420), title, body, color, body_font=F_SMALL)
    g.card(
        (520, 1780, 2880, 2110),
        "M16T-PLAY-008 decision",
        "The Play-First check was applied in M16-AO and is now required for any local launch, so the ID can move to done.",
        GREEN,
        body_font=F_SMALL,
    )
    g.save("play_first_launch_check")


def contact_sheet(stems: list[str]) -> None:
    width, height = 3600, 3900
    img = Image.new("RGB", (width, height), BG)
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle((50, 40, width - 50, height - 40), radius=30, fill=BG, outline=BORDER, width=2)
    draw.text((95, 90), "M16-AP Visual Contact Sheet", fill=INK, font=F_TITLE)
    draw.text(
        (95, 175),
        "PNG + SVG documentation previews for the Bank preview launch gate.",
        fill=MUTED,
        font=F_SUB,
    )
    svg: list[str] = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">',
        f'<rect width="{width}" height="{height}" fill="{BG}"/>',
        f'<rect x="50" y="40" width="{width - 100}" height="{height - 80}" rx="30" ry="30" fill="{BG}" stroke="{BORDER}" stroke-width="2"/>',
        f'<text x="95" y="152" font-family="{SVG_FONT}" font-size="{F_TITLE.size}" font-weight="700" fill="{INK}">M16-AP Visual Contact Sheet</text>',
        f'<text x="95" y="204" font-family="{SVG_FONT}" font-size="{F_SUB.size}" fill="{MUTED}">PNG + SVG documentation previews for the Bank preview launch gate.</text>',
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
        "launch_option_matrix",
        "isolated_launch_boundary",
        "allowed_vs_blocked_launch_files",
        "launch_acceptance_gate",
        "play_first_launch_check",
    ]
    launch_option_matrix()
    isolated_launch_boundary()
    allowed_vs_blocked_launch_files()
    launch_acceptance_gate()
    play_first_launch_check()
    contact_sheet(stems)


if __name__ == "__main__":
    main()
