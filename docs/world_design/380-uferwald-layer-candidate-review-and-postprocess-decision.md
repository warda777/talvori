# M16-CQ: Uferwald Layer Candidate Review and Postprocess Decision

Status: `review_decision / documentation only`
Candidate status remains: `layer_postprocess_candidate`
Commit status: no commit in this slice

## 1. Zweck

M16-CQ reviewed den abgeschlossenen M16-CP/M16-CP2-Uferwald-`island_base`-
Layer-Postprocess-Candidate und entscheidet, wie er fachlich weitergefuehrt
werden soll.

M16-CQ erzeugt keine neuen Bilder, keine neuen Exporte, keine Assets, keine
transparenten Layer und keinen Code. Der Slice dokumentiert nur Review,
Entscheidung, Risiken und den naechsten sinnvollen Postprocess-Schritt.

## 2. Gepruefte Grundlage

Geprueft wurden:

- `379-uferwald-layer-candidate-intake-and-qa.md`
- `talvori_island_base_uferwald_structure_postprocess_candidate_v1_1x.png`
- `talvori_island_base_uferwald_structure_postprocess_candidate_v1_2x.png`
- `talvori_island_base_uferwald_structure_postprocess_candidate_v1_3x.png`
- `talvori_uferwald_layer_postprocess_contact_sheet_1x.png`
- `talvori_uferwald_layer_postprocess_metadata.md`
- `talvori_uferwald_layer_postprocess_anchor_manifest.md`
- `talvori_uferwald_layer_postprocess_qa.md`

Die Preview-Dateien liegen nur unter:

```text
docs/world_design/previews/m16_cp_uferwald_layer_candidate_intake_and_qa/
```

## 3. M16-CP-Ergebnis

M16-CP/M16-CP2 ist fachlich vollstaendig genug fuer einen Review-Decision-
Slice:

- 1x ist als Source of Truth vorhanden: 1254 x 1254.
- 2x und 3x sind Pillow-`Image.Resampling.LANCZOS`-Review-Kopien.
- Das Contact Sheet ist lesbar und markiert den Status als Dokumentation.
- Metadata, Anchor Manifest und QA sind vorhanden.
- Der Status bleibt `layer_postprocess_candidate`.
- Es gibt keine echten transparenten Layer.
- Es gibt keine echten separaten Layer.
- Es gibt keine Engine-ready-Freigabe.
- Es gibt keine Dateien unter `assets/`.

## 4. Visuelle Bewertung

| Frage | Bewertung | Begruendung |
| --- | --- | --- |
| Passt die Insel zur Talvori-Richtung? | JA | Sie liest als warme, hochwertige 2.5D-Cozy-Island-Welt und nicht als Web-/Worksheet-Fluss. |
| Wirkt sie wie Cozy Island Diorama Builder? | JA | Insel, Wasser, Hain, Klippen und Lichtungen bilden zuerst einen Ort, nicht eine UI. |
| Organischer als alte runde Grundstuecksflächen? | JA | Die Reserveflaechen wirken landschaftlich eingebettet und nicht wie sichtbare Plot-Kreise. |
| Genug Platz fuer spaetere Kategorien? | JA | Zentrale, noerdliche, suedliche und oestliche Reserven sind sichtbar, ohne Kategorien festzulegen. |
| Vorparzellierung sichtbar? | NEIN | Es gibt keine Pins, Marker, Kategoriepads oder harten Haus-/Markt-/Werkstattplaetze. |
| Zentrale Bau-/Hub-Zone brauchbar? | JA | Die zentrale Wiese plus Wege-/Wassernaehe ist als Hub gut lesbar. Sie braucht aber spaeter Overlay-/No-Overlap-Regeln. |
| Wald/Hain lesbar? | JA | Der dichte obere/rechte Baumbereich gibt Uferwald eine klare Identitaet und eignet sich als No-Build-/terrain-sensitive Zone. |
| Wasser/Fluss/Kueste lesbar? | JA | Wasserfall, Flussarm, Muendung und Kueste sind stark genug fuer spaetere `water_paths`-Planung. |
| Klippen und Reservebereiche lesbar? | JA | Hoehen, Felsen und ruhigere Randbereiche geben Tiefe und Reserven. |
| Zoom-out brauchbar? | JA | Silhouette, Wasserstruktur, Hain und Hauptlichtung bleiben erkennbar. |
| Mid-Zoom brauchbar? | JA | Hauptreserven, Flussstruktur und Hain-/No-Build-Bereiche sind reviewbar. |
| Zoom-in produktionsreif? | NEIN | Painterly Details bleiben monolithisch; 2x/3x sind nur Review-Kopien. |
| Echte Layerbarkeit schon gegeben? | NEIN | Wasser, Terrain, Licht, Baeume, Felsen und Wege sind in einem RGB-Bitmap eingebettet. |

## 5. Name- und Terminologie-Entscheidung

| Entscheidung | Ergebnis |
| --- | --- |
| `Uferwald` bleibt als Arbeitsname fuer diesen Candidate | JA |
| `Uferhain` bleibt als alte Linie / bestehende Referenz | JA |
| Kuenftige Dateinamen fuer direkte Folgearbeit an diesem Candidate | `uferwald` |
| Finale Produkt-/Inselbenennung entschieden | NEIN |

Begruendung:

- `Uferwald` passt zur staerkeren Wald-/Hain- und Flussufer-Lesbarkeit dieses
  Kandidaten.
- `Uferhain` bleibt als bestehende Design- und Docs-Linie wichtig und wird
  nicht per M16-CQ umbenannt.
- Fuer direkte Folgearbeit an diesem konkreten PNG und seinen Postprocess-
  Briefs soll `uferwald` in Dateinamen bleiben, damit Quelle, Review und
  spaetere Entscheidungen nachvollziehbar bleiben.
- Eine finale Produkt- oder Inselbenennung braucht ein eigenes Naming- oder
  Product-Decision-Gate, falls sie relevant wird.

## 6. Anchor- und Placement-Bewertung

Das Anchor Manifest ist fuer Review und Folgebriefing ausreichend:

- `main_build_area_anchor`, `hub_center_anchor` und `house_primary_anchor`
  liegen plausibel im zentralen Bau-/Hub-Bereich.
- `river_entry_anchor` und `river_exit_anchor` beschreiben die Wasserlogik.
- `grove_anchor` sichert den Wald-/No-Build-Charakter.
- `reserve_zone_anchor_north` und `reserve_zone_anchor_south` halten
  langfristige Erweiterungsbereiche fest.

Grenze:

Alle Koordinaten bleiben `measured_on_candidate_bitmap_not_final_runtime_anchor`.
Sie sind keine Runtime-Daten, keine BuildState-Logik und keine Engine-ready
Placement-Information.

## 7. Zoom- und Scale-Bewertung

| Ebene | Bewertung | Entscheidung |
| --- | --- | --- |
| 1x | Gut fuer Source-of-Truth, Review und breite mobile Lesbarkeit. | Beibehalten. |
| 2x | Gut fuer Scale-Review und naeheren Blick; kein neuer Detailgehalt. | Als Review-Kopie beibehalten. |
| 3x | Hilfreich fuer Inspektion; zeigt aber auch Monolith-/Detailrisiken. | Als Review-Kopie beibehalten. |
| Zoom-out | Lesbar. | Geeignet fuer Flow-/Map-Gefuehl. |
| Mid-Zoom | Lesbar. | Geeignet fuer Anchor-/Zone-Diskussion. |
| Zoom-in | Nur eingeschraenkt. | Nicht fuer Produktion oder Detailapproval geeignet. |

## 8. Layer-Readiness-Bewertung

| Frage | Ergebnis |
| --- | --- |
| Flaches `island_base`-Bitmap vorhanden | JA |
| Echte transparente Layer vorhanden | NEIN |
| Echte separate Layer vorhanden | NEIN |
| `water_paths` als eigene Datei vorhanden | NEIN |
| `terrain_layers` als eigene Datei vorhanden | NEIN |
| `slot_markers` als eigene Datei vorhanden | NEIN |
| Engine-ready Candidate vorhanden | NEIN |
| Approved Asset vorhanden | NEIN |

Der Candidate ist als Struktur- und Postprocess-Referenz geeignet, aber nicht
als Pixelziel. Externe Layerarbeit darf ihn nur als Struktur-/Stimmungs- und
Registration-Referenz verwenden, nicht als direkt zu zerschneidende
Produktionsgrafik.

## 9. Entscheidung

| Entscheidung | Ergebnis |
| --- | --- |
| Candidate weiterfuehren | JA |
| Als Struktur-/Postprocess-Referenz weiterfuehren | JA |
| Als Pixel-/Asset-Ziel uebernehmen | NEIN |
| Als Engine-ready Basis uebernehmen | NEIN |
| Fuer spaetere externe Layerarbeit geeignet | TEILWEISE |
| Neue Bildvariante jetzt noetig | NEIN |
| Direkte Flutter-/App-Arbeit danach sinnvoll | NEIN |

Interpretation:

Uferwald ist die derzeit staerkste Struktur-/Postprocess-Referenz fuer die
Starter-Insel-Basis. Er soll weitergefuehrt werden, aber nur ueber einen
kontrollierten Overlay-/Layer-/Postprocess-Pfad.

## 10. Naechster Layer-Schritt

Empfohlene Option: Option A, Figma-/Overlay-Plan fuer Anchors, Zonen und Layer.

Empfohlener Folge-Slice:

```text
M16-CR Uferwald Anchor, Zone and Layer Overlay Plan
```

Der Folge-Slice soll zuerst die sichtbare Struktur in ein klares Overlay-Modell
uebersetzen:

- Anchor Points sichtbar machen,
- Buildable Footprint, Soft Placement, Reserve, No-Build, No-Overlap,
  Water-only und terrain-sensitive Zones abgrenzen,
- Layer-Reihenfolge und Sort-Bands auf der Kandidatenstruktur pruefen,
- entscheiden, welche spaeteren externen Layer wirklich gebraucht werden.

Warum nicht die anderen Optionen zuerst:

- Option B, externer Paintover-/Layer-Separation-Brief: sinnvoll, aber erst
  nach einem klaren Overlay, damit externe Arbeit nicht wieder nach Gefuehl
  trennt.
- Option C, erneute Bildvariante: aktuell nicht noetig, weil Uferwald als
  Strukturreferenz stark genug ist.
- Option D, Water-Paths-Layer vorbereiten: zu frueh, solange Zonen, Anchors
  und No-Overlap noch nicht visuell/strukturell bestaetigt sind.
- Option E, Terrain-/No-Build-Overlay visualisieren: wichtig, aber als Teil
  von Option A besser eingebettet als als isolierter Terrain-Schritt.

## 11. Risiken

- Der starke Gesamteindruck koennte als Asset-Freigabe missverstanden werden.
- Die offenen Wiesen koennten in spaeterer Arbeit wieder zu festen
  Kategorieplaetzen werden.
- 2x/3x Review-Kopien koennten faelschlich als Produktionsqualitaet gelesen
  werden.
- Wasser, Hain, Licht, Felsen und Wege sind aktuell monolithisch und muessen
  vor echter Layerarbeit getrennt geplant werden.
- `Uferwald` darf nicht still den Produktnamen ersetzen; es bleibt vorerst ein
  Kandidaten-Arbeitsname.

## 12. Nicht-Freigaben

M16-CQ gibt nicht frei:

- keine Asset-Freigabe,
- keine Engine-ready-Freigabe,
- keine App-/Code-Freigabe,
- keine `assets/`-Freigabe,
- keine echten separaten Layer,
- keine echten transparenten Layer,
- keine Figma-/externen Writes,
- keine neue KI-Bildgenerierung,
- keine Flutter-/Dart-Dateien,
- keine Route,
- keine Navigation,
- keine Persistenz,
- kein `BuildState`,
- keine Tests,
- kein Commit.
