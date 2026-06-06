from __future__ import annotations

import math
from pathlib import Path
from textwrap import wrap

from PIL import Image, ImageDraw, ImageFont


OUT_DIR = Path(__file__).resolve().parent
W, H = 2200, 1500
BG = "#f5f6f1"
INK = "#26323a"
MUTED = "#627179"
LINE = "#c9d1cd"
CARD = "#ffffff"
BLUE = "#2e5d8d"
BLUE_SOFT = "#dce9f6"
GREEN = "#2f7a50"
GREEN_SOFT = "#dcefdc"
PURPLE = "#66508f"
PURPLE_SOFT = "#e6def3"
AMBER = "#956b14"
AMBER_SOFT = "#f5e8c6"
RED = "#9f3b34"
RED_SOFT = "#f1d8d6"
GRAY_SOFT = "#edf0f0"
FOOTER = "Documentation preview only / no code / no assets / no implementation release"


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


F_TITLE = font(52, True)
F_SUB = font(28)
F_H2 = font(34, True)
F_H3 = font(26, True)
F_BODY = font(24)
F_SMALL = font(20)
F_FOOTER = font(20)


def text_size(draw: ImageDraw.ImageDraw, text: str, fnt: ImageFont.ImageFont) -> tuple[int, int]:
    box = draw.textbbox((0, 0), text, font=fnt)
    return box[2] - box[0], box[3] - box[1]


def wrap_lines(draw: ImageDraw.ImageDraw, text: str, fnt: ImageFont.ImageFont, max_w: int) -> list[str]:
    if not text:
        return [""]
    words = text.split()
    lines: list[str] = []
    current = ""
    for word in words:
        probe = word if not current else f"{current} {word}"
        if text_size(draw, probe, fnt)[0] <= max_w:
            current = probe
        else:
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
            while text_size(draw, last + "...", fnt)[0] > max_w and len(last) > 6:
                last = last[:-1]
            lines[-1] = last + "..."
    for line in lines:
        draw.text((x, y), line, font=fnt, fill=fill)
        y += line_h
    return y


def canvas(title: str, subtitle: str) -> tuple[Image.Image, ImageDraw.ImageDraw]:
    img = Image.new("RGB", (W, H), BG)
    draw = ImageDraw.Draw(img)
    draw.text((85, 58), title, font=F_TITLE, fill=INK)
    draw.text((88, 122), subtitle, font=F_SUB, fill=MUTED)
    draw.line((85, 175, W - 85, 175), fill=LINE, width=2)
    draw.text((85, H - 70), FOOTER, font=F_FOOTER, fill=MUTED)
    return img, draw


def card(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    title: str,
    body: list[str] | str,
    accent: str = BLUE,
    soft: str = BLUE_SOFT,
    label: str | None = None,
) -> None:
    x, y, w, h = box
    draw.rounded_rectangle((x, y, x + w, y + h), radius=8, fill=CARD, outline=accent, width=3)
    draw.rectangle((x, y, x + w, y + 22), fill=soft)
    draw.text((x + 28, y + 48), title, font=F_H3, fill=accent)
    yy = y + 92
    lines = body if isinstance(body, list) else [body]
    items: list[str] = []
    for item in lines:
        items.extend(str(item).split("\n"))
    for item in items:
        item = item.strip()
        if not item:
            yy += 10
            continue
        if ":" in item:
            head, rest = item.split(":", 1)
            draw.text((x + 28, yy), head.strip(), font=F_SMALL, fill=INK)
            yy += 30
            yy = draw_wrapped(draw, (x + 28, yy), rest.strip(), F_SMALL, INK, w - 56, max_h=max(30, h - (yy - y) - 28))
        else:
            yy = draw_wrapped(draw, (x + 28, yy), item, F_SMALL, INK, w - 56, max_h=max(30, h - (yy - y) - 28))
        yy += 16
    if label:
        lx, ly = x + 28, y + h - 82
        draw.rounded_rectangle((lx, ly, x + w - 28, y + h - 28), radius=8, fill=soft, outline=accent, width=2)
        draw_wrapped(draw, (lx + 18, ly + 14), label, F_SMALL, accent, w - 92, max_h=42)


def badge(draw: ImageDraw.ImageDraw, xy: tuple[int, int], text: str, fill: str, outline: str) -> None:
    x, y = xy
    tw, th = text_size(draw, text, F_SMALL)
    pad_x, pad_y = 16, 9
    draw.rounded_rectangle((x, y, x + tw + pad_x * 2, y + th + pad_y * 2), radius=6, fill=fill, outline=outline, width=2)
    draw.text((x + pad_x, y + pad_y), text, font=F_SMALL, fill=outline)


def arrow(draw: ImageDraw.ImageDraw, start: tuple[int, int], end: tuple[int, int], color: str = MUTED, width: int = 4) -> None:
    x1, y1 = start
    x2, y2 = end
    draw.line((x1, y1, x2, y2), fill=color, width=width)
    angle = math.atan2(y2 - y1, x2 - x1)
    size = 16
    pts = [
        (x2, y2),
        (x2 - size * math.cos(angle - 0.45), y2 - size * math.sin(angle - 0.45)),
        (x2 - size * math.cos(angle + 0.45), y2 - size * math.sin(angle + 0.45)),
    ]
    draw.polygon(pts, fill=color)


def flow_box(draw: ImageDraw.ImageDraw, x: int, y: int, w: int, h: int, title: str, body: str, color: str, soft: str) -> tuple[int, int, int, int]:
    draw.rounded_rectangle((x, y, x + w, y + h), radius=10, fill=CARD, outline=color, width=3)
    draw.rectangle((x, y, x + w, y + 18), fill=soft)
    draw.text((x + 22, y + 32), title, font=F_H3, fill=color)
    draw_wrapped(draw, (x + 22, y + 76), body, F_SMALL, INK, w - 44, max_h=h - 92)
    return (x, y, w, h)


def save(img: Image.Image, name: str) -> None:
    img.save(OUT_DIR / name, "PNG", optimize=True)


def make_01() -> None:
    img, draw = canvas("M14-V1 ThemeIsland Capability Overview", "Docs 283: capability waves, gates and blocked implementation paths")
    cards = [
        ("Foundation", "Home / Everyday\nSchool / Learning\nGarden / Near nature", "preview needed", BLUE, BLUE_SOFT),
        ("Expansion Wave 1", "Food / Cafe\nShopping / Supply\nLand / Farm", "preview + scope gate", GREEN, GREEN_SOFT),
        ("Expansion Wave 2", "Coast / Harbor\nOutdoor / Mountains\nLeisure / Sport", "mobile complexity gate", PURPLE, PURPLE_SOFT),
        ("System-Heavy", "City / Travel\nWork / Workshop\nTech / Digital", "system concept needed", AMBER, AMBER_SOFT),
        ("Sensitive / Special", "Health / Culture\nReligion / Politics\nCourt / Police / Hospital", "policy gate / blocked", RED, RED_SOFT),
    ]
    x = 85
    for title, body, gate, color, soft in cards:
        card(draw, (x, 255, 380, 760), title, [f"Scope: {body}", f"Gate: {gate}", "Not allowed: no app integration, no final ThemeIsland base, no assets"], color, soft, "planning only")
        x += 410
    draw.rounded_rectangle((160, 1085, W - 160, 1245), radius=8, fill="#ffffff", outline=LINE, width=2)
    draw_wrapped(draw, (190, 1125), "Freeze meaning: stable enough for planning conversations, never a code release or asset production order.", F_BODY, INK, W - 380)
    save(img, "01_theme_island_capability_overview.png")


def make_02() -> None:
    img, draw = canvas("M14-V1 Word-to-Island Decision Pipeline", "Docs 284, 292, 299, 300: user-controlled suggestion flow")
    steps = [
        ("Word received", "learned, imported or manual"),
        ("Sense / context", "ambiguity needs user choice"),
        ("Safety", "sensitive and abstract stay neutral"),
        ("Theme + depth", "suggest island and detail level"),
        ("User choice", "confirm, change, Codex, Blueprint, later"),
        ("Safe result", "planning state, not placement"),
    ]
    x, y = 100, 330
    boxes = []
    for i, (t, b) in enumerate(steps):
        color, soft = [BLUE, PURPLE, RED, GREEN, AMBER, BLUE][i], [BLUE_SOFT, PURPLE_SOFT, RED_SOFT, GREEN_SOFT, AMBER_SOFT, BLUE_SOFT][i]
        boxes.append(flow_box(draw, x + i * 335, y, 285, 220, t, b, color, soft))
    for i in range(len(boxes) - 1):
        bx = boxes[i]
        nx = boxes[i + 1]
        arrow(draw, (bx[0] + bx[2], bx[1] + 110), (nx[0] - 16, nx[1] + 110))
    outcomes = [
        ("PlacementCandidate", "only after user confirms"),
        ("Codex", "safe knowledge fallback"),
        ("Blueprint", "mark as idea, no build state"),
        ("Backlog / later", "no penalty, no loss"),
    ]
    ox = 210
    for t, b in outcomes:
        card(draw, (ox, 770, 395, 250), t, b, GREEN if t != "Blueprint" else AMBER, GREEN_SOFT if t != "Blueprint" else AMBER_SOFT)
        ox += 450
    draw.rounded_rectangle((310, 1095, W - 310, 1250), radius=8, fill=RED_SOFT, outline=RED, width=2)
    draw_wrapped(draw, (340, 1130), "Hard guardrail: Talvori suggests. The user decides. No automatic visible placement, no routing data structure, no runtime config.", F_BODY, RED, W - 680)
    save(img, "02_word_to_island_decision_pipeline.png")


def make_03() -> None:
    img, draw = canvas("M14-V1 Device Accessibility Gate Map", "Docs 285, 294, 303, 304: device profiles and required preview checks")
    devices = [
        ("Small Phone", "critical lead case\nstacked cards\nshort labels", BLUE, BLUE_SOFT),
        ("Standard Phone", "primary portrait case\nnormal spacing\nsafe exit visible", GREEN, GREEN_SOFT),
        ("Large Phone", "more air\nsame complexity\nno extra decisions", PURPLE, PURPLE_SOFT),
        ("Later cases", "landscape risk\ntablet optional\nseparate review", AMBER, AMBER_SOFT),
    ]
    x = 110
    for t, b, c, s in devices:
        card(draw, (x, 250, 460, 305), t, b, c, s, "device profile")
        x += 510
    checks = [
        ("Text containment", "No text leaves cards, panels or frames."),
        ("Tap targets", "Buttons and cards stay large and separated."),
        ("Safe area", "No primary action hidden near device edge."),
        ("Tali/Vori collision", "Companion never covers choices or fallback."),
        ("Fallback visibility", "Later, Codex, Blueprint and Backlog stay visible."),
    ]
    y = 680
    for i, (t, b) in enumerate(checks):
        c, s = [BLUE, GREEN, PURPLE, AMBER, RED][i], [BLUE_SOFT, GREEN_SOFT, PURPLE_SOFT, AMBER_SOFT, RED_SOFT][i]
        card(draw, (145 + (i % 3) * 640, y + (i // 3) * 255, 560, 205), t, b, c, s)
    draw.rounded_rectangle((150, 1225, W - 150, 1320), radius=8, fill="#ffffff", outline=LINE, width=2)
    draw_wrapped(draw, (180, 1250), "Harness note: this is review planning only. It does not create tests, screenshots, Flutter code or compliance release.", F_BODY, INK, W - 360)
    save(img, "03_device_accessibility_gate_map.png")


def make_04() -> None:
    img, draw = canvas("M14-V1 Container QA Overlay Map", "Docs 286, 293, 301, 302: zones for readable container previews")
    cx, cy, cw, ch = 380, 285, 1180, 820
    draw.rounded_rectangle((cx, cy, cx + cw, cy + ch), radius=12, fill="#ffffff", outline=BLUE, width=4)
    draw.rectangle((cx, cy, cx + cw, cy + 28), fill=BLUE_SOFT)
    draw.text((cx + 35, cy + 48), "Container Bounds", font=F_H2, fill=BLUE)
    draw.rounded_rectangle((cx + 360, cy + 175, cx + 790, cy + 480), radius=12, fill=GREEN_SOFT, outline=GREEN, width=3)
    draw.text((cx + 430, cy + 300), "Focus Object Zone", font=F_H3, fill=GREEN)
    draw.rounded_rectangle((cx + 70, cy + 185, cx + 300, cy + 430), radius=10, fill=GRAY_SOFT, outline=MUTED, width=2)
    draw.text((cx + 95, cy + 285), "Secondary\nObjects", font=F_SMALL, fill=INK)
    draw.rounded_rectangle((cx + 850, cy + 185, cx + 1080, cy + 430), radius=10, fill=GRAY_SOFT, outline=MUTED, width=2)
    draw.text((cx + 880, cy + 285), "Overflow /\nBlocked", font=F_SMALL, fill=INK)
    draw.rounded_rectangle((cx + 330, cy + 520, cx + 825, cy + 600), radius=8, fill=PURPLE_SOFT, outline=PURPLE, width=2)
    draw.text((cx + 385, cy + 545), "Label Zone: short, not covering objects", font=F_SMALL, fill=PURPLE)
    draw.rounded_rectangle((cx + 280, cy + 650, cx + 900, cy + 750), radius=8, fill=AMBER_SOFT, outline=AMBER, width=2)
    draw.text((cx + 370, cy + 684), "Primary Action / Tap Target Zone", font=F_H3, fill=AMBER)
    draw.rounded_rectangle((cx + 930, cy + 655, cx + 1100, cy + 745), radius=8, fill=BLUE_SOFT, outline=BLUE, width=2)
    draw.text((cx + 960, cy + 682), "Pages", font=F_H3, fill=BLUE)
    draw.rounded_rectangle((cx + 35, cy + 640, cx + 240, cy + 780), radius=8, fill=RED_SOFT, outline=RED, width=2)
    draw.text((cx + 58, cy + 682), "Tali/Vori\nExclusion", font=F_SMALL, fill=RED)
    legend = [
        ("Good", "few focus objects, large tap zones, labels contained"),
        ("Adjust", "pagination or layout needed before preview approval"),
        ("Blocked", "inventory list, tiny taps, companion collision"),
    ]
    lx = 160
    for t, b in legend:
        color = GREEN if t == "Good" else AMBER if t == "Adjust" else RED
        soft = GREEN_SOFT if t == "Good" else AMBER_SOFT if t == "Adjust" else RED_SOFT
        card(draw, (lx, 1160, 570, 190), t, b, color, soft)
        lx += 620
    save(img, "04_container_qa_overlay_map.png")


def make_05() -> None:
    img, draw = canvas("M14-V1 Sensitive Policy Flow", "Doc 287: safe routing for sensitive, abstract and potentially heavy words")
    steps = [
        ("Sensitive / abstract word", "illness, law, prayer, freedom, memory", RED, RED_SOFT),
        ("Category", "health, legal, politics, religion, body, trauma", PURPLE, PURPLE_SOFT),
        ("Safety tier", "CodexOnly, ContextCard, UserChoice, Blocked", BLUE, BLUE_SOFT),
        ("User choice", "private, neutral, not visible, later", GREEN, GREEN_SOFT),
        ("Safe route", "Codex / ContextCard / Backlog / Blocked", AMBER, AMBER_SOFT),
    ]
    boxes = []
    x = 150
    for t, b, c, s in steps:
        boxes.append(flow_box(draw, x, 335, 345, 230, t, b, c, s))
        x += 395
    for i in range(len(boxes) - 1):
        bx, nx = boxes[i], boxes[i + 1]
        arrow(draw, (bx[0] + bx[2], bx[1] + 115), (nx[0] - 14, nx[1] + 115))
    blockers = [
        "no automatic visualisation",
        "no medical / legal / political advice",
        "no companion drama",
        "no streak, retention or paywall pressure",
        "no public showcase by default",
    ]
    y = 760
    for i, b in enumerate(blockers):
        card(draw, (180 + (i % 3) * 610, y + (i // 3) * 210, 540, 170), "Blocked", b, RED, RED_SOFT)
    save(img, "05_sensitive_policy_flow.png")


def make_06() -> None:
    img, draw = canvas("M14-V1 Growth Timer Fairness Flow", "Doc 288: motivation without decay, guilt, FOMO or pay-to-win")
    steps = [
        ("Learning action", "user learns or returns", BLUE, BLUE_SOFT),
        ("Soft reward", "visible progress, no punishment", GREEN, GREEN_SOFT),
        ("No decay", "plants do not die during pauses", GREEN, GREEN_SOFT),
        ("Friendly comeback", "welcome back, no blame", PURPLE, PURPLE_SOFT),
        ("No pressure", "no hard streak, no FOMO", AMBER, AMBER_SOFT),
        ("No pay-to-win", "no premium rescue or speed pressure", RED, RED_SOFT),
    ]
    boxes = []
    x = 95
    for t, b, c, s in steps:
        boxes.append(flow_box(draw, x, 360, 310, 220, t, b, c, s))
        x += 350
    for i in range(len(boxes) - 1):
        bx, nx = boxes[i], boxes[i + 1]
        arrow(draw, (bx[0] + bx[2], bx[1] + 110), (nx[0] - 12, nx[1] + 110))
    card(draw, (190, 760, 560, 270), "Allowed", ["Visual growth can celebrate learning.", "Comeback can be warm and optional.", "Daily moments stay voluntary."], GREEN, GREEN_SOFT)
    card(draw, (820, 760, 560, 270), "Blocked", ["Plants dying during pause.", "Streak penalties or guilt wording.", "Premium acceleration pressure."], RED, RED_SOFT)
    card(draw, (1450, 760, 560, 270), "Gate", ["Growth or timer mechanics need fairness review, device review and own implementation prompt."], AMBER, AMBER_SOFT)
    save(img, "06_growth_timer_fairness_flow.png")


def make_07() -> None:
    img, draw = canvas("M14-V1 Asset Scope Gate Map", "Doc 289: planning does not automatically become asset production")
    top = flow_box(draw, 170, 310, 390, 210, "Planning docs", "taxonomy, roadmap, routing, product previews", BLUE, BLUE_SOFT)
    mid = flow_box(draw, 780, 310, 390, 210, "Asset candidate?", "first ask if an asset is actually needed", PURPLE, PURPLE_SOFT)
    gate = flow_box(draw, 1390, 310, 390, 210, "Scope gate", "purpose, device, accessibility, policy, fairness", AMBER, AMBER_SOFT)
    arrow(draw, (560, 415), (765, 415))
    arrow(draw, (1170, 415), (1375, 415))
    outcomes = [
        ("Priority 0", "existing approved mock assets only: base, foundation_started, foundation_complete", GREEN, GREEN_SOFT),
        ("Priority 1", "product, QA and device preview plans before new assets", BLUE, BLUE_SOFT),
        ("Blocked", "new build states, sensitive, companion, growth pressure, social showcase", RED, RED_SOFT),
    ]
    x = 230
    for t, b, c, s in outcomes:
        card(draw, (x, 760, 540, 330), t, b, c, s, "no automatic production")
        x += 610
    draw.rounded_rectangle((260, 1175, W - 260, 1285), radius=8, fill="#ffffff", outline=LINE, width=2)
    draw_wrapped(draw, (290, 1205), "Key rule: no asset files under assets/ from M14-V1. PNGs here are documentation previews only.", F_BODY, INK, W - 580)
    save(img, "07_asset_scope_gate_map.png")


def make_08() -> None:
    img, draw = canvas("M14-V1 M13 Readiness Gate Summary", "Docs 290, 295, 296: planning usable, but no implementation release")
    steps = [
        ("M13 chain", "roadmap, onboarding, capabilities, word flow", BLUE, BLUE_SOFT),
        ("Readiness review", "usable as planning basis", GREEN, GREEN_SOFT),
        ("Scope freeze", "non-final planning stability", PURPLE, PURPLE_SOFT),
        ("Candidate gate", "later candidates only", AMBER, AMBER_SOFT),
        ("Decision", "no code, no assets, no runtime config", RED, RED_SOFT),
    ]
    boxes = []
    x = 180
    for t, b, c, s in steps:
        boxes.append(flow_box(draw, x, 350, 330, 220, t, b, c, s))
        x += 390
    for i in range(len(boxes) - 1):
        bx, nx = boxes[i], boxes[i + 1]
        arrow(draw, (bx[0] + bx[2], bx[1] + 110), (nx[0] - 14, nx[1] + 110))
    card(draw, (210, 760, 570, 300), "Planning usable", ["Hybrid onboarding direction", "Word-to-Island needs user choice", "Container/detail needed for tiny objects"], GREEN, GREEN_SOFT)
    card(draw, (840, 760, 570, 300), "Needs review", ["Device previews", "Container QA overlays", "Product preview refinements"], AMBER, AMBER_SOFT)
    card(draw, (1470, 760, 570, 300), "Blocked for implementation", ["final UI", "assets", "runtime config", "frame_started"], RED, RED_SOFT)
    save(img, "08_m13_readiness_gate_summary.png")


def make_09() -> None:
    img, draw = canvas("M14-V1 Foundation Choice Product Flow", "Docs 291, 294, 297, 298: first learning focus, reversible and non-final")
    steps = [
        ("Welcome", "Tali/Vori says hello, no pressure"),
        ("Cards", "Home, School, Garden as learning focus"),
        ("Focus", "one card gets short explanation"),
        ("Select", "user chooses, not final island"),
        ("Confirm", "choice stays reversible"),
        ("Later", "safe exit / planning state"),
    ]
    x = 110
    for i, (t, b) in enumerate(steps):
        c, s = [BLUE, GREEN, PURPLE, AMBER, GREEN, BLUE][i], [BLUE_SOFT, GREEN_SOFT, PURPLE_SOFT, AMBER_SOFT, GREEN_SOFT, BLUE_SOFT][i]
        box = flow_box(draw, x + i * 345, 320, 295, 210, t, b, c, s)
        if i < len(steps) - 1:
            arrow(draw, (box[0] + box[2], box[1] + 105), (x + (i + 1) * 345 - 14, box[1] + 105))
    cards = [
        ("Home / Everyday", "familiar words\nnot forced house start", BLUE, BLUE_SOFT),
        ("School / Learning", "clear learning context\nnot punishment school", PURPLE, PURPLE_SOFT),
        ("Garden / Nature", "calm nature focus\nno timer promise", GREEN, GREEN_SOFT),
    ]
    x = 250
    for t, b, c, s in cards:
        card(draw, (x, 720, 500, 320), t, b, c, s, "can change later")
        x += 600
    draw.rounded_rectangle((300, 1140, W - 300, 1265), radius=8, fill="#ffffff", outline=LINE, width=2)
    draw_wrapped(draw, (330, 1172), "Guardrail: user chooses a first learning focus, not a final start island, not a house build, not a premium path.", F_BODY, INK, W - 660)
    save(img, "09_foundation_choice_product_flow.png")


def make_10() -> None:
    img, draw = canvas("M14-V1 Word-to-Island Product Preview Cards", "Docs 299, 300: example routes and guardrails without automatic placement")
    cards = [
        ("Direct word", "apple, book, chair\nRoute: suggestion + user confirm\nGuardrail: can change"),
        ("Ambiguous", "bank, mouse, spring\nRoute: sense choice first\nGuardrail: no automatic meaning"),
        ("Tiny object", "pencil, spoon, key, seed\nRoute: container/detail\nGuardrail: not IslandView clutter"),
        ("Building part", "window, door, roof\nRoute: Blueprint candidate\nGuardrail: no build state"),
        ("Sensitive / abstract", "illness, law, freedom, memory\nRoute: Codex/ContextCard\nGuardrail: no visual drama"),
    ]
    x = 90
    for i, (t, b) in enumerate(cards):
        c, s = [GREEN, PURPLE, BLUE, AMBER, RED][i], [GREEN_SOFT, PURPLE_SOFT, BLUE_SOFT, AMBER_SOFT, RED_SOFT][i]
        card(draw, (x, 270, 390, 770), t, b, c, s, "user decides")
        x += 425
    draw.rounded_rectangle((210, 1145, W - 210, 1270), radius=8, fill=RED_SOFT, outline=RED, width=2)
    draw_wrapped(draw, (240, 1175), "Blocked: final routing data structure, runtime config, automatic word placement, final UI, asset or code release.", F_BODY, RED, W - 480)
    save(img, "10_word_to_island_product_preview_cards.png")


def make_11() -> None:
    img, draw = canvas("M14-V1 Container Product Preview Examples", "Docs 301, 302: few focus objects, no inventory list")
    examples = [
        ("School pencil case", "pencil, eraser, ruler\nGood: mini learning moment\nGuardrail: no tiny tap clutter", BLUE, BLUE_SOFT),
        ("Kitchen drawer", "spoon, fork, knife\nGood: focus object instead of list\nGuardrail: knife stays neutral", GREEN, GREEN_SOFT),
        ("Garden bed", "seed, watering can, plant\nGood: nature focus\nGuardrail: no timer or care duty", PURPLE, PURPLE_SOFT),
        ("Harbor box", "compass, map, rope\nGood later, but mobile risk\nGuardrail: needs complexity review", AMBER, AMBER_SOFT),
    ]
    x = 130
    for t, b, c, s in examples:
        card(draw, (x, 280, 470, 620), t, b, c, s, "few objects only")
        x += 520
    card(draw, (370, 1020, 780, 260), "Pagination / Backlog", "When object count grows, show page indicator or move extra words to Codex/Backlog. No endless list, no overfilled grid.", BLUE, BLUE_SOFT)
    card(draw, (1230, 1020, 780, 260), "Blocked", "Inventory UI, tiny taps, hidden labels, companion collision, final ContainerOpenView UI or implementation release.", RED, RED_SOFT)
    save(img, "11_container_product_preview_examples.png")


def make_12() -> None:
    img, draw = canvas("M14-V1 Review Harness Coverage Map", "Docs 303, 304: coverage plan, not tests or screenshots")
    areas = ["Foundation", "Word-to-Island", "Sense", "Fallback", "Container", "Detail", "Tali/Vori", "Blocked state"]
    checks = ["Text fit", "Tap zones", "Safe area", "Collision", "Fallback"]
    x0, y0 = 275, 300
    row_h, col_w = 105, 255
    draw.text((x0, y0 - 70), "Product areas", font=F_H2, fill=INK)
    for j, c in enumerate(checks):
        draw.rounded_rectangle((x0 + 360 + j * col_w, y0 - 35, x0 + 360 + (j + 1) * col_w - 16, y0 + 35), radius=8, fill=BLUE_SOFT, outline=BLUE, width=2)
        draw_wrapped(draw, (x0 + 380 + j * col_w, y0 - 17), c, F_SMALL, BLUE, col_w - 55, max_h=45)
    for i, area in enumerate(areas):
        y = y0 + i * row_h + 70
        draw.rounded_rectangle((x0, y, x0 + 310, y + 72), radius=8, fill=CARD, outline=LINE, width=2)
        draw_wrapped(draw, (x0 + 20, y + 18), area, F_SMALL, INK, 270, max_h=45)
        for j in range(len(checks)):
            fill = GREEN_SOFT if not (area == "Blocked state" and checks[j] == "Tap zones") else AMBER_SOFT
            outline = GREEN if fill == GREEN_SOFT else AMBER
            draw.rounded_rectangle((x0 + 360 + j * col_w, y, x0 + 360 + (j + 1) * col_w - 16, y + 72), radius=8, fill=fill, outline=outline, width=2)
            draw.text((x0 + 455 + j * col_w, y + 20), "review", font=F_SMALL, fill=outline)
    draw.rounded_rectangle((270, 1240, W - 270, 1340), radius=8, fill=RED_SOFT, outline=RED, width=2)
    draw_wrapped(draw, (300, 1268), "Not a test harness. No tests, no widget tests, no screenshots, no Flutter code from this coverage map.", F_BODY, RED, W - 600)
    save(img, "12_review_harness_coverage_map.png")


def make_13() -> None:
    img, draw = canvas("M14-V1 Small Implementation Candidate Gate", "Docs 305, 306: candidate review with no code now")
    items = [
        ("implementation-candidate-later", "Foundation Choice\nonly after own gate + user approval", GREEN, GREEN_SOFT),
        ("harness-candidate-later", "Device/Accessibility Harness\nnot tests, not screenshots", BLUE, BLUE_SOFT),
        ("review-candidate-later", "Word cards, Sense, Fallbacks,\nContainer previews", PURPLE, PURPLE_SOFT),
        ("blocked", "frame_started, new assets,\ngrowth, sensitive, runtime config", RED, RED_SOFT),
    ]
    x = 145
    for t, b, c, s in items:
        card(draw, (x, 295, 475, 560), t, b, c, s, "not a release")
        x += 520
    draw.rounded_rectangle((245, 980, W - 245, 1185), radius=8, fill=AMBER_SOFT, outline=AMBER, width=3)
    draw_wrapped(draw, (285, 1030), "Decision: M14-E/M14-E2 may identify later candidates, but M14-F cannot write code unless the user explicitly approves a separate minimal implementation prompt.", F_BODY, AMBER, W - 570)
    badge(draw, (820, 1245), "No code now", RED_SOFT, RED)
    badge(draw, (1020, 1245), "No assets now", RED_SOFT, RED)
    badge(draw, (1235, 1245), "No frame_started", RED_SOFT, RED)
    save(img, "13_small_implementation_candidate_gate.png")


def make_14() -> None:
    img, draw = canvas("M14-V1 Global Stop Rules Map", "Docs 283-306: central blockers preserved after visual backfill")
    stops = [
        ("No code", "no Flutter/Dart, no app logic"),
        ("No tests", "no tests, no widget tests"),
        ("No screenshots", "documentation PNGs only"),
        ("No assets", "nothing under assets/"),
        ("No final UI", "no app screen, no release UI"),
        ("No runtime config", "no schema, no settings"),
        ("No automatic placement", "user decision stays required"),
        ("No frame_started", "no build state or raw structure"),
        ("No implementation release", "visuals support docs only"),
    ]
    for i, (t, b) in enumerate(stops):
        x = 175 + (i % 3) * 650
        y = 280 + (i // 3) * 300
        card(draw, (x, y, 560, 225), t, b, RED if i in [0, 1, 3, 7] else BLUE, RED_SOFT if i in [0, 1, 3, 7] else BLUE_SOFT)
    draw.rounded_rectangle((260, 1215, W - 260, 1305), radius=8, fill="#ffffff", outline=LINE, width=2)
    draw_wrapped(draw, (290, 1242), "Visual backfill means: clearer documentation diagrams for Andreas, not production UI, not game art, not app integration.", F_BODY, INK, W - 580)
    save(img, "14_global_stop_rules_map.png")


def make_contact_sheet(names: list[str]) -> None:
    thumbs = []
    for name in names:
        img = Image.open(OUT_DIR / name).convert("RGB")
        thumb = img.resize((420, 286))
        thumbs.append((name, thumb))
    sheet_w, sheet_h = 2200, 1900
    sheet = Image.new("RGB", (sheet_w, sheet_h), BG)
    draw = ImageDraw.Draw(sheet)
    draw.text((85, 55), "M14-V1 Visual Backfill Contact Sheet", font=F_TITLE, fill=INK)
    draw.text((88, 120), "Docs 283-306 documentation PNG overview / no code / no assets / no implementation", font=F_SUB, fill=MUTED)
    draw.line((85, 175, sheet_w - 85, 175), fill=LINE, width=2)
    for i, (name, thumb) in enumerate(thumbs):
        col = i % 4
        row = i // 4
        x = 90 + col * 530
        y = 240 + row * 390
        draw.rounded_rectangle((x - 8, y - 8, x + 428, y + 320), radius=8, fill="#ffffff", outline=LINE, width=2)
        sheet.paste(thumb, (x, y))
        draw_wrapped(draw, (x, y + 298), name, F_SMALL, INK, 420, max_h=56)
    draw.text((85, sheet_h - 65), FOOTER, font=F_FOOTER, fill=MUTED)
    sheet.save(OUT_DIR / "00_contact_sheet.png", "PNG", optimize=True)


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    makers = [
        ("01_theme_island_capability_overview.png", make_01),
        ("02_word_to_island_decision_pipeline.png", make_02),
        ("03_device_accessibility_gate_map.png", make_03),
        ("04_container_qa_overlay_map.png", make_04),
        ("05_sensitive_policy_flow.png", make_05),
        ("06_growth_timer_fairness_flow.png", make_06),
        ("07_asset_scope_gate_map.png", make_07),
        ("08_m13_readiness_gate_summary.png", make_08),
        ("09_foundation_choice_product_flow.png", make_09),
        ("10_word_to_island_product_preview_cards.png", make_10),
        ("11_container_product_preview_examples.png", make_11),
        ("12_review_harness_coverage_map.png", make_12),
        ("13_small_implementation_candidate_gate.png", make_13),
        ("14_global_stop_rules_map.png", make_14),
    ]
    for _, fn in makers:
        fn()
    make_contact_sheet([name for name, _ in makers])
    for name, _ in makers:
        print(name)
    print("00_contact_sheet.png")


if __name__ == "__main__":
    main()
