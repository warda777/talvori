from pathlib import Path
from PIL import Image, ImageDraw, ImageFont


OUT = Path(__file__).resolve().parent
W, H = 2400, 1500

BG = "#f6f1e8"
PANEL = "#fffdf8"
INK = "#243336"
MUTED = "#66706e"
LINE = "#cec4b2"
GREEN = "#dcefdc"
GREEN_D = "#3f7b4b"
BLUE = "#dcebf4"
BLUE_D = "#3d7190"
AMBER = "#f4e7c2"
AMBER_D = "#8a7132"
RED = "#f2d8d8"
RED_D = "#98514f"
PURPLE = "#e7ddf1"
PURPLE_D = "#70548d"
MINT = "#d9eee7"
MINT_D = "#397c70"
GRAY = "#ece7dd"
GRAY_D = "#776f64"


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    candidates = [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    ]
    for name in candidates:
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()


TITLE = font(56, True)
SUB = font(30)
H1 = font(34, True)
H2 = font(27, True)
BODY = font(24)
SMALL = font(20)
TINY = font(17)
FOOT = font(21, True)


def text_size(draw: ImageDraw.ImageDraw, text: str, fnt: ImageFont.ImageFont) -> tuple[int, int]:
    box = draw.textbbox((0, 0), text, font=fnt)
    return box[2] - box[0], box[3] - box[1]


def wrap(draw: ImageDraw.ImageDraw, text: str, fnt: ImageFont.ImageFont, max_width: int) -> list[str]:
    lines: list[str] = []
    for raw in text.split("\n"):
        words = raw.split()
        if not words:
            lines.append("")
            continue
        line = words[0]
        for word in words[1:]:
            test = f"{line} {word}"
            if text_size(draw, test, fnt)[0] <= max_width:
                line = test
            else:
                lines.append(line)
                line = word
        lines.append(line)
    return lines


def draw_wrapped(
    draw: ImageDraw.ImageDraw,
    text: str,
    xy: tuple[int, int],
    fnt: ImageFont.ImageFont,
    fill: str,
    max_width: int,
    line_gap: int = 8,
) -> int:
    x, y = xy
    for line in wrap(draw, text, fnt, max_width):
        draw.text((x, y), line, font=fnt, fill=fill)
        y += text_size(draw, line or " ", fnt)[1] + line_gap
    return y


def header(draw: ImageDraw.ImageDraw, title: str, subtitle: str) -> None:
    draw.text((90, 52), title, font=TITLE, fill=INK)
    draw.text((90, 128), subtitle, font=SUB, fill=MUTED)
    draw.line((90, 183, W - 90, 183), fill=LINE, width=3)


def footer(draw: ImageDraw.ImageDraw) -> None:
    y = H - 86
    draw.rounded_rectangle((90, y, W - 90, y + 54), radius=14, fill="#eee6d8", outline="#d6cdbc", width=2)
    draw.text(
        (115, y + 16),
        "documentation preview only / no code / no assets / no route / no persistence / no build state / no frame_started",
        font=FOOT,
        fill=INK,
    )


def canvas(title: str, subtitle: str) -> tuple[Image.Image, ImageDraw.ImageDraw]:
    img = Image.new("RGB", (W, H), BG)
    draw = ImageDraw.Draw(img)
    header(draw, title, subtitle)
    footer(draw)
    return img, draw


def card(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    title: str,
    body: str,
    fill: str,
    outline: str,
    title_color: str | None = None,
    body_font: ImageFont.ImageFont = BODY,
) -> None:
    x1, y1, x2, y2 = box
    draw.rounded_rectangle(box, radius=20, fill=fill, outline=outline, width=4)
    draw_wrapped(draw, title, (x1 + 22, y1 + 20), H2, title_color or outline, x2 - x1 - 44, 6)
    draw_wrapped(draw, body, (x1 + 22, y1 + 70), body_font, INK, x2 - x1 - 44, 8)


def arrow(draw: ImageDraw.ImageDraw, start: tuple[int, int], end: tuple[int, int], color: str = LINE) -> None:
    draw.line((*start, *end), fill=color, width=5)
    sx, sy = start
    ex, ey = end
    if abs(ex - sx) >= abs(ey - sy):
        if ex >= sx:
            pts = [(ex, ey), (ex - 18, ey - 11), (ex - 18, ey + 11)]
        else:
            pts = [(ex, ey), (ex + 18, ey - 11), (ex + 18, ey + 11)]
    else:
        if ey >= sy:
            pts = [(ex, ey), (ex - 11, ey - 18), (ex + 11, ey - 18)]
        else:
            pts = [(ex, ey), (ex - 11, ey + 18), (ex + 11, ey + 18)]
    draw.polygon(pts, fill=color)


def chip(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], label: str, fill: str, outline: str) -> None:
    draw.rounded_rectangle(box, radius=18, fill=fill, outline=outline, width=2)
    tw, th = text_size(draw, label, SMALL)
    x1, y1, x2, y2 = box
    draw.text((x1 + (x2 - x1 - tw) / 2, y1 + (y2 - y1 - th) / 2 - 1), label, font=SMALL, fill=outline)


def make_pipeline() -> Path:
    img, draw = canvas(
        "M16-L Global Semantics Decision Pipeline",
        "Future world prompts must route semantics before category, plot or wheel decisions",
    )
    steps = [
        ("Word / intent", "incoming word, import or user goal", BLUE, BLUE_D),
        ("Context / sense", "sentence, meaning, multi-home check", PURPLE, PURPLE_D),
        ("Word type", "noun, verb, tiny object, emotion, abstract", MINT, MINT_D),
        ("Safety", "sensitive / policy / pressure check", RED, RED_D),
        ("Theme candidates", "one or more ThemeIslands", AMBER, AMBER_D),
        ("Plot / depth", "plot family, interior, container or detail", GREEN, GREEN_D),
        ("Representation", "object, action, emotion, context, Codex, Blueprint, Backlog", BLUE, BLUE_D),
        ("User choice", "confirm, change, later or not visible", PURPLE, PURPLE_D),
        ("Preview / gate", "preview only, later implementation gate", GREEN, GREEN_D),
    ]
    x0, y0 = 115, 270
    box_w, box_h = 385, 150
    h_gap, v_gap = 80, 120
    positions = []
    for i, step in enumerate(steps):
        row = i // 3
        col = i % 3
        x = x0 + col * (box_w + h_gap)
        y = y0 + row * (box_h + v_gap)
        positions.append((x, y))
        title, body, fill, outline = step
        card(draw, (x, y, x + box_w, y + box_h), title, body, fill, outline, body_font=SMALL)
        if i > 0:
            px, py = positions[i - 1]
            if col == 0:
                arrow(draw, (px + box_w // 2, py + box_h + 18), (x + box_w // 2, y - 18))
            else:
                arrow(draw, (px + box_w + 16, py + box_h // 2), (x - 16, y + box_h // 2))

    card(
        draw,
        (1530, 330, 2245, 420),
        "Hard rule",
        "A category match is not a placement command.",
        RED,
        RED_D,
        body_font=SMALL,
    )
    card(
        draw,
        (1530, 520, 2245, 735),
        "Representation outcomes",
        "WorldObject / PlotCandidate / BuildingCandidate / InteriorObject / ContainerItem / ActionChallenge / EmotionCue / ContextCard / Codex / Blueprint / Backlog",
        PANEL,
        BLUE_D,
        body_font=SMALL,
    )
    card(
        draw,
        (1530, 835, 2245, 1045),
        "Always blocked",
        "automatic word placement, direct build, persistence, route, assets, runtime config, frame_started",
        RED,
        RED_D,
        body_font=SMALL,
    )
    path = OUT / "01_global_semantics_decision_pipeline.png"
    img.save(path)
    return path


def make_representation_map() -> Path:
    img, draw = canvas(
        "M16-L Word Type To Representation Map",
        "Not every word becomes an object, plot, building or visible island element",
    )
    rows = [
        ("Noun / object", ["ok", "gate", "gate", "maybe", "maybe", "-", "-", "-", "fallback", "fallback", "fallback"]),
        ("Verb / action", ["-", "-", "-", "-", "-", "ok", "-", "maybe", "ok", "-", "fallback"]),
        ("Adjective", ["-", "-", "-", "-", "-", "maybe", "-", "ok", "ok", "-", "fallback"]),
        ("Emotion", ["-", "-", "-", "-", "-", "-", "ok", "ok", "ok", "-", "fallback"]),
        ("Abstract", ["-", "-", "-", "-", "-", "maybe", "-", "ok", "ok", "-", "fallback"]),
        ("Sensitive", ["no", "no", "no", "no", "no", "gate", "gate", "ok", "ok", "gate", "ok"]),
        ("Tiny object", ["no", "-", "-", "maybe", "ok", "maybe", "-", "-", "ok", "fallback", "fallback"]),
        ("Place", ["maybe", "ok", "gate", "maybe", "-", "-", "-", "maybe", "ok", "fallback", "fallback"]),
        ("Building part", ["no", "-", "gate", "gate", "-", "-", "-", "-", "ok", "ok", "fallback"]),
        ("Container item", ["no", "-", "-", "maybe", "ok", "maybe", "-", "-", "ok", "-", "fallback"]),
    ]
    cols = [
        "World\nObject",
        "Plot\nCand.",
        "Building\nCand.",
        "Interior\nObj.",
        "Container\nItem",
        "Action\nChallenge",
        "Emotion\nCue",
        "Context\nCard",
        "Codex",
        "Blueprint",
        "Backlog",
    ]
    x0, y0 = 90, 250
    row_h = 82
    row_label_w = 260
    col_w = 175
    draw.rounded_rectangle((x0, y0, x0 + row_label_w + col_w * len(cols), y0 + row_h * (len(rows) + 1)), radius=20, fill=PANEL, outline=LINE, width=3)
    draw.text((x0 + 24, y0 + 28), "Word type", font=H2, fill=INK)
    for j, col in enumerate(cols):
        cx = x0 + row_label_w + j * col_w
        draw_wrapped(draw, col, (cx + 12, y0 + 18), SMALL, BLUE_D, col_w - 24, 3)
    for i, (label, values) in enumerate(rows):
        y = y0 + row_h * (i + 1)
        fill = "#fbf8f1" if i % 2 == 0 else "#f1eadc"
        draw.rectangle((x0 + 2, y, x0 + row_label_w + col_w * len(cols) - 2, y + row_h), fill=fill)
        draw_wrapped(draw, label, (x0 + 22, y + 22), SMALL, INK, row_label_w - 44, 3)
        for j, value in enumerate(values):
            cx = x0 + row_label_w + j * col_w
            color, outline = {
                "ok": (GREEN, GREEN_D),
                "maybe": (MINT, MINT_D),
                "gate": (AMBER, AMBER_D),
                "fallback": (BLUE, BLUE_D),
                "no": (RED, RED_D),
                "-": (GRAY, GRAY_D),
            }[value]
            draw.rounded_rectangle((cx + 18, y + 19, cx + col_w - 18, y + 59), radius=13, fill=color, outline=outline, width=2)
            tw, th = text_size(draw, value, TINY)
            draw.text((cx + (col_w - tw) / 2, y + 39 - th / 2), value, font=TINY, fill=outline)
    card(
        draw,
        (350, 1195, W - 350, 1315),
        "Legend",
        "ok = suitable route, gate = only after own gate, fallback = safe non-visible route, no = blocked for visible world representation.",
        BLUE,
        BLUE_D,
        body_font=SMALL,
    )
    path = OUT / "02_word_type_representation_map.png"
    img.save(path)
    return path


def make_multi_home_examples() -> Path:
    img, draw = canvas(
        "M16-L Multi-Home Word Examples",
        "A word can map to several themes or to non-building representations",
    )
    examples = [
        ("Haus", "home / city / farm / coast", "Needs context. Could be residential, block, farmhouse, holiday house. No forced start.", GREEN, GREEN_D),
        ("Garage", "home / vehicle / city", "Utility or parking context first. Not automatically Zuhause.", BLUE, BLUE_D),
        ("Baum", "garden / city / farm", "Nature, street tree or orchard. Clutter and deco gate.", MINT, MINT_D),
        ("schwimmen", "coast / sport", "Verb/action. Water safety gate. Not a building.", PURPLE, PURPLE_D),
        ("Angst", "emotion / sensitive", "EmotionCue, ContextCard, CompanionDialog or Codex. No object.", RED, RED_D),
        ("lernen", "action / school", "LearningMode or challenge. Not automatically school building.", AMBER, AMBER_D),
        ("Messer", "kitchen / tool / safety", "Container/detail plus safety and context. No auto visible object.", RED, RED_D),
        ("Polizei", "public / sensitive", "Policy gate. ContextCard or Codex. No automatic station.", RED, RED_D),
    ]
    x_positions = [115, 675, 1235, 1795]
    y_positions = [285, 685]
    for idx, (title, route, body, fill, outline) in enumerate(examples):
        x = x_positions[idx % 4]
        y = y_positions[idx // 4]
        card(draw, (x, y, x + 475, y + 295), title, body, fill, outline, body_font=SMALL)
        chip(draw, (x + 22, y + 235, x + 250, y + 277), route, PANEL, outline)
    card(
        draw,
        (260, 1080, W - 260, 1252),
        "Audit conclusion",
        "M16-K category profiles are necessary, but a word still needs sense, word type, safety, representation decision, user choice and fallback before any visible preview or later implementation.",
        BLUE,
        BLUE_D,
        body_font=SMALL,
    )
    path = OUT / "03_multi_home_word_examples.png"
    img.save(path)
    return path


def make_gap_map() -> Path:
    img, draw = canvas(
        "M16-L M16-I / M16-J / M16-K Gap Map",
        "Plot capacity work is useful, but future prompts need semantic filters too",
    )
    cards = [
        ("M16-I", "Strong: theme-to-plot pipeline and in-place wheel rule.\nGap: word type, multi-home and fallbacks not central.", GREEN, GREEN_D),
        ("M16-J", "Strong: village multi-slot example.\nGap: too narrow as a global next step.", AMBER, AMBER_D),
        ("M16-K", "Strong: global category and plot capacity matrix.\nGap: categories do not decide representation.", BLUE, BLUE_D),
        ("M16-L", "Adds: mandatory semantics, routing, sensitive, depth, fallback and stop-rule audit.", PURPLE, PURPLE_D),
    ]
    x = 135
    y = 315
    box_w = 500
    for title, body, fill, outline in cards:
        card(draw, (x, y, x + box_w, y + 320), title, body, fill, outline, body_font=SMALL)
        x += box_w + 60
    for i in range(3):
        sx = 135 + i * (box_w + 60) + box_w + 15
        ex = sx + 30
        arrow(draw, (sx, y + 160), (ex, y + 160), LINE)

    lanes = [
        ("Capacity axis", "theme, slot count, size mix, connectors, exchangeability", GREEN, GREEN_D),
        ("Semantics axis", "context, word type, sensitive check, representation, fallback", PURPLE, PURPLE_D),
        ("Release axis", "preview only, later gate, no code now, no assets, no frame_started", RED, RED_D),
    ]
    x = 220
    for title, body, fill, outline in lanes:
        card(draw, (x, 830, x + 600, 1040), title, body, fill, outline, body_font=SMALL)
        x += 700
    card(
        draw,
        (340, 1160, W - 340, 1285),
        "Future rule",
        "No category-specific preview prompt should skip the global semantics pipeline, even when plot capacity is already documented.",
        RED,
        RED_D,
        body_font=SMALL,
    )
    path = OUT / "04_m16_i_j_k_gap_map.png"
    img.save(path)
    return path


def make_future_checklist() -> Path:
    img, draw = canvas(
        "M16-L Required Future Prompt Checklist",
        "Every future World prompt must pass these filters before code, assets or build states",
    )
    items = [
        ("Read docs", "Taxonomy, routing, capabilities, sensitive, mobile, depth and asset scope."),
        ("Taxonomy", "Category exists, but category alone does not place a word."),
        ("Routing", "Word-to-Island suggests; it does not automatically build."),
        ("Capabilities", "Plot functions are permissions, not Pflichtbelegung."),
        ("Sensitive", "Neutral, private, optional; Codex/ContextCard/Backlog first."),
        ("Mobile", "Tiny objects, labels and containers stay readable."),
        ("Depth", "Interior, container, detail and zoom routes are considered."),
        ("Multi-home", "Words like Haus, Garage, Baum need context and choice."),
        ("Fallbacks", "Codex, Blueprint and Backlog stay valid outcomes."),
        ("Stop rules", "No route, persistence, assets, build state or frame_started."),
    ]
    cols = 2
    card_w, card_h = 1000, 155
    x0, y0 = 145, 250
    for i, (title, body) in enumerate(items):
        col = i % cols
        row = i // cols
        x = x0 + col * 1120
        y = y0 + row * 190
        fill = GREEN if i < 4 else BLUE if i < 8 else RED if i == 9 else AMBER
        outline = GREEN_D if i < 4 else BLUE_D if i < 8 else RED_D if i == 9 else AMBER_D
        card(draw, (x, y, x + card_w, y + card_h), title, body, fill, outline, body_font=SMALL)
    card(
        draw,
        (270, 1230, W - 270, 1330),
        "Decision rule",
        "If any checklist item is missing, the next step is another audit/refinement, not implementation.",
        PURPLE,
        PURPLE_D,
        body_font=SMALL,
    )
    path = OUT / "05_required_future_prompt_checklist.png"
    img.save(path)
    return path


def make_contact_sheet(paths: list[Path]) -> Path:
    thumbs = []
    for path in paths:
        img = Image.open(path).convert("RGB")
        img.thumbnail((700, 420))
        thumbs.append((path, img.copy()))
    sheet = Image.new("RGB", (2400, 1500), BG)
    draw = ImageDraw.Draw(sheet)
    header(draw, "M16-L Contact Sheet", "Quick overview of global semantics audit documentation previews")
    footer(draw)
    positions = [(110, 260), (850, 260), (1590, 260), (480, 820), (1220, 820)]
    for (path, thumb), (x, y) in zip(thumbs, positions):
        draw.rounded_rectangle((x - 18, y - 18, x + 718, y + 482), radius=20, fill=PANEL, outline=LINE, width=3)
        sheet.paste(thumb, (x, y))
        label = path.name
        draw_wrapped(draw, label, (x, y + 430), SMALL, INK, 700, 4)
    out = OUT / "00_contact_sheet.png"
    sheet.save(out)
    return out


def main() -> None:
    paths = [
        make_pipeline(),
        make_representation_map(),
        make_multi_home_examples(),
        make_gap_map(),
        make_future_checklist(),
    ]
    make_contact_sheet(paths)
    print("\n".join(str(path) for path in [OUT / "00_contact_sheet.png", *paths]))


if __name__ == "__main__":
    main()
