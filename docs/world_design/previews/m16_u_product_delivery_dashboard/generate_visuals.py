from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

OUT_DIR = Path(__file__).resolve().parent
W, H = 2400, 1600
BG = "#f7f5ef"
INK = "#25322e"
MUTED = "#67736f"
LINE = "#cbd5ce"
WHITE = "#fffdf8"
GREEN = "#dcefdc"
BLUE = "#dce9f4"
YELLOW = "#fff0c7"
RED = "#f5d8d2"
PURPLE = "#e9ddf2"
GREEN_D = "#42794f"
BLUE_D = "#3f7092"
YELLOW_D = "#8b6c24"
RED_D = "#915046"
PURPLE_D = "#715a89"
FOOTER = "documentation preview only / no code / no assets / no implementation"


def font(size, bold=False):
    candidates = [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/Library/Fonts/Arial Bold.ttf" if bold else "/Library/Fonts/Arial.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    ]
    for candidate in candidates:
        try:
            return ImageFont.truetype(candidate, size)
        except OSError:
            pass
    return ImageFont.load_default()


TITLE = font(58, True)
SUB = font(30)
HEAD = font(32, True)
BODY = font(25)
SMALL = font(21)


def size(draw, text, fnt):
    box = draw.textbbox((0, 0), text, font=fnt)
    return box[2] - box[0], box[3] - box[1]


def wrap(draw, text, fnt, width):
    words = text.split()
    lines, current = [], ""
    for word in words:
        test = word if not current else f"{current} {word}"
        if size(draw, test, fnt)[0] <= width:
            current = test
        else:
            if current:
                lines.append(current)
            current = word
    if current:
        lines.append(current)
    return lines


def text(draw, xy, content, fnt, fill, width, gap=8):
    x, y = xy
    for line in wrap(draw, content, fnt, width):
        draw.text((x, y), line, font=fnt, fill=fill)
        y += size(draw, line, fnt)[1] + gap
    return y


def rounded(draw, box, fill=WHITE, outline=LINE, radius=24, width=3):
    draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def base(title, subtitle):
    img = Image.new("RGB", (W, H), BG)
    draw = ImageDraw.Draw(img)
    draw.text((110, 70), title, font=TITLE, fill=INK)
    draw.text((112, 145), subtitle, font=SUB, fill=MUTED)
    draw.line((110, 210, W - 110, 210), fill=LINE, width=3)
    draw.text((110, H - 80), FOOTER, font=SMALL, fill=MUTED)
    return img, draw


def card(draw, box, title, body, fill, accent):
    rounded(draw, box, fill=fill)
    x1, y1, x2, y2 = box
    draw.rounded_rectangle((x1, y1, x1 + 14, y2), radius=14, fill=accent)
    draw.text((x1 + 34, y1 + 28), title, font=HEAD, fill=INK)
    text(draw, (x1 + 34, y1 + 82), body, BODY, MUTED, x2 - x1 - 68)


def arrow(draw, start, end):
    draw.line([start, end], fill="#84978f", width=5)
    sx, sy = start
    ex, ey = end
    if abs(ex - sx) >= abs(ey - sy):
        dx = 1 if ex >= sx else -1
        head = [(ex, ey), (ex - 20 * dx, ey - 12), (ex - 20 * dx, ey + 12)]
    else:
        dy = 1 if ey >= sy else -1
        head = [(ex, ey), (ex - 12, ey - 20 * dy), (ex + 12, ey - 20 * dy)]
    draw.polygon(head, fill="#84978f")


def progress_bar(draw, box, pct):
    rounded(draw, box, fill="#edf1ec", outline=LINE, radius=22, width=2)
    x1, y1, x2, y2 = box
    fill_w = int((x2 - x1) * pct)
    draw.rounded_rectangle((x1, y1, x1 + fill_w, y2), radius=22, fill=GREEN_D)


def progress_dashboard():
    img, draw = base("M16-U Product Delivery Dashboard", "119 items / Scrum-lite / MVP steering / no implementation")
    card(draw, (120, 280, 780, 560), "Overall Progress", "16 done, 10 partial, 79 open, 12 blocked, 2 outsourced.", BLUE, BLUE_D)
    draw.text((180, 640), "17.6 %", font=font(86, True), fill=GREEN_D)
    progress_bar(draw, (180, 760, 1080, 835), 0.176)
    card(draw, (1220, 280, 2220, 560), "Next Recommended IDs", "MVP-004, CORE-001, L2W-001, WOT-001, REWARD-001, QUEUE-001, RESEARCH-002, RESEARCH-003.", GREEN, GREEN_D)
    card(draw, (120, 970, 720, 1240), "Ready / Partial", "Dashboard, Scrum-lite, MVP framing, Change Intake and Research Gate are now documented.", GREEN, GREEN_D)
    card(draw, (780, 970, 1420, 1240), "Needs Work", "Core Loop, Learning-to-World Contract, Word Outcomes, Reward, Queue and Game Pillars.", YELLOW, YELLOW_D)
    card(draw, (1480, 970, 2220, 1240), "Blocked", "Persistence, Supabase writes, App integration, Route, Assets, Build-State and frame_started.", RED, RED_D)
    img.save(OUT_DIR / "progress_dashboard.png")


def mvp_roadmap():
    img, draw = base("MVP Roadmap", "First runnable version: small playable learning loop")
    steps = [
        ("MVP Critical", "Product anchor, Core Loop, L2W Contract, Word Outcomes, Semantics, Reward, Queue, Game Pillars.", GREEN, GREEN_D),
        ("Before MVP", "Mobile density, Companion policy, Architecture boundaries and data direction.", YELLOW, YELLOW_D),
        ("After MVP", "Build-Wheel, deep containers, Social/Competition and advanced metrics.", BLUE, BLUE_D),
        ("Release Critical", "Persistence, migrations, tests, accessibility, assets, privacy and commit hygiene.", PURPLE, PURPLE_D),
        ("Blocked Gates", "Supabase writes, App route, Build-State, assets, frame_started and automatic placement.", RED, RED_D),
    ]
    x, y = 120, 300
    for i, (title, body, fill, accent) in enumerate(steps):
        box = (x, y, x + 390, y + 520)
        card(draw, box, title, body, fill, accent)
        if i < len(steps) - 1:
            arrow(draw, (x + 390, y + 260), (x + 455, y + 260))
        x += 455
    card(draw, (420, 1040, 1980, 1265), "MVP Principle", "Not all 119 items are required before a first playable version, but learning logic, reward, word outcomes, sensitive rules, queue and minimal world feedback must harmonize.", BLUE, BLUE_D)
    img.save(OUT_DIR / "mvp_roadmap.png")


def scrum_lite_flow():
    img, draw = base("Scrum-lite Operating Model", "M16-T as product backlog, selected IDs as sprint backlog")
    steps = [
        ("Product Backlog", "M16-T IDs"),
        ("Sprint Backlog", "selected IDs"),
        ("Sprint Goal", "one sentence"),
        ("Ready", "scope, docs, stops"),
        ("Do Work", "Codex + review"),
        ("Done", "checks + status"),
    ]
    x, y = 150, 340
    for title, body in steps:
        card(draw, (x, y, x + 315, y + 230), title, body, BLUE, BLUE_D)
        if title != "Done":
            arrow(draw, (x + 315, y + 115), (x + 365, y + 115))
        x += 370
    card(draw, (210, 810, 720, 1080), "Product Owner", "Andreas / project decisions.", GREEN, GREEN_D)
    card(draw, (820, 810, 1330, 1080), "Product Coach", "ChatGPT review and structure.", PURPLE, PURPLE_D)
    card(draw, (1430, 810, 1940, 1080), "Implementation", "Codex plus manual verification.", YELLOW, YELLOW_D)
    card(draw, (620, 1210, 1800, 1390), "Commit Rule", "Commit only after separate approval. Every output reports M16-T IDs, diff check and git status.", RED, RED_D)
    img.save(OUT_DIR / "scrum_lite_flow.png")


def research_to_product_loop():
    img, draw = base("Research to Product Loop", "Benchmarks become Talvori principles, not copied mechanics")
    boxes = [
        ("Benchmark", "Duolingo, Supercell/Clash and later learning/game apps.", BLUE, BLUE_D),
        ("Extract Principles", "What works, why it works, what fits Talvori.", GREEN, GREEN_D),
        ("Risk Filter", "Retention pressure, pay-to-win, unfair competition, privacy.", RED, RED_D),
        ("Talvori Rule", "Learning remains more important than pressure or monetization.", YELLOW, YELLOW_D),
        ("M16-T Update", "IDs, gates and MVP relevance are updated before code.", PURPLE, PURPLE_D),
    ]
    positions = [(150, 340), (580, 340), (1010, 340), (1440, 340), (850, 820)]
    for (title, body, fill, accent), (x, y) in zip(boxes, positions):
        card(draw, (x, y, x + 360, y + 250), title, body, fill, accent)
    arrow(draw, (510, 465), (580, 465))
    arrow(draw, (940, 465), (1010, 465))
    arrow(draw, (1370, 465), (1440, 465))
    arrow(draw, (1620, 590), (1210, 820))
    arrow(draw, (850, 945), (330, 590))
    card(draw, (420, 1240, 1980, 1410), "Research Gate", "No productive learning, reward, level, social, competition, retention or game mechanic without benchmark review and Talvori-specific principle.", RED, RED_D)
    img.save(OUT_DIR / "research_to_product_loop.png")


def change_intake_flow():
    img, draw = base("Change and Idea Intake", "New ideas are evaluated before they become scope")
    steps = [
        ("Idea", "source and reason"),
        ("Hypothesis", "what might improve"),
        ("Affected IDs", "link M16-T items"),
        ("Decision", "take, park, reject, research"),
        ("Next Step", "gate, docs, prompt or no action"),
    ]
    x, y = 170, 360
    for title, body in steps:
        card(draw, (x, y, x + 360, y + 260), title, body, GREEN if title != "Decision" else YELLOW, GREEN_D if title != "Decision" else YELLOW_D)
        if title != "Next Step":
            arrow(draw, (x + 360, y + 130), (x + 430, y + 130))
        x += 430
    card(draw, (260, 860, 1080, 1130), "Risk Check", "MVP relevance, architecture risk, safety risk, retention pressure and Stop Rules.", RED, RED_D)
    card(draw, (1320, 860, 2140, 1130), "Traceability", "Every accepted idea creates, updates or links stable M16-T IDs.", BLUE, BLUE_D)
    card(draw, (620, 1260, 1780, 1410), "Rule", "New ideas never go straight into implementation.", PURPLE, PURPLE_D)
    img.save(OUT_DIR / "change_intake_flow.png")


def contact_sheet():
    files = [
        "progress_dashboard.png",
        "mvp_roadmap.png",
        "scrum_lite_flow.png",
        "research_to_product_loop.png",
        "change_intake_flow.png",
    ]
    img = Image.new("RGB", (2400, 2100), BG)
    draw = ImageDraw.Draw(img)
    draw.text((100, 70), "M16-U Product Delivery Visuals", font=TITLE, fill=INK)
    draw.text((102, 145), "contact sheet / documentation previews only", font=SUB, fill=MUTED)
    positions = [(120, 260), (890, 260), (1660, 260), (500, 910), (1280, 910)]
    tw, th = 620, 415
    for name, (x, y) in zip(files, positions):
        src = Image.open(OUT_DIR / name).convert("RGB")
        src.thumbnail((tw, th))
        rounded(draw, (x - 18, y - 18, x + tw + 18, y + th + 74), fill=WHITE)
        img.paste(src, (x + (tw - src.width) // 2, y))
        text(draw, (x, y + th + 22), name, SMALL, INK, tw)
    draw.text((100, 2010), FOOTER, font=SMALL, fill=MUTED)
    img.save(OUT_DIR / "00_contact_sheet.png")


def main():
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    progress_dashboard()
    mvp_roadmap()
    scrum_lite_flow()
    research_to_product_loop()
    change_intake_flow()
    contact_sheet()
    for file in sorted(OUT_DIR.glob("*.png")):
        print(file)


if __name__ == "__main__":
    main()
