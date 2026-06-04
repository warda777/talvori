# Phase 2G: Frame Started Asset Prompt

Stand: 2026-06-04

Dieses Dokument ist der Asset-Prompt-/Freigabeblock fuer Phase 2G
`frame_started` / Rohbau.

Es erzeugt noch kein Asset. Es gibt keinen Code frei. Es bereitet nur den
Prompt, die Materialentscheidung, die Preview-Pruefung und die Freigabe-Gates
fuer einen spaeteren Asset-Erzeugungsblock vor.

Fuehrende Dokumente:

- `docs/world_design/243-frame-started-plan.md`
- `docs/world_design/235-world-production-roadmap-and-checklists.md`
- `assets/images/world/buildable_islands/forest_clearing/template.md`
- `docs/world_design/234-asset-production-and-buildable-island-templates.md`
- `docs/world_design/239-world-scale-and-dimension-rules.md`
- `docs/world_design/240-private-island-state-system.md`
- `docs/world_design/241-build-feedback-animation-and-sound.md`
- `docs/world_design/242-foundation-complete-plan.md`

## 1. Zweck Des Dokuments

Dieses Dokument bereitet den spaeteren Asset-Erzeugungsblock fuer
`frame_started.png` vor.

Ziel:

- kurzer Professional Game Development Research Gate,
- Materialentscheidung fuer den ersten Rohbau,
- finaler Asset-Prompt fuer `frame_started.png`,
- negative Prompt-/Ausschlussliste,
- technische Anforderungen,
- Preview-/Pruefplan,
- weiterhin blockierte Systeme,
- naechster erlaubter Schritt.

Nicht-Ziel:

- kein Asset erzeugen,
- kein `frame_started.png` erstellen,
- keine PNGs veraendern,
- kein Flutter-/Dart-Code,
- keine App-Integration,
- keine Tests,
- keine Persistenz,
- keine Supabase Writes,
- keine SRS-/`word_progress`-Aenderung,
- keine Reward Bridge,
- keine Ressourcenlogik.

## 2. Research-Gate: Rohbau- Und Construction-Progress-Stufen

Fokussierte Orientierung:

| Quelle / Orientierung | Ableitung fuer Talvori | Entscheidung |
| --- | --- | --- |
| Unity Learn, `Creating a prototype blockout from concept art`: `https://learn.unity.com/tutorial/creating-a-prototype-blockout-from-concept-art` | Professionelle Umgebungsarbeit identifiziert zuerst fokale Formen, interaktive Bereiche und modulare Wiederverwendung, bevor finale Assets entstehen. | `frame_started` wird nicht als huebsche Mini-Huette gedacht, sondern als klare Rohbauform auf der bestehenden BuildArea. |
| Sim Settlements Toolkit, `Construction Stages and Upgrade Levels`: `https://simsettlements.com/web/wiki/index.php?title=Toolkit_Chapter_03_Construction_Stages_and_Upgrade_Levels` | Baufortschritt kann ueber getrennte visuelle Stufen entstehen, die ein Gebaeude nicht sofort fertig zeigen. Construction-Stages muessen geordnet und unterscheidbar bleiben. | `frame_started` muss sichtbar weiter als `foundation_complete` sein, aber noch deutlich vor `frame_complete` und `building_level_1` liegen. |
| IBM Design Language, `Isometric style`: `https://www.ibm.com/design/language/illustration/isometric-style/design/` | Isometrische Objekte brauchen konsistente Winkel, grundlegende Formen sowie einheitliche Licht- und Schattenlogik. | Das Rohbau-Overlay nutzt dieselbe 2.5D/isometrische Perspektive, Lichtlogik und Canvas-Position wie die bisherigen Waldlichtung-Assets. |
| GameDevFoundry, `Stages of Game Development`: `https://www.gamedevfoundry.com/StagesOfGameDevelopment.html` | Pre-Production und Vertical-Slice-Denken sollen Risiken klein halten; Produktion wird erst sinnvoll, wenn Scope, Pipeline und Qualitaet wiederholbar sind. | Dieser Block bleibt Prompt-/Freigabevorbereitung. Asset-Erzeugung und Code starten erst nach expliziter Freigabe. |

Ableitung:

- Ein frueher Rohbau braucht eine klare, lesbare Silhouette.
- Die Silhouette darf hoeher sein als das Fundament, aber nicht wie ein
  fertiges Haus wirken.
- Die sichtbare Konstruktion muss offen bleiben: Pfosten, einfache Querbalken
  und wenige Rahmenansaetze statt geschlossener Waende.
- Das Asset muss als wiederholbarer BuildAreaState funktionieren, nicht als
  einmalige Sondergrafik.
- Material und Form muessen sich an der Waldlichtung orientieren, aber
  category-neutral bleiben.

Risiken:

- Zu viele Wandflaechen lassen `frame_started` wie `building_level_1` wirken.
- Zu duenne Pfosten sind im Mobile-Island-View nicht lesbar.
- Zu viel Steinmasse wirkt wie ein zweites Fundament statt Rohbau.
- Lehmflaechen wirken schnell wie fertige Huettenwaende.
- Zu viel Deko, Glow oder Bauwerkzeug wirkt wie UI/Marker oder fertige Szene.

Erlaubt durch diese Entscheidung:

- einen klaren Holzrahmen-Rohbau prompten,
- wenige simple Stuetzen, Balken und offene Rahmenansaetze nutzen,
- dieselbe BuildArea und denselben Canvas wie die bisherigen Overlays nutzen.

Blockiert bleibt:

- Asset-Erzeugung ohne Prompt-Freigabe,
- Code,
- App-Integration,
- PlacedItems,
- Expansion,
- Interiors/ObjectDetail,
- produktive Bau-/Lernlogik.

## 3. Materialentscheidung

Vergleich:

| Option | Staerken | Risiken | Bewertung |
| --- | --- | --- | --- |
| Holzrahmen | Passt natuerlich zur Waldlichtung, wirkt frueh und unfertig, erzeugt klare Pfosten-/Balken-Silhouette, bleibt category-neutral, blockiert wenig Flaeche. | Zu feine Balken koennen im Mobile-View verschwinden. | Beste Option, wenn Balken etwas ueberzeichnet und sauber lesbar sind. |
| Stein/Holz-Mix | Verbindet sich gut mit dem Fundament und wirkt stabil. | Zu viel Stein wirkt schwer, wandartig oder wie fortgeschrittene Bauphase; kann Hof/Vorplatz optisch blockieren. | Nur sehr sparsam als Kontaktpunkte oder Sockeluebergang, nicht als Hauptmaterial. |
| Lehm/Holz-Mix | Warm, natuerlich und spaeter gut fuer Huette/Haus. | Lehmflaechen wirken schnell wie geschlossene Waende und damit zu fertig. | Fuer `frame_complete` oder `building_level_1` moeglich, fuer `frame_started` zu riskant. |

Empfehlung:

`frame_started` soll primaer als leichter Holzrahmen geplant werden.

Erlaubt sind wenige kleine Stein-/Erdkontaktpunkte dort, wo die Pfosten auf dem
fertigen Fundament stehen. Nicht erlaubt sind geschlossene Lehmwandflaechen,
Steinwandreihen oder ein vollstaendiger Wandkoerper.

Begruendung:

- Holz ist fuer eine Waldlichtung glaubwuerdig.
- Pfosten und Balken lesen sich in kleiner Ansicht besser als flache
  Materialflaechen.
- Offene Holzrahmen kommunizieren klar: Rohbau begonnen, aber noch nicht
  bewohnbar.
- Der Zustand bleibt neutral genug fuer spaetere Kategoriegebaeude.

## 4. Zielpfad Und Status

Spaeterer Zielpfad:

```text
assets/images/world/buildable_islands/forest_clearing/frame_started.png
```

Status:

- Prompt vorbereitet.
- Asset noch nicht erzeugt.
- Prompt noch nicht vom Nutzer freigegeben.
- Asset-Erzeugung bleibt blockiert.
- Phase-2G-Code bleibt blockiert.

## 5. Finaler Asset-Prompt Fuer `frame_started.png`

```text
Create a transparent PNG/RGBA overlay for a 2.5D/isometric mobile game buildable island.

Target asset:
assets/images/world/buildable_islands/forest_clearing/frame_started.png

Use the existing forest clearing buildable island assets as visual references:
- base.png
- foundation_started.png
- foundation_complete.png

The new asset represents the "frame_started" construction state. It must be a BuildAreaState overlay, not a full island replacement and not a placed world item.

Technical requirements:
- transparent PNG/RGBA overlay only
- exact canvas size: 1536 x 1024
- same canvas, perspective, alignment, lighting direction and isometric angle as base.png, foundation_started.png and foundation_complete.png
- visible content sits on the existing main_build_area
- the overlay should visually replace foundation_complete as the current build state, not require permanent stacking on top of foundation_complete
- include enough of the completed foundation/sockel footprint inside the overlay to make the frame feel grounded, but do not redraw the whole island

Visual goal:
- early rough construction frame on top of the completed foundation
- primary material: natural wooden frame
- optional very small stone/earth contact points where posts meet the foundation
- 4 to 6 simple wooden posts or supports
- a few simple horizontal beams and optional diagonal braces
- one or two very small unfinished wall-frame hints, but mostly open structure
- clearly unfinished and not habitable
- small but readable height in mobile Island View
- natural forest-clearing material language
- category-neutral, no thematic symbols
- enough visual progress beyond foundation_complete to feel like the next build stage
- modest scale so yard/front area/path/expansion remain plausible
- calm, high-quality cozy 2.5D mobile game diorama style
- slightly handcrafted and unfinished, with small natural variation in wooden posts and beams
- not perfectly symmetrical, not too clean, not like a finished icon
- still high-quality, calm and clearly readable, not chaotic or dirty

The result should communicate:
"The house is starting to rise, but it is still only a rough frame."

Do not make it look like:
- building_level_1
- a finished hut
- a finished house
- frame_complete
- a decorated or habitable building
- a perfectly polished miniature house icon
```

## 6. Negative Prompt / Ausschluesse

```text
No full island image.
No background.
No space background.
No UI elements.
No text.
No labels.
No buttons.
No arrows.
No markers.
No glowing magical platform.
No modern platform.
No rectangular UI base.
No hard rectangular matte.
No chroma-key leftovers.

No finished house.
No finished hut.
No complete closed walls.
No finished roof.
No full roof shape.
No complete door.
No complete windows.
No furniture.
No interior.
No porch furniture.
No lanterns as finished decoration.
No chimney.
No flowerbeds.
No garden decoration.
No NPCs.
No tools used as UI-like markers.
No category symbols.
No travel, health, business, school, food or tech symbols.

No heavy stone wall courses.
No closed clay wall panels.
No large solid wall masses.
No oversized structure.
No object that blocks yard, path, docking candidates or future expansion.
No excessive dust, particles, glow or baked animation effects.
No perfectly symmetrical icon-like frame.
No chaotic ruin.
No broken hut.
No dirty construction site.
No overloaded detail density.
```

## 7. Technische Asset-Anforderungen

Das spaeter erzeugte Asset muss:

- `1536 x 1024` Pixel gross sein,
- PNG/RGBA sein,
- transparente Ecken haben,
- keine Chroma-Key-Reste enthalten,
- denselben Canvas wie `base.png`, `foundation_started.png` und
  `foundation_complete.png` nutzen,
- auf der bestehenden `main_build_area` sitzen,
- perspektivisch zu `base.png` passen,
- `foundation_complete` als aktueller BuildAreaState visuell ersetzen,
- nicht dauerhaft mit `foundation_started` oder `foundation_complete`
  gestapelt werden muessen.

## 8. Visuelle Akzeptanzkriterien

Das Asset ist nur brauchbar, wenn:

- `frame_started` klar weiter als `foundation_complete` wirkt,
- der Zustand weiterhin klar unfertig bleibt,
- die Konstruktion offen ist,
- der Rohbau leicht handwerklich/unfertig wirkt, ohne chaotisch, kaputt oder
  dreckig zu erscheinen,
- der Rohbau nicht wie ein perfektes fertiges Minihaus-Icon wirkt,
- keine fertigen Waende, kein fertiges Dach, keine fertige Tuer und keine
  fertigen Fenster sichtbar sind,
- es nicht wie `building_level_1` wirkt,
- der Holzrahmen im Mobile-Island-View lesbar ist,
- Groesse und Hoehe zur Insel passen,
- Hof/Vorplatz, erster Weg, Deko- und Expansion-Raum plausibel bleiben,
- Docking-/Connector-Kandidaten nicht verdeckt werden,
- Material, Licht und Perspektive zur Waldlichtung passen,
- keine UI-/Marker-Optik entsteht.

## 9. Preview-/Pruefplan Nach Spaeterer Asset-Erzeugung

Nach spaeterer Erzeugung von `frame_started.png` muss geprueft werden:

- `base.png` allein,
- `base.png + foundation_complete.png`,
- `base.png + frame_started.png`,
- Contact Sheet:
  - `base`,
  - `foundation_started`,
  - `foundation_complete`,
  - `frame_started`.

Pruefpunkte:

- gleicher Canvas,
- PNG/RGBA,
- transparente Ecken,
- keine Chroma-Key-Reste,
- sitzt plausibel auf der `main_build_area`,
- wirkt klar weiter als `foundation_complete`,
- wirkt klar unfertig,
- kein fertiges Haus,
- keine fertigen Waende,
- kein fertiges Dach,
- keine fertige Tuer-/Fenster-Optik,
- keine UI-/Marker-Optik,
- Groessenverhaeltnis passt zur Insel,
- Hof/Weg/Expansion bleiben plausibel,
- `frame_started` ersetzt `foundation_complete`, statt dauerhaft darauf
  gestapelt zu werden.

## 10. Weiterhin Blockierte Systeme

Weiterhin blockiert:

- Flutter-/Dart-Code,
- App-Integration,
- Asset-Erzeugung ohne ausdrueckliche Prompt-Freigabe,
- PNG-Aenderungen in diesem Block,
- Tests,
- Supabase Writes,
- Persistenz,
- SQLite-/SRS-/`word_progress`-Aenderungen,
- Reward Bridge,
- Ressourcenlogik,
- Sound-/FX-Schicht,
- Audio/Sounddateien,
- Expansion,
- PlacedItems,
- Interiors/ObjectDetail,
- produktive Bau-/Lernlogik.

## 11. Naechster Erlaubter Schritt

Nach diesem Dokument ist nur erlaubt:

- Prompt pruefen und freigeben,
- oder Prompt nachbessern.

Nicht erlaubt ist:

- direkt `frame_started.png` erzeugen,
- direkt Phase-2G-Code bauen,
- direkt App-Integration starten.

Asset-Erzeugung darf erst starten, wenn der Prompt explizit freigegeben wurde.
Code darf erst starten, wenn das Asset erzeugt, lokal vorgeprueft, in
`template.md` dokumentiert, auf Geraet geprueft und formal fuer einen engen
lokalen Mock-Slice freigegeben wurde.

## 12. Offene Fragen

- Reicht die Holzrahmen-Silhouette nach der ersten Preview in mobiler Groesse?
- Muss der Rohbau minimal hoeher oder breiter werden, um lesbar zu sein?
- Soll `frame_started` im spaeteren Code als direkter Tap nach
  `foundation_complete` funktionieren oder zunaechst nur visuell geprueft
  werden?
- Reicht die Overlay-Strategie auch fuer vertikale Rohbau-Elemente, oder muss
  nach dem Device-Check eine alternative Asset-Strategie geprueft werden?
