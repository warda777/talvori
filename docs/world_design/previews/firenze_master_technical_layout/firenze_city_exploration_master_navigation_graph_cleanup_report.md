# Firenze City Exploration Master Navigation Graph Cleanup Report

Stand: 2026-06-17

Status: `documentation_only` / `planning_svg_cleanup` / `navigation_graph_review` /
`not_runtime_data` / `not_asset` / `not_engine_ready` / `no_yaml_json` /
`no_app_integration`

## 1. Gelesene Dokumente

- `AGENTS.md`
- `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md`
- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
- `docs/world_design/384-uferwald-playable-map-layer-and-mask-architecture.md`
- `docs/world_design/416-talvori-playable-area-specification-standard-v1.md`
- `docs/world_design/417-firenze-playable-city-layout-blueprint-v5.md`
- `docs/world_design/previews/firenze_master_technical_layout/firenze_city_exploration_master_id_cleanup_report.md`

## 2. Geprüfte SVG-Datei

Geprüft und bereinigt:

```text
docs/world_design/previews/firenze_master_technical_layout/firenze_city_exploration_master.svg
```

Root-Canvas bleibt:

- `width="1672"`
- `height="941"`
- `viewBox="0 0 442.38333 248.97292"`

## 3. Sicherungskopie

Vor der Navigation-Graph-Bereinigung wurde diese Sicherung angelegt:

```text
docs/world_design/previews/firenze_master_technical_layout/firenze_city_exploration_master_before_navigation_graph_cleanup.svg
```

## 4. Geometrie-Schutz

Geändert wurden nur:

- `id`-Attribute,
- `inkscape:label`-Attribute,
- die Layer-Zuordnung von bestehenden Graph-Ellipsen zu `11_navigation_nodes`,
- der Layername `12_navigation_graph` zu `12_navigation_edges`.

Nicht geändert wurden:

- Pfadpunkte,
- Koordinaten,
- `d`-Werte,
- `cx`-/`cy`-Werte,
- `x`-/`y`-Werte,
- Transforms,
- Styles,
- sichtbare Texte,
- sichtbare Flächen.

Die automatische Geometrieprüfung verglich die SVG gegen
`firenze_city_exploration_master_before_navigation_graph_cleanup.svg` als
Multiset aus Elementtyp, sichtbarem Text und allen nicht-ID-/nicht-Label-
Attributen. Ergebnis: keine Geometrie-/Style-/Textänderung.

## 5. Strukturänderung

Vorher:

- `11_navigation_nodes` enthielt Bridge-Nodes und Parcel-Entries.
- `12_navigation_graph` enthielt gemischt Graph-Nodes, Road-Access-Nodes und
  Edge-Pfade.

Nachher:

| Layer | Inhalt |
| --- | --- |
| `11_navigation_nodes` | nur Punkt-/Knotenobjekte, 154 Ellipsen |
| `12_navigation_edges` | nur Navigation-Edges, 215 Pfade |

Die 102 Ellipsen aus dem früheren `12_navigation_graph` wurden in
`11_navigation_nodes` verschoben. Ihre Koordinaten und Styles blieben
unverändert.

## 6. Nodes nach Typ

| Typ | Anzahl | Namensschema |
| --- | ---: | --- |
| Crossroads / Road-Nodes | 74 | `N001_crossroad` bis `N074_crossroad` |
| Bridge Nodes | 24 | `B01_N`, `B01_M`, `B01_S` bis `B08_N/M/S` |
| Parcel Entries | 28 | `P01_entry_1/2` bis `P14_entry_1/2` |
| Road Access Nodes | 28 | `P01_access_1/2` bis `P14_access_1/2` |

Zusätzlich geprüft:

- `city_spawn_start` bleibt im Anchor-Layer, ist aber über eine Edge mit dem
  Navigation-Graph verbunden.
- `city_center_anchor` bleibt im Anchor-Layer und ist nicht als
  Navigation-Ziel angebunden.

## 7. Edges

Edge-Zuweisung:

- Jede Edge wurde anhand ihrer SVG-Path-Endpunkte gegen den nächstgelegenen
  benannten Node geprüft.
- Schwelle für automatische Benennung: maximal `0.5` Review-Canvas-Einheiten
  Abstand pro Endpunkt.
- Nur Edges mit zwei eindeutigen, verschiedenen Node-Endpunkten wurden auf
  `E_<from>_<to>` gesetzt.
- Edges mit unklarem Endpunkt, zu großer Distanz, gleicher Start-/Zielauflösung
  oder doppelter Kandidatenverbindung blieben `E_needs_manual_review_###`.

Ergebnis:

| Kategorie | Anzahl |
| --- | ---: |
| Navigation-Edges gesamt | 215 |
| Erfolgreich eindeutig benannte Edges | 188 |
| Verbleibende `needs_manual_review`-Edges | 27 |

## 8. Bridge-Ketten

Alle acht Bridge-Familien sind als Kette prüfbar:

```text
Road/Crossroad -> B##_N -> B##_M -> B##_S -> Road/Crossroad
```

| Bridge | N-M | M-S | Nordanschluss | Südanschluss |
| --- | --- | --- | --- | --- |
| B01 | ok | ok | `N043_crossroad` | `N040_crossroad` |
| B02 | ok | ok | `N045_crossroad` | `N037_crossroad` |
| B03 | ok | ok | `N052_crossroad` | `N036_crossroad` |
| B04 | ok | ok | `N047_crossroad` | `N046_crossroad` |
| B05 | ok | ok | `N015_crossroad` | `N027_crossroad` |
| B06 | ok | ok | `N016_crossroad` | `N025_crossroad` |
| B07 | ok | ok | `N018_crossroad` | `N019_crossroad` |
| B08 | ok | ok | `N071_crossroad` | `N070_crossroad` |

Hinweis:

Bridge-Nodes wurden innerhalb jeder Bridge-Familie nach ihrer tatsächlichen
Nord/Mitte/Süd-Lage benannt. Das korrigiert die zuvor uneindeutige B01-Reihenfolge
rein per ID/Label, ohne die Punkte zu verschieben.

## 9. Parcel-Access-Verbindungen

Direkte Access-zu-Entry-Verbindungen sind teilweise eindeutig vorhanden.

Fehlende oder nicht eindeutig benannte direkte Verbindungen:

- `P08_access_1 -> P08_entry_1`
- `P08_access_2 -> P08_entry_2`
- `P09_access_1 -> P09_entry_1`
- `P09_access_2 -> P09_entry_2`
- `P11_access_1 -> P11_entry_1`
- `P11_access_2 -> P11_entry_2`
- `P13_access_1 -> P13_entry_1`
- `P13_access_2 -> P13_entry_2`
- `P14_access_2 -> P14_entry_2`

Diese Fälle wurden nicht geraten. Sie müssen manuell in Inkscape geprüft oder
über zusätzliche eindeutige Edge-Beschriftung geklärt werden.

## 10. Verbleibende `needs_manual_review`-Edges

27 Edges bleiben offen:

| Gruppe | Grund |
| --- | --- |
| Same-node-Auflösung | Beide Endpunkte liegen gemäß Distanzprüfung am selben Node. |
| Zu große Endpunktdistanz | Mindestens ein Endpunkt liegt zu weit vom nächsten bekannten Node entfernt. |
| Doppelte/unklare Kleinsegmente | Einzelne kurze Hilfs-/Beziersegmente sind nicht eindeutig als zwei-Knoten-Edge lesbar. |

Die offenen Edge-IDs sind:

```text
E_needs_manual_review_001
E_needs_manual_review_002
E_needs_manual_review_003
E_needs_manual_review_004
E_needs_manual_review_005
E_needs_manual_review_006
E_needs_manual_review_007
E_needs_manual_review_008
E_needs_manual_review_009
E_needs_manual_review_010
E_needs_manual_review_011
E_needs_manual_review_012
E_needs_manual_review_013
E_needs_manual_review_014
E_needs_manual_review_015
E_needs_manual_review_016
E_needs_manual_review_017
E_needs_manual_review_018
E_needs_manual_review_019
E_needs_manual_review_020
E_needs_manual_review_021
E_needs_manual_review_022
E_needs_manual_review_023
E_needs_manual_review_024
E_needs_manual_review_025
E_needs_manual_review_026
E_needs_manual_review_027
```

## 11. Doppelte oder unklare Nodes

Nach der Bereinigung:

- Keine doppelten IDs.
- Keine unklaren Node-IDs im Navigation-Node-Layer.
- Keine Inkscape-Standard-IDs.
- Crossroads wurden bewusst neu durchnummeriert, weil vorher mehrere
  ursprüngliche `N...`-Namen doppelt oder uneinheitlich waren.

## 12. City Nodes

| Node | Ergebnis |
| --- | --- |
| `city_spawn_start` | verbunden, Edge zu `N001_crossroad` vorhanden |
| `city_center_anchor` | nicht verbunden; bleibt Anchor, kein aktiver Navigation-Zielnode |

## 13. Prüfstatus

| Frage | Ergebnis |
| --- | --- |
| Sind Nodes und Edges getrennt? | Ja |
| Enthält `11_navigation_nodes` nur Punkte/Knoten? | Ja |
| Enthält `12_navigation_edges` nur Linien/Edges? | Ja |
| Haben alle B01-B08 eine N-M-S-Kette? | Ja |
| Ist `city_spawn_start` angebunden? | Ja |
| Ist `city_center_anchor` angebunden? | Nein, bewusst nicht als Zielnode belegt |
| Sind alle Parcel-Access-Nodes eindeutig an Entries angeschlossen? | Nein |
| Sind alle Edges eindeutig `E_<from>_<to>`? | Nein, 27 offen |

## 14. Bereitschaft

```text
Navigation-Graph bereit für QA-Preview: NO
Area-Specification-JSON bereit: NO
```

Begründung:

- Die Layerstruktur ist jetzt sauber getrennt und der Großteil der Edges ist
  eindeutig benannt.
- Es bleiben aber mehr als 20 `needs_manual_review`-Edges.
- 9 Parcel-Access-zu-Entry-Verbindungen sind nicht eindeutig bestätigt.
- Daraus darf noch keine Area-Specification-JSON oder Runtime-/Walkability-
  Ableitung entstehen.

## 15. Nächster kleiner Schritt

Nächster sinnvoller Schritt:

```text
Firenze navigation edge manual review pass
```

Dieser Schritt sollte ausschließlich die 27 offenen Edge-IDs und die 9
Parcel-Access-Verbindungen in Inkscape oder einem Review-Overlay klären. Erst
wenn diese Reststellen eindeutig sind, ist eine QA-Preview des Navigation-
Graphs sinnvoll.

## 16. Stop-Regel

Diese SVG bleibt planning-only. Sie erzeugt keine Runtime-Daten, keine finalen
Koordinaten, keine produktiven Polygone, keine App-Integration, keine Assets,
kein YAML/JSON und keinen BuildState.
