# Talvori Welt: Private Island State System

Stand: 2026-06-04

Dieses Dokument definiert Phase 2E-A5: das Private-Island-State-System fuer
Talvori Welt. Es legt fest, wie private Inseln als Zustands- und Modulsystem
geplant werden, statt als ein einzelnes wachsendes Bild.

Es ist ein reines Planungsdokument. Es wurden keine Dart-/Flutter-Dateien,
keine Assets, keine Supabase-Daten, keine SQLite-/Vokabeldaten, keine SRS-Daten,
kein `word_progress`, keine Reward Bridge, keine Persistenz, keine Secrets und
keine Release-Artefakte geaendert.

Das aktuelle untracked Base-Asset
`assets/images/world/buildable_islands/forest_clearing/base.png` bleibt
unveraendert, nicht committed und nicht freigegeben.

Grundlagen:

- `docs/world_design/000-world-design-document-map.md`
- `docs/world_design/223-learning-to-building-loop.md`
- `docs/world_design/224-economy-balancing.md`
- `docs/world_design/225-in-world-learning-ui.md`
- `docs/world_design/226-build-progression-and-zones.md`
- `docs/world_design/232-onboarding-first-session.md`
- `docs/world_design/234-asset-production-and-buildable-island-templates.md`
- `docs/world_design/235-world-production-roadmap-and-checklists.md`
- `docs/world_design/236-buildable-forest-clearing-template-concept.md`
- `docs/world_design/237-buildable-forest-clearing-greybox-layout.md`
- `docs/world_design/238-multi-scale-world-and-interior-system.md`
- `docs/world_design/239-world-scale-and-dimension-rules.md`
- `docs/221-talvori-world-build-and-expansion-architecture.md`
- `docs/222-talvori-world-game-system-master-plan.md`

## 1. Zweck Des Dokuments

Dieses Dokument definiert das Private-Island-State-System.

Es verhindert, dass eine private Insel als einzelnes starres PNG geplant wird.

Es klaert, welche Teile einer Insel getrennt behandelt werden:

- Base-State,
- Expansion-State,
- Overlay-State,
- Placed-Item-State,
- Connector-/Docking-State,
- Building-Exterior-State,
- Interior-State,
- Object-Detail-State.

Dieses Dokument ist Pflichtgrundlage vor weiterer Base-Asset-Erzeugung und vor
Code.

## 2. Research-Ergebnis: Wie Profis Vorgehen

Das Professional Game Development Research Gate wurde fuer diesen Schritt
angewendet.

| Quelle / Orientierung | Ableitung fuer Talvori | Konkrete Entscheidung |
| --- | --- | --- |
| Unity Manual: Prefabs. Prefabs speichern konfigurierte GameObjects als wiederverwendbare Assets/Templates, die in Szenen instanziiert werden koennen. Quelle: `https://docs.unity.cn/Documentation/Manual/Prefabs.html` | Wiederverwendbare Weltteile werden als Templates gedacht, nicht als einmalige Bildkomposition. | Talvori trennt `IslandTemplate`, Expansion-Module und platzierte Items. |
| Unity Manual: Grid component. Grid nutzt Cell Size, Cell Gap und isometrische Layouts, um Platzierung konsistent zu machen. Quelle: `https://docs.unity.cn/Manual/class-Grid.html` | BuildZones, Slots und Footprints brauchen gemeinsame lokale Koordinaten/Referenzen. | Talvori platziert Items ueber Zonen/Slots statt freie Pixel. |
| Unity: Separate game data and logic with ScriptableObjects. ScriptableObjects dienen als Datencontainer und helfen, Daten von Logik zu trennen. Quelle: `https://unity.com/how-to/separate-game-data-logic-scriptable-objects` | Templates und Runtime-State muessen getrennt bleiben. | Talvori unterscheidet Template-Metadaten von `PrivateIslandState`. |
| Unity Scripting API: ScriptableObject. ScriptableObjects leben unabhaengig von GameObjects und koennen Daten zentralisieren. Quelle: `https://docs.unity.cn/ScriptReference/ScriptableObject.html` | Ein sichtbares Objekt ist nicht automatisch die Spielwahrheit. Daten duerfen rendererunabhaengig sein. | Talvori speichert Zustand als IDs, Phasen, Slots und Bindings, nicht als Bildzustand. |
| Unreal Engine: Saving and Loading Your Game. SaveGame-Klassen speichern die Informationen, die ueber Sessions erhalten bleiben sollen. Quelle: `https://dev.epicgames.com/documentation/en-us/unreal-engine/saving-and-loading-your-game?application_version=4.27` | Save State muss explizit definieren, welche Daten dauerhaft erhalten werden. | Talvori trennt Save State von Visual State; Phase 2E bleibt lokal/mock. |
| Unreal Engine: World Partition. Grosse Welten werden in ladbare Zellen/Layer organisiert. Quelle: `https://dev.epicgames.com/documentation/unreal-engine/world-partition-in-unreal-engine?lang=en-US` | Wachsende Welten werden modular und relevant geladen, nicht als ein Gesamtbild behandelt. | Talvori plant Core, ExpansionStates, InteriorSpaces und ObjectDetailSpaces getrennt. |
| Unity Addressables: Loading Addressable Assets. Assets werden ueber Adresse/Label/Referenz asynchron geladen. Quelle: `https://docs.unity.cn/Packages/com.unity.addressables%401.19/manual/LoadingAddressableAssets.html` | Spaetere Module brauchen adressierbare Asset-Gruppen und klare Abhaengigkeiten. | Talvori plant module-ready Asset-Struktur und Template-Metadaten. |

Kurzfassung:

Professionelle Spiele trennen Templates, platzierte Instanzen, Runtime-State,
Save-State, visuelle Darstellung und Detailraeume. Modulare Welt- und
Base-Building-Systeme packen Wachstum, Items und Innenraeume nicht in ein
einziges Bild. Sie nutzen Prefabs/Module, Slots, Szenen/Spaces, Save-Daten und
Content-Pipelines.

Ableitung fuer Talvori:

Talvori braucht ein Private-Island-State-System aus Core/Base,
Expansion-Modulen, Build-State-Overlays, platzierten Gebaeuden/Objekten und
eigenen Detail-Spaces.

## 3. Grundentscheidung

Eine private Insel besteht nicht aus einem einzigen Bild.

Sie besteht aus:

- `IslandTemplate`
- `IslandBaseState`
- `IslandExpansionState`
- `BuildAreaState`
- `PlacedWorldItemState`
- `Connector/DockingState`
- `BuildingExteriorState`
- `InteriorState`
- `ObjectDetailState`
- Template-Metadaten

Regel:

Ein Bild darf nur eine visuelle Schicht sein, nicht die komplette
Spielwahrheit.

Konsequenz:

`base.png` zeigt nur den initialen Island-View-Core. Wachstum, Baufortschritt,
Gebaeude, Wege, Connectoren, Innenraeume und Objekt-Details muessen als
separate States/Module planbar bleiben.

## 4. State-Typen Erklaeren

### `IslandTemplate`

Beschreibt die generelle Struktur einer Insel:

- erlaubte Zonen,
- `ExpansionSlots`,
- `DockingCandidates`,
- Kategoriekompatibilitaet,
- BuildZone-/Overlay-Anker,
- logical/visual/placement bounds.

Es ist kein Nutzerzustand, sondern eine Vorlage.

### `IslandBaseState`

Beschreibt die Grundform der Insel:

- Core/Base,
- initiales Biom,
- initiale Lesbarkeit,
- vorbereitete Anker.

Der Base-State ist nicht automatisch finaler Ausbau.

### `IslandExpansionState`

Beschreibt zusaetzliche Landstuecke oder freigeschaltete Flaechen:

- `northwest_expansion`,
- `southeast_ledge`,
- `second_plateau`,
- kleine Nebeninsel,
- Randmodul.

ExpansionStates duerfen bestehende Bau-Items nicht uebermalen.

### `BuildAreaState`

Beschreibt den Zustand einzelner Bauflächen:

- `empty`,
- `prepared`,
- `foundation_started`,
- `foundation_complete`,
- `frame_started`,
- `frame_complete`,
- `building_level_1`,
- spaetere Phasen.

BuildAreaState ist lokal zur BuildZone gedacht und nicht gleichbedeutend mit
dem ganzen Inselbild.

### `PlacedWorldItemState`

Beschreibt konkret platzierte Gebaeude, Deko, Wege und Objekte:

- Haus,
- Weg,
- Garten,
- Laterne,
- Auto-Aussenobjekt,
- Kategoriegebaeude.

Placed Items behalten ihren Zustand unabhaengig vom Base-Bild.

### `Connector/DockingState`

Beschreibt Verbindungen:

- Docking-Anker,
- Bruecken,
- Felsstege,
- Connector-Segmente,
- besetzte oder freie Dockingpunkte.

Connectoren verbinden DockingPoint zu DockingPoint und haengen nicht frei im
Space.

### `BuildingExteriorState`

Beschreibt den Aussen-Zustand eines Gebaeudes:

- Level,
- sichtbare Teile,
- Eingang,
- Fenster,
- Dach,
- Schild,
- Aussen-Deko.

### `InteriorState`

Beschreibt Innenraeume:

- Raum-Slots,
- freigeschaltete Objekte,
- Kategoriebezug,
- Interior-Progression,
- Lernbindungen.

InteriorState ist eine eigene Detailstufe und kein Zoom auf das Inselbild.

### `ObjectDetailState`

Beschreibt groessere oder lernstarke Objekte:

- Auto,
- Werkbank,
- grosser Koffer,
- Maschine,
- Kategorieobjekte.

Beispiel Auto:

- Frontscheibe,
- Lenkrad,
- Sitz,
- Tuer,
- Spiegel.

## 5. Warum Base-State Nicht Alles Enthalten Darf

Das Base-Asset zeigt nur die initiale Island View.

Es darf nicht enthalten:

- spaetere Haeuser,
- finale Wege,
- fertige Deko,
- Innenraeume,
- Autos,
- Object-Detail-Zustaende,
- voll ausgebaute Erweiterungen.

Es muss vorbereiten:

- genug Raum,
- glaubwuerdige Anker,
- ExpansionSlots,
- DockingCandidates,
- freie BuildZones,
- passende Dimensionen.

Ein Base-State darf nicht wie ein abgeschlossenes fertiges Plateau wirken.

## 6. Landwachstum / Expansion-System

Private Inseln wachsen von innen nach aussen.

Struktur:

- Core Area: erstes Fundament / erstes Gebaeude.
- Inner Ring: Hof, erster Weg, Lichtpunkt, kleine Deko.
- Middle Ring: Bibliothek, zweite BuildZone, Kategoriegebaeude.
- Edge Ring: Docking, Connector, Land-Erweiterung.
- Expansion Modules: neue Landstuecke / Plateaus / kleine Nebeninseln.

Regeln:

- Landwachstum darf nicht nur ein neues grosses Komplettbild sein.
- Erweiterungen sollen als Module oder klar definierte ExpansionStates geplant
  werden.
- Grosse Meilensteine duerfen optional komplette Base-State-Varianten bekommen,
  aber nur wenn das Modulmodell nicht ausreicht.
- Bereits gebaute Objekte muessen bei Expansion erhalten bleiben.

Phase-2E-Regel:

Keine echte Expansion bauen. `base.png` muss aber so aussehen, dass Core,
ExpansionSlots und DockingCandidates spaeter zusammen funktionieren.

## 7. Base-State Vs Expansion-Module Vs Full-State-Replacement

### A) Full-State-Replacement

Beschreibung:

- Komplettes Inselbild pro Ausbaustufe.

Vorteile:

- maximale visuelle Kontrolle,
- sehr stimmige Gesamtkomposition moeglich,
- gut fuer grosse Meilenstein-Zustaende.

Nachteile:

- teuer in Produktion,
- unflexibel bei individuellen Nutzerinseln,
- bestehende Objekte schwer zu erhalten,
- viele Varianten bei mehreren Kategorien und Inselrollen.

Risiko:

Wenn jedes Wachstum ein neues Gesamtbild braucht, wird Talvori kaum skalierbar.

### B) Base + Expansion Modules

Beschreibung:

- Core bleibt erhalten.
- Landstuecke, BuildState-Overlays und Placed Items werden ergaenzt.

Vorteile:

- modular,
- besser fuer mehrere Nutzerinseln,
- bestehende Items koennen erhalten bleiben,
- gut fuer Snap-/Docking-/Expansion-Logik.

Nachteile:

- hoehere Anforderungen an Anker, Perspektive und Asset-Kanten,
- Gefahr sichtbarer Naehte,
- braucht gute Template-Metadaten.

Empfehlung:

Diese Strategie ist die Basis fuer Talvori.

### C) Hybrid

Beschreibung:

- Module fuer kleine/mittlere Erweiterungen.
- Komplette State-Varianten nur fuer grosse Meilensteine.

Vorteile:

- gute Balance aus Flexibilitaet und Art Direction,
- erlaubt hochwertige Meilensteinbilder,
- vermeidet zu viele Spezialfaelle im Alltag.

Nachteile:

- braucht klare Regeln, wann Full-State-Replacement erlaubt ist,
- braucht Migrations-/Kompatibilitaetsregeln.

Leitentscheidung:

Fuer Talvori wird ein Hybrid geplant. Phase 2E konzentriert sich nur auf
Core/Base + vorbereitete ExpansionSlots. Keine echte Expansion in Phase 2E.

## 8. Placed Items Bleiben Unabhaengig

Wenn spaeter ein Haus, Weg, Garten oder Auto gebaut wurde, darf ein
Land-Expansion-State diese Objekte nicht wegmalen.

Regeln:

- Gebaeude und Objekte sind nicht fest ins Base-Asset eingebrannt.
- Sie existieren als `PlacedWorldItemState`.
- Sie werden ueber Slots/Zonen gerendert.
- Base-/Expansion-Aenderungen duerfen vorhandene Items nicht ueberschreiben.
- Wenn ein kompletter Full-State-Replacement genutzt wird, braucht es eine
  Migrations-/Kompatibilitaetsregel.

Konsequenz:

Neue Base-Assets duerfen keine spaeteren Pflicht-Items bereits fertig zeigen.

## 9. Beispiele Fuer Wachstum

### Beispiel 1: Haus Und Suedost-Erweiterung

Start:

- `base_core`.
- `main_build_area` ist leer.

Lernen:

- Aufgabe gelernt -> `foundation_started` auf `main_build_area`.
- Spaeter -> `house_level_1` als `PlacedWorldItem`.
- Spaeter -> `path_to_edge` als `PlacedWorldItem` oder `PathState`.
- Spaeter -> `expansion_se_unlocked` als `ExpansionState`.

### Beispiel 2: Auto

Start:

- Hof oder Yard-Slot ist freigeschaltet.

Aufbau:

- Auto-Aussenobjekt als `PlacedWorldItem`.
- Tap Auto -> `ObjectDetailSpace`.
- Innenraum-Slots: Frontscheibe, Lenkrad, Sitz, Tuer, Spiegel.

Regel:

Das Auto gehoert nicht in `base.png`.

### Beispiel 3: Haus-Innenraum

Start:

- Haus aussen ist ausreichend gebaut.
- Eingang ist freigeschaltet.

Navigation:

- Tap Eingang -> `InteriorSpace`.
- Innenraumobjekte werden dort gelernt/dekoriert.
- Tisch, Stuhl, Tasse und Regal gehoeren in den InteriorState, nicht in die
  Island View.

## 10. Kategorie-Erweiterbarkeit

Kategorien wie Reisen, Gesundheit, Essen, Business, Schule, Alltag, Technik
oder Kultur duerfen nicht hart codiert werden.

Regeln:

- `ExpansionSlots`, `BuildZones`, `PlacedItems`, `InteriorSlots` und
  `ObjectDetailSlots` muessen Kategorievarianten tragen koennen.
- Kategorie bestimmt moegliche Gebaeude-/Objektvarianten, nicht die
  Grundarchitektur.
- Waldlichtung bleibt neutrales Starter-Template.
- Kategoriekompatibilitaet gehoert in Templates und Bindings, nicht in
  Flutter-Widget-Sonderlogik.

Beispiele:

- Reisen kann spaeter Auto, Bahnhof, Hotel oder Koffer nutzen.
- Gesundheit kann Praxis, Apotheke oder Koerper-/Medizinobjekte nutzen.
- Essen kann Kueche, Tisch, Teller oder Tasse nutzen.
- Business kann Buero, Schreibtisch, Laptop oder Meetingraum nutzen.
- Schule kann Klassenzimmer, Tafel, Buecher oder Stifte nutzen.

## 11. Auswirkungen Auf Das Naechste Waldlichtung-Base-Asset

Das naechste `base.png` darf nur den Core/IslandBaseState zeigen, muss aber
vorbereiten:

- core/`main_build_area`,
- genug Raum fuer `PlacedWorldItems`,
- mindestens zwei `ExpansionSlots`,
- mindestens zwei `DockingCandidates`,
- moegliche Hof-/Weg-/Deko-Ringe,
- keine eingebrannten spaeteren Gebaeude,
- keine eingebrannten finalen Wege als Pflichtstruktur,
- keine geschlossene Plateau-Optik.

Wichtig:

Das Base-Asset muss nicht selbst wachsen. Es muss Slots und Module ermoeglichen.

Freigabe-Frage:

Kann man bei der Sichtpruefung erkennen, wo Core, innerer Ring, ExpansionSlots
und DockingCandidates spaeter logisch liegen koennen?

## 12. Auswirkungen Auf Asset-Struktur

Moegliche langfristige Struktur:

```text
assets/images/world/buildable_islands/forest_clearing/
  island/base_core.png
  island/expansion_nw_empty.png
  island/expansion_se_empty.png
  island/docking_w_empty.png
  build_states/main_build_area/foundation_started.png
  placed_items/house/exterior_level_1.png
  placed_items/path/path_core_to_edge.png
  interiors/house/interior_empty.png
  objects/car/exterior.png
  objects/car/interior_empty.png
  template.md
```

Fuer Phase 2E weiterhin minimal:

- `base.png` oder `base_core.png`,
- spaeter `foundation_started.png`,
- `template.md`.

Regel:

Die langfristige Struktur muss module-ready sein, auch wenn Phase 2E nur ein
kleines Core/Base-Asset nutzt.

## 13. Datenmodell Grob

### `PrivateIslandState`

- `islandId`
- `templateId`
- `ownerId`
- `baseStateId`
- `unlockedExpansionStateIds[]`
- `buildAreaStates[]`
- `placedWorldItems[]`
- `connectorStates[]`
- `unlockedInteriorSpaces[]`
- `unlockedObjectDetailSpaces[]`
- `categoryBindings[]`
- `version`

### `BuildAreaState`

- `buildAreaId`
- `phase`
- `progress`
- `activeTaskId` optional

### `PlacedWorldItemState`

- `itemId`
- `templateId`
- `slotId`
- `level`
- `visualState`
- `categoryBinding` optional

### `ExpansionState`

- `expansionId`
- `slotId`
- `unlocked`
- `assetPath`
- `requiredProgression`

Regel:

IDs und States sind wichtiger als ein einzelner Bildpfad. Das Bild wird aus
State + Template + Renderer abgeleitet.

## 14. Visual State Vs Save State

Definition:

- Visual State = was gerade gerendert wird.
- Save State = was dauerhaft/authoritative gespeichert wird.

Phase 2E:

- bleibt lokal/mock,
- keine Persistenz,
- keine Supabase Writes,
- keine Reward Bridge.

Spaeter zu klaeren:

- welche States lokal gecached werden,
- welche States Cloud-authoritative sind,
- wie Konflikte geloest werden,
- wie alte Template-Versionen migriert werden.

Regel:

Nicht jede visuelle Zwischenanimation gehoert in den Save State. Nicht jeder
Save-State muss als eigenes Bild existieren.

## 15. Phase-2E-Konsequenz

Fuer Phase 2E gilt:

- Kein echtes Expansion-System bauen.
- Kein PlacedItem-System bauen.
- Kein Full-State-Replacement bauen.
- Kein Interior/ObjectDetail bauen.
- Aber `base.png` muss so aussehen, dass diese Systeme spaeter moeglich sind.
- Asset-Prompt muss Core + ExpansionSlots + DockingCandidates + Scale
  beruecksichtigen.

Phase 2E bleibt:

- ein Island-View-Core/Base-Asset,
- spaeter ein `foundation_started`-Overlay,
- spaeter `template.md`,
- danach erst ein sehr kleiner lokaler Mock-Code-Slice.

## 16. Update Von `235`

`docs/world_design/235-world-production-roadmap-and-checklists.md` wird minimal
aktualisiert:

- Phase 2E-A5 wird in der Roadmap sichtbar.
- Status nach Erstellung dieses Dokuments: `fertig`.
- Naechster erlaubter Schritt bleibt: Base-Prompt ueberarbeiten / Phase 2E-B
  erneut.
- Code bleibt blockiert.

## 17. Stop-Regeln

Stoppen, wenn:

- Codex versucht, Inselwachstum als ein einziges Bild zu loesen,
- vorhandene Gebaeude/Objekte in Base-Asset eingebrannt werden,
- Placed Items nicht unabhaengig geplant werden,
- ExpansionSlots fehlen,
- Kategorie-Erweiterbarkeit vergessen wird,
- Save State und Visual State vermischt werden,
- Asset erzeugt wird,
- Code geschrieben wird.

Stoppen bedeutet:

- State-Typ klaeren,
- Template-/State-Grenze dokumentieren,
- Modul- oder Slot-Loesung ableiten,
- dann erst Asset-Prompt oder Code-Scope fortsetzen.

## 18. Akzeptanzkriterien

Dieses Dokument ist gut, wenn:

- klar ist, dass private Inseln ein State-/Modulsystem brauchen,
- Base, Expansion, Overlay und Placed Items getrennt sind,
- Landwachstum von innen nach aussen beschrieben ist,
- bestehende gebaute Objekte bei Expansion erhalten bleiben,
- Hybrid-Strategie beschrieben ist,
- Datenmodell grob ableitbar ist,
- Kategorie-Erweiterbarkeit beruecksichtigt ist,
- Phase 2E klein bleibt,
- Code weiterhin blockiert bleibt.

## Offene Fragen

- Welche ExpansionSlots braucht die Waldlichtung konkret zuerst: Nordwest,
  Suedost, Ost oder West?
- Wann ist ein Full-State-Replacement statt Modul-Erweiterung erlaubt?
- Welche States muessen in `template.md` vor dem ersten Code-Slice enthalten
  sein?
- Wie werden bestehende `PlacedWorldItemState`s bei spaeteren
  Template-Versionen migriert?
- Welche States werden spaeter lokal gecached und welche Cloud-authoritative?
