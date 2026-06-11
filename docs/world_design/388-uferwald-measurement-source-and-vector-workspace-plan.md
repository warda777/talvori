# M16-DE: Uferwald Measurement Source and Vector Workspace Plan

Stand: 2026-06-11

Status: `Docs-/Format-Decision-Gate / keine Vector-Dateien`

Template: `docs/world_design/prompt_templates/docs_only_slice.md`

## 1. Zweck

M16-DE entscheidet, welches Arbeitsformat der naechste Uferwald-Mess- und
Vector-Plan nutzen soll. Das Ziel ist eine klare Formatentscheidung, bevor
echte SVG-, Polygon-, JSON/YAML-, Figma- oder Runtime-Dateien entstehen.

M16-DE erzeugt keine Koordinaten, keine Polygon-Dateien, keine Bilder, keine
SVG/PNG-Dateien, keine Assets, keine Figma-Writes, keine Runtime-Mapdaten und
keinen Code.

## 2. Eingangsquellen

Fuehrende Quellen:

- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
- `docs/world_design/370-asset-family-and-export-spec.md`
- `docs/world_design/379-uferwald-layer-candidate-intake-and-qa.md`
- `docs/world_design/381-uferwald-anchor-zone-layer-overlay-plan.md`
- `docs/world_design/384-uferwald-playable-map-layer-and-mask-architecture.md`
- `docs/world_design/385-uferwald-technical-layer-and-mask-spec.md`
- `docs/world_design/386-uferwald-technical-layer-manifest.md`
- `docs/world_design/387-uferwald-technical-measurement-and-vector-planning-gate.md`

Diese Quellen definieren: Uferwald braucht technische Layer/Masks/Zonen vor
spielbarer Karte. Das sichtbare Uferwald-Bild und die bisherigen Overlays sind
Review-Kontext, nicht technische Quelle.

## 3. Entscheidungskriterien

M16-DE bewertet vier moegliche naechste Formate nach:

- Verstaendlichkeit fuer Andreas,
- technische Weiterverwendbarkeit,
- Risiko fuer falsche Runtime-Freigabe,
- Visual-QA-Moeglichkeit,
- Aufwand,
- spaetere Flutter-/Asset-/Runtime-Kompatibilitaet.

Die Entscheidung muss zugleich die M16-DA- bis M16-DD-Grenzen schuetzen:

- keine technische Ableitung aus Pixelbildern,
- keine finalen Koordinaten,
- keine Runtime-Mapdaten,
- keine Assets,
- keine App-Integration.

## 4. Optionenvergleich

| Option | Verstaendlichkeit fuer Andreas | Technische Weiterverwendbarkeit | Risiko fuer falsche Runtime-Freigabe | Visual-QA-Moeglichkeit | Aufwand | Spaetere Flutter-/Asset-/Runtime-Kompatibilitaet |
| --- | --- | --- | --- | --- | --- | --- |
| Markdown-only | Hoch: Regeln, Reihenfolge und Entscheidungen bleiben lesbar. | Mittel: gut fuer Spec/Review, schwach fuer Geometrie. | Niedrig: schwer als Runtime-Daten misszuverstehen. | Niedrig bis mittel: keine echte raeumliche Pruefung. | Niedrig. | Mittel: guter Vertrag, aber keine Geometriequelle. |
| SVG-Plan | Hoch, wenn als beschriftetes Dokumentationsvisual gebaut. | Hoch fuer Vector-Review und spaetere manuelle Uebertragung. | Mittel: muss klar `documentation_only` bleiben. | Hoch: Layer, Masks, Zonen und Labels visuell pruefbar. | Mittel. | Hoch als Planungsquelle, aber nicht direkt Runtime ohne Folge-Gate. |
| Figma-Plan | Hoch fuer visuelle Zusammenarbeit, falls sauber aufgebaut. | Hoch fuer Designer/Artist-Workflow. | Mittel bis hoch: Figma kann als "fertiges Design" missverstanden werden. | Hoch. | Mittel bis hoch; braucht Tool-/Write-Freigabe. | Hoch fuer Designarbeit, aber kein Runtime-Format. |
| JSON/YAML-Planungsstruktur | Niedrig bis mittel: gut fuer technische Review, weniger visuell. | Hoch als spaeteres Manifest-Vorformat. | Hoch: kann zu frueh als Runtime-Daten gelesen werden. | Niedrig: ohne Visual schwer zu pruefen. | Mittel. | Sehr hoch spaeter, aber erst nach visueller und fachlicher Mess-QA. |

## 5. Bewertung

### Markdown-only

Markdown-only ist der sicherste Weg fuer Regeln, Grenzen, Reihenfolge und
Review-Entscheidungen. Es ist aber als naechster alleiniger Schritt zu schwach,
weil Uferwald jetzt raeumliche Fragen klaeren muss: Wassergrenzen, echte Wege,
Hain-/Felsblocker, Build-Zonen, No-Walk/No-Build und Sort-Bands muessen
sichtbar gegeneinander geprueft werden.

Entscheidung: Als begleitende Source-of-Truth-Dokumentation behalten, aber
nicht alleiniger naechster Messplan.

### SVG-Plan

Ein SVG-Plan ist fuer den naechsten Schritt am staerksten, wenn er ausdruecklich
als Dokumentationsvisual gebaut wird. Er kann den Uferwald-1x-Kandidaten oder
eine neutrale Canvas als Hintergrund/Referenz nutzen und technische Overlays
sichtbar trennen:

- harte Inselkontur,
- Wasser,
- Hain-/Felsblocker,
- begehbare Pfadkorridore,
- organische Build-Zonen,
- No-Walk/No-Build,
- Sort-Bands,
- Landmark-Anker.

Wichtig: Das SVG darf nicht als Runtime-Geometrie freigegeben werden. Es muss
sichtbar `documentation_only`, `not_runtime_data`, `not_asset` und
`not_engine_ready` markieren.

Entscheidung: Als naechstes Arbeitsformat empfohlen, aber erst in eigenem
Folge-Slice erzeugen.

### Figma-Plan

Ein Figma-Plan waere fuer spaetere Zusammenarbeit mit Design/Artist stark.
Aktuell ist er aber nicht der beste naechste Schritt, weil M16-DE keinen
externen Write oeffnet und das Repo weiterhin Source of Truth bleiben soll.
Ausserdem waere ein Figma-Board schnell visuell ueberzeugend und koennte
faelschlich als Design- oder Asset-Freigabe gelesen werden.

Entscheidung: Noch kein Figma-Write. Figma kann spaeter nach SVG-/Markdown-
Review oder mit eigenem Tool-/Write-Gate sinnvoll sein.

### JSON/YAML-Planungsstruktur

JSON/YAML ist spaeter wichtig, sobald aus den Review-Geometrien ein
maschinennaeheres Manifest entstehen soll. Als direkter naechster Schritt ist es
zu frueh: Ohne visuelle QA wuerde eine strukturierte Datei schnell wie
Runtime-Daten wirken und koennte Fehler in Pfaden, Masks oder Zonen
verfestigen.

Entscheidung: Noch kein JSON/YAML als technische Datenstruktur. Nur
Feldnamen/Schema-Ideen in Markdown oder SVG-Labels, keine Runtime-Mapdaten.

## 6. Entscheidung

Naechster Schritt:

```text
Markdown + SVG-Plan als Dokumentationsvisual
```

Genauer:

- Markdown bleibt das fuehrende Entscheidungs- und QA-Dokument.
- Ein SVG-Plan darf im naechsten ausdruecklich freigegebenen Visual-/Docs-Slice
  als Dokumentationsvisual entstehen.
- Das SVG darf technische Ebenen sichtbar machen, aber keine Runtime-Geometrie
  freigeben.
- Es gibt noch keinen Figma-Write.
- Es gibt noch kein JSON/YAML als Runtime- oder Manifest-Datenquelle.
- Es gibt noch keine finalen Koordinaten.

## 7. Begruendung

Markdown + SVG-Plan ist der beste Zwischenweg:

- Andreas kann die Mess-/Zonenlogik visuell pruefen.
- Codex kann SVG im Repo als Dokumentationsmaterial erzeugen und per Visual-QA
  pruefen, wenn ein Folge-Slice es ausdruecklich erlaubt.
- Das Risiko bleibt kontrollierbar, weil SVG klar als Planungsvisual markiert
  werden kann.
- JSON/YAML wird nicht zu frueh als Runtime-Daten missverstanden.
- Figma bleibt optional fuer spaetere Zusammenarbeit, ohne jetzt externe Writes
  zu oeffnen.

## 8. Anforderungen an den naechsten SVG-Plan-Slice

Ein spaeterer SVG-Plan-Slice muss mindestens:

- `387` und `388` lesen,
- den erlaubten Preview-/Docs-Pfad explizit nennen,
- SVG/PNG-Erzeugung ausdruecklich erlauben,
- kein Figma-Write ohne separate Freigabe ausloesen,
- keine finalen Koordinaten behaupten,
- jede Ebene als `planning_overlay` oder `documentation_only` markieren,
- Labels lesbar halten,
- No-Walk und No-Build getrennt zeigen,
- Build-Zonen als organische Eignungsraeume zeigen, nicht als feste Slots,
- Pfade als Vorschlagskorridore zeigen, nicht als Runtime-Pathfinding,
- Sort-Bands grob visualisieren, nicht als Renderer-Implementation,
- im Dokument klar sagen: keine Runtime-Mapdaten.

## 9. Was weiter blockiert bleibt

Weiter blockiert:

- Figma-Writes,
- JSON/YAML-Runtime-Manifest,
- echte Polygon-Dateien als technische Datenquelle,
- finale Koordinaten,
- App-/Flutter-Integration,
- Assets oder Dateien unter `assets/`,
- Engine-ready Candidates,
- approved Assets,
- BuildState,
- Persistenz.

## 10. Folgepfad

Empfohlener naechster Slice:

```text
M16-DF Uferwald Measurement SVG Documentation Plan
```

M16-DF sollte ein Visual-/Docs-Slice sein, der einen SVG-Plan und optional ein
PNG-Review-Export nur als Dokumentationsvisual erzeugt. Er darf weiterhin keine
Runtime-Daten, keine Assets, keine App-Integration und keine finalen
Koordinaten freigeben.

Erst danach ist sinnvoll:

```text
M16-DG Uferwald Technical Measurement Review
M16-DH Uferwald JSON/YAML Planning Schema Gate
```

JSON/YAML kommt erst nach visueller Review-QA, nicht davor.

## 11. Stop-Regeln

M16-DE gibt nicht frei:

- keinen Code,
- keine Flutter-/Dart-Dateien,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- keinen BuildState,
- keine Runtime-Mapdaten,
- keine Tests,
- keine Bilder,
- keine PNG/SVG-Dateien,
- keine Preview-Ordner,
- keine echten Polygon-/Vector-Dateien,
- keine Assets,
- keine Dateien unter `assets/`,
- keine Figma-Writes,
- keine JSON/YAML-Runtime-Daten,
- keine Engine-ready Candidates,
- keine approved Assets,
- keine externen Writes,
- keinen Commit.
