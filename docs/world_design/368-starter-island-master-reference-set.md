# M16-CB: Starter Island Master Reference Set

Stand: 2026-06-11

Status: `Markdown-Docs-/Master-Reference-Brief-Gate / keine Implementierung`

## 1. Zweck und Non-Goals

M16-CB definiert die ersten Master-Reference-Briefs fuer die Starter-Insel
und zentrale visuelle Familien von Talvori. Diese Briefs sind die Bruecke
zwischen der Art Bible v1 und spaeteren Asset-Familien-/Export-Spezifikationen.

Ziel:

- Uferhain als Starter-Insel konkret genug fuer spaetere Master References
  eingrenzen.
- Build Station, Haus-Bauphasen, Figuren, HUD, Slots und Layer als visuelle
  Familien beschreiben.
- Style-/Structure-Reference-Bedarf, erlaubte Variation und QA-Kriterien
  vor spaeterer Bildproduktion klaeren.
- M16-CC vorbereiten, ohne schon Asset-Familien, Exportformate oder
  Spielbilder zu erzeugen.

Non-Goals:

- keine Bilder,
- kein Preview-Ordner,
- keine PNG,
- keine SVG,
- keine Bilddatei,
- keine Assets,
- keine Dateien unter `assets/`,
- keine High-Fidelity-Spielbilder,
- keine App-Screens,
- keine Flutter-/Dart-Dateien,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- kein BuildState,
- keine Tests,
- keine Figma-/Notion-/Linear-/GitHub-Writes,
- keine externen Writes,
- keine Stashes anfassen,
- keine Produktivmechanik-Freigabe.

M16-CB ist ein Reference-Brief-Gate. Es beschreibt, welche Master References
spaeter entstehen sollen. Es erzeugt keine Master-Reference-Bilder und keine
engine-ready Kandidaten.

## 2. Eingangsquellen und Abgrenzung

Fuehrende Quellen:

- M16-BY: `docs/world_design/365-modern-mobile-game-direction-board.md`
- M16-BZ: `docs/world_design/366-ai-art-production-pipeline-and-style-consistency-gate.md`
- M16-CA: `docs/world_design/367-talvori-art-bible-v1.md`
- Starter Island Infrastructure: `docs/world_design/351-starter-island-infrastructure-strategy-gate.md`
- Starter Island Identity / Biome / Category Scope:
  `docs/world_design/353-starter-island-identity-biome-and-category-scope-gate.md`
- Construction-Learning Spine:
  `docs/world_design/355-talvori-core-construction-learning-spine.md`
- Game-like Camera Flow:
  `docs/world_design/357-game-like-island-selection-and-construction-camera-flow-gate.md`
- Object-first Construction Play:
  `docs/world_design/359-successful-game-pattern-translation-for-talvori-construction-play.md`
- Character-assisted World Action:
  `docs/world_design/360-character-assisted-world-action-rule.md`
- Professional Design Gate:
  `docs/world_design/363-professional-island-build-flow-design-gate.md`

Abgrenzung:

- M16-BY definiert die moderne Game-DNA: Cozy Island Diorama Builder,
  island-first, object-first, character-assisted, Build Station am Slot und
  kein Schul-/Worksheet-/Menue-first-Gefuehl.
- M16-BZ definiert die kontrollierte KI-Art-Pipeline und verbietet freie
  Einzelprompts, Codex-Bildnachbau und ungepruefte finale Assets.
- M16-CA definiert das Style-System: Kamera, Perspektive, Licht, Farbe,
  Formensprache, Figuren, Build Station, UI/HUD, Layer und QA.
- M16-CB definiert nur Master-Reference-Briefs. Es ist noch nicht M16-CC,
  erzeugt keine Asset-Familien-Spezifikation und startet keine
  High-Fidelity- oder Flutter-Arbeit.

Das starke Talvori-Referenzbild bleibt Art-Direction-Reference. Es ist kein
App-Screen, kein finales Asset, nicht nach `assets/` zu kopieren und nicht von
Codex nachzuzeichnen.

`modern_mobile_game_direction_board_v2.*` bleibt rejected/transitional. Es ist
kein visuelles Zielbild fuer M16-CB.

## 3. Master-Reference-Regel: Referenz-Brief, nicht Asset

Eine Master Reference ist in M16-CB zuerst ein Brief:

```text
Was muss spaeter als fuehrende visuelle Referenz entstehen?
Welche Rolle spielt diese Referenz?
Welche Style-, Structure-, Layer- und QA-Regeln gelten?
Was darf sie ausdruecklich noch nicht freigeben?
```

M16-CB-Master-Reference-Briefs sind:

- fachliche Referenzbeschreibungen,
- Grundlage fuer spaetere KI-/Figma-/Artist-Arbeit,
- QA-Raster gegen Stilbruch,
- Input fuer M16-CC Asset Family and Export Spec.

Sie sind nicht:

- finale Assets,
- App-Screens,
- Spielbilder,
- Dateien unter `assets/`,
- Export-Spezifikationen,
- Flutter-Kompositionen,
- BuildState- oder Persistenzfreigaben.

Jede spaetere echte Master Reference braucht eigene Quellen-, Prompt-,
Reference-, Lizenz- und QA-Metadaten.

## 4. Starter-Insel / Uferhain Master Reference

| Feld | Brief |
| --- | --- |
| Zweck | Fuehrende Referenz fuer die erste Starter-Insel als Uferhain: eine Kuestenhain-/Flussufer-Starterinsel. |
| Rolle im Spiel | Erster eigener Ort des Spielers, Insel-Showcase, Slot-Auswahl, Weltkontext fuer Zuhause/Haus und spaetere Sprache. |
| Sichtbare Bestandteile | Kueste, Flussarm, Hain, zentrale Lichtung / Hub, 1-2 Hauptwege, leichte Hoehen, ruhige Randbereiche, spaetere Teaser-Bereiche. |
| Kamera / Perspektive | 2.5D-Diorama mit leicht erhoehter Kamera; Insel, Slots, Wege, Figuren und Bauobjekte muessen dieselbe Perspektive teilen. |
| Licht / Farbe | Warmes, klares Tageslicht; Gruenfamilien fuer Hain/Wiese, Blau/Tuerkis fuer Wasser, warme Erd-/Sandtoene fuer Wege und Slots. |
| Proportionen | Kompakte, erweiterbare Insel; ca. 12 sichtbare Slots, 6 sofort nutzbare freie Slots, 6 spaetere sichtbare Slots, Reserve fuer 16-20 Slots langfristig. |
| Layer-Erwartung | Inselbasis/Wasser/Rand -> Terrainflaechen -> Wege -> Slot-Marker -> Build Station/Bauidee -> Gebaeudephase -> Figuren -> Reaktionen -> HUD/Bubbles. |
| Mobile-Lesbarkeit | Slots bleiben unterscheidbar; Wege/Wasser/Hain tragen Orientierung; keine Labelwolke; kein einzelner Slot darf die ganze Insel dominieren. |
| Style-Reference-Bedarf | Cozy 2.5D island diorama, warm, freundlich, nicht fotorealistisch, nicht generisch cozy, nicht kindlich-klebrig. |
| Structure-Reference-Bedarf | Inselkontur, Wasserarm, Hainzone, zentrale Lichtung, Slotverteilung, Start-/Spaeter-Slots, Hauptwege und Randbereiche. |
| Erlaubte Variation | Slotpositionen, Wegschwung, Hain-Dichte, Uferform, leichte Hoehen, Wasserbreite und Lichtstimmung duerfen variieren. |
| Verbotene Abweichungen | Reine Strandinsel, reine Waldinsel, Stadtkarte, technische Editor-Map, feste Kategorieplaetze, harte Terrainblockaden, zu kleine unlesbare Slots. |
| QA-Kriterien | Uferhain ist sofort als Kuestenhain-/Flussuferinsel lesbar; 12 Slots sind moeglich; Slots bleiben neutral; Insel wirkt wie Spielort, nicht UI. |
| Noch kein Asset | Keine Inselgrafik, keine Map-Datei, keine Layer-Datei, keine App-Komposition, keine Platzierung, keine Persistenz. |

Verbindliche Uferhain-Regeln:

- Uferhain darf nicht generisch werden. Kueste, Flussarm und Hain muessen die
  Identitaet tragen.
- Die zentrale Lichtung / Hub gibt Sicherheit, aber keine Pflichtkategorie.
- Slots beschreiben Lage, nicht Gebaeudeart.
- Terrain darf Varianten nahelegen, aber nicht hart blockieren.
- Erweiterung muss sichtbar sein, aber ohne Unlock-, Timer-, FOMO- oder
  Kaufdruck.

## 5. Build Station Master Reference

| Feld | Brief |
| --- | --- |
| Zweck | Fuehrende Referenz fuer BuildChoice als Weltobjekt am gewaehlten Slot. |
| Rolle im Spiel | Spieler versteht: Ich baue an diesem Ort; Bauideen entstehen direkt im Weltbild, nicht in einem Menue. |
| Sichtbare Bestandteile | Kleine Werkbank, Baukiste, Werkzeugstaender, Baurolle, Materialplatz, ruhige Bauideen-Ghosts, Worker-/Companion-Nahe. |
| Kamera / Perspektive | Gleiche 2.5D-Perspektive wie Slot, Insel und Gebaeude; Station steht auf dem Boden, nicht als Overlay. |
| Licht / Farbe | Etwas heller/aktiver als Umgebung, aber nicht neonhaft; warme Holz-/Stein-/Werkzeugakzente. |
| Proportionen | Groesser als ein Marker, kleiner als ein Gebaeude; klarer Hauptfokus am gewaehlten Slot. |
| Layer-Erwartung | Slot-Marker darunter, Station/Bauidee darueber, Worker daneben/darueber, Bubble/HUD separat und klein. |
| Mobile-Lesbarkeit | Haus als Hauptidee klar antippbar/lesbar; Garten/Werkstatt/Garage kleiner und ruhig; keine acht gleich grossen Labels. |
| Style-Reference-Bedarf | Handwerklich, freundlich, weltlich, nicht Shop, nicht SaaS-Karte, nicht Crafting-Inventar. |
| Structure-Reference-Bedarf | Relation Slot -> Station -> Hausidee -> Alternativen -> Worker/Tali/Vori -> Safe-HUD. |
| Erlaubte Variation | Station kann Werkbank, Baukiste, Materialplatz oder Werkzeugpunkt sein; Alternativen koennen halbkreisfoermig, gestapelt oder als kleine Props erscheinen. |
| Verbotene Abweichungen | Bottom Sheet als Hauptentscheidung, Shop, Menueleiste, Label-Wolke, Formular, technische Blueprint-Tafel, isoliertes Wheel als Hauptpattern. |
| QA-Kriterien | BuildChoice wirkt wie Spielmoment im Weltbild; Haus ist klare Hauptidee; Alternativen sind sichtbar, aber ruhig; Spielraum dominiert. |
| Noch kein Asset | Keine Station-Grafik, keine UI-Komponente, keine BuildChoice-Implementierung, keine Persistenz, kein BuildState. |

Verbindliche Build-Station-Regeln:

- Build Station am Slot ist das fuehrende BuildChoice-Pattern.
- Haus ist fuer den ersten Flow die aktive Hauptidee.
- Garten, Werkstatt und Garage sind kleinere ruhige Alternativen.
- Weitere Moeglichkeiten duerfen spaeter als Kiste, Beutel, Materialrolle oder
  "mehr spaeter"-Andeutung erscheinen.
- Wheel ist nur ein kleiner Bestandteil einer Station, nicht das Hauptpattern.
- Worker/Tali/Vori darf den Moment beleben, aber nicht zu Tutorial-Text
  machen.

## 6. Haus-Bauphasen Master Reference

| Feld | Brief |
| --- | --- |
| Zweck | Fuehrende Referenz fuer den ersten Zuhause/Haus-Bauverlauf und seine sichtbaren Zwischenstufen. |
| Rolle im Spiel | Spieler sieht Weltfortschritt als Bauplatzveraenderung: Boden -> Fundament -> Wand-Ghost -> spaetere Tiefe. |
| Sichtbare Bestandteile | Lockere Erde, Risse/Unruhe, vorbereiteter Boden, Fundamentsteine, stabiler Rahmen, Wand-Ghost, Tuer-/Fenster-Ghost, spaetere Raum-Andeutung. |
| Kamera / Perspektive | Grundstuecksnahes 2.5D-Diorama; Inselumgebung bleibt angedeutet; Bauplatz bleibt Teil der Welt. |
| Licht / Farbe | Startboden etwas dunkler/unruhiger; vorbereiteter Boden heller/ruhiger; Fundament stabil hell; Ghosts transparent und freundlich. |
| Proportionen | Fundament passt auf Slot; Wand-Ghost zeigt naechste Moeglichkeit, ohne fertiges Haus zu sein. |
| Layer-Erwartung | Terrain -> Bauplatzproblem -> vorbereiteter Boden -> Fundament -> Ghost-Schichten -> Worker-Reaktionen -> Bubble. |
| Mobile-Lesbarkeit | Jede Bauphase muss ohne Text unterscheidbar sein; falsche Bauteile bleiben ruhig lesbar, nicht strafend. |
| Style-Reference-Bedarf | Bauphasen muessen zum Cozy-Diorama passen, nicht nach technischer CAD-/Blueprint-Ansicht wirken. |
| Structure-Reference-Bedarf | Reihenfolge und Flaechenrelation: lockerer Boden, geglaettete Flaeche, Fundamentrahmen, Wand-/Tuer-/Fenster-Andeutung. |
| Erlaubte Variation | Rissformen, Steinverteilung, Fundamentrahmenform, Ghost-Transparenz und kleine Arbeitsreaktionen duerfen variieren. |
| Verbotene Abweichungen | Fertiges Haus zu frueh, produktive State-Namen, rotes Fehlerfeedback, Quizkarten, Bauphasen als Menue oder Liste. |
| QA-Kriterien | Spieler versteht: Boden war locker, wurde vorbereitet, Fundament haelt, Aussenwaende sind naechster Hook. |
| Noch kein Asset | Keine Bauphasen-Grafiken, keine finalen Hausassets, keine App-Preview, keine BuildState-Freigabe, keine Persistenz. |

Pflichtphasen:

- lockerer Boden,
- vorbereiteter Boden,
- Fundament,
- Wand-Ghost,
- Tuer-/Fenster-Ghost,
- spaetere Tiefe als Raum/Interior/Container nur vorbereitet.

## 7. Worker / Tali / Vori Master Reference

| Feld | Brief |
| --- | --- |
| Zweck | Fuehrende Referenz fuer Figuren, die Talvori lebendig machen, ohne aus der Welt herauszufallen. |
| Rolle im Spiel | Worker zeigt Weltarbeit; Tali/Vori gibt kurze Companion-Hilfe, feiert Moeglichkeiten und rahmt Sprache. |
| Sichtbare Bestandteile | Worker mit Werkzeug-/Materiallesart; Tali/Vori als freundliche Companion-Figur; einfache Posen, Gesicht, Haltung, klare Silhouette. |
| Kamera / Perspektive | Gleiche Perspektive und Bodenkontakt wie Insel/Gebaeude; Figuren stehen im Diorama, nicht auf der UI. |
| Licht / Farbe | Gleiche Lichtlogik wie Insel; Figuren duerfen Akzentfarben tragen, aber nicht fremd leuchten. |
| Proportionen | Freundlich vereinfacht, emotional lesbar, nicht zu chibi, nicht realistisch, nicht winzig. |
| Layer-Erwartung | Figuren ueber Terrain/Bauobjekten, unter Bubbles/HUD; Arbeitspartikel separat spaeter. |
| Mobile-Lesbarkeit | Koerperform, Werkzeug und Haltung muessen auf kleiner Breite erkennbar bleiben. |
| Style-Reference-Bedarf | Character Master braucht Stilgleichheit mit Insel, Gebaeude und HUD. |
| Structure-Reference-Bedarf | Basisposen: idle, gehen, arbeiten, tragen, zeigen, feiern, kurzer Hinweis. |
| Erlaubte Variation | Kleidung, Werkzeug, kleine Posen, Ausdruck und Companion-Haltung duerfen variieren. |
| Verbotene Abweichungen | Sticker-Look, anderer Renderstil, Tutorial-Maskottchen-Panel, Joystick-Figur, Pathfinding-/Kollisions-Scope. |
| QA-Kriterien | Figur wirkt im selben Raum wie Insel; Worker macht Arbeit sichtbar; Tali/Vori hilft kurz und freundlich. |
| Noch kein Asset | Keine Character-Sprites, keine Animationen, kein Movement-System, kein Joystick, kein Pathfinding, kein Produktiv-Worker. |

Pflichtgrenze:

- Worker ist sichtbarer Arbeitsmoment, nicht Timer- oder Wartezeitmechanik.
- Der Spieler gibt Auftrag, Werkzeug, Material oder Reihenfolge vor; die Figur
  handelt sichtbar.
- Tali/Vori ist Companion-Hilfe, kein dauerhaftes Tutorial-Panel.

## 8. UI / HUD / Bubble Master Reference

| Feld | Brief |
| --- | --- |
| Zweck | Fuehrende Referenz fuer Talvori-Spiel-HUD, Bubbles und Safe Actions. |
| Rolle im Spiel | UI unterstuetzt Weltaktionen, erklaert kurz und laesst die Insel dominieren. |
| Sichtbare Bestandteile | Kleine Bubbles, Safe Actions, minimaler Toolbelt/HUD, kurze Hinweise, optional kleine Status-/Archivzugriffe. |
| Kamera / Perspektive | UI liegt ueber der Welt, darf aber Spielraum nicht zu einer App-Seite machen. |
| Licht / Farbe | Sanfte helle Flaechen, gute Kontraste, kleine Schatten, keine schweren Web-Karten. |
| Proportionen | HUD kleiner als Spielobjekte; Bubbles kurz; keine Textwand; Tap-Ziele mobil sicher. |
| Layer-Erwartung | Oberste Interaktionsschicht; verdeckt keine Build Station, Slots, Worker oder Bauphasen. |
| Mobile-Lesbarkeit | Keine abgeschnittenen Labels, keine einzelnen Buchstaben, keine Ueberlappung mit Weltmoment. |
| Style-Reference-Bedarf | HUD Master muss Spiel-HUD, nicht Dashboard/Worksheet/SaaS, definieren. |
| Structure-Reference-Bedarf | Bubble-Positionen, Safe-Action-Anordnung, Toolbelt-Grenzen, Konflikt mit Build Station. |
| Erlaubte Variation | Bubble-Form, kleine Icon-Buttons, dezente Safe-Actions, kontextuelle Hinweise. |
| Verbotene Abweichungen | Admin-Kaesten, permanente Footer-Leiste, grosse Textpanels, Quizkarte, Formular, App-Screen-Freigabe. |
| QA-Kriterien | UI ist ruhig, kurz, lesbar, weltbezogen und nie Hauptentscheidungstraeger fuer BuildChoice. |
| Noch kein Asset | Keine HUD-Grafik, keine App-Komponente, keine Screen-Freigabe, keine Navigation. |

Geeignete Copy:

- "Such dir eine Insel aus."
- "Such dir einen Ort aus."
- "Dieser Platz ist frei."
- "Was moechtest du hier bauen?"
- "Ein Haus passt hierher."
- "Der Boden ist noch locker."
- "Jetzt haelt der Boden."

Sichtbar vermeiden:

- BuildChoice,
- Blueprint,
- Candidate,
- Phase,
- Pan,
- Zoom,
- Menue,
- BuildState.

## 9. Slot / Marker / Layer Master Reference

| Feld | Brief |
| --- | --- |
| Zweck | Fuehrende Referenz fuer neutrale Slots, Marker, Spaeter-Slots und Layerordnung. |
| Rolle im Spiel | Spieler erkennt freie Orte, waehlt kreativ und bleibt auf der Insel orientiert. |
| Sichtbare Bestandteile | Freie Slotflaechen, dezente Marker, gewaehlter Slot-Fokus, Spaeter-Slots gedimmt, Wege/Wasser/Hain als Orientierung. |
| Kamera / Perspektive | Slots liegen sichtbar im 2.5D-Terrain, nicht als UI-Karten oder Debugpunkte. |
| Licht / Farbe | Freie Slots freundlich klar; spaetere Slots ruhiger/gedimmt; gewaehlter Slot etwas heller. |
| Proportionen | Slot gross genug fuer Build Station und Hausidee, klein genug fuer ca. 12 sichtbare Slots. |
| Layer-Erwartung | Inselbasis -> Terrain -> Wege -> Slot/Marker -> Build Station -> Bauphase -> Figuren -> Reaktionen -> HUD. |
| Mobile-Lesbarkeit | Slotlabels kurz oder optional; keine Ueberfuellung; spaetere Slots erkennbar, aber nicht dominant. |
| Style-Reference-Bedarf | Marker muessen weltlich wirken, nicht Debug-Kreis, nicht Editor-Gizmo, nicht Formularchip. |
| Structure-Reference-Bedarf | 6 freie Slots, 6 spaetere Slots, Reserve, Fokuszustand, Build-Station-Ankerpunkt. |
| Erlaubte Variation | Markerform, Bodenmarkierung, kleiner Schild-/Stein-/Licht-Akzent, Fokusglow. |
| Verbotene Abweichungen | Hausplatz/Marktplatz/Werkstattplatz als feste Labels, Kategoriezwang, Raster-Editor, harte rote Sperren. |
| QA-Kriterien | Slots bleiben neutral; gewaehlter Slot fokussiert, aber Welt bleibt sichtbar; Build Station passt ohne Labelwolke. |
| Noch kein Asset | Keine Marker-Dateien, keine Layer-Dateien, keine Map-Daten, keine Persistenz, kein BuildState. |

Slot-Regel:

```text
Slot = Lage.
Kategorie = Richtung.
Build Station = lokale Bauidee.
Bauphase = spaeterer Spielmoment.
BuildState = blockiert.
```

## 10. Optional: Container / Interior Future Master Reference

| Feld | Brief |
| --- | --- |
| Zweck | Spaetere Tiefe Haus -> Raum -> Moebel -> Container vorbereiten, ohne sie jetzt zu bauen. |
| Rolle im Spiel | Kleine Objekte und Sprachanker finden spaeter natuerliche Orte statt Insel-Clutter. |
| Sichtbare Bestandteile | Raum-Andeutung, Moebelplatz, Schublade/Fach/Kiste/Tasche als spaeterer kleiner Bedeutungsraum. |
| Kamera / Perspektive | Tieferer Fokus bleibt Weltort, kein Formularwechsel. |
| Licht / Farbe | Warm, ruhig, innen etwas fokussierter; gleiche Style-Familie wie Insel. |
| Proportionen | Container klein, aber lesbar; keine TinyObject-Wolke auf der Insel. |
| Layer-Erwartung | Raum -> Moebel -> Container -> Detailobjekt -> Bubble/HUD. |
| Mobile-Lesbarkeit | Container muss als oeffenbarer Ort lesbar sein, nicht als winziger Dekorpunkt. |
| Style-Reference-Bedarf | Future Master fuer Interior-Stil und Container-Objekte nach M16-CC. |
| Structure-Reference-Bedarf | Tiefenkarte Insel -> Grundstueck -> Haus -> Raum -> Moebel -> Container. |
| Erlaubte Variation | Kiste, Tasche, Fach, Schublade, Regal, kleiner Schrank. |
| Verbotene Abweichungen | Inventar-Dump, globale Objektliste, unlesbare TinyObjects, App-Formular als Interior. |
| QA-Kriterien | Container loest Clutter und schafft Kontext; er wirkt wie Ort, nicht wie Liste. |
| Noch kein Asset | Keine Interior-Grafik, keine Container-Assets, keine Persistenz, kein Inventar. |

## 11. Optional: Water / Path / Terrain Master Reference

| Feld | Brief |
| --- | --- |
| Zweck | Die Uferhain-Identitaet ueber Wasser, Wege und Terrain stabilisieren. |
| Rolle im Spiel | Wasserarm, Kueste, Hain, Wege und Hoehen machen die Insel erinnerbar und navigierbar. |
| Sichtbare Bestandteile | Kueste, Flussarm, Wasserband, 1-2 Hauptwege, 2-3 Nebenwege, Hainzone, leichte Hoehen, Randbereiche. |
| Kamera / Perspektive | Terrain folgt der Insel-Diorama-Perspektive und stuetzt Slot-/Build-Station-Orientierung. |
| Licht / Farbe | Wasser klar und ruhig; Wege warm/erdig; Hain lebendig, aber nicht kleinteilig. |
| Proportionen | Wasser und Wege sind Landmarks, aber fressen nicht die Slot-Kapazitaet. |
| Layer-Erwartung | Wasser/Rand unter Terrain; Wege ueber Terrain; Slots und Marker darueber. |
| Mobile-Lesbarkeit | Wasser/Wege/Hain muessen ohne viele Labels Orientierung geben. |
| Style-Reference-Bedarf | Master fuer wassernahe cozy 2.5D-Insel, nicht Hafen-/Bootssystem. |
| Structure-Reference-Bedarf | Lage von Wasserarm, Hub, Hain, Wegen, Hoehen und Erweiterungszonen. |
| Erlaubte Variation | Uferkrummung, Wegschwung, Hainrand, Wasserbreite, Hoehenform. |
| Verbotene Abweichungen | Freie Terrain-Sandbox, Hafen-System, harte Pfade, Wuesten-/Stadtinsel, generische Wiese ohne Uferhain-Lesart. |
| QA-Kriterien | Uferhain bleibt als Kuestenhain-/Flussufer-Starterinsel lesbar und kann 12 Slots tragen. |
| Noch kein Asset | Keine Terrain-Layer, keine Wasserassets, keine Pfad-Assets, keine Map-Engine. |

## 12. Metadaten pro Master Reference

Jede spaetere echte Master Reference braucht mindestens:

```text
reference_family:
working_name:
purpose:
game_role:
source_tool:
prompt_or_brief:
negative_prompt:
style_reference:
structure_reference:
art_bible_rules:
source_files_or_links:
license_notes:
postprocess_tool:
layer_expectation:
mobile_readability_notes:
qa_status:
approved_for:
blocked_for:
owner:
date:
```

M16-CB setzt diese Metadaten nur als Pflichtschema. Es erzeugt keine Dateien,
auf die diese Metadaten schon angewendet werden.

## 13. Style-/Structure-Reference-Bedarf

Style References sollen spaeter klaeren:

- warme 2.5D-Cozy-Island-Diorama-Anmutung,
- Licht und Schatten,
- Farbe und Materialgefuehl,
- Figurenproportionen,
- UI/HUD-Spielstil,
- Build Station als Weltobjekt.

Structure References sollen spaeter klaeren:

- Uferhain-Inselkontur,
- Wasserarm / Kueste / Hain / Hub,
- Slotverteilung mit 6 frei und 6 spaeter,
- Build Station relativ zum Slot,
- Haus-Bauphasen relativ zum Bauplatz,
- Worker/Tali/Vori relativ zu Weltobjekten,
- Layer-Reihenfolge fuer M16-CC.

Regel:

```text
Style Reference beantwortet: Wie fuehlt es sich visuell an?
Structure Reference beantwortet: Wie ist es raeumlich aufgebaut?
Master Reference verbindet beides, bleibt aber bis Asset-Gate kein Asset.
```

## 14. QA-Kriterien

M16-CB-Reference-Briefs sind nur gruene Grundlage, wenn sie diese Risiken
aktiv verhindern:

- Master Reference wird als finales Asset gelesen.
- Codex erzeugt doch Spielbilder.
- Uferhain wird generisch statt Kuestenhain-/Flussufer-Starterinsel.
- Slots werden wieder Kategorieplaetze.
- Build Station kippt zu Menue, Shop oder Bottom Sheet.
- Figuren wirken wie fremde Sticker.
- HUD wirkt wie Web-App oder Worksheet.
- Layerbarkeit wird nicht vorbereitet.
- M16-CB widerspricht der Art Bible.
- M16-CB startet ungewollt M16-CC, High-Fidelity oder Asset-Produktion.

Prueffragen:

- Ist jede Reference als Brief und nicht als Asset gekennzeichnet?
- Ist Uferhain als Kueste + Flussarm + Hain + Lichtung lesbar?
- Sind Slots neutral und frei kombinierbar?
- Bleibt Build Station Weltobjekt statt Menue?
- Sind Worker/Tali/Vori perspektivisch an die Welt gebunden?
- Ist HUD klein, kurz und spielnah?
- Ist Layerbarkeit fuer M16-CC vorbereitet?
- Bleiben `assets/`, Code, Route, Persistenz und BuildState blockiert?

## 15. Stop-Regeln

M16-CB gibt nicht frei:

- keine Bilder,
- kein Preview-Ordner,
- keine PNG,
- keine SVG,
- keine Bilddatei,
- keine Assets,
- keine Dateien unter `assets/`,
- keine High-Fidelity-Spielbilder,
- keine App-Screens,
- keine Flutter-/Dart-Dateien,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- kein BuildState,
- keine Supabase/local DB Writes,
- keine SRS-/`word_progress`-Aenderung,
- keine automatische Wortplatzierung,
- keine Tests,
- keine Figma-/Notion-/Linear-/GitHub-Writes,
- keine externen Writes,
- keine Stashes anfassen,
- kein Commit ohne separate Freigabe.

M16-CB ist kein Asset-Gate und kein Implementierungs-Gate.

## 16. Folgepfad zu M16-CC

Empfohlener Folgepfad:

```text
M16-CB Starter Island Master Reference Set
-> M16-CC Asset Family and Export Spec
-> danach erst High-Fidelity Flow oder Flutter-Code pruefen
```

M16-CC sollte auf Basis von M16-CA und M16-CB definieren:

- Asset-Familien,
- Layer und Exportformate,
- Groessen und Skalierung,
- Benennung,
- Source-/Prompt-/Reference-Metadaten,
- QA-Status,
- was in `assets/` spaeter ueberhaupt erlaubt waere,
- welches eigene Asset-Gate vor Produktintegration noetig ist.

Auch nach M16-CC bleiben High-Fidelity Flow, Flutter-Code und App-Integration
eigene Slices mit eigenen Stop-Regeln.
