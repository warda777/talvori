# Firenze V5 Handoff Layers

Status: `documentation_only` / `not_runtime_data` / `not_asset` / `not_engine_ready`

## Zweck

Dieser Ordner enthält die vorbereiteten SVG-Handoff-Layer für den Firenze-Blueprint v5. Die Dateien dienen ausschließlich der Planung, Prüfung und Dokumentation der spielbaren Stadtfläche. Sie sind keine finalen Spielassets und dürfen nicht direkt als Runtime-Daten oder Flutter-Implementierung behandelt werden.

## Ordnerstruktur

```text
handoff_layers/
  boundary/
  river/
  streets/
  parcels/
  landmarks/
  README.md
```

## Layer-Familien

### boundary

Enthält die Florenz-Grenze als sichtbare Außenlinie, geschlossene spielbare Gesamtfläche und Randpuffer. Diese Dateien definieren, was grundsätzlich innerhalb der Firenze-Spielzone liegt und welcher Randbereich nicht begehbar oder nicht bebaubar sein soll.

### river

Enthält den Arno als Seitenlinien, geschlossene Wasserfläche und Mittellinie. Die geschlossene Wasserfläche ist für die Planung wichtig, weil Wasser als `no_walk` und `no_build` gilt. Querungen dürfen später nur über freigegebene Brücken erfolgen.

### streets

Enthält Straßen-/Wegeflächen, Mittellinien und Knotenpunkte. Diese Layer dienen zur Prüfung der Erreichbarkeit, Wegeführung, Kreuzungen und späteren Navigation. Sie sind noch keine Runtime-Navigation.

### parcels

Enthält die Grundstücksflächen P01–P14 mit Outlines, gefüllten Buildable Areas, Innenzonen, No-Build-Clearance und Ankern. Diese Flächen sind Kandidaten für spätere bebaubare Grundstücke, aber noch keine final freigegebenen BuildStates.

### landmarks

Enthält reservierte Sehenswürdigkeitsflächen für L1–L5 mit Reserve-Outlines, Protected Core Areas, Interaction Zones, Collision-/No-Build-Buffer und Anchors. Diese Flächen sind keine normalen Baugrundstücke. Sie sind für Florenz-Identität und Sightseeing reserviert.

## Stop-Regel

Aus diesen SVGs entsteht noch keine App-Implementierung. Es darf daraus noch kein Flutter-Code, keine Runtime-Geometrie, keine Persistenz und kein finales Asset unter `assets/` erzeugt werden.

## Nächster erlaubter Schritt

Der nächste erlaubte Schritt ist ein Review der Layer-Konsistenz. Danach darf ein Metrics-/Reachability-/Collision-Review geplant werden. Erst nach dieser Prüfung darf ein späterer City-Entry- oder Runtime-Slice vorbereitet werden.

## Mindestprüfung vor jedem Folge-Slice

Vor jedem weiteren Firenze-/City-Entry-Slice muss geprüft werden:

- Liegt jede Parcel-Fläche innerhalb der `playable_boundary_area`?
- Überschneiden sich Parcels, Landmark-Reserves, River oder Street-Korridore unzulässig?
- Sind alle Early-Parcels über Streets/Paths erreichbar?
- Liegt kein Buildable Parcel im River-, Landmark- oder Boundary-Buffer?
- Sind Landmark-Zonen weiterhin reserved-only und no-build?
- Sind Flussquerungen nur über B1–B3 erlaubt?
- Bleiben alle Layer `documentation_only`, solange kein eigenes Runtime-Gate freigegeben wurde?
