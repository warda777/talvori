# Phase 2G-M12-E Mobile And Clutter Rules Preview

Stand: 2026-06-06

Status: `Preview erzeugt / visuelle Pruefung offen`

## Zweck

Diese Preview-Dateien visualisieren erste Mobile- und Clutter-Regeln fuer
kleine Objekte, Deko, Container-Inhalte und Detailobjekte in Talvori. Sie
zeigen, wie kleine Lernwoerter ueber Depth, Container, Fokus, Codex, Blueprint
oder Backlog gelenkt werden koennen, statt Mobile-Ansichten dauerhaft zu
ueberladen.

Die Dateien sind:

- Dokumentationsmaterial,
- Debug-/Planungsmaterial,
- keine finale UI,
- keine finale Datenstruktur,
- keine Spielassets,
- keine App-Integration,
- keine Container-Implementierung,
- keine Assetfreigabe,
- keine Freigabe fuer `frame_started`.

## Dateien

1. `01_mobile_clutter_depth_ladder.png`
   - zeigt IslandView, PlotView, InteriorView, ContainerOpenView und
     DetailInteractionView mit ersten Planungsgrenzen.
2. `02_small_object_routing_matrix.png`
   - zeigt Clutter-Kategorien gegen Ziel-Ebenen wie Island, Plot, Interior,
     Container, Detail und Codex/Backlog.
3. `03_container_clutter_examples.png`
   - vergleicht gute und riskante Container-Beispiele fuer Schublade und
     Federmappe.
4. `04_mobile_stop_gates.png`
   - zeigt Stop-Gates fuer zu kleine Objekte, zu viele Labels, unklare
     Tap-Ziele, verdeckende Deko, sensitiveSmallObjects und Objektlisten-
     Container.

## Prueffazit

Die Previews machen sichtbar:

- TinyObjects gehoeren nicht dauerhaft in die IslandView.
- Kleine Objekte brauchen passende Depth, Zoom, Container oder Detailansicht.
- Container sollen wenige Challenge-Objekte zeigen, nicht ganze Objektlisten.
- Labels sind Fokus-/Challenge-/Accessibility-Hilfen, keine dauerhafte
  Beschriftungswolke.
- Deko bleibt ruhiger Hintergrund und darf Lernobjekte nicht verdecken.
- SensitiveSmallObjects folgen zusaetzlich M12-D.
- Codex, Blueprint und Backlog sind sichere Fallbacks bei Clutter-Gefahr.

## Sichtbare Risiken

- Die Planungswerte sind keine finalen Runtime-Werte.
- Die Matrix ist fuer interne Planung gedacht, nicht als Nutzeransicht.
- Spaeter braucht es echte Mobile-Device-Previews.
- Tap-Zielgroessen, Accessibility-Modus, Pagination und Container-UX brauchen
  spaetere eigene Pruefung.
- M12-E erzeugt keine Container-Implementierung und keine Spielassets.

## Grenzen

Nicht ableiten:

- keine finale Mobile-UI,
- keine finale Datenstruktur,
- keine finale Runtime-Konfiguration,
- keine Kleinteile-/Container-Implementierung,
- keine ThemeIsland-Umsetzung,
- keine App-Integration,
- keine Spielassets,
- keine automatische Wortplatzierung,
- keine Assetfreigabe,
- kein `frame_started`.

## Naechster Schritt

Erlaubt:

- M12-E visuell pruefen,
- M12-E bei Bedarf nachbessern,
- spaeter Mobile-/Clutter-Device-Previews planen.
