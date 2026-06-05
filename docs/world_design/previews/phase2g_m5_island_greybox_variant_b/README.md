# Phase 2G-M5 Variant B Debug-Greybox Preview

Stand: 2026-06-05

Diese Dateien sind reine Dokumentations- und Debug-Previews fuer das
Talvori-Insel-Masterlayout. Sie sind keine Spielassets, keine finale Kunst und
keine Code- oder Asset-Freigabe.

## Zweck Der Preview

Die Variante-B-Preview prueft eine organischere Plot-Anordnung als die M4-
Greybox. Sie reagiert auf die M4-Probleme: zu lineare Struktur, zu langer
`market_square`-Schwanz unter `hub_seed_south`, kuenstliche
`water_edge_east`-Diagonale und zu starkes Netzdiagramm-Gefuehl.

Variante B soll zeigen:

- `starter_home` bleibt klarer Startpunkt, wirkt aber weniger wie ein starrer
  Kreuzungsmittelpunkt.
- `garden_west` und `nature_north` rahmen die Starterzone organischer.
- `hub_seed_south` und `market_square` liegen naeher am Hauptweg.
- `market_square` haengt nicht mehr als langer vertikaler Schwanz.
- `water_edge_east` liest sich eher als rechte/obere Inselkante.
- `farm_southwest` wirkt als Rand- und Uebergangszone.

## Preview-Dateien

- `01_island_plot_greybox_variant_b.png`: Plotflaechen, Labels und Status.
- `02_socket_debug_overlay_variant_b.png`: Plotstruktur mit sichtbaren
  Socket-Punkten und Socket-Typen.
- `03_footprint_debug_overlay_variant_b.png`: Footprints, Wege,
  Sicherheitszonen, Deko-Zonen und StarterCorePlot-Markierung.
- `04_status_legend_variant_b.png`: Status- und Socket-Legende mit Hinweis auf
  Debug-/Planungscharakter.

## Kurzes Prueffazit

Variante B wirkt weniger linear als M4 und ist als naechster Debug-
Pruefschritt geeignet. Die Plotverteilung bildet eher eine kompakte,
organische Inselstruktur, bleibt aber intern modular pruefbar. `starter_home`
ist weiterhin gut erkennbar, `garden_west` und `nature_north` geben der
Starterzone mehr Rahmen, und `market_square` ist weniger isoliert.

Vorlaeufiges Ergebnis:

```text
Variante B Debug-Preview erzeugt / manuelle visuelle Pruefung offen
```

## Sichtbare Verbesserungen Gegenueber M4

- Weniger starre Vertikalachse von `path_south` ueber `hub_seed_south` zu
  `market_square`.
- `market_square` sitzt naeher und diagonaler am Hub statt als langer Schwanz.
- `water_edge_east` liegt klarer an einer rechten/oberen Randlogik.
- Starterbereich wird durch Garten und Natur besser eingefasst.
- Die schematische Inselhuelle macht die Struktur weniger rein rasterhaft.

## Sichtbare Probleme Und Risiken

- Die Preview bleibt ein technisches Diagramm, keine bestaetigte Inselkunst.
- Mobile-Lesbarkeit ist noch nicht geprueft.
- Das Footprint-/Safety-Overlay ist informationsreich und wirkt stellenweise
  dicht.
- `hub_seed_south`, `market_square` und `path_south` muessen in der manuellen
  Pruefung weiter auf Abstand, Lesbarkeit und Kapazitaet geprueft werden.
- Die organische Aussenkante ist nur schematisch dargestellt und muss vor
  spaeterer Asset-Produktion erneut bewertet werden.

## Blockierte Folgen

- Keine Spielasset-Erzeugung.
- Kein finales Inselbild.
- Kein `frame_started`.
- Kein Flutter-/Dart-Code.
- Keine App-Integration.
- Keine Bau-, Lern-, Reward-, Persistenz-, Supabase-, SRS- oder
  Ressourcenlogik.

Naechster erlaubter Schritt:

```text
Manuelle visuelle Pruefung der Variante-B-Greybox; danach Variante B
bestaetigen oder erneut nachbessern.
```
