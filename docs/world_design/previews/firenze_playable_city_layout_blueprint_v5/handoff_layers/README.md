# Firenze V5 Handoff Layers

Status: `documentation_only` / `not_runtime_data` / `not_asset` /
`not_engine_ready` / `no_app_integration`

Diese Handoff-Layer gehoeren zum Firenze playable city layout blueprint v5.
Sie sind planning-only Area-Spec-Layer fuer Review und Folgeplanung. Sie sind
keine App-Dateien, keine Runtime-Geometrie, keine finalen Koordinaten und keine
Engine-ready Assets.

## Ordner

| Ordner | Inhalt | Planungszweck |
| --- | --- | --- |
| `boundary/` | Stadtgrenze, spielbare Flaeche und Randpuffer | Prueft, ob Firenze als groessere Florenz-orientierte Boundary lesbar bleibt und wo No-Walk/No-Build-Randpuffer beginnen. |
| `river/` | Arno-Seitenlinien, geschlossene Wasserflaeche und Mittellinie | Trennt Wasser als `no_walk` + `no_build` von Bruecken- und Uferlogik. |
| `streets/` | Strassen-/Wegeflaechen, Mittellinien und Knotenpunkte | Prueft organische PATH-N/PATH-S-, Connector-, Branch- und Future-Path-Logik. |
| `parcels/` | Grundstuecksflaechen, Innenzonen, Puffer und Anker | Prueft 14 Parcel Candidates, Subzonen, Access Points, Clearance und No-Overlap. |
| `landmarks/` | Reservierte Sehenswuerdigkeitsflaechen, Kern, Interaktion, Puffer und Anker | Prueft L1-L5 Landmark-Identitaet, Schutzraeume und spaetere Interaktionskandidaten. |

## Stop-Regel

Aus diesen SVGs entsteht noch keine App-Implementierung. Kein Layer darf als
Runtime-Polygon, Koordinate, Collision, Pathfinding, Build-Zone, No-Walk-/
No-Build-Maske, Asset, App-Route, YAML/JSON oder Persistenz gelesen werden.

## Naechster erlaubter Schritt

Naechster erlaubter Schritt ist ein Review der Layer-Konsistenz. Danach darf
ein eigener Metrics-/Reachability-/Collision-Review-Slice folgen. Eine
Flutter-City-Entry-Preview bleibt bis dahin blockiert.
