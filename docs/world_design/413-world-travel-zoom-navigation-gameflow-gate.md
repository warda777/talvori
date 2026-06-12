# 413: World-Travel Zoom Navigation Gameflow Gate

Stand: 2026-06-12

Status: `docs_only` / `navigation_gameflow_gate` / `documentation_only` /
`not_asset` / `not_runtime_data` / `not_engine_ready` / `no_yaml_json` /
`no_app_integration`

## 1. Zweck

Dieses Gate legt fest, dass Talvori die Dokumentationskarte aus `411` nicht
als iPhone-Screen uebernimmt. Talvori braucht eine spielartige Welt-zu-Land-
zu-Stadt-Zoomnavigation.

`411` und `412` bleiben fachliche Grundlagen fuer Stadtbereiche und erste
Stadtentscheidung. Sie sind keine App-Screens, keine UI-Layouts, keine
Runtime-Karten und keine finalen Koordinaten.

## 2. Reuse-Before-Build Check

| Grundlage / Muster | Ergebnis | Entscheidung |
| --- | --- | --- |
| `409` Europa-Land-/Stadt-Zoom-Architektur | geeignet | Wird als struktureller Flow wiederverwendet. |
| `410` ISTAT-Comuni-Footprints | geeignet als Quelle | Bleibt Source-Footprint-Kontext, nicht App-Screen. |
| `411` Playable-City-Area-Visual | geeignet als Doku-Grundlage | Nicht als App-Screen uebernehmen. |
| `412` erste Stadtentscheidung | geeignet | Firenze wird erster City-Zoom. |
| Pokémon GO | starkes Muster: Karte als Spielfenster mit Orten im Raum | Ableiten: Karte muss Weltfenster sein, nicht Liste. |
| Genshin Impact / HoYoLAB | starkes Muster: Regionen/Nationen tragen Orientierung, Erlebnis bleibt Welt | Ableiten: Karte unterstuetzt Reise, ersetzt aber nicht Szene. |
| Clash of Clans | starkes Muster: baubare Besitzflaeche ist Kern des Spiels | Ableiten: Stadtansicht muss bebaubare Spielflaeche zeigen. |
| Everdale | passendes Muster: Dorf + Tal als Spielraeume | Ableiten: Land/Stadt duerfen spaeter soziale Nachbarschaft vorbereiten. |
| Neue Flutter-/Map-Packages | nicht noetig fuer dieses Gate | Keine technische Uebernahme. |
| Google Maps / Apple Maps / Kartenkacheln | ungeeignet | Nicht uebernehmen, nicht nachzeichnen. |

Benchmark-Quellen:

- Pokémon GO: `https://en.wikipedia.org/wiki/Pok%C3%A9mon_Go`
- Genshin Impact: `https://en.wikipedia.org/wiki/Genshin_Impact`
- HoYoLAB Interactive Map: `https://act.hoyolab.com/ys/app/interactive-map/index.html?lang=en-us`
- Clash of Clans: `https://en.wikipedia.org/wiki/Clash_of_Clans`
- Everdale: `https://en.wikipedia.org/wiki/Everdale`

Die Quellen werden nur fuer Pattern-Research genutzt. Keine Screenshots,
Assets, Kartenbilder, UI-Elemente, Code oder Daten werden uebernommen.

## 3. Benchmark-Ableitung

| Muster | Beobachtung | Talvori-Regel |
| --- | --- | --- |
| Pokémon GO | Die Karte ist ein Spielweltfenster mit Avatar, Orten und Umgebung, nicht nur ein Auswahlmenue. | Talvori zeigt Weltregionen und Stadtpunkte als lebendige Orte im Spielfeld. |
| Genshin Impact / HoYoLAB | Regionen/Nationen strukturieren Reise und Orientierung; die Welt bleibt das Erlebnis. | Der Zoom muss sich wie Reise durch eine Welt anfuehlen, nicht wie Layer-Wechsel in einem GIS. |
| Clash of Clans | Die baubare Flaeche ist der Kern der Beziehung zur Welt. | Firenze muss als bebaubare Stadtflaeche erlebbar sein, nicht als statische Karte. |
| Everdale | Dorf und Tal trennen eigenen Ausbau und groesseren Sozial-/Kooperationsraum. | Talvori kann Stadt, Land und spaeter Freunde/Showcase trennen, ohne Listenansicht als Hauptscreen. |

## 4. Ziel-Flow

Der Ziel-Flow fuer den ersten produktiven Navigations-Prototyp:

```text
Globus / Welt
-> Europa / Weltregion
-> Land auswaehlen
-> Italien-Landansicht
-> Stadtanker auswaehlen
-> Firenze-Stadtansicht
-> Bauflaechen / Wege / Lernorte / Gebaeude
```

Der Flow ist eine Reise, keine Dokumentenkarte. Uebergaenge sollen spaeter als
Zoom, Fokus, Kamerafahrt oder weiches Morphing wirken, nicht als harter
Screenwechsel zwischen Tabellen.

## 5. Spielgefuehl-Regeln

Pflicht fuer kommende World-Travel-Previews:

- fullscreen/near-fullscreen Weltflaeche,
- animierter Zoom statt Kartenwechsel,
- Laender als spielbare Diorama-Flaechen,
- Italien als erstes aktives Land,
- andere Laender sichtbar, aber locked/ausgegraut,
- Stadtpunkte als lebendige Orte, nicht technische Marker,
- Firenze als erste betretbare Stadt,
- Land-/Stadt-Zoom wirkt wie Spielreise, nicht wie GIS,
- Tali/Vori darf begleiten, Hinweise geben und Kontext schaffen,
- Tali/Vori ersetzt aber nicht die Welt-Interaktion durch ein Menue.

HUD-Regel:

- kleine, spielartige Overlays,
- keine grosse Header-/Dashboard-Flaeche,
- keine Kartenlisten als Hauptinteraktion,
- keine technischen Labels wie `playable_city_area`, `ISTAT`, `PRO_COM_T`
  im spielnahen Screen.

## 6. Rollen Von 411 Und 412

`411` bleibt:

- Dokumentationsgrundlage fuer 13 abstrahierte `playable_city_area`-
  Kandidaten,
- Quelle fuer Stadtbereichsdenken,
- keine iPhone-UI,
- kein App-Screen,
- keine Runtime-Geometrie.

`412` bleibt:

- Review- und Entscheidungsgrundlage,
- Firenze-Entscheidung,
- Roma/Bologna als Reserve-Kandidaten,
- keine UI,
- keine Runtime-Freigabe.

Das `411`-Visual darf in einer Dev-Dokumentation gezeigt werden, aber nicht als
erste Nutzeransicht. Fuer Spieler muss die Reise ueber Welt, Europa, Italien
und Firenze als eigenes Spielgefuehl entstehen.

## 7. Erste Produktive Navigationsrichtung

Entscheidung:

```text
Der erste produktive Navigations-Prototyp soll den World-Travel Zoom Flow zeigen.
```

Konkrete Ausrichtung:

- Start bei Globus/Welt,
- Europa als naechster Fokus,
- Italien aktiv und visuell einladend,
- andere europaeische Laender locked/ausgegraut,
- Stadtanker erscheinen als lebendige Reiseziele,
- Firenze ist erster betretbarer City-Zoom,
- Firenze fuehrt zu Bauflächen, Wegen, Lernorten und Gebaeuden.

Nicht Ziel:

- eine statische Kopie des 411-Visuals,
- eine GIS-Karte,
- eine Atlasansicht,
- eine Google-Maps-artige App,
- eine Dashboard-/Tabellen-/Listenansicht,
- technische Debug-Labels im Hauptscreen.

## 8. Stop-Regeln

Ein kommender World-Travel-/Italy-/City-Zoom-Slice ist nicht commitfaehig,
wenn:

- das 411-Visual als App-Screen uebernommen wird,
- die Ansicht wie GIS, Atlas, Google Maps, Dashboard, Debug-Tool oder
  Kartenliste wirkt,
- Laender und Stadtpunkte nur technische Marker ohne Spielgefuehl sind,
- andere Laender unsichtbar sind, statt als spaeterer locked/ausgegrauter
  Welt-Kontext mitzuwirken,
- Italien nicht als erstes aktives Land klar erkennbar ist,
- Firenze nicht als erster City-Zoom respektiert wird,
- Tali/Vori das Welt-/Stadt-Auswaehlen als Menue ersetzt,
- Runtime-Daten, finale Koordinaten, YAML/JSON/YML, Assets, App-Code,
  App-Routen, Persistenz, Supabase-/DB-Writes oder BuildState entstehen.

## 9. Entscheidung

| Frage | Entscheidung |
| --- | --- |
| Wird 411 als App-Screen uebernommen? | NEIN |
| Bleiben 411/412 Dokumentationsgrundlage? | JA |
| Soll der erste produktive Navigations-Prototyp World-Travel-Flow zeigen? | JA |
| Soll Italien erstes aktives Land sein? | JA |
| Sollen andere Laender sichtbar locked/ausgegraut sein? | JA |
| Soll Firenze erster City-Zoom sein? | JA |
| Darf daraus Runtime, Asset, YAML/JSON oder App-Integration entstehen? | NEIN |

## 10. Naechster Slice

Naechster empfohlener Slice:

```text
World-Travel Zoom Flow Visual Preview
```

Dieser Folge-Slice soll ein sichtbares, spielnahes Dokumentationsvisual oder
eine isolierte Preview fuer den Flow erzeugen:

```text
Globus -> Europa -> Italien -> Firenze -> Bauflaechen/Lernorte
```

Der Folge-Slice muss ausdruecklich klaeren, ob er nur SVG/PNG-Dokumentation,
eine isolierte Flutter-Preview oder beides erzeugen darf. Ohne eigene
Freigabe bleiben App-Integration, Runtime-Daten, Assets und YAML/JSON
blockiert.
