from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

OUT_DIR = Path(__file__).resolve().parent

W, H = 2400, 1600
BG = "#f7f5ef"
INK = "#24312d"
MUTED = "#66736f"
LINE = "#c8d2ca"
GREEN = "#dbeedc"
GREEN_DARK = "#447a53"
BLUE = "#dbe8f4"
BLUE_DARK = "#3f6f91"
YELLOW = "#fff1c9"
YELLOW_DARK = "#8a6a24"
RED = "#f6d9d4"
RED_DARK = "#8f4d45"
PURPLE = "#e8ddf1"
PURPLE_DARK = "#6f5a87"
WHITE = "#fffdf8"
FOOTER = "documentation preview only / no code / no assets / no implementation"


def font(size: int, bold: bool = False):
    candidates = [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/Library/Fonts/Arial Bold.ttf" if bold else "/Library/Fonts/Arial.ttf",
        "/System/Library/Fonts/Supplemental/Helvetica.ttc",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    ]
    for candidate in candidates:
        try:
            return ImageFont.truetype(candidate, size)
        except OSError:
            continue
    return ImageFont.load_default()


TITLE = font(58, True)
SUBTITLE = font(30)
HEAD = font(32, True)
BODY = font(25)
SMALL = font(21)
TINY = font(18)


def text_size(draw, text, fnt):
    box = draw.textbbox((0, 0), text, font=fnt)
    return box[2] - box[0], box[3] - box[1]


def wrap_text(draw, text, fnt, max_width):
    words = text.split()
    lines = []
    current = ""
    for word in words:
        test = word if not current else f"{current} {word}"
        if text_size(draw, test, fnt)[0] <= max_width:
            current = test
        else:
            if current:
                lines.append(current)
            current = word
    if current:
        lines.append(current)
    return lines


def draw_wrapped(draw, xy, text, fnt, fill, max_width, line_gap=8):
    x, y = xy
    for line in wrap_text(draw, text, fnt, max_width):
        draw.text((x, y), line, font=fnt, fill=fill)
        y += text_size(draw, line, fnt)[1] + line_gap
    return y


def rounded(draw, box, fill=WHITE, outline=LINE, width=3, radius=26):
    draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def arrow(draw, start, end, color="#80918a", width=5):
    draw.line([start, end], fill=color, width=width)
    ex, ey = end
    sx, sy = start
    dx = 1 if ex >= sx else -1
    draw.polygon([(ex, ey), (ex - 20 * dx, ey - 12), (ex - 20 * dx, ey + 12)], fill=color)


def poly_arrow(draw, points, color="#80918a", width=5):
    draw.line(points, fill=color, width=width, joint="curve")
    (sx, sy), (ex, ey) = points[-2], points[-1]
    if abs(ex - sx) >= abs(ey - sy):
        dx = 1 if ex >= sx else -1
        head = [(ex, ey), (ex - 20 * dx, ey - 12), (ex - 20 * dx, ey + 12)]
    else:
        dy = 1 if ey >= sy else -1
        head = [(ex, ey), (ex - 12, ey - 20 * dy), (ex + 12, ey - 20 * dy)]
    draw.polygon(head, fill=color)


def base(title, subtitle):
    img = Image.new("RGB", (W, H), BG)
    draw = ImageDraw.Draw(img)
    draw.text((110, 70), title, font=TITLE, fill=INK)
    draw.text((112, 145), subtitle, font=SUBTITLE, fill=MUTED)
    draw.line((110, 210, W - 110, 210), fill=LINE, width=3)
    draw.text((110, H - 80), FOOTER, font=SMALL, fill=MUTED)
    return img, draw


def card(draw, box, title, body, fill=WHITE, accent=GREEN_DARK):
    rounded(draw, box, fill=fill, outline=LINE, width=3)
    x1, y1, x2, _ = box
    draw.rounded_rectangle((x1, y1, x1 + 14, box[3]), radius=16, fill=accent)
    draw.text((x1 + 34, y1 + 26), title, font=HEAD, fill=INK)
    draw_wrapped(draw, (x1 + 34, y1 + 76), body, BODY, MUTED, x2 - x1 - 68, line_gap=8)


def badge(draw, xy, text, fill, outline):
    x, y = xy
    tw, th = text_size(draw, text, SMALL)
    box = (x, y, x + tw + 34, y + th + 20)
    draw.rounded_rectangle(box, radius=20, fill=fill, outline=outline, width=2)
    draw.text((x + 17, y + 10), text, font=SMALL, fill=outline)
    return box


def learning_to_world_contract():
    img, draw = base(
        "Learning-to-World Contract",
        "M16-S readiness audit / learning events may suggest, not place",
    )
    boxes = [
        ("Learning Event", "word learned, import, exercise result, context seen", GREEN, GREEN_DARK),
        ("Semantic Check", "sense, word type, safety, clutter, multi-home", BLUE, BLUE_DARK),
        ("Reward Suggestion", "soft signal or proposal only, no pressure", YELLOW, YELLOW_DARK),
        ("User Choice", "confirm, change, later, codex, blueprint, backlog", PURPLE, PURPLE_DARK),
        ("Safe World Reaction", "preview, codex progress, reversible candidate", GREEN, GREEN_DARK),
    ]
    y = 300
    x = 120
    bw, bh, gap = 385, 220, 45
    centers = []
    for title, body, fill, accent in boxes:
        card(draw, (x, y, x + bw, y + bh), title, body, fill, accent)
        centers.append((x + bw, y + bh // 2))
        x += bw + gap
    for i in range(len(centers) - 1):
        arrow(draw, (centers[i][0] + 10, centers[i][1]), (centers[i][0] + gap - 12, centers[i][1]))

    card(
        draw,
        (210, 690, 1090, 1020),
        "Allowed Later Reactions",
        "Codex progress, semantic proposal, review queue entry, blueprint candidate, reversible preview and Tali/Vori explanation.",
        GREEN,
        GREEN_DARK,
    )
    card(
        draw,
        (1310, 690, 2190, 1020),
        "Blocked Now",
        "No automatic placement, no build state, no persistence, no Reward Bridge, no SRS or word_progress change.",
        RED,
        RED_DARK,
    )
    badge(draw, (850, 1120), "no automatic word placement", RED, RED_DARK)
    badge(draw, (850, 1190), "no Build-State / no frame_started", RED, RED_DARK)
    badge(draw, (850, 1260), "no SRS or word_progress mutation", RED, RED_DARK)
    img.save(OUT_DIR / "learning_to_world_contract.png")


def semantic_scaling_funnel():
    img, draw = base(
        "Semantic Scaling Funnel",
        "20,000+ words become profiles, filters and rare visible decisions",
    )
    stages = [
        ("20,000 Words", "intake from learning, import, sparks and user words", 1800, GREEN),
        ("Semantic Profiles", "internal candidates, word type, sense, safety and confidence", 1500, BLUE),
        ("Filters", "multi-home, sensitive, clutter, action, container and backlog", 1220, YELLOW),
        ("Review Queue", "only uncertain or relevant decisions surface", 930, PURPLE),
        ("Visible Decisions", "few per session, reversible and optional", 650, GREEN),
        ("Curated World Objects", "strongly limited, gated and user confirmed", 430, BLUE),
    ]
    center = W // 2
    top = 285
    height = 150
    gap = 34
    prev_mid = None
    for i, (title, body, width, fill) in enumerate(stages):
        y1 = top + i * (height + gap)
        x1 = center - width // 2
        box = (x1, y1, x1 + width, y1 + height)
        rounded(draw, box, fill=fill, outline=LINE, width=3, radius=30)
        draw.text((x1 + 36, y1 + 28), title, font=HEAD, fill=INK)
        draw_wrapped(draw, (x1 + 36, y1 + 78), body, BODY, MUTED, width - 72)
        if prev_mid:
            arrow(draw, (center, prev_mid + 10), (center, y1 - 12), color="#91a09a", width=4)
        prev_mid = y1 + height
    card(
        draw,
        (120, 1260, 780, 1450),
        "Not a UI list",
        "No 20,000 cards, no 20,000 plots, no 20,000 direct decisions.",
        RED,
        RED_DARK,
    )
    card(
        draw,
        (1620, 1260, 2280, 1450),
        "Safe defaults",
        "Codex, Blueprint, Backlog, ContextCard and ContainerItem absorb most words.",
        GREEN,
        GREEN_DARK,
    )
    img.save(OUT_DIR / "semantic_scaling_funnel.png")


def readiness_risk_matrix():
    img, draw = base(
        "Readiness Risk Matrix",
        "Conceptual basis is strong; product systems still need gates",
    )
    columns = [
        ("Ready", GREEN, GREEN_DARK, ["Product north star", "Routing rules", "Plot capabilities", "Sensitive rules", "Mobile clutter"]),
        ("Needs Gate", YELLOW, YELLOW_DARK, ["Core loop", "Reward loop", "Container/depth", "ThemeIsland capacity", "Visual harness"]),
        ("Blocked", RED, RED_DARK, ["Persistence", "Supabase writes", "SRS mutation", "Assets", "frame_started"]),
        ("Too Early", PURPLE, PURPLE_DARK, ["Build-Wheel code", "Water/boats", "Farm timers", "Sensitive islands", "Mass AI routing"]),
    ]
    x = 110
    y = 290
    col_w = 520
    for title, fill, accent, items in columns:
        rounded(draw, (x, y, x + col_w, 1320), fill=fill, outline=LINE, width=3)
        draw.text((x + 34, y + 34), title, font=HEAD, fill=accent)
        yy = y + 110
        for item in items:
            rounded(draw, (x + 34, yy, x + col_w - 34, yy + 120), fill=WHITE, outline=LINE, width=2, radius=18)
            draw_wrapped(draw, (x + 58, yy + 34), item, BODY, INK, col_w - 116)
            yy += 145
        x += col_w + 40
    badge(draw, (770, 1400), "Verdict: solid basis, not production-ready", BLUE, BLUE_DARK)
    img.save(OUT_DIR / "readiness_risk_matrix.png")


def reward_loop_without_pressure():
    img, draw = base(
        "Reward Loop Without Pressure",
        "Motivation should invite return, not punish absence",
    )
    loop = [
        ("Learn", "exercise, word, sentence or import", GREEN, GREEN_DARK, (250, 330)),
        ("Soft Progress", "small reversible signal", BLUE, BLUE_DARK, (850, 330)),
        ("Proposal", "Tali/Vori suggests, user can skip", YELLOW, YELLOW_DARK, (1450, 330)),
        ("Voluntary Choice", "confirm, later, codex or backlog", PURPLE, PURPLE_DARK, (1450, 800)),
        ("World Feedback", "preview only until gate", GREEN, GREEN_DARK, (850, 800)),
        ("Next Motivation", "curiosity, not guilt", BLUE, BLUE_DARK, (250, 800)),
    ]
    bw, bh = 470, 210
    centers = []
    for title, body, fill, accent, (x, y) in loop:
        card(draw, (x, y, x + bw, y + bh), title, body, fill, accent)
        centers.append((x + bw // 2, y + bh // 2))
    arrow(draw, (250 + bw, 435), (850, 435), color="#85978f", width=4)
    arrow(draw, (850 + bw, 435), (1450, 435), color="#85978f", width=4)
    arrow(draw, (1450 + bw // 2, 330 + bh), (1450 + bw // 2, 800), color="#85978f", width=4)
    arrow(draw, (1450, 800 + bh // 2), (850 + bw, 800 + bh // 2), color="#85978f", width=4)
    arrow(draw, (850, 800 + bh // 2), (250 + bw, 800 + bh // 2), color="#85978f", width=4)
    arrow(draw, (250 + bw // 2, 800), (250 + bw // 2, 330 + bh), color="#85978f", width=4)
    card(
        draw,
        (210, 1240, 1090, 1440),
        "Allowed",
        "Gentle comeback, optional review, reversible progress signals and world feedback only after gate.",
        GREEN,
        GREEN_DARK,
    )
    card(
        draw,
        (1310, 1240, 2190, 1440),
        "Blocked",
        "No streak guilt, no world punishment, no forced decision after every lesson, no decay pressure.",
        RED,
        RED_DARK,
    )
    img.save(OUT_DIR / "reward_loop_without_pressure.png")


def productive_system_gate_map():
    img, draw = base(
        "Productive System Gate Map",
        "What must exist before real world, reward or semantics systems",
    )
    gates = [
        ("Data + Persistence", "data model, migration, local DB/Supabase safety, offline/sync", RED, RED_DARK),
        ("Semantics Operations", "confidence scoring, review queue, privacy, AI/classifier provider", YELLOW, YELLOW_DARK),
        ("World Contract", "LearningResult, Reward Bridge, reversible user choice, no auto placement", BLUE, BLUE_DARK),
        ("UX + Safety", "sensitive review, undo, accessibility, mobile clutter, retention fairness", PURPLE, PURPLE_DARK),
        ("Production Readiness", "tests, performance, app integration gate, asset scope, no frame_started", GREEN, GREEN_DARK),
    ]
    x_positions = [140, 850, 1560, 500, 1210]
    y_positions = [310, 310, 310, 800, 800]
    centers = []
    for (title, body, fill, accent), x, y in zip(gates, x_positions, y_positions):
        card(draw, (x, y, x + 690, y + 330), title, body, fill, accent)
        centers.append((x + 345, y + 165))
    arrow(draw, (830, 475), (850, 475))
    arrow(draw, (1540, 475), (1560, 475))
    poly_arrow(draw, [(485, 640), (485, 730), (845, 730), (845, 800)])
    poly_arrow(draw, [(1905, 640), (1905, 730), (1555, 730), (1555, 800)])
    arrow(draw, (1190, 965), (1210, 965))
    badge(draw, (820, 1270), "Productive systems remain blocked until gates pass", RED, RED_DARK)
    badge(draw, (900, 1350), "No assets / no persistence / no Build-State / no frame_started", RED, RED_DARK)
    img.save(OUT_DIR / "productive_system_gate_map.png")


def contact_sheet():
    files = [
        "learning_to_world_contract.png",
        "semantic_scaling_funnel.png",
        "readiness_risk_matrix.png",
        "reward_loop_without_pressure.png",
        "productive_system_gate_map.png",
    ]
    cw, ch = 2400, 2100
    img = Image.new("RGB", (cw, ch), BG)
    draw = ImageDraw.Draw(img)
    draw.text((100, 70), "M16-S Learning Game Readiness Visuals", font=TITLE, fill=INK)
    draw.text((102, 145), "contact sheet / documentation previews only", font=SUBTITLE, fill=MUTED)
    thumb_w, thumb_h = 620, 415
    positions = [(120, 260), (890, 260), (1660, 260), (500, 910), (1280, 910)]
    for file_name, (x, y) in zip(files, positions):
        src = Image.open(OUT_DIR / file_name).convert("RGB")
        src.thumbnail((thumb_w, thumb_h))
        rounded(draw, (x - 18, y - 18, x + thumb_w + 18, y + thumb_h + 70), fill=WHITE, outline=LINE, width=3, radius=24)
        img.paste(src, (x + (thumb_w - src.width) // 2, y))
        draw_wrapped(draw, (x, y + thumb_h + 22), file_name, SMALL, INK, thumb_w)
    draw.text((100, ch - 90), FOOTER, font=SMALL, fill=MUTED)
    img.save(OUT_DIR / "00_contact_sheet.png")


def main():
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    learning_to_world_contract()
    semantic_scaling_funnel()
    readiness_risk_matrix()
    reward_loop_without_pressure()
    productive_system_gate_map()
    contact_sheet()
    for file in sorted(OUT_DIR.glob("*.png")):
        print(file)


if __name__ == "__main__":
    main()
