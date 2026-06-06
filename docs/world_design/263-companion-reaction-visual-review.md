# Phase 2G-M10-C2: Companion Reaction Visual Review

Stand: 2026-06-06

Status: `visuelle Pruefung gestartet / erste Richtung brauchbar`

Dieses Dokument prueft die M10-C-Previews visuell. Es entscheidet nicht ueber
Companion-Implementierung, finale Companion-UX, Voice, Audio, Animation,
Rive/FX, Spielassets, App-Integration, `frame_started` oder Bauzustaende.

## 1. Ziel

M10-C hat geplant und visualisiert, wie Tali/Vori den Depth-/Container-
Lernflow emotional begleitet:

```text
Haus/Kueche -> Schublade -> Besteck
```

M10-C2 prueft, ob dieser Companion Reaction Flow als erste Produkt- und
Planungsrichtung brauchbar ist oder nachgebessert werden muss.

## 2. Gepruefte Dateien

- `docs/world_design/previews/phase2g_m10c_companion_reaction_flow/01_companion_reaction_timeline.png`
- `docs/world_design/previews/phase2g_m10c_companion_reaction_flow/02_success_error_idle_reactions.png`
- `docs/world_design/previews/phase2g_m10c_companion_reaction_flow/03_companion_boundaries.png`
- `docs/world_design/previews/phase2g_m10c_companion_reaction_flow/README.md`

## 3. Visuelle Pruefung

| Prueffrage | Bewertung |
| --- | --- |
| Wird Tali/Vori als emotionaler Motivationsanker sichtbar? | Ja. Timeline und Reaktionspfade zeigen Tali/Vori als kleine, freundliche Praesenz an wichtigen Momenten. |
| Wird klar, dass Tali/Vori die Challenge nicht loest? | Ja. Timeline und Boundaries nennen explizit `Companion does not solve it` und `Challenge automatisch loesen` als verboten. |
| Wird klar, dass Tali/Vori keinen Druck erzeugen darf? | Ja. Die Timing Rules und Boundaries markieren `No pressure`, keine Schuld, keine harte Streak-Logik und keine erzwungene Fortsetzung. |
| Sind Success, Error und Idle/Hint getrennt verstaendlich? | Ja. `02_success_error_idle_reactions.png` trennt die drei Pfade klar nach Trigger, Companion Line, Result und Grenze. |
| Sind die Grenzen in `03_companion_boundaries.png` klar? | Ja. `Darf`, `Darf nicht` und `Offen / spaeter pruefen` sind gut getrennt und als Planungsgrenzen lesbar. |
| Wird Tali/Vori zu dominant oder bleibt die Challenge im Vordergrund? | Tali/Vori bleibt ausreichend klein und begleitend. Die Challenge bleibt inhaltlich beim Nutzer. |
| Sind die Texte freundlich, kurz und nicht beschaemend? | Ja. Beispiele wie `Gut gefunden!` und `Fast. Schau noch einmal auf die Form.` sind kurz und unterstuetzend. |
| Ist die Preview als Planungs-/Produktverstaendnis brauchbar? | Ja. Sie zeigt ausreichend, wie Companion-Reaktion als Motivation funktionieren kann, ohne finale UI zu behaupten. |
| Ist klar, dass keine Voice-/Audio-/Animation-Freigabe entsteht? | Ja. README und Boundary-Preview nennen Voice, Audio, Animation/Rive/FX als offen bzw. spaeter zu pruefen. |
| Ist klar, dass keine Companion-Implementierung entsteht? | Ja. Titel, Scope und README markieren die Previews als Dokumentation ohne Codefreigabe. |
| Ist die Text-Containment-Auffaelligkeit richtig dokumentiert? | Ja. Die Timeline hat nicht-blockierende knappe Labels; M10-C-Dokument, README, Roadmap und Template halten diese als Quality Note und Zukunftsregel fest. |

## 4. Entscheidungsempfehlung

Empfehlung:

```text
M10-C als erste Companion-Reaktionsrichtung grundsaetzlich bestaetigen.
```

Begruendung:

- Tali/Vori wird als emotionaler Motivationsanker sichtbar.
- Die Companion-Reaktion ist an sinnvolle Momente gebunden.
- Fehler und Untaetigkeit werden freundlich behandelt.
- Die Challenge wird nicht automatisch geloest.
- Die Previews setzen klare Grenzen gegen Druck, Schuldgefuehl und harte
  Streak-Mechanik.
- Die dokumentierte Text-Containment-Auffaelligkeit ist nicht blockierend,
  weil M10-C keine finale UI und kein Spielasset ist.

Diese Empfehlung bestaetigt nur eine erste Produkt-/Planungsrichtung. Sie ist
keine finale Companion-UX und keine Implementierungsfreigabe.

## 5. Auffaelligkeiten Und Risiken

- `01_companion_reaction_timeline.png` ist als Timeline brauchbar, aber einige
  lange Titel wirken knapp am Kartenrahmen.
- Zukuenftige Previews muessen Text-Containment vor Commit pruefen.
- Voice, Audio, Animation, Rive/FX und Companion-Personality-Varianten bleiben
  ungeprueft.
- Comeback-Erinnerungen brauchen spaeter eine Fairness- und Druck-Pruefung,
  damit sie nicht wie Streak-Zwang wirken.
- M10-C2 bestaetigt kein allgemeines Container-System; M11 bleibt offen.
- M10-C2 bestaetigt keine konkrete Companion-Implementierung.

## 6. Offene Follow-ups

| Follow-up | Status Nach M10-C2 | Bedeutung |
| --- | --- | --- |
| `Phase 2G-M10 Emotional Product Flow Preview` | `geprueft / grundsaetzlich brauchbar` | Emotionalere Produktflow-Preview bleibt als erstes Produktgefuehl brauchbar. |
| `Phase 2G-M10-B Challenge Interaction Comparison` | `geprueft / erste Empfehlung brauchbar` | Tap-Auswahl zuerst, Audio + Tap danach, Matching/Sortieren spaeter, Mini-Sequenzen advanced. |
| `Phase 2G-M10-C Companion Reaction Flow` | `geprueft / erste Richtung brauchbar` | Tali/Vori darf als sanfter Motivationsanker geplant werden, aber ohne finale UX- oder Implementierungsfreigabe. |
| `Phase 2G-M11 Multi-Example Container Flow Previews` | `offen` | Weitere Flows fuer Schule/Federmappe, Hafen/Bootskajute und Garten/Beet bleiben Pflichtpruefung. |

## 7. Stop-Regeln

Stoppen, wenn:

- aus M10-C2 Companion-Implementierung abgeleitet wird,
- finale Companion-UX ohne spaetere Detailpruefung entschieden wird,
- aus M10-C2 Voice-, Audio-, Animation- oder Rive-Freigabe abgeleitet wird,
- Companion-Personality-Varianten ohne eigenes Konzept geplant werden,
- Comeback-Erinnerungen ohne Fairness-/Druck-Pruefung geplant werden,
- aus M10-C oder M10-C2 App-, Code- oder Assetfreigabe abgeleitet wird,
- `frame_started` oder Bauzustaende aus diesem Review wieder aufgenommen werden.

## 8. Naechster Erlaubter Schritt

Nach M10-C2 ist erlaubt:

- M10-C dokumentarisch als erste Companion-Reaktionsrichtung bestaetigen,
- M11 Multi-Example Container Flow Previews planen,
- M10-C bei konkreten Companion-/Text-Containment-Bedenken gezielt
  nachbessern.

Weiterhin nicht erlaubt:

- Flutter-/Dart-Code,
- App-Integration,
- Tests,
- Spielassets,
- PNG-Aenderungen,
- finales Inselbild,
- `frame_started`,
- Bauzustaende,
- Companion-Implementierung,
- Voice-/Audio-/Animation-/Rive-Freigabe.
