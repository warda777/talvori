# Phase 2G-M9-B: Depth Container User Flow Visual Review

Stand: 2026-06-06

Status: `visuelle Pruefung gestartet / M9 grundsaetzlich brauchbar`

Dieses Dokument bewertet die Phase-2G-M9-Preview visuell. Es klaert, ob der
Flow `Haus/Kueche -> Schublade -> Besteck` als erste vereinfachte Nutzer-/
Produktansicht fuer Depth-/Container-Lernen brauchbar ist oder nachgebessert
werden muss.

Die Pruefung gibt keine Freigabe fuer:

- Flutter-/Dart-Code,
- App-Integration,
- Tests,
- Spielassets,
- PNGs im Asset-Ordner,
- finales Inselbild,
- `frame_started`,
- neue Bauzustaende,
- produktive Bau-/Lernlogik.

## 1. Zweck

M9-B prueft, ob die M9-Preview das Ziel aus
`docs/world_design/255-world-depth-gameplay-retention-research.md` erfuellt:

```text
Container sind keine Objektlisten. Der Nutzer soll ein Objekt oeffnen, eine
kleine Lern-Challenge loesen, klares Feedback erhalten und einen ruhigen
Reward Moment sehen.
```

## 2. Gepruefte Dateien

Geprueft wurden:

- `docs/world_design/previews/phase2g_m9_depth_container_user_flow/01_depth_flow_storyboard.png`
- `docs/world_design/previews/phase2g_m9_depth_container_user_flow/02_depth_level_stack.png`
- `docs/world_design/previews/phase2g_m9_depth_container_user_flow/03_interaction_reward_loop.png`
- `docs/world_design/previews/phase2g_m9_depth_container_user_flow/README.md`

Die Dateien sind Dokumentations-/Previewmaterial. Sie sind keine Spielassets
und keine finale UI.

## 3. Visuelle Bewertung

| Prueffrage | Bewertung |
| --- | --- |
| Ist der Flow `Haus/Kueche -> Schublade -> Besteck` verstaendlich? | Ja. Das Storyboard zeigt den Weg von Raum ueber Schublade bis Mini-Challenge in klarer Reihenfolge. |
| Wird klar, dass der Nutzer aktiv etwas tut? | Ja. Der Tap auf die Schublade und die Besteck-Auswahl in der Mini-Challenge sind sichtbar. |
| Wird klar, dass der Container nicht nur eine Objektliste ist? | Ja. Das Storyboard zeigt die Mini-Challenge, und der Interaction-/Reward-Loop nennt explizit, dass Container keine Objektlisten sind. |
| Wird klar, dass eine Mini-Challenge Teil des Flows ist? | Ja. Panel 5 und der Loop-Schritt `loesen` machen die Aufgabe sichtbar. |
| Sind Feedback und Reward Moment sichtbar? | Ja. `Richtig!`, `Schublade 1/3`, Objektmarkierung und Fortschritt sind als Reward Moment erkennbar. |
| Ist das naechste Ziel optional statt Druck? | Ja. Das Storyboard formuliert das naechste Ziel als optionalen Vorschlag. |
| Wirkt die Ansicht zu technisch? | Nein fuer interne Produktplanung. Sie ist deutlich weniger technisch als M7-B. |
| Wirkt die Ansicht zu leer oder zu schematisch? | Teilweise. Die Preview ist bewusst schematisch und transportiert noch wenig Atmosphaere. |
| Fehlt emotionale/spielerische Wirkung? | Teilweise. Tali/Vori-Reaktion ist sichtbar, aber noch sehr klein und textlich. |
| Ist die Preview als Produktverstaendnis brauchbar? | Ja, als erste vereinfachte Nutzer-/Produktansicht. |
| Ist sie weiterhin klar keine finale UI und kein Spielasset? | Ja. Alle Dateien und README markieren den Dokumentationsstatus klar. |

## 4. Einzelbewertung Der Preview-Dateien

### `01_depth_flow_storyboard.png`

Das Storyboard ist die wichtigste Produktansicht. Es zeigt sieben Schritte:
Kueche, Schublade tippen, Fokus/Zoom, Schublade offen, Mini-Challenge,
Feedback/Reward und naechstes Ziel.

Bewertung: `brauchbar als erste vereinfachte Nutzer-/Produktansicht`.

Risiko:

- Die Darstellung ist noch schematisch.
- Die emotionale Szene muss spaeter staerker werden, ohne zur finalen UI zu
  werden.

### `02_depth_level_stack.png`

Der Depth Stack zeigt sauber, dass kleine Woerter nicht dauerhaft auf die
Island View gehoeren. Der Beispielpfad von `InteriorView` bis
`DetailInteractionView` ist lesbar.

Bewertung: `brauchbar als Produkt-/Planungsverstaendnis fuer Depth`.

Risiko:

- Fuer echte Nutzer waere diese Ansicht noch zu abstrakt. Sie eignet sich fuer
  Produktplanung, nicht fuer App-UX.

### `03_interaction_reward_loop.png`

Der Loop zeigt, dass Container-Lernen aus Entdecken, Oeffnen, Erkennen,
Loesen, Feedback, Sammeln/Verbessern und naechstem Ziel besteht. Die Kernregel
ist sichtbar.

Bewertung: `brauchbar als vereinfachter Motivations- und Aufgabenloop`.

Risiko:

- Der konkrete Challenge-Typ bleibt offen: Tap, Audio, Drag-and-drop oder
  Zuordnung muessen spaeter separat entschieden werden.

### `README.md`

Das README dokumentiert Zweck, Dateien, Prueffazit, Risiken und Grenzen klar.

Bewertung: `brauchbar`.

## 5. Entscheidungsempfehlung

Empfehlung:

```text
M9 als erste vereinfachte Nutzer-/Produktansicht grundsaetzlich bestaetigen.
```

Begruendung:

- M9 loest die wichtigste M8-Frage visuell: Depth-/Container-Lernen ist mehr
  als eine Objektliste.
- Der Flow zeigt aktive Nutzerhandlung, Mini-Challenge, Feedback, Reward und
  optionales naechstes Ziel.
- Die Preview bleibt klar Dokumentationsmaterial und erzeugt keine Asset- oder
  Codefreigabe.

Einschraenkung:

M9 darf nicht allein als allgemeines Container-System bestaetigt werden. Ein
einziger Kuechen-Flow reicht nicht fuer alle Themeninseln, Worttypen und
Containerarten.

## 6. Entscheidungmoeglichkeiten

| Option | Bewertung |
| --- | --- |
| M9 als erste vereinfachte Nutzer-/Produktansicht bestaetigen | Empfohlen fuer den konkreten Beispiel-Flow. |
| M9 mit kleinen Nachbesserungen bestaetigen | Nicht zwingend noetig, aber spaeter moeglich, wenn emotionale Wirkung sichtbarer werden soll. |
| M9 erneut nachbessern | Aktuell nicht noetig. |
| Zusaetzlich weitere Beispiel-Flows planen | Empfohlen, bevor ein allgemeines Container-System abgeleitet wird. |

## 7. Empfohlene Weitere Beispiel-Flows

Weitere Flows sollten andere Themen, andere Objektarten und andere Container
pruefen:

- Schule -> Federmappe -> Stifte
  - prueft Schulobjekte, kleine Gegenstaende, Sortieren und Zuordnen.
- Hafen -> Bootskajute -> Kompass/Karte/Seil
  - prueft Themeninsel-/Reisebezug, Navigation und Abenteuerobjekte.
- Garten -> Beet -> Samen/Giesskanne/Pflanze
  - prueft Aussenbereich, Wachstum, Objektkette und Fortschritt ueber Zeit.

Optional spaeter:

- Werkstatt -> Werkzeugkasten -> Hammer/Zange/Schraube
- Medizinbereich -> Medizinschrank -> Pflaster/Salbe/Tablette
- Reise -> Koffer -> Ticket/Pass/Hemd

## 8. Weiterhin Blockiert

Weiterhin blockiert bleiben:

- Flutter-/Dart-Code,
- App-Integration,
- Tests,
- Spielassets,
- PNGs im Asset-Ordner,
- finales Inselbild,
- `frame_started`,
- neue Bauzustaende,
- produktive Bau-/Lernlogik,
- Persistenz,
- Supabase,
- SRS-/`word_progress`,
- Reward Bridge,
- Ressourcenlogik,
- Sound-/FX-Schicht.

## 9. Stop-Regeln

Stoppen, wenn:

- aus nur einem Beispiel-Flow eine Produktentscheidung fuer alle Themen
  abgeleitet werden soll,
- ein Container-System ohne mehrere Beispiel-Flows bestaetigt werden soll,
- finale Nutzer-UX ohne emotionale/spielerische Pruefung abgeleitet werden
  soll,
- aus M9 oder M9-B Codefreigabe abgeleitet wird,
- aus M9 oder M9-B Assetfreigabe abgeleitet wird,
- die M9-Preview als finale App-UI oder finales Spielasset gelesen wird.

## 10. Naechster Erlaubter Schritt

Nach M9-B ist erlaubt:

- M9 als ersten Beispiel-Flow dokumentarisch bestaetigen,
- weitere Beispiel-Flows planen,
- eine neue Preview fuer Schule/Federmappe, Hafen/Bootskajute oder
  Garten/Beet planen oder erzeugen.

Weiterhin nicht erlaubt:

- Code,
- Assets,
- App-Integration,
- `frame_started`,
- produktive Bau-/Lernlogik.

## 11. Verbindliche Follow-up-Punkte

Die folgenden Punkte sind keine optionalen Randnotizen. Sie muessen in
kommenden Planungsbloecken aktiv verfolgt werden, damit M9-B nicht zu frueh
als abgeschlossenes Depth-/Container-System gelesen wird.

M9-B darf als erster Beispiel-Flow grundsaetzlich bestaetigt werden. Es darf
aber nicht als allgemeine Container-/Depth-Systemfreigabe gelten.

| Offener Punkt | Warum wichtig | Folgeblock | Status |
| --- | --- | --- | --- |
| Emotionale/spielerische Version der Preview | Die aktuelle Preview ist schematisch und zeigt noch wenig Atmosphaere, Neugier und Spielreiz. | `Phase 2G-M10 Emotional Product Flow Preview` | geprueft / grundsaetzlich brauchbar |
| Challenge-Art entscheiden | Tap, Audio, Drag-and-drop und Zuordnung erzeugen unterschiedliche UX, Schwierigkeit, Barrierefreiheit und Entwicklungsaufwand. | `Phase 2G-M10-B Challenge Interaction Comparison` | geprueft / erste Empfehlung brauchbar |
| Tali/Vori Companion-Reaktion visualisieren | Tali/Vori ist ein wichtiger emotionaler Motivationsanker und darf nicht nur als Textzeile erscheinen. | `Phase 2G-M10-C Companion Reaction Flow` | gestartet / Preview erzeugt / Review offen |
| Weitere Beispiel-Flows | Ein Kuechenflow reicht nicht fuer Schule, Hafen, Garten und andere Themen. | `Phase 2G-M11 Multi-Example Container Flow Previews` | offen |
| Keine Code-/Assetfreigabe | M9/M9-B ist Dokumentation und visuelle Pruefung, keine Implementierung. | bleibt Stop-Regel | aktiv |
| `frame_started` bleibt gestoppt | Bauassets sind weiterhin nicht freigegeben. | bleibt Stop-Regel | aktiv |

Diese Follow-ups muessen entweder umgesetzt, geprueft oder bewusst mit
Begruendung zurueckgestellt werden, bevor eine finale Depth-/Container-UX,
Challenge-Implementierung oder allgemeine Container-Systementscheidung
abgeleitet wird.

M10 hat den ersten Follow-up-Punkt gestartet und Preview-Dateien unter
`docs/world_design/previews/phase2g_m10_emotional_product_flow/` erzeugt. Die
visuelle M10-D-Pruefung liegt in
`docs/world_design/259-emotional-product-flow-visual-review.md`. Ergebnis:
M10 ist als emotionalere Produktflow-Preview grundsaetzlich brauchbar.

M10-B hat den Challenge-Interaktionsvergleich in
`docs/world_design/260-challenge-interaction-comparison.md` gestartet und
Preview-Dateien unter
`docs/world_design/previews/phase2g_m10b_challenge_interaction_comparison/`
erzeugt. Ergebnis fuer den Review-Stand: Tap-Auswahl ist die empfohlene erste
Prototype-Challenge, Audio + Tap die zweite Stufe, Matching/Sortieren spaetere
Varianten und Mini-Sequenzen spaeter fuer Aktionswoerter. Diese Empfehlung ist
in der visuellen M10-B2-Pruefung
`docs/world_design/261-challenge-interaction-visual-review.md` als erste
Prototype-Richtung grundsaetzlich brauchbar. Sie ist weiterhin keine finale
Challenge-Systementscheidung fuer alle Themen.

M10-C hat den Tali/Vori Companion Reaction Flow in
`docs/world_design/262-companion-reaction-flow.md` gestartet und Preview-
Dateien unter
`docs/world_design/previews/phase2g_m10c_companion_reaction_flow/` erzeugt.
Der Flow visualisiert Curiosity Cue, Gentle Nudge, Challenge Support, Success
Reaction, Correction Support, Idle Hint und optionale Next Goal Suggestion.
Diese Preview ist keine finale Companion-UX, keine Voice-/Audio-/Animation-
Freigabe und keine Implementierung. M11 bleibt weiterhin offen.
