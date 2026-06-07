from pathlib import Path
import textwrap

from PIL import Image, ImageDraw, ImageFont


OUT_DIR = Path(__file__).resolve().parent
W, H = 2400, 1600
BG = "#f4efe6"
INK = "#233538"
MUTED = "#667574"
LINE = "#c7bda9"
FOOTER_BG = "#eee6d6"


def font(size, bold=False):
    candidates = [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/Library/Fonts/Arial Bold.ttf" if bold else "/Library/Fonts/Arial.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
    ]
    for path in candidates:
        try:
            return ImageFont.truetype(path, size)
        except OSError:
            continue
    return ImageFont.load_default()


F_TITLE = font(58, True)
F_SUB = font(31)
F_H = font(27, True)
F_BODY = font(21)
F_SMALL = font(17)
F_FOOT = font(18, True)


PALETTE = {
    "blue": ("#d9ebf5", "#3c7898"),
    "green": ("#dcefdc", "#3b8850"),
    "red": ("#f0d4d4", "#a85656"),
    "yellow": ("#f4e6ba", "#96752c"),
    "purple": ("#e4d8ef", "#765894"),
    "teal": ("#d7eee8", "#3e8b7f"),
    "gray": ("#e8e2d8", "#786f64"),
}


def canvas(title, subtitle):
    img = Image.new("RGB", (W, H), BG)
    d = ImageDraw.Draw(img)
    d.text((92, 58), title, fill=INK, font=F_TITLE)
    d.text((92, 140), subtitle, fill=MUTED, font=F_SUB)
    d.line((92, 194, W - 92, 194), fill=LINE, width=3)
    footer(d)
    return img, d


def footer(d):
    text = "documentation preview only / architecture plan only / no code / no persistence / no assets / no automatic placement / no frame_started"
    x, y, w, h = 92, H - 104, W - 184, 56
    d.rounded_rectangle((x, y, x + w, y + h), radius=10, fill=FOOTER_BG, outline="#d6ccb9", width=2)
    d.text((x + 22, y + 16), text, fill=INK, font=F_FOOT)


def wrap_lines(text, width):
    lines = []
    for raw in text.split("\n"):
        if not raw:
            lines.append("")
            continue
        lines.extend(textwrap.wrap(raw, width=width, break_long_words=False))
    return lines


def card(d, xy, title, body, color="blue", title_size=27, body_size=21, body_width=42):
    x, y, w, h = xy
    fill, border = PALETTE[color]
    d.rounded_rectangle((x, y, x + w, y + h), radius=16, fill=fill, outline=border, width=4)
    d.text((x + 22, y + 20), title, fill=border, font=font(title_size, True))
    yy = y + 72
    for line in wrap_lines(body, body_width):
        d.text((x + 22, yy), line, fill=INK, font=font(body_size))
        yy += body_size + 7


def pill(d, xy, text, color="blue"):
    x, y, w, h = xy
    fill, border = PALETTE[color]
    d.rounded_rectangle((x, y, x + w, y + h), radius=15, fill="#fbfaf6", outline=border, width=2)
    tw = d.textlength(text, font=F_SMALL)
    d.text((x + (w - tw) / 2, y + 11), text, fill=border, font=F_SMALL)


def arrow(d, start, end):
    sx, sy = start
    ex, ey = end
    d.line((sx, sy, ex, ey), fill="#c8bdab", width=5)
    d.polygon([(ex, ey), (ex - 16, ey - 10), (ex - 16, ey + 10)], fill="#c8bdab")


def save(img, name):
    img.save(OUT_DIR / name)


def draw_many_words_pipeline():
    img, d = canvas(
        "M16-R Many Words To Semantic Profiles",
        "20,000+ words become internal profiles and filtered decisions, not 20,000 world objects",
    )
    steps = [
        ("20,000 Words", "imported, collected or typed", "blue"),
        ("Semantic Profiles", "one internal candidate profile per word", "purple"),
        ("Routing Candidates", "sense, word type, safety, theme, depth", "yellow"),
        ("Safe Fallbacks", "Codex, Blueprint, Backlog, ContextCard", "green"),
        ("Review Queue", "only risky or relevant decisions surface", "teal"),
        ("Later Gates", "placement, build and persistence stay separate", "red"),
    ]
    x, y, w, h, gap = 90, 335, 330, 170, 46
    for i, (title, body, color) in enumerate(steps):
        card(d, (x + i * (w + gap), y, w, h), title, body, color, title_size=24, body_size=18, body_width=24)
        if i < len(steps) - 1:
            arrow(d, (x + i * (w + gap) + w + 10, y + h / 2), (x + (i + 1) * (w + gap) - 16, y + h / 2))
    card(
        d,
        (210, 680, 900, 260),
        "Not the scaling model",
        "20,000 words -> 20,000 cards -> 20,000 island objects -> 20,000 plots or buildings.",
        "red",
        body_width=62,
    )
    card(
        d,
        (1285, 680, 900, 260),
        "Actual scaling model",
        "20,000 possible profiles -> filtered suggestions -> only relevant user decisions -> preview only until later gates.",
        "green",
        body_width=62,
    )
    pill(d, (600, 1060, 1200, 58), "Automatic analysis prepares suggestions; it never places or builds", "purple")
    save(img, "01_many_words_to_semantic_profiles_pipeline.png")


def draw_status_lifecycle():
    img, d = canvas(
        "M16-R Word Profile Status Lifecycle",
        "Statuses keep mass word handling quiet until a word really needs attention",
    )
    top = [
        ("unprocessed", "word exists, no profile", "gray"),
        ("auto_profiled", "internal analysis only", "blue"),
        ("confidence decision", "safe fallback or queue", "purple"),
    ]
    x, y, w, h, gap = 260, 310, 460, 150, 90
    for i, (title, body, color) in enumerate(top):
        card(d, (x + i * (w + gap), y, w, h), title, body, color, title_size=25, body_size=19, body_width=32)
        if i < len(top) - 1:
            arrow(d, (x + i * (w + gap) + w + 12, y + h / 2), (x + (i + 1) * (w + gap) - 18, y + h / 2))
    outcomes = [
        ("safe_codex", "quiet learning entry", "green"),
        ("blueprint_candidate", "planning only", "yellow"),
        ("needs_user_choice", "small review queue", "purple"),
        ("sensitive_gated", "policy first", "red"),
        ("clutter_gated", "container/depth first", "teal"),
        ("backlog", "wait for context/gates", "gray"),
    ]
    x0, y0, cw, ch = 135, 650, 330, 150
    for idx, (title, body, color) in enumerate(outcomes):
        card(d, (x0 + idx * 365, y0, cw, ch), title, body, color, title_size=23, body_size=18, body_width=22)
    card(
        d,
        (520, 980, 1360, 150),
        "Visible only when useful",
        "`user_confirmed` may happen later after review. `discarded_or_hidden` remains valid when a word should not surface.",
        "green",
        body_width=92,
    )
    save(img, "02_word_profile_status_lifecycle.png")


def draw_ui_strategy():
    img, d = canvas(
        "M16-R Mass Word UI Strategy",
        "Large vocabularies need queues, filters and safe defaults instead of endless cards",
    )
    card(
        d,
        (120, 300, 680, 370),
        "Do not show",
        "No 20,000 decision cards\nNo 20,000 island objects\nNo 20,000 plots or buildings\nNo bulk visible placement\nNo forced review work",
        "red",
        body_width=44,
    )
    card(
        d,
        (860, 300, 680, 370),
        "Show instead",
        "Inbox for unclear words\nSmall review queue\nRisk filters\nTali/Vori suggestions\nChange later option\nSafe defaults",
        "green",
        body_width=44,
    )
    card(
        d,
        (1600, 300, 680, 370),
        "Filter by risk",
        "Multi-Home\nSensitive\nClutter\nAction\nContainer\nBlueprint\nBacklog",
        "purple",
        body_width=38,
    )
    filters = [
        ("Codex", "safe explanation"),
        ("Backlog", "wait for context"),
        ("Blueprint", "planning only"),
        ("ContextCard", "explain without object"),
    ]
    x0, y0 = 365, 790
    for i, (title, body) in enumerate(filters):
        card(d, (x0 + i * 430, y0, 370, 145), title, body, "blue" if i % 2 == 0 else "teal", title_size=24, body_size=18, body_width=25)
    pill(d, (590, 1065, 1220, 58), "Bulk is allowed only for safe groups, never for visible placement", "yellow")
    save(img, "03_mass_word_ui_strategy.png")


def draw_allowed_blocked():
    img, d = canvas(
        "M16-R Allowed vs Blocked Scope",
        "This block plans scalable semantics; it does not implement data, AI, persistence or placement",
    )
    card(
        d,
        (125, 300, 930, 620),
        "Allowed in M16-R",
        "Architecture planning\nWordSemanticProfile concept\nStatus lifecycle concept\nQueue and filter concept\nSafe fallback concept\nThreshold assumptions\nDocumentation previews\nFuture gate list",
        "green",
        body_width=45,
    )
    card(
        d,
        (1230, 300, 930, 620),
        "Blocked in M16-R",
        "Final data model\nPersistence or DB writes\nSupabase or local DB\nRuntime config\nAI provider integration\nApp integration or route\nAutomatic placement\nBuild-State / frame_started\nAssets or asset files",
        "red",
        body_width=43,
    )
    pill(d, (640, 1045, 1120, 58), "Every future mass-semantics step needs its own gate", "purple")
    save(img, "04_allowed_vs_blocked_scalable_semantics_scope.png")


def draw_contact_sheet():
    files = [
        "01_many_words_to_semantic_profiles_pipeline.png",
        "02_word_profile_status_lifecycle.png",
        "03_mass_word_ui_strategy.png",
        "04_allowed_vs_blocked_scalable_semantics_scope.png",
    ]
    img = Image.new("RGB", (2400, 1900), BG)
    d = ImageDraw.Draw(img)
    d.text((92, 58), "M16-R Contact Sheet", fill=INK, font=F_TITLE)
    d.text((92, 140), "Quick overview of scalable word semantics architecture visuals", fill=MUTED, font=F_SUB)
    d.line((92, 194, 2308, 194), fill=LINE, width=3)
    positions = [(115, 270), (1230, 270), (115, 890), (1230, 890)]
    thumb_w, thumb_h = 930, 620
    for file_name, (x, y) in zip(files, positions):
        src = Image.open(OUT_DIR / file_name)
        src.thumbnail((thumb_w - 70, thumb_h - 130))
        d.rounded_rectangle((x, y, x + thumb_w, y + thumb_h), radius=16, fill="#fbfaf6", outline=LINE, width=3)
        tx = x + (thumb_w - src.width) // 2
        ty = y + 28
        img.paste(src, (tx, ty))
        d.text((x + 28, y + thumb_h - 70), file_name, fill=INK, font=font(21, True))
    footer_y = 1780
    d.rounded_rectangle((92, footer_y, 2308, footer_y + 56), radius=10, fill=FOOTER_BG, outline="#d6ccb9", width=2)
    d.text(
        (114, footer_y + 16),
        "documentation preview only / architecture plan only / no code / no persistence / no assets / no automatic placement / no frame_started",
        fill=INK,
        font=F_FOOT,
    )
    save(img, "00_contact_sheet.png")


def main():
    draw_many_words_pipeline()
    draw_status_lifecycle()
    draw_ui_strategy()
    draw_allowed_blocked()
    draw_contact_sheet()
    for path in sorted(OUT_DIR.glob("*.png")):
        print(path)


if __name__ == "__main__":
    main()
