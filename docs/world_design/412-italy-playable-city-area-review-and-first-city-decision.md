# 412: Italy Playable City Area Review And First City Decision

Stand: 2026-06-12

Status: `review_slice` / `first_city_decision` / `documentation_only` /
`not_asset` / `not_runtime_data` / `not_engine_ready` / `no_yaml_json` /
`no_app_integration`

## 1. Zweck

Dieses Review prueft, ob die 13 `playable_city_area`-Kandidaten aus `411`
ausreichen, um daraus den ersten Stadt-Greybox-/Blockout-Pfad abzuleiten.

Das Review erzeugt keine neuen Runtime-Daten, keine finalen Koordinaten, keine
YAML-/JSON-Dateien, keine Assets, keine App-Integration und keine neuen
Visuals. Es entscheidet nur, welche Stadt als erste echte Stadt-Greybox
weitergefuehrt werden soll.

## 2. Reuse-Before-Build Check

| Grundlage / Tool | Ergebnis | Entscheidung |
| --- | --- | --- |
| `411` Playable-City-Area-Kandidaten | geeignet als Review-Basis | Fuer die Stadtwahl verwenden, aber nicht als Runtime-Polygone. |
| `410` ISTAT-Comuni-Footprints | geeignet als Source-Footprint-Kontext | Nur Quellenform, keine direkte Spielgeometrie. |
| `408` Stadtanker-Plan | geeignet | Kern-/Reserve-Rollen bleiben fuehrend. |
| `407` Makro-Blockout | geeignet als Land-/Wege-Kontext | Nicht direkt in Stadt-Greybox uebernehmen. |
| `409` Europa-Zoom-Architektur | geeignet | Entscheidung muss spaeter auf weitere Laender uebertragbar bleiben. |
| OSM / MapTiler / OpenMapTiles / free-map.org | nicht noetig | Keine neue Quelle, kein Tile, kein Screenshot, kein Fremdasset. |

Es wurden keine Kartenbilder, Screenshots, Tiles, Google Maps, Apple Maps,
Pinterest, Luftbilder oder Atlasbilder kopiert oder nachgezeichnet.

## 3. Review-Kriterien

Bewertet wurden:

- Lesbarkeit,
- Spielbarkeit,
- Build-Flaechen-Potenzial,
- Wege-/Kamera-Potenzial,
- Lernort-Potenzial,
- Risiko durch zu komplizierte echte Stadtform,
- Eignung als erster Stadt-Greybox-Prototyp.

Die Bewertung ist eine Produktionsentscheidung. Sie ist keine Runtime-
Bewertung und erzeugt keine Koordinaten, Polygone oder App-Daten.

## 4. Review Der 13 Stadtbereiche

| Stadt | Lesbarkeit | Spielbarkeit | Build-Potenzial | Wege-/Kamera-Potenzial | Lernort-Potenzial | Komplexitaetsrisiko | Eignung als erste Greybox |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Milano | hoch | hoch | hoch | mittel-hoch | mittel | niedrig-mittel | gut, aber weniger emotional als Firenze/Roma |
| Venezia | sehr hoch | mittel | mittel | hoch, aber wasserabhaengig | hoch | hoch | spaeter, wegen Wasser-/Brueckenlogik |
| Bologna | hoch | hoch | mittel-hoch | sehr hoch | hoch | niedrig | sehr gut als Wegekreuz-Reserve |
| Firenze | hoch | hoch | hoch | hoch | sehr hoch | niedrig-mittel | beste erste Wahl |
| Roma | sehr hoch | hoch | sehr hoch | hoch | sehr hoch | mittel-hoch | sehr stark, aber besser nach erstem Pattern |
| Napoli | hoch | mittel-hoch | mittel-hoch | mittel-hoch | hoch | hoch | spaeter, wegen Kueste/Hoehenlogik |
| Genova | mittel-hoch | mittel | mittel | mittel | mittel | hoch | Reserve, schmale Kuestenform erst spaeter |
| Pisa | hoch | mittel | mittel | mittel | hoch | niedrig | Reserve fuer Object-Focus/Landmarke |
| Verona | mittel-hoch | mittel-hoch | mittel | mittel-hoch | mittel-hoch | niedrig | Reserve fuer Besuchs-/Kulturpfad |
| Bari | mittel | mittel | mittel | mittel | mittel | mittel | Reserve fuer Adriaraum |
| Palermo | hoch | mittel | mittel-hoch | mittel | hoch | mittel | Reserve fuer Sizilien-Hub |
| Catania | mittel-hoch | mittel | mittel | mittel | hoch | mittel-hoch | Reserve wegen Hoehen-/Vulkanbezug |
| Cagliari | mittel | mittel | mittel | mittel | mittel | mittel | Reserve fuer Sardinien-Hub |

## 5. Erste Stadt-Entscheidung

Erste Stadt fuer den naechsten Greybox-Slice:

```text
Firenze
```

Begruendung:

- Firenze ist kulturell stark und als Lernort glaubwuerdig, ohne dass die
  Greybox sofort die volle Komplexitaet einer Hauptstadt tragen muss.
- Die Stadt ist kleiner und kontrollierbarer als Roma, aber emotionaler und
  talvori-naeher als ein rein moderner Milano-Test.
- Der Kandidat bietet klaren Stadtkern, ruhige Reserve, moeglichen Start-
  Bauplatz und genug Raum fuer erste Build-/Lernort-Entscheidungen.
- Wasser-, Hafen-, Insel- oder Hoehenlogik dominieren nicht. Dadurch kann der
  erste Slice sich auf Kernfragen konzentrieren: Stadtkern, Wege, Baupunkte,
  Kamera, Lernorte und No-Build-Rand.
- Firenze eignet sich gut, um zu beweisen, dass echte Stadtgrundformen
  Talvori-gerecht abstrahiert werden koennen, ohne wie GIS oder Atlas zu
  wirken.

## 6. Reserve-Kandidaten

Reserve 1:

```text
Roma
```

Roma bleibt der staerkste Haupt-Hub-Kandidat und die bekannteste Stadt. Sie
soll als naechster oder uebernaechster grosser Hub folgen, sobald das erste
Stadt-Greybox-Pattern in Firenze stabil ist.

Reserve 2:

```text
Bologna
```

Bologna ist der beste Wegekreuz- und Systemtest. Wenn nach Firenze vor allem
Pathing, Verbindungslogik und Kamera-Gefuehl geprueft werden sollen, ist
Bologna die sinnvollste zweite technische Stadt.

## 7. Warum Die Anderen Warten

| Stadt | Grund fuer spaeter |
| --- | --- |
| Roma | hoechste Bekanntheit, aber zu viel Hub-/Landmark-/Geschichtsdruck fuer den ersten Pattern-Test. |
| Milano | technisch gut und flach, aber fuer den ersten emotionalen Stadt-Prototyp weniger stark als Firenze. |
| Venezia | sehr attraktiv, aber Wasser, Bruecken und Insel-/Kanal-Logik wuerden den ersten Greybox-Slice ueberladen. |
| Bologna | sehr guter Systemtest, aber als erste Stadt weniger ikonisch als Firenze. |
| Napoli | stark, aber Kueste, Hang/Hoehe und dichter Suedraum erhoehen den ersten Greybox-Aufwand. |
| Genova | schmale Kuestenform macht Build- und Kameraflaechen schwieriger. |
| Pisa | gut fuer Landmark/Object-Focus, aber zu klein als erster kompletter Stadtbereich. |
| Verona | solides Reserveprofil, aber nicht so klar als erster Produktanker. |
| Bari | wichtig fuer Adriaraum, aber eher spaeterer Regionalanker. |
| Palermo | wichtig fuer Sizilien, aber Insel-Hub sollte nach Festland-Pattern kommen. |
| Catania | interessant wegen Hoehen-/Vulkanbezug, aber komplexer als erster Test. |
| Cagliari | wichtig fuer Sardinien, aber separater Inselraum sollte spaeter folgen. |

## 8. Was Aus 411 Ausreichend Ist

Ausreichend fuer den naechsten Slice:

- alle 13 Kandidaten sind lesbar,
- Kern- und Reserve-Staedte sind unterscheidbar,
- jeder Kandidat hat Stadtkern, Reserve, Rand/No-Build und Start-Bauplatz,
- die echten ISTAT-Footprints bleiben als Quellenumrisse erkennbar getrennt,
- Firenze ist ausreichend klar, um einen ersten Stadt-Greybox-Blockout zu
  starten.

Noch nicht ausreichend fuer Runtime:

- keine echten Wege,
- keine echten Baupunkte,
- keine No-Walk-/No-Build-Masken,
- keine Landmark-Anker,
- keine finalen Koordinaten,
- keine Path-Centerlines,
- keine App-/Engine-Struktur.

## 9. Stop-Regeln Fuer Den Naechsten Slice

Der naechste Slice ist nicht commitfaehig, wenn:

- Firenze 1:1 aus dem ISTAT-Footprint als Runtime-Polygon uebernommen wird,
- finale Koordinaten, produktive Polygone, YAML/JSON/YML oder App-Daten
  entstehen,
- Wege, Build-Flaechen oder No-Build-Zonen aus Pixeln oder Atlaslogik
  erraten werden,
- die Greybox wie GIS, Unterrichtsatlas, Dashboard, Tabellen- oder Debug-Tool
  wirkt,
- die Stadt nicht spielartig als fullscreen/near-fullscreen Greybox gedacht
  wird,
- Lernorte nur als Liste statt als Orte im Stadtbereich geplant werden,
- Dateien unter `assets/` entstehen,
- Flutter-/Dart-Code, App-Routes, Persistenz, Supabase-/DB-Writes oder
  BuildState entstehen.

## 10. Entscheidung

| Frage | Entscheidung |
| --- | --- |
| Sind die 13 Kandidaten aus 411 gut genug fuer eine erste Stadtentscheidung? | JA |
| Darf daraus ein erster Stadt-Greybox-Slice vorbereitet werden? | JA |
| Erste Stadt | Firenze |
| Reserve-Kandidaten | Roma, Bologna |
| Echte Stadtbereiche 1:1 als Runtime-Polygone uebernehmen? | NEIN |
| Runtime-Daten, YAML/JSON, Assets oder App-Code freigegeben? | NEIN |

## 11. Naechster Slice

Naechster empfohlener Slice:

```text
Erste Stadt-Greybox aus Firenze playable_city_area ableiten
```

Dieser Folge-Slice soll aus dem Firenze-Kandidaten eine sichtbare, spielnahe
Greybox planen: Stadtkern, 6 erste Baupunkte, Reserve, Wege, Lernorte,
No-Walk/No-Build-Rand, Kamera- und HUD-Grenzen. Auch dieser Schritt bleibt
zunaechst Dokumentations-/Visual- oder Preview-Arbeit und darf keine Runtime-
Geometrie oder App-Integration erzeugen, wenn der Prompt das nicht ausdruecklich
oeffnet.
