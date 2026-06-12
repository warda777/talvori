# 414: World-Travel Preview Fail Review And Source-Based Rebuild Plan

Stand: 2026-06-12

Status: `fail_review` / `source_based_rebuild_plan` / `documentation_only` /
`not_asset` / `not_runtime_data` / `not_engine_ready` / `no_yaml_json` /
`no_app_integration`

## 1. Zweck

Dieses kurze Review verwirft die erste isolierte World-Travel-Zoom-Preview.
Die Datei `world_travel_zoom_flow_preview.dart` wurde nicht als fachlich
brauchbare Grundlage weitergefuehrt.

Dieses Dokument ist kein weiterer Theorie-Loop. Es setzt nur die Stop-Regel,
damit der naechste Slice direkt source-based neu aufgebaut werden kann.

## 2. Warum Die Preview Abgelehnt Wurde

Die Preview widersprach dem Anspruch aus `413`, weil sie zwar einen
spielerischen Flow andeutete, aber die Weltformen frei erfand:

- Die Erde wirkte nicht wie Erde.
- Der Zoom lief seitlich am Zielgefuehl vorbei.
- Italien war nicht als Italien erkennbar.
- Europa und Laenderformen waren frei zusammengebastelt.
- Die Formen wirkten wie Fantasie-Blobs statt wie offene, nachvollziehbare
  Konturgrundlagen.

Damit war die Preview nicht commitfaehig.

## 3. Was Nicht Wieder Passieren Darf

Kuenftige World-Travel-Previews duerfen nicht mehr:

- einen Globus als selbstgemalten Kreis mit zufaelligen Flecken darstellen,
- Europa oder Laender frei malen, wenn echte offene Konturen verfuegbar sind,
- Italien als Fantasieform oder Blob zeigen,
- Firenze als frei gesetzte Blase statt als Ziel aus dem dokumentierten
  Italien-/Stadtanker-Pfad behandeln,
- das `411`-Visual als App-Screen uebernehmen,
- in GIS-, Atlas-, Dashboard-, Kartenlisten- oder Debug-Optik kippen.

## 4. Harte Neue Regel

Keine Laender-, Globus- oder Stadtformen frei malen, wenn echte offene
Konturgrundlagen vorhanden oder bereits im Repo dokumentiert sind.

Der naechste World-Travel-Zoom-Prototyp muss source-based starten:

- Welt/Globus braucht eine echte vereinfachte Kontur- oder Kartenquelle als
  Grundlage, keine frei gemalten Landflecken.
- Europa und Laender muessen aus einer echten vereinfachten offenen Quelle
  abgeleitet werden.
- Italien muss aus der vorhandenen Natural-Earth-/`406`-Arbeitskontur bzw.
  derselben Source-of-Truth-Linie kommen.
- Firenze bleibt Ziel aus `410`, `411` und `412`, aber nicht als technische
  Doku-Karte und nicht als Fantasie-Blase.
- Die Darstellung darf weiterhin spielartig, weich, dioramaartig und
  fullscreen/near-fullscreen sein.

Source-based bedeutet nicht GIS-Look. Es bedeutet: echte erkennbare Formen als
Grundlage, danach Talvori-gerechte Vereinfachung und Spielinszenierung.

## 5. Reuse-Before-Build Check

| Grundlage | Ergebnis | Entscheidung |
| --- | --- | --- |
| `406` Natural-Earth-basierte Italien-Arbeitskontur | geeignet | Fuer Italien wiederverwenden, nicht neu frei zeichnen. |
| `409` Europa-Land-/Stadt-Zoom-Architektur | geeignet | Flow generisch fuer Europa/Land/Stadt halten. |
| `410` bis `412` Stadtgrundformen und Firenze-Entscheidung | geeignet als Backstage-Kontext | Firenze bleibt erster City-Zoom, aber nicht als Fantasie-Overlay. |
| frei gemalter Globus / frei gemalte Laender | ungeeignet | Verworfen. |
| Google Maps, Apple Maps, Screenshots, Atlasbilder, Kartenkacheln | ungeeignet | Nicht kopieren, nicht nachzeichnen. |

## 6. Naechster Slice

Naechster Slice:

```text
Source-based World-Travel Zoom Preview mit echten Konturen
```

Dieser Slice soll ein sichtbares Ergebnis liefern. Er darf nicht in eine lange
Doku-Schleife ausweichen, sondern muss vor der Umsetzung klaeren, welche
offenen Konturquellen fuer Welt/Europa genutzt werden und dann eine
source-based Preview bauen, sofern der Prompt Code/Preview-Scope ausdruecklich
oeffnet.

## 7. Nicht-Freigaben

Dieses Review gibt nicht frei:

- keine neue Preview-Datei,
- keine App-Integration,
- keine Route,
- keine Persistenz,
- kein BuildState,
- keine Runtime-Daten,
- keine finalen Koordinaten,
- keine YAML/JSON/YML,
- keine Assets,
- keine Dateien unter `assets/`,
- keine fremden Kartenbilder oder Screenshots,
- keinen Commit.
