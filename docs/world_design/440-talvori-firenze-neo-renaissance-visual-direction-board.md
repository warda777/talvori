# 440 Talvori Firenze Neo-Renaissance Visual Direction Board 1K

Status: `visual_direction_board` / `planning_only` / `documentation_only`
Runtime integration: NO
Production assets: NO
Firenze layout changes: NO
Commit: NO

Unity Platform Update 2026-06-21:

Dieses Board bleibt als Talvori Neo-Renaissance Stilreferenz gueltig. Ab
`442-talvori-unity-modular-district-platform-decision.md` und
`443-p02-vertical-slice-and-online-foundation-roadmap.md` dient es vor allem
als Richtung fuer Unity-Environment-Kit-Intake, P02-District-Assembly,
Materialfamilien, Props und mobile Lesbarkeit. Es ist kein Flutter-Street-
Runtime-Ziel und kein Produktionsasset-Gate.

## 1. Ziel

Dieser Slice konkretisiert die in `439` entschiedene Richtung fuer genau einen
kleinen Firenze-District-/Street-Corner-Vertical-Slice.

Der Slice beschreibt keine fertige Runtime-Karte und kein final importierbares
Spielbild. Er definiert, wie die erste kleine Stilprobe aussehen soll:

- eine kurze Pflasterstrasse,
- eine warme Stein-/Bordsteinkante mit kleiner Stufe,
- eine einfache Neo-Renaissance-Hausfassade als Hintergrund-/District-Lesart,
- ein weltliches Interaktionsobjekt,
- wenige Kisten/Faesser/Marktmaterialien,
- eine Zypressen-/Topfpflanzen-Gruppe,
- sparsame Cyan-/Lila-/Gold-Akzente als Lernmagie.

Die bestehende Firenze-Layoutlogik bleibt unberuehrt: Boundary, Arno, Roads,
Bridge-Ketten, P01-P14, Navigation Graph, `city_spawn_start` und bestehende
Preview-Core-Daten werden nicht veraendert.

## 2. Grundlage

Fuehrend:

- `docs/world_design/439-talvori-firenze-visual-era-and-environment-style-direction-gate.md`

Relevante lokale Regeln:

- Talvori ist eine warme isometrische 3D-Welt mit 2D-/2.5D-Lesbarkeit, kein
  Dashboard.
- Weltobjekte muessen dieselbe Perspektive, Lichtlogik und Materialfamilie
  teilen.
- KI-/Meshy-Outputs sind Kandidaten, keine Assets.
- Keine Dateien nach `assets/` ohne eigenes Asset-Gate.
- Codex dokumentiert, prueft und formuliert Prompts; Codex erzeugt keine
  finalen Spielbilder.

## 3. Board-Entscheidung

Board-Name:

```text
Firenze Neo-Renaissance Street Corner v1
```

Zielbild in Worten:

```text
Ein warmer, kleiner Firenze-Strassenecken-Ausschnitt in Talvori-2.5D:
helle Kalkstein- und Putzflaechen, Terracotta-Dachkante, klare Pflasterwege,
ein ruhiger Bordstein mit Stufe, handwerkliche Marktprops, ein magischer
Sprachlaternen-Anker und Zypressengruen als rahmende Vegetation.
```

Nicht zeigen:

- keine komplette Stadt,
- keine echte Firenze-Runtime-Karte,
- keine GIS-Labels,
- keine technischen Node-/Edge-Markierungen,
- keine App-UI,
- keine finale Mission oder Gameplay-Integration.

## 4. Visual Recipe

### Perspektive und Massstab

- 2D-/2.5D-Mobile-Game-Lesart mit leicht erhoehter Kamera.
- Strasse, Kante, Props und Fassade muessen dieselbe Kamera teilen.
- Figuren-Footpoint bleibt spaeter bottom-center; Props duerfen ihn nicht
  optisch blockieren.
- Details werden so gross gedacht, dass sie in Route Camera lesbar bleiben.

### Palette

| Rolle | Farben |
| --- | --- |
| City base | warmer Kalkstein, heller Putz, Sandstein, gedecktes Ocker |
| Dach/Erde | Terracotta, warmes Ziegelrot, gedimmtes Braun |
| Holz/Handwerk | warmes Holz, Bronze, Leder, dunkles Kupfer |
| Vegetation | Zypressengruen, Olivgruen, Kraeutertopf-Gruen |
| Schatten | weiches Indigo, warmes Braunviolett |
| Interaktion | Cyan, Lila, Gold, nur sparsam |

### Materialien

- Pflaster: weich stilisierte helle Steine, nicht fotorealistisch.
- Bordstein/Stufen: massiver heller Stein mit klarer Silhouette.
- Fassade: Putz, Steinbogen, Holzlaeden, Terracotta-Kante.
- Props: Holz, Stoff, Bronze, Keramik.
- Magie: Glas/Kristall/Laternenlicht, aber handwerklich verankert.

### Interaktionssprache

Moderne Funktion wird nicht als modernes Objekt gezeigt:

| Moderne Funktion | Talvori-Artefakt |
| --- | --- |
| Quest-Hinweis | kleine Sprachlaterne oder Wachssiegel |
| Lernobjekt | Lexikon-Stein, Schriftrolle, Lichtglyphen |
| Translation | Prisma/Atelier-Werkbank |
| Progress | kleine Bauflagge, Materialkiste, goldener Lichtpunkt |

## 5. Prompt-Familien

Alle Prompts sind Kandidaten-Prompts fuer externe Tools. Ergebnisdateien
bleiben zuerst ausserhalb `assets/`, bevorzugt unter `_incoming_character_assets/`
oder einem separaten externen Asset-Archiv.

### 5.1 `firenze_cobble_road_tile_set_v1`

Positive Prompt:

```text
Stylized 2.5D mobile game cobblestone road tile set for a warm magical
Renaissance-inspired Firenze district in the original Talvori style. Light
limestone and soft sandstone cobbles, hand-painted clean shapes, readable
stone pattern, gentle warm shadows, slight top-down/isometric-friendly angle,
modular straight road patch, corner patch and small road-edge patch. Cozy,
crafted, game-ready visual clarity, no labels, no UI, no characters.
```

Negative Prompt / No-Go:

```text
No photorealistic asphalt, no satellite map, no GIS lines, no modern road
markings, no cars, no traffic lights, no wet realistic pavement, no medieval
dark dungeon stones, no noisy tiny cobbles, no cyberpunk neon road, no copied
franchise style.
```

Erwarteter Output:

- kleine modulare Road-/Tile-Set-Quelle,
- mindestens Straight, Corner und Edge-Lesart,
- helle warme Pflasterfamilie,
- keine Route-/Debug-Markierung.

Exportziel:

- `GLB Master` falls 3D,
- `Blender Render` als 2D-Patch,
- spaeter moeglicher `2D Prop`/Tile-Kandidat nach eigenem Gate.

QA-Kriterien:

- bei kleiner Darstellung lesbar,
- gleiche Perspektive wie Explorer-/Firenze-Proofs,
- keine technische Kartenoptik,
- Kanten gut an Bordstein/Stufen anschliessbar,
- neutral genug fuer mehrere Strassenabschnitte.

Risiken:

- zu fotorealistisch,
- zu kleinteilig,
- zu repetitiv,
- Strassenbreite wirkt nicht kompatibel mit Explorer-Scale.

### 5.2 `firenze_stone_curb_and_steps_v1`

Positive Prompt:

```text
Stylized warm limestone curb and small step kit for a Neo-Renaissance magical
Firenze street corner, original Talvori 2.5D mobile game style. Soft beveled
stone edges, clean readable silhouette, one low curb segment, one short stair
of three steps, one corner curb piece, hand-painted material feel, warm
shadows, slight top-down view, modular and reusable, no characters, no UI.
```

Negative Prompt / No-Go:

```text
No modern concrete sidewalk, no asphalt curb, no photorealistic dirt, no
broken ruin, no ancient Roman temple style, no high fantasy castle blocks, no
sharp black outlines, no labels, no technical grid.
```

Erwarteter Output:

- Bordstein-/Stufen-Kit mit klarer Grounding-Lesart,
- leichte Hoehe ohne harte Collision-Implikation,
- kompatibel mit Pflaster und Hausfassade.

Exportziel:

- `GLB Master`,
- `Blender Render`,
- spaeter `2D Prop`-Kandidat.

QA-Kriterien:

- Footpoint von Figuren bleibt visuell klar,
- Stufe wirkt nicht wie unpassierbare Mauer,
- keine Gameplay-Collision ableiten,
- Material passt zu Road Tile und Fassade.

Risiken:

- wirkt modern-staedtisch statt Talvori,
- zu hoch fuer kleine Route-Camera,
- Schatten trennt sich nicht sauber vom Boden.

### 5.3 `firenze_word_lantern_v1`

Positive Prompt:

```text
Small magical word lantern for an original Talvori Neo-Renaissance Firenze
street corner. Crafted bronze and warm glass, tiny parchment charm, subtle
cyan and lilac inner glow, gold accent, sits on a stone base or short post,
clearly an interactable learning artifact but still part of the world. Cozy
2.5D mobile game prop, readable silhouette, no text labels, no UI panel, no
modern screen.
```

Negative Prompt / No-Go:

```text
No smartphone, no tablet, no hologram screen, no sci-fi neon lamp, no huge glow
orb, no floating menu, no readable fake text, no weapon, no copied fantasy
franchise prop, no excessive particles.
```

Erwarteter Output:

- kleines Quest-/Lernsignal,
- warmes handwerkliches Objekt,
- Cyan/Lila nur innen oder als sehr kleine Akzentkante.

Exportziel:

- `Concept`,
- `GLB Master`,
- `Blender Render`,
- spaeter `2D Prop` und VFX-separat.

QA-Kriterien:

- bei Route Camera sichtbar, aber nicht dominant,
- klar kein moderner Bildschirm,
- Glow klein und ruhig,
- kann neben Plots oder Kreuzungen stehen.

Risiken:

- zu neon/sci-fi,
- zu gross wie Hauptgebäude,
- wird als UI-Button statt Weltobjekt gelesen.

### 5.4 `firenze_market_crates_barrels_v1`

Positive Prompt:

```text
Reusable small market crate and barrel prop set for a warm Talvori
Neo-Renaissance Firenze district. Handcrafted wooden crates, small cloth roll,
ceramic jar, modest bronze corner accents, one small parchment tag without
readable text, stylized 2.5D mobile game look, clean silhouettes, warm soft
shadows, no characters, no UI, no scene background.
```

Negative Prompt / No-Go:

```text
No pirate treasure, no medieval weapons, no food clutter overload, no
photorealistic wood, no dirty survival style, no modern cardboard boxes, no
brand labels, no tiny unreadable ornaments, no copied game asset style.
```

Erwarteter Output:

- 3-5 kleine Props als Kit,
- Markt-/Bau-/Material-Lesart,
- nicht zu laut, nicht zu viel Clutter.

Exportziel:

- `GLB Master`,
- `Blender Render`,
- `2D Prop`-Kandidaten nach QA.

QA-Kriterien:

- klare Einzel-Silhouetten,
- kompatibel mit Street Corner,
- kein Path/Plot blockierender Massstab,
- genug Talvori-Akzent ohne Neon-Dominanz.

Risiken:

- generisch,
- zu viele Minidetails,
- wirkt wie Lootbox oder Shop-UI.

### 5.5 `firenze_cypress_planter_v1`

Positive Prompt:

```text
Stylized cypress planter and small herb pot set for an original Talvori
Neo-Renaissance Firenze street corner. Terracotta pots, slim cypress silhouette,
olive-green and deep cypress-green foliage, warm stone base, clean 2.5D mobile
game readability, soft shadows, handcrafted cozy look, modular small and medium
planters, no characters, no UI, no large scene background.
```

Negative Prompt / No-Go:

```text
No photorealistic tree, no dense noisy leaves, no dark haunted forest, no
tropical palm, no oversized tree blocking the street, no floating plant, no
checkerboard, no labels, no copied franchise style.
```

Erwarteter Output:

- kleine und mittlere Pflanzenprops,
- Scenic-/Street-Corner-Rahmung,
- Zypressenform sofort lesbar.

Exportziel:

- `GLB Master`,
- `Blender Render`,
- `2D Prop`-Kandidat.

QA-Kriterien:

- gute Silhouette,
- kein Flimmern durch zu viele Blaetter,
- Schatten unter Topf stabil,
- blockiert keine Route.

Risiken:

- zu realistisch,
- zu dunkel,
- zu gross im Verhaeltnis zur Figur.

### 5.6 Optional `neo_renaissance_house_facade_a_v1`

Positive Prompt:

```text
Small stylized Neo-Renaissance house facade module for an original Talvori
Firenze street corner. Warm plaster, light stone arch, terracotta roof edge,
wood shutters, simple balcony or awning, handcrafted 2.5D mobile game style,
clear silhouette, friendly cozy proportions, not a full building, modular
facade slice, no interior, no characters, no UI.
```

Negative Prompt / No-Go:

```text
No exact Florence landmark replica, no photorealistic facade, no modern shop
signage, no cars, no neon storefront, no castle tower, no ancient Roman temple,
no huge cathedral, no dense tiny windows, no labels.
```

Erwarteter Output:

- kleine Hintergrund-/District-Fassade,
- klare Renaissance-Anmutung ohne Realrekonstruktion,
- modularer Test fuer Material und Massstab.

Exportziel:

- `Concept`,
- `GLB Master`,
- `Blender Render`,
- spaeter eventuell 2D Background/Facade-Kandidat.

QA-Kriterien:

- liest sich als Firenze-inspiriert,
- bleibt Talvori-eigen,
- nicht zu dominant gegen Props/Figur,
- keine Plot-/Road-Geometrie implizieren.

Risiken:

- zu gross,
- zu historisch-realistisch,
- zieht Stil weg von spielbarer Street-Corner.

## 6. Meshy-Abo-Ausnutzungsplanung fuer 1K

### Erste 3-5 Assets

1. `firenze_cobble_road_tile_set_v1`
2. `firenze_stone_curb_and_steps_v1`
3. `firenze_word_lantern_v1`
4. `firenze_cypress_planter_v1`
5. `firenze_market_crates_barrels_v1`

Begruendung:

- Road und Curb setzen Massstab, Material und Camera-Lesbarkeit.
- Word Lantern prueft die Talvori-Magie-/Lernakzent-Sprache.
- Cypress Planter und Market Props pruefen Vegetation und Handwerks-Clutter.
- Erst danach lohnt eine Hausfassade; sonst wird die Fassade zu frueh zum
  falschen Stilanker.

### Sinnvolle Varianten

| Asset | Varianten |
| --- | --- |
| Road Tile | straight, corner, edge, small worn patch |
| Curb/Steps | low curb, corner curb, three-step stair |
| Word Lantern | ground base, short post, wall-hook concept |
| Crates/Barrels | crate stack, barrel pair, ceramic jar group |
| Cypress Planter | small herb pot, medium cypress pot, double planter |

### Sofort zu sichernde Exporte

Pro Meshy-/AI-Kandidat sichern:

- Original Tool Export,
- GLB, falls verfuegbar,
- Texturen/Materialien, falls separat,
- Screenshot/Preview aus Tool,
- Prompt und Negative Prompt,
- Generation ID / Tool-Version / Datum,
- Lizenz-/Source-Notiz,
- Blender-Import-Check,
- 3/4 Render und Top-ish 2.5D Render als QA-Bild.

Speicherort:

```text
_incoming_character_assets/ oder externes Asset-Archiv
```

Nicht direkt:

```text
assets/
```

### Noch nicht generieren

- komplette Firenze-Stadt,
- kompletter District,
- Duomo-/Ponte-Vecchio-exakte Landmark-Kopie,
- NPC-Varianten,
- Fahrzeuge,
- moderne Screens,
- River-VFX-Finalisierung,
- produktive Tilesheets,
- App-HUD oder Mission-UI,
- alles, was neue Roads, Plots oder River-Geometrie vorgibt.

## 7. Board-QA

PASS-Kriterien fuer diesen Direction-Board-Slice:

- Board zeigt Stilrichtung, Palette, Materialfamilien und Prop-Prioritaet.
- Moderne Funktionen sind als Talvori-Artefakte erklaert.
- Geschuetzte Firenze-Ebene ist sichtbar benannt.
- No-Go-Stilbrueche sind klar.
- PNG und SVG sind Dokumentationsvisuals, keine App-Screens.
- Keine Runtime-/Asset-/Layout-Aenderung.

## 8. Ergebnis

Visual Direction Board 1K: PASS als Planungs- und Prompt-Gate.

Produktionsasset-Gate:

```text
CLOSED
```

Empfohlener erster Meshy-Test:

```text
firenze_cobble_road_tile_set_v1
```

Direkt danach:

```text
firenze_stone_curb_and_steps_v1
```

Warum:

Road und Curb definieren den kleinsten gemeinsamen Environment-Massstab fuer
Route Camera, Explorer-Footpoint, Street-Corner-Material und spaetere Props.
Wenn diese Basis nicht funktioniert, wuerden Lantern, Props und Facades auf
falschem Massstab entstehen.

Naechster moeglicher Codex-Slice:

```text
Talvori Firenze Meshy Road/Curb Candidate Intake 1L
```

Scope fuer 1L:

- externe Meshy-Outputs nur in `_incoming_character_assets/` pruefen,
- GLB/Texture/Preview/Prompt/License sichern,
- Blender-Import- und Scale-QA,
- kein `assets/`-Import,
- keine Runtime-Integration,
- keine Firenze-Layoutaenderung.
