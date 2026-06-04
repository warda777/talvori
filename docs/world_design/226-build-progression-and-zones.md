# Talvori Welt: Build Progression Und Zonen

Stand: 2026-06-04

Dieses Dokument plant konkret, wie Bauzonen, Fundamente, Gebaeudezustaende,
Deko, Wege, Innenraeume und Platzierungsregeln in Talvori Welt funktionieren
sollen. Es vertieft die Architektur aus `docs/221` und leitet einen kleinen
Phase-2E-Slice ab.

Es ist ein reines Planungsdokument. Es wurden keine Dart-/Flutter-Dateien,
keine Assets, keine Supabase-Daten, keine SQLite-/Vokabeldaten, keine SRS-Daten,
kein `word_progress`, keine Reward Bridge, keine Persistenz, keine Secrets und
keine Release-Artefakte geaendert.

Grundlagen:

- `docs/world_design/000-world-design-document-map.md`
- `docs/world_design/223-learning-to-building-loop.md`
- `docs/world_design/224-economy-balancing.md`
- `docs/world_design/225-in-world-learning-ui.md`
- `docs/221-talvori-world-build-and-expansion-architecture.md`
- `docs/222-talvori-world-game-system-master-plan.md`

## 1. Ziel Des Dokuments

BuildZones und Bauphasen sind noetig, weil Talvori Welt nicht aus beliebigen
Pixelplatzierungen bestehen darf.

Assets allein reichen nicht:

- Ein PNG zeigt nur, wie eine Insel aussieht.
- Die App weiss dadurch nicht, wo gebaut werden darf.
- Sie weiss nicht, wo Wasser, Felsen, Klippen oder freie Flaechen liegen.
- Sie weiss nicht, welche Gebaeude, Wege oder Deko dort erlaubt sind.

Spaetere Gebaeude duerfen deshalb nicht frei auf Pixeln platziert werden.
Jedes Bauobjekt braucht eine semantische Zone, einen erlaubten Zustand und eine
Validierung.

Ziel:

- BuildZones definieren, wo Bau moeglich ist.
- Bauphasen definieren, wie ein Bauplatz sichtbar waechst.
- DecorationZones und NatureAreas halten Deko und Natur kontrolliert.
- PathNodes verhindern frei gemalte Wege.
- BlockedAreas schuetzen Wasser, Felsen, Klippen und wichtige Bereiche.
- Renderer und Weltlogik bleiben getrennt.

## 2. Grundprinzip

Jede Insel hat semantische Zonen.

Regeln:

- Gebaeude entstehen nur auf erlaubten BuildZones.
- Deko entsteht nur in DecorationZones.
- Wege entstehen nur ueber PathNodes oder PathAreas.
- Wasser, Felsen und Klippen sind BlockedAreas.
- Sichtbare Grafik und logische Bauflaeche sind getrennt.
- Eine Zone ist fachlich, nicht bildschirmbezogen.
- Eine Zone kann im normalen Modus unsichtbar sein.
- Debug-/Editor-Modus darf Zonen spaeter sichtbar machen.

Merksatz:

> Das Asset zeigt die Welt. Die Zonen erklaeren, was in dieser Welt erlaubt ist.

## 2a. Sichtbarkeit Von BuildZones

BuildZones sind ein Strukturmodell, nicht automatisch sichtbare Nutzer-UI.

Sichtbarkeitsregeln:

- Im normalen Weltmodus sind BuildZones unsichtbar oder sehr dezent.
- Bei Tap/Fokus darf eine Zone kurz hervorgehoben werden.
- Im Bau-/Aufgabenmodus darf sie deutlicher sichtbar sein.
- Im Debug-/Editor-Modus duerfen Zonen klar farbig sichtbar sein.
- Debug-Anzeige darf niemals normale Nutzer-UI sein.

Ziel:

Der Nutzer soll einen Bauplatz verstehen, aber nicht das Gefuehl bekommen, in
einem Editor mit technischen Flaechen zu arbeiten.

## 3. BuildZone-Typen

| Typ | Zweck | Erlaubte Objekte | Sichtbarer Zustand | Fruehe Nutzung | Spaetere Nutzung |
| --- | --- | --- | --- | --- | --- |
| `main_build_area` | zentraler erster Bauplatz | Haus, Huette, Bibliothek-Start, Werkstatt spaeter | leer, vorbereitet, Fundament, Gebaeude | erstes Fundament | Hauptgebaeude, Varianten |
| `secondary_build_area` | weitere Gebaeudeplaetze | Markt, Bibliothek, Werkstatt, Gartenhaus | meist unsichtbar bis Bauplanung | noch nicht dominant | Inselausbau, zweite Gebaeude |
| `nature_area` | natuerliche Bereiche | Baeume, Buesche, Garten, Teich, Felsen | Natur sichtbar, nicht immer tappbar | einfache Naturkulisse | Roden, Garten, Naturaufwertung |
| `decoration_area` | kleine Deko | Laternen, Blumen, Kristalle, Baenke, Schilder | unsichtbar oder dezenter Bauhinweis | kleine Deko spaeter | Besitzgefuehl, Cosmetics |
| `path_area` | Wege und Pfade | Wegstuecke, Stufen, Weglaternen | Pfadmarkierung oder unsichtbar | erster Weg/Lichtpunkt | Wege zwischen Gebaeuden |
| `water_area` | Wasserflaechen | Wasser, Quelle, Teich, Uferdeko | sichtbar als Wasser | blockiert Bau | Wasser-Features, Brueckennaehe |
| `blocked_area` | geschuetzte Flaechen | keine normalen Items | normalerweise unsichtbar | Kollision/Schutz | Klippen, Landmarken, Community-Sperren |
| `future_expansion_area` | vorbereitete Erweiterung | spaetere Zonen, Inselmodule | locked/preview | nicht nutzbar | neue Bauplaetze, Archipel |
| `interior_area` | Innenraum spaeter | Lernstationen, Deko, NPCs, Moebel | nur im Gebaeude-/Innenraum | nicht Phase 2E | Haus, Bibliothek, Markt, Werkstatt |

Regel:

Nicht jeder Inseltyp braucht jede Zone. Eine Starter-Insel kann wenige klare
Zonen haben. Community-Regionen koennen groessere, kuratierte Zonen haben.

## 4. BuildZone-Datenmodell

Zielmodell:

```text
BuildZone
  id
  islandId
  localPosition
  size
  shape
  allowedItemTypes[]
  locked
  requiredProgressionState optional
  priority
  visualHint optional
  debugColor optional
  placementRules[]
```

Felder:

| Feld | Bedeutung |
| --- | --- |
| `id` | stabile Zone-ID |
| `islandId` | Insel, zu der die Zone gehoert |
| `localPosition` | relative Position zur Insel oder logischen Bounding-Box |
| `size` | Radius, Breite/Hoehe oder Polygon-Extent |
| `shape` | `circle`, `rect`, `polygon` |
| `allowedItemTypes` | erlaubte Items, z. B. Haus, Markt, Baum, Weg |
| `locked/unlocked` | ob Zone aktuell nutzbar ist |
| `requiredProgressionState` | benoetigter Insel-/Gebaeudezustand |
| `priority` | Auswahl- und Validierungsprioritaet |
| `visualHint` | spaetere Bauplatz- oder Debug-Anzeige |
| `debugColor` | optionale interne Editor-Farbe |
| `placementRules` | Regeln fuer Snap, Overlap, Abstand, Besitz |

Wichtig:

- `localPosition` ist nicht die Bildschirmposition.
- `shape` muss zur logischen Zone passen, nicht zwingend zur sichtbaren
  Textur.
- `debugColor` ist nie Nutzer-UI.

## 4a. Zone, Slot Und Item Trennen

Talvori muss drei Ebenen unterscheiden:

| Ebene | Bedeutung |
| --- | --- |
| `BuildZone` | erlaubter Bereich, in dem grundsaetzlich gebaut werden darf |
| `ItemSlot` | konkreter Platz innerhalb einer Zone |
| `PlacedWorldItem` | tatsaechlich platziertes Objekt |

Ein Gebaeude entsteht spaeter nicht direkt auf der gesamten Zone, sondern auf
einem gueltigen Slot oder einer validierten Position innerhalb der Zone.

Warum diese Trennung wichtig ist:

- Eine grosse BuildZone kann mehrere spaetere Slots enthalten.
- Ein Slot kann Groesse, Rotation, Snap und Item-Typ genauer begrenzen.
- Ein PlacedWorldItem bleibt eine konkrete Instanz mit Level, Variante und
  Zustand.
- Diese Trennung verhindert Chaos bei spaeterem Ausbau.
- Sie macht Debug, Tests und spaetere Persistenz deutlich sicherer.

## 5. Bauphasen

| Phase | Bedeutung | Moegliche Weltgrafik | Lern-/Ressourcenanforderung | Sichtbarkeit | Darf noch nicht passieren |
| --- | --- | --- | --- | --- | --- |
| `empty` | Zone ist frei | natuerliche Flaeche, kein Bau | keine | sichtbar als freier Platz oder unsichtbar | kein Haus anzeigen |
| `prepared` / gerodet / geebnet | Zone wurde vorbereitet | geglaettete Flaeche, Markierung, Pfosten | kleiner Bauimpuls, Stein | frueh sichtbar | keine Waende |
| `foundation_started` | Fundament beginnt | erste Steinplatten, leichte Markierung | Stein/Bauimpuls | Phase 2E-Ziel | kein Rohbau |
| `foundation_complete` | Fundament fertig | vollstaendige Basis, stabiler Sockel | mehrere Steinimpulse | nach mehreren Aufgaben | kein fertiges Gebaeude |
| `frame_started` | Rohbau beginnt | erste Balken, Geruest | Holz, spaeter Wissen | nach Fundament | keine fertige Huette |
| `frame_complete` | Rohbau steht | Waende/Balken komplett | Holz/Struktur | spaeter | keine Level-2-Funktion |
| `building_level_1` | kleines Gebaeude nutzbar | einfache Huette/Haus/Bibliothek | Stein + Holz + Wissen | nach mehreren Sessions | kein voller Ausbau |
| `building_level_2` | ausgebautes Gebaeude | Fenster, Schild, Deko | Glas/Wissen/Licht | spaeter | keine Master-Version |
| `living_building` | Gebaeude lebt | Bewohner, Licht, kleine Bewegung | Dialog/Licht/Bewohner | spaeter | keine Social-Vollsysteme |
| `master_version` | Meister-Version | hochwertiger finaler Zustand | langfristige Ziele | langfristig | nicht Phase 2E |

Regeln:

- Eine Phase muss visuell lesbar sein.
- Keine Phase darf zu viele Systeme gleichzeitig einfuehren.
- Phase 2E endet maximal bei `foundation_started`.
- Bauphasen sind Weltzustand, nicht Renderer-Zufall.

## 6. Erstes Bauziel: Fundament

Ausgang:

- BuildZone ist leer.
- Zone ist `main_build_area`.
- Zone ist unlocked.
- Nutzer hat eine Starter-Insel gewaehlt oder der lokale Slice simuliert diese
  Situation.

Flow:

1. Nutzer tippt auf Zone.
2. Kontextkarte zeigt `Fundament beginnen`.
3. Aufgabe erzeugt Stein oder einen lokalen Bauimpuls.
4. Fundament bekommt Fortschritt.
5. Sichtbarer Zustand wechselt von `empty` zu `foundation_started`.

Moegliche Grafik:

- dezente Markierung,
- kleine Steinplatten,
- geglaettete Flaeche,
- kurzer Glow,
- kleine Staub-/Lichtwirkung spaeter.

Visuelle Definition von `foundation_started`:

- kleine Steinplatten,
- dezente Fundament-Markierung,
- leicht geglaettete Flaeche,
- kurzer Glow oder Staub-/Lichteffekt,
- klarer Unterschied zu `empty`.

Nicht erlaubt fuer `foundation_started`:

- fertiges Haus,
- komplette Waende,
- grosse UI-Markierung,
- Editor-Look,
- zu viel Animation.

Nicht erlaubt im ersten Fundament-Slice:

- kein Haus sofort fertig,
- keine Ressourcenueberladung,
- keine dauerhafte Wallet,
- keine echte Reward Bridge,
- keine SRS-/`word_progress`-Aenderung,
- keine Persistenz.

Ziel:

Der Nutzer sieht Baufortschritt, nicht Ressourcenverwaltung.

## 7. Gebaeudearten Und Fruehe Reihenfolge

Empfohlene Reihenfolge:

1. Erstes Haus / Huette.
2. Bibliothek.
3. Markt.
4. Weg oder Lichtpunkt.
5. Spaeter Bruecke.
6. Spaeter Werkstatt/Gartenhaus.

Warum nicht alles sofort:

- Das erste Haus erklaert Besitz und Start.
- Die Bibliothek erklaert Wissen, Saetze und Lernwert.
- Der Markt erklaert spaeter Muenzen, Austausch oder Kategorien.
- Weg/Lichtpunkt erklaert Weltstruktur und Orientierung.
- Bruecken brauchen DockingPoints und Connector-Regeln.
- Werkstatt/Gartenhaus brauchen mehr Ressourcen- und BuildZone-Reife.

Fruehe Phase:

- Fokus auf Haus/Huette und Fundament.
- Bibliothek kann vorbereitet sein, aber nicht zwingend im ersten Slice.
- Markt, Bruecke und Deko bleiben spaeter, damit UI und Balancing ruhig
  bleiben.

## 8. Platzierungsvalidierung

Eine Platzierung ist nur gueltig, wenn:

- Zone existiert.
- Zone ist unlocked.
- Item-Typ ist erlaubt.
- Zone ist nicht blocked.
- Keine Ueberlappung mit vorhandenen Items entsteht.
- Kein Bau auf Wasser, Felsen oder Klippe passiert.
- DockingPoints oder PathNodes werden nicht blockiert.
- Eigentuemer ist berechtigt.
- `progressionState` passt.
- Groesse und Shape des Items passen zur Zone.
- Optionaler Snap-Punkt ist gueltig.

Moegliches Ergebnis:

```text
PlacementValidationResult
  isValid
  reason
  targetZoneId
  correctedLocalPosition optional
  blockingObjectIds[]
```

Regeln:

- Ungueltige Platzierung wird nicht gerendert.
- Ungueltige Platzierung wird nicht persistiert.
- In fruehen Slices wird nur lokal/mock validiert.
- Debug darf erklaeren, warum eine Zone nicht nutzbar ist.

## 9. DecorationZones

DecorationZones dienen Besitzgefuehl und Atmosphaere.

Moegliche Objekte:

- Baeume,
- Blumen,
- Laternen,
- Kristalle,
- Baenke,
- Schilder,
- Zaune,
- kleine Kisten.

Regeln:

- Kleine Deko kann spaeter ohne starke Lernpflicht moeglich sein.
- Bedeutende Deko braucht Ressourcen.
- Deko darf BuildZones nicht blockieren.
- Deko darf DockingPoints, PathNodes und BlockedAreas nicht verletzen.
- Deko soll Besitzgefuehl staerken, aber Lernen nicht ersetzen.

Nicht Phase 2E:

- Kein Deko-System als Vollsystem.
- Maximal eine lokale `decoration_area` als semantische Vorbereitung.

## 10. NatureAreas

NatureAreas beschreiben natuerliche Flaechen.

Moegliche spaetere Aktionen:

- Baeume roden,
- Flaeche ebnen,
- Wasser/Teich freilegen,
- Garten anlegen,
- Natur aufwerten,
- Felsen als Landmarke behalten.

Regeln:

- Nicht alles ist bebaubar.
- Natur darf Bauzonen rahmen, statt komplett entfernt zu werden.
- Roden/Ebnen braucht klare Weltwirkung und spaeter passende Lern- oder
  Ressourcenlogik.
- Naturbereiche koennen DecorationZones enthalten, aber nicht automatisch
  Gebaeudezonen sein.

Phase 2E:

- NatureAreas koennen geplant werden.
- Sie muessen nicht interaktiv sein.

## 11. PathAreas Und PathNodes

Wege verbinden Bauzonen und Orientierungspunkte.

Regeln:

- Wege duerfen nicht frei gemalt werden.
- Wege entstehen entlang PathNodes oder innerhalb `path_area`.
- Ein Wegstueck kann frueh ein sichtbares Objekt sein.
- Wege duerfen nicht durch BlockedAreas laufen.
- Wege duerfen DockingPoints nicht blockieren.

Spaetere Verbindungen:

- Gebaeude zu Gebaeude,
- BuildZone zu Markt/Bibliothek,
- DockingPoint zu Bruecke,
- Community-Ort zu Platz,
- Bewohnerbewegung entlang PathNodes.

Phase 2E:

- Zwei PathNodes reichen als Vorbereitung.
- Kein vollstaendiges Wegsystem bauen.

## 12. BlockedAreas

BlockedAreas schuetzen Flaechen, die nicht bebaut werden duerfen.

Beispiele:

- Wasser,
- Felsen,
- Klippen,
- bestehende Landmarken,
- Community-Bereiche,
- fremde Eigentumsbereiche,
- Dockingnahe Schutzbereiche,
- Assetbereiche, die visuell keinen Bau tragen.

Regeln:

- Kein Fundament in BlockedAreas.
- Keine Deko, die BlockedAreas unplausibel ueberdeckt.
- Keine Wege durch geschuetzte Klippen oder Wasser, ausser es gibt definierte
  PathNodes/Brueckenregeln.
- Debug-Anzeige spaeter moeglich.

Phase 2E:

- Eine BlockedArea reicht, um Validierungslogik und Debug-Denken vorzubereiten.

## 13. Innenraeume Spaeter

Innenraeume sind nicht Phase 2E, aber architektonisch vorgesehen.

Moegliche Innenraeume:

- Haus-Innenraum,
- Bibliothek-Innenraum,
- Markt-Innenraum,
- Werkstatt-Innenraum.

Regeln:

- Innenraeume bekommen eigene `interior_area`.
- Innenraeume bekommen eigene BuildZones.
- Innenraeume koennen Lernstationen enthalten.
- Innenraeume koennen Deko und NPCs enthalten.
- Innenraeume duerfen nicht direkt an die Aussenwelt-Pixel gekoppelt sein.

Beispiele:

- Haus: persoenlicher Raum, Deko, Companion-Kommentar.
- Bibliothek: Satzaufgaben, Wissen, Regale, Satzfunken.
- Markt: Kategorien, kleine Dialoge, spaetere Organisationslogik.
- Werkstatt: Materialvarianten, Reparatur, Bauoptionen.

## 14. BuildZone Debug-/Editor-Modus

Debug ist standardmaessig aus.

Debug kann spaeter zeigen:

- BuildZones,
- BlockedAreas,
- PathNodes,
- DockingPoints,
- logicalBounds,
- PlacementValidationResult,
- Zonenprioritaeten.

Zweck:

- hilft beim Platzieren von Assets und Zonen,
- macht Validierungsfehler sichtbar,
- schuetzt gegen falsche Pixelplatzierung,
- ermoeglicht Tests fuer Zone/Item-Regeln.

Regeln:

- Keine Nutzer-UI.
- Keine Persistenz.
- Keine Supabase Writes.
- Keine Release-Artefakte.
- Nur lokal/mock, solange kein Editor-System geplant ist.

## 15. Erste Technische Slice-Empfehlung

Phase 2E:

- eine Starter-Insel,
- eine `main_build_area`,
- eine `blocked_area` als nicht sichtbare Validierungsvorbereitung,
- eine `decoration_area` als nicht sichtbare Architekturvorbereitung,
- zwei PathNodes als nicht sichtbare Architekturvorbereitung,
- Kontextkarte `Fundament beginnen`,
- lokaler Mock-State,
- sichtbarer Zustand: `empty` -> `foundation_started`,
- keine Persistenz,
- keine Reward Bridge,
- keine SRS-/`word_progress`-Aenderung.

Empfohlene Zielinsel:

- Waldlichtung.

Begruendung:

- ruhiges Biom,
- klarer Start,
- natuerlicher Bauplatz,
- wenig Ablenkung.

Ackerfeld und Felseninsel folgen spaeter als Vergleichsinseln. Sie sind wichtig,
aber nicht noetig fuer den ersten BuildZone-/Fundament-Slice.

### V1-/Phase-2E-Reduktion

Phase 2E nutzt nur:

- eine Starter-Insel,
- eine sichtbare/interaktive `main_build_area`,
- den Zustand `empty` -> `foundation_started`.

`blocked_area`, `decoration_area` und PathNodes duerfen nur unsichtbar als
Architektur- oder Validierungsvorbereitung existieren. Sie erzeugen im ersten
Slice keine Deko, keine Wege und keine zusaetzliche Nutzerinteraktion.

Nicht Teil von Phase 2E:

- keine Gebaeudeauswahl,
- keine Deko-Platzierung,
- keine Wege-Logik,
- keine Innenraeume,
- keine Connectoren,
- keine Persistenz,
- keine Reward Bridge,
- kein SRS-/`word_progress`-Eingriff.

Minimaler Ablauf:

1. Nutzer tippt auf `main_build_area`.
2. Validierung prueft: Zone existiert, unlocked, nicht blocked.
3. Kontextkarte zeigt `Fundament beginnen`.
4. Lokale Mock-Aufgabe liefert Bauimpuls.
5. Zone wechselt auf `foundation_started`.
6. Debug bleibt aus.

Nicht Teil von Phase 2E:

- kein Gebaeude-Level-1 als fertiges System,
- keine Deko-Platzierung als Vollsystem,
- keine Bruecken/Connectoren,
- keine Innenraeume,
- keine Persistenz.

## 16. Querschnittspruefung

Jeder spaetere Build-/Zonen-Slice muss pruefen:

- Lernwert: Welche Aufgabe oder Lernart ist beteiligt?
- Weltwirkung: Welche sichtbare Phase aendert sich?
- Ressourcen/Balancing: Welche Ressource oder welcher Bauimpuls ist betroffen?
- UI-Komplexitaet: Wird die Welt zu editorartig?
- Performance: Wie viele Zonen/Items werden gerendert oder geprueft?
- Renderer-Unabhaengigkeit: Bleibt die Logik ausserhalb des Flutter-Renderers?
- SRS-/`word_progress`-Schutz: Bleiben bestehende Lernsemantiken unangetastet?
- Spaetere Cloud/Persistenz: Welche Daten waeren spaeter authoritative?
- Testbarkeit: Welche Validierungsregeln koennen getestet werden?

## 17. Risiken

Risiken:

- zu viele sichtbare Zonen,
- UI wirkt wie Editor,
- Bau wirkt zu technisch,
- Objekte ueberlappen,
- zu viel Deko ohne Lernen,
- zu harte Baukosten,
- Renderer und Weltlogik vermischen sich,
- Insel-Asset passt nicht zu Zonen,
- Debug-Marker gelangen in Nutzer-UI,
- BlockedAreas werden vergessen,
- PathNodes werden durch Bauobjekte blockiert,
- spaetere Persistenz speichert ungueltige Platzierungen.

Fruehes Warnsignal:

Wenn der Nutzer mehr ueber Zonen als ueber seine Insel nachdenkt, ist die UI zu
technisch.

## 18. Akzeptanzkriterien

Dieses Dokument ist gut, wenn:

- klar ist, was BuildZones sind,
- klar ist, wie ein Fundament beginnt,
- klar ist, wo Gebaeude, Deko, Wege und Natur entstehen duerfen,
- Platzierungsvalidierung definiert ist,
- Innenraeume spaeter beruecksichtigt sind,
- Debug-/Editor-Modus nur intern geplant ist,
- ein kleiner Phase-2E-Slice ableitbar ist,
- Phase 2E auf Waldlichtung, eine `main_build_area` und
  `foundation_started` begrenzt ist,
- BuildZones im normalen Modus nicht wie Debug-Editorflaechen wirken,
- `foundation_started` visuell klar, aber klein bleibt,
- Zone, Slot und Item konzeptionell getrennt sind,
- keine Reward Bridge, Persistenz oder SRS-/`word_progress`-Aenderung
  vorweggenommen wird.

Offene Fragen:

- Wie werden Ackerfeld und Felseninsel spaeter als Vergleichsinseln zoniert?
- Welche sichtbare Form hat `foundation_started` auf dem bestehenden Asset?
- Soll die erste BuildZone im normalen Modus sichtbar sein oder erst nach Tap?
- Wie werden `logicalBounds` und Zonen spaeter aus Assetgroessen abgeleitet?
- Welche Zonen muessen fuer Portrait/Landscape separat getestet werden?
