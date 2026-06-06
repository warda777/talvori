# Phase 2G-M11: Multi-Example Container Flow Previews

Stand: 2026-06-06

Status: `gestartet / Preview erzeugt / Review offen`

Dieses Dokument plant und bewertet mehrere Depth-/Container-Beispiel-Flows.
M11 prueft, ob die Grundlogik aus M9 bis M10-C nicht nur fuer
`Haus/Kueche -> Schublade -> Besteck` funktioniert, sondern auch fuer andere
Themen, Containerarten, Worttypen und Lernhandlungen.

M11 gibt keine finale Container-Systemarchitektur frei. M11 erzeugt keine
Spielassets, keine finale UI, keine App-Integration und keinen Code.

## 1. Zweck

M9 hat gezeigt, dass ein einzelner Flow mit Kueche, Schublade und Besteck als
erste vereinfachte Nutzer-/Produktansicht brauchbar ist. Ein einzelner Flow
reicht aber nicht, um ein allgemeines Depth-/Container-System fuer Talvori
abzuleiten.

M11 soll daher pruefen:

- ob Container-Lernen ueber mehrere Themen hinweg logisch bleibt,
- ob kleine Objekte sinnvoll in Containern oder fokussierten Zonen liegen,
- ob Tap-Auswahl, Audio + Tap, Matching, Sortieren und Mini-Sequenzen je nach
  Flow unterschiedlich gut passen,
- ob Tali/Vori in verschiedenen Themen sanft motivieren kann,
- ob die Nutzeransicht ruhig bleibt und nicht zur Objektliste wird,
- ob weitere UX-/Mobile-Pruefungen noetig sind.

## 2. Nicht-Ziele

M11 entscheidet nicht:

- keine finale Container-Systemarchitektur,
- keine finale Challenge-Architektur,
- keine finale Companion-UX,
- keine finale Nutzeroberflaeche,
- keine Spielassets,
- keine Asset-Prompts,
- keine PNGs im Asset-Ordner,
- keine Flutter-/Dart-Implementierung,
- keine App-Integration,
- kein `frame_started`,
- keine Bauzustaende.

## 3. Pflicht-Flow A: Schule -> Federmappe -> Stifte

| Feld | Entscheidung |
| --- | --- |
| Thema | Schule / Lernen |
| Depth-Pfad | `ThemeIsland/School -> Classroom/Desk -> Federmappe -> Schreibzeug` |
| Container | Federmappe |
| Objekte | Bleistift, Radiergummi, Lineal, Anspitzer |
| Primaere Challenge | Tap-Auswahl: `Finde den Bleistift` |
| Weitere Challenge | Matching: `pencil -> Bleistift` |
| Spaetere Challenge | Sortieren: Schreibzeug in die Federmappe legen |
| Tali/Vori-Moment | Curiosity Cue beim Rascheln der Federmappe, sanfter Hinweis bei Fehler |

Bewertung:

- Der Container ist intuitiv und stark alltagsnah.
- Kleine Objekte gehoeren logisch in die Federmappe und ueberladen die
  Hauptansicht nicht.
- Tap-Auswahl ist sehr gut fuer den Einstieg.
- Matching eignet sich gut fuer Wort-Objekt-Paare.
- Sortieren ist spaeter sinnvoll, weil der Container eine klare Innenlogik hat.

Offene Frage:

- Wie viele kleine Schulobjekte duerfen sichtbar sein, bevor die Mobile-Ansicht
  zu dicht wirkt?

## 4. Pflicht-Flow B: Hafen -> Bootskajute -> Kompass/Karte/Seil

| Feld | Entscheidung |
| --- | --- |
| Thema | Meer / Reisen / Navigation |
| Depth-Pfad | `CoastIsland -> Harbor/Dock -> BoatCabin -> NavigationKit` |
| Container | Bootskajute oder Navigationskiste |
| Objekte | Kompass, Karte, Seil |
| Primaere Challenge | Tap-Auswahl: `Finde den Kompass` |
| Weitere Challenge | Audio + Tap: `compass` hoeren und Kompass antippen |
| Spaetere Challenge | Mini-Sequenz: Karte pruefen -> Kompass nehmen -> Kurs waehlen |
| Tali/Vori-Moment | Neugier auf die Kajute, Erfolg als kleiner Reise-/Abenteuerimpuls |

Bewertung:

- Der Flow ist thematisch stark, weil Hafen und Boot natuerlich in eine
  Themeninsel passen.
- Kleine Objekte haben Abenteuer- und Reisebezug.
- Tap-Auswahl und Audio + Tap funktionieren gut.
- Mini-Sequenzen sind hier besonders attraktiv, aber eher advanced.
- Die Kajute darf nicht zur komplexen Inventaransicht werden.

Offene Frage:

- Muss der erste Hafen-Flow eine einfache Navigationskiste statt voller Kajute
  nutzen, damit der Einstieg mobil lesbar bleibt?

## 5. Pflicht-Flow C: Garten -> Beet -> Samen/Giesskanne/Pflanze

| Feld | Entscheidung |
| --- | --- |
| Thema | Garten / Natur / Wachstum |
| Depth-Pfad | `Starter/FarmIsland -> GardenPlot -> Beet/Pflanzkiste -> Pflanzenobjekte` |
| Container | Beet oder Pflanzkiste |
| Objekte | Samen, Giesskanne, Pflanze |
| Primaere Challenge | Tap-Auswahl: `Finde die Giesskanne` |
| Weitere Challenge | Sortieren: Samen ins Beet, Werkzeug daneben |
| Spaetere Challenge | Mini-Sequenz: Samen setzen -> giessen -> Pflanze waechst |
| Tali/Vori-Moment | Sanfter Wachstumsimpuls und Freude ueber sichtbaren Fortschritt |

Bewertung:

- Der Flow ist besonders stark fuer Progression, weil Lernen und sichtbares
  Wachstum natuerlich zusammenpassen.
- Das Beet ist kein klassischer Container, aber eine fokussierte Zone mit
  innerer Logik.
- Tap-Auswahl funktioniert.
- Sortieren und Mini-Sequenzen passen sehr gut, sollten aber nicht sofort
  erzwungen werden.
- Tali/Vori kann hier besonders gut freiwillige naechste Ziele vorschlagen.

Offene Frage:

- Wie wird Wachstum ueber Zeit motivierend, ohne manipulative Timer oder
  Druckmechaniken zu erzeugen?

## 6. Vergleichskriterien

Jeder Flow wird nach diesen Kriterien bewertet:

| Kriterium | Bedeutung |
| --- | --- |
| Thema passt | Der Flow gehoert natuerlich in die Themeninsel oder Zone. |
| Container logisch | Der Container oder die fokussierte Zone erklaert, warum Objekte dort liegen. |
| Kleine Objekte fokussiert | Kleine Woerter ueberladen nicht die Island View. |
| Tap-Auswahl | `Wort sehen/hoeren -> Objekt antippen` funktioniert klar. |
| Audio + Tap | Hoerverstaendnis kann ergaenzt werden, mit Silent-/Accessibility-Fallback. |
| Matching/Sortieren | Zuordnen oder Sortieren passt zur Objektgruppe. |
| Mini-Sequenz | Reihenfolge/Handlung kann spaeter sinnvoll werden. |
| Companion-Moment | Tali/Vori kann motivieren, ohne Druck zu erzeugen. |
| Ueberladung | Risiko, dass zu viele Objekte oder Labels sichtbar werden. |
| Langweile/Technik | Risiko, dass der Flow zu schematisch oder technisch wirkt. |
| Mobile | Bedienung und Lesbarkeit bleiben auf kleinen Screens plausibel. |
| Offene Frage | Wichtigster naechster Klaerungspunkt. |

## 7. Vergleichsmatrix

| Flow | Thema | Container | Tap | Audio + Tap | Matching | Sortieren | Mini-Sequenz | Tali/Vori | Risiko |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Schule/Federmappe | gut | gut | gut | mittel | gut | gut | mittel | gut | viele kleine Objekte |
| Hafen/Bootskajute | gut | mittel | gut | gut | mittel | mittel | gut | gut | Kajute kann zu komplex werden |
| Garten/Beet | gut | mittel | gut | mittel | mittel | gut | gut | gut | Wachstum/Timer fair halten |

Legende:

- `gut`: direkt fuer fruehe Planung geeignet,
- `mittel`: plausibel, aber weitere UX-/Mobile-Pruefung noetig,
- `riskant`: nicht als erster Schritt erzwingen.

## 8. Challenge-Fit Nach Flow

| Challenge-Art | Schule/Federmappe | Hafen/Bootskajute | Garten/Beet | M11-Einschaetzung |
| --- | --- | --- | --- | --- |
| Tap-Auswahl | sehr gut | sehr gut | sehr gut | bester gemeinsamer MVP-Kandidat |
| Audio + Tap | gut | sehr gut | gut | fruehe zweite Stufe mit Fallback |
| Matching | sehr gut | mittel | mittel | gut fuer Wort-Objekt-Paare |
| Sortieren | sehr gut | mittel | gut | stark fuer Container, aber nicht als erster Zwang |
| Mini-Sequenz | mittel | sehr gut | sehr gut | spaeter fuer Aktionen und Progression |

## 9. Companion-Momente Nach Flow

| Moment | Schule/Federmappe | Hafen/Bootskajute | Garten/Beet |
| --- | --- | --- | --- |
| Curiosity Cue | Federmappe raschelt | Licht in der Kajute | Beet funkelt leicht |
| Sanfter Hinweis | `Schau auf die Spitze.` | `Der Kompass zeigt die Richtung.` | `Womit giesst man?` |
| Erfolg | `Gut gefunden!` | `Jetzt kennen wir den Kurs.` | `Das hilft der Pflanze.` |
| Fehlerhilfe | `Fast. Das ist das Lineal.` | `Fast. Die Karte ist flach.` | `Fast. Samen sind kleiner.` |
| Optionales Ziel | `Noch den Radiergummi?` | `Als naechstes die Karte?` | `Moechtest du giessen?` |

Regel:

Tali/Vori bleibt kurz, freundlich und optional. Der Companion loest die
Challenge nicht und erzeugt keinen Druck.

## 10. Visualisierungen

M11 erzeugt Dokumentations-/Preview-Dateien unter:

`docs/world_design/previews/phase2g_m11_multi_example_container_flows/`

Dateien:

- `01_multi_flow_overview.png`
- `02_flow_comparison_matrix.png`
- `03_challenge_fit_by_flow.png`
- `04_companion_moments_by_flow.png`
- `README.md`

Diese Dateien sind:

- Dokumentationsmaterial,
- keine Spielassets,
- keine finale UI,
- keine App-Integration,
- keine Codefreigabe,
- keine allgemeine Container-Systemfreigabe.

## 11. Prueffazit

Die M11-Planung spricht dafuer, dass die Grundlogik ueber mehrere Themen
tragfaehig ist:

- Schule/Federmappe zeigt einen sehr klaren Alltagscontainer fuer kleine
  Objektwoerter.
- Garten/Beet zeigt, dass eine fokussierte Zone auch ohne klassischen
  Behaelter als Container-Logik funktionieren kann.
- Hafen/Bootskajute zeigt, dass thematische Inseln und spaetere
  Mini-Sequenzen reizvoll sind, aber mehr UX-/Mobile-Komplexitaet haben.

M11 bestaetigt nicht, dass alle Container gleich funktionieren. Der naechste
Review muss pruefen, ob die Previews lesbar sind und ob weitere Flows oder
eine Mobile-spezifische Pruefung noetig sind.

## 12. Empfehlung Fuer Den Naechsten Schritt

Empfehlung:

```text
M11 als Multi-Flow-Pruefung visuell reviewen.
```

Wenn der Review positiv ist:

- Tap-Auswahl bleibt der staerkste gemeinsame MVP-Kandidat.
- Audio + Tap bleibt die fruehe zweite Stufe mit Silent-/Accessibility-
  Fallback.
- Matching und Sortieren bleiben spaetere Varianten je nach Container.
- Mini-Sequenzen bleiben fuer Aktionen und Progression reserviert.
- Das allgemeine Container-System darf weiterhin nur geplant, nicht
  implementiert werden.

Wenn der Review negativ ist:

- Flow-Dichte reduzieren,
- Mobile-Lesbarkeit separat pruefen,
- weitere einfache Themenflows planen,
- oder Container- und fokussierte-Zonen-Logik trennen.

## 13. Weiterhin Blockiert

Weiterhin blockiert bleiben:

- Flutter-/Dart-Code,
- App-Integration,
- Tests,
- Spielassets,
- PNGs im Asset-Ordner,
- finale UI,
- finales Inselbild,
- `frame_started`,
- neue Bauzustaende,
- allgemeine Container-Systemarchitektur,
- produktive Challenge-Implementierung,
- Companion-Implementierung,
- Voice-/Audio-/Animation-/Rive-Freigabe,
- Persistenz,
- Supabase,
- SRS-/`word_progress`,
- Reward Bridge.

## 14. Stop-Regeln

Stoppen, wenn:

- aus nur einem Flow eine allgemeine Container-Systemarchitektur abgeleitet
  werden soll,
- eine finale Container-Systemarchitektur ohne M11-Review bestaetigt werden
  soll,
- ein Flow implementiert werden soll, bevor UX- und Mobile-Pruefung erfolgt
  sind,
- Mini-Sequenzen implementiert werden sollen, bevor Aktionen und Reihenfolgen
  separat geprueft sind,
- aus M11 eine App-, Code- oder Assetfreigabe abgeleitet wird,
- eine Preview committed werden soll, obwohl wichtige Texte aus Karten,
  Rahmen oder Panels herauslaufen.

