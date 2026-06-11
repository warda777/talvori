# Template: Visual Documentation Slice

Status: `Arbeitsvertrag / keine Asset- oder App-Screen-Freigabe`

## Einsatz

Nutze dieses Template fuer Diagramme, PNG/SVG-Boards, Contact Sheets und
repo-native Dokumentationsvisuals, wenn der Kurzprompt Visuals ausdruecklich
erlaubt.

## Kurzprompt muss nennen

- Slice-ID,
- Ziel,
- erwartete Dokumentationsdateien,
- erwarteter Preview-Ordner,
- erlaubte Visualformate,
- ob PNG/SVG/Contact Sheet erforderlich sind,
- besondere Visual-QA-Kriterien,
- Commit-Status.

## Harte Grenzen

- Keine Visuals erzeugen, wenn der Kurzprompt sie nicht ausdruecklich erlaubt.
- Keine App-Screens, ausser explizit als nicht-produktives Konzept erlaubt.
- Keine Spielassets.
- Keine Dateien unter `assets/`.
- Keine Screenshots als Repo-Artefakte, ausser der Kurzprompt erlaubt sie
  ausdruecklich.
- Keine externen Figma-/Canva-/Notion-/Linear-/GitHub-Writes ohne Freigabe.

## Visual-QA

Pruefe:

- Text bleibt in Rahmen,
- keine abgeschnittenen Woerter,
- keine Text- oder Label-Ueberlappungen,
- ausreichender Innenabstand,
- Contact Sheet lesbar, falls erzeugt,
- PNG oeffnet oder ist plausibel pruefbar,
- SVG ist strukturiert und nach Moeglichkeit XML-valide,
- Visuals sind Dokumentationsmaterial, keine App-Screens und keine Assets.

## Standardchecks

```bash
git status --short
git diff --check
git status --short -- lib assets test integration_test ios android macos web windows linux
```

Falls SVG erzeugt wurde und `xmllint` verfuegbar ist, SVG pruefen.

## Abschlussbericht

Berichte:

- genutztes Template,
- erzeugte Visuals,
- geaenderte/erstellte Dateien,
- neue/geaenderte M16-T-IDs,
- Visual-QA-Ergebnis,
- Scope-Check,
- ob keine App-Screens/Assets entstanden sind,
- Risiken/offene Punkte,
- kein Commit durchgefuehrt: JA/NEIN.

