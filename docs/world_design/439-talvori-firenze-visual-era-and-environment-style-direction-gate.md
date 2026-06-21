# 439 Talvori Firenze Visual Era and Environment Style Direction Gate 1J

Status: `decision_gate` / `planning_only` / `documentation_only`
Runtime integration: NO
Production assets: NO
Firenze layout changes: NO
Commit: NO

Unity Platform Update 2026-06-21:

Die Entscheidung `Talvori Neo-Renaissance / Magical Renaissance` bleibt gueltig.
Ab `442-talvori-unity-modular-district-platform-decision.md` und
`443-p02-vertical-slice-and-online-foundation-roadmap.md` wird sie jedoch fuer
Unity 6 URP, modulare Districts, P02 und coherent environment kits angewendet.
Die Flutter-Sprite-/Street-Proofs bis `1I` bleiben historische technische
Proofs, nicht primaerer Runtime-Weg.

## 1. Ziel

Dieser Slice entscheidet die erste visuelle Epochen- und Environment-Richtung
fuer Firenze als spielbare Talvori-Stadt.

Der Proof-Stand bis `1I` zeigt technisch genug:

- Explorer-Sprite-Motion funktioniert in 8 Richtungen.
- Das `1D` Direction-Mapping ist freigegeben.
- Firenze-Integration, Route, Scale und Cadence sind als Proof kalibriert.
- Runtime bewegt den Footpoint; Walk bleibt in-place; kein Root Motion.
- Das Produktionsasset-Gate bleibt geschlossen.

Dieser Slice entscheidet nur die visuelle Richtung und die naechste
Asset-Pipeline. Er veraendert keine bestehende Firenze-Topologie, keine
Graphroute, keine Master-SVG, keine Runtime-Daten und keine App-Integration.

## 2. Gelesene Grundlagen

- `AGENTS.md`
- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
- `docs/world_design/talvori_game_bible.md`
- `docs/world_design/366-ai-art-production-pipeline-and-style-consistency-gate.md`
- `docs/world_design/367-talvori-art-bible-v1.md`
- `docs/world_design/370-asset-family-and-export-spec.md`
- `docs/world_design/426-firenze-master-technical-layout-readiness-check.md`
- `docs/world_design/431-firenze-area-specification-metrics-and-reachability-review-v1.md`
- `docs/world_design/438-talvori-modern-2d-25d-character-sprite-style-decision.md`

Wichtige lokale Regeln:

- Firenze bleibt graph- und source-authentisch.
- Player-facing Szenen duerfen nicht wie GIS, Admin-Panel oder Debug-Map wirken.
- Technische Navigation, sichtbare Art und Character-Animation bleiben getrennte
  Systeme.
- Keine vollstaendige Stadt-Art vor einem freigegebenen District-Slice.
- Codex erzeugt keine prozeduralen Ersatzfiguren und keine finalen Spielbilder.

## 3. Externe Orientierung

Kurzrecherche, nur als Ableitung fuer Talvori:

| Quelle | Relevante Ableitung |
| --- | --- |
| [Creative Bloq, Playable-Watercolour-Environments](https://www.creativebloq.com/3d/video-game-design/this-indie-game-turns-watercolour-art-into-playable-puzzle-spaces) | Eine starke Spielwelt braucht eine wiedererkennbare visuelle Identitaet, nicht nur huebsche Einzelbilder. Das bestaetigt: Firenze braucht ein Style-Gate vor Asset-Massenproduktion. |
| [Unity Manual: Asset Workflow](https://docs.unity3d.com/Manual/AssetWorkflow.html) | Assets muessen mit klarer Import-/Export-Logik, wiederholbaren Quellen und pruefbaren technischen Eigenschaften behandelt werden. Das bestaetigt: Visual Skin und technische Gameplay-Daten bleiben getrennt. |
| [Unity Manual: Sprites](https://docs.unity3d.com/Manual/sprite/sprite-landing.html) | Sprite-Produktion braucht klare Frame-, Transparenz-, Pivot- und Importvertraege. Das bestaetigt: Character-/Prop-/Tile-Frames brauchen eigene QA-Gates. |
| [Riot Games: Clarity in League](https://www.leagueoflegends.com/en-us/news/dev/clarity-in-league/) | Erfolgreiche Game-Art schuetzt Hierarchie, Silhouette, Facing und minimiert visuelles Rauschen. Das bestaetigt: Firenze-Props und Figuren muessen mobile-lesbar bleiben und duerfen nicht in Detailrauschen kippen. |

## 4. Vergleich der Stilrichtungen

| Kriterium | A) Modern Firenze | B) Historisch/Renaissance Firenze | C) Talvori Neo-Renaissance / Magical Renaissance |
| --- | --- | --- | --- |
| Passt zur Explorer-Figur | Mittel: moderne Stadt bricht schnell mit Explorer-Look. | Gut, aber Gefahr von Museums-/Kostuemwirkung. | Sehr gut: Explorer wirkt als Talvori-Buerger/Entdecker. |
| Passt zu Sprachlern-/Weltbau-Spiel | Mittel: moderne Alltagswelt kann schnell nach Realstadt/App aussehen. | Mittel: starke Kulturstimmung, aber weniger Raum fuer moderne Lernfunktionen. | Hoch: Lernen kann als Magie, Werkstatt, Bibliothek, Markt und Entdeckung erscheinen. |
| Erlaubt moderne Funktionen | Hoch, aber banal: Screens, Schilder, Geraete. | Niedrig bis mittel: moderne Funktionen wirken anachronistisch. | Hoch: moderne Funktionen werden als Talvori-Artefakte, Lernobjekte und magische Werkzeuge uebersetzt. |
| Visuelle Konsistenz | Risiko durch Autos, Asphalt, reale Beschilderung und Tech-UI. | Risiko durch zu viel historische Genauigkeit und detailreiche Rekonstruktion. | Beste Balance aus Firenze-Identitaet, Spielbarkeit und Talvori-Eigenstil. |
| Mit Meshy/AI produzierbar | Gut, aber generisch und nahe an realistischen Stadtassets. | Mittel: historische Details koennen kleinteilig und inkonsistent werden. | Gut: klare Promptfamilien, modulare Props, stilisierte Materialien. |
| Stilbruch-Risiko | Hoch. | Mittel. | Niedrig bis mittel, wenn Palette, Materialien und Verbotenliste streng bleiben. |

Entscheidung:

```text
C) Talvori Neo-Renaissance / Magical Renaissance
```

Firenze soll Renaissance-inspiriert, spielerisch stilisiert und eindeutig
Talvori-eigen werden. Moderne Funktionen duerfen vorkommen, aber nur als
Talvori-Interpretation: Sprachlaternen, Lexikon-Werkbaenke, Erinnerungssteine,
Uebersetzungsatelier, Companion-Signale und Lernartefakte statt realer Screens,
Autos, App-Panels oder Neon-Stadt.

## 5. Firenze Visual Contract v1

### Epoche und Stil

- Fuehrend: `Talvori Neo-Renaissance / Magical Renaissance`.
- Renaissance-inspirierte Firenze-Formen, aber keine historische Rekonstruktion.
- Moderne stilisierte 2D-/2.5D-Mobile-Game-Lesart.
- Welt zuerst als begehbarer Spielort, nicht als Karte.
- Cyan/Lila/Dark-Neon nur als Interaktions- und Lernmagie-Akzent.

### Farbpalette

| Rolle | Farben |
| --- | --- |
| Stadtbasis | warmer Kalkstein, heller Putz, Terracotta, Sandstein, gedecktes Ocker |
| Vegetation | Zypressengruen, Olivgruen, Kraeutergruen, warme Wiesentoene |
| Wasser | ruhiges Arno-Tuerkis, tiefes Blaugruen, weiche helle Reflexe |
| Schatten | weiches Indigo, warmes Braunviolett, kein hartes Schwarz |
| Interaktion | Cyan, Lila, Gold, nur sparsam fuer aktive Lern-/Magieobjekte |

Keine dominante Beige-/Braunwelt, keine reine Slate-/Neonwelt, keine grellen
Comicfarben als Hauptpalette.

### Materialien

- Stein, heller Putz, Terracotta, Holz, Bronze, Keramik, Stoff, Glas/Kristall.
- Magische Lernobjekte wirken wie handwerkliche Artefakte, nicht wie Sci-Fi.
- Texturen bleiben stilisiert und mobile-lesbar.
- Keine fotorealistischen Fassaden, keine KI-Fransen, keine inkonsistente
  Materialqualitaet pro Assetfamilie.

### Strassen und Wege

- Warme, klare Stein- und Pflasterwege.
- Wege duerfen organisch bleiben, aber muessen die echte Firenze-Graphlogik
  visuell tragen.
- Route/Walk-Layer bleibt eine Gameplay-Schicht ueber dem Visual Skin.
- Keine Asphaltstadt, keine Satellitenkarte, keine technische Linienkarte.

### Gebaeudeformen

- Kleine Renaissance-inspirierte Haeuser, Werkstaetten, Bibliotheken,
  Arkaden, Loggien, Laubengaenge, Turm-/Dachsilhouetten.
- Klare 2.5D-Silhouetten, nicht realistische Fassadenrekonstruktion.
- Modular: Fassaden, Dachkanten, Torboegen, Fenster, Laeden, Treppen,
  Terrassen, kleine Hoehenverspruenge.
- P01-P14 bleiben Gameplay-/Plot-Logik; die Art darf Plot-Skins liefern,
  aber keine Plot-Geometrie veraendern.

### Bruecken und Arno

- Arno bleibt zentrale Struktur, Barriere und Atmosphaerenachweis.
- Bruecken sind warme Steinbruecken mit Renaissance-Anmutung und klaren
  Walk-Decks.
- Keine Arno-Querung ausserhalb der bestehenden Bridge-Ketten.
- Wasser darf subtil magisch reflektieren, aber keine grellen VFX-Streifen.

### Vegetation

- Zypressen, Oliven, Kraeuter, Rankpflanzen, kleine Gärten, Terracotta-Toepfe.
- Scenic Ring bleibt nicht spielbar, aber gestaltet.
- Vegetation darf Abstand, Rand, Tiefe und Szene geben; sie darf Wege, Plots
  und Figuren nicht verdecken.

### Interaktionsobjekte

Moderne Funktionen werden uebersetzt:

| Funktion | Talvori-Interpretation |
| --- | --- |
| Quest/Mission | kleine Weltmarke, Companion-Bubble, Wachssiegel, Lichtsignal |
| Lernen/Wort | Sprachlaterne, Lexikon-Stein, Notizrolle, Klangmuschel |
| Uebersetzen | Uebersetzungsatelier, Kristallprisma, Kartenpult |
| Import/Sammlung | Kurierkiste, Reisetagebuch, Marktregister |
| Fortschritt | Bauflagge, Materialkiste, Werkbank, leuchtender Meilenstein |
| Debug/Preview | nur kDebug/Preview-HUD, nie als Hauptweltobjekt |

### Figurenkompatibilitaet

- Der Explorer bleibt moderne 2D-/2.5D-Sprite-Referenz.
- NPCs muessen dieselbe Perspektive, Lichtquelle, Groesse, Schattenlogik und
  Grounding-Regel teilen.
- Keine NPC-Menge vor funktionierender Einzelfigur und Variantenfreigabe.
- Backward-Walk bleibt Spezialanimation, nicht Standard-Movement.

### Verbotene Stilbrueche

- Modern-realistische Autos, Strassenlaternen, Asphalt, Ampeln, Handy-Screens,
  realistische Werbeschilder.
- Antike/Rom-Kulisse, Mittelalter-Fantasy-Castle, generische DnD-Stadt.
- Voller Cyberpunk, dominante Neonstadt, Sci-Fi-Hologramm-UI.
- GIS-/Admin-/Debuglabels als Player-facing Hauptwelt.
- Clash-of-Clans-, Clash-Royale-, Rise-of-Kingdoms- oder fremde IP-Kopie.
- Fotorealistische Asset-Sets neben handgemalten Talvori-Sprites.

## 6. Meshy-/AI-Assetliste fuer den laufenden Abo-Monat

Ziel: moeglichst viele wiederverwendbare Master-/Candidate-Quellen sichern,
ohne sie als Produktionsassets nach `assets/` zu importieren.

### Prioritaet 1: wiederverwendbare Basis-Props

| Asset | Zweck | Tool-Vorschlag | Exportziel | Risiko |
| --- | --- | --- | --- | --- |
| `firenze_cobble_road_tile_set_v1` | Strassen-/Route-Skin fuer Graphwege | Meshy + Blender | GLB Master, gerenderte 2D Tile-/Patch-Frames | Pflaster kann zu realistisch oder zu kleinteilig werden. |
| `firenze_stone_curb_and_steps_v1` | Wegkanten, Treppen, kleine Hoehen | Meshy + Blender | GLB, 2D Props | Scale muss zu Explorer und Plotkamera passen. |
| `firenze_word_lantern_v1` | Lern-/Questsignal statt Tech-UI | Meshy/Scenario + Blender | Konzeptbild, GLB, 2D Prop | Glow darf nicht Neonwelt dominieren. |
| `firenze_market_crates_barrels_v1` | Markt, Material, Baustellenfeedback | Meshy + Blender | GLB Set, 2D Props | Zu generisch, wenn keine Talvori-Akzente. |
| `firenze_cypress_planter_v1` | Vegetations- und Scenic-Ring-Baustein | Meshy + Blender | GLB, 2D Prop | Baumdetails koennen auf Mobile flimmern. |

### Prioritaet 2: Gebaeude-/Strassenmodule

| Asset | Zweck | Tool-Vorschlag | Exportziel | Risiko |
| --- | --- | --- | --- | --- |
| `neo_renaissance_house_facade_a_v1` | Standard-Wohn-/Plot-Fassade | Meshy + Blender | GLB Master, 2D facade render | Stil muss klar Talvori bleiben. |
| `neo_renaissance_arch_loggia_kit_v1` | Arkaden, Durchgaenge, Marktrand | Meshy + Blender | GLB modular kit | Kann zu historisch/detailreich werden. |
| `terracotta_roof_edge_kit_v1` | Wiedererkennbare Dachfamilie | Meshy + Blender | GLB kit, 2D trims | Wiederholungen duerfen nicht auffallen. |
| `workshop_market_stall_v1` | Markt-/Werkstattaktivitaet | Meshy/Scenario + Blender | GLB, 2D prop group | Muss als Spielobjekt, nicht Deko-Clutter, lesbar sein. |
| `parcel_foundation_marker_v1` | dauerhafte Bauortmarke | Meshy/Blender | 2D prop, GLB source | Darf keine produktive BuildState-Logik implizieren. |

### Prioritaet 3: Landmark-/Firenze-Elemente

| Asset | Zweck | Tool-Vorschlag | Exportziel | Risiko |
| --- | --- | --- | --- | --- |
| `arno_stone_bridge_module_v1` | Firenze-Brueckenlesart ueber B01-B08 | Meshy + Blender | GLB, 2D bridge deck renders | Muss Bridge-Ketten respektieren, nicht neue Querungen erfinden. |
| `firenze_small_piazza_fountain_v1` | Platzanker und Activity-Point | Meshy + Blender | GLB, 2D prop | Wasser/VFX getrennt halten. |
| `generic_renaissance_tower_silhouette_v1` | Landmark-Fernlesbarkeit | Meshy/Leonardo + Blender | Konzept, GLB silhouette | Nicht exakte Rekonstruktion realer Wahrzeichen. |
| `arno_quay_wall_v1` | Uferkante und Stadt-River-Integration | Meshy + Blender | GLB kit, 2D edge renders | Darf River-Maske nicht veraendern. |

### Prioritaet 4: NPC-/Citizen-Varianten

| Asset | Zweck | Tool-Vorschlag | Exportziel | Risiko |
| --- | --- | --- | --- | --- |
| `citizen_base_01_render_source_cleanup_v1` | Explorer/Citizen Master sichern | Blender | GLB/BLEND QA, 2D render sequences | Keine Variantenproduktion vor Basisfreigabe. |
| `citizen_base_01_8dir_walk_render_set_v1` | Runtime-Kandidat fuer Motion-Gate | Blender + Aseprite QA | transparente 2D Sprite-Sequenzen | Nur nach Import-Gate; nicht direkt in `assets/`. |
| `citizen_style_family_reference_v1` | spaetere Varianten absichern | Scenario/Leonardo/Blender | Konzeptbild, nicht Runtime | Varianten bleiben gesperrt bis Basisfigur frei ist. |

### Prioritaet 5: Interaktions-/Lernobjekte

| Asset | Zweck | Tool-Vorschlag | Exportziel | Risiko |
| --- | --- | --- | --- | --- |
| `lexicon_stone_kiosk_v1` | Weltliches Lernobjekt | Meshy/Scenario + Blender | GLB, 2D prop | Darf nicht wie modernes Tablet aussehen. |
| `translation_prism_workbench_v1` | Uebersetzungs-/Import-Funktion | Meshy + Blender | GLB, 2D prop | Sci-Fi-Risiko; Material warm halten. |
| `phrase_loom_v1` | Satz-/Grammar-Anker | Meshy/Leonardo + Blender | Konzept, GLB/2D prop | Muss sofort als friedliche Lernmaschine lesbar sein. |
| `quest_seal_marker_v1` | Mission/Action Signal | Scenario/Aseprite/Blender | 2D UI-world hybrid | Nicht zum grossen HUD-Panel werden lassen. |

## 7. Schutz der bestehenden Firenze-Layoutlogik

Diese Elemente bleiben verbindlich und werden durch Art-Skins nicht ersetzt:

- Boundary,
- River/Arno,
- Roads,
- Bridge-Ketten B01-B08,
- P01-P14 und deren Access-/Entry-Logik,
- Landmark-/Anchor-Familien,
- Navigation Graph mit 181 Nodes und 221 Edges,
- `city_spawn_start`,
- bestehende Preview-Core-Daten und Source-SHA.

Neue Art darf:

- vorhandene Roads visuell als Pflaster, Kanten oder Wegbelag skinnen,
- bestehende Plot- und Anchor-Lesarten als weltliche Signale zeigen,
- Bruecken und Ufer als Stil-Layer darstellen,
- Scenic Ring und Stadtoberflaeche spielweltlich aufwerten.

Neue Art darf nicht:

- neue freie Wege erfinden,
- neue Arno-Querungen erzeugen,
- Plot-Positionen oder Entry-Ziele verschieben,
- River-/Boundary-/Road-Geometrie veraendern,
- Debug-/GIS-Labels in player-facing Art verwandeln,
- Produktivassets ohne eigenes Gate nach `assets/` bringen.

## 8. Risiken und Gegenmassnahmen

| Risiko | Gegenmassnahme |
| --- | --- |
| Meshy/AI erzeugt inkonsistente Einzelstile. | Kleine Assetfamilien, Contact Sheets, Style-Metadaten und harte QA gegen 367/438. |
| Neo-Renaissance kippt in Museum oder Kostuemfilm. | Spielobjekte, Lernmagie und mobile Lesbarkeit bleiben wichtiger als historische Korrektheit. |
| Magische Akzente kippen in Neon/Sci-Fi. | Cyan/Lila/Dark nur als Interaktionssprache, nicht als Hauptpalette. |
| Props ueberfuellen die Stadt. | Prop-Familien als Kit, keine Deko-Massen vor District-Slice. |
| Charakter und Environment haben andere Perspektive. | Blender-Renderkameras und 2.5D-Kontrakt gemeinsam testen, bevor Import-Gate oeffnet. |
| Assetgroessen und Dateimengen wachsen stark. | Rohdaten bleiben ausserhalb Git; spaeter LFS/Asset-Archiv-Konzept. |
| Real-Firenze-Referenzen werden zu direkt kopiert. | Nur inspiriert, stilisiert und generisch; keine fremden Spielstile oder IP. |

## 9. Ergebnis

Decision: PASS.

Gewaehlte Richtung:

```text
Talvori Neo-Renaissance / Magical Renaissance
```

Firenze wird als spielbare, stilisierte Talvori-Stadt gedacht: Renaissance-
inspiriert, warm, handwerklich, magisch genug fuer Sprache/Lernen und
Weltbau, aber nicht modern-realistisch, nicht Altertum und nicht technische
Karte.

Produktionsasset-Gate:

```text
CLOSED
```

Naechster empfohlener Codex-Slice:

```text
Talvori Firenze Neo-Renaissance Visual Direction Board 1K
```

Scope fuer 1K:

- ein kompaktes Reference-/Prompt-/QA-Board fuer genau einen District- oder
  Street-Corner-Vertical-Slice,
- keine Runtime-Integration,
- keine Dateien unter `assets/`,
- keine neue Graph-/Layoutlogik,
- klare Promptfamilien fuer Prioritaet-1-Props und ein kleines Strassenkit,
- Meshy-/Blender-/Aseprite-QA-Checkliste fuer den Abo-Monat.
