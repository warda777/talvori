# MVP-Screenshot-Content-Auswahl

> Supersession notice: This document belongs to the old vocabulary-app MVP
> launch path. It is preserved as Foundation Build / future compliance
> material. The current public product direction is Talvori Welt; do not
> continue this as the next launch path without explicit decision.

Stand: 2026-05-31

Diese Datei dokumentiert eine sichere Auswahl gepruefter Englisch-Deutsch-Woerter fuer spaetere Store-Screenshots, Onboarding-Motive und die erste Nutzerreise. Es wurden keine Supabase-Daten, keine SQLite-/App-Vokabeldaten, keine SRS-/`word_progress`-Daten, keine Imports und keine Produktivfreigaben geaendert.

## 1. Ziel

Die Store-Screenshots sollen nur Inhalte zeigen, die im ersten MVP-Content-Review fachlich als unproblematisch fuer den MVP markiert wurden.

Die Auswahl ist bewusst klein. Sie ist keine Aussage, dass der komplette Wortbestand geprueft oder releasefertig ist.

## 2. Quelle Und Regel

Quelle:

- `docs/word-review/mvp_content_first_review_overlay.csv`

Auswahlregel:

- nur Zeilen mit `review_decision = approved_for_mvp`
- keine Zeilen mit `fix_translation_later`
- keine Zeilen mit `needs_context`
- keine Zeilen mit `reject_for_mvp`
- keine Zeilen mit `move_out_of_mvp`
- keine Produktivfreigabe, kein Import, kein `release_ready=true`

Aus dem Overlay wurden gefunden:

| Wortwelt | `approved_for_mvp` |
| --- | ---: |
| Travel | 21 |
| Food & Cooking | 46 |
| Home & Living | 48 |
| Gesamt | 115 |

Die exportierte Screenshot-Auswahl enthaelt:

| Wortwelt | Ausgewaehlt |
| --- | ---: |
| Travel | 11 |
| Food & Cooking | 20 |
| Home & Living | 20 |
| Gesamt | 51 |

Alle ausgewaehlten Begriffe sind aktuell A1-Begriffe. Das ist fuer die erste Nutzerreise und Store-Screenshots passend, weil die Beispiele einfach und schnell erfassbar bleiben.

## 3. Auswahl-Datei

Erzeugte CSV:

- `docs/word-review/mvp_screenshot_content_selection.csv`

Tool:

- `tool/export_mvp_screenshot_content_selection.dart`

Das Tool liest nur lokale CSV-Dateien. Es oeffnet keine Supabase- oder SQLite-Verbindung, fuehrt keinen Import aus, ruft keine KI auf und schreibt keine App-Daten.

## 4. Empfohlene Screenshot-Wortwelten

Fuer den ersten Store-Durchlauf werden diese Wortwelten empfohlen:

1. Travel
   - gut fuer ersten Eindruck und Onboarding
   - nur einfache Begriffe verwenden
   - spezialisierte Travel-Operationen wie `boarding pass`, `transfer`, `rebook` nicht als Primaerbeispiele nutzen

2. Food & Cooking
   - sehr alltagsnah
   - gut fuer Wortwelt- und Wortspiel-Screens
   - viele kurze A1-Begriffe vorhanden

3. Home & Living
   - gut fuer Lernmodus und erste Nutzerreise
   - viele kurze Alltagsbegriffe und einfache Handlungen vorhanden

## 5. Empfohlene Woerter Je Screenshot-Kontext

### Onboarding / Erster Eindruck

Geeignete Begriffe:

- Travel: `luggage`, `one-way ticket`, `airport`
- Food & Cooking: `napkin`, `pasta`, `salty`
- Home & Living: `drawer`, `hallway`, `dish towel`

Grund:

- kurz
- alltagsnah
- direkt verstaendlich
- keine sensiblen oder stark kontextabhaengigen Inhalte

### Home / Wortwelten

Geeignete Begriffe:

- Travel: `bag`, `international flight`, `mobile check-in`, `passport`, `plane`
- Food & Cooking: `pepper shaker`, `salt shaker`, `to cook`, `to cut`, `apple`
- Home & Living: `living room`, `to brush teeth`, `to clean`, `to eat at home`, `to shower`

Grund:

- zeigt klar die thematische Breite
- eignet sich fuer Karten, Listen oder kurze Wortwelt-Vorschauen

### Lernmodus

Geeignete Begriffe:

- Home & Living: `to sit`, `to sleep`, `to open the window`, `to wash the dishes`, `to water plants`
- Food & Cooking: `to cook`, `to cut`

Grund:

- einfache Handlungen
- gute Uebungsbeispiele fuer Wiederholung und aktive Nutzung

### Wortspiele

Geeignete Begriffe:

- Travel: `passport`, `plane`, `room`, `bus`, `hotel`
- Food & Cooking: `bottle`, `bread`, `breakfast`, `carrot`, `cheese`, `chicken`, `coffee`, `cup`
- Home & Living: `apartment`, `bathroom`, `bed`, `bedroom`, `chair`, `garden`, `internet`

Grund:

- kurz genug fuer Spielkarten
- gut lesbar
- keine langen Phrasen

### Travel

Primaer geeignet:

- `luggage`
- `airport`
- `bag`
- `passport`
- `plane`
- `one-way ticket`

Nur vorsichtig verwenden:

- `bus`
- `hotel`

Hinweis:

- `bus` und `hotel` sind Internationalismen. Sie sind approved, sollten aber nicht als alleiniger Beweis fuer Uebersetzungsqualitaet dienen.

### Food & Cooking

Primaer geeignet:

- `apple`
- `bread`
- `breakfast`
- `carrot`
- `cheese`
- `coffee`
- `cup`
- `pasta`
- `salt shaker`
- `to cook`

Hinweis:

- Einige Begriffe haben noch Struktur-Metadatenhinweise, weil A1/Top-500 aktuell teilweise in Kategorien stehen. Das ist kein Screenshot-Textproblem, bleibt aber fuer die spaetere Datenstruktur offen.

### Home & Living

Primaer geeignet:

- `drawer`
- `hallway`
- `living room`
- `bathroom`
- `bed`
- `bedroom`
- `chair`
- `garden`
- `to sleep`
- `to open the window`

Nur vorsichtig verwenden:

- `internet`

Hinweis:

- `internet` ist ein Internationalismus und sollte nicht als einziges Uebersetzungsbeispiel gezeigt werden.

## 6. Risiken Und No-Gos

Nicht fuer Screenshots verwenden:

- `fix_translation_later`
- `needs_context`
- `reject_for_mvp`
- `move_out_of_mvp`
- sehr lange Phrasen
- Fragen mit Satzzeichen
- stark spezialisierte Travel-Operationen
- sensible, peinliche oder kontextabhaengige Begriffe
- Woerter mit offensichtlicher Korrekturanforderung
- Spanisch-/Franzoesisch-Inhalte als fertige Produktfunktion

Weiterhin offen:

- Struktur-Metadaten muessen spaeter bereinigt werden.
- A1-C2 und Top 500 duerfen nicht als normale Wortwelten behandelt werden.
- Die Auswahl ersetzt keinen vollstaendigen Wort-fuer-Wort-Review des Gesamtbestands.

## 7. Status

- Screenshot-Content-Auswahl vorbereitet.
- Keine Screenshots erstellt.
- Keine UI geaendert.
- Keine Produktivdaten geaendert.
- Finaler Screenshot-Build-Test bleibt offen.
