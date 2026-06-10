# M16-BW: Professional Island Build Flow Design Gate

Stand: 2026-06-10

Status: `Docs-/Design-/UX-Gate-Slice / keine Implementierung`

## 1. Zweck

M16-BW stoppt die direkte Code-Flickerei am lokalen M16-BT-Rejoin-Proof und
setzt eine professionelle Designphase vor den naechsten Flutter-Slice.

Ausgangslage:

- M16-BT wurde gestoppt.
- Der WIP-Stand wurde als `wip m16-bt rejoin preview iterations` gestashed.
- Die Iterationen haben wichtige Fragen sichtbar gemacht, aber zu viel direkt
  im Code beantwortet.

Warum M16-BT gestoppt wurde:

- zu viel Code-Patching,
- zu wenig vorherige Flow-, Layout- und UX-Klaerung,
- fehlendes freigegebenes Interaktionsmodell,
- unklare Grenze zwischen Insel, Slot, BuildChoice und Bauplatz,
- Gefahr, dieselben Fehler in jedem Preview-Fix erneut zu machen.

M16-BW gibt keinen Code, keine App-Integration, keine Route, keine Navigation,
keine Persistenz, keine Assets, keine Tests, keine Figma-/Notion-/Linear-/
GitHub-Writes, keinen BuildState und keine Produktivmechanik frei.

## 2. Professioneller Arbeitsprozess

Komplexe Talvori-World-, UI- und BuildChoice-Flows duerfen nicht mehr direkt
im Flutter-Code gesucht werden. Der neue Prozess lautet:

```text
Research / Benchmark pruefen
-> Flow schriftlich festlegen
-> Low-Fidelity Wireflow
-> visuelle Preview als PNG/SVG oder Figma-Konzept
-> Interaktionsregeln festlegen
-> Visual-QA
-> erst danach Code
```

Pflichtregeln:

- Erst klaeren, welcher Spielmoment entsteht.
- Erst klaeren, welches Interaktionsmuster passt.
- Erst klaeren, wie Kamera, Slots, BuildChoice und HUD zusammenspielen.
- Erst klaeren, welche Texte sichtbar sind.
- Erst klaeren, welche Dateien ein spaeterer Code-Slice beruehren darf.
- Code startet erst, wenn der Flow visuell pruefbar und akzeptiert ist.

## 3. Welche Tools Sinnvoll Sind

| Tool | Sinnvoll fuer | Grenze |
| --- | --- | --- |
| Figma | editierbare UI-/Flow-Layouts, Variantenvergleich, spaetere Design-Freigabe. | Keine Figma-Writes ohne ausdrueckliche Freigabe. |
| Game Studio | Game-Feel-, Mechanik- und Playfield-Review, ob der Flow wie Spiel statt Formular wirkt. | Nur Review/Planung; keine Assets oder Projektwrites ohne Freigabe. |
| Browser / Screenshot | lokale Preview- und Visual-QA, wenn spaeter wieder Code existiert. | Keine Screenshots als Repo-Artefakte ohne eigenen Visual-Scope. |
| Notion / Linear | Management-Spiegel, Aufgaben, Reviews, offene Fragen. | Keine Produktwahrheit und keine Writes ohne Freigabe. |
| Repo | Source of Truth fuer Gates, Game Bible, M16-Dokumente, Code und Commits. | Repo-Dokumente ersetzen nicht visuelle QA; sie definieren die Regeln. |

Fuer den naechsten Schritt ist ein repo-nativer Low-Fidelity-Wireflow am
sinnvollsten. Figma kann danach folgen, wenn ein editierbares Designfile
ausdruecklich freigegeben wird.

## 4. Ziel-Flow

Der professionelle Ziel-Flow fuer den Talvori-Inselbau lautet:

```text
Insel auswaehlen
-> Insel betreten
-> Inselkarte mit Pan/Pinch-Zoom bewegen
-> neutralen Slot frei waehlen
-> BuildChoice direkt am Slot waehlen
-> Gebaeude- oder Objektidee erscheint im Spielfeld
-> Grundstueck wird fokussiert
-> Bauphase startet
-> spaeter tiefere Ebenen: Gebaeude, Raum, Moebel, Container
```

Dieser Flow ist ein Designziel. Er erzeugt keine Route, Navigation, Persistenz
oder Produktmechanik.

## 5. Insel-Auswahl

Im MVP ist nur eine aktive Starterinsel moeglich. Weitere Inseln duerfen als
ruhige Teaser sichtbar sein.

Regeln:

- Die aktive Insel ist der Uferhain bzw. sichtbar spielnah als
  `Lichtung am Ufer`.
- Weitere Inseln wie Bergpfad, Hafen, Waldinsel oder Wissensinsel sind
  spaetere Teaser.
- Die Auswahl muss sich trotzdem wie ein echter Spielmodus anfuehlen.
- Keine Listen- oder Formularauswahl.
- Die Insel erscheint als grosses zentrales Objekt oder Showcase.
- Teaser duerfen Neugier erzeugen, aber keine FOMO-, Timer-, Kauf- oder
  Unlock-Drucksprache nutzen.

## 6. Inselgroesse und Slot-Kapazitaet

Designentscheidung fuer die Starter-Insel:

- sichtbar im ersten MVP: ca. 12 Slots,
- davon 6 sofort nutzbar,
- 6 sichtbar spaeter,
- langfristige Erweiterungsreserve: ca. 16 bis 20 Slots,
- Slots bleiben neutral,
- Terrain beeinflusst spaeter Varianten, blockiert aber keine Kategorie hart.

Die Insel soll groesser wirken als ein einzelner Screen, aber nicht wie eine
unendliche Map-Engine. Mobile-Dichte bleibt hart: Slotlabels, Ghosts und HUD
duerfen den Spielraum nicht ueberladen.

## 7. Slot-Freiheit

Jeder freie Slot kann grundsaetzlich Haus, Garten, Werkstatt, Garage, Markt,
Lager, Wissen, Archiv oder spaetere Kategorien tragen.

Verbindlich:

- Slot ist Lage, nicht Kategorie.
- Slot != Hausplatz.
- Slot != Marktplatz.
- Nutzer entscheidet, wo sein Haus entsteht.
- Kreative Freiheit kommt vor Systemvorschlag.
- Terrain darf Varianten vorschlagen, aber nicht hart bevormunden.

Beispiele:

- Nordlichtung + Haus ist erlaubt.
- Uferplatz + Haus ist erlaubt.
- Hainrand + Werkstatt ist erlaubt.
- Suedhuegel + Garten ist erlaubt.

Alle Beispiele bleiben Preview-/Designlogik, keine BuildState-Freigabe.

## 8. BuildChoice-Auswahl als Spielmoment

BuildChoice darf nicht als normales App-Menue erscheinen.

Nicht geeignet fuer den ersten Code-Proof:

- Bottom-Sheet als Hauptentscheidung,
- Formular,
- technische Wolke,
- lange Liste,
- acht gleich dominante Ghosts mit Label-Ueberlappung.

Moegliche Patterns:

| Pattern | Staerken | Risiken |
| --- | --- | --- |
| In-World radial wheel | direkt am Slot, schnell, spielnah. | Nur fuer wenige klare Optionen geeignet. |
| Kleine Werkbank / Blueprint-Station am Slot | wirkt wie Spielstation und kann Auswahl beruhigen. | Kann zu Crafting-/Blueprint-Scope verleiten. |
| Showcase-Fokus am Slot mit 3-5 sichtbaren Karten | gute visuelle Entscheidung, klare Hierarchie. | Kann wie UI-Seite wirken, wenn Umgebung verschwindet. |
| Companion/Worker schlaegt Optionen im Weltbild vor | lebendiger, weniger technisch. | Darf nicht zu Textdialog oder Pflichtberatung werden. |

Entscheidung fuer den ersten Folge-Proof:

```text
M16-BX soll zuerst ein Low-Fidelity-Wireflow fuer ein fokussiertes
In-World-Build-Wheel mit optionaler kleiner Werkbank-/Worker-Andeutung
erstellen.
```

Begruendung:

- Die Wahl bleibt am Slot.
- Der Spieler sieht: Ich baue hier.
- Das Pattern ist klein genug fuer MVP.
- Visuelle Hierarchie kann vor Code geprueft werden.
- Wenn das Wheel mit 4 bis 5 Optionen nicht funktioniert, kann das Wireflow
  sauber zu Werkbank oder Showcase wechseln, bevor Flutter-Code entsteht.

## 9. Kamera / Zoom / Pan

Mobile-Standard:

- ein Finger verschiebt die Inselkarte,
- zwei Finger zoomen rein und raus,
- keine sichtbaren Pfeil- oder Zoom-Buttons,
- Slot-Tap bringt den Slot in guten Fokus,
- BuildChoice bleibt erreichbar,
- Toolbelt und Bubbles ueberdecken das Wheel nicht.

Fuer jetzt ist das eine Designentscheidung, keine produktive Kamera-Engine.
Spaeter kann eine eigene Kamera-/Map-Engine entstehen, aber nur mit eigenem
Gate fuer Gesten, Clamping, Accessibility, Performance und App-Integration.

## 10. Tiefenmodell

Talvori soll spaeter immer tiefer in die eigene Welt zoomen koennen:

```text
Insel
-> Grundstueck
-> Gebaeude
-> Raum
-> Moebel
-> Container
-> Detailobjekt
```

Designregeln:

- Jede Ebene bleibt als Weltort lesbar.
- Tiefer zoomen ist kein Formularwechsel.
- Herauszoomen muss spaeter ebenso natuerlich sein wie Hineinzoomen.
- Container und Detailobjekte verhindern TinyObject-Clutter auf der Insel.
- Keine Ebene erzeugt ohne eigenes Gate Persistenz, BuildState oder Assets.

## 11. Sprache / Copy

Spieler sehen einfache, natuerliche Sprache. Interne Begriffe bleiben intern.

Nicht im Spiel verwenden:

- BuildChoice,
- Blueprint,
- Candidate,
- Fokus,
- Phase,
- Transform,
- Pan,
- Zoom,
- Menu.

Geeignete Copy:

- `Such dir eine Insel aus.`
- `Such dir einen Ort aus.`
- `Was moechtest du hier bauen?`
- `Ein Haus passt hierher.`
- `Garten spaeter.`
- `Werkstatt spaeter.`
- `Garage spaeter.`
- `Mehr spaeter.`
- `Der Boden ist noch locker.`
- `Jetzt haelt der Boden.`

Text bleibt kurz. Der Ort, das Objekt, die Kamera und die Weltveraenderung
tragen den Spielmoment.

## 12. Was M16-BT Falsch Gemacht Hat

Sachliche Fehleranalyse:

- zuerst zu linear: Lichtung -> Haus -> Bauplatz,
- zu wenig echte Slot-Freiheit,
- zu wenige Slots fuer die Starter-Insel-Kapazitaet,
- Bottom-Panel statt Spielmoment am Ort,
- spaeter zu viele Ghosts und Label-Wolke,
- sekundaere Ghost-Reihe wirkte wie Menueleiste im Spielfeld,
- Pan/Zoom zuerst mit Dev-Buttons statt nativen Gesten,
- Code wurde ohne fertiges Interaktionsmodell zu oft gepatcht,
- jeder Fix loeste ein sichtbares Problem, aber das Gesamtdesign blieb
  ungenehmigt.

M16-BT war deshalb als Lernbeweis nuetzlich, aber nicht commitfaehig als
naechster Produktpfad.

## 13. Neuer Folgepfad

Empfohlener naechster Slice:

> M16-BX Low-Fidelity Island Build Flow Wireflow

Slice-Typ:

```text
Visual-/Design-Gate, kein Flutter-Code.
```

Ziel:

Ein repo-nativer Low-Fidelity-Wireflow definiert die wichtigsten Screens und
Zustaende:

- Insel-Auswahl,
- Insel betreten,
- Karte bewegen/zoomen,
- Slot waehlen,
- BuildChoice am Slot,
- Grundstueckszoom,
- Bauplatzstart,
- spaeteres Tiefenmodell.

Warum nicht sofort Figma?

- Figma ist sinnvoll, aber ein externer Write.
- Das Repo bleibt Source of Truth.
- Ein erstes SVG/PNG-/Markdown-Wireflow im Repo reicht, um Flow und Layout vor
  Code zu pruefen.
- Figma kann danach mit ausdruecklicher Freigabe als editierbare Version
  entstehen.

Warum nicht sofort Code?

- M16-BT hat gezeigt, dass Code ohne freigegebenen Wireflow zu endlosen
  lokalen Korrekturen fuehrt.
- Der naechste Code-Slice braucht ein visuell akzeptiertes Pattern.

## 14. Akzeptanzkriterien Fuer Spaeteren Code

Ein neuer Flutter-Code-Slice fuer diesen Flow darf erst starten, wenn:

- der Flow visuell klar ist,
- Slotanzahl und Slotgruppen feststehen,
- das BuildChoice-Pattern feststeht,
- Kamera-/Gestenmodell feststeht,
- Copy/Texte feststehen,
- Visual-QA-Kriterien stehen,
- erlaubte Dateien feststehen,
- BQ oder andere Proofs als Muster/Kopie/Import/Referenz klar benannt sind,
- keine App-Integration geoeffnet wird,
- keine Route oder Navigation geoeffnet wird,
- keine Persistenz, kein BuildState und keine Assets geoeffnet werden.

## 15. M16-T-IDs

Dieses Gate erledigt folgende neue Design-IDs:

| ID | Status | Entscheidung |
| --- | --- | --- |
| M16T-DESIGN-001 | [x] | Professional design-before-code rule. |
| M16T-DESIGN-002 | [x] | Island build flow wireflow required before code. |
| M16T-DESIGN-003 | [x] | BuildChoice interaction pattern must be visually approved. |
| M16T-DESIGN-004 | [x] | Pan/zoom/slot focus design gate. |

## 16. Stop-Regeln

M16-BW erlaubt nicht:

- keine Flutter-/Dart-Dateien,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- keine Supabase/local DB Writes,
- keine SRS-/`word_progress`-Aenderung,
- keine automatische Wortplatzierung,
- keine Assets,
- kein BuildState,
- keine Tests,
- keine Figma-Writes,
- keine Notion-Writes,
- keine Linear-Writes,
- keine GitHub-Writes,
- kein Plugin-Write,
- kein Commit.
