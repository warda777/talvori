# Phase 2G-M5: Island Greybox Layout Review

Stand: 2026-06-05

Dieses Dokument startet Phase 2G-M5 als reinen Planungs- und Bewertungsblock
fuer die visuelle Bewertung und Nachbesserung der M4-Debug-Greybox des
Talvori-Insel-Masterlayouts.

Fuehrende Dokumente:

- `docs/world_design/249-island-greybox-preview-plan.md`
- `docs/world_design/248-island-plot-metrics-and-greybox-layout.md`
- `docs/world_design/247-island-greybox-scale-and-plot-metrics.md`
- `docs/world_design/246-island-master-layout-and-modular-plot-system.md`
- `docs/world_design/235-world-production-roadmap-and-checklists.md`
- `assets/images/world/buildable_islands/forest_clearing/template.md`

## 1. Zweck Der Bewertung

M5 bewertet, ob die in M4 erzeugte sichtbare Debug-Greybox als
Insel-Masterlayout plausibel genug ist, um darauf weitere Planung
aufzubauen.

Die Bewertung klaert:

- ob die Plot-Anordnung als Inselstruktur funktioniert,
- ob die Starter-/Vorbereitungsplots gut zueinander liegen,
- ob Expansionen organisch anschliessen,
- ob das Layout zu linear oder zu rasterhaft wirkt,
- ob eine Nachbesserungsvariante noetig ist.

Nicht-Ziele:

- kein Flutter-/Dart-Code,
- keine App-Integration,
- keine Tests,
- keine neuen Spielassets,
- keine PNGs im Asset-Ordner,
- kein finales Inselbild,
- kein `frame_started`,
- keine Bauzustands-Fortsetzung,
- kein Commit.

## 2. Gepruefte Preview-Dateien

Geprueft wurden:

- `docs/world_design/previews/phase2g_m3_island_greybox/01_island_plot_greybox.png`
- `docs/world_design/previews/phase2g_m3_island_greybox/02_socket_debug_overlay.png`
- `docs/world_design/previews/phase2g_m3_island_greybox/03_footprint_debug_overlay.png`
- `docs/world_design/previews/phase2g_m3_island_greybox/04_status_legend.png`
- `docs/world_design/previews/phase2g_m3_island_greybox/README.md`

## 3. Positives Ergebnis Der M4-Greybox

Die M4-Greybox ist als technisches Debugmaterial brauchbar.

Positiv:

- Sieben Starter-/Vorbereitungsplots sind sichtbar:
  `starter_home`, `garden_west`, `path_south`, `nature_north`,
  `function_seed_east`, `hub_seed_south`, `expansion_edge_se`.
- Spaetere Expansionen sind sichtbar vorbereitet:
  `neighbor_west`, `market_square`, `nature_edge_nw`, `water_edge_east`,
  `farm_southwest`.
- Plot-Status sind lesbar.
- Socket-Typen sind sichtbar.
- Wege, Footprints und Sicherheitszonen koennen technisch geprueft werden.
- `starter_home` ist klar als StarterCorePlot markiert.

Interpretation:

```text
M4 besteht als technisches Debugdiagramm.
M4 ist noch nicht als visuell plausibles Insel-Masterlayout bestaetigt.
```

## 4. Visuelle Bewertung Der Aktuellen Struktur

| Frage | Bewertung |
| --- | --- |
| Wirkt die Struktur wie eine Insel? | Nur bedingt. Sie wirkt derzeit eher wie ein technisches Netzdiagramm. |
| Sind die 7 Starter-/Vorbereitungsplots sinnvoll angeordnet? | Funktional ja, visuell noch zu linear. |
| Ist `starter_home` als Zentrum gut positioniert? | Ja fuer Startklarheit, aber zu stark als absoluter Kreuzungsmittelpunkt. |
| Ist `garden_west` sinnvoll am Starter-Haus? | Ja, der Wohn-/Gartenanschluss links wirkt plausibel. |
| Ist `path_south` sinnvoll als erster Weg? | Ja, aber die Weiterfuehrung nach unten wird zu stark vertikal. |
| Ist `function_seed_east` sinnvoll platziert? | Grundsaetzlich ja, aber sie verstaerkt die Kreuz-/Rasterwirkung. |
| Ist `hub_seed_south` zu linear unter dem Starterbereich? | Ja, es wirkt wie ein zweiter Knoten auf einer langen Mittelachse. |
| Haengt `market_square` zu weit unten und isoliert? | Ja. Der Markt wirkt wie ein langer vertikaler Schwanz. |
| Ist `water_edge_east` zu weit diagonal / kuenstlich angebunden? | Ja. Die Verbindung von `nature_north` wirkt zu lang und zu technisch. |
| Ist `farm_southwest` sinnvoll? | Inhaltlich ja, visuell etwas abgesetzt und noch nicht organisch eingebettet. |
| Ist `neighbor_west` sinnvoll als spaeterer Nachbarplot? | Ja, ueber `garden_west` gut nachvollziehbar. |
| Gibt es genug organische Inselwirkung? | Noch nicht. Die Aussenkante und Zwischenraeume wirken zu schematisch. |
| Gibt es genug Rand-/Natur-/Expansion-Raum? | Planerisch ja, visuell noch nicht als natuerliche Randlogik. |
| Wirkt das Layout zu sehr wie ein Brettspielraster? | Ja, besonders durch lange Achsen und gleichmaessige Plotabstaende. |
| Ist die Struktur fuer Mobile wahrscheinlich lesbar? | Labels sind gross lesbar, aber Gesamtstruktur koennte in Island View zu langgezogen wirken. |

## 5. Konkrete Schwächen

1. `market_square` haengt zu linear unter `hub_seed_south`.
   - Der Markt wirkt wie ein Endpunkt eines langen vertikalen Schwanzes.
   - Das Risiko ist eine zu hohe Inselhoehe ohne natuerliche Breite.

2. `water_edge_east` ist zu lang diagonal angebunden.
   - Die Verbindung ueber `nature_north` wirkt technisch und kuenstlich.
   - Ein Ufer braucht eine klare Inselkante oder einen Uebergangsplot.

3. `hub_seed_south` und `market_square` erzeugen zu viel vertikale Laenge.
   - Der Hauptweg wird zu einer Linie statt zu einem kleinen Inselnetz.
   - Mobile-Ansicht koennte zu stark herauszoomen muessen.

4. `starter_home` ist zu stark absoluter Mittelpunkt.
   - Fuer den Start ist das gut.
   - Fuer organisches Wachstum sollte es leicht aus der geometrischen Mitte
     herausruecken oder von Natur/Garten asymmetrisch gerahmt werden.

5. Die Struktur wirkt eher wie ein Netzdiagramm als wie eine Insel.
   - Der Nutzen als Debugbild bleibt.
   - Als Masterlayout ist die Form noch nicht organisch genug.

6. Aussenplots sind zu gleichmaessig verteilt.
   - Die geplante Inselkante bleibt unklar.
   - Expansion braucht natuerliche Randlogik statt nur Punkt-zu-Punkt-Linien.

7. Verbindungslinien bilden natuerliche Wege noch nicht gut ab.
   - Wege duerfen modular geplant sein, sollten aber spaeter leicht gebogen
     oder indirekt wirken.

## 6. Layout-Risiken

- Zu lineares Layout erzeugt spaeter eine lange, schmale Insel.
- Ein langer Markt-/Hub-Schwanz kann die Island-View-Kamera unnoetig weit
  herauszoomen lassen.
- Eine lange diagonale Wasserverbindung wirkt unnatuerlich, wenn kein
  Uebergangsplot dazwischenliegt.
- Ein zu symmetrisches Raster fuehlt sich nicht wie eine Waldlichtung-Insel an.
- Zu viele gleich grosse Plotabstaende koennen spaeter finale Kunst steif
  machen.
- Wenn die M4-Struktur ungeprueft bestaetigt wuerde, koennte `frame_started`
  erneut auf ein nicht belastbares Layout aufbauen.

## 7. Nachbesserungsprinzipien

Eine bessere organische Greybox soll:

- zentrale Starterzone erkennbar halten,
- Wege leicht gebogen oder indirekt denken,
- Hub/Market naeher an den Hauptweg bringen, aber nicht als langen Schwanz,
- Wasser/Ufer an eine klare Inselkante legen,
- Farm/Natur als Rand- oder Uebergangszone nutzen,
- Neighbor-Plot logisch ueber Wohn-/Gartenbereich anbinden,
- Expansion-Edges an natuerlichen Randstellen platzieren,
- intern modular bleiben, aber aeusserlich organisch wirken,
- keine perfekte Kreuz-/Rasterform erzwingen,
- keine langen Einzelverbindungen ohne Zwischenplot verwenden,
- `starter_home` als Startpunkt lesbar halten, aber nicht als einziges
  geometrisches Zentrum ueberhoehen.

## 8. Alternative Layout-Varianten

### Variante A: Moderate Nachbesserung

Ziel:

- Bestehende Struktur moeglichst wenig veraendern.
- `market_square` naeher an `hub_seed_south` ziehen.
- `water_edge_east` ueber einen besseren rechten Zwischenplot anbinden.

```text
              [nature_edge_nw] -- [nature_north]
                    |                  |
[neighbor_west*] -- [garden_west] -- [starter_home] -- [function_seed_east] -- [water_edge_east*]
                    |                  |                    |
              [farm_southwest*] -- [path_south] ----- [expansion_edge_se]
                                       |
                              [hub_seed_south] -- [market_square*]
```

Vorteile:

- Wenig Umplanung.
- Bestehende Starterstruktur bleibt erhalten.
- Markt haengt nicht mehr so tief.
- Wasser liegt klarer am rechten Rand.

Risiken:

- Die Grundform bleibt relativ rasterhaft.
- Rechts kann eine neue horizontale Kette entstehen.

Empfehlung:

```text
Geeignet als schnelle M5-Korrektur, aber nicht die staerkste organische Loesung.
```

### Variante B: Organischere Starter-Insel

Ziel:

- `starter_home` leicht aus dem geometrischen Zentrum nehmen.
- Garten/Natur rahmen den Wohnbereich.
- Hub/Market liegen seitlich-vorne statt tief unten.

```text
              [nature_edge_nw*] -- [nature_north] ---- [water_edge_east*]
                    |                  |
             [garden_west] ----- [starter_home] -- [function_seed_east]
                    |                  |              |
[neighbor_west*] -- [path_south] -- [hub_seed_south] -- [expansion_edge_se]
                                       |
                              [market_square*]
                    |
             [farm_southwest*]
```

Vorteile:

- Weniger langer vertikaler Schwanz.
- Starterbereich wirkt eher eingebettet.
- Hub/Market bleiben am Hauptweg, aber nicht als reine Achse.
- Wasser kann als rechte Kante gelesen werden.
- Neighbor bleibt ueber Wohn-/Gartenlogik erreichbar.

Risiken:

- Braucht eine neue Debug-Greybox, um Abstaende und Mobile-Lesbarkeit zu
  pruefen.
- `path_south` und `hub_seed_south` muessen sauber getrennt bleiben.

Empfehlung:

```text
Beste naechste M5-Variante fuer eine neue Debug-Greybox.
```

### Variante C: Staerker Zukunftsorientierte Ausbauinsel

Ziel:

- Wohnbereich, Marktbereich, Naturbereich und Wasser-/Randbereich klarer
  trennen.
- Die Starter-Insel bereitet die spaetere Ausbauinsel staerker vor.

```text
        [nature_edge_nw*] -- [nature_north] ---- [water_edge_east*]
              |                  |                    |
[neighbor_west*] -- [garden_west] -- [starter_home] -- [function_seed_east]
              |                  |                    |
        [farm_southwest*] -- [path_south] -- [hub_seed_south]
                                                   |
                                           [market_square*]
                                                   |
                                           [expansion_edge_se]
```

Vorteile:

- Deutlichere Bereiche fuer Wohnen, Natur, Funktion und Markt.
- Expansion laesst sich spaeter thematischer staffeln.
- Gut fuer langfristige Zonenlogik.

Risiken:

- Koennte erneut zu lang werden, wenn `market_square` und
  `expansion_edge_se` vertikal untereinander bleiben.
- Wirkt weniger kompakt fuer eine Starter-Insel.

Empfehlung:

```text
Als spaeterer Ausbauinsel-Entwurf interessant, fuer die naechste M5-Greybox
zu gross und noch zu linear.
```

## 9. Empfehlung

M4 sollte nicht unveraendert bestaetigt werden.

Empfohlene Entscheidung:

```text
M4 nachbessern / neue M5-Greybox-Variante erzeugen.
```

Empfohlener Kandidat:

```text
Variante B als naechste Debug-Greybox.
```

Begruendung:

- M4 ist technisch pruefbar, aber visuell zu linear/rasterhaft.
- `market_square` und `hub_seed_south` erzeugen eine zu lange Achse.
- `water_edge_east` braucht eine klarere Randlogik.
- Variante B reduziert die Achsenwirkung, haelt den Starterbereich lesbar und
  verteilt Hub/Market organischer.

Diese Empfehlung ist keine finale Layout-Freigabe.

## 10. Naechster Erlaubter Schritt

Erlaubt ist als naechstes:

- eine M5-Layoutvariante als neue Debug-Greybox planen oder erzeugen,
- bevorzugt auf Basis von Variante B,
- oder M4 nach weiterer manueller Nutzerpruefung bewusst bestaetigen, falls
  die lineare Struktur akzeptiert wird.

Weiterhin nicht erlaubt:

- finales Inselbild,
- neue Spielassets,
- PNGs im Asset-Ordner,
- `frame_started`,
- Bauzustands-Fortsetzung,
- Flutter-/Dart-Code,
- App-Integration,
- Tests,
- Persistenz,
- Supabase,
- SRS-/`word_progress`,
- Reward Bridge,
- Ressourcenlogik,
- Sound-/FX-Schicht,
- Expansion-System,
- PlacedItems,
- Interiors/ObjectDetail.

## 11. Stop-Regeln

Stoppen, wenn:

- eine Greybox als bestaetigt behandelt wird, obwohl sie zu linear oder
  rasterhaft wirkt,
- eine Market-/Hub-Struktur als langer isolierter Schwanz geplant wird,
- `water_edge_east` ueber eine unnatuerlich lange Diagonale ohne
  Uebergangsplot angebunden wird,
- Expansion ohne nachvollziehbare Randlogik geplant wird,
- Asset-Produktion gestartet wird, solange die Greybox nicht visuell
  bestaetigt ist,
- Bauzustaende weitergebaut werden, solange der `starter_home_plot` im
  bestaetigten Layout nicht feststeht,
- aus einem Debugdiagramm finale Inselkunst abgeleitet wird,
- `frame_started` wieder aufgenommen wird,
- Code geschrieben wird.

## 12. Akzeptanzkriterien

Dieses Dokument ist gut, wenn:

- die M4-Greybox sichtbar bewertet wurde,
- positive technische Ergebnisse benannt sind,
- visuelle Schwachstellen konkret sind,
- Nachbesserungsprinzipien vorliegen,
- mindestens zwei alternative Layouts verglichen werden,
- eine klare Empfehlung fuer den naechsten Debug-Schritt existiert,
- Assets und Code weiterhin blockiert bleiben.
