# Phase 2G-M10-B: Challenge Interaction Comparison

Stand: 2026-06-06

Status: `Research-, Planungs- und Visualisierungsblock gestartet`

Dieses Dokument vergleicht Challenge-Arten fuer den Depth-/Container-Flow.
Es klaert, welche Interaktionen fuer Talvori zuerst geeignet sind, bevor eine
Challenge-Art implementiert oder final entschieden wird.

M10-B ist kein Flutter-/Dart-Code, keine App-Integration, kein Testblock,
keine Spielasset-Produktion, kein finales Inselbild, kein `frame_started` und
keine Bauzustandsarbeit.

## 1. Ziel

M9/M9-B haben gezeigt, dass der Flow

```text
Haus/Kueche -> Schublade -> Besteck
```

als erster Depth-/Container-Beispiel-Flow verstaendlich ist. M10/M10-D haben
diesen Flow emotionaler und spielnaeher gemacht. Offen bleibt aber, welche
Art von Mini-Challenge fuer den ersten Prototype am besten passt.

M10-B vergleicht deshalb:

1. Tap-Auswahl,
2. Drag-and-drop-Zuordnung,
3. Audio-Erkennung / Hoerverstaendnis,
4. Sortieren,
5. Matching / Paarbildung,
6. Mini-Sequenz / Reihenfolge,
7. Kombinationen.

## 2. Fuehrende Grundlagen

- `docs/world_design/255-world-depth-gameplay-retention-research.md`
- `docs/world_design/257-depth-container-user-flow-visual-review.md`
- `docs/world_design/258-emotional-product-flow-preview-plan.md`
- `docs/world_design/259-emotional-product-flow-visual-review.md`
- `docs/world_design/235-world-production-roadmap-and-checklists.md`
- `assets/images/world/buildable_islands/forest_clearing/template.md`

## 3. Research-Orientierung

M10-B nutzt die bestehenden M8-/M9-/M10-D-Grundlagen:

- Erfolgreiche Mobile-Lern- und Puzzle-Loops funktionieren gut, wenn die
  erste Aufgabe kurz, eindeutig und schnell belohnend ist.
- Container-/Detailansichten sollen keine Objektlisten sein, sondern kleine
  Interaktionen mit Feedback und Reward tragen.
- Mobile-Interaktionen muessen mit wenig Zeit, kleinen Screens und
  unterschiedlicher Motorik funktionieren.
- Audio ist lernstark, braucht aber Silent-Mode- und Accessibility-Alternativen.
- Drag-and-drop und Sortieren koennen spielerischer sein, sind aber auf Mobile
  riskanter, wenn Zielbereiche klein sind.

Entscheidung fuer diesen Block:

```text
Erste Prototype-Challenge: Tap-Auswahl.
Zweite Stufe: Audio + Tap.
Spaeter: Matching / Sortieren.
Advanced: Mini-Sequenzen fuer Aktionen.
```

## 4. Bewertungskriterien

Jede Challenge-Art wird nach diesen Kriterien bewertet:

| Kriterium | Bedeutung |
| --- | --- |
| Verstaendlichkeit fuer neue Nutzer | Kann der Nutzer sofort erkennen, was zu tun ist? |
| Lernwert | Trainiert die Interaktion Wort, Objekt, Hoeren, Kontext oder Handlung sinnvoll? |
| Spass / Spielgefuehl | Fuehlt sich die Aufgabe spielerisch an, ohne Druck aufzubauen? |
| Geschwindigkeit fuer kurze Sessions | Passt die Aufgabe in sehr kurze Lernmomente? |
| Mobile-Bedienbarkeit | Funktioniert sie mit kleinen Touch-Zielen und einer Hand? |
| Barrierefreiheit | Gibt es Alternativen fuer Audio, Motorik, Lesen oder Sehen? |
| Schwierigkeit skalierbar | Kann die Aufgabe spaeter schwerer werden? |
| Entwicklungsaufwand | Wie teuer ist eine erste robuste Umsetzung? |
| Risiko von Frust | Wie schnell erzeugt sie Fehlbedienung oder Unklarheit? |
| Konkrete Objekte | Passt sie zu Objekten wie Loeffel, Gabel, Messer? |
| Aktionen | Passt sie zu Verben wie oeffnen, nehmen, fahren, gehen? |
| Abstrakte Begriffe | Passt sie zu Begriffen wie Meinung, Freiheit, Politik? |
| Container-Ansichten | Passt sie zu Schublade, Kiste, Federmappe, Werkzeugkasten? |
| Tali/Vori-Reaktion | Laesst sich klares Feedback durch Companion gut anschliessen? |
| MVP-Tauglichkeit | Eignet sie sich fuer einen ersten kontrollierten Prototype? |

Bewertungen:

- `gut`: stark geeignet,
- `mittel`: nutzbar, aber mit Bedingungen,
- `riskant`: erst spaeter oder nur fuer Sonderfaelle.

## 5. Challenge-Arten Im Vergleich

| Challenge-Art | Kurzbeschreibung | Staerken | Risiken | Erste Bewertung |
| --- | --- | --- | --- | --- |
| Tap-Auswahl | Nutzer sieht/hoert Wort und tippt korrektes Objekt an. | Schnell, klar, mobile-freundlich, guter MVP-Start. | Kann zu simpel werden, wenn nicht variiert. | `gut` |
| Drag-and-drop-Zuordnung | Nutzer zieht Wortkarte zum Objekt oder Objekt zum Wort. | Spielerischer, staerkeres Zuordnungsgefuehl. | Mobile-Zielgroessen, Motorik, Frust bei ungenauem Drop. | `mittel / riskant` |
| Audio + Tap | Nutzer hoert Wort/Satz und tippt passendes Objekt. | Hoerverstaendnis, kurzer Flow, sehr lernnah. | Silent Mode, Hoerbarriere, Aussprache-/Audioqualitaet. | `gut als zweite Stufe` |
| Sortieren | Nutzer sortiert passende/falsche Gegenstaende in Container. | Sehr passend fuer Container, spielerisch, skalierbar. | Mehr Regeln, laengere Aufgabe, mehr UI-Zustand. | `mittel / spaeter gut` |
| Matching / Paarbildung | Nutzer verbindet Wort und Objekt. | Klassischer Lernwert, gut fuer Wortpaare. | Kann trocken wirken; braucht gute Mobile-Umsetzung. | `mittel` |
| Mini-Sequenz | Nutzer bringt Handlungsschritte in Reihenfolge. | Stark fuer Aktionen und Kontext. | Fuer erste Objektwoerter zu komplex. | `spaeter / advanced` |
| Kombination | Beispiel: hoeren + tippen, zuordnen + sortieren. | Mehr Tiefe, gute Progression. | Kann im MVP zu viel sein. | `gut spaeter` |

## 6. Beispiel: Kueche / Schublade / Besteck

Konkreter Beispiel-Flow:

```text
Haus/Kueche -> Schublade -> Besteck
```

Beispielvarianten:

| Variante | Beispiel | Bewertung |
| --- | --- | --- |
| Tap-Auswahl | `Finde den Loeffel` -> Nutzer tippt Loeffel. | Sehr geeignet fuer ersten Prototype: klar, schnell, belohnend. |
| Drag-and-drop | `Ziehe spoon zu Loeffel` -> Wortkarte wird auf Objekt gezogen. | Lernstark, aber Mobile-Drop-Zonen muessen erst geprueft werden. |
| Audio + Tap | Audio: `spoon` -> Nutzer tippt Loeffel. | Sehr geeignet als zweite Stufe; braucht Silent-Mode-Alternative. |
| Sortieren | Nutzer sortiert Besteck in die Schublade und falsche Objekte heraus. | Sehr passend fuer Container, aber nicht als allererste Challenge erzwingen. |
| Matching | `fork` mit `Gabel` verbinden. | Gut fuer Wortpaare, spaeter als Variante. |

## 7. Eignung Nach Worttyp

| Worttyp | Beste erste Challenge | Spaetere Varianten |
| --- | --- | --- |
| Konkretes Objekt | Tap-Auswahl | Audio + Tap, Matching, Sortieren |
| Kleines Container-Objekt | Tap-Auswahl | Sortieren, Matching |
| Bauteilwort | Tap auf Bauteilslot | Matching, Kontextfrage |
| Aktionswort | Mini-Sequenz | Audio + Sequenz, kleine Animation |
| Raum-/Ort-Wort | Plot/Room-Auswahl | Matching mit Szene |
| Eigenschaft/Adjektiv | Vergleichsauswahl | Sortieren nach Eigenschaft |
| Abstrakter Begriff | Codex/Dialog/Beispielsatz | Szene oder Kontext-Challenge |
| Mehrdeutiges Wort | Sense-Auswahl | Kontext-Matching |

## 8. Empfehlung

Empfohlene Progression fuer den ersten Prototype:

1. `MVP`: Tap-Auswahl.
2. `Early`: Audio + Tap.
3. `Later`: Matching / Zuordnung und Sortieren.
4. `Advanced`: Mini-Sequenzen fuer Aktionen.

Begruendung:

- Die erste Challenge muss schnell, klar und belohnend sein.
- Tap-Auswahl ist am einfachsten verstaendlich und am robustesten fuer Mobile.
- Audio + Tap erhoeht den Lernwert, braucht aber Accessibility- und
  Silent-Mode-Alternativen.
- Drag-and-drop kann sich gut anfuehlen, muss aber Mobile-Bedienbarkeit erst
  beweisen.
- Sortieren passt sehr gut zu Containern, ist aber komplexer als der erste
  Erfolgsmoment.
- Mini-Sequenzen sind stark fuer Aktionen, aber fuer den ersten
  Besteck-Flow zu schwer.
- Nicht alle Challenge-Typen sollen gleichzeitig eingefuehrt werden. Talvori
  braucht Progression, Variation und Worttyp-spezifische Auswahl.

## 9. Preview-Dateien

M10-B erzeugt Dokumentations-/Preview-Dateien unter:

```text
docs/world_design/previews/phase2g_m10b_challenge_interaction_comparison/
```

Dateien:

| Datei | Zweck |
| --- | --- |
| `01_challenge_type_matrix.png` | Matrix der Challenge-Arten gegen zentrale Kriterien. |
| `02_kitchen_challenge_variants.png` | Varianten am Beispiel Loeffel/Gabel/Messer. |
| `03_recommended_challenge_progression.png` | Empfohlene Progression von MVP bis Advanced. |
| `README.md` | Zweck, Dateien, Prueffazit, Grenzen und Blocker. |

Diese Dateien sind Dokumentationsmaterial und keine Spielassets.

## 10. Was M10-B Nicht Entscheidet

M10-B entscheidet nicht:

- finale Challenge-Implementierung,
- finale UI,
- finale Kunst,
- Sound-/FX-Design,
- echte Audio-Implementierung,
- Companion-System,
- allgemeines Container-System fuer alle Themen,
- App-Integration,
- Asset-Freigabe,
- `frame_started`.

## 11. Stop-Regeln

Stoppen, wenn:

- aus M10-B Challenge-Implementierung abgeleitet wird,
- eine Challenge-Art final gewaehlt wird, bevor M10-B visuell geprueft wurde,
- Drag-and-drop ohne Mobile-Bedienbarkeitspruefung entschieden wird,
- Audio-Challenges ohne Accessibility-/Silent-Mode-Alternative entschieden
  werden,
- eine allgemeine Challenge-Systementscheidung ohne weitere Beispiel-Flows
  getroffen wird,
- aus M10-B App-, Code- oder Assetfreigabe abgeleitet wird.

## 12. Naechster Erlaubter Schritt

Nach M10-B ist erlaubt:

- M10-B visuell pruefen,
- Tap-Auswahl als erste Prototype-Empfehlung dokumentarisch bestaetigen oder
  nachbessern,
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
