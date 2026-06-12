# M16-DU: Uferwald Island Build Blueprint Rule

Stand: 2026-06-12

Status: `docs_only_slice`, `blueprint_rule`, `game_feel_gate`,
`no_code`, `no_assets`, `not_runtime_data`

## 1. Zweck und Non-Goals

M16-DU legt eine verbindliche Uferwald Island Build Blueprint Rule fest. Das
Dokument muss kuenftig vor jeder Uferwald-, Island-, Map-, World-, Build-,
Preview- oder Implementierungsarbeit gelesen werden, wenn sichtbare
Inselstruktur, Spielfeldaufbau, Build/Map, Visit/Wander, Object Focus,
Slots, Wege, Bruecken, Build-Zonen oder technische Layout-Previews betroffen
sind.

Ziel:

- Uferwald wird als spielartiges 2.5D-Insel-Spielfeld gedacht.
- Die Insel dominiert den Bildschirm.
- Technische Layoutlogik schuetzt spaetere Spielbarkeit.
- Previews fallen nicht mehr in Tabellen-, Kartenlisten-, Debug-,
  Dashboard- oder Tool-Optik zurueck.

Non-Goals:

- kein Code,
- keine Flutter-/Dart-Dateien,
- keine Bilder,
- keine SVG/PNG,
- keine Assets,
- keine Dateien unter `assets/`,
- keine YAML-/JSON-/YML-Aenderung,
- keine Runtime-Mapdaten,
- keine finalen Koordinaten,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- kein BuildState,
- kein Commit.

M16-DU ist eine Regel fuer Aufbau, Spielgefuehl und Stop-Kriterien. Es ist
keine Implementierungs-, Asset-, Runtime-, Daten- oder App-Freigabe.

## 2. Eingangsquellen

Fuehrende Quellen:

- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
- `docs/world_design/365-modern-mobile-game-direction-board.md`
- `docs/world_design/367-talvori-art-bible-v1.md`
- `docs/world_design/368-starter-island-master-reference-set.md`
- `docs/world_design/383-talvori-camera-modes-and-visit-wander-rule.md`
- `docs/world_design/384-uferwald-playable-map-layer-and-mask-architecture.md`
- `docs/world_design/385-uferwald-technical-layer-and-mask-spec.md`
- `docs/world_design/386-uferwald-technical-layer-manifest.md`
- `docs/world_design/391-uferwald-measurement-precision-pass.md`
- `docs/world_design/392-uferwald-measurement-visual-precision-pass.md`
- `docs/world_design/402-uferwald-anchor-review-values-yaml-update-gate.md`
- `docs/world_design/planning/uferwald/uferwald_starter_island_planning_skeleton.yaml`

Leitlinien aus diesen Quellen:

- Talvori ist ein Cozy Island Diorama Builder, nicht ein Vokabel-Worksheet.
- Die Welt ist zuerst ein Ort, nicht eine UI.
- Sichtbares Art-Bild ist nicht die technische Spielkarte.
- Technische Layer, Masks, Zonen, Pfade, Build-Flaechen und Anchors muessen
  vor Rendering, Interaktion und Runtime-Naehe logisch vorhanden sein.
- YAML-Reviewwerte bleiben `review_values_only` und `not_runtime_data`.

## 3. Kernregel

Die Uferwald-Insel ist kein Debug-Board, keine Tabelle, keine Kartenliste und
keine technische Admin-Ansicht.

Sie ist ein spielbares 2.5D-Insel-Spielfeld. Jede sichtbare Uferwald-Preview
oder spaetere Implementierung muss als fullscreen oder near-fullscreen
Spielfeld gedacht werden. Die Insel muss der visuelle Hauptakteur sein; UI,
Legenden, technische Hinweise und Debug-Informationen duerfen sie nur
unterstuetzen.

Wenn eine Preview zuerst wie ein Tool aussieht und erst danach wie eine Insel,
ist sie fuer Uferwald nicht commitfaehig.

## 4. Fullscreen-Spielgefuehl

Verbindlich:

- Insel/World-Map nimmt den Hauptscreen ein.
- Die Insel ist die Hauptflaeche, nicht Header, Tabelle, Liste oder
  Sidepanel.
- HUD bleibt klein, spielartig und overlayartig.
- Build/Map wird als direktes Spielfeld gedacht: pan/zoom/focus spaeter am
  Ort, nicht als Formular.
- Overview darf die ganze Insel zeigen, muss aber als bewusster Review- oder
  Ueberblicksmodus erkennbar bleiben.
- Visit/Wander braucht einen begehbar gedachten Ort, nicht nur einen Zoom auf
  ein Bild.
- Object Focus bleibt ein Ausschnitt der Welt, kein Bottom-Sheet-Ersatz.

Nicht erlaubt:

- grosse Header-Karten ueber der Insel,
- Debug-Infos im Hauptspielfeld,
- Tabellen-/Dashboard-/Tooling-Look,
- technische Layernamen in einer spielnahen Preview,
- dominante Legenden, die mehr Raum als die Insel einnehmen,
- lange Erklaertexte vor dem sichtbaren Ort.

Technische Labels sind nur in internen Debug-Modi erlaubt. Ein spielnaher
Preview-Modus darf keine sichtbaren Begriffe wie `planning_path_corridor`,
`no_walk_mask`, `anchor_review_values` oder `runtime_status` im Spielbild
dominieren.

## 5. Pflichtbestandteile der Uferwald-Insel

Eine Uferwald-Insel-Blueprint- oder spielnahe Layout-Preview muss mindestens
enthalten:

- klare Inselgrundform / Kuestenform,
- Flusslauf oder Wasserarm,
- mindestens 2 kleine Bruecken oder Uebergaenge,
- 11-14 bebaubare Grundflaechen / Slots,
- Wege oder Pfade zu allen bebaubaren Grundflaechen,
- zentrale Lichtung / Hub,
- Startbereich,
- Wald-/Hainbereich,
- Ufer-/Wasserbereich,
- Felsen-/Klippen-/Hoehenbereich,
- Reserveflaechen fuer spaetere Erweiterungen,
- No-Walk-Flaechen,
- No-Build-Flaechen,
- Landmark-/Anchor-Punkte,
- Build-Station-am-Slot als spaeteres Pattern.

Diese Bestandteile muessen als Inselstruktur lesbar sein. Sie duerfen nicht
nur als Liste, Legende oder technische Marker existieren.

## 6. Infrastruktur-Regel

Jede Grundflaeche muss logisch erreichbar sein.

Verbindlich:

- Wege duerfen nicht nur Dekoration sein.
- Wege verbinden Start, Hub, Slots, Bruecken, Ufer, Wald und Hoehenbereiche.
- Bruecken verbinden getrennte Inselteile ueber Wasser oder Flussarme.
- Pfade muessen wie echte Spielwege wirken, nicht wie zufaellige Linien.
- Grundflaechen duerfen nicht isoliert schweben.
- Zentrale Hauptwege plus kleinere Nebenwege sind Pflicht.
- Wasser muss raeumliche Funktion haben: trennen, rahmen, fuehren oder
  Bruecken begruenden.
- Wald, Felsen und Klippen muessen Bewegung und Build-Flaechen logisch
  begrenzen, ohne die Insel unspielbar wirken zu lassen.

Ein Weg, der nicht zu einem Ort fuehrt, ist nur Deko. Ein Slot ohne Weg ist
kein glaubwuerdiger Spielort.

## 7. Grundflaechen- und Slot-Regel

Zielgroesse:

- 11-14 sichtbare bebaubare Grundflaechen.
- Ca. 6 davon sofort plausibel nutzbar.
- Der Rest bleibt sichtbare spaetere Reserve.

Slots bleiben neutral:

- kein sichtbares `home/market/library`-Hardcoding,
- keine festen Kategorieplaetze,
- keine Pflichtkategorie durch Terrain,
- keine Label-Wolke,
- keine isolierten Pins als Hauptlesart.

Slots brauchen unterschiedliche Lagequalitaeten:

- am Fluss,
- im oder am Hain,
- nahe Hub,
- auf Hoehe/Felsnaehe,
- Randzone,
- Reservebereich.

Terrain darf Varianten inspirieren. Es darf nicht hart blockieren, solange
kein eigenes Gate eine konkrete Build-/Terrain-Regel freigibt.

## 8. Landschaftsarchitektur

Uferwald braucht eine glaubwuerdige Topologie:

- flache zentrale Lichtung,
- gruener Hauptbereich,
- dichterer Wald/Hain an einer Seite,
- Wasser/Fluss als strukturierendes Element,
- Felsen/Klippen als natuerliche Begrenzung,
- mehrere Ebenen oder visuelle Hoehen,
- Rand- und Uferbereiche,
- Reservebereiche fuer spaetere Erweiterung.

Vegetation darf nicht zufaellig verteilt sein. Baeume bilden Gruppen,
Waldkanten und Hainbereiche. Felsen und Klippen zeigen Grenzen und
Hoehenlogik. Grasflaechen muessen Baufelder und Pfade lesbar lassen.

Eine gute Uferwald-Struktur zeigt auf einen Blick:

- Wo bin ich?
- Wo fuehrt der Weg hin?
- Wo koennte ich bauen?
- Was ist Wasser, Wald, Fels oder Reserve?
- Warum fuehlt sich diese Insel wie ein eigener Ort an?

## 9. Gameplay- und UX-Regel

Aktionen gehoeren ins Spielfeld.

Verbindlich:

- Auswahl passiert am Slot, an der Build Station oder am Weltobjekt.
- BuildChoice wird aus der Welt heraus verstanden.
- HUD hilft kurz und ruhig.
- Bubbles sind klein, kontextuell und spielartig.
- Technische QA-Informationen leben in einem separaten Dev-/Debug-Modus.

Nicht erlaubt:

- billige Liste als Hauptinteraktion,
- grosse Debug-Legende im Hauptbild,
- technische Layernamen in spielnaher Preview,
- Bottom Sheet, Formular, Tabelle oder Dashboard als Hauptentscheidung,
- UI, die mehr Raum als die Insel einnimmt,
- Aktionen, die nur in Panels passieren und nicht im Spielfeld verankert
  sind.

Spielgefuehl geht vor Admin-Tooling. Wenn ein interner Debug-Modus noetig ist,
muss er klar vom spielnahen Inselmodus getrennt sein.

## 10. Referenzregel

Erfolgreiche Mobile-Games dienen als Strukturvorbild auf Prinzipienebene:

- fullscreen Welt/Map,
- Interaktion direkt am Objekt,
- kleine HUD-Overlays,
- Bottom-/Side-UI nur unterstuetzend,
- Fokus auf spielbare Szene statt Formular.

Talvori kopiert keine fremden Assets, Screens, Layouts oder Mechaniken.
Reale Inseln, Luftbilder, Karten- oder Landschaftsvorstellungen duerfen als
Strukturreferenz dienen, aber keine Bilder duerfen kopiert oder
nachgezeichnet werden.

Reale Referenzen helfen nur fuer:

- Dimension,
- Vegetationslogik,
- Kuestenform,
- Fluss-/Weglogik,
- Bruecken-/Uebergangslogik,
- Grundflaechenverteilung.

## 11. Technische Layer-Regel

Vor schoenem Rendering muessen diese Layer logisch vorhanden sein:

- `island_shape`
- `water_river_layer`
- `grass_base_layer`
- `forest_grove_layer`
- `rock_cliff_layer`
- `path_network_layer`
- `bridge_layer`
- `buildable_ground_layer`
- `reserved_ground_layer`
- `no_walk_layer`
- `no_build_layer`
- `anchor_landmark_layer`
- optional `sort_depth_bands`

Diese Layer duerfen in fruehen Previews als lokale Skizzenkonstanten,
Dokumentationsvisual, Markdown-Blueprint oder spaeter als eng gegatete
Planungsstruktur erscheinen. Sie sind keine Runtime-Mapdaten, keine finalen
Koordinaten, keine Assets und keine App-Integration.

Die technische Wahrheit bleibt fuehrend. Ein schoenes Bild darf daraus
entstehen, aber das Bild darf nicht zur Quelle werden, aus der Codex Wege,
Collision, No-Walk, No-Build oder Slots raet.

## 12. Pflichtreihenfolge

Diese Reihenfolge ist Pflicht:

1. Insel-Blueprint / technische Layoutlogik.
2. Visuelle Layout-Preview als fullscreen oder near-fullscreen Spielfeld.
3. Schoener Game-Look / Rendering.
4. Slot-Interaktion.
5. BuildChoice / Build Station.
6. Bauphase / Lernhandlung.

Nicht mehr zuerst:

- Debug-Liste,
- Anchor-Karten,
- Tabellen,
- technische Panels,
- formularartige Admin-Ansichten,
- isolierte Datenboards ohne Insel.

Ein Slice darf bewusst ein internes Debug-Werkzeug bauen, wenn der Prompt das
ausdruecklich erlaubt. Dann muss er aber sagen, dass es kein spielnaher
Uferwald-Preview-Zustand ist.

## 13. Harte Stop-Regeln

Ein Uferwald-, Island-, Map-, World-, Build-, Preview- oder
Implementierungs-Slice ist nicht commitfaehig, wenn:

- die Insel nicht Hauptflaeche des Screens ist,
- die Ansicht wie ein Debug-Tool statt wie ein Spiel wirkt,
- weniger als 11 bebaubare Grundflaechen geplant sind,
- Wege nicht zu allen Grundflaechen fuehren,
- Fluss/Wasser keine raeumliche Funktion hat,
- Bruecken/Uebergaenge fehlen, obwohl Wasser trennt,
- Slots isoliert oder zufaellig wirken,
- Debug-Labels das Spielbild dominieren,
- technische Layernamen in der spielnahen Preview sichtbar sind,
- UI mehr Raum einnimmt als die Insel,
- Aktionen nicht im Spielfeld gedacht sind,
- BuildChoice als Liste, Tabelle, Shop, Formular oder grosses Bottom Sheet
  startet,
- Slots als feste Kategorieplaetze gelesen werden,
- der Slice technische Layoutwerte aus Pixeln raet,
- Runtime-Daten, Assets, Route, Persistenz oder BuildState ohne eigenes Gate
  entstehen.

Diese Stop-Regeln gelten auch, wenn die technische Umsetzung korrekt ist.
Eine korrekte, aber toolartige Uferwald-Ansicht ist fuer Talvori nicht gut
genug.

## 14. Commitfaehigkeitspruefung fuer kuenftige Slices

Jeder relevante Folge-Slice muss vor Abschluss beantworten:

| Frage | Erwartung |
| --- | --- |
| Dominiert die Insel den Screen? | Ja |
| Wirkt die Ansicht wie ein Spielort statt Tooling? | Ja |
| Sind 11-14 Grundflaechen als Auswahlraum plausibel? | Ja |
| Sind ca. 6 Startflaechen plausibel nutzbar? | Ja |
| Sind Wege, Bruecken und Wasser raeumlich sinnvoll? | Ja |
| Bleiben Slots neutral und frei waehlbar? | Ja |
| Sind HUD, Legende und Labels klein/untergeordnet? | Ja |
| Sind technische Labels aus dem spielnahen Modus entfernt? | Ja |
| Sind Runtime, Assets, YAML/JSON, Persistenz und BuildState blockiert, falls kein eigenes Gate sie oeffnet? | Ja |

Wenn eine Antwort NEIN ist, bleibt der Slice Review/WIP und ist nicht
commitfaehig.

## 15. Folgepfad

Der naechste sinnvolle Uferwald-Code- oder Preview-Slice muss 403 zuerst
anwenden und den aktuellen Layout-/Game-Feel-Status dagegen pruefen.

Empfohlene Reihenfolge:

1. Bestehende isolierte technische Layout-Preview gegen 403 pruefen.
2. Falls noetig: spielnahe fullscreen Layout-Preview korrigieren.
3. Danach erst ueber schoeneres Rendering oder weitere Interaktion sprechen.
4. Slot-Interaktion und Build Station bleiben eigene Folge-Gates.

M16-DU gibt keinen Code frei. Es definiert nur die verbindliche Regel, an der
kuenftige Uferwald-Previews und Implementierungen gemessen werden.
