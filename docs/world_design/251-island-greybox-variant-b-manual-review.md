# Island Greybox Variant B Manual Review

Stand: 2026-06-05

Status: `manuelle Pruefung vorbereitet / Nutzerentscheidung offen`

## 1. Zweck

Dieses Dokument bereitet die manuelle visuelle Sichtpruefung der
Phase-2G-M5-Variante-B-Greybox vor.

Es trifft noch keine finale Layoutentscheidung. Es stellt nur sicher, dass die
Debug-Greybox bewusst anhand klarer Fragen bewertet wird, bevor Talvori das
Insel-Masterlayout bestaetigt, nachbessert oder zu einer anderen Variante
zurueckkehrt.

Variante B ist weiterhin:

- Dokumentations- und Debugmaterial,
- keine finale Inselkunst,
- kein Spielasset,
- keine Codefreigabe,
- keine Asset-Freigabe fuer `frame_started`.

## 2. Gepruefte Dateien

Manuell zu pruefen sind:

- `docs/world_design/previews/phase2g_m5_island_greybox_variant_b/01_island_plot_greybox_variant_b.png`
- `docs/world_design/previews/phase2g_m5_island_greybox_variant_b/02_socket_debug_overlay_variant_b.png`
- `docs/world_design/previews/phase2g_m5_island_greybox_variant_b/03_footprint_debug_overlay_variant_b.png`
- `docs/world_design/previews/phase2g_m5_island_greybox_variant_b/04_status_legend_variant_b.png`
- `docs/world_design/previews/phase2g_m5_island_greybox_variant_b/README.md`

Diese Dateien liegen ausserhalb des Asset-Ordners und duerfen nicht als
Runtime-Assets interpretiert werden.

## 3. Prueffragen Fuer Die Manuelle Sichtpruefung

Die manuelle Sichtpruefung soll mindestens diese Fragen beantworten:

- Wirkt Variante B weniger linear als M4?
- Wirkt die Insel organischer?
- Ist `starter_home` weiterhin klar erkennbar?
- Wird `starter_home` weniger wie ein starres Kreuzungszentrum behandelt?
- Rahmen `garden_west` und `nature_north` den Starterbereich sinnvoll?
- Liegt `market_square` besser am Hub?
- Ist `market_square` nicht mehr als langer vertikaler Schwanz sichtbar?
- Ist `water_edge_east` als Rand-/Uferzone plausibler?
- Wirkt `farm_southwest` als Rand-/Uebergangszone sinnvoll?
- Ist `neighbor_west` logisch erreichbar?
- Sind 7 Starter-/Vorbereitungsplots sichtbar?
- Sind 12-14 Ausbau-Slots plausibel vorbereitet?
- Sind Wege, Sockets und Footprints pruefbar?
- Wirkt die Struktur trotz Debug-Stil spaeter als organische Insel denkbar?
- Gibt es sichtbare Ueberfuellung?
- Gibt es neue Probleme gegenueber M4?

## 4. Bewertungskriterien

Variante B ist nur dann bestaetigungsfaehig, wenn:

- die Struktur weniger linear/rasterhaft wirkt als M4,
- `starter_home` als Startpunkt lesbar bleibt, aber nicht als starres
  Kreuzungszentrum dominiert,
- `garden_west` und `nature_north` die Starterzone glaubwuerdig rahmen,
- `market_square` naeher und natuerlicher an `hub_seed_south` liegt,
- `market_square` nicht als isolierter langer Schwanz wirkt,
- `water_edge_east` als rechte/obere Rand- oder Uferzone plausibel ist,
- `farm_southwest` als Rand- oder Uebergangszone lesbar bleibt,
- `neighbor_west` ueber Wohn-, Garten- oder Pfadlogik erreichbar wirkt,
- Starter-/Vorbereitungsplots und spaetere Ausbauplots klar unterscheidbar
  bleiben,
- Wege, Sockets, Footprints und Sicherheitszonen sichtbar pruefbar sind,
- die Struktur modular bleibt, ohne wie ein reines Netzdiagramm zu wirken,
- keine neue Ueberfuellung oder zu starke Brettspieloptik entsteht.

Die Greybox darf technisch/diagrammartig aussehen. Sie muss aber erkennen
lassen, dass daraus spaeter eine organische Inselstruktur ableitbar ist.

## 5. Entscheidungsmoeglichkeiten

Nach der manuellen Sichtpruefung gibt es vier erlaubte Entscheidungen:

### Variante B Bestaetigen

Variante B wird als naechste fuehrende Greybox-Struktur fuer das
Insel-Masterlayout akzeptiert.

Erlaubt danach:

- Metriken und Plot-Anker auf Basis von Variante B weiter konkretisieren,
- eine naechste Planungs- oder Debug-Preview-Stufe vorbereiten.

Nicht automatisch erlaubt:

- Spielasset-Erzeugung,
- `frame_started`,
- Code,
- finale Inselkunst.

### Variante B Mit Kleinen Korrekturen Bestaetigen

Variante B ist grundsaetzlich gut, braucht aber kleine Korrekturen, zum
Beispiel Abstand, Label-Dichte, einzelne Plot-Positionen oder bessere
Lesbarkeit.

Erlaubt danach:

- gezielte Metrik-/Preview-Nachbesserung,
- keine neue Asset-Produktion.

### Variante B Erneut Nachbessern

Variante B loest die M4-Probleme nur teilweise oder erzeugt neue sichtbare
Probleme.

Erlaubt danach:

- neue Debug-Greybox-Variante,
- Anpassung von Plotpositionen, Wegen, Sockets oder Status-Zuordnung.

### Zurueck Zu Einer Anderen Variante

Variante B wird verworfen oder nur als Lernstand behalten.

Erlaubt danach:

- Rueckgriff auf Variante A oder C aus
  `docs/world_design/250-island-greybox-layout-review.md`,
- erneuter Debug-Preview-Block.

## 6. Offene Pruefpunkte

Offen bleiben:

- echte Nutzerentscheidung zur Variante-B-Greybox,
- Mobile-Lesbarkeit der Labels und Plotdichte,
- ob `hub_seed_south`, `market_square` und `path_south` genuegend Abstand und
  Kapazitaet haben,
- ob `water_edge_east` wirklich als Rand-/Uferzone funktioniert,
- ob die Struktur bei spaeterer organischer Inselkante noch plausibel bleibt,
- ob 7 Starter-/Vorbereitungsplots und 12-14 Ausbau-Slots visuell nicht zu
  ueberladen wirken,
- ob die Footprint-/Safety-Overlay-Dichte fuer weitere Planung ausreicht oder
  eine reduzierte Debug-Ansicht benoetigt.

## 7. Weiterhin Blockierte Systeme

Weiterhin blockiert bleiben:

- Flutter-/Dart-Code,
- App-Integration,
- Tests,
- Spielassets,
- PNGs im Asset-Ordner,
- finales Inselbild,
- `frame_started`,
- weitere Bauzustaende,
- Persistenz,
- Supabase Writes,
- SQLite-/SRS-/`word_progress`-Aenderungen,
- Reward Bridge,
- Ressourcenlogik,
- Sound-/FX-Schicht,
- Expansion,
- PlacedItems,
- Interiors/ObjectDetail,
- produktive Bau-/Lernlogik.

Naechster erlaubter Schritt:

```text
Nutzer prueft die Variante-B-Greybox visuell; danach Variante B bestaetigen,
mit kleinen Korrekturen bestaetigen, erneut nachbessern oder zu einer anderen
Variante zurueckkehren.
```
