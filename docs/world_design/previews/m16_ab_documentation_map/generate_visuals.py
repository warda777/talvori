from __future__ import annotations

from pathlib import Path
from typing import Iterable

from PIL import Image, ImageDraw, ImageFont


OUT = Path(__file__).resolve().parent
W, H = 2400, 1800
BG = "#f5f7f2"
SURFACE = "#fbfcf8"
PANEL = "#ffffff"
INK = "#23302d"
MUTED = "#65746f"
LINE = "#d7ded5"
GREEN = "#69ad84"
BLUE = "#6ea6c8"
YELLOW = "#d7b85f"
RED = "#d97670"
PURPLE = "#9987c5"
TEAL = "#61b8ad"
FOOTER = "documentation preview only / no code / no app integration / no assets / no screenshots / no commit"


def font(size: int, bold: bool = False) -> ImageFont.ImageFont:
    paths = [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/Library/Fonts/Arial Bold.ttf" if bold else "/Library/Fonts/Arial.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    ]
    for path in paths:
        try:
            return ImageFont.truetype(path, size=size)
        except OSError:
            pass
    return ImageFont.load_default()


TITLE = font(54, True)
SUB = font(27)
H2 = font(32, True)
H3 = font(24, True)
BODY = font(22)
SMALL = font(19)
TINY = font(17)


def text_size(draw: ImageDraw.ImageDraw, text: str, fnt: ImageFont.ImageFont) -> tuple[int, int]:
    box = draw.textbbox((0, 0), text, font=fnt)
    return box[2] - box[0], box[3] - box[1]


def wrap(draw: ImageDraw.ImageDraw, text: str, fnt: ImageFont.ImageFont, width: int) -> list[str]:
    lines: list[str] = []
    for raw in text.split("\n"):
        words = raw.split()
        if not words:
            lines.append("")
            continue
        line = words[0]
        for word in words[1:]:
            candidate = f"{line} {word}"
            if text_size(draw, candidate, fnt)[0] <= width:
                line = candidate
            else:
                lines.append(line)
                line = word
        lines.append(line)
    return lines


def draw_wrapped(
    draw: ImageDraw.ImageDraw,
    xy: tuple[int, int],
    text: str,
    fnt: ImageFont.ImageFont,
    width: int,
    fill: str = MUTED,
    spacing: int = 7,
) -> int:
    x, y = xy
    for line in wrap(draw, text, fnt, width):
        draw.text((x, y), line, font=fnt, fill=fill)
        y += text_size(draw, line or " ", fnt)[1] + spacing
    return y


def base(title: str, subtitle: str) -> tuple[Image.Image, ImageDraw.ImageDraw]:
    img = Image.new("RGB", (W, H), BG)
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle((58, 48, W - 58, H - 58), radius=34, fill=SURFACE, outline=LINE, width=3)
    draw.text((100, 88), title, font=TITLE, fill=INK)
    draw_wrapped(draw, (102, 164), subtitle, SUB, W - 204, MUTED, 8)
    draw.line((100, H - 126, W - 100, H - 126), fill=LINE, width=2)
    draw.text((100, H - 90), FOOTER, font=TINY, fill=MUTED)
    return img, draw


def card(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    title: str,
    body: str,
    color: str,
    body_font: ImageFont.ImageFont = SMALL,
    title_font: ImageFont.ImageFont = H3,
) -> None:
    x1, y1, x2, y2 = box
    draw.rounded_rectangle(box, radius=22, fill=PANEL, outline=LINE, width=3)
    draw.rounded_rectangle((x1, y1, x2, y1 + 13), radius=8, fill=color)
    draw.text((x1 + 24, y1 + 28), title, font=title_font, fill=INK)
    draw_wrapped(draw, (x1 + 24, y1 + 72), body, body_font, x2 - x1 - 48)


def pill(draw: ImageDraw.ImageDraw, xy: tuple[int, int], label: str, color: str) -> None:
    x, y = xy
    tw, th = text_size(draw, label, SMALL)
    draw.rounded_rectangle((x, y, x + tw + 34, y + th + 18), radius=17, fill=color)
    draw.text((x + 17, y + 9), label, font=SMALL, fill="#ffffff")


def arrow(draw: ImageDraw.ImageDraw, start: tuple[int, int], end: tuple[int, int], color: str = "#899891") -> None:
    draw.line((start, end), fill=color, width=6)
    sx, sy = start
    ex, ey = end
    if abs(ex - sx) >= abs(ey - sy):
        sign = 1 if ex > sx else -1
        draw.polygon([(ex, ey), (ex - sign * 24, ey - 15), (ex - sign * 24, ey + 15)], fill=color)
    else:
        sign = 1 if ey > sy else -1
        draw.polygon([(ex, ey), (ex - 15, ey - sign * 24), (ex + 15, ey - sign * 24)], fill=color)


def documentation_map_overview() -> Path:
    img, draw = base(
        "Documentation Map Overview",
        "M16-AB turns the growing World Design documentation into a readable map: each future slice starts from the right rule set.",
    )
    items = [
        ("Readiness / Dashboard", "327 review\n328 M16-T backlog\n329 scrum-lite\n336 reading rules", BLUE),
        ("Minimal Loop", "330 learning loop\n335 learning states\nno SRS writes", GREEN),
        ("Word Outcomes", "323 examples\n331 outcome gate\nCodex / Queue / Fallbacks", PURPLE),
        ("Reward / Queue", "332 budgets\nno pressure\nLater always allowed", GREEN),
        ("Semantics / Routing", "321 audit\n333 priority stack\n270 / 284 routing", TEAL),
        ("Companion / Sensitive", "334 companion policy\n274 sensitive rules\nno advice / no pressure", RED),
        ("World / Plot / Build", "318 capacity\n320 global matrix\n272 capabilities", YELLOW),
        ("Container / Depth", "256 / 264 depth flows\n276 tiny objects\nno clutter", TEAL),
        ("Mobile / A11y", "276 clutter rules\n277 visual review\nsmall screens first", BLUE),
        ("Assets", "289 asset scope\ntemplate guardrails\nno assets now", RED),
        ("Data / Backend", "326 profile concept\n327 blockers\nno persistence now", PURPLE),
        ("Research / Visual QA", "329 research gate\n322 visual QA\npreview PNGs only", YELLOW),
    ]
    x0, y0 = 110, 305
    card_w, card_h = 520, 220
    gap_x, gap_y = 50, 48
    for i, (title, body, color) in enumerate(items):
        col = i % 4
        row = i // 4
        x = x0 + col * (card_w + gap_x)
        y = y0 + row * (card_h + gap_y)
        card(draw, (x, y, x + card_w, y + card_h), title, body, color)
    card(
        draw,
        (270, 1250, 2130, 1460),
        "Core rule",
        "A documentation gate can prepare scope, visuals and prompt rules. It never grants code, app integration, assets, persistence, SRS changes, BuildState or frame_started.",
        RED,
    )
    out = OUT / "documentation_map_overview.png"
    img.save(out)
    return out


def slice_type_reading_matrix() -> Path:
    img, draw = base(
        "Slice Type Reading Matrix",
        "Every slice type has a minimum reading set. Extra docs are allowed; skipping the core set is not.",
    )
    groups = [
        ("Learning / Word", "Learning Loop: 328, 327, 330, 331, 332, 335, 329\nWord Outcome: 328, 330, 331, 333, 321, 323, 274, 276", GREEN),
        ("Reward / Queue", "Reward Queue: 328, 330, 331, 332, 334, 327, 326\nReview must keep Later, safe defaults and budget.", BLUE),
        ("Semantics / AI", "Semantics AI: 328, 321, 323, 326, 333, 335, 274, 276, 284\nProvider calls need own gate.", TEAL),
        ("Companion / Sensitive", "Companion Sensitive: 328, 334, 274, 333, 331, 332, 327\nNo advice, guilt or sensitive triggers.", RED),
        ("World / Plot / Build", "World Plot: 328, 321, 318, 320, 272, 273, 276, 331, 333\nBuild-Wheel remains blocked.", YELLOW),
        ("Container / Mobile", "Container Depth: 328, 331, 333, 276, 256, 257, 264, 265\nMobile A11y: 328, 276, 277.", PURPLE),
        ("Assets / Data", "Asset: 328, 289, 274, 276, 320, template\nData: 328, 326, 327, 333, 335 plus own gates.", RED),
        ("Research / Review", "Research: 328, 329, 327 and question\nCommit Review: 328, 336, expected files, status, diff, scope.", BLUE),
    ]
    x0, y0 = 125, 315
    card_w, card_h = 1020, 260
    gap_x, gap_y = 70, 55
    for i, (title, body, color) in enumerate(groups):
        col = i % 2
        row = i // 2
        x = x0 + col * (card_w + gap_x)
        y = y0 + row * (card_h + gap_y)
        card(draw, (x, y, x + card_w, y + card_h), title, body, color, SMALL, H2)
    pill(draw, (420, 1590), "mandatory minimum", BLUE)
    pill(draw, (860, 1590), "extra docs allowed", GREEN)
    pill(draw, (1260, 1590), "stop rules still win", RED)
    out = OUT / "slice_type_reading_matrix.png"
    img.save(out)
    return out


def prompt_output_contract() -> Path:
    img, draw = base(
        "Prompt / Output Contract",
        "M16-AB makes future prompts and final reports predictable: IDs, reading list, stop rules, checks and dashboard updates stay visible.",
    )
    left = (150, 330, 1040, 1130)
    right = (1360, 330, 2250, 1130)
    card(
        draw,
        left,
        "Future prompt must include",
        "Sprint-ID\nGoal\nAffected M16-T IDs\nRequired reading\nExpected files\nNon-goals\nStop rules\nChecks\nNo commit rule\n328 update when IDs change",
        BLUE,
        BODY,
        H2,
    )
    card(
        draw,
        right,
        "Future output must report",
        "Created / changed files\nChanged M16-T IDs\nNew progress\nVisual-QA\nStop-rule proof\ngit diff --check\ngit status --short\nScope check when docs-only",
        GREEN,
        BODY,
        H2,
    )
    arrow(draw, (1075, 725), (1320, 725), TEAL)
    card(
        draw,
        (475, 1285, 1925, 1485),
        "Dashboard link",
        "If an ID changes, update 328. If no ID changes, say 328 stayed unchanged. Documentation still does not grant code.",
        PURPLE,
    )
    out = OUT / "prompt_output_contract.png"
    img.save(out)
    return out


def dashboard_update_flow() -> Path:
    img, draw = base(
        "Dashboard Update Flow",
        "M16T-DASH-004 becomes operational: after every ID-changing slice, 328 is updated before reporting.",
    )
    steps = [
        ("1. Identify IDs", "affected, completed, partial, open, blocked", BLUE),
        ("2. Update rows", "status table and current stand", GREEN),
        ("3. Recount", "open / partial / done / blocked / outsourced", TEAL),
        ("4. Area dashboard", "update affected areas", PURPLE),
        ("5. Next IDs", "refresh recommendations", YELLOW),
        ("6. Report", "progress and ID changes", BLUE),
    ]
    x0, y0 = 135, 410
    card_w, card_h = 330, 250
    boxes = []
    for i, (title, body, color) in enumerate(steps):
        x = x0 + i * 365
        box = (x, y0, x + card_w, y0 + card_h)
        boxes.append(box)
        card(draw, box, title, body, color)
    for left, right in zip(boxes, boxes[1:]):
        arrow(draw, (left[2] + 16, y0 + 125), (right[0] - 16, y0 + 125))
    card(
        draw,
        (300, 900, 2100, 1135),
        "If IDs are unchanged",
        "The final answer says the checklist stayed unchanged. If IDs changed, stale dashboard numbers are a failing check.",
        RED,
    )
    card(
        draw,
        (520, 1265, 1880, 1460),
        "M16-AB result",
        "DOC-001, DOC-002, DASH-004, META-002, META-003, META-004, GIT-001 and GIT-002 are now done.",
        GREEN,
    )
    out = OUT / "dashboard_update_flow.png"
    img.save(out)
    return out


def commit_review_guardrails() -> Path:
    img, draw = base(
        "Commit / Review Guardrails",
        "M16-AB operationalizes status, diff and scope checks. Commit remains separate and explicit.",
    )
    steps = [
        ("git status", "before commit and final report", BLUE),
        ("git diff --check", "no whitespace or patch issues", GREEN),
        ("scope check", "expected files only", TEAL),
        ("stop rules", "no app, route, assets, data", RED),
        ("review", "unexpected files block commit", YELLOW),
        ("approval", "commit only after explicit ask", PURPLE),
    ]
    positions = [
        (120, 350, 520, 585),
        (620, 350, 1020, 585),
        (1120, 350, 1520, 585),
        (1620, 350, 2220, 585),
        (520, 860, 980, 1105),
        (1390, 860, 1880, 1105),
    ]
    for (title, body, color), box in zip(steps, positions):
        card(draw, box, title, body, color)
    arrow(draw, (535, 468), (605, 468))
    arrow(draw, (1035, 468), (1105, 468))
    arrow(draw, (1535, 468), (1605, 468))
    arrow(draw, (1920, 600), (1680, 840), RED)
    arrow(draw, (995, 985), (1368, 985), TEAL)
    card(
        draw,
        (360, 1300, 2040, 1485),
        "Docs-only scope check",
        "For planning/visual slices, lib, assets, test and integration_test must stay unchanged unless the prompt explicitly names an exception.",
        RED,
    )
    out = OUT / "commit_review_guardrails.png"
    img.save(out)
    return out


def contact_sheet(paths: Iterable[Path]) -> Path:
    paths = list(paths)
    cw, ch = 2400, 2200
    img = Image.new("RGB", (cw, ch), BG)
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle((58, 48, cw - 58, ch - 58), radius=34, fill=SURFACE, outline=LINE, width=3)
    draw.text((100, 88), "M16-AB Contact Sheet", font=TITLE, fill=INK)
    draw_wrapped(
        draw,
        (102, 164),
        "Documentation map, reading rules, prompt/output contract, dashboard flow and commit guardrails.",
        SUB,
        cw - 204,
    )
    thumb_w, thumb_h = 660, 405
    x_positions = [145, 870, 1595]
    y_positions = [310, 880]
    for idx, path in enumerate(paths):
        row = idx // 3
        col = idx % 3
        x = x_positions[col]
        y = y_positions[row]
        frame = (x - 18, y - 18, x + thumb_w + 18, y + thumb_h + 70)
        draw.rounded_rectangle(frame, radius=20, fill=PANEL, outline=LINE, width=3)
        thumb = Image.open(path).convert("RGB")
        thumb.thumbnail((thumb_w, thumb_h))
        tx = x + (thumb_w - thumb.width) // 2
        ty = y + (thumb_h - thumb.height) // 2
        img.paste(thumb, (tx, ty))
        draw_wrapped(draw, (x, y + thumb_h + 22), path.name, SMALL, thumb_w, INK, 6)
    card(
        draw,
        (300, 1560, 2100, 1760),
        "Visual-QA checklist",
        "Text containment, inner padding, card spacing, no overlap, footer separation and no cropped content checked manually after generation.",
        GREEN,
    )
    draw.line((100, ch - 126, cw - 100, ch - 126), fill=LINE, width=2)
    draw.text((100, ch - 90), FOOTER, font=TINY, fill=MUTED)
    out = OUT / "00_contact_sheet.png"
    img.save(out)
    return out


def main() -> None:
    paths = [
        documentation_map_overview(),
        slice_type_reading_matrix(),
        prompt_output_contract(),
        dashboard_update_flow(),
        commit_review_guardrails(),
    ]
    contact_sheet(paths)
    for path in [OUT / "00_contact_sheet.png", *paths]:
        print(path)


if __name__ == "__main__":
    main()
