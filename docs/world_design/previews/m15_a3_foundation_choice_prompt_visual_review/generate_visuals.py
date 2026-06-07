from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


OUT_DIR = Path(__file__).resolve().parent
W, H = 2200, 1500

BG = "#f5f6f1"
CARD = "#ffffff"
INK = "#26323a"
MUTED = "#627179"
LINE = "#c8d0cc"
BLUE = "#2e5d8d"
BLUE_SOFT = "#dce9f6"
GREEN = "#2f7a50"
GREEN_SOFT = "#dcefdc"
AMBER = "#956b14"
AMBER_SOFT = "#f5e8c6"
RED = "#9f3b34"
RED_SOFT = "#f1d8d6"
PURPLE = "#66508f"
PURPLE_SOFT = "#e6def3"
GRAY_SOFT = "#edf0f0"
FOOTER = "Documentation preview only / no code / no assets / no implementation"


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    candidates = [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/System/Library/Fonts/Supplemental/Helvetica Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Helvetica.ttf",
        "/Library/Fonts/Arial Bold.ttf" if bold else "/Library/Fonts/Arial.ttf",
    ]
    for path in candidates:
        if Path(path).exists():
            return ImageFont.truetype(path, size)
    return ImageFont.load_default(size)


F_TITLE = font(54, True)
F_SUB = font(28)
F_H2 = font(36, True)
F_H3 = font(28, True)
F_BODY = font(25)
F_SMALL = font(21)
F_TINY = font(18)
F_FOOTER = font(20)


def text_size(draw: ImageDraw.ImageDraw, text: str, fnt: ImageFont.ImageFont) -> tuple[int, int]:
    box = draw.textbbox((0, 0), text, font=fnt)
    return box[2] - box[0], box[3] - box[1]


def wrap_lines(draw: ImageDraw.ImageDraw, text: str, fnt: ImageFont.ImageFont, max_w: int) -> list[str]:
    words = text.split()
    if not words:
        return [""]
    lines: list[str] = []
    current = ""
    for word in words:
        probe = word if not current else f"{current} {word}"
        if text_size(draw, probe, fnt)[0] <= max_w:
            current = probe
            continue
        if current:
            lines.append(current)
        current = word
    if current:
        lines.append(current)
    return lines


def draw_wrapped(
    draw: ImageDraw.ImageDraw,
    xy: tuple[int, int],
    text: str,
    fnt: ImageFont.ImageFont,
    fill: str,
    max_w: int,
    line_gap: int = 8,
    max_h: int | None = None,
) -> int:
    x, y = xy
    line_h = text_size(draw, "Ag", fnt)[1] + line_gap
    lines: list[str] = []
    for raw in str(text).split("\n"):
        lines.extend(wrap_lines(draw, raw, fnt, max_w))
    if max_h is not None:
        max_lines = max(1, max_h // line_h)
        if len(lines) > max_lines:
            lines = lines[:max_lines]
            last = lines[-1]
            while text_size(draw, last + "...", fnt)[0] > max_w and len(last) > 5:
                last = last[:-1]
            lines[-1] = last + "..."
    for line in lines:
        draw.text((x, y), line, font=fnt, fill=fill)
        y += line_h
    return y


def canvas(title: str, subtitle: str) -> tuple[Image.Image, ImageDraw.ImageDraw]:
    img = Image.new("RGB", (W, H), BG)
    draw = ImageDraw.Draw(img)
    draw.text((85, 56), title, font=F_TITLE, fill=INK)
    draw.text((88, 122), subtitle, font=F_SUB, fill=MUTED)
    draw.line((85, 178, W - 85, 178), fill=LINE, width=2)
    draw.text((85, H - 70), FOOTER, font=F_FOOTER, fill=MUTED)
    return img, draw


def panel(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    title: str,
    body: list[str],
    accent: str,
    soft: str,
    label: str | None = None,
) -> None:
    x, y, w, h = box
    draw.rounded_rectangle((x, y, x + w, y + h), radius=10, fill=CARD, outline=accent, width=3)
    draw.rectangle((x, y, x + w, y + 24), fill=soft)
    draw.text((x + 30, y + 48), title, font=F_H2, fill=accent)
    yy = y + 108
    for item in body:
        draw.ellipse((x + 32, yy + 10, x + 44, yy + 22), fill=accent)
        yy = draw_wrapped(draw, (x + 62, yy), item, F_BODY, INK, w - 98, max_h=62)
        yy += 18
    if label:
        lx, ly = x + 30, y + h - 92
        draw.rounded_rectangle((lx, ly, x + w - 30, y + h - 30), radius=8, fill=soft, outline=accent, width=2)
        draw_wrapped(draw, (lx + 18, ly + 17), label, F_SMALL, accent, w - 96, max_h=46)


def mini_card(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    title: str,
    body: str,
    accent: str,
    soft: str,
) -> None:
    x, y, w, h = box
    draw.rounded_rectangle((x, y, x + w, y + h), radius=8, fill=CARD, outline=accent, width=3)
    draw.rectangle((x, y, x + w, y + 18), fill=soft)
    title_end = draw_wrapped(draw, (x + 22, y + 34), title, F_H3, accent, w - 44, line_gap=5, max_h=105)
    body_y = max(y + 86, title_end + 10)
    draw_wrapped(draw, (x + 22, body_y), body, F_SMALL, INK, w - 44, max_h=h - (body_y - y) - 24)


def flow_box(
    draw: ImageDraw.ImageDraw,
    x: int,
    y: int,
    w: int,
    h: int,
    title: str,
    body: str,
    accent: str,
    soft: str,
) -> tuple[int, int, int, int]:
    mini_card(draw, (x, y, w, h), title, body, accent, soft)
    return (x, y, w, h)


def arrow(draw: ImageDraw.ImageDraw, start: tuple[int, int], end: tuple[int, int], color: str = MUTED) -> None:
    x1, y1 = start
    x2, y2 = end
    draw.line((x1, y1, x2, y2), fill=color, width=4)
    angle = math.atan2(y2 - y1, x2 - x1)
    size = 16
    points = [
        (x2, y2),
        (x2 - size * math.cos(angle - 0.45), y2 - size * math.sin(angle - 0.45)),
        (x2 - size * math.cos(angle + 0.45), y2 - size * math.sin(angle + 0.45)),
    ]
    draw.polygon(points, fill=color)


def stamp_no_code(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], text: str) -> None:
    x, y, w, h = box
    draw.rounded_rectangle((x, y, x + w, y + h), radius=10, fill=RED_SOFT, outline=RED, width=3)
    draw.text((x + 28, y + 26), "NO CODE NOW", font=F_H2, fill=RED)
    draw_wrapped(draw, (x + 28, y + 82), text, F_BODY, RED, w - 56, max_h=h - 104)


def save(img: Image.Image, name: str) -> None:
    img.save(OUT_DIR / name, "PNG", optimize=True)


def make_01() -> None:
    img, draw = canvas(
        "M15-A3 Prompt Scope Boundary",
        "Docs 310-311: later minimal slice draft vs blocked scope",
    )
    panel(
        draw,
        (110, 250, 900, 850),
        "Allowed Later Minimal Slice",
        [
            "Local preview or demo only, only after explicit user approval.",
            "Short Tali/Vori intro placeholder.",
            "Three Foundation cards: Home / Everyday, School / Learning, Garden / Near nature.",
            "Local in-memory selection state only.",
            "Visible 'change later' note and safe exit.",
            "No real onboarding and no final start island.",
        ],
        GREEN,
        GREEN_SOFT,
        "Allowed later does not mean allowed now.",
    )
    panel(
        draw,
        (1190, 250, 900, 850),
        "Blocked Scope",
        [
            "No Flutter/Dart changes from M15-A3.",
            "No persistence, Supabase writes, local database writes or word_progress changes.",
            "No runtime config, app-wide navigation or final UI.",
            "No assets, no asset files under assets, no screenshots.",
            "No automatic word placement, Reward Bridge, build state or frame_started.",
            "No tests unless a later prompt explicitly approves them.",
        ],
        RED,
        RED_SOFT,
        "Blocked now: implementation, assets, tests and frame_started.",
    )
    stamp_no_code(
        draw,
        (585, 1165, 1030, 170),
        "M15-A3 reviews the prompt draft and documentation visuals only. It does not execute the later prompt.",
    )
    save(img, "01_prompt_scope_boundary.png")


def make_02() -> None:
    img, draw = canvas(
        "M15-A3 Later Implementation Prompt Gate Flow",
        "M15-A2 draft can only become code after explicit approval and a separate prompt",
    )
    steps = [
        ("M15-A2 Draft", "Prompt text exists, but is not released."),
        ("User Explicit Approval", "Andreas must actively start a later implementation block."),
        ("Separate Implementation Prompt", "Scope and files are re-checked before edits."),
        ("Minimal Local Preview", "Only local demo/in-memory Foundation Choice."),
        ("Review", "git status, diff check and scope proof."),
        ("No Commit Until Checked", "Commit only after a separate explicit request."),
    ]
    x0, y0 = 100, 360
    boxes = []
    palette = [
        (BLUE, BLUE_SOFT),
        (GREEN, GREEN_SOFT),
        (PURPLE, PURPLE_SOFT),
        (AMBER, AMBER_SOFT),
        (BLUE, BLUE_SOFT),
        (RED, RED_SOFT),
    ]
    for index, (title, body) in enumerate(steps):
        x = x0 + index * 335
        color, soft = palette[index]
        boxes.append(flow_box(draw, x, y0, 285, 230, title, body, color, soft))
    for left, right in zip(boxes, boxes[1:]):
        arrow(draw, (left[0] + left[2], left[1] + 115), (right[0] - 18, right[1] + 115))
    stamp_no_code(
        draw,
        (355, 780, 1490, 210),
        "M15-A2 and M15-A3 do not execute implementation. The later copy-paste prompt is still inert until explicitly approved.",
    )
    mini_card(
        draw,
        (505, 1075, 1190, 190),
        "Gate Meaning",
        "The gate protects the Foundation Choice idea from drifting into final onboarding, persistence, assets or frame_started.",
        GREEN,
        GREEN_SOFT,
    )
    save(img, "02_later_implementation_prompt_gate_flow.png")


def make_03() -> None:
    img, draw = canvas(
        "M15-A3 Foundation Choice Minimal Slice Risk Map",
        "Risk review for the later prompt draft: every risk needs a hard guardrail",
    )
    risks = [
        ("Final UI risk", "Guardrail: preview/demo language only; no final onboarding screen."),
        ("Persistence risk", "Guardrail: local in-memory only; no database, Supabase or word_progress."),
        ("Navigation risk", "Guardrail: no app-wide route or Home-Zentrale coupling without new gate."),
        ("Asset risk", "Guardrail: no icons, images, game assets or files under assets."),
        ("Runtime config risk", "Guardrail: no config, schema, flags or rollout settings."),
        ("Word placement risk", "Guardrail: no automatic placement and no ThemeIsland creation."),
        ("frame_started risk", "Guardrail: no build state, no Rohbau, no world construction."),
    ]
    positions = [
        (110, 260),
        (610, 260),
        (1110, 260),
        (1610, 260),
        (360, 690),
        (860, 690),
        (1360, 690),
    ]
    colors = [
        (RED, RED_SOFT),
        (AMBER, AMBER_SOFT),
        (PURPLE, PURPLE_SOFT),
        (BLUE, BLUE_SOFT),
        (AMBER, AMBER_SOFT),
        (GREEN, GREEN_SOFT),
        (RED, RED_SOFT),
    ]
    for (title, body), (x, y), (color, soft) in zip(risks, positions, colors):
        mini_card(draw, (x, y, 410, 300), title, body, color, soft)
    stamp_no_code(
        draw,
        (435, 1105, 1330, 180),
        "Decision: the draft is useful only if the later implementation prompt repeats these guardrails before any edit.",
    )
    save(img, "03_foundation_choice_minimal_slice_risk_map.png")


def make_04() -> None:
    img, draw = canvas(
        "M15-A3 Stop Rules Summary",
        "Global stop map for Foundation Choice prompt review",
    )
    stops = [
        ("No Flutter / Dart", "No UI code, widgets or app files from this block."),
        ("No tests", "No tests, no widget tests and no harness implementation."),
        ("No app integration", "No routes, Home changes or real onboarding."),
        ("No persistence", "No Supabase, SQLite, SRS or word_progress writes."),
        ("No runtime config", "No flags, config files, schemas or rollout state."),
        ("No assets", "No game assets and no files under assets."),
        ("No automatic placement", "Foundation choice does not place words."),
        ("No frame_started", "No build state, no Rohbau and no construction."),
    ]
    x_values = [120, 620, 1120, 1620]
    y_values = [280, 655]
    for index, (title, body) in enumerate(stops):
        x = x_values[index % 4]
        y = y_values[index // 4]
        mini_card(draw, (x, y, 420, 285), title, body, RED if index in (0, 1, 5, 7) else BLUE, RED_SOFT if index in (0, 1, 5, 7) else BLUE_SOFT)
    mini_card(
        draw,
        (420, 1060, 1360, 210),
        "Review Result Boundary",
        "M15-A3 may create documentation PNGs and the review document only. It creates no implementation release.",
        GREEN,
        GREEN_SOFT,
    )
    save(img, "04_stop_rules_summary.png")


def make_contact_sheet() -> None:
    files = [
        "01_prompt_scope_boundary.png",
        "02_later_implementation_prompt_gate_flow.png",
        "03_foundation_choice_minimal_slice_risk_map.png",
        "04_stop_rules_summary.png",
    ]
    thumb_w, thumb_h = 840, 500
    sheet = Image.new("RGB", (2200, 1500), BG)
    draw = ImageDraw.Draw(sheet)
    draw.text((85, 56), "M15-A3 Contact Sheet", font=F_TITLE, fill=INK)
    draw.text((88, 122), "Foundation Choice Prompt Visual Review documentation previews", font=F_SUB, fill=MUTED)
    draw.line((85, 178, W - 85, 178), fill=LINE, width=2)
    for index, name in enumerate(files):
        src = Image.open(OUT_DIR / name).convert("RGB")
        src.thumbnail((thumb_w, thumb_h))
        card_x = 105 + (index % 2) * 1010
        card_y = 235 + (index // 2) * 585
        draw.rounded_rectangle((card_x, card_y, card_x + 960, card_y + 535), radius=8, fill=CARD, outline=LINE, width=2)
        img_x = card_x + (960 - src.width) // 2
        img_y = card_y + 28
        sheet.paste(src, (img_x, img_y))
        draw_wrapped(draw, (card_x + 34, card_y + 475), name, F_SMALL, INK, 890, max_h=38)
    draw.text((85, H - 70), FOOTER, font=F_FOOTER, fill=MUTED)
    save(sheet, "00_contact_sheet.png")


def main() -> None:
    make_01()
    make_02()
    make_03()
    make_04()
    make_contact_sheet()


if __name__ == "__main__":
    main()
