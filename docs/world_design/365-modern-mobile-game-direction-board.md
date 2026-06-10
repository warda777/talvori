# M16-BY: Modern Mobile Game Direction Board

Stand: 2026-06-10

Status: `Research-/Design-/Visual-Gate-Slice / keine Implementierung`

## 1. Zweck

M16-BY definiert eine moderne Mobile-Game-Richtung fuer den Talvori-
Inselbau-Flow, bevor ein neuer Wireflow oder neuer Flutter-Code entsteht.

Ausgangslage:

- M16-BT wurde gestoppt und als `wip m16-bt rejoin preview iterations`
  gestashed.
- M16-BX wurde gestoppt und als
  `wip m16-bx low fidelity wireflow not accepted` gestashed.

Warum M16-BY noetig ist:

- M16-BT hat gezeigt, dass Code ohne klare Designrichtung zu Flickerei fuehrt.
- M16-BX hat gezeigt, dass Low-Fidelity allein nicht reicht.
- Talvori braucht vor dem naechsten Flow oder Code eine moderne Mobile-Game-
  Direction: visuelle Hierarchie, Game-DNA, Kamera-Gefuehl,
  BuildChoice-Pattern und klare Verwerfungen.

M16-BY gibt keinen Code, keine App-Integration, keine Route, keine Navigation,
keine Persistenz, keine Assets unter `assets/`, keine Tests, keine Figma-,
Notion-, Linear-, GitHub- oder Plugin-Writes, keinen BuildState und keine
Produktivmechanik frei.

M16-BY dokumentiert die moderne Game-Richtung anhand des neuen
Referenzboards:

- Die vom Prompt genannte Referenz `talvori_direction_reference_v1.png` liegt
  im Preview-Ordner aktuell als
  `talvori_direction_reference_v1.png.png`.
- Das starke Referenzbild ist Art-Direction-Reference, aber nur
  Dokumentationsmaterial: kein App-Screen, kein Spielasset, keine finale UI und
  keine Datei fuer `assets/`.
- Die uebernommene Richtung ist: cozy 2.5D island diorama, lebendige Insel,
  Build Station am Slot als Weltobjekt, Worker/Tali/Vori als emotionale
  Spielbegleitung, klare Avoid-Liste und Flow von Insel -> Slot -> Build
  Station -> Worker -> Tiefe.
- Das Bild wird nicht kopiert, nicht von Codex nachgezeichnet und nicht als
  direkter Build-Auftrag behandelt.
- Das konkrete `modern_mobile_game_direction_board_v2.*` war ein
  Zwischenversuch. Es ist nicht als finale visuelle Zielrichtung akzeptiert.

## 2. Designproblem

Die bisherigen Versuche waren fachlich nuetzlich, aber visuell noch nicht
stark genug.

Probleme:

- zu diagrammartig,
- zu wenig modernes Mobile-Game-Gefuehl,
- zu wenig visuelle Spannung,
- zu wenig klare Game-DNA,
- zu viel Arbeitsblatt-/Wireframe-Anmutung,
- BuildChoice entweder zu UI-lastig oder zu wolkig,
- Kamera und Tiefe noch zu sehr als Flow-Logik statt als Spielgefuehl.

Die naechste Richtung muss deshalb nicht nur korrekt sein. Sie muss wie die
Grundlage fuer ein hochwertiges Mobile Game wirken.

## 3. Referenz-/Pattern-Gruppen

M16-BY betrachtet Benchmarks auf Prinzipienebene. Talvori kopiert keine
Mechaniken.

### Aufbau-/Base-Games

Beispiele:

- Clash of Clans,
- The Tribez,
- Townsmen,
- Elvenar.

Prinzip:

Sichtbarer Ort, eigene Gestaltung, klare Flaechen, langfristige Erweiterung,
lebendige Bewohner oder Worker und sichtbarer Fortschritt erzeugen Ownership.

Talvori uebernimmt:

- Insel als eigener Ort,
- sichtbare Slots,
- Bauideen im Weltkontext,
- Worker macht Fortschritt lebendig,
- neue Moeglichkeit statt abstraktem Reward.

Talvori verwirft:

- Timer,
- Ressourcenstress,
- Pay-to-Win,
- War-/Clan-Druck,
- irreversible Upgrade-Pfade im MVP.

### Cozy / Decor / Meta-Games

Beispiele:

- Gardenscapes,
- Homescapes.

Prinzip:

Renovieren, Reparieren und Dekorieren wirken stark, wenn ein Ort emotional
lesbar ist und eine Figur oder Geschichte den naechsten Schritt motiviert.

Talvori uebernimmt:

- Ort vorher/nachher,
- ruhige emotionale Verbesserung,
- kleine neue Bauoption,
- Companion/Worker als freundliche Hilfe.

Talvori verwirft:

- To-do-Listen als Hauptgefuehl,
- Match-3-Pflicht als Fortschrittskosten,
- irrefuehrende Minigame-Lesart,
- Stars/Coins als sichtbaren Lernantrieb.

### Sandbox / Creation

Beispiele:

- Minecraft,
- Roblox.

Prinzip:

Kreative Freiheit und eigene Orte motivieren, wenn Spieler spuerbar sagen
koennen: Das ist mein Ort.

Talvori uebernimmt:

- kreative Slotfreiheit,
- sichtbare Tiefe,
- spaeteres Reinzoomen in Haus, Raum, Moebel und Container,
- eigene Welt als Ausdruck von Sprachkontext.

Talvori verwirft:

- endlose Sandbox im MVP,
- UGC-/Moderationsscope,
- 3D-/Assetflut,
- freie Terrainbearbeitung als Startziel.

### Collection / Map / Progression

Beispiele:

- Pokemon TCG Pocket,
- Genshin Impact,
- Wuthering Waves.

Prinzip:

Sammeln, Map-Neugier und Weltfokus erzeugen "was gibt es dort?" statt "welche
Liste muss ich abarbeiten?".

Talvori uebernimmt:

- Insel-/Region-Neugier,
- Archiv als Wiederfinden,
- neue Moeglichkeiten sichtbar machen,
- Weltkarte und Tiefe als Motivation.

Talvori verwirft:

- Gacha,
- Pack-Stamina,
- FOMO-Events,
- Rang-/Collection-Druck,
- Kampf- oder Open-World-Scope fuer den MVP.

### Puzzle / Flow

Beispiele:

- Candy Crush,
- Block Blast.

Prinzip:

Eine kleine Huerde muss sofort verstehbar sein; Feedback muss direkt aus dem
Feld kommen.

Talvori uebernimmt:

- sichtbares Bauplatzproblem,
- klares Einsetzen/Reparieren/Ordnen,
- ruhiges Retry,
- kurze Feedbackschleife.

Talvori verwirft:

- Moves-/Timer-Druck,
- Booster-Frust,
- Score als Hauptmotivation,
- abstraktes Puzzle ohne Weltanker.

### Runner / Session-Hook

Beispiel:

- Subway Surfers.

Prinzip:

Der Einstieg muss ohne lange Erklaerung lesbar sein. Der Nutzer versteht
sofort: Hier kann ich handeln.

Talvori uebernimmt:

- sofort sichtbarer naechster Schritt,
- klare Geste,
- kurze Session,
- schnelle Rueckmeldung.

Talvori verwirft:

- endlose Reflexspannung,
- Store-/Event-/Currency-Druck,
- Geschwindigkeit statt Bedeutung.

## 4. Pattern-Vergleich

| Pattern | Was daran funktioniert | Risiko fuer Talvori | Talvori-Uebertragung | Entscheidung |
| --- | --- | --- | --- | --- |
| Insel-/Welt-Showcase | Ein grosses zentrales Objekt erzeugt Besitz und Neugier. | Kann wie Carousel-Marketing wirken. | Aktive Starterinsel gross, spaetere Inseln als ruhige Teaser. | uebernehmen |
| Karte mit nativer Pan/Zoom-Steuerung | Mobile-Spieler erwarten direkte Kartenbewegung. | Kamera-/Map-Engine-Scope kann wachsen. | Designregel: ein Finger schiebt, zwei Finger zoomen; kein Dev-Control. | uebernehmen, Code spaeter gaten |
| Slot/Plot-Fokus | Spieler fuehlt: Ich waehle diesen Ort. | Zu schnell kann der Slot wieder als Formularzeile wirken. | Slot bleibt Weltort, Kamera bringt ihn in gute Sicht. | uebernehmen |
| In-World-Build-Wheel | Schnell, lokal, direkt am Slot. | Bei vielen Optionen wird es Label-Wolke. | Nur als fokussierter Teil einer Build Station, nicht allein. | angepasst uebernehmen |
| Werkbank-/Blueprint-Station | Wirkt wie Spielstation und kann Auswahl beruhigen. | Kann Crafting-/Rezept-/Materialscope oeffnen. | Als lokale Build Station am Slot, ohne Rezepte, Materialien oder Persistenz. | fuehrend |
| BuildChoice-Showcase am Slot | Gute Hierarchie fuer groessere visuelle Auswahl. | Kann wie neue UI-Seite oder Shop wirken. | Spaeter fuer High-Fidelity-Varianten pruefen, wenn Station nicht reicht. | Reserve |
| Worker/Character-assisted Action | Arbeit wird lebendig statt nur bestaetigt. | Worker darf kein Timer-/Builder-System werden. | Indirekter Auftrag, sichtbare Arbeitsbewegung, Welt veraendert sich. | uebernehmen |
| Companion-Tipp als sekundaere Hilfe | Tali/Vori kann den Moment freundlich rahmen. | Zu viel Text wird Tutorial oder Pflichtberatung. | Kurze Bubble nur nach sichtbarem Problem. | sekundaer |
| Bottom Sheet | Bekannt, schnell baubar, strukturiert. | Wirkt formularartig und verdeckt Spielraum. | Nur fuer Safe Details, nicht als Haupt-BuildChoice. | fuer Hauptmoment verwerfen |
| Vollbild-Menue | Viel Raum fuer Vergleich. | Bricht Island-First und Kamera-Gefuehl. | Nur spaeter fuer echte Sammlung/Codex, nicht fuer Slot-BuildChoice. | verwerfen |
| Reine Karten-/Listenwahl | Lesbar und einfach. | Schul-/Admin-Gefuehl, kein Weltmoment. | Nicht fuer den ersten Bauflow. | verwerfen |

## 5. Entscheidung: Talvori Game-DNA

Verbindliche Richtung:

```text
Cozy adventure construction world.
Island-first.
Object-first.
Character-assisted.
Context-based language learning.
No school feeling.
No worksheet feeling.
No menu-first gameplay.
```

Talvori soll sich anfuehlen wie:

- eine eigene kleine Insel,
- ein lebendiger Bauplatz,
- ein freundlicher Companion-/Worker-Moment,
- eine Welt, in der Sprache Bedeutung bekommt,
- ein Ort, der durch Handeln klarer, reicher und tiefer wird.

Talvori soll sich nicht anfuehlen wie:

- Lernformular,
- Dashboard,
- Wireframe-Arbeitsblatt,
- Shop-Menue,
- BuildState-Editor,
- Vokabelliste mit Deko.

Drei Richtungen bleiben bewusst eingeordnet:

| Richtung | Entscheidung | Uebernahme |
| --- | --- | --- |
| A) Cozy Island Diorama Builder | gewaehlt | Inhaltliche Hauptdirection: warmes 2.5D-Insel-Diorama, sichtbare Orte, Build Station, Worker/Companion und lebendige Welt. Die finale visuelle Qualitaet wird spaeter ueber Art Bible und Master References definiert. |
| B) Base Builder Tactical Map | nicht fuehrend | Nur Struktur, Lesbarkeit, Slot-Klarheit und langfristige Erweiterbarkeit uebernehmen. |
| C) Storybook Adventure Island | nicht fuehrend | Nur Waerme, Entdeckung, Charakterbindung und Atmosphaere uebernehmen. |

## 6. Empfohlener Hauptflow

Moderner Zielablauf:

```text
Weltkarte / Insel-Showcase
-> Insel betreten
-> Karte frei erkunden
-> Grundstueck im Feld waehlen
-> BuildChoice als Build Station am Slot
-> Worker/Tali/Vori macht Aktion lebendig
-> sichtbare Bauveraenderung
-> neuer Hook
-> spaeter Tiefe: Haus -> Raum -> Moebel -> Container
```

Regeln:

- Der Spielraum dominiert.
- UI ist HUD, Bubble, Station oder kurzer Safe Exit.
- Der Ort kommt vor dem Text.
- Die Bauidee gehoert sichtbar zum Slot.
- Worker-Arbeit veraendert die Welt.
- Der naechste Hook ist eine neue Moeglichkeit, keine Economy.

## 7. BuildChoice-Pattern Neu Bewerten

### A. Focused In-World Wheel

Staerken:

- direkt am Slot,
- schnell,
- wenig UI,
- gut fuer 3-4 kurze Optionen.

Schwaechen:

- kippt bei mehr Optionen schnell in Label-Wolke,
- wirkt ohne Rahmen technisch,
- kann das Spielgefuehl nicht allein tragen.

Entscheidung:

Nur als kleiner Auswahlring innerhalb einer staerkeren Build Station nutzen.

### B. Build Station / Werkbank Am Slot

Staerken:

- fuehlt sich wie Spielstation an,
- beruhigt die Auswahl,
- kann Haus gross zeigen und andere Ideen klein halten,
- verbindet Slot, Bauidee und Worker,
- vermeidet Bottom-Menue und Arbeitsblatt.

Risiko:

- darf keine echte Crafting-, Rezept-, Material- oder Economy-Mechanik
  vortaeuschen.

Entscheidung:

```text
Fuehrendes Pattern fuer den naechsten High-Fidelity-Flow.
```

M16-BY bestaetigt diese konzeptionelle Entscheidung:

- BuildChoice ist nicht mehr als isoliertes Wheel zu verstehen.
- Die Build Station am Slot ist das fuehrende Weltobjekt.
- Ein kleines Wheel oder wenige Karten duerfen nur Bestandteil dieser Station
  sein.
- Tali, Vori oder ein Worker machen die Station lebendig, zeigen Vorschlaege
  und verbinden Auswahl mit spaeterer Arbeit am Ort.

### C. Slot Showcase Mit Grossen Visuellen Karten

Staerken:

- starke visuelle Praesentation,
- gut fuer Varianten,
- laesst sich hochwertig inszenieren.

Risiko:

- kann schnell wie Shop, Fullscreen-Menue oder Kartenliste wirken.

Entscheidung:

Reserve fuer spaeteren High-Fidelity-Vergleich, nicht erstes Hauptpattern.

### D. Companion/Worker-Guided Suggestion

Staerken:

- lebendig,
- gut fuer Anfaenger,
- erklaert ohne Formular.

Risiko:

- kann Entscheidung zu stark lenken,
- kann Textlast erzeugen.

Entscheidung:

Sekundaere Hilfe. Tali/Vori oder Worker darf vorschlagen, aber der Spieler
waehlt.

## 8. Moderner Screen-Aufbau

| Zustand | Hauptobjekt | Spielerhandlung | UI-Anteil | Kamera/Bewegung | Emotion/Hook | Vermeiden |
| --- | --- | --- | --- | --- | --- | --- |
| Island Select | grosse Starterinsel | Insel antippen/betreten | kleine CTA, Teaser am Rand | Showcase, leichtes Float-Gefuehl | "Das ist mein erster Ort." | Liste, Formular, Kartenstapel |
| Entered Island | Uferhain-Karte | erkunden, schieben, zoomen | minimale Safe Actions | native Map-Gesten | "Hier kann ich bauen." | Dev-Pfeile, Zoom-Buttons |
| Slot Selected | freier Slot | Slot antippen | kurze Bubble | Slot kommt in gute Sicht | "Dieser Ort ist frei." | Slot = Kategorie |
| BuildChoice | Build Station am Slot | Haus/Idee in Station waehlen | Station als Weltobjekt | Karte bleibt im Kontext | "Ich baue genau hier." | Bottom Sheet, Label-Wolke |
| Build Preview | Hausidee am Slot | bestaetigen/naeher schauen | kleiner Hook | sanfter Push-in | "Ein Haus passt hierher." | sofortiger BuildState |
| Plot Focus | Bauplatz | Problem erkennen | Bubble erst nach sichtbarem Problem | Kamera naeher, Umgebung bleibt | "Der Boden ist locker." | neue App-Seite |
| Worker Buildsite | Worker + Ort | Auftrag geben | Werkzeug/Material klein | Worker bewegt sich im Ort | "Der Ort veraendert sich." | Button-Quiz |
| Depth Future | Haus/Raum/Moebel/Container | spaeter tiefer gehen | kleine Tiefen-Hints | Rein-/rauszoomen als Weltgefuehl | "Hier wird mehr moeglich." | Interior-Scope ohne Gate |

## 9. Copy-Regeln

Natuerliche Sprache:

```text
Such dir eine Insel aus.
Such dir einen Ort aus.
Was moechtest du hier bauen?
Ein Haus passt hierher.
Der Boden ist noch locker.
Jetzt haelt der Boden.
```

Verboten im sichtbaren Spiel:

- BuildChoice,
- Blueprint,
- Candidate,
- Fokus,
- Phase,
- Pan,
- Zoom,
- Menue,
- Richtung waehlen.

Interne Fachbegriffe duerfen in Docs und Code-IDs vorkommen. Der Spieler
sieht Ort, Handlung und kurze menschliche Sprache.

## 10. Visual Direction Board

Repo-native Visuals:

- [modern_mobile_game_direction_board.svg](previews/m16_by_modern_mobile_game_direction_board/modern_mobile_game_direction_board.svg)
- [modern_mobile_game_direction_board.png](previews/m16_by_modern_mobile_game_direction_board/modern_mobile_game_direction_board.png)
- [modern_mobile_game_direction_board_v2.svg](previews/m16_by_modern_mobile_game_direction_board/modern_mobile_game_direction_board_v2.svg)
- [modern_mobile_game_direction_board_v2.png](previews/m16_by_modern_mobile_game_direction_board/modern_mobile_game_direction_board_v2.png)

Referenz:

- [talvori_direction_reference_v1.png.png](previews/m16_by_modern_mobile_game_direction_board/talvori_direction_reference_v1.png.png)

Status:

- `modern_mobile_game_direction_board.*` ist das M16-BY-v1-Uebergangsboard.
  Es war fachlich nuetzlich, aber noch zu sehr Direction-Folie.
- `modern_mobile_game_direction_board_v2.*` ist ein nicht akzeptierter
  Zwischenstand. Es bleibt nur zur Nachvollziehbarkeit im Preview-Ordner und
  darf nicht als fuehrendes Board, visueller Zielzustand oder Pflichtreferenz
  fuer spaetere Slices gelesen werden.
- Die Referenzdatei bleibt Dokumentationsmaterial und wird nicht als Produkt-
  oder App-Asset behandelt.

Die inhaltliche M16-BY-Richtung verlangt weiterhin:

- grosse zentrale Insel als cozy 2.5D-Diorama,
- sichtbare Slots als echte Orte,
- Build Station am Slot als Weltobjekt,
- Haus als klare Hauptidee,
- Garten/Werkstatt/Garage als ruhige kleinere Optionen,
- weitere Moeglichkeiten nur als Kiste/Beutel/`spaeter`,
- Worker/Tali/Vori als sichtbare emotionale Spielbegleitung,
- Flow von Insel -> Slot -> Build Station -> Worker -> Tiefe,
- klare Avoid-Liste gegen Schulblatt, Bottom Sheet, Menue-first und
  Label-Wolke.

Es ist bewusst kein App-Screen, kein Screenshot und kein Asset. Es ist ein
Direction Board fuer den naechsten Designschritt.

Konzeptionelle Richtung:

- `Cozy Island Diorama Builder`,
- warm, lebendig und spielerisch,
- Island-first und object-first,
- BuildChoice als Weltmoment,
- Station/Worker/Companion statt UI-Panel,
- weniger Text als v1,
- keine acht gleichfoermigen Panels,
- keine Corporate-Folie,
- keine Schulblatt-Optik,
- keine finale App-Illustration.

Wichtig:

Die visuelle Zielqualitaet darf nicht aus dem schwachen v2-Board abgeleitet
werden. Sie muss ueber M16-BZ, eine Talvori Art Bible, Master Reference Sets
und spaetere Asset-/Export-Specs aufgebaut und geprueft werden.

## 11. Entscheidung Fuer Den Naechsten Slice

Bisher empfohlener naechster Slice vor dem Pipeline-Gate:

```text
M16-BZ High-Fidelity Island Build Flow Concept
```

Nachtrag M16-BZ:

Nach der neuen Erkenntnis zur Art-Produktion wurde M16-BZ bewusst als
`AI Art Production Pipeline and Style Consistency Gate` umgesetzt, bevor ein
High-Fidelity Island Build Flow entsteht. Das fruehere High-Fidelity-Ziel
bleibt sinnvoll, aber erst nach:

```text
M16-BZ AI Art Production Pipeline and Style Consistency Gate
-> M16-CA Talvori Art Bible v1
-> M16-CB Starter Island Master Reference Set
-> M16-CC Asset Family and Export Spec
```

Grund: Talvori braucht nicht nur eine moderne Game-Direction, sondern auch
kontrollierte Art-Produktion, Style-Konsistenz und Engine-ready
Exportregeln, bevor neue High-Fidelity-Screens oder Spielassets sinnvoll
bewertet werden koennen.

Typ des frueheren High-Fidelity-Ziels:

```text
Visual-/Design-Gate vor Code
```

Ziel des spaeteren High-Fidelity-Schritts:

Ein hochwertigerer, vertikaler Mobile-Flow als PNG/SVG oder Figma-ready
Konzept, der die konzeptionelle M16-BY-Richtung in konkrete Screens/States
uebersetzt:

- Island Select,
- Entered Island,
- Slot Selected,
- Build Station am Slot,
- Build Preview,
- Plot Focus,
- Worker Buildsite,
- Depth Future.

Warum nicht direkt Code:

- M16-BT und M16-BX haben gezeigt, dass ohne akzeptierte visuelle Richtung zu
  viel im Code gesucht wird.
- M16-BY entscheidet die Game-DNA und das BuildChoice-Pattern:
  Cozy Island Diorama Builder und Build Station am Slot.
- Das konkrete M16-BY-v2-Board ist nicht als visuelle Zielqualitaet
  akzeptiert.
- Ein spaeterer High-Fidelity-Slice soll diese Luecke erst nach Art Bible,
  Master References und Asset-Family-Spec schliessen.

Alternative bewusst zurueckgestellt:

- `Figma-ready Screen Concept`: sinnvoll, aber nur wenn Figma-Writes
  explizit freigegeben werden.
- `Alternative BuildChoice Pattern Comparison`: weniger sinnvoll als
  naechster Schritt, weil M16-BY die Build Station bereits als fuehrendes
  Pattern festlegt. Ein Vergleich kann als Abschnitt im High-Fidelity-Konzept
  enthalten sein.

## 12. Source Register

M16-BY nutzt interne Gates als Source of Truth und prueft Benchmark-Prinzipien
gegen externe offizielle Quellen, ohne Mechaniken zu kopieren.

| Quelle | Rolle |
| --- | --- |
| `340`, `341`, `344`, `346`, `358`, `359`, `360` | Interne Research- und Gameplay-Gates fuer Druckfreiheit, Spielmuster, Aufbau, Puzzle, Sammlung, Worker und Fun-/Hook-Regeln. |
| [Supercell: Clash of Clans](https://supercell.com/en/games/clashofclans/) | Offizielle Referenz fuer Village Customization, Clan-/Community-Kontext und Aufbau-Spielrahmen. |
| [HandyGames: Townsmen](https://handy-games.com/en/games/townsmen/) | Offizielle Referenz fuer Worker, Stadtbau, Jobs, Routinen und Aufbau-Tiefe als Prinzipienquelle. |
| [Pokemon TCG Pocket](https://tcgpocket.pokemon.com/en-us/) | Offizielle Referenz fuer Sammeln, Deck-Idee, immersive Karten und Collection-Risiken. |
| [Minecraft: What is Minecraft?](https://www.minecraft.net/en-us/about-minecraft) | Offizielle Referenz fuer eigene Welt, Erkunden, Ueberleben und Erschaffen als Sandbox-Prinzip. |

## 13. Konsequenz Fuer Folge-Code

Kein neuer komplexer Island-/Slot-/BuildChoice-/Kamera-Code darf allein auf
dem abgelehnten M16-BX-Low-Fidelity-Wireflow basieren.

Vor Code braucht Talvori:

- akzeptierte konzeptionelle Game-Direction aus M16-BY,
- Cozy Island Diorama Builder als konzeptionelle visuelle DNA,
- High-Fidelity-Flow-Konzept,
- klare Build Station am Slot als Weltobjekt,
- Kamera-/Gestenmodell,
- Visual-QA-Regeln,
- erlaubte Dateien,
- Stop-Regeln fuer BuildState, Persistenz, Assets, App-Integration und Routes.

## 14. Stop-Regeln

- keine Flutter-/Dart-Dateien,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- keine Supabase/local DB Writes,
- keine SRS-/`word_progress`-Aenderung,
- keine automatische Wortplatzierung,
- keine Assets unter `assets/`,
- kein BuildState,
- keine Tests,
- keine Figma-Writes,
- keine Notion-Writes,
- keine Linear-Writes,
- keine GitHub-Writes,
- kein Plugin-Write,
- kein Commit.
