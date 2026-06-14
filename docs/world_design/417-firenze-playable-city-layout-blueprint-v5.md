# 417: Firenze Playable City Layout Blueprint v5

Stand: 2026-06-14

Status: `documentation_only` / `planning_blueprint` / `not_runtime_data` /
`not_asset` / `not_engine_ready` / `no_yaml_json` / `no_app_integration`

## 1. Ziel

Dieses Dokument ist die fuehrende Firenze-Blueprint-Fassung.

Ziel:

- Firenze als erste konkrete City-Greybox-Flaeche nach `416` planen.
- Den v4-Zwischenstand durch eine groessere, raeumlich entspanntere und
  landmark-aware v5-Fassung ersetzen.
- Die visuelle Zielrichtung aus dem bereitgestellten v5-Bild konzeptionell
  uebernehmen, ohne es pixelgenau zu kopieren.
- Eine lesbare Florenz-orientierte Infrastrukturplanung mit Boundary, Arno,
  Bruecken, organischen Wegen, Vegetationspuffern, Parcels, Subflaechen,
  fuenf Landmark-Ankern, Depth-/Sorting-Bands, No-Walk/No-Build, Anchors und
  Reachability-Review festhalten.

Nicht-Ziele:

- keine App-City-Entry-Preview,
- kein Flutter-/Dart-Code,
- keine Runtime-Daten,
- keine finalen Koordinaten,
- keine produktiven Polygone,
- keine YAML-/JSON-/YML-Dateien,
- keine Assets,
- keine Dateien unter `assets/`,
- keine App-Integration,
- keine Route,
- keine Persistenz,
- kein BuildState,
- kein Commit.

## 2. Warum v5 v4 ersetzt

v4 war ein Fortschritt gegenueber v3, aber noch nicht ausreichend:

- die Gesamtflaeche wirkte weiterhin zu klein,
- mehrere Parcels fuehlten sich noch zu gedrungen an,
- die Vegetationspuffer waren sichtbar, aber noch nicht raumstiftend genug,
- Florenz-Identitaetsanker fehlten noch als explizite Landmark-Struktur,
- die spaetere Laufbarkeit brauchte mehr Luft zwischen Wegen, Parcels und
  Boundary.

v5 ersetzt v4, weil es sichtbar einplant:

- eine deutlich groessere Florence-shaped Ground Shape,
- 14 Parcels mit viel Abstand und klaren Vegetationspuffern,
- organische `PATH-N`- und `PATH-S`-Hauptwege,
- kurze Branch Paths zu jedem Parcel,
- Arno-Querungen ausschliesslich ueber `B1`, `B2` und `B3`,
- fuenf Landmark-Anker fuer die Florenz-Identitaet,
- klarere No-Overlap-, Reachability- und Landmark-QA.

Das v5-Visual ist eine eigene Dokumentationsvisualisierung. Es ist kein
Runtime-Polygon, kein Asset und kein App-Screen.

## 3. Eingangsgrundlagen

| Grundlage | Verwendung |
| --- | --- |
| `410-italy-city-footprints-istat-comuni-gate.md` | ISTAT Comuni 2026, `COMUNE=Firenze`, `PRO_COM_T=048017`, Source-Kontext. |
| `411-italy-playable-city-areas-from-footprints.md` | Firenze als abstrahierter `playable_city_area`-Kandidat mit Kulturkern, Reserve, Rand/No-Build und Startidee. |
| `412-italy-playable-city-area-review-and-first-city-decision.md` | Firenze als erste Stadt-Greybox; Roma und Bologna bleiben Reserve. |
| `415-firenze-playable-city-ground-layer-and-anchors-gate.md` | Stoppt freie City-Entry-WIP und fordert Ground-/Layer-/Anchor-Familien. |
| `416-talvori-playable-area-specification-standard-v1.md` | Fuehrender Area-Spec-Standard mit Area Layout Blueprint, Parcel-Struktur, Path Network, Reachability, Collision und Visual-QA. |

## 4. Firenze City Ground Shape v5

Die v5-Ground-Shape ist eine dokumentierte Abstraktion, kein Runtime-Polygon.

Pflichtmerkmale:

- keine runde Form,
- keine generische Insel,
- deutlich groessere, breitere Westseite Richtung Novoli/Scandicci,
- kompakter, aber nicht gedrungener Kern,
- ausgepraegtere noerdliche Ausbuchtungen Richtung Careggi/Fiesole,
- laengerer oestlicher Arm,
- suedliche Huegelkante mit mehr Gruenraum,
- zentraler Arno-Korridor,
- alle Parcel Candidates liegen vollstaendig innerhalb der Boundary,
- alle Parcels haben sichtbaren Abstand zur Boundary, zum Arno und zu
  Bridge Decks.

Abstraktionsgrund:

- Der echte Comune-Footprint ist fuer Mobile/Greybox zu detailreich.
- v5 schuetzt die wiedererkennbare Florenz-Struktur, ohne GIS-/Atlas-Look zu
  werden.
- Der Arno ist eine Movement- und No-Build-Struktur, keine Dekoration.
- Landmark-Anker geben Florenz Identitaet, ohne echte Atlas- oder
  Unterrichtskartenlogik zu erzwingen.

## 5. Parcel Count

Firenze v5 plant konkret:

| Familie | Anzahl | Status |
| --- | --- | --- |
| `buildable_parcel_candidates` gesamt | 14 | planning only |
| `early_use_candidates` | 7 | candidate_only |
| `reserve_or_expansion_candidates` | 4 | candidate_only |
| `special_or_landmark_adjacent_candidates` | 3 | candidate_only |

Die Anzahl ist Planung, kein BuildState, keine Persistenz und keine
Freischaltlogik.

## 6. Parcel-Familien in v5

V5 uebernimmt die im Zielbild erkennbare Verteilung: Early-Parcels liegen als
primaere Route entlang der gut angebundenen Nord-/Sued-Spines, Reserve-Parcels
liegen in freieren West-/Suedraeumen, und Special-Parcels liegen naeher an
Landmark- und East-Arm-Strukturen.

| Parcel | Familie | Rolle | Sichtbarkeit |
| --- | --- | --- | --- |
| P01 | early | `start_home_parcel` | visible_now |
| P02 | early | `garden_learning_parcel` | visible_now |
| P03 | early | `archive_workshop_parcel` | visible_now |
| P04 | early | `market_plaza_parcel` | visible_now |
| P05 | early | `east_arm_use_parcel` | visible_now |
| P06 | reserve | `west_river_reserve_parcel` | reserve_only |
| P07 | reserve | `southwest_quiet_reserve_parcel` | reserve_only |
| P08 | reserve | `hill_reserve_parcel` | reserve_only |
| P09 | early | `bridge_craft_parcel` | visible_now |
| P10 | reserve | `later_expansion_parcel` | reserve_only |
| P11 | early | `river_edge_practice_parcel` | visible_now |
| P12 | special | `culture_landmark_support_parcel` | visible_now |
| P13 | special | `bridge_support_parcel` | visible_now |
| P14 | special | `east_landmark_support_parcel` | visible_now |

## 7. Parcel Internal Structure

Jedes der 14 Parcels zeigt im Visual:

- Parcel-ID `P01` bis `P14`,
- `main_building_zone`,
- `secondary_zone`,
- `garden_or_open_zone`,
- `access_point`,
- kurzen Branch Path zum naechsten Haupt- oder Connector Path,
- `status: candidate_only`.

Regeln:

- Kein Parcel ist ein fertiger Bauplatz.
- Keine Subzone erzeugt automatisch ein Gebaeude.
- Alle Subzonen bleiben Planung, nicht Runtime-Placement.
- Paths duerfen Parcel-Subflaechen nicht verdecken.
- Access Points sitzen lesbar am Parcel-Rand.

## 8. Landmark-Anker

V5 fuehrt fuenf Florenz-Identitaetsanker ein. Sie sind Identity-/Review-Anker,
keine finalen Runtime-Positionen.

| Anchor | Landmark | Zweck |
| --- | --- | --- |
| L1 | Duomo / Santa Maria del Fiore | Kulturkern, visuelle Stadtidentitaet, Camera-Focus-Kandidat |
| L2 | Ponte Vecchio | Arno-/Bridge-Identitaet, zentraler Querungsbezug |
| L3 | Palazzo Vecchio / Piazza della Signoria | Civic Square, Kultur-/Quest-Kontext |
| L4 | Uffizi / art district | Art-/Archiv-/Lernort-Kontext |
| L5 | Boboli / Pitti / south gardens-hills | Suedlicher Garten-/Huegelanker, Reserve-/Naturkontext |

Regeln:

- Landmark-Anker schuetzen Identitaet, ersetzen aber keine echte Stadtkarte.
- Landmark-Core bleibt `protected` und `no_build`.
- Landmark-Bands sind Sort-/Identity-Kontext, keine Runtime-Sortierung.
- Parcels duerfen landmark-adjacent sein, aber nicht in Landmark-Kernen liegen.

## 9. Vegetation und Freiraum

V5 macht Vegetation und Freiraum zu sichtbaren Spacing-Elementen:

- dichte Vegetationspuffer zwischen Parcels,
- mehr Gruenraum um Reserve-Parcels,
- staerkere Hill-Edge-Gruenstruktur im Sueden,
- gruene Korridore zwischen Branch Paths,
- Arno-Uferpuffer als No-Build-Kontext,
- Wald-/Parkfelder um L5 Boboli/Pitti und die suedlichen Huegel.

Vegetation ist Deko-/Terrain-/Spacing-Kontext, keine Build-Freigabe. Sie darf
Wege, Access Points, Bridge Connections und Reachability nicht blockieren.

## 10. Path Network

V5 plant alle Wege als organische Infrastruktur:

| Layer | Regel |
| --- | --- |
| `PATH-N` | noerdlicher organischer Hauptweg, walkable, no_build |
| `PATH-S` | suedlicher organischer Hauptweg, walkable, no_build |
| `B1`, `B2`, `B3` | einzige Arno-Querungen, bridge deck walkable, no_build |
| Connector Paths | verbinden `PATH-N` und `PATH-S` nur ueber B1-B3 |
| Branch Paths | kurze, klare Zugangswege zu jedem Parcel |
| Future Paths | gestrichelt, geplant, nicht aktuell walkable |
| Landmark Paths | binden L1-L5 semantisch an Hauptwege an |

Regeln:

- Kein Pfad darf den Arno ohne B1/B2/B3 kreuzen.
- Future Paths sind nicht aktuell walkable.
- Keine isolierten Parcels.
- Branch Paths duerfen nicht als freie spaetere Erfindung entstehen.
- Wege muessen zwischen Parcels genug Luft lassen.

## 11. Blocked Layers und Depth / Sorting

V5 zeigt weiterhin getrennt:

| Layer | Status |
| --- | --- |
| Arno water | `no_walk` + `no_build` |
| bridge deck | `walkable` + `no_build` |
| paths | `walkable` + `no_build` |
| hill edge | `high` + `no_build_candidate` |
| landmark band | sort band / protected area |
| vegetation buffer | spacing / terrain context, not build-ready |
| future paths | planned, not walkable yet |

Planungslogik:

```text
water_low < bridge_deck < north_bank/south_bank < landmark_band < hill_edge_high
```

Diese Reihenfolge ist Planungslogik, keine Runtime-Sortierung.

## 12. Reachability, Landmark und Spacing Review v5

| QA-Frage | V5-Entscheidung |
| --- | --- |
| Sind 14/14 Parcels erreichbar? | Ja, jedes Parcel hat Access Point und Branch Path. |
| Kreuzen alle Arno-Bewegungen nur B1-B3? | Ja. |
| Gibt es Parcel-Overlap? | Nein, alle Parcels sind sichtbar getrennt. |
| Liegen alle Parcels innerhalb der Boundary? | Ja. |
| Sind Vegetationspuffer sichtbar? | Ja, zwischen Parcels, am Arno, West Tail, East Arm und Hill Edge. |
| Sind Landmark-Anker sichtbar? | Ja, L1-L5 sind als Identity Anchors markiert. |
| Gibt es stoerende Label-Overlaps? | Nein, Labels sind im v5-Visual getrennt gesetzt. |

## 13. Visual

Preview-Ordner:

```text
docs/world_design/previews/firenze_playable_city_layout_blueprint_v5/
```

Dateien:

- `firenze_playable_city_layout_blueprint_v5.svg`
- `firenze_playable_city_layout_blueprint_v5.png`

Das Visual muss zeigen:

- expanded Florence-shaped Ground Shape,
- Arno-Korridor,
- B1/B2/B3 als einzige Querungen,
- organisches `PATH-N` und `PATH-S`,
- Branch Paths zu allen Parcels,
- Future Paths gestrichelt,
- 14 Parcels mit Subzonen,
- 5 Landmark-Anker L1-L5,
- Vegetationspuffer,
- No-Walk und No-Build getrennt,
- Depth-/Sorting-Bands,
- QA-Badges,
- Legende,
- Statushinweis: planning only, not runtime data.

## 14. Firenze V5 handoff layers

Handoff-Ordner:

```text
docs/world_design/previews/firenze_playable_city_layout_blueprint_v5/handoff_layers/
```

Diese Layer sind vorbereitete planning-only Area-Spec-Layer fuer Review,
Weitergabe und spaetere Konsistenzpruefung. Sie sind keine Runtime-Daten,
keine Assets, keine finalen Koordinaten und keine App-Integration.

| Layer-Ordner | Inhalt | Planungsbedeutung |
| --- | --- | --- |
| `boundary/` | Stadtgrenze, spielbare Flaeche, Randpuffer | Definiert die v5-Ground-Shape als Review-Boundary und zeigt, wo aeussere No-Walk-/No-Build-Puffer beginnen. |
| `river/` | Seitenlinien, geschlossene Wasserflaeche, Mittellinie | Trennt Arno-Wasser als `no_walk` + `no_build` von Bruecken-, Ufer- und Path-Logik. |
| `streets/` | Strassen-/Wegeflaeche, Mittellinien, Knotenpunkte | Prueft PATH-N/PATH-S, Connector Paths, Branch Paths, Knoten und spaetere Reachability. |
| `parcels/` | Grundstuecksflaechen, Innenzonen, Puffer, Anker | Prueft 14 Parcel Candidates, Subzonen, Access Points, Clearance und No-Overlap. |
| `landmarks/` | reservierte Sehenswuerdigkeitsflaechen, Kern, Interaktion, Puffer, Anker | Prueft L1-L5 Landmark-Identitaet, geschuetzte Kerne, Interaktionszonen und No-Build-Puffer. |
| `correction_metadata/` | finale planning-only Korrektur-Metadaten | Ergaenzt B1-B3-IDs, Future-Path-Status, Boundary-Buffer-Review-Area, River/Core-Korrekturkandidaten und erlaubte Landmark-Buffer-Naehe ohne Original-Handoff-SVGs zu ueberschreiben. |

Stop-Regel:

- Aus den Handoff-SVGs entsteht noch keine App-Implementierung.
- Kein Handoff-Layer darf als Runtime-Polygon, Koordinate, Collision,
  Pathfinding, Build-Zone, No-Walk-/No-Build-Maske, Asset, YAML/JSON,
  App-Route oder Persistenz gelesen werden.
- Der naechste erlaubte Schritt ist ein erneuter Metrics-/Reachability-/
  Collision-Review gegen Original-Handoff-Layer plus `correction_metadata/`.

## 15. Stop-Regeln

Ein Folge-Slice ist nicht commitfaehig, wenn:

- aus diesem Blueprint Runtime-Daten, finale Koordinaten, produktive Polygone,
  YAML/JSON/YML, App-Code, Assets oder Persistenz entstehen,
- die 14 Parcels als fertige BuildState-Slots gelesen werden,
- City Entry vor v5-Review gebaut wird,
- ein Pfad den Arno ausserhalb B1/B2/B3 kreuzt,
- ein Parcel ohne Access Point oder Branch Path fortgesetzt wird,
- Parcels sich beruehren, ueberlappen oder direkt an Boundary/Arno/Bridge Deck
  kleben,
- Vegetationspuffer als Build-Freigabe gelesen werden,
- Landmark-Anker als finale Stadtkoordinaten gelesen werden,
- Future Paths ignoriert und Erweiterungen spaeter frei erfunden werden,
- Depth-/Sorting-Bands als Runtime-Sortierung gelesen werden,
- Arno, Bridges, Landmark Bands oder Hill Edge als reine Deko statt als
  Layer-/Anchor-Struktur gelesen werden.

## 16. Entscheidung

| Frage | Entscheidung |
| --- | --- |
| Ersetzt v5 die v4-Zwischenrichtung? | Ja. |
| Ist Firenze v5 weiterhin documentation_only? | Ja. |
| Sind 14 Parcels geplant? | Ja. |
| Sind 7 Early, 4 Reserve und 3 Special Parcels geplant? | Ja. |
| Sind B1-B3 die einzigen Arno-Querungen? | Ja. |
| Sind L1-L5 als Landmark-Anker sichtbar? | Ja. |
| Sind Vegetationspuffer sichtbar? | Ja. |
| Ist City Entry erlaubt? | Nein, erst nach v5-Review. |
| Entstehen Runtime-Daten, YAML/JSON, Assets oder Code? | Nein. |

## 17. Naechster erlaubter Folgeslice

Naechster fachlich erlaubter Slice nach Review:

```text
Firenze metrics / reachability / collision review
```

Der naechste Schritt ist ein technisches Review von Metrics, Reachability,
Collision, No-Overlap, Landmark-Bands und Layer-Beziehungen. Er ist nicht
sofort Flutter und keine City-Entry-App-Preview.
