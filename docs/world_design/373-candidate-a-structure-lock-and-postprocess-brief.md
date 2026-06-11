# M16-CI: Candidate A Structure Lock and Postprocess Brief

Stand: 2026-06-11

Status: `Markdown-Docs-/Structure-Lock-Gate / keine Asset-Freigabe`

Template: `docs/world_design/prompt_templates/art_master_reference_slice.md`

## 1. Zweck und Non-Goals

M16-CI sperrt M16-CG Candidate A als primaere Strukturreferenz fuer die
Uferhain-`island_base`-Richtung. Das bedeutet: Die lesbare Inselstruktur aus
Candidate A darf fuer spaetere Postprocess-, Layer- und Asset-Gates als
Orientierung dienen.

M16-CI uebernimmt Candidate A nicht als:

- Asset,
- finales Zielbild,
- Engine-ready Candidate,
- approved Asset,
- App-Screen,
- Produktdatei,
- Flutter- oder Runtime-Grundlage.

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

M16-CI ist ein Structure-Lock- und Postprocess-Brief. Es ist keine Asset-,
Code-, App- oder Engine-ready-Freigabe.

## 2. Eingangsquellen und Abgrenzung

Fuehrende Quellen:

- `docs/world_design/365-modern-mobile-game-direction-board.md`
- `docs/world_design/367-talvori-art-bible-v1.md`
- `docs/world_design/368-starter-island-master-reference-set.md`
- `docs/world_design/370-asset-family-and-export-spec.md`
- `docs/world_design/371-starter-island-asset-candidate-gate.md`
- `docs/world_design/372-starter-island-base-candidate-generation-gate.md`
- `docs/world_design/previews/m16_cg_starter_island_base_candidate_generation/talvori_island_base_uferhain_candidate_metadata.md`
- `docs/world_design/previews/m16_cg_starter_island_base_candidate_generation/talvori_island_base_uferhain_candidate_a_1x.png`
- `docs/world_design/previews/m16_cg_starter_island_base_candidate_generation/talvori_island_base_uferhain_contact_sheet_1x.png`

Abgrenzung:

- M16-CG erzeugte 2-3 `island_base`-Dokumentationscandidates mit
  Maximalstatus `asset_candidate`.
- M16-CH reviewte Candidate A und empfahl ihn nur als Strukturreferenz, nicht
  als Asset oder Engine-ready Grundlage.
- M16-CI dokumentiert diese Entscheidung und macht daraus Postprocess- und
  Layer-Planungsregeln.

Candidate B und Candidate C bleiben sekundaere Review-Referenzen:

- Candidate B kann fuer klare Riverarm-/Terrassenlesbarkeit verglichen werden,
  ist aber wegen pad-/kartenartiger Terrassen nicht primaer.
- Candidate C kann fuer langfristige Reserve und groesseres Inselgefuehl
  verglichen werden, ist aber wegen starker Hoehen-/Wasserfallbetonung nicht
  primaer.

## 3. Entscheidung

```text
Candidate A Primary Structure Reference: JA
Candidate A Asset: NEIN
Candidate A finales Zielbild: NEIN
Candidate A Engine-ready: NEIN
Candidate A approved Asset: NEIN
Candidate A Postprocess noetig: JA
Candidate B/C Primary Alternative: NEIN
```

Candidate A wird als Strukturreferenz gesperrt, weil es die staerkste
Kombination aus Uferhain-Identitaet, Kuesten-/Wasserbezug, Flussarm,
zentraler Lichtung, Hainzone, neutralen Flaechenreserven und cozy
2.5D-Diorama-Lesbarkeit zeigt.

Gesperrt wird nicht die Pixelqualitaet. Gesperrt wird die strukturelle
Kompositionsidee.

## 4. Candidate-A-Strukturregeln

### Fuehrende Insel-Silhouette

Candidate A zeigt eine kompakte, erweiterbare Insel mit deutlich lesbarer
Hauptmasse und mehreren ruhigen Randbereichen. Diese Silhouette ist fuer
Uferhain fuehrend:

- Insel wirkt wie ein Spielort, nicht wie UI.
- Landmasse ist gross genug fuer spaetere freie Gestaltung.
- Randbereiche koennen spaeter Erweiterung, Ruhe, Hain oder Wasserblick
  tragen.
- Die Silhouette darf nicht zu einer generischen Tropeninsel, Stadtkarte oder
  flachen Editor-Map kippen.

### Kuesten- und Wasserbezug

Der Wasserbezug ist ein Pflichtanker:

- helle Kueste im unteren/seitlichen Bereich,
- Wasser um die Insel,
- sichtbare Uferlinien,
- kleine Felsen/Steine als natuerlicher Rand,
- klare Trennung von Land und Wasser ohne harte UI-Kante.

Der Wasserbezug darf spaeter lebendiger werden, muss aber vom
`island_base`-Layer getrennt gedacht werden.

### Flussarm / Uferarm

Candidate A zeigt links/oben einen lesbaren Fluss-/Uferarm, der Uferhain
identitaetsstark macht.

Regeln:

- Der Flussarm bleibt Strukturtraeger, nicht Dekoration.
- Er darf Orientierung geben, aber keine harte Baubarriere fuer Kategorien
  werden.
- Er darf spaeter `water_paths` fuehren, waehrend `island_base` die
  Grundsilhouette traegt.

### Zentrale Lichtung / Hub

Die grosse zentrale Lichtung ist fuehrend als erster Orientierungspunkt:

- sicherer erster Hub,
- breite neutrale Bauplatzreserve,
- geeignet fuer ersten Slot-Fokus und spaetere Build Station,
- nicht automatisch "Hausplatz".

Die zentrale Lichtung darf keine Pflichtkategorie erzwingen. Sie ist ein
Weltort, kein Formularfeld.

### Hain-/Waldzone

Candidate A setzt den Hain stark im oberen/rechten Bereich:

- dichter Wald/Hain als Identitaetszone,
- Mischgruen und einzelne warme Akzentbaeume,
- Hain rahmt die Lichtungen, ohne die Insel zu ueberfuellen.

Spaeter muessen Baumgruppen und Hainkanten als `terrain_layers` trennbar
gedacht werden. Sie duerfen nicht untrennbar in die spielbare Basis
eingebacken werden.

### Ruhige Randbereiche

Die unteren, rechten und linken Randbereiche geben der Insel Luft:

- ruhige Wiesen,
- Felsen und Ufer,
- kleinere Reserveflaechen,
- natuerliche Erweiterungspunkte.

Diese Bereiche sind wichtig gegen ein zu enges Ein-Slot-Gefuehl.

### Hoehen- und Terrassenlogik

Candidate A nutzt sanfte Hoehen, Felsrander und kleine Terrassen. Das ist
brauchbar, solange es weich bleibt:

- Hoehen geben 2.5D-Diorama-Charakter.
- Terrassen duerfen spaeter Slotnahe ermoeglichen.
- Kanten duerfen nicht wie starre Baupads oder Kategorieplaetze wirken.
- Keine technische Level-Editor-Treppenlogik.

## 5. Slot-Reserve-Regeln

Candidate A soll als Strukturreferenz fuer ca. 12 sichtbare neutrale
Slot-Reserven gelesen werden.

Plausible sichtbare Reservezonen:

1. zentrale grosse Lichtung,
2. obere rechte Wiesenflaeche,
3. mittlere rechte Wiesenflaeche,
4. untere rechte Randwiese,
5. untere mittlere Wiese,
6. untere linke Uferwiese,
7. linke Insel-/Uferarmflaeche,
8. obere linke Wassernahe,
9. obere Hainrandflaeche,
10. kleine mittlere Hainkante,
11. rechter Ufer-/Felsrand,
12. ruhiger unterer Strand-/Wiesenuebergang.

Regeln:

- Diese Zonen sind Strukturreserven, keine eingezeichneten Slot-Marker.
- Sie duerfen spaeter freie und spaetere Slots tragen.
- Sie duerfen keine Kategorien vorgeben.
- Kein `Hausplatz`, `Marktplatz`, `Werkstattplatz` oder aehnliche
  Festlegung.

Langfristig muss die Struktur 16-20 Slots denkbar machen:

- durch feinere Aufteilung der zentralen Lichtung,
- durch Randreserven,
- durch Hainrand- und Uferblick-Varianten,
- durch spaetere Erweiterung an ruhigen Aussenkanten,
- ohne die Insel mit sichtbaren Markern zu ueberfuellen.

## 6. Layer-Trennung fuer spaetere Arbeit

Candidate A ist aktuell ein flaches Bild. Fuer spaetere Arbeit muss es in
Layer-Familien uebersetzt werden.

| Spaetere Familie | Rolle aus Candidate A | M16-CI-Regel |
| --- | --- | --- |
| `island_base` | Grundsilhouette, Landmasse, Basisrand. | Nur die Basisform ableiten, nicht die ganze gemalte Welt uebernehmen. |
| `terrain_layers` | Wiesen, Hain, Baumgruppen, Felsen, Hoehen. | Hain/Wiese/Felsen getrennt denken; keine monolithische Karte. |
| `water_paths` | Kueste, Flussarm, Uferlinien, Wasserraeume. | Wasser getrennt planbar halten; Flussarm als Strukturanker bewahren. |
| `slot_markers` | Noch nicht sichtbar, nur Reserveflaechen. | Spaeter neutral markieren; keine Pins/Kategorien im Basisbild. |
| `build_stations` | Noch nicht enthalten. | Build Station erst spaeter auf gewaehltem Slot, nicht in Candidate A. |
| `building_phases` | Noch nicht enthalten. | Fundament/Wand-Ghost erst nach Slot/Station-Gate. |
| `workers_companions` | Noch nicht enthalten. | Worker/Tali/Vori muessen spaeter dieselbe Perspektive teilen. |
| `ui_hud_bubbles` | Noch nicht enthalten. | HUD/Bubbles bleiben komplett getrennt von Weltgrafik. |

## 7. Postprocess- und Korrekturregeln

Ein spaeterer Postprocess- oder Layer-Plan muss Candidate A in Richtung
strukturierter, layerbarer Uferhain-Basis fuehren.

Pflichtkorrekturen:

- Bild darf weniger final und weniger monolithisch wirken.
- Wasser, Baeume, Lichtung, Wege und Reserveflaechen muessen getrennt
  planbar werden.
- Lichtungen duerfen nicht wie fertige Pads wirken.
- Reserveflaechen muessen weich, natuerlich und lagebezogen bleiben.
- Keine festen Haus-/Markt-/Werkstattplaetze.
- Keine Gebaeude.
- Keine Figuren.
- Keine HUD-/UI-Elemente.
- Keine Texte, Labels, Pins oder Icons.
- Uferhain muss Kuestenhain-/Flussufer-Identitaet behalten.
- Mobile-Lesbarkeit muss erhalten bleiben.
- 2.5D-Cozy-Island-Diorama-Perspektive muss erhalten bleiben.

Postprocess darf nicht:

- Candidate A nachzeichnen und als finalen Stil fixieren,
- ein einzelnes riesiges Weltbild als spielbare Karte festschreiben,
- Slotmarker, Build Station oder Gebaeude in die Inselbasis einbacken,
- ein Engine-ready Exportformat behaupten,
- Dateien unter `assets/` vorbereiten,
- Flutter- oder App-Integration oeffnen.

## 8. Mobile- und Stil-QA

Candidate-A-basierte Folgearbeit muss pruefen:

- Insel bleibt bei Smartphone-Groesse als Form lesbar.
- Wasserarm, zentrale Lichtung, Hainzone und Randreserven sind ohne Labels
  erkennbar.
- Keine Flaeche sieht wie Pflichtkategorie aus.
- Detailgrad bleibt warm und hochwertig, aber nicht so malerisch, dass
  Layerbarkeit verloren geht.
- Perspektive passt zu spaeteren Slots, Build Station, Gebaeuden, Worker,
  Tali/Vori und HUD.
- Spielraum dominiert; UI bleibt getrennt.
- Uferhain ist nicht generisch cozy, sondern Kuestenhain-/Flussufer-Ort.

## 9. Candidate B und C

Candidate B und Candidate C bleiben hilfreich, aber sekundaer.

Candidate B:

- gut fuer Riverarm-Lesbarkeit,
- gut fuer Terrassen- und Wasserfuehrung,
- Risiko: Terrassen wirken zu pad- oder map-artig.

Candidate C:

- gut fuer Langfristreserve und groessere Inselkapazitaet,
- gut fuer starke Kuesten-/Grove-Lesbarkeit,
- Risiko: Hoehen-/Wasserfallbetonung wirkt fuer den ersten Uferhain zu
  dramatisch.

Keiner der beiden Candidates ersetzt Candidate A als primaere
Strukturreferenz.

## 10. Folgepfad

Empfohlener naechster Slice:

```text
M16-CJ Candidate A Layer and Postprocess Plan
```

M16-CJ sollte keinen Flutter-Code starten. M16-CJ sollte auch keine
Engine-ready Candidates oeffnen. Sinnvoll waere:

- Candidate-A-Struktur in Layer-Familien uebersetzen,
- definieren, welche Teile `island_base`, `terrain_layers` und `water_paths`
  werden koennen,
- Regeln fuer spaetere neutrale `slot_markers` vorbereiten,
- entscheiden, ob ein weiteres KI-/Figma-/Artist-Postprocess-Gate noetig ist,
- weiterhin `assets/`, approved Assets, Engine-ready und App-Integration
  blockieren.

Erst nach einem solchen Layer-/Postprocess-Plan darf ein spaeteres Gate
pruefen, ob neue, besser layerbare Dokumentationscandidates erzeugt werden
sollen.

## 11. Stop-Regeln

M16-CI gibt nicht frei:

- keine neuen Bilder,
- keine PNG/SVG,
- kein Preview-Ordner,
- keine Assets,
- keine Dateien unter `assets/`,
- keine Engine-ready Candidates,
- keine approved Assets,
- keine finalen Spielbilder,
- keine App-Screens,
- kein Code,
- keine Flutter-/Dart-Dateien,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- kein BuildState,
- keine Tests,
- keine externen Writes,
- kein Commit ohne separate ausdrueckliche Freigabe.

## 12. M16-T-IDs

M16-CI erfuellt:

- M16T-ASSET-030 Candidate A primary structure reference lock
- M16T-ASSET-031 Candidate A not-asset and not-engine-ready boundary
- M16T-ASSET-032 Candidate A postprocess rules
- M16T-ASSET-033 Uferhain layer separation brief
- M16T-ASSET-034 Candidate B/C secondary reference boundary
- M16T-ASSET-035 Layer/postprocess plan before code

M16T-ASSET-001 bleibt blockiert, weil M16-CI keine echten Assets, keine
Dateien unter `assets/`, keine Engine-ready Candidates und keine
Produktintegration freigibt.
