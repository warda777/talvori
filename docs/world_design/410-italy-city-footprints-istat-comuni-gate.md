# 410: Italy City Footprints ISTAT Comuni Gate

Stand: 2026-06-12

Status: `source_review_gate` / `documentation_visual` / `not_asset` /
`not_runtime_data` / `not_engine_ready` / `no_yaml_json` / `no_app_integration`

## 1. Zweck

Dieses Gate prueft, ob ISTAT Comuni als Source-of-Truth-Kandidat fuer echte
Stadt-/Gemeindegrundformen der italienischen Stadtanker geeignet ist.

Ziel im Talvori-Zoompfad:

```text
Europa -> Land -> Stadtanker -> Stadtgrundform -> spielbarer Stadtbereich
```

Dieses Gate erzeugt ein Dokumentationsvisual, aber keinen Runtime-Datensatz.
Die echten Gemeindegrenzen duerfen als Quellenform fuer Review und spaetere
Abstraktion dienen. Sie duerfen nicht als finale Runtime-Polygone, Collision,
Build-Zones, Pathfinding oder App-Daten gelesen werden.

## 2. Reuse-before-build Check

| Grundlage / Tool | Ergebnis | Entscheidung |
| --- | --- | --- |
| ISTAT Comuni | geeignet fuer italienische Stadt-/Gemeindegrundformen | Bevorzugte Quelle fuer diesen Slice. |
| ISTAT version generalizzata 2026 | geeignet fuer Talvori-Review | Weniger detailliert als die nicht-generalisierte Fassung und deshalb besser fuer Mobile-/Spielbarkeitsabstraktion. |
| ISTAT version non generalizzata 2026 | fachlich verfuegbar, aber zu detailreich fuer ersten Spiel-Review | Nicht fuer dieses Visual genutzt. |
| Natural Earth Admin 0 / 406-Kontur | weiterhin geeignet fuer Landkontur-Kontext | Kontext bleibt relevant, aber Stadtgrundformen kommen aus ISTAT Comuni. |
| Natural Earth Populated Places / 408 | weiterhin geeignet fuer Stadtanker-Punkte | Stadtanker-Logik bleibt relevant; Footprints kommen aus ISTAT. |
| OSM | fachlich reich, aber ODbL-/Attributions-/Share-Alike-Risiko | Nicht genutzt; nur Kandidat mit eigenem Lizenzgate. |
| OpenMapTiles / MapTiler / free-map.org | moegliche Toolchains, keine Quelle in diesem Slice | Nicht genutzt, keine Tiles, keine Screenshots, keine Uebernahme. |

Keine Kartenbilder, Screenshots, Tiles, Google Maps, Apple Maps, Pinterest,
Luftbilder oder Atlasbilder wurden kopiert oder nachgezeichnet.

## 3. ISTAT-Quelle und Lizenzentscheidung

Verwendete Quelle:

- source_owner: Istat - Istituto nazionale di statistica
- source_page: `https://www.istat.it/it/archivio/222527`
- source_page_current_url:
  `https://www.istat.it/notizia/confini-delle-unita-amministrative-a-fini-statistici-al-1-gennaio-2018-2/`
- dataset: `Confini delle unita amministrative a fini statistici`
- release_context: confini amministrativi aggiornati al 1 gennaio 2026
- format: shapefile
- coordinate_reference: WGS 1984 UTM Zone 32N
- relevant_level: `comuni` / municipality boundaries
- selected_file:
  `Com01012026_g/Com01012026_g_WGS84`
- selected_download:
  `https://www.istat.it/storage/cartografia/confini_amministrativi/generalizzati/2026/Limiti01012026_g.zip`
- date_used: 2026-06-12

Lizenzentscheidung:

- Die Istat-Note-legali-Seite nennt fuer Inhalte der Website, sofern nicht
  anders angegeben, Creative Commons Attribution 4.0.
- CC BY 4.0 erlaubt Teilen und Bearbeitung, auch kommerziell, wenn Attribution,
  Lizenzlink und Aenderungshinweis geleistet werden.
- Fuer Talvori-Dokumentation ist deshalb ein Quellenhinweis Pflicht.
- Vor produktiver Runtime-, Asset- oder App-Nutzung bleibt ein eigenes
  Rechts-/Attributionsreview sinnvoll.

Vorgeschlagene Attribution fuer dieses Visual:

```text
Fonte: Istat, Confini delle unita amministrative a fini statistici, 2026,
CC BY 4.0; modified for Talvori documentation visual.
```

## 4. Relevante ISTAT-Ebene

Fuer Stadtgrundformen ist die Ebene `comuni` relevant.

Nicht genutzt:

- `regioni` als Stadtgrundform,
- `province` oder `citta metropolitane` als Stadtgrundform,
- `ripartizioni geografiche`,
- nicht-generalisierte Stadtgrenzen fuer diesen ersten Review.

Regionen wurden im Visual nur als reduzierte Italien-Uebersicht genutzt, damit
die Stadtgrundformen im Landkontext lesbar sind.

## 5. Generalisiert vs. detailliert

Entscheidung:

```text
Fuer Talvori zuerst die generalisierte ISTAT-Version verwenden.
```

Begruendung:

- weniger Detailrauschen,
- bessere mobile Lesbarkeit,
- weniger Risiko, dass das Visual wie GIS oder Unterrichtsatlas wirkt,
- ausreichend fuer die Frage: Welche echten Stadt-/Gemeindegrundformen sind
  als Ausgangspunkt geeignet?

Die nicht-generalisierte Fassung bleibt fuer spaetere Spezialpruefungen
verfuegbar, ist aber fuer den ersten Spielbereichs-Review zu detailreich.

## 6. Gefundene Stadtgrundformen

Alle 13 Zielstaedte wurden in der ISTAT-Comuni-Ebene per exaktem
`COMUNE`-Matching gefunden.

| Talvori-Label | ISTAT `COMUNE` | `PRO_COM_T` | Rolle |
| --- | --- | --- | --- |
| Mailand | Milano | 015146 | Kernstadt |
| Venedig | Venezia | 027042 | Kernstadt |
| Bologna | Bologna | 037006 | Kernstadt |
| Florenz | Firenze | 048017 | Kernstadt |
| Rom | Roma | 058091 | Kernstadt |
| Neapel | Napoli | 063049 | Kernstadt |
| Genua | Genova | 010025 | Reserve |
| Pisa | Pisa | 050026 | Reserve |
| Verona | Verona | 023091 | Reserve |
| Bari | Bari | 072006 | Reserve |
| Palermo | Palermo | 082053 | Reserve |
| Catania | Catania | 087015 | Reserve |
| Cagliari | Cagliari | 118006 | Reserve |

## 7. Matching-Risiken

Die deutschen oder englischen Stadtlabels duerfen nicht blind gegen ISTAT
gesucht werden. ISTAT nutzt italienische `COMUNE`-Namen.

Pflicht-Mapping:

- Rom -> `Roma`
- Florenz -> `Firenze`
- Venedig -> `Venezia`
- Mailand -> `Milano`
- Neapel -> `Napoli`
- Genua -> `Genova`
- Bologna, Pisa, Verona, Bari, Palermo, Catania und Cagliari matchen direkt.

Substring-Matching ist nicht sicher. Beispiele fuer Fehlrisiken:

- `Roma` kann Orte mit `Romano` oder `Roma` im Namen treffen.
- `Bari` kann Orte wie `Bariano` oder `Baricella` treffen.
- `Pisa` kann `Pisano` oder `Orciano Pisano` treffen.
- `Verona` kann `Villafranca di Verona` treffen.

Fuer kuenftige Quellenarbeit ist exaktes `COMUNE`-Matching plus
`PRO_COM_T`-Kontrolle Pflicht.

## 8. Erzeugte Dokumentationsvisuals

Erlaubter Preview-Pfad:

```text
docs/world_design/previews/italy_city_footprints_istat_comuni/
```

Erzeugt:

- `italy_city_footprints_istat_comuni.svg`
- `italy_city_footprints_istat_comuni.png`
- `italy_city_footprints_istat_comuni_metadata.md`

Visual-Inhalt:

- reduzierte Italien-Uebersicht aus ISTAT-Regionen,
- 13 Stadtgrundformen aus ISTAT-Comuni,
- Kernstaedte staerker,
- Reserve-Staedte dezenter,
- Labels und `PRO_COM_T`-Codes,
- Statushinweis `documentation_only`, `not_asset`, `not_runtime_data`,
  `not_engine_ready`.

Visual-QA:

| Pruefung | Ergebnis |
| --- | --- |
| Alle 13 Stadtgrundformen sichtbar | JA |
| Kernstadt/Reserve unterscheidbar | JA |
| Labels lesbar | JA |
| Labels abgeschnitten | NEIN |
| Italien-Kontext sichtbar | JA |
| GIS-/Atlas-/Dashboard-Look dominiert | NEIN |
| Statusschutz sichtbar | JA |

## 9. Nicht-Runtime-Grenze

Nicht freigegeben:

- keine Runtime-Daten,
- keine finalen Koordinaten,
- keine produktiven Polygone,
- keine Collision,
- keine Build-Zonen,
- keine Pathfinding-Daten,
- keine Path-Centerlines,
- keine No-Walk-/No-Build-Geometrien,
- keine YAML-/JSON-/YML-Dateien,
- keine Assets,
- keine Dateien unter `assets/`,
- keine App-Code-Dateien,
- keine App-Integration,
- keine Route,
- keine Persistenz,
- kein BuildState.

Die Stadtgrundformen sind Quellenformen fuer Review. Spielbare Stadtbereiche
muessen im naechsten Slice gameplaygerecht abgeleitet, vereinfacht und gegen
Bau-/Wege-/Kamera-Regeln geprueft werden.

## 10. Entscheidung

| Frage | Entscheidung |
| --- | --- |
| Ist ISTAT Comuni fuer erste italienische Stadtgrundformen geeignet? | JA |
| Ist die Ebene `comuni` relevant? | JA |
| Ist die generalisierte 2026-Fassung fuer Talvori zuerst sinnvoller? | JA |
| Sind alle 13 Zielstaedte auffindbar? | JA |
| Wurde ein Dokumentationsvisual erzeugt? | JA |
| Entstehen Runtime-Daten oder finale Polygone? | NEIN |
| Darf danach ein spielbarer-Stadtbereich-Slice vorbereitet werden? | JA |

## 11. Naechster empfohlener Slice

Naechster Slice:

```text
Italien spielbare Stadtbereiche aus Stadtgrundformen ableiten
```

Dieser Folge-Slice soll die echten Comune-Umrisse nicht direkt uebernehmen,
sondern daraus Talvori-gerechte `playable_city_area`-Kandidaten ableiten:
spielbarer, lesbarer, build-faehiger, weniger atlasartig und weiterhin ohne
Runtime-, Asset- oder App-Freigabe, bis ein eigenes Gate dies oeffnet.
