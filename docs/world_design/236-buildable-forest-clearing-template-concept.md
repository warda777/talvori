# Talvori Welt: Buildable Forest Clearing Template Concept

Stand: 2026-06-04

Dieses Dokument definiert Phase 2E-A: das Konzept fuer das erste buildable
Waldlichtung-Template. Es ist die Grundlage fuer spaetere Asset-Prompts fuer
`base`/`empty` und `foundation_started`.

Es ist ein reines Planungsdokument. Es wurden keine Dart-/Flutter-Dateien,
keine Assets, keine Supabase-Daten, keine SQLite-/Vokabeldaten, keine SRS-Daten,
kein `word_progress`, keine Reward Bridge, keine Persistenz, keine Secrets und
keine Release-Artefakte geaendert.

Grundlagen:

- `docs/world_design/000-world-design-document-map.md`
- `docs/world_design/223-learning-to-building-loop.md`
- `docs/world_design/224-economy-balancing.md`
- `docs/world_design/225-in-world-learning-ui.md`
- `docs/world_design/226-build-progression-and-zones.md`
- `docs/world_design/232-onboarding-first-session.md`
- `docs/world_design/234-asset-production-and-buildable-island-templates.md`
- `docs/world_design/235-world-production-roadmap-and-checklists.md`
- `docs/221-talvori-world-build-and-expansion-architecture.md`
- `docs/222-talvori-world-game-system-master-plan.md`

## 1. Zweck Von Phase 2E-A

Phase 2E-A ist ein Konzeptblock.

Regeln:

- Kein Code.
- Kein Asset.
- Nur Konzept.
- Ziel ist, Waldlichtung als erstes buildable Template sauber zu planen.
- Code bleibt blockiert, bis `base`, `foundation_started`, Metadaten und
  Device-Check freigegeben sind.

Dieses Dokument soll so konkret sein, dass daraus als naechster Schritt ein
Asset-Prompt fuer die Buildable-Waldlichtung und ein abgestimmtes
`foundation_started`-Overlay entstehen kann.

## 2. Warum Die Bisherige Waldlichtung Nicht Reicht

Das aktuelle Waldlichtung-Asset ist ein schoenes Preview-/Naturasset. Es ist
geeignet, um eine Starter-Insel als Auswahloption in der Welt zu zeigen.

Es reicht aber nicht als Buildable Template:

- Die Bauflaeche ist nicht ausreichend vorbereitet.
- Freie Stellen sind nicht eindeutig als spaetere BuildZone komponiert.
- Fundament-Markierungen wirken nachtraeglich aufgelegt.
- Der Baufortschritt verschmilzt nicht mit Material, Perspektive und Licht.
- BuildZones brauchen eine visuelle Entsprechung im Asset.

Neuer Ansatz:

Asset und semantische Zonen werden gemeinsam geplant. Das Bild zeigt nicht nur
Natur, sondern eine natuerliche, glaubwuerdige Insel, die bauliche Veraenderung
von Anfang an tragen kann.

## 3. Template-Rolle

Template-Daten:

| Feld | Wert |
| --- | --- |
| Template-Name | `buildable_forest_clearing` |
| Rolle | erste baubare Starter-Insel |
| Phase | 2E-A Konzept |
| Status | Phase 2E-A-Konzept ist fertig dokumentiert; Template selbst noch nicht freigegeben |
| Zweck | erster Qualitaetsbeweis fuer den Talvori-Bauworkflow |

Klarstellung:

Das Phase-2E-A-Konzept ist fertig dokumentiert. Das Buildable-Waldlichtung-
Template selbst ist noch nicht freigegeben, weil `base`, `foundation_started`,
`template.md` und Device-Check noch fehlen.

Nicht-Zweck:

- kein vollstaendiges Gebaeudesystem,
- kein Deko-System,
- kein Wege-System,
- kein Connector-System,
- kein Innenraum-System,
- keine Persistenz,
- keine Reward Bridge.

## 4. Visuelles Grundkonzept Der Waldlichtung

Die Buildable-Waldlichtung ist eine freigestellte schwebende 2.5D-Insel.

Visuelle Richtung:

- isometrische / 2.5D Mobile-Game-Perspektive,
- natuerlicher Waldlichtungs-Charakter,
- hochwertige Cozy-Fantasy-Diorama-Optik,
- klare, ruhige Hauptbauflaeche,
- natuerliche Umrandung durch Gras, Moos, kleine Baeume, Buesche und Steine,
- glaubwuerdiger schwebender Fels-/Erdkoerper,
- gute Lesbarkeit in Weltuebersicht, Inselansicht und Bauplatzansicht.

Nicht erlaubt:

- fertige Gebaeude,
- UI-Flaechen,
- moderne Plattform,
- Kreis,
- Rechteck,
- sichtbarer Bau-Marker,
- Space-Hintergrund im Inselasset,
- Schrift, Labels oder Buttons.

Spaetere Ausgabe:

- transparentes PNG,
- freigestellt,
- keine rechteckige Matte,
- keine Chroma-Key-Reste.

## 5. Geplante Asset-Schichten

Phase 2E benoetigt zwei Schichten.

### `base` / `empty`

Das Base-Asset zeigt:

- natuerliche Waldlichtung,
- vorbereitete, aber noch unbebaute Bauflaeche,
- organische Erd-/Grasflaeche,
- genug Platz fuer Fundament und spaeter kleines Haus,
- ruhige Bildstelle fuer spaetere Overlays,
- keine fertigen Gebaeude.

Die Bauflaeche darf nicht technisch leer wirken. Sie soll aussehen, als haette
die Natur dort ohnehin eine ruhige, nutzbare Lichtung gelassen.

### `foundation_started`

Das `foundation_started`-Overlay zeigt:

- erste kleine Steinplatten,
- geglaettete Erde oder ersten Fundamentansatz,
- exakt dieselbe Perspektive wie das Base-Asset,
- Material und Licht passend zur Waldlichtung,
- klare Veraenderung gegenueber `empty`.

Nicht erlaubt:

- fertiges Haus,
- Waende,
- Dach,
- Editor-Look,
- UI-Kreis,
- generisches Rechteck,
- Plattform,
- fremde Perspektive.

### Spaetere Schichten

Spaetere Schichten bleiben nur konzeptionell:

- `foundation_complete`,
- `frame_started`,
- `frame_complete`,
- `building_level_1`,
- `building_level_2`,
- `living_building`,
- `master_version`.

## 6. Semantische Zonen Auf Der Waldlichtung

Die Buildable-Waldlichtung braucht semantische Zonen, auch wenn in Phase 2E nur
eine davon sichtbar/interaktiv ist.

| Zone | Zweck | Ungefaehre Lage | Erlaubt | Nicht erlaubt | Phase 2E sichtbar/interaktiv? |
| --- | --- | --- | --- | --- | --- |
| `main_build_area` | erster Bauplatz fuer Fundament und spaeteres Startgebaeude | zentral oder leicht nach vorne versetzt in der Lichtung | Fundament, spaeter Haus/Huette | Wasser, Klippe, Felsblock, fertiges Gebaeude | ja |
| `blocked_area` | Schutz von Rand, Felsen, Baeumen, Klippen | Inselraender, Felskoerper, dichte Baumgruppen | keine normalen Items | Bau, Deko, Wege | nein |
| `decoration_area` | spaetere kleine Deko ohne Bauzonen zu blockieren | Randnahe Grasstellen, kleine Lichtungsbereiche | Blumen, Laterne, kleine Steine, Buesche | Gebaeude, Fundament | nein |
| `path_area` / `pathNodes` | spaetere Wege zwischen Bauplatz, Rand und Docking | vom Bauplatz zu einem Randbereich | Wegstuecke, Lichtpunkt spaeter | freie Pixelwege, grosse Strassen | nein |
| `future_expansion_area` | optionale spaetere Erweiterung | freiere Nebenflaeche, falls Motiv Platz bietet | spaetere Zone oder Preview | Phase-2E-Bau | nein |
| `docking candidates` | spaetere Connector-Anschlusspunkte | zwei plausible Inselraender | spaetere DockingPoints | fertige Bruecken in Phase 2E | nein |

Phase-2E-Regel:

- Nur `main_build_area` ist sichtbar/interaktiv.
- `blocked_area`, `decoration_area` und PathNodes sind nur unsichtbare
  Vorbereitung.
- Keine Deko.
- Keine Wege.
- Keine Connectoren.

## 7. Main Build Area

Die `main_build_area` ist die wichtigste Zone des Templates.

Anforderungen:

- zentrale oder leicht versetzte natuerliche Bauflaeche,
- gross genug fuer Fundament und spaeter kleines Haus,
- freie Sicht, nicht von Baeumen verdeckt,
- keine Klippe,
- kein Wasser,
- keine harte Felsflaeche,
- organisch in die Lichtung eingebettet,
- in Portrait und Landscape gut antippbar,
- im normalen Modus kein Debug-Flaechen-Look,
- bei Tap/Fokus dezente Hervorhebung moeglich.

Visuelle Wirkung:

Die Flaeche soll im Base-Asset bereits so wirken, als koenne hier etwas
entstehen. Sie darf aber nicht so vorbereitet aussehen, als waere schon eine
Baustelle vorhanden.

## 8. BuildZone-Anker Und Overlay-Anker

Spaetere Metadaten muessen die folgenden Felder aufnehmen.

Noetige Felder:

- `mainBuildAreaAnchor`,
- `foundationOverlayAnchor`,
- `foundationOverlayScale`,
- `localPosition` relativ zu `logicalBounds`,
- `hitTestShape`,
- `placementBounds`,
- `visualBounds`,
- optional `focusCameraTarget`.

Keine finalen Koordinaten in diesem Konzept erzwingen.

Ziel:

Die Felder muessen klar sein, damit spaeter in `template.md` nicht geraten
wird, wo der Bauplatz und das Overlay liegen.

## 9. LearningCategory-Erweiterbarkeit

Talvori Welt muss beliebige Lernkategorien unterstuetzen.

Kategorien wie Reisen, Gesundheit, Alltag, Business, Schule, Essen, Technik
oder Kultur duerfen nicht hart codiert werden. Inseln, Gebaeude, Quests,
Ressourcenwirkungen und visuelle Varianten muessen templatebasiert und
kategoriefaehig gedacht werden.

Zielmodell:

```text
LearningCategoryTemplate
  id
  displayName
  icon
  theme
  preferredBiomes
  possibleBuildings
  possibleDecorations
  possibleQuestTypes
  learningModes
  rewardPreferences
  visualVariants
```

Beispiele:

- Reisen,
- Gesundheit,
- Alltag,
- Business,
- Schule,
- Essen,
- Technik,
- Kultur.

Regeln:

- Keine Kategorie wird hart im Code verdrahtet.
- Waldlichtung darf erste allgemeine Lernkategorie tragen, aber nicht nur fuer
  eine feste Kategorie gebaut werden.
- BuildZones muessen spaeter unterschiedliche Kategorie-Gebaeude aufnehmen
  koennen.
- Gebaeude wie Haus, Bibliothek, Markt, Werkstatt oder Themengebaeude muessen
  ueber Templates und Varianten erweiterbar sein.
- Neue Kategorien duerfen spaeter ergaenzt werden, ohne Insel-, Quest- oder
  Ressourcenarchitektur zu brechen.

## 10. Kategoriebezug Der Waldlichtung

Die Waldlichtung ist ein neutrales Starter-Template.

Sie ist geeignet fuer:

- allgemeines erstes Lernen,
- fruehe Orientierung,
- erstes Fundament,
- erstes neutrales Startgebaeude.

Sie ist nicht festgelegt auf:

- Reisen,
- Gesundheit,
- Business,
- Schule,
- eine andere einzelne Kategorie.

Erste BuildZone:

Die `main_build_area` sollte ein neutrales Startgebaeude ermoeglichen, z. B.
eine Huette, ein Haus oder ein Basis-Lernhaus.

Spaetere Erweiterung:

Eine Bibliothek oder ein Wissensort kann als zweite Zone oder spaeteres
Gebaeude folgen.

## 11. Gebaeude- Und Ausbau-Reihenfolge Fuer Dieses Template

Geplante Reihenfolge:

1. `foundation_started`
2. `foundation_complete`
3. Einfaches Haus / einfache Huette
4. Erster Weg oder Lichtpunkt
5. Bibliotheks-/Wissenspunkt
6. Spaeter Markt / Werkstatt / Deko
7. Spaeter kategorie-spezifische Gebaeudevarianten

Phase-2E-Grenze:

Nur `foundation_started`.

## 12. Docking- Und Connector-Vorbereitung

Die Buildable-Waldlichtung braucht spaetere Docking-Moeglichkeiten, aber in
Phase 2E keine aktiven Connectoren.

Plan:

- mindestens zwei moegliche spaetere Dockingrichtungen,
- visuell plausible Inselraender,
- keine fertigen Bruecken,
- keine technischen Steckpunkte,
- Dockingbereiche muessen spaeter mit Connectoren funktionieren,
- in Phase 2E nicht interaktiv.

Moegliche Richtungen:

- Ost / Suedost als erster offener Rand,
- West / Nordwest als zweite Option.

Diese Richtungen sind konzeptionell. Final werden sie erst mit dem Asset und
`template.md` festgelegt.

## 13. Zoom-/Kamera-Anforderungen

Die Waldlichtung muss in mehreren Blickweiten funktionieren.

Anforderungen:

- Weltuebersicht: Insel bleibt als Waldlichtung lesbar.
- Inselansicht: Bauflaeche ist erkennbar.
- Bauplatzansicht: `foundation_started` wirkt klar und integriert.
- Portrait: Insel darf nicht gequetscht wirken.
- Landscape: spaeter als Explore-Modus moeglich.
- `focusCameraTarget` fuer `main_build_area` wird vorbereitet.

Kamera-Ziel:

Bei Tap auf `main_build_area` soll spaeter ein sanfter Fokus moeglich sein, der
die Insel nicht in eine technische Bauansicht verwandelt.

## 14. Template-Metadaten

Spaetere `template.md` oder strukturierte Metadaten muessen enthalten:

- `templateId`,
- `status`,
- `assetPaths`,
- `buildZones`,
- `buildZoneAnchors`,
- `overlayAnchors`,
- `logicalBounds`,
- `visualBounds`,
- `hitTestShape`,
- `placementBounds`,
- `dockingCandidates`,
- `pathCandidates`,
- `blockedAreas`,
- `decorationAreas`,
- `categoryCompatibility`,
- `zoomNotes`,
- `deviceCheckNotes`,
- `decisionLog`.

Metadaten sind Pflicht, bevor Code erneut startet.

Verbindliche Dateistruktur fuer den ersten buildable Waldlichtung-Versuch:

```text
assets/images/world/buildable_islands/forest_clearing/base.png
assets/images/world/buildable_islands/forest_clearing/foundation_started.png
assets/images/world/buildable_islands/forest_clearing/template.md
```

Begruendung:

Diese Struktur haelt Base, Overlays und Metadaten zusammen und passt zur
langfristigen Buildable-Island-Template-Strategie.

## 15. Asset-Prompt-Anforderungen

Der spaetere Base-Prompt muss enthalten:

- buildable forest clearing,
- one natural main build area,
- no finished buildings,
- no UI/text/buttons,
- transparent PNG,
- enough room for foundation overlay,
- 2.5D/isometric mobile game style,
- high quality,
- natural, not empty/artificial,
- subtle docking-capable edges,
- category-neutral starter island.

Der spaetere `foundation_started`-Prompt muss enthalten:

- transparent overlay only,
- same perspective,
- small stone/foundation start,
- fits base build area,
- no house/walls,
- no rectangle/platform/UI marker.

Wichtig:

Der Base-Prompt und der Overlay-Prompt muessen zusammen gedacht werden. Das
Overlay darf nicht spaeter auf eine unpassende Flaeche gezwungen werden.

## 16. Phase-2E-A ToDos

Konkrete ToDos:

- Konzept pruefen.
- Base-Prompt erstellen.
- `foundation_started`-Prompt erstellen.
- Verbindliche Dateistruktur verwenden.
- `template.md`-Struktur vorbereiten.
- Status in `docs/world_design/235-world-production-roadmap-and-checklists.md`
  aktualisieren.
- Danach erst Asset-Erzeugung 2E-B starten.

## 17. Stop-Regeln

Stoppen, wenn:

- Waldlichtung zu sehr wie fertige Deko-Insel wirkt,
- Bauflaeche nicht klar ist,
- Bauflaeche kuenstlich wirkt,
- Kategorieerweiterbarkeit nicht beruecksichtigt ist,
- Foundation-Overlay nicht perspektivisch planbar ist,
- Docking-/Path-/Deko-Bereiche vergessen wurden,
- Codex versucht, Code zu schreiben,
- Codex versucht, Asset ohne Konzept zu erzeugen.

Stoppen bedeutet:

Der naechste Block bleibt Planung oder Prompt-Verbesserung. Es wird kein Code
geschrieben und kein Asset produziert, solange die Konzeptluecke besteht.

## 18. Offene Fragen

Offene Fragen:

- Soll die Buildable-Waldlichtung dem bestehenden Preview-Asset sehr aehnlich
  sehen oder darf sie als klar neue Variante wirken?
- Welche zusaetzlichen Metadatenfelder braucht `template.md` nach dem ersten
  Device-Check?
- Wird `foundation_started` ein eigenstaendiges Overlay oder ein kompletter
  alternativer Inselzustand?
- Wie gross darf die `main_build_area` sein, ohne die Naturwirkung zu
  verlieren?
- Welche ersten Kategorievarianten werden spaeter als Test fuer
  `LearningCategoryTemplate` genutzt?

## 19. Akzeptanzkriterien

Dieses Dokument ist gut, wenn:

- Waldlichtung als buildable Template klar definiert ist,
- `base` und `foundation_started` ableitbar sind,
- `main_build_area` logisch und visuell beschrieben ist,
- Kategorie-Erweiterbarkeit beruecksichtigt ist,
- keine harte Kategoriecodierung geplant ist,
- Template-Metadaten klar sind,
- ein Asset-Prompt ableitbar ist,
- Code weiterhin blockiert bleibt, bis Assets freigegeben sind.
