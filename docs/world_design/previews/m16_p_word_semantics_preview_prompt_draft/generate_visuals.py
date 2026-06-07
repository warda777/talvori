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
    text = "documentation preview only / prompt draft only / no code now / no app route / no persistence / no assets / no automatic placement / no frame_started"
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


def card(d, xy, title, body, color="blue", title_size=27, body_size=21, body_width=44):
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


def draw_scope_boundary():
    img, d = canvas(
        "M16-P Prompt Scope Boundary",
        "The prompt can prepare a later tiny preview slice; M16-P itself writes no Dart",
    )
    card(
        d,
        (130, 300, 930, 620),
        "Allowed later only after explicit approval",
        "One isolated preview widget\nExample-word cards\nLocal setState selection\nContext/Sense, Word Type, Safety\nTheme candidates and Plot/Depth\nRepresentation Decision\nPreview Only / Later Gate\nNo storage and no placement",
        "green",
        body_width=44,
    )
    card(
        d,
        (1230, 300, 930, 620),
        "Blocked now and in the later prompt",
        "Real routing implementation\nFinal data structure\nApp integration or route\nProduct navigation\nPersistence or DB writes\nSupabase writes\nAutomatic word placement\nBuild-Wheel implementation\nAssets or asset files\nBuild-State / frame_started",
        "red",
        body_width=43,
    )
    pill(d, (680, 1050, 1040, 58), "M16-P documents the prompt only; it does not execute it", "purple")
    save(img, "01_prompt_scope_boundary.png")


def draw_execution_flow():
    img, d = canvas(
        "M16-P Later Prompt Execution Flow",
        "A future implementation prompt must stay isolated, checked and uncommitted",
    )
    steps = [
        ("Read Docs", "M16-P/O/N/L and routing rules", "blue"),
        ("Check Status", "`git status --short` first", "purple"),
        ("List Files", "name affected files before edits", "yellow"),
        ("Create Preview", "one isolated local widget only", "green"),
        ("Format / Analyze", "changed Dart files only later", "teal"),
        ("Diff / Report", "diff check, status, no commit", "gray"),
    ]
    x, y, w, h, gap = 120, 330, 320, 170, 56
    for i, (t, b, c) in enumerate(steps):
        card(d, (x + i * (w + gap), y, w, h), t, b, c, title_size=25, body_size=18, body_width=22)
        if i < len(steps) - 1:
            arrow(d, (x + i * (w + gap) + w + 12, y + h / 2), (x + (i + 1) * (w + gap) - 18, y + h / 2))
    card(
        d,
        (230, 700, 840, 260),
        "Must not happen in the prompt",
        "No app route, no Home/Onboarding/World integration, no persistence, no runtime config, no assets, no screenshots, no tests unless separately approved.",
        "red",
        body_width=60,
    )
    card(
        d,
        (1290, 700, 840, 260),
        "Required report",
        "Changed files, why they were needed, scope proof, format/analyze result, diff check, final status and no commit.",
        "green",
        body_width=60,
    )
    pill(d, (700, 1060, 1000, 58), "Future code only after separate user approval", "purple")
    save(img, "02_later_prompt_execution_flow.png")


def draw_content_map():
    img, d = canvas(
        "M16-P Preview Widget Content Map",
        "The future widget teaches semantic decisions instead of building world objects",
    )
    words = [
        ("Haus", "multi-home\nContext / Blueprint"),
        ("Garage", "parking / utility\nContextCard"),
        ("Baum", "nature / clutter\nBacklog or note"),
        ("schwimmen", "verb / water\nActionChallenge"),
        ("Angst", "emotion\nContextCard / Codex"),
        ("lernen", "action\nChallenge / Codex"),
        ("Messer", "tool / safety\nContainerItem"),
        ("Polizei", "public institution\nPolicy gate"),
    ]
    x0, y0, cw, ch = 115, 300, 485, 150
    colors = ["blue", "yellow", "teal", "purple", "red", "green", "gray", "red"]
    for idx, (word, body) in enumerate(words):
        row = idx // 4
        col = idx % 4
        card(d, (x0 + col * 560, y0 + row * 210, cw, ch), word, body, colors[idx], title_size=28, body_size=19, body_width=30)
    levels = [
        "Context/Sense",
        "Word Type",
        "Safety/Sensitive",
        "ThemeIsland(s)",
        "Plot/Depth",
        "Representation",
        "Preview/Later Gate",
    ]
    sx, sy = 270, 855
    for i, label in enumerate(levels):
        pill(d, (sx + i * 285, sy, 245, 52), label, "blue" if i % 2 == 0 else "green")
    card(
        d,
        (430, 1020, 1540, 150),
        "Shared guardrail",
        "Every example remains explanatory: no storage, no placement, no automatic routing, no Build-State and no frame_started.",
        "green",
        body_width=105,
    )
    save(img, "03_preview_widget_content_map.png")


def draw_stop_rules():
    img, d = canvas(
        "M16-P Stop Rules For Later Prompt",
        "The draft prompt must keep product, data, assets and build states out of scope",
    )
    items = [
        ("No app integration", "no Home, Onboarding, World or route", "red"),
        ("No persistence", "no Supabase, local DB or word_progress", "red"),
        ("No runtime config", "no flags, config or product navigation", "purple"),
        ("No assets", "no files under assets and no app screens", "yellow"),
        ("No auto placement", "suggestions only, user choice first", "blue"),
        ("No Build-State", "no build wheel, no frame_started", "red"),
        ("No tests now", "unless a later prompt explicitly allows", "gray"),
        ("No commit", "format, analyze, diff and status first", "green"),
    ]
    x0, y0, cw, ch = 140, 300, 490, 170
    for idx, (title, body, color) in enumerate(items):
        row = idx // 4
        col = idx % 4
        card(d, (x0 + col * 550, y0 + row * 250, cw, ch), title, body, color, title_size=26, body_size=19, body_width=31)
    pill(d, (570, 960, 1260, 62), "M16-P is a prompt draft, not an implementation grant", "purple")
    card(
        d,
        (430, 1085, 1540, 135),
        "Safe default",
        "If the later prompt cannot prove isolation and no data/app/assets impact, stop and report instead of editing.",
        "green",
        body_width=105,
    )
    save(img, "04_stop_rules_for_later_prompt.png")


def draw_contact_sheet():
    files = [
        "01_prompt_scope_boundary.png",
        "02_later_prompt_execution_flow.png",
        "03_preview_widget_content_map.png",
        "04_stop_rules_for_later_prompt.png",
    ]
    img = Image.new("RGB", (2400, 1900), BG)
    d = ImageDraw.Draw(img)
    d.text((92, 58), "M16-P Contact Sheet", fill=INK, font=F_TITLE)
    d.text((92, 140), "Quick overview of word semantics prompt draft visuals", fill=MUTED, font=F_SUB)
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
        "documentation preview only / prompt draft only / no code now / no app route / no persistence / no assets / no automatic placement / no frame_started",
        fill=INK,
        font=F_FOOT,
    )
    save(img, "00_contact_sheet.png")


def main():
    draw_scope_boundary()
    draw_execution_flow()
    draw_content_map()
    draw_stop_rules()
    draw_contact_sheet()
    for path in sorted(OUT_DIR.glob("*.png")):
        print(path)


if __name__ == "__main__":
    main()
