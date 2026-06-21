# M16-CA: Talvori Art Bible v1

Stand: 2026-06-21

Status: `Docs-/Style-Gate-Slice / keine Implementierung`

Unity Platform Supersession 2026-06-21:

`442-talvori-unity-modular-district-platform-decision.md` und
`443-p02-vertical-slice-and-online-foundation-roadmap.md` fuehren die neue
Runtime-Richtung. Diese Art Bible bleibt als Stil- und QA-Grundlage gueltig,
wird aber fuer Unity Echtzeit-3D, feste isometrische Kamera, mobile
Lesbarkeit, Materialfamilien, Lichtfamilien und coherent environment kits
weitergedacht. Die alten 2.5D-Diorama-Regeln sind historische
Lesbarkeits-/Stilanker, nicht mehr die primaere technische Runtime-Vorgabe.

## 1. Zweck und Non-Goals

M16-CA definiert die erste verbindliche visuelle Sprache fuer Talvori Welt.
Die Art Bible ist das Style-System-Gate zwischen der modernen Game-Direction
aus M16-BY und der Produktionspipeline aus M16-BZ.

Ziel:

- Talvori soll als warmes, hochwertiges 2.5D-Cozy-Island-Diorama lesbar
  werden.
- Fuer neue Districts soll diese Lesbarkeit in eine warme, isometrische Unity
  3D-Welt mit konsistenten Materialien und Lichtfamilien uebersetzt werden.
- Insel, Slots, Build Station, Gebaeude, Figuren und HUD sollen zur selben
  visuellen Welt gehoeren.
- Kuenftige KI-Referenzen, Master-Referenzen und Asset-Familien sollen gegen
  klare Style-Regeln geprueft werden koennen.
- M16-CB und M16-CC sollen auf einer gemeinsamen Art Direction aufsetzen.

Non-Goals:

- keine Flutter-/Dart-Dateien,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- kein BuildState,
- keine Tests,
- keine Dateien unter `assets/`,
- keine finalen Assets,
- keine neuen High-Fidelity-Spielbilder,
- keine App-Screens,
- keine Figma-/Notion-/Linear-/GitHub-Writes,
- keine externen Writes,
- keine Produktivmechanik-Freigabe.

M16-CA ist eine Stil- und QA-Entscheidung. Es ist keine Asset-Freigabe und
keine Code-Freigabe.

## 2. Eingangsquellen und Abgrenzung

Fuehrende Quellen:

- `docs/world_design/talvori_game_bible.md`
- `docs/world_design/365-modern-mobile-game-direction-board.md`
- `docs/world_design/366-ai-art-production-pipeline-and-style-consistency-gate.md`
- `docs/world_design/351-starter-island-infrastructure-strategy-gate.md`
- `docs/world_design/353-starter-island-identity-biome-and-category-scope-gate.md`
- `docs/world_design/355-talvori-core-construction-learning-spine.md`
- `docs/world_design/357-game-like-island-selection-and-construction-camera-flow-gate.md`
- `docs/world_design/359-successful-game-pattern-translation-for-talvori-construction-play.md`
- `docs/world_design/360-character-assisted-world-action-rule.md`

M16-BY definiert die konzeptionelle Game-DNA:

```text
Cozy Island Diorama Builder
2.5D cozy island world
island-first
object-first
character-assisted
context-based language learning
Build Station am Slot
Worker / Tali / Vori beleben den Ort
kein Schulgefuehl
kein Worksheet
kein Menue-first Gameplay
```

M16-BZ definiert die Produktionspipeline:

```text
ChatGPT richtet aus.
Codex dokumentiert und prueft.
KI-Bildtools generieren kontrolliert mit Referenzen.
Design-/Pixeltools bereinigen, schneiden, layern und exportieren.
Ein spaeterer Artist kann optional finalisieren.
```

Das starke Talvori-Referenzbild aus M16-BY ist nur Art-Direction-Reference:

- Es ist Dokumentationsmaterial.
- Es ist kein App-Screen.
- Es ist kein finales Asset.
- Es gehoert nicht nach `assets/`.
- Es darf nicht von Codex nachgezeichnet oder vereinfacht nachgebaut werden.
- Es ist kein direkter Build-Auftrag.

`modern_mobile_game_direction_board_v2.*` ist rejected/transitional:

- Es bleibt als Entscheidungsverlauf nachvollziehbar.
- Es ist kein akzeptierter visueller Zielzustand.
- Es darf keine Zielqualitaet fuer M16-CB, M16-CC, High-Fidelity-Flows oder
  Flutter-Code setzen.
- Visuelle Qualitaet muss aus dieser Art Bible, spaeteren Master References
  und der kontrollierten KI-Art-Pipeline entstehen.

## 3. Talvori Visual North Star

Talvori soll sich anfuehlen wie:

```text
Ein freundliches 2.5D-Insel-Diorama, in dem Orte gebaut werden,
Figuren sichtbar helfen und Sprache aus konkreten Situationen waechst.
```

Die Welt ist zuerst ein Ort, nicht eine UI. Der Spieler soll zuerst sehen:

- eine Insel mit Charakter,
- freie Orte,
- sichtbare Bauideen,
- Figuren, die handeln,
- veraenderte Welt,
- neue Moeglichkeit.

Die UI erklaert nur, was die Welt schon zeigt. Sie darf nicht der Hauptort des
Spiels werden.

Talvori vermeidet:

- Schulbuch- oder Worksheet-Anmutung,
- Web-App-/Dashboard-Optik,
- Corporate-Slide-Optik,
- Menu-first Gameplay,
- zu realistische Rendergrafik,
- generisches Cozy ohne eigene Identitaet,
- zu kindliche Kleinkinder-App,
- malerische Gesamtbilder, die nicht layerbar sind.

## 4. Kamera und Perspektive

Fuehrende Perspektive:

- 2.5D-Diorama mit leicht erhoehter Kamera.
- Insel, Slots, Wege, Gebaeude und Figuren werden aus derselben Richtung
  gelesen.
- Kamera zeigt genug Oberseite, damit Grundstuecke, Wege und Bauphasen
  verstaendlich bleiben.
- Seitenflaechen duerfen sichtbar sein, aber nicht so stark, dass die Welt wie
  ein 3D-Render oder ein realistisches Modell kippt.

Kamera-Gefuehl:

- Insel-Showcase: grosse zentrale Insel, spaetere Inseln nur als Teaser.
- Inselkarte: direkt bewegbar und zoombar gedacht, aber M16-CA implementiert
  keine Kamera.
- Slot-Fokus: der gewaehlte Ort wird als Weltort hervorgehoben.
- Grundstueck: Kamera geht naeher an den Bauplatz, die Insel bleibt nur
  angedeutet.
- Tiefe spaeter: Insel -> Grundstueck -> Gebaeude -> Raum -> Moebel ->
  Container -> Detailobjekt.

Regeln:

- Keine flache Tabellen- oder Kartenansicht als Hauptwelt.
- Keine technische Draufsicht wie Editor, Debug-Map oder Level-Plan.
- Keine realistische 3D-Kamera mit starker Flucht und kleinen unlesbaren
  Details.

## 5. Insel-/Diorama-Proportionen

Die Starter-Insel ist ein kompakter, erweiterbarer Ort.

MVP-Lesart:

- ca. 12 sichtbare Slots,
- 6 sofort nutzbare freie Slots,
- 6 sichtbare spaetere Slots,
- langfristige Reserve ca. 16-20 Slots,
- zentrale Lichtung / Hub,
- Ufer-/Wassernaehe,
- Hain-/Waldnaehe,
- leichte Hoehen oder Randbereiche,
- Wege als weiche Orientierung, nicht als starres Raster.

Slots bleiben Orte, keine Menueeintraege. Slotnamen duerfen Lage beschreiben,
aber keine Kategorie erzwingen:

- Nordlichtung,
- Uferplatz,
- Hainrand,
- Suedhuegel,
- Westwiese,
- Ostrand.

Nicht verwenden:

- Hausplatz,
- Marktplatz,
- Werkstattplatz,
- Gartenplatz.

Terrain darf Varianten nahelegen, aber keine harte Kategorie sperren. Der
Spieler entscheidet, wo sein erstes Haus, ein Garten, eine Werkstatt oder ein
anderer Ort entstehen soll.

## 6. Licht und Atmosphaere

Talvori nutzt warmes, klares, freundliches Licht.

Leitwerte:

- Morgen- oder sanftes Tageslicht statt dramatischer Abend-Kontraste.
- Weiche Schatten, damit Objekte auf dem Boden stehen.
- Kleine Highlights auf Wasser, Dachkanten, Werkzeugen und Build Station.
- Ruhige Tiefe durch leichte atmosphaerische Trennung, nicht durch Nebel als
  Dauerfilter.

Stimmung:

- sicher,
- neugierig,
- lebendig,
- freundlich,
- einladend,
- nicht hektisch.

Vermeiden:

- duestere Survival-Stimmung,
- uebertriebene Fantasy-Glow-Orbs,
- harte Cartoon-Kontraste,
- sterile App-Helligkeit,
- braun-graue Bauplatz-Schwere.

## 7. Farbpalette

Talvori braucht eine warme, aber differenzierte Palette.

Primaere Weltfarben:

- Gruenfamilien fuer Hain, Wiesen und Inselkanten,
- warme Erd- und Sandtoene fuer Bauplaetze und Wege,
- klares Blau/Tuerkis fuer Wasser,
- helle Stein- und Holztoene fuer Bauphasen,
- kleine farbige Akzente fuer Figuren, Build Station und aktive Auswahl.

Palette-Regeln:

- Keine einfarbige Beige-/Braunwelt.
- Keine reine Blau-/Slate-App-Optik.
- Keine dominante Purple-/Neon-Gradient-Welt.
- Saettigung kontrolliert einsetzen: aktive Spielmomente duerfen heller sein,
  Hintergrund bleibt ruhiger.
- Sprach-/Lernmomente duerfen eigene Akzente nutzen, muessen aber zur Welt
  passen.

Kontrast:

- Tap-Ziele muessen auf Mobile klar unterscheidbar sein.
- Labels und Bubbles brauchen ausreichend Kontrast, aber keine harten
  Web-App-Kaesten.
- Spaetere/gesperrte Dinge werden gedimmt, nicht rot bestraft.

## 8. Formensprache

Talvori ist weich, gebaut und greifbar.

Formen:

- abgerundete Inselkanten,
- organische Wege,
- leicht vereinfachte Gebaeude,
- klare, gut erkennbare Silhouetten,
- weiche Rechtecke fuer kleine HUD-Elemente,
- Werkzeuge und Build-Objekte mit grosser Silhouette.

Nicht:

- scharfe technische Polygonoptik,
- sterile SaaS-Karten,
- ueberladene Fantasy-Ornamente,
- winzige realistische Details,
- Sticker-Figuren, die nicht auf dem Boden stehen.

Die Formensprache soll die Sprachebene tragen: Objekte muessen so klar sein,
dass sie spaeter als Language Anchors funktionieren.

## 9. Detailgrad und mobile Lesbarkeit

Detail ist erlaubt, wenn er lesbar bleibt.

Mobile-Regeln:

- Primaere Objekte muessen auf kleiner Breite erkennbar bleiben.
- Slots brauchen klare Umrisse und ausreichend Abstand.
- Figuren muessen auch klein als Figur, Worker oder Companion lesbar sein.
- Bauphasen muessen sich unterscheiden: lockerer Boden, Fundament, Wand-Ghost,
  Tuer/Fenster-Ghost, Raum.
- Text darf nicht in einzelne Buchstaben umbrechen.
- Labels duerfen Weltobjekte nicht verdecken.

Detailhierarchie:

1. Hauptort / Insel
2. gewaehlter Slot / Bauplatz
3. Build Station / Bauidee
4. Figurenaktion
5. HUD / Bubble
6. Hintergrunddetails

Hintergrunddetails duerfen lebendig wirken, aber nie die BuildChoice oder
Worker-Handlung ueberdecken.

## 10. Linien, Edges und Schatten

Talvori soll nicht flach wirken, aber auch nicht wie ein realistisches Render.

Edges:

- weiche, saubere Kanten,
- leichte Innenkanten bei Holz, Stein, Erde und Wasser,
- klare Silhouetten fuer Tap-Ziele,
- keine schwarzen Comic-Outlines als Default,
- keine unsauberen KI-Fransen.

Schatten:

- einheitliche Lichtquelle,
- kurze, weiche Bodenschatten fuer Figuren und Props,
- Bauobjekte muessen auf dem Boden verankert sein,
- UI-Schatten klein und ruhig,
- keine schweren Drop-Shadows wie Web-Dashboard-Karten.

Schatten sind funktional: Sie zeigen, was begehbar, gebaut, aktiv oder
schwebend/ghosted ist.

## 11. Materialgefuehl

Materialien muessen zum Diorama passen und layerbar bleiben.

Weltmaterialien:

- Erde: weich, bearbeitbar, warm,
- Stein: hell, stabil, nicht fotorealistisch,
- Holz: freundlich, leicht handwerklich,
- Wasser: klar und ruhig,
- Gras/Hain: lebendig, aber nicht kleinteilig,
- Bau-Ghosts: transparent, hell, ruhig, keine Neon-Hologramme.

Build Station:

- wirkt wie ein kleines Weltobjekt,
- kann Kiste, Arbeitstisch, Baurolle, Werkzeugstaender oder Markierung
  enthalten,
- zeigt Auswahl als Bauvorbereitung, nicht als Shop.

Vermeiden:

- photorealistische Texturen,
- malerische Flaechen, die nicht getrennt exportierbar waeren,
- zufaellige Materialstile pro Asset-Familie.

## 12. Figurenstil fuer Tali, Vori und Worker

Figuren sind emotionale Spielbegleiter, keine UI-Sticker.

Gemeinsame Regeln:

- gleiche Perspektive wie Insel und Gebaeude,
- gleicher Lichtwinkel,
- vereinfachte, freundliche Proportionen,
- klare Koerpersilhouette,
- grosse lesbare Gesten,
- ruhige, warme Gesichter,
- nicht zu chibi, nicht zu realistisch.

Tali/Vori:

- Companion-Figuren duerfen persoenlicher und ausdrucksstaerker sein.
- Sie geben kurze Hilfe, feiern neue Moeglichkeiten und rahmen Sprache.
- Sie duerfen nicht als dauerhaftes Tutorial-Panel wirken.

Worker:

- Worker macht Weltarbeit sichtbar.
- Auftrag -> laeuft -> arbeitet -> Welt veraendert sich -> neuer Hook.
- Worker darf Werkzeuge tragen, Material holen und kleine Arbeitsbewegungen
  zeigen.
- Worker ist keine direkte Avatarsteuerung, kein Joystick und kein
  Pathfinding-Scope.

Risiko:

Wenn Figuren aussehen, als kaemen sie aus einer anderen App, bricht Talvori
sofort auseinander. Figuren brauchen spaeter eigene Master References.

## 13. Gebaeudeproportionen und Bauphasen

Gebaeude sind kleine, klare Weltobjekte mit sichtbaren Bauphasen.

Haus-MVP:

- Fundament,
- Wand-Ghost,
- Tuer-/Fenster-Ghost,
- Dach-/Raum-Andeutung spaeter,
- Innenraum als spaetere Tiefe.

Proportionen:

- groesser als Props,
- kleiner als Insel-Hauptform,
- ausreichend hoch, um als Gebaeude zu wirken,
- nicht so gross, dass 12 Slots unmoeglich werden.

Bauphasen muessen visuell unterscheidbar sein:

- lockerer Boden: dunkel, unruhig, rissig,
- vorbereiteter Boden: ruhiger, heller, klarer Umriss,
- Fundament: stabile Stein-/Rahmenlesart,
- Wand-Ghost: neue Moeglichkeit, nicht fertiges Haus,
- spaetere Tiefe: Innenraum, Moebel, Container noch nicht in M16-CA.

Keine Bauphase darf als produktiver BuildState verstanden werden. M16-CA
beschreibt nur visuelle Regeln.

## 14. Build Station am Slot

Die Build Station am Slot ist das fuehrende BuildChoice-Pattern.

Sie ersetzt:

- Bottom-Sheet als Hauptentscheidung,
- Formularauswahl,
- reine Karten-/Listenwahl,
- Label-Wolke,
- isoliertes Wheel als Hauptpattern.

Build Station bedeutet:

- Bauentscheidung erscheint direkt am gewaehlten Slot.
- Die Station ist ein Weltobjekt: kleine Werkbank, Baukiste,
  Werkzeugpunkt, Baurolle oder Materialplatz.
- Haus ist als aktive Hauptidee klar sichtbar.
- Garten, Werkstatt, Garage und spaetere Kategorien koennen als ruhige
  Alternativen erscheinen.
- Weitere Moeglichkeiten werden als "mehr spaeter" angedeutet, nicht als
  unruhige Leiste.
- Worker/Tali/Vori kann die Station lebendig machen.

Regeln:

- Kein Menue-first Gameplay.
- Keine harte Kopplung Slot = Kategorie.
- Jeder freie Slot kann grundsaetzlich verschiedene Bauideen tragen.
- Terrain beeinflusst Stimmung und Variante, nicht harte Erlaubnis.
- Auswahl bleibt Spielmoment im Weltbild.

## 15. UI, HUD und Bubbles

UI unterstuetzt die Welt. Sie ersetzt sie nicht.

HUD-Regeln:

- klein,
- ruhig,
- kontextuell,
- mobil lesbar,
- nicht dauerhaft dominant,
- nicht als Admin-Kasten.

Bubbles:

- kurze Saetze,
- erst nach sichtbarem Objekt oder Problem,
- nicht als Textwand,
- nicht als Tutorial-Panel.

Geeignete Copy:

- "Such dir eine Insel aus."
- "Such dir einen Ort aus."
- "Dieser Platz ist frei."
- "Was moechtest du hier bauen?"
- "Ein Haus passt hierher."
- "Der Boden ist noch locker."
- "Jetzt haelt der Boden."

Nicht im sichtbaren Spiel:

- BuildChoice,
- Blueprint,
- Candidate,
- Phase,
- Transform,
- Pan,
- Zoom,
- Menue,
- BuildState.

UI-Stil:

- weiche kleine Rahmen,
- leichte Schatten,
- klare Tap-Ziele,
- keine Web-Dashboard-Karten,
- keine Quizkarte als Hauptmoment.

## 16. Slot-, Tile- und Layer-Regeln

Slots sind neutrale Orte.

Slot-Regeln:

- Slot beschreibt Lage, nicht Kategorie.
- Slot bleibt sichtbar genug, um gewaehlt zu werden.
- Gewaehlter Slot bekommt Fokus, aber andere Orte verschwinden nicht voellig.
- Spaetere Slots sind gedimmt und ruhig.
- Falsche oder spaetere Wahl zeigt keinen roten Fehler und keine Strafe.

Layer-Grundmodell fuer spaetere Assets:

1. Inselbasis / Wasser / Rand
2. Terrainflaechen
3. Wege
4. Slot-Marker / Bauplatzmarker
5. Build Station / Bauidee
6. Gebaeudephase
7. Figuren / Worker / Companion
8. kleine Partikel / Arbeitsreaktionen
9. Bubbles / HUD

Diese Reihenfolge ist eine Style-Regel, keine Implementierung. M16-CA erzeugt
keine Layer-Dateien und keine Asset-Dateien.

## 17. Asset-Familien-Grenzen

Spaetere Asset-Familien:

- Island base,
- terrain layers,
- slots / markers,
- paths / water / trees,
- build stations,
- buildings,
- building phases,
- workers / companions,
- props,
- interiors,
- furniture,
- containers,
- UI / HUD elements.

Jede Familie braucht spaeter:

- Perspektivregel,
- Lichtregel,
- Groessenregel,
- Exportregel,
- Benennung,
- Source-/Prompt-/Reference-Metadaten,
- QA-Status.

M16-CA gibt keine Familie als Asset frei. Es definiert nur die Grenzen, damit
M16-CB und M16-CC sauber arbeiten koennen.

## 18. KI-Art-Reference-Regeln

Referenztypen:

| Typ | Zweck | Grenze |
| --- | --- | --- |
| Art-Direction-Reference | Stimmung, Qualitaetsniveau, Weltgefuehl, Composition-Taste. | Kein App-Screen, kein finales Asset, nicht nachzeichnen. |
| Style Reference | Formensprache, Licht, Farbe, Detailgrad, Materialgefuehl. | Muss rechtlich und qualitativ geprueft werden. |
| Structure Reference | Perspektive, Slot-Layout, Layerordnung, Kamera. | Kein finaler Stil, nur Strukturhilfe. |
| Master Reference | Spaeteres fuehrendes Beispiel fuer eine Asset-Familie. | Erst in M16-CB/M16-CC oder Folgegates. |
| Engine-ready Candidate | Technisch vorbereiteter Kandidat fuer spaetere Integration. | Noch keine Produktfreigabe ohne Asset-Gate. |

Codex darf diese Regeln dokumentieren, pruefen und strukturieren. Codex soll
keine hochwertigen Spielbilder nachzeichnen oder als Bildgenerator auftreten.

## 19. Prompt-, Source- und Reference-Metadaten

Jeder spaetere Bild- oder Asset-Kandidat braucht Metadaten.

Mindestfelder:

```text
asset_family:
working_name:
purpose:
source_tool:
prompt:
negative_prompt:
style_reference:
structure_reference:
seed_or_generation_id:
postprocess_tool:
license_notes:
export_format:
layer_notes:
qa_status:
approved_for:
blocked_for:
```

Regeln:

- Keine Quelle ohne Notiz.
- Kein Prompt ohne Zweck.
- Keine Referenz ohne Rolle.
- Keine Datei ohne QA-Status.
- Keine Bilder nach `assets/` ohne eigenes Asset-Gate und ausdrueckliche
  Freigabe.

## 20. QA-Regeln gegen Stilbruch

Jede spaetere visuelle Arbeit muss pruefen:

- gleiche Kamera,
- gleiche Perspektive,
- gleiche Lichtquelle,
- gleiche Farbfamilie,
- gleiche Rundheit/Formensprache,
- gleiche Detaildichte,
- gleiche Figurenproportionen,
- gleiche Gebaeudeproportionen,
- gleiche Slot-/Tile-Lesbarkeit,
- gleiche UI-Ecken, Rahmen und Schatten,
- mobile Lesbarkeit,
- Layerbarkeit,
- Exportgroesse und Skalierung,
- Benennung,
- Lizenz-/Source-/Prompt-/Reference-Metadaten.

Sofortige Warnsignale:

- Insel wirkt wie Concept Art, UI wie Dashboard.
- Figur wirkt wie fremder Sticker.
- Gebaeude hat andere Perspektive als Slot.
- Build Station sieht wie Shop-Karte aus.
- HUD verdeckt Spielraum.
- Details sind huebsch, aber auf Mobile unlesbar.
- Bild ist stark, aber nicht layerbar.
- v2-Board wird wieder als Zielbild gelesen.
- Referenzbild wird direkt nachgebaut.

## 21. Visuals fuer spaetere Slices

M16-CA erstellt keine Preview-Bilder.

Spaetere Dokumentationsvisuals koennen sinnvoll sein:

- Art Bible Overview Map,
- Camera / Perspective Guide,
- Color / Light Board,
- Shape Language Strip,
- Character / Building / World Style Relationship,
- Build Station Anatomy,
- Asset Family Boundary Map,
- UI / HUD / Bubble Style Strip,
- QA Checklist Diagram.

Diese Visuals bleiben Dokumentationsmaterial. Sie sind keine App-Screens,
keine finalen Assets und keine Dateien unter `assets/`.

## 22. Stop-Regeln

M16-CA und direkte Folge-Slices muessen diese Grenzen respektieren:

- Keine Flutter-/Dart-Dateien.
- Keine App-Integration.
- Keine Route.
- Keine Navigation.
- Keine Persistenz.
- Kein BuildState.
- Keine Supabase/local DB Writes.
- Keine SRS-/`word_progress`-Aenderung.
- Keine automatische Wortplatzierung.
- Keine Tests.
- Keine Dateien unter `assets/`.
- Keine finalen Assets.
- Keine neuen High-Fidelity-Spielbilder.
- Keine App-Screens.
- Keine Figma-/Notion-/Linear-/GitHub-Writes.
- Keine externen Writes.
- Kein Plugin-Write.
- Keine Stashes anfassen.
- Kein Commit ohne separate Freigabe.

M16-CA ist keine Implementierungsfreigabe. Es macht nur Style-Entscheidungen
pruefbar.

## 23. Folgepfad zu M16-CB und M16-CC

Empfohlener Folgepfad:

```text
M16-CA Talvori Art Bible v1
-> M16-CB Starter Island Master Reference Set
-> M16-CC Asset Family and Export Spec
-> danach erst High-Fidelity Flow oder Flutter-Code
```

M16-CB sollte auf Basis dieser Art Bible klaeren:

- Starter-Insel Master Reference,
- Build Station Master Reference,
- Haus-Bauphasen Master Reference,
- Worker/Tali/Vori Master Reference,
- UI/HUD Master Reference,
- Container/Interior-Richtung als spaetere Tiefe.

M16-CC sollte danach klaeren:

- Asset-Familien,
- Exportformate,
- Layer,
- Benennung,
- Groessen,
- Metadaten,
- QA-Status,
- Asset-Gate fuer spaetere Integration.

Erst danach darf ein neuer High-Fidelity-Flow oder Flutter-Code geprueft
werden. Auch dann braucht jeder Code- oder Asset-Schritt einen eigenen Prompt
mit erlaubten Dateien, Stop-Regeln und Checks.
