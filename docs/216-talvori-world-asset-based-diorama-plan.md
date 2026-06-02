# Talvori Welt Phase 2B: Asset-basierter Diorama-Plan

Stand: 2026-06-02

Dieses Dokument legt die naechste visuelle und technische Richtung fuer den lokalen Talvori-Welt-Screen fest.

Es ist ein reines Planungsdokument. Es wurden keine Dart-/Flutter-Dateien, keine Supabase-Daten, keine SQLite-/Vokabeldaten, keine SRS-Daten, kein `word_progress`, keine Reward Bridge, keine Secrets und keine Release-Artefakte geaendert.

## 1. Ausgangspunkt

Phase 2 funktioniert technisch:

- Der Globe-Tap fuehrt in einen lokalen Welt-Screen.
- `Talvori Ursprungshain` ist als Startregion vorhanden.
- Haus, Markt und Bibliothek sind sichtbar.
- Freie Grundstuecke und Mock-Ressourcen koennen lokal dargestellt werden.
- Ruecknavigation zur Home-Zentrale funktioniert.

Phase 2A hat die visuelle Zielrichtung dokumentiert:

- Cozy Learning World als schwebendes Diorama,
- hochwertige 2.5D-/Diorama-Anmutung,
- Haus, Markt und Bibliothek als Weltobjekte,
- freie Grundstuecke,
- Zoom/Pan,
- Portrait und Landscape,
- spaetere Erweiterbarkeit mit Freunden, Fremd-Plots, Bruecken und Schnellnavigation.

Der erste visuelle Umbau mit Flutter-Widgets, Icons und CustomPainter-Formen ist aber nicht ausreichend hochwertig. Der Screen wirkt trotz Diorama-Idee noch zu flach, zu app-artig und nicht wie eine echte kleine Welt.

## 2. Problem des aktuellen Ansatzes

Der aktuelle CustomPainter-/Widget-Diorama-Ansatz reicht visuell nicht aus.

Gruende:

- Flutter-Icons, einfache Shapes und CustomPainter-Flaechen erzeugen keine hochwertige Spielwelt-Tiefe.
- Gebaeude aus Standard-Icons wirken eher wie UI-Symbole als wie Weltobjekte.
- Landschaft aus einfachen Formen wirkt schnell flach und billig.
- Zu viel eigene Illustration im Code ist teuer, schwer zu pflegen und visuell begrenzt.
- Die gewuenschte Referenzqualitaet laesst sich so nicht realistisch erreichen.
- Weiteres Feintuning am flachen Ansatz wuerde wahrscheinlich Zeit kosten, ohne den Qualitaetssprung zu liefern.

Entscheidung:

Der aktuelle Code-Diorama-Ansatz darf als technische Zwischenstufe gelten, aber nicht als visuelle Grundlage fuer Talvori Welt.

## 3. Neue Zielarchitektur

Titel:

> Asset-basierte 2.5D-Diorama-Welt mit interaktiven Hotspots

Grundidee:

Flutter baut nicht die gesamte Welt aus einfachen Formen nach. Stattdessen nutzt Talvori eine hochwertige Weltillustration als visuelle Basis. Flutter uebernimmt Interaktion, Hotspots, Overlays, Navigation, Zoom/Pan und Zustand.

Ebenen:

| Ebene | Zweck |
| --- | --- |
| Hintergrundebene | Space, Nebel, Sterne, Tiefe hinter der Insel |
| Welt-Asset | Hochwertige schwebende Insel/Landschaft als Bild-/Illustrationsasset |
| Hotspot-Ebene | Haus, Markt, Bibliothek, freie Plots, Brueckenpunkte, spaetere Freunde/Fremd-Plots |
| Overlay-Ebene | Zurueck, Ressourcen, `Zu meinem Plot`, Freunde, Einstellungen/Weltkarte |
| Interaktionsebene | Zoom, Pan, Tap, spaeter Fokus/Sprung zu Plot |

Wichtig:

Die Welt soll wie ein Ort wirken. Flutter-Widgets sollen die Welt nicht ersetzen, sondern bedienbar machen.

## 4. Referenzbild-Regel

Das Beispielbild bleibt Qualitaetsreferenz.

Regeln:

- Nicht exakt kopieren.
- Keine fremden Assets ungeprueft uebernehmen.
- Keine kopierten Spielgrafiken.
- Keine externen Bilder ohne Lizenzklaerung.
- Ziel ist eine aehnlich hochwertige Wirkung.
- Das Ergebnis darf nicht wie eine flache App-Zeichnung wirken.
- Talvori braucht eine eigene Farbwelt und eine eigene Asset-Serie.

Stilrichtung:

- dunkel,
- cozy,
- cyan/lila/tuerkis,
- magisch,
- hochwertige 2.5D-Illustration,
- warme Lichtpunkte,
- klare Weltobjekte,
- ruhige Premium-Anmutung.

## 5. Asset-Strategie

### Kurzfristig

Fuer den naechsten visuellen Slice kann ein lokales Placeholder-/Prototype-Asset verwendet werden.

Anforderungen:

- rechtlich sauber nutzbar,
- nicht aus fremden Spielen kopiert,
- nicht aus dem Referenzbild uebernommen,
- ausreichend hochwertig, um den visuellen Ansatz zu pruefen,
- gut genug fuer Geraetetest und Produktgefuehl,
- noch nicht zwingend finale Talvori-Asset-Serie.

### Mittelfristig

Eigene generierte oder illustrierte Talvori-Weltassets:

- Ursprungshain-Insel,
- Gebaeudevarianten fuer Haus, Markt, Bibliothek,
- freie Bauplaetze,
- Bruecken-/Ankerpunkte,
- magische Naturdetails,
- spaetere Freundes-/Fremd-Plot-Andockpunkte.

Diese Assets sollen zur Talvori-Farbwelt passen und wiederverwendbar sein.

### Langfristig

Mehrere Landschafts-/Plot-Kacheln koennen verbunden werden:

- eigene Insel,
- Nachbarplots,
- Freundesplots,
- Fremdplots,
- regionale Erweiterungen,
- Bruecken oder magische Verbindungsstuecke.

Ziel:

Eine wachsende Welt, ohne dass jeder neue Bereich neu als kompletter Screen gebaut werden muss.

## 6. Technische UI-Struktur

Moegliche Struktur:

```text
LocalWorldScreen
├─ Stack
│  ├─ BackgroundLayer
│  ├─ InteractiveViewer
│  │  └─ WorldCanvas
│  │     ├─ WorldImageLayer
│  │     └─ HotspotLayer
│  │        ├─ BuildingHotspot Haus
│  │        ├─ BuildingHotspot Markt
│  │        ├─ BuildingHotspot Bibliothek
│  │        ├─ FreePlotHotspots
│  │        └─ BridgeAnchorHotspots
│  └─ OverlayControlLayer
│     ├─ BackButton
│     ├─ ResourceBar
│     ├─ MyPlotButton
│     ├─ FriendsButton
│     └─ Settings/MapButton
```

Technische Leitlinien:

- `WorldImageLayer` zeigt das Welt-/Inselasset.
- `HotspotLayer` liegt positionsgenau ueber demselben Koordinatensystem.
- Hotspots nutzen normalisierte Positionen oder Weltkoordinaten.
- Overlays liegen ausserhalb des zoombaren Inhalts, damit sie lesbar bleiben.
- Ressourcen bleiben dezent.
- Schnellnavigation ist ein eigener Control-Layer.

## 7. Zoom/Pan und Orientation

`InteractiveViewer` oder eine vergleichbare saubere Flutter-Loesung bleibt bevorzugt.

Regeln:

- Die Weltflaeche ist groesser als der Viewport.
- Portrait zeigt einen fokussierten Ausschnitt.
- Landscape zeigt einen breiteren Explore-Modus.
- Die Insel darf nicht gequetscht werden.
- Das Asset soll proportional skaliert werden.
- UI-Overlays duerfen die Weltmitte nicht verdecken.
- Hotspots muessen beim Zoomen/Pannen korrekt auf der Welt bleiben.

Phase 2B muss noch keine perfekte Kamera-Logik liefern. Sie muss aber verhindern, dass die Weltansicht wieder zu einem fixen Portrait-Dashboard wird.

## 8. Hotspot-Konzept

Hotspot-Typen:

| Typ | Bedeutung | Phase-2B-Rolle |
| --- | --- | --- |
| Eigenes Gebaeude | Haus, Markt, Bibliothek auf dem eigenen Plot | Sichtbar und tappbar als Mock-Hotspot |
| Freier Bauplatz | Noch leerer Plot-/Bauplatz | Sichtbar als freier Hotspot |
| Bruecken-/Verbindungsanker | Anschluss zu spaeteren Nachbarlandschaften | Sichtbar oder dezent vorbereitet |
| Freundes-Plot | Plot eines Freundes | Spaeter; in Phase 2B nur UI-Platzhalter moeglich |
| Fremd-Plot | Plot eines anderen Nutzers | Spaeter; nur architektonisch mitdenken |

Jeder Hotspot braucht spaeter mindestens:

- `id`
- `type`
- `label`
- `normalizedPosition` oder `worldPosition`
- optional `targetAction`
- optional `locked/unlocked` state

Fuer Phase 2B reicht lokaler Mock-State.

Keine Hotspot-Aktion darf in Phase 2B echte Ressourcen verbrauchen, Supabase schreiben oder SRS/`word_progress` veraendern.

## 9. Schnellnavigation

Wenn die Welt groesser wird, braucht der Nutzer jederzeit Orientierung.

Pflicht fuer spaetere groessere Welten:

- `Zu meinem Plot`
- schneller Sprung zu Freunden
- Freund antippen und direkt dessen Grundstueck oeffnen
- optional Weltkarte oder Regionsuebersicht

Phase 2B:

- UI-Platzhalter oder Mock-Control fuer `Zu meinem Plot`,
- UI-Platzhalter fuer Freunde,
- kein Social-Backend,
- keine echte Freundesnavigation,
- keine Cloud-Abfrage.

Die Schnellnavigation gehoert in den `OverlayControlLayer`, nicht tief in einzelne Plot-Widgets.

## 10. Phase-2B-Ziel

Phase 2B soll den aktuellen flachen Diorama-Screen ersetzen durch:

- asset-basierte Inselansicht,
- `InteractiveViewer` mit Zoom/Pan,
- Hotspots fuer Haus, Markt und Bibliothek,
- freie Grundstuecke als Hotspots,
- dezente Ressourcen-Overlays,
- Schnellnavigation-Controls als UI-Platzhalter,
- keine echte Persistenz oder Backend-Logik.

Der wichtigste Qualitaetssprung:

> Der Screen muss beim Globe-Tap wie eine kleine Talvori-Welt wirken, nicht wie eine App-Zeichnung.

## 11. Scope-Grenzen

Weiterhin ausgeschlossen:

- keine Supabase Writes,
- keine SQLite-/SRS-/`word_progress`-Aenderungen,
- keine Reward Bridge,
- keine echte Ressourcen-Persistenz,
- keine Cloud-Welt,
- kein Social-Backend,
- keine echte Oekonomie,
- keine Multiplayer-Funktion,
- keine fremden Assets ohne Lizenz,
- keine grosse 3D-Engine,
- keine neuen Packages ohne ausdrueckliche Freigabe.

## 12. Akzeptanzkriterien

Phase 2B gilt als gelungen, wenn:

- Der Screen wirkt deutlich naeher an der Referenzqualitaet.
- Die Welt hat sichtbare Tiefe durch Asset/Illustration.
- Haus, Markt und Bibliothek sind als Hotspots auf der Welt erkennbar.
- Freie Grundstuecke sind sichtbar.
- Zoom/Pan funktioniert.
- Portrait wirkt nicht gequetscht.
- Landscape ist vorbereitet.
- Overlays dominieren die Welt nicht.
- Der Screen wirkt nicht wie eine Liste.
- Der Screen wirkt nicht wie ein Dashboard.
- Der Screen wirkt nicht wie eine flache App-Zeichnung.
- Supabase/SQLite/SRS/`word_progress` bleiben unangetastet.

## 13. Umgang mit aktuellem uncommitted Code

Der aktuelle uncommitted Phase-2A-Code darf als technische Zwischenstufe betrachtet werden.

Entscheidung fuer den naechsten Implementierungsblock:

- Der aktuelle flache Ansatz soll nicht weiter als visuelle Grundlage verfeinert werden.
- Der naechste Implementierungsblock soll ihn ersetzen oder stark umbauen.
- Vor Commit muss entschieden werden, ob der aktuelle flache Ansatz verworfen oder direkt durch Phase 2B ueberschrieben wird.
- Wertvoll bleiben:
  - Globe-Tap-Navigation,
  - Ruecknavigation,
  - lokale Screen-Struktur,
  - Tests fuer LocalWorldScreen,
  - Mock-Ressourcen,
  - Hotspot-/Plot-Grundidee,
  - `InteractiveViewer`-Richtung.

Nicht wertvoll als finale Richtung:

- Gebaeude aus Standard-Icons,
- Landschaft aus einfachen Code-Shapes,
- flache CustomPainter-Insel als Hauptqualitaetstraeger.

