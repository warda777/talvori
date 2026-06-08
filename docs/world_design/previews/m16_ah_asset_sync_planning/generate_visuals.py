from __future__ import annotations

from dataclasses import dataclass
from html import escape
from pathlib import Path
import xml.etree.ElementTree as ET

from PIL import Image, ImageDraw, ImageFont


OUT = Path(__file__).resolve().parent

W = 2600
H = 1900
BG = "#f7f8f3"
PANEL = "#ffffff"
INK = "#20302b"
MUTED = "#62706a"
BORDER = "#d6dfd7"
ARROW = "#91a49e"
GREEN = "#68ad7a"
BLUE = "#68a6ca"
TEAL = "#5bb8aa"
YELLOW = "#d5b856"
RED = "#d96f68"
PURPLE = "#8e7ac8"
GRAY = "#93a19b"
FOOTER = (
    "documentation preview only / no app integration / no route / no assets / "
    "no persistence / no sync implementation / no BuildState / no frame_started"
)
SVG_FONT = "Arial, Helvetica, sans-serif"


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


F_TITLE = font(60, True)
F_SUB = font(30)
F_HEAD = font(34, True)
F_BODY = font(25)
F_SMALL = font(22)
F_TINY = font(19)
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
        self.rounded_rect((44, 34, self.width - 44, self.height - 34), 28, BG, BORDER, 2)
        self.text(self.title, 82, 82, F_TITLE, INK, bold=True, max_width=self.width - 164)
        self.text(self.subtitle, 82, 164, F_SUB, MUTED, max_width=self.width - 164)
        self.line((82, self.height - 104), (self.width - 82, self.height - 104), BORDER, 2)
        self.text(FOOTER, 82, self.height - 70, F_FOOT, MUTED, max_width=self.width - 164)

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

    def arrow(self, start: tuple[int, int], end: tuple[int, int], color: str = ARROW) -> None:
        self.line(start, end, color, 6)
        x1, y1 = start
        x2, y2 = end
        if abs(x2 - x1) >= abs(y2 - y1):
            points = (
                [(x2, y2), (x2 - 28, y2 - 17), (x2 - 28, y2 + 17)]
                if x2 >= x1
                else [(x2, y2), (x2 + 28, y2 - 17), (x2 + 28, y2 + 17)]
            )
        else:
            points = (
                [(x2, y2), (x2 - 17, y2 - 28), (x2 + 17, y2 - 28)]
                if y2 >= y1
                else [(x2, y2), (x2 - 17, y2 + 28), (x2 + 17, y2 + 28)]
            )
        self.polygon(points, color)

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
        pad = 26
        self.rounded_rect(box, 18, PANEL, BORDER, 2)
        self.rounded_rect((x1, y1, x2, y1 + 14), 8, accent)
        title_end = self.text(title, x1 + pad, y1 + 34, title_font, INK, bold=True, max_width=x2 - x1 - 2 * pad)
        self.text(body, x1 + pad, max(title_end + 16, y1 + 96), body_font, MUTED, max_width=x2 - x1 - 2 * pad)

    def pill(self, x: int, y: int, text: str, color: str) -> None:
        tw = text_width(self.draw, text, F_SMALL)
        box = (x, y, x + tw + 42, y + 42)
        self.rounded_rect(box, 21, color)
        self.text(text, x + 21, y + 8, F_SMALL, "#ffffff", max_width=tw + 8)

    def save(self, stem: str) -> None:
        self.img.save(OUT / f"{stem}.png")
        self.svg.append("</svg>")
        svg_text = "\n".join(self.svg)
        (OUT / f"{stem}.svg").write_text(svg_text, encoding="utf-8")
        ET.fromstring(svg_text)


def asset_scope_naming_rules() -> None:
    g = Diagram(
        "Asset Scope And Naming Rules",
        "M16-AH prepares rules only. No asset file, app asset path, BuildState or frame_started is unlocked.",
    )
    cards = [
        ((120, 310, 680, 560), "Docs visual", "Lives under docs/world_design/previews.\nNever a game asset or screenshot substitute.", GREEN),
        ((740, 310, 1200, 560), "Placeholder", "Later only after its own gate.\nCannot mask missing UX or safety decisions.", BLUE),
        ((1260, 310, 1760, 560), "Prototype asset", "Only in a separately scoped local prototype.\nNo production meaning by default.", TEAL),
        ((1820, 310, 2480, 560), "Production asset", "Needs source, license, purpose, style, mobile and policy review.", PURPLE),
    ]
    for box, title, body, color in cards:
        g.card(box, title, body, color, body_font=F_SMALL)
    g.card(
        (190, 740, 1220, 1040),
        "Naming plan",
        "Use snake_case, clear theme/family/state/variant, no spaces, no final.png or test.png, and no ambiguous filenames.",
        YELLOW,
    )
    g.card(
        (1380, 740, 2410, 1040),
        "Source and license plan",
        "Every later asset needs known source, license status, allowed use, purpose, scope and review before any app path.",
        BLUE,
    )
    g.arrow((1220, 890), (1380, 890))
    g.card(
        (280, 1245, 2320, 1515),
        "Hard stop",
        "No automatic asset from word, semantics, plot, capability, review, BuildChoice or reward. No files under assets in this slice.",
        RED,
    )
    g.pill(490, 1610, "doc preview only", GREEN)
    g.pill(900, 1610, "source required", BLUE)
    g.pill(1320, 1610, "license required", PURPLE)
    g.pill(1760, 1610, "no auto asset", RED)
    g.save("asset_scope_naming_rules")


def asset_review_checklist() -> None:
    g = Diagram(
        "Asset Review Checklist",
        "A later real asset prompt must pass every review area before app use is even considered.",
        height=2050,
    )
    items = [
        ("Source known", "origin, creator, generator or internal source documented", GREEN),
        ("License clear", "use rights and restrictions understood before file creation", BLUE),
        ("Use allowed", "Talvori purpose matches license and product scope", TEAL),
        ("Purpose scoped", "asset solves a reviewed need, not a missing UX choice", YELLOW),
        ("Sensitive-safe", "no deco, no reward, no dramatic symbol for sensitive topics", RED),
        ("Mobile readable", "not too small; tap, label and clutter risk checked", PURPLE),
        ("Style fit", "fits Talvori visual direction and does not confuse docs with product", GREEN),
        ("No auto word asset", "word, outcome, plot or capability cannot generate an image", RED),
        ("Correct name", "snake_case, meaningful family/state/variant, no test/final names", BLUE),
        ("Correct path", "docs preview stays in docs; app asset waits for asset gate", TEAL),
        ("Visual QA", "text, labels, frames and contact sheet are readable", YELLOW),
        ("No runtime release", "no BuildState, persistence, route, sync or frame_started", RED),
    ]
    x_positions = [110, 910, 1710]
    y_positions = [300, 555, 810, 1065]
    idx = 0
    for y in y_positions:
        for x in x_positions:
            title, body, color = items[idx]
            g.card((x, y, x + 690, y + 205), title, body, color, body_font=F_TINY, title_font=F_HEAD)
            idx += 1
    g.card(
        (310, 1515, 2290, 1705),
        "Gate result",
        "If any review answer is unclear, the safe result is Backlog, Later, ContextCard, CodexOnly or a separate follow-up gate.",
        RED,
        body_font=F_SMALL,
    )
    g.save("asset_review_checklist")


def offline_sync_conflict_map() -> None:
    g = Diagram(
        "Offline And Sync Conflict Map",
        "Offline-first is likely important later, but M16-AH creates only conflict rules, not sync code.",
        height=2050,
    )
    left = [
        ("Offline practice", "word practiced locally\nno SRS write without gate"),
        ("Offline semantic edit", "sense or outcome changed\nmay conflict with remote"),
        ("Offline review choice", "confirm, change, later or hide\nmust remain explainable"),
        ("Local island change", "resizing or slot idea\nno auto migration"),
    ]
    right = [
        ("Remote state", "older or newer data\nnot automatically truth"),
        ("Sensitive update", "policy or safety changed\nvisible output can be blocked"),
        ("Blueprint invalid", "candidate or asset no longer valid\nreturn to review/backlog"),
        ("Multi-device conflict", "different choices across devices\nneeds safe resolution"),
    ]
    for i, (title, body) in enumerate(left):
        g.card((110, 310 + i * 275, 760, 535 + i * 275), title, body, BLUE, body_font=F_SMALL)
    for i, (title, body) in enumerate(right):
        g.card((1850, 310 + i * 275, 2500, 535 + i * 275), title, body, PURPLE, body_font=F_SMALL)
    g.card(
        (940, 650, 1660, 1090),
        "Conflict review",
        "Safety first.\nNo silent overwrite.\nNo automatic placement.\nNo BuildState.\nNo SRS or word_progress write.\nUse safe fallback.",
        RED,
    )
    for y in [425, 700, 975, 1250]:
        g.arrow((760, y), (940, 825))
        g.arrow((1660, 825), (1850, y))
    g.card(
        (390, 1545, 2210, 1740),
        "Safe destination",
        "Review, Backlog, Later, CodexOnly, ContextCard, Hide or SensitiveGated. Productive merge logic waits for a separate data gate.",
        GREEN,
        body_font=F_SMALL,
    )
    g.save("offline_sync_conflict_map")


def safe_conflict_resolution_flow() -> None:
    g = Diagram(
        "Safe Conflict Resolution Flow",
        "Conflict handling must protect safety, data integrity, reversibility and user trust before any world effect.",
        height=2050,
    )
    steps = [
        ("Conflict detected", "local and remote disagree", BLUE),
        ("Safety check", "sensitive or policy risk wins immediately", RED),
        ("Protect learning data", "no SRS or word_progress write without gate", PURPLE),
        ("Explain history", "show what changed; no silent overwrite", TEAL),
        ("Reversible choice", "Change, Later, Backlog, Codex or ContextCard", GREEN),
        ("Later gate", "persistence, sync and tests only after own gate", YELLOW),
    ]
    boxes = [
        (110, 350, 500, 590),
        (610, 350, 1000, 590),
        (1110, 350, 1510, 590),
        (1610, 350, 2010, 590),
        (760, 900, 1230, 1165),
        (1360, 900, 1830, 1165),
    ]
    for (title, body, color), box in zip(steps, boxes):
        g.card(box, title, body, color, body_font=F_SMALL)
    g.arrow((500, 470), (610, 470))
    g.arrow((1000, 470), (1110, 470))
    g.arrow((1510, 470), (1610, 470))
    g.arrow((1805, 590), (1210, 900))
    g.arrow((1230, 1030), (1360, 1030))
    g.card(
        (300, 1390, 2300, 1665),
        "Never as conflict resolution",
        "No automatic irreversible decision, no world placement, no BuildState, no frame_started, no asset, no persistence write, no safety override by user choice.",
        RED,
        body_font=F_SMALL,
    )
    g.save("safe_conflict_resolution_flow")


def remaining_open_items_closure() -> None:
    g = Diagram(
        "Remaining Open Items Closure",
        "M16-AH closes the last normal open M16-T items while keeping blocked gates blocked.",
    )
    g.card(
        (150, 330, 760, 650),
        "Before M16-AH",
        "2 open normal items:\nM16T-ASSET-004\nM16T-DATA-004\nProgress 79.0%",
        YELLOW,
    )
    g.card(
        (970, 330, 1630, 650),
        "M16-AH rules",
        "Asset source/license/naming review.\nOffline/sync conflict safety.\nNo implementation.",
        BLUE,
    )
    g.card(
        (1850, 330, 2450, 650),
        "After M16-AH",
        "0 open normal items.\n87 done, 18 partial, 12 blocked, 2 outsourced.\nProgress 80.7%",
        GREEN,
    )
    g.arrow((760, 490), (970, 490))
    g.arrow((1630, 490), (1850, 490))
    g.card(
        (170, 885, 1210, 1210),
        "M16T-ASSET-004",
        "Done as planning: naming, source, license and review checklist exist. Still no asset path, no asset pipeline and no production asset.",
        GREEN,
    )
    g.card(
        (1390, 885, 2430, 1210),
        "M16T-DATA-004",
        "Done as planning: conflict types and safe resolution rules exist. Still no persistence, no local DB writes and no sync implementation.",
        GREEN,
    )
    g.card(
        (360, 1450, 2240, 1645),
        "Still blocked",
        "Data model, persistence, migration, Supabase writes, app integration, routes, assets, screenshots, BuildState and frame_started remain separate gates.",
        RED,
        body_font=F_SMALL,
    )
    g.save("remaining_open_items_closure")


def contact_sheet() -> None:
    files = [
        "asset_scope_naming_rules.png",
        "asset_review_checklist.png",
        "offline_sync_conflict_map.png",
        "safe_conflict_resolution_flow.png",
        "remaining_open_items_closure.png",
    ]
    cw, ch = 3400, 2700
    img = Image.new("RGB", (cw, ch), BG)
    draw = ImageDraw.Draw(img)
    svg: list[str] = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{cw}" height="{ch}" viewBox="0 0 {cw} {ch}">',
        f'<rect width="{cw}" height="{ch}" fill="{BG}"/>',
    ]

    def draw_text(text: str, x: int, y: int, fnt: ImageFont.ImageFont, fill: str, max_width: int, bold: bool = False) -> int:
        lines = wrap_lines(draw, text, max_width, fnt)
        line_height = fnt.size + 8
        for idx, line in enumerate(lines):
            py = y + idx * line_height
            draw.text((x, py), line, fill=fill, font=fnt)
            weight = "700" if bold else "400"
            svg.append(
                f'<text x="{x}" y="{py + fnt.size}" font-family="{SVG_FONT}" font-size="{fnt.size}" font-weight="{weight}" fill="{fill}">{escape(line)}</text>'
            )
        return y + len(lines) * line_height

    draw.rounded_rectangle((45, 35, cw - 45, ch - 35), radius=28, fill=BG, outline=BORDER, width=2)
    svg.append(f'<rect x="45" y="35" width="{cw - 90}" height="{ch - 70}" rx="28" ry="28" fill="{BG}" stroke="{BORDER}" stroke-width="2"/>')
    draw_text("M16-AH Contact Sheet", 90, 84, F_TITLE, INK, cw - 180, bold=True)
    draw_text("Asset naming/licensing and offline/sync planning visuals. Documentation only.", 90, 164, F_SUB, MUTED, cw - 180)

    positions = [
        (120, 305),
        (1185, 305),
        (2250, 305),
        (560, 1335),
        (1625, 1335),
    ]
    thumb_w, thumb_h = 880, 640
    label_h = 70
    for file_name, (x, y) in zip(files, positions):
        source = Image.open(OUT / file_name)
        source.thumbnail((thumb_w, thumb_h), Image.Resampling.LANCZOS)
        frame = (x - 20, y - 20, x + thumb_w + 20, y + thumb_h + label_h + 38)
        draw.rounded_rectangle(frame, radius=22, fill=PANEL, outline=BORDER, width=2)
        svg.append(
            f'<rect x="{frame[0]}" y="{frame[1]}" width="{frame[2] - frame[0]}" height="{frame[3] - frame[1]}" rx="22" ry="22" fill="{PANEL}" stroke="{BORDER}" stroke-width="2"/>'
        )
        px = x + (thumb_w - source.width) // 2
        py = y
        img.paste(source, (px, py))
        draw_text(file_name, x, y + thumb_h + 18, F_SMALL, INK, thumb_w, bold=True)

    footer_y = ch - 112
    draw.line((90, footer_y - 30, cw - 90, footer_y - 30), fill=BORDER, width=2)
    svg.append(f'<line x1="90" y1="{footer_y - 30}" x2="{cw - 90}" y2="{footer_y - 30}" stroke="{BORDER}" stroke-width="2"/>')
    draw_text(FOOTER, 90, footer_y, F_FOOT, MUTED, cw - 180)
    img.save(OUT / "00_contact_sheet.png")
    svg.append("</svg>")
    svg_text = "\n".join(svg)
    (OUT / "00_contact_sheet.svg").write_text(svg_text, encoding="utf-8")
    ET.fromstring(svg_text)


def main() -> None:
    asset_scope_naming_rules()
    asset_review_checklist()
    offline_sync_conflict_map()
    safe_conflict_resolution_flow()
    remaining_open_items_closure()
    contact_sheet()


if __name__ == "__main__":
    main()
