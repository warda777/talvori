# Talvori Welt: Multi-Scale World And Interior System

Stand: 2026-06-04

Dieses Dokument definiert Phase 2E-A3: die Multi-Scale-Architektur fuer
Talvori Welt. Es klaert, wie Talvori von Weltansicht zu Inselansicht,
Bauplatzansicht, Gebaeudeansicht, Innenraumansicht und Objekt-Detailansicht
wechselt.

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
- `docs/world_design/236-buildable-forest-clearing-template-concept.md`
- `docs/world_design/237-buildable-forest-clearing-greybox-layout.md`
- `docs/221-talvori-world-build-and-expansion-architecture.md`
- `docs/222-talvori-world-game-system-master-plan.md`

## 1. Zweck Des Dokuments

Dieses Dokument klaert die Multi-Scale-Architektur von Talvori Welt.

Es verhindert, dass Inseln, Gebaeude und Objekte als ein einziges zoombares Bild
missverstanden werden.

Es legt fest:

- Detailstufen brauchen eigene Assets, Slots, Zustaende und Lernlogik.
- Ein Insel-PNG darf nicht alle spaeteren Bau-, Innenraum- und
  Objekt-Details tragen.
- Detailansichten sind eigene Spaces/Views, nicht nur staerkerer Zoom.
- Asset-Produktion bleibt blockiert, wenn die benoetigte Detailstufe nicht
  bekannt ist.

## 2. Research-Ergebnis: Wie Profis Vorgehen

Das Professional Game Development Research Gate wurde fuer diesen Schritt
angewendet.

| Quelle / Orientierung | Ableitung fuer Talvori | Konkrete Entscheidung |
| --- | --- | --- |
| Unity Manual: LOD Group. LOD reduziert Detail abhaengig von Kamera-/Screen-Groesse. Quelle: `https://docs.unity.cn/Manual/class-LODGroup.html` | Professionelle Systeme zeigen je Entfernung nicht dasselbe Asset mit gleicher Detailtiefe. | Talvori unterscheidet World-, Island-, BuildArea-, Building- und Interior-Details. |
| Unity Manual: Multi-Scene Editing. Szenen koennen als eigenstaendige Level/Umgebungen additiv verwaltet werden. Quelle: `https://docs.unity.cn/2020.2/Documentation/Manual/MultiSceneEditing.html` | Grosse Welten werden in handhabbare Teilraeume zerlegt, statt alles in einem Raum zu halten. | Talvori plant getrennte Spaces/Views mit klaren Entry-/Exit-Punkten. |
| Unreal Engine: Level Streaming. Map-Dateien werden geladen/entladen, damit nur relevante Weltteile Ressourcen verbrauchen. Quelle: `https://dev.epicgames.com/documentation/en-us/unreal-engine/level-streaming-in-unreal-engine` | Detail muss bedarfsgerecht geladen werden. Innenraeume und Objektansichten gehoeren nicht in die World View. | Talvori laedt spaeter nur aktuelle oder relevante Detailstufen. |
| Unity Addressables: Assets koennen per Adresse, Label oder Referenz asynchron geladen werden. Quelle: `https://docs.unity.cn/Packages/com.unity.addressables%401.18/manual/LoadingAddressableAssets.html` | Eine Asset-Pipeline braucht Adressen, Gruppen, Abhaengigkeiten und spaeter optional Remote-/Cache-Strategien. | Talvori trennt Asset-Gruppen fuer Insel, BuildArea, Gebaeude, Innenraum und Objekt. |
| Android Screen Compatibility Overview. Mobile Apps muessen unterschiedliche Bildschirmgroessen, Dichten, Orientierungen und Fensterkonfigurationen beruecksichtigen. Quelle: `https://developer.android.google.cn/guide/practices/screens_support?hl=en` | Ein stark vergroessertes Einzelbild wird auf mobilen Geraeten schnell unscharf, unlesbar oder UI-konfliktig. | Talvori nutzt eigene Detailansichten mit reduzierter UI statt extremem Zoom. |
| Godot Docs: Instancing. Projekte koennen in wiederverwendbare Szenen zerlegt werden. Quelle: `https://docs.godotengine.org/en/3.0/getting_started/step_by_step/instancing.html` | Wiederverwendbare Raeume und Objekte sind ein bewaehrtes Muster fuer modulare Inhalte. | Talvori denkt Raeume, Kategoriegebaeude und Objekt-Details templatebasiert. |

Kurzfassung:

Professionelle Spiele loesen grosse, detaillierte Welten nicht ueber ein
einziges Bild. Sie trennen Uebersicht, Detail, Innenraeume, Objektzustand,
Asset-Varianten, Ladeverhalten und Interaktion.

Ableitung fuer Talvori:

Talvori nutzt nicht "ein Bild endlos reinzoomen", sondern getrennte
Detailstufen mit eigenen Assets, Slots, Zustaenden, Lernbindungen und
Kamera-/UI-Regeln.

## 3. Grundentscheidung

Talvori Welt besteht aus mehreren Detailstufen:

- World View
- Island View
- Build Area View
- Building Exterior View
- Building Interior View
- Object Detail View

Jede Stufe hat:

- eigene Assets,
- eigene Slots/Zonen,
- eigene Interaktionen,
- eigene Lernaufgaben,
- eigene Kamera-/UI-Regeln,
- eigene Performance-Regeln.

Regel:

Eine Detailstufe darf Details der darunterliegenden Stufe andeuten, aber nicht
deren komplette Logik tragen.

## 4. Detailstufe 1: World View

Zweck:

- Ueberblick ueber mehrere Inseln und Community-Regionen.
- Orientierung in der Talvori-Welt.
- Auswahl, Besuche, Freunde, Community-Gefuehl.

Eigenschaften:

- stark verkleinerte Insel-/Regionsassets,
- keine Bau-Details,
- keine Innenraeume,
- keine kleinen Objektzustaende,
- keine kleinteilige Deko-Interaktion.

Interaktionen:

- Insel antippen,
- Community-Region ansehen,
- "Meine Insel" fokussieren,
- Freunde/Showcase spaeter besuchen.

Nicht in der World View:

- Interior-Slots,
- einzelne Moebel,
- einzelne Baufortschrittsdetails,
- Objekt-Inspektion,
- vollstaendige Lernaufgaben im Raum.

## 5. Detailstufe 2: Island View

Zweck:

- Eigene Insel als Ganzes sehen.
- Besitz, Inselwachstum und Bauziele verstehen.
- BuildZones und Erweiterungen als Weltbestandteil lesen.

Eigenschaften:

- Insel-Asset in hoeherer Detailstufe als World View.
- Bauflächen sichtbar oder antippbar, aber nicht als Debug-Flaechen.
- Land-Erweiterungen sichtbar.
- Docking-/Connector-Ansaetze spaeter sichtbar.
- Gebaeude als Aussenobjekte sichtbar.

Nicht in der Island View:

- Innenraum-Details,
- einzelne Moebel-Slots,
- Objekt-Innenansichten,
- zu viele Ressourcen- oder Editorinformationen.

## 6. Detailstufe 3: Build Area View

Zweck:

- Fokus auf Bauplatz oder BuildZone.
- Erste Bauwirkung klar zeigen.
- Aufgabenkarte und Weltwirkung direkt verbinden.

Ausloeser:

- Nutzer tippt auf Baufläche oder Bauplatz.

Regeln:

- Kamera geht naeher an den Bauplatz.
- Das ist nicht nur Pixel-Zoom auf ein All-in-one-PNG.
- Eine eigene Bauplatz-Komposition oder ein passendes Overlay darf genutzt
  werden.
- Fundament, Rohbau oder kleiner Baufortschritt werden klarer sichtbar.
- UI zeigt nur das aktuelle Bauziel.

Beispiel:

`foundation_started` wird in der Build Area View deutlicher gelesen als in der
World View. Die Island View kann denselben Zustand kleiner zeigen.

## 7. Detailstufe 4: Building Exterior View

Zweck:

- Gebaeude von aussen als eigenes Fortschrittsobjekt behandeln.
- Weitere Ausbaustufen und Gebaeudeteile freischalten.

Ausloeser:

- Tap auf fertiges oder teilfertiges Gebaeude.

Moegliche Exterior-Slots:

- Fundament,
- Waende,
- Dach,
- Fenster,
- Schild,
- Eingang,
- kleine Aussen-Deko,
- Licht/Energieeffekt.

Lernwirkung:

- Lernaufgaben koennen Gebaeudeteile freischalten.
- Satzverstaendnis koennte Fenster/Schilder staerken.
- Aussprache/Hoeren koennte Licht/Energie aktivieren.
- Dialoge koennten Bewohner/Leben freischalten.

Beispiel:

Ein Haus waechst von Fundament zu Huette zu Haus. Die Aussenansicht zeigt
Makroprogression und Besitzgefuehl.

## 8. Detailstufe 5: Building Interior View

Zweck:

- Innenraum als eigene Szene/Ansicht oeffnen.
- Detailliertes Wort-/Objektlernen kontrolliert vertiefen.

Grundregel:

Ein Innenraum ist nicht nur Zoom auf das Inselbild. Er ist ein eigener
`InteriorSpace` mit eigenen Assets, Slots, Zustaenden und Lernbindungen.

Moegliche InteriorSlots:

- Tisch,
- Stuhl,
- Tasse,
- Regal,
- Fenster,
- Tuer,
- Lampe,
- Teppich.

Beispiele:

- Wort "Tisch" gelernt -> Tisch erscheint.
- Wort "Stuhl" gelernt -> Stuhl erscheint.
- Wort "Tasse" gelernt -> Tasse erscheint.
- Satzaufgabe geschafft -> Regal oder Fenster leuchtet.

Regeln:

- Deko und Lernobjekte entstehen nur ueber Slots.
- Keine freie Pixelplatzierung.
- Nicht jeder Innenraum zeigt alle Slots sofort.
- Innenraeume werden erst freigeschaltet, wenn das Gebaeude ausreichend fertig
  ist.

## 9. Detailstufe 6: Object Detail View

Zweck:

- Groessere oder lernstarke Objekte inspectierbar machen.
- Objektvokabular ohne Ueberladung des Innenraums vertiefen.

Beispiel Auto:

- Aussenansicht Auto.
- Innenansicht Auto.
- Frontscheibe, Lenkrad, Sitz, Tuer, Spiegel als Slots.

Beispiel Haus:

- Aussen gebaut.
- Innen dekoriert/gelernt.
- Einzelne groessere Moebel oder Lernobjekte koennen eine eigene Detailansicht
  bekommen.

Regeln:

- Nicht jedes Objekt braucht eine Detail View.
- Nur groessere, category-relevante oder lernstarke Objekte bekommen diese
  Stufe.
- Object Detail Views brauchen ein Slot-System.
- Keine Objekt-Detailansicht ohne klaren Exit-Pfad.

## 10. Aussenbau Und Innenausbau

Aussenbau:

- Gebaeude wird zuerst aussen gebaut.
- Aussenbau zeigt Besitz, Inselprogression und sichtbaren Fortschritt.
- Aussen = Makroprogression.

Innenausbau:

- Innenraum wird erst freigeschaltet, wenn das Gebaeude ausreichend fertig ist.
- Innenraum vertieft Wort-/Objektlernen.
- Innen = detailliertes Vokabel- und Kategorie-Lernen.

Konsequenz:

Ein Gebaeude braucht zwei Denkebenen:

- ExteriorTemplate fuer sichtbaren Weltfortschritt.
- InteriorTemplate fuer spaetere Lernraeume und Objekt-Slots.

## 11. Kategorien Und Detailstufen

Talvori muss beliebige Lernkategorien tragen koennen.

Beispiele:

- Reisen: Hotel, Bahnhof, Flughafen, Koffer, Ticket, Auto.
- Gesundheit: Praxis, Apotheke, Koerperteile, Medizinobjekte.
- Essen: Kueche, Restaurant, Tisch, Teller, Tasse.
- Business: Buero, Schreibtisch, Laptop, Meetingraum.
- Schule: Klassenzimmer, Tafel, Buecher, Stifte.

Regeln:

- Kategorien sind Templates.
- Raeume und Objekte sind Templates.
- Keine Kategorie wird hart codiert.
- Gebaeude und Innenraeume muessen Kategorievarianten tragen koennen.
- Kategoriekompatibilitaet gehoert in Metadaten, nicht in Widget-Sonderlogik.

## 12. Asset-Struktur

Moegliche Struktur:

```text
assets/images/world/buildable_islands/forest_clearing/
  island/base.png
  island/foundation_started.png
  island/land_expansion_se.png
  build_areas/main_build_area_empty.png
  buildings/house/exterior_level_1.png
  buildings/house/interior_empty.png
  buildings/house/interior_table.png
  objects/car/exterior.png
  objects/car/interior_empty.png
  objects/car/interior_windshield.png
  template.md
```

Diese Struktur ist ein Vorschlag. Ziel ist, Asset-Gruppen logisch zu trennen:

- `island/` fuer Insel- und Landzustand.
- `build_areas/` fuer Bauplatz-nahe Darstellungen.
- `buildings/` fuer Exterior/Interior pro Gebaeudetyp.
- `objects/` fuer inspectierbare Objekt-Details.
- `template.md` fuer Metadaten, Status und Decision Log.

Phase 2E nutzt weiterhin die einfachere aktuelle Zielstruktur aus `236`:

```text
assets/images/world/buildable_islands/forest_clearing/base.png
assets/images/world/buildable_islands/forest_clearing/foundation_started.png
assets/images/world/buildable_islands/forest_clearing/template.md
```

Die tiefere Struktur wird erst relevant, wenn mehrere Detailstufen real
produziert werden.

## 13. Datenmodell

Grobe Spaces:

- `WorldSpace`
- `IslandSpace`
- `BuildAreaSpace`
- `BuildingSpace`
- `InteriorSpace`
- `ObjectDetailSpace`

Jeder Space braucht:

- `id`
- `parentId`
- `assetPath`
- `slots`
- `unlockedState`
- `progressionState`
- `learningBindings` optional
- `categoryCompatibility`
- `cameraMode`
- `entryPoints`
- `exitTarget`

Regel:

Ein Space referenziert seinen Parent, aber kopiert nicht dessen ganze Logik.
Das verhindert, dass Innenraumlogik in Insel-Widgets oder Objektlogik in
Gebaeude-Overlays wandert.

## 14. Navigation Zwischen Detailstufen

Navigation:

- World -> Island durch Insel-Tap.
- Island -> BuildArea durch Bauplatz-Tap.
- Island -> BuildingExterior durch Gebaeude-Tap.
- BuildingExterior -> Interior durch Eingang/Innenraum-Tap.
- Interior -> ObjectDetail durch Objekt-Tap.
- Zurueck immer ueber klaren Zurueck-Pfad.

Regeln:

- Keine Sackgassen.
- Jede Detailstufe kennt ihren Exit.
- Companion-Hinweise duerfen Navigation vorschlagen, aber nicht erzwingen.
- Detailstufen duerfen nur freigeschaltet werden, wenn ihr Parent-State passt.

## 15. Kamera Und UI

Kamera-Regeln:

- Nicht extrem in ein Asset zoomen.
- Fuer Detailansichten eigene Assets/Szenen verwenden.
- Kamera-Fokus ist Kontextnavigation, kein Ersatz fuer fehlende Assetqualitaet.

UI-Regeln:

- UI bleibt je Detailstufe reduziert.
- World View zeigt andere Informationen als Interior View.
- Bauplatzansicht darf mehr Baukontext zeigen.
- Innenraumansicht darf Objekt-/Vokabelkontext zeigen.
- Der Nutzer muss immer wissen, wo er ist und wie er zurueckkommt.

Beispiele:

- World View: Inselwahl, Freunde, Community.
- Island View: Bauziele, BuildZones, Besitz.
- Build Area View: aktuelles Fundament/Bauziel.
- Interior View: Objektwort, Kategorie, kleine Lernaufgabe.

## 16. Performance Und Mobile

Regeln:

- Nur aktuelle Detailstufe laden.
- Vorschau-Assets fuer Uebersicht verwenden.
- Detail-Assets erst bei Eintritt laden.
- Innenraeume nicht in World View rendern.
- Object Detail Views nur bei Bedarf laden.
- Cache ist moeglich, aber spaeter zu planen.
- Keine riesigen All-in-one-Bilder.

Mobile-Konsequenz:

Portrait, Landscape, kleine Phones, Tablets und spaetere Desktop-/Web-Formate
brauchen unterschiedliche UI-Dichte. Multi-Scale reduziert die Versuchung, mit
einem einzigen Bild alle Viewports zu bedienen.

## 17. Phase-2E-Konsequenz

Der naechste Waldlichtung-Base-Asset-Prompt darf nicht versuchen, alle spaeteren
Detailstufen in ein einzelnes Bild zu packen.

Fuer Phase 2E reicht:

- Island View base,
- `main_build_area`,
- expansion-ready edges,
- docking candidates,
- spaeter `foundation_started` overlay.

Architektonisch vorbereitet, aber jetzt nicht produziert:

- Gebaeude-Innenraeume,
- Auto-Innenraeume,
- Objekt-Detail-Views,
- Kategorie-Innenraeume,
- mehrere Gebaeude-Exterior-Stufen.

Regel:

Phase 2E bleibt klein. Die Waldlichtung muss ausbaubar wirken, aber nicht alle
spaeteren Detailraeume sichtbar zeigen.

## 18. Beziehung Zu `237`

`237` beschreibt das Greybox/Layout der Waldlichtung auf Island-/BuildArea-
Ebene.

`238` ergaenzt:

- spaetere Detailstufen brauchen eigene Spaces/Views,
- ein einzelnes Waldlichtung-PNG darf nicht die gesamte spaetere Bau- und
  Innenraumlogik tragen,
- Innenraeume und Objekt-Details werden nicht durch staerkeren Zoom geloest.

Konsequenz:

Der Base-Prompt aus `237` muss Erweiterung, Docking und Bauplatz vorbereiten,
aber keine Innenraeume oder Objekt-Detailansichten abbilden.

## 19. Update Von `235`

`docs/world_design/235-world-production-roadmap-and-checklists.md` wird minimal
aktualisiert:

- Phase 2E-A3 wird in der Roadmap sichtbar.
- Status nach Erstellung dieses Dokuments: `fertig`.
- Naechster erlaubter Schritt bleibt: Base-Prompt ueberarbeiten / Phase 2E-B
  erneut.
- Code bleibt blockiert.

## 20. Stop-Regeln

Stoppen, wenn:

- Codex versucht, alle Detailstufen in ein einziges Asset zu pressen,
- Innenraeume als Zoom auf Inselbild geplant werden,
- Kategorien hart codiert werden,
- Gebaeude ohne spaetere Interior-Slots geplant werden,
- Object Detail Views ohne Slot-System geplant werden,
- Code geschrieben wird,
- Assets erzeugt werden.

Stoppen bedeutet:

- Blocker benennen,
- Detailstufe klaeren,
- ggf. auf Planungs- oder Asset-Pipeline-Schritt zurueckgehen.

## 21. Akzeptanzkriterien

Dieses Dokument ist gut, wenn:

- klar ist, dass Talvori mehrere Detailstufen braucht,
- klar ist, warum nicht endlos in ein PNG gezoomt wird,
- Gebaeude und Innenraeume getrennt geplant sind,
- Objekt-Detailansichten wie Auto/Innenraum beruecksichtigt sind,
- Kategorie-Erweiterbarkeit beruecksichtigt ist,
- Asset- und Datenmodell grob ableitbar sind,
- Phase 2E weiterhin klein bleibt,
- Code weiterhin blockiert bleibt.

## Offene Fragen

- Ab wann braucht ein Gebaeude eine eigene Exterior View statt nur Island View?
- Welche Gebaeude bekommen zuerst Interior Spaces?
- Welche Objektarten sind lernstark genug fuer Object Detail Views?
- Wie werden InteriorSlots spaeter als Templates versioniert?
- Welche Detailstufen muessen vor Cloud/Persistenz lokal mockbar sein?
