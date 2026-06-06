# Phase 2G-M10: Emotional Product Flow Preview Plan

Stand: 2026-06-06

Status: `Planungs- und Visualisierungsblock gestartet`

Dieses Dokument plant und bewertet eine emotionalere, spielnaehere
Produktflow-Preview fuer den bestehenden M9-Flow:

```text
Haus/Kueche -> Schublade -> Besteck
```

M10 ist kein Flutter-/Dart-Code, keine App-Integration, kein Testblock, keine
Spielasset-Produktion, kein finales Inselbild, kein `frame_started` und keine
Bauzustandsarbeit.

## 1. Ziel

M9 hat gezeigt, dass Depth-/Container-Lernen als Nutzerflow grundsaetzlich
verstaendlich ist. M9 war aber noch schematisch. M10 prueft deshalb, wie der
gleiche Flow produktnaeher wirken kann:

- mehr Neugier,
- kleine Spannung,
- Entdeckung,
- positive Rueckmeldung,
- ruhiger Belohnungsmoment,
- Tali/Vori-Praesenz als Motivationsanker,
- klare freiwillige naechste Aktion.

Die Preview soll Produktgefuehl erzeugen, aber keine finale UI behaupten.

## 2. Fuehrende Grundlagen

- `docs/world_design/255-world-depth-gameplay-retention-research.md`
- `docs/world_design/256-depth-container-user-flow-preview-plan.md`
- `docs/world_design/257-depth-container-user-flow-visual-review.md`
- `docs/world_design/235-world-production-roadmap-and-checklists.md`
- `assets/images/world/buildable_islands/forest_clearing/template.md`

## 3. Emotional Erweiterter Beispiel-Flow

Der M9-Flow wird in M10 nicht ersetzt, sondern emotional angereichert:

| Schritt | Produktmoment | Zweck |
| --- | --- | --- |
| 1. Ruhige Kueche | Nutzer sieht einen warmen, ruhigen Kuechenbereich. | Orientierung ohne Ueberladung. |
| 2. Curiosity Cue | Die Schublade glimmt leicht, ein kleines Fragezeichen erscheint, Tali/Vori schaut neugierig hin. | Neugier ohne Druck. |
| 3. Nutzer tippt | Nutzer tippt die Schublade direkt an. | Aktive Handlung. |
| 4. Fokus und Oeffnen | Schublade fokussiert und oeffnet sich. | Entdeckungsmoment. |
| 5. Wenige Objekte | Loeffel, Gabel und Messer sind sichtbar, aber nicht ueberladen. | Kleine Woerter in passender Tiefe. |
| 6. Mini-Challenge | Frage: `Finde den Loeffel`. Nutzer waehlt das passende Objekt. | Lernen statt Museum. |
| 7. Feedback | Kurzer Glow, Objekt springt leicht oder wird markiert, Tali/Vori reagiert freundlich. | Positive Rueckmeldung. |
| 8. Reward und naechstes Ziel | Loeffel wird ins Set aufgenommen, `Schublade 1/3`, optionaler Vorschlag: `Als naechstes: Gabel?` | Fortschritt und freiwillige Fortsetzung. |

## 4. Preview-Dateien

M10 erzeugt Dokumentations-/Preview-Dateien unter:

```text
docs/world_design/previews/phase2g_m10_emotional_product_flow/
```

Dateien:

| Datei | Zweck |
| --- | --- |
| `01_emotional_storyboard.png` | 8-Panel-Storyboard mit Neugier, Oeffnen, Challenge, Feedback, Reward und naechstem Ziel. |
| `02_emotion_motivation_beats.png` | Emotionale Beats von Curiosity Cue bis Next Goal. |
| `03_tali_vori_light_reaction_concept.png` | Leichter Companion-Reaktionsablauf als Vorgeschmack, nicht M10-C-Vollausarbeitung. |
| `README.md` | Zweck, Dateien, Prueffazit, Grenzen und Blocker. |

Die Dateien sind Dokumentationsmaterial und keine Spielassets.

## 5. Produktregeln Fuer M10

- Die Preview darf mehr Atmosphaere zeigen als M9.
- Sie bleibt trotzdem klar eine Storyboard-/Diagramm-Preview.
- Keine finale App-UI behaupten.
- Keine finale Kunst oder Spielasset-Optik erzeugen.
- Keine Sounddateien erzeugen; Audio-Hinweise bleiben rein konzeptionell.
- Keine Companion-Implementierung ableiten.
- Keine Challenge-Art final entscheiden.
- Das naechste Ziel bleibt freiwillig.
- Tali/Vori darf motivieren, aber nicht hetzen.
- Der Reward Moment zeigt Fortschritt, nicht Druck.

## 6. Pruefkriterien

M10 ist brauchbar, wenn:

- der gleiche Kuechen-Flow emotionaler wirkt als M9,
- Curiosity Cue, Entdeckung, Challenge, Feedback und Reward sichtbar sind,
- Tali/Vori als leichter Motivationsanker erkennbar ist,
- die Preview nicht wie finale UI oder finales Spielasset wirkt,
- die Challenge-Art noch offen bleibt,
- M10-B, M10-C und M11 nicht durch M10 ersetzt werden,
- keine Code- oder Assetfreigabe daraus abgeleitet wird.

## 7. Sichtbare Risiken

- Die Preview kann trotz mehr Atmosphaere noch zu diagrammatisch wirken.
- Zu viele Emotionsmarker koennten spaeter wie UI-Chaos wirken.
- Tali/Vori-Reaktion ist nur angerissen und braucht M10-C als eigenen Block.
- Die Challenge-Art bleibt offen und braucht M10-B.
- Ein einzelner Kuechenflow reicht weiterhin nicht fuer ein allgemeines
  Container-System.

## 8. Was M10 Nicht Entscheidet

M10 entscheidet nicht:

- finale UI,
- finale Illustration,
- Sound-/FX-Design,
- Challenge-Typ,
- Companion-System,
- Container-System fuer alle Themen,
- Implementierung,
- App-Integration,
- Asset-Freigabe,
- `frame_started`.

## 9. Naechster Erlaubter Schritt

Nach M10 ist erlaubt:

- M10 visuell pruefen,
- die emotionale Produktflow-Preview bestaetigen oder nachbessern,
- M10-B Challenge Interaction Comparison planen,
- M10-C Companion Reaction Flow planen,
- M11 Multi-Example Container Flow Previews planen.

Weiterhin nicht erlaubt:

- Flutter-/Dart-Code,
- App-Integration,
- Tests,
- Spielassets,
- PNGs im Asset-Ordner,
- finales Inselbild,
- `frame_started`,
- Bauzustaende,
- produktive Bau-/Lernlogik.

## 10. Stop-Regeln

Stoppen, wenn:

- die emotionale Produktpreview als finale UI gelesen wird,
- aus M10 Sound-/FX-Implementierung abgeleitet wird,
- aus M10 Companion-Implementierung abgeleitet wird,
- die Challenge-Art final entschieden werden soll, bevor M10-B erfolgt,
- eine allgemeine Container-UX bestaetigt werden soll, bevor M10-B, M10-C und
  M11 geprueft sind,
- Code- oder Assetfreigabe aus M10 abgeleitet wird.
