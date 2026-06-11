# M16-CJ: Candidate A Layer and Postprocess Plan

Stand: 2026-06-11

Status: `Markdown-Docs-/Layer-Plan-Gate / keine Asset-Freigabe`

Template: `docs/world_design/prompt_templates/art_master_reference_slice.md`

## 1. Zweck und Non-Goals

M16-CJ uebersetzt M16-CG Candidate A in einen konkreten Layer- und
Postprocess-Plan fuer die Uferhain-`island_base`-Folgearbeit.

Candidate A bleibt dabei eine Strukturreferenz. M16-CJ uebernimmt kein
Pixelbild in Produktqualitaet und oeffnet keine Asset-, Engine-ready-,
Flutter- oder App-Freigabe.

Non-Goals:

- keine neuen Bilder,
- keine PNG/SVG,
- kein Preview-Ordner,
- keine Assets,
- keine Dateien unter `assets/`,
- keine Engine-ready Candidates,
- keine approved Assets,
- kein Code,
- keine Flutter-/Dart-Dateien,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- kein BuildState,
- keine Tests,
- keine externen Writes,
- kein Commit.

Codex darf in diesem Slice nur vorhandene Repo-Bilder und Dokumente auswerten,
dokumentieren und QA-pruefen. Codex darf keine KI-Bildtools anstossen und keine
neuen Spielbilder erzeugen.

## 2. Eingangsquellen und Abgrenzung

Fuehrende Quellen:

- `docs/world_design/365-modern-mobile-game-direction-board.md`
- `docs/world_design/367-talvori-art-bible-v1.md`
- `docs/world_design/368-starter-island-master-reference-set.md`
- `docs/world_design/370-asset-family-and-export-spec.md`
- `docs/world_design/371-starter-island-asset-candidate-gate.md`
- `docs/world_design/372-starter-island-base-candidate-generation-gate.md`
- `docs/world_design/373-candidate-a-structure-lock-and-postprocess-brief.md`
- `docs/world_design/previews/m16_cg_starter_island_base_candidate_generation/talvori_island_base_uferhain_candidate_metadata.md`
- `docs/world_design/previews/m16_cg_starter_island_base_candidate_generation/talvori_island_base_uferhain_candidate_a_1x.png`
- `docs/world_design/previews/m16_cg_starter_island_base_candidate_generation/talvori_island_base_uferhain_contact_sheet_1x.png`

Abgrenzung:

- M16-CG erzeugte Uferhain-`island_base`-Dokumentationscandidates.
- M16-CH reviewte Candidate A als beste Strukturgrundlage.
- M16-CI sperrte Candidate A nur als primaere Strukturreferenz.
- M16-CJ macht daraus Layer-, Postprocess- und Reihenfolge-Regeln.

M16-CJ ersetzt keine spaetere Art-, Figma-, Postprocess- oder Asset-Produktion.
Es beschreibt, was spaeter getrennt entstehen muss.

## 3. Entscheidung

```text
Candidate A als Layer-Plan-Grundlage: JA
Neue Bildgenerierung jetzt noetig: NEIN
Neuer Artist-/Figma-/Postprocess-Slice noetig: JA
Engine-ready oder assets/ weiterhin blockiert: JA
Candidate A Asset: NEIN
Candidate A approved Asset: NEIN
Candidate A finales Zielbild: NEIN
```

Candidate A wird nur fuer Strukturentscheidungen genutzt: Silhouette,
Kuesten-/Wasserbezug, Flussarm, zentrale Lichtung, Hainzone, ruhige
Randbereiche, Hoehenlogik und neutrale Slot-Reserven.

Nicht uebernommen werden:

- konkrete Pixel,
- finale Licht-/Farbqualitaet,
- eingebackene Wege,
- pad-artige Lichtungsformen,
- untrennbare Baum-/Fels-/Wasserdetails,
- ein monolithisches Gesamtbild als Runtime-Basis.

## 4. Layer-Zielbild aus Candidate A

Candidate A liefert ein strukturelles Zielbild:

- eine kompakte, grosszuegige Kuestenhain-/Flussufer-Starterinsel,
- Wasser und Uferarm als Identitaetsanker,
- zentrale Lichtung als Hub ohne feste Kategorie,
- Hain-/Waldkante als ruhige Weltkante,
- mehrere natuerliche Reserveflaechen fuer ca. 12 sichtbare Slots,
- langfristige Erweiterbarkeit auf 16-20 Slots,
- warme 2.5D-Cozy-Island-Diorama-Perspektive.

Das spaetere Layer-Ziel ist nicht ein ausgeschnittenes Candidate-A-Bild,
sondern eine neu aufgebaute, trennbare Uferhain-Komposition, die dieselbe
Struktur respektiert.

## 5. Layer-Familien

Die spaetere Arbeit wird in diese Familien getrennt:

1. `island_base`
2. `water_paths`
3. `terrain_layers`
4. `slot_markers`
5. `build_stations`
6. `building_phases`
7. `workers_companions`
8. `ui_hud_bubbles`

Die Reihenfolge ist absichtlich streng. `build_stations`, `building_phases`,
Figuren und HUD duerfen erst sinnvoll entstehen, wenn die Basis, Wasserwege,
Terrain und neutrale Slotlogik getrennt verstanden sind.

## 6. Familienplan

| Layer-Familie | Zweck | Bezug zu Candidate A | Uebernehmen | Entfernen/abstrahieren | Spaeter separat erzeugen | Blockiert bleibt |
| --- | --- | --- | --- | --- | --- | --- |
| `island_base` | Grundsilhouette, begehbare Landmasse und Basisrand. | Candidate A zeigt die fuehrende Inselkontur und grobe Masse. | Insel-Silhouette, grosser Hub, Randreserven, 2.5D-Grundneigung. | Eingebackene Details, fertige Wege, malerische Vegetation, pad-artige Formen. | Saubere Basisform mit transparentem Export erst nach Asset-Gate. | `assets/`, Engine-ready, Runtime-Import. |
| `water_paths` | Wasserumfeld, Uferarm, Kueste und spaetere Wasserbewegung. | Candidate A hat starken Wasserbezug links/oben und rund um die Insel. | Fluss-/Uferarm als Strukturanker, weiche Uferlinie, Kuestenlesbarkeit. | Untrennbares Wasser im Gesamtbild, harte UI-Kanten. | Wasserlayer, Uferschaum, Felsen am Ufer, ggf. spaetere subtile Bewegung. | Fertige Wasser-Animation, Runtime-Shader. |
| `terrain_layers` | Wiese, Hain, Waldkante, Felsen, Hoehen und Blumenakzente. | Candidate A zeigt Hain oben/rechts, ruhige Wiesen und weiche Hoehen. | Hainzone, Hoehen-/Terrassenlogik, natuerliche Randbereiche. | Ueberdichte Details, feste Pads, unlesbare Kleinteile. | Baumgruppen, Felsen, Hoehenkanten, Wiesenvarianten als getrennte Families. | Monolithische Terrainkarte. |
| `slot_markers` | Neutrale, spaeter sichtbare freie und spaetere Slots. | Candidate A bietet nur Reserveflaechen, noch keine Marker. | Ca. 12 plausible Reservezonen und Reserve fuer 16-20 Slots. | Kategorieplaetze, Pins, Icons, harte Kreise, Haus-/Markt-/Werkstattzuweisung. | Dezente neutrale Marker und gewaehlter Slot-Zustand nach eigenem Gate. | Automatische Wortplatzierung, BuildState, Persistenz. |
| `build_stations` | BuildChoice als Weltobjekt am gewaehlten Slot. | Candidate A enthaelt keine Station, aber zeigt geeignete Slotumfelder. | Nur Standortlogik: Station kommt auf Nutzerwahl, nicht auf feste Kategorie. | Menue, Shop, Bottom Sheet, Labelwolke. | Build Station, kleine Optionstraeger, Materialkiste, Werkzeughinweis. | Produktive BuildChoice-Implementierung. |
| `building_phases` | Sichtbare Bauentwicklung nach Station/Slot. | Candidate A enthaelt noch keine Gebaeude. | Nur die Einbettung in Lichtung/Hang/Ufer als spaeteren Kontext. | Fertige Haeuser, Kategorien, vorgebaute Bauplaetze. | lockerer Boden, vorbereiteter Boden, Fundament, Wand-/Tuer-/Fenster-Ghosts. | Engine-ready Phasen, BuildState. |
| `workers_companions` | Worker/Tali/Vori beleben Bau- und Lernmomente. | Candidate A enthaelt keine Figuren. | Perspektive, Licht und Massstab muessen zur Insel passen. | Stickerhafte Figuren, fremdes Licht, Joystick-/Pathfinding-Scope. | Worker/Tali/Vori Master- und Animation-Briefs. | Figuren-Assets, Movement-System. |
| `ui_hud_bubbles` | Kurze Spiel-HUDs und kontextuelle Bubbles. | Candidate A enthaelt keine UI. | Welt bleibt sichtbar und dominant. | Dashboard, Worksheet, Admin-Kaesten, Textwand. | Kleine Bubbles, Safe Actions, ruhige HUD-Elemente nach UI/HUD-Gate. | App-Screen-Freigabe, produktive Navigation. |

## 7. `island_base`-Plan

`island_base` ist die erste konkrete Layer-Familie, aber M16-CJ erzeugt noch
keine Datei dafuer.

Struktur aus Candidate A:

- breite Hauptinsel mit organischer Kontur,
- zentrale Lichtung als groesster freier Orientierungspunkt,
- offene Randwiesen unten/rechts/links,
- Hainruecken oben/rechts als Weltgrenze,
- sanfte Hoehenstufen statt flacher Editor-Map,
- Strand-/Felsrand als natuerliche Inselkante.

Postprocess-Ziel:

- Basislandmasse klar von Wasser, Hain, Felsen und spaeteren Markern trennen,
- keine Kategorie- oder Slot-Icons in die Basis einbacken,
- keine Wege als starre Grid-Struktur uebernehmen,
- Zentrallichtung weich halten,
- Reserveflaechen als Terrainlesbarkeit, nicht als Pads.

## 8. `water_paths`-Plan

`water_paths` muss frueh getrennt werden, weil Uferhain ohne Wasserarm seine
Identitaet verliert.

Struktur aus Candidate A:

- Wasser um die Insel,
- Fluss-/Uferarm links/oben,
- Kuestenlinie und kleine Fels-/Steinrander,
- ruhiger Strand-/Uferuebergang unten.

Postprocess-Ziel:

- Wasser nicht als Hintergrund in das Inselbild einbacken,
- Uferlinie, Felsen und Wasserflaechen getrennt planbar halten,
- Flussarm als Orientierung behalten, aber nicht als harte Kategoriebarriere
  missverstehen,
- spaetere Bewegung/Glow/Partikel nicht in M16-CJ oeffnen.

## 9. `terrain_layers`-Plan

`terrain_layers` tragen den Cozy-Diorama-Charakter, muessen aber mobile-lesbar
und layerbar bleiben.

Struktur aus Candidate A:

- dichter Hain oben/rechts,
- mehrere Wiesenlichtungen,
- Felsen und Hoehenkanten,
- Blueten und kleinere Akzente,
- ruhige Randbereiche.

Postprocess-Ziel:

- Hain, Einzelbaumgruppen, Felsen, Blumen und Hoehenkanten getrennt denken,
- Details reduzieren, wenn sie Slots oder mobile Lesbarkeit stoeren,
- Lichtungen nicht kreisrund oder pad-artig glatten,
- Hainzone nicht zum untrennbaren Hintergrundrauschen machen.

## 10. `slot_markers`-Plan

Candidate A zeigt keine Slot Marker. Das ist richtig. M16-CJ definiert nur,
welche Reserveflaechen spaeter markierbar sein sollen.

Grundregeln:

- ca. 12 sichtbare neutrale Slot-Reserven,
- davon spaeter ca. 6 sofort nutzbar und 6 sichtbar spaeter,
- langfristige Reserve fuer 16-20 Slots,
- Lage statt Kategorie,
- kein `Hausplatz`, `Marktplatz`, `Werkstattplatz` oder `Gartenplatz`,
- Terrain darf Variante nahelegen, aber keine Kategorie hart blockieren.

Postprocess-Ziel:

- Reserveflaechen muessen weich und natuerlich bleiben,
- Marker duerfen spaeter auf einem separaten Layer erscheinen,
- gewaehlter Slot darf fokussieren, ohne die Welt auszublenden,
- spaetere Slots duerfen gedimmt sein, aber nicht wie verbotene Fehlstellen.

## 11. `build_stations`-Plan

Build Station am Slot bleibt das fuehrende BuildChoice-Pattern. Candidate A
liefert dafuer nur die Weltstruktur, nicht das Station-Design.

Spaeterer Station-Scope:

- Station erscheint am vom Nutzer gewaehlten neutralen Slot,
- Station ist Weltobjekt, kein Menue,
- Haus ist eine klare Hauptidee,
- Garten/Werkstatt/Garage koennen ruhige Alternativen sein,
- weitere Moeglichkeiten bleiben dezent,
- Worker/Tali/Vori koennen den Moment lebendig machen.

Blockiert:

- Shop-Optik,
- Bottom Sheet als Hauptentscheidung,
- technische Labelwolke,
- produktive BuildChoice-Implementierung,
- Persistenz oder BuildState.

## 12. `building_phases`, Figuren und HUD

Diese Familien bleiben spaeter.

`building_phases`:

- lockerer Boden,
- vorbereiteter Boden,
- Fundament,
- Wand-Ghost,
- Tuer-/Fenster-Ghost,
- spaetere Tiefe Richtung Raum/Interior/Container.

`workers_companions`:

- gleiche Perspektive wie Insel und Station,
- gleiche Lichtlogik,
- freundlich, emotional und lesbar,
- nicht stickerhaft,
- kein Joystick-/Pathfinding-Scope.

`ui_hud_bubbles`:

- kleines Spiel-HUD,
- kurze Bubbles,
- kontextuell und ruhig,
- keine Dashboard-/Worksheet-Optik,
- keine App-Screen-Freigabe.

## 13. Postprocess-Regeln

Ein spaeterer Postprocess-Slice muss Candidate A in trennbare, weniger
monolithische Arbeitsfamilien ueberfuehren.

Pflichtregeln:

- monolithisches Bild aufbrechen,
- Wasser, Hain, Lichtung, Felsen, Hoehen und Randbereiche getrennt denken,
- Lichtungen natuerlicher machen, nicht pad-artig,
- Slot-Reserven weich und neutral halten,
- keine Kategorieplaetze,
- keine Gebaeude,
- keine Figuren,
- keine UI/HUD/Bubbles,
- keine Texte, Pins, Icons oder Labels,
- keine finalen Pixel aus Candidate A als Produktziel uebernehmen,
- Mobile-Lesbarkeit erhalten,
- 2.5D-Cozy-Island-Diorama-Perspektive erhalten,
- Kuestenhain-/Flussufer-Identitaet von Uferhain schuetzen.

## 14. Reihenfolge fuer spaetere Arbeit

Verbindliche Folge-Reihenfolge:

1. `island_base`-Layer-Plan
2. `water_paths`
3. `terrain_layers`
4. neutrale `slot_markers`
5. `build_stations`
6. `building_phases`
7. `workers_companions`
8. `ui_hud_bubbles`

Erst nach diesen Planungs- und ggf. externen Postprocess-Gates darf geprueft
werden, ob ein Engine-ready- oder Flutter-Integrations-Gate sinnvoll ist.

## 15. QA-Kriterien fuer Folge-Slices

Ein Folge-Slice muss mindestens pruefen:

- Ist Candidate A nur Strukturreferenz, nicht Pixelziel?
- Bleibt Uferhain als Kuestenhain-/Flussufer-Starterinsel lesbar?
- Sind Wasser, Land, Terrain, Slots, Station, Figuren und HUD getrennt?
- Bleiben ca. 12 sichtbare Slot-Reserven plausibel?
- Bleibt Reserve fuer 16-20 Slots plausibel?
- Sind alle Slots neutral und nicht kategoriegebunden?
- Wirkt die Insel noch 2.5D cozy und mobile-lesbar?
- Sind keine Gebaeude, Figuren, UI, Texte, Pins oder Icons im Basisbild?
- Sind keine Dateien unter `assets/` entstanden?
- Bleibt der Status unterhalb von Engine-ready und approved Asset?

## 16. Tool- und Rollenregel

Fuer spaetere Bild- oder Postprocess-Arbeit gilt:

- ChatGPT/image_gen oder ein ausdruecklich benanntes Bildtool kann spaeter nur
  nach eigenem Freigabe-Slice neue Bildkandidaten erzeugen.
- Figma, Photopea, Photoshop, Aseprite oder ein Artist koennen spaeter
  Postprocess, Layering, Zuschnitt und Export vorbereiten.
- Codex dokumentiert Pipeline, Dateistruktur, Metadaten, QA, Pfadgrenzen,
  Flutter-Grenzen und Checks.
- Codex erzeugt in M16-CJ keine Bilder und zeichnet Candidate A nicht nach.

## 17. Stop-Regeln

- Keine neuen Bilder.
- Keine PNG/SVG.
- Kein Preview-Ordner.
- Keine Assets.
- Keine Dateien unter `assets/`.
- Keine Engine-ready Candidates.
- Keine approved Assets.
- Kein Code.
- Keine Flutter-/Dart-Dateien.
- Keine App-Integration.
- Keine Route.
- Keine Navigation.
- Keine Persistenz.
- Kein BuildState.
- Keine Tests.
- Keine externen Writes.
- Kein Commit.

## 18. Folgepfad

Empfohlener naechster Slice:

```text
M16-CK Candidate A External Postprocess and Layer Production Brief
```

Ziel von M16-CK waere nicht sofort Flutter-Code, sondern ein konkreter Brief
fuer externe/visuelle Arbeit: welche Layer zuerst erzeugt werden duerfen,
welches Tool oder welche Rolle sie erzeugt, welche Metadaten entstehen muessen
und welche QA entscheidet, ob daraus spaeter ein `engine_ready_candidate`-Gate
ueberhaupt geoeffnet werden darf.
