# M16-BZ: AI Art Production Pipeline and Style Consistency Gate

Stand: 2026-06-21

Status: `Docs-/Pipeline-Gate-Slice / keine Implementierung`

Unity Platform Supersession 2026-06-21:

Ab `442-talvori-unity-modular-district-platform-decision.md` und
`443-p02-vertical-slice-and-online-foundation-roadmap.md` gilt fuer Firenze
und neue World-Produktion: coherent environment kit first. KI- und
Generator-Tools dienen kontrollierten Luecken, Varianten, Konzepten oder
Talvori-spezifischen Sonderobjekten. Lizenz, Provenance, kommerzielle
Nutzbarkeit, Importstandard und QA sind Pflicht vor jedem Asset-Gate. Codex
bleibt Technical Environment Assembler und baut keine finale Stadt-Art aus
Primitiven.

## 1. Zweck

M16-BZ legt fest, wie Talvori kuenftig hochwertige Spielgrafiken erzeugen kann,
obwohl noch kein echter Artist dauerhaft verfuegbar ist.

Ziel ist keine freie Bildproduktion und keine Asset-Freigabe. Ziel ist eine
kontrollierte KI-gestuetzte Art-Pipeline, die professioneller arbeitet als
Einzelprompts und Style-Brueche frueh verhindert.

M16-BZ gibt keinen Code, keine Flutter-/Dart-/Unity-Dateien, keine App-Integration,
keine Route, keine Navigation, keine Persistenz, keine Assets unter `assets/`,
keine Tests, keine Figma-/Notion-/Linear-/GitHub-Writes, keinen Plugin-Write,
keinen BuildState und keine Produktivmechanik frei.

## 2. Klare Rollenverteilung

| Rolle | Aufgabe | Grenze |
| --- | --- | --- |
| ChatGPT | Art Direction, Referenzbilder, Prompts, Style Bible, Moodboards und QA-Regeln vorbereiten. | Nicht alleinige Asset-Wahrheit; keine ungeprueften finalen Spielassets. |
| Codex | Dokumentation, Pipeline-Regeln, Dateistruktur, Unity-Import-/Prefab-/QA-Regeln, Exportregeln, Integrationsgrenzen und Checks pflegen. | Codex soll keine hochwertigen Spielbilder nachzeichnen, keine finale Stadt aus Primitiven bauen und nicht als Bildgenerator auftreten. |
| KI-Bildtool | Bilder mit Style References, Structure References, ggf. LoRA oder ControlNet generieren. | Keine freien Einzelprompts ohne Referenz; keine finale Asset-Freigabe ohne QA. |
| Figma / Photoshop / Photopea / Aseprite | Nachbearbeitung, Zuschnitt, Layering, Layout, Export und Konsistenzkorrektur. | Keine externen Writes oder Designfile-Aenderungen ohne Freigabe. |
| Spaeterer Artist | Optional Finalisierung, Paintover, Konsistenzpruefung, Charakter-/Asset-System und Produktionsqualitaet. | Kommt, sobald Budget/Bedarf da ist; ersetzt nicht die jetzige Gate-Struktur. |

Kurzregel:

```text
ChatGPT richtet aus.
Codex dokumentiert und prueft.
KI-Bildtool generiert.
Design-/Pixeltools bereinigen.
Artist finalisiert spaeter optional.
```

## 3. Grundentscheidung

Talvori nutzt vorerst:

- kontrollierte KI-Pipeline,
- Style References,
- Structure References,
- ggf. LoRA,
- ggf. ControlNet,
- manuelle Nachbearbeitung,
- strenge Asset-QA,
- dokumentierte Prompts, Quellen und Referenzen.

Talvori nutzt nicht:

- freie Einzelprompts ohne Referenz,
- Codex als Bildgenerator,
- zufaellige Stilwechsel,
- finale Assets ohne Pruefung,
- Spielgrafiken ohne Lizenz-/Source-/Prompt-/Reference-Metadaten,
- Bilder unter `assets/` ohne eigenes Asset-Gate.

## 4. Referenzbild-Regel

Das erste starke Referenzbild aus M16-BY ist eine Art-Direction-Reference.

Regeln:

- Es ist Dokumentationsmaterial.
- Es ist kein App-Screen.
- Es ist kein finales Asset.
- Es darf nicht nach `assets/`.
- Es darf nicht von Codex vereinfacht nachgezeichnet werden.
- Es darf nicht als finale UI oder Spielgrafik missverstanden werden.
- Es muss als visuelle Richtung fuer spaetere High-Fidelity-Konzepte gelesen
  werden.

Die inhaltliche M16-BY-Richtung bleibt:

```text
Cozy Island Diorama Builder
-> Build Station am Slot
-> Worker / Tali / Vori als lebendige Begleitung
-> Insel -> Slot -> Station -> Worker -> Tiefe
```

## 5. Style Bible Anforderungen

Eine spaetere Talvori Art Bible muss mindestens definieren:

- Kamera und Perspektive,
- Licht,
- Farbpalette,
- Formen,
- Detailgrad,
- Linien / Edges,
- Materialgefuehl,
- UI-Stil,
- Figurenstil,
- Gebaeudeproportionen,
- Slot-/Tile-Groessen,
- Exportformate,
- Benennung,
- QA-Regeln.

Sie muss so konkret sein, dass mehrere Generierungen, Nachbearbeitungen und
spaetere Flutter-Kompositionen erkennbar zur selben Welt gehoeren.

## 6. Master-Referenzen

Erste benoetigte Master-Referenzen:

| Master-Referenz | Zweck |
| --- | --- |
| Starter-Insel Master | Fuehrende Perspektive, Inselproportion, Biome, Slot-Lesbarkeit und Wasser/Hain/Hub-Stimmung. |
| Build Station Master | Fuehrende BuildChoice-Lesart als Weltobjekt am Slot. |
| Haus-Bauphasen Master | Foundation, Wand-Ghost, Fenster/Tuer, Dach und spaetere Tiefe konsistent halten. |
| Worker/Tali/Vori Master | Figurproportionen, Gesicht, Kleidung, Haltung und Wiedererkennbarkeit. |
| UI/HUD Master | Bubbles, Safe Actions, kleine Toolbelts, Rahmen, Schatten und Lesbarkeit. |
| Container/Interior Master | Haus -> Raum -> Moebel -> Container als spaetere Tiefe vorbereiten. |

Keines dieser Masters ist durch M16-BZ bereits ein Asset. Es sind geplante
Produktionsreferenzen fuer spaetere Gates.

## 7. Asset-Familien

Spaetere Asset-Familien:

- Island base,
- terrain layers,
- slots / markers,
- paths / water / trees,
- build stations,
- buildings,
- building phases,
- workers / companions,
- props,
- interiors,
- furniture,
- containers,
- UI / HUD elements.

Regeln:

- Asset-Familien brauchen gemeinsame Perspektive, Lichtlogik und
  Exportregeln.
- Kleine Props und Container duerfen die Insel nicht mit TinyObjects fuellen.
- UI/HUD-Elemente gehoeren zum Stil, aber duerfen Spielraum nicht dominieren.
- Jede Familie braucht spaeter eigene Benennung, Groessen, Layer und QA.

## 8. KI-Tool-Strategie

| Option | Sinnvoll fuer | Grenze |
| --- | --- | --- |
| Adobe Firefly mit Style/Structure Reference | Zugaengliche fruehe Konsistenz, schnelle Varianten, weniger technischer Setup. | Nicht automatisch engine-ready; Lizenz-/Exportregeln trotzdem pruefen. |
| Stable Diffusion / ComfyUI mit ControlNet | Staerkere Strukturkontrolle, wiederholbare Kompositionen, lokale Pipeline moeglich. | Setup- und Pflegeaufwand; braucht klare Nodes, Seeds, References und QA. |
| LoRA | Wiederkehrender Stil, Figur- oder Asset-Konsistenz. | Nur sinnvoll nach sauberem Style-Set; kein Shortcut fuer schlechte Art Direction. |
| Bildgenerierung durch ChatGPT | Fruehe Moodboards, Art-Direction-References, Konzeptbilder. | Nicht als alleinige Produktionspipeline fuer finale Assets. |

Entscheidung:

```text
Talvori beginnt mit kontrollierter Reference-basierter KI-Art-Pipeline.
Freie Einzelprompts sind kein Produktionsmodell.
```

## 9. Kontrollpunkte gegen Stilbruch

Jede Art-Produktion muss pruefen:

- gleiche Perspektive,
- gleiche Lichtquelle,
- gleiche Farbfamilie,
- gleiche Rundheit / Formensprache,
- gleiche Detaildichte,
- gleiche UI-Ecken / Rahmen / Schatten,
- gleiche Figurenproportionen,
- gleiche Exportgroesse / Skalierung,
- gleiche Benennung,
- QA gegen Fremdstil.

Stilbruch bedeutet:

- Figur sieht aus einer anderen App,
- Inselperspektive kippt,
- Gebaeude wirkt realistischer als Umgebung,
- UI sieht wie Web-App statt Spiel-HUD aus,
- Asset ist malerisch, aber nicht layerbar,
- Details sind huebsch, aber unklar bedienbar.

## 10. Engine-ready Export-Regeln

Engine-ready bedeutet noch nicht produktiv freigegeben. Es bedeutet nur:
technisch geeignet als Kandidat fuer spaetere Integration.

Regeln:

- PNG/WebP mit Transparenz bevorzugen.
- Layer getrennt exportieren.
- Keine riesigen finalen Gesamtbilder als spielbare Welt.
- Quellen, Prompts und Referenzen dokumentieren.
- Keine Assets ohne Lizenz-/Source-/Prompt-/Reference-Metadaten.
- Einheitliche Groessen, Namen und Varianten nutzen.
- UI, Figuren, Terrain, Slots und Gebaeude getrennt halten.
- Asset-ready erst nach eigenem Asset-Gate.

Beispielhafte Metadaten pro Kandidat:

```text
asset_family:
working_name:
source_tool:
prompt:
style_reference:
structure_reference:
seed_or_generation_id:
postprocess_tool:
license_notes:
qa_status:
```

## 11. Flutter-Relevanz

Flutter kann spaeter Assets darstellen ueber:

- `Stack` / `CustomPaint` / `Transform`,
- `InteractiveViewer` / Kamera,
- sprite-/layer-artige Komposition,
- `AnimationController`,
- Rive / Spine / Lottie spaeter,
- Shader / Glow / Partikel sparsam.

Aber:

Flutter loest nicht die Art-Konsistenz. Ein sauberer Renderer kann inkonsistente
Bilder nur inkonsistent darstellen.

Reihenfolge:

```text
Art Direction
-> Style Bible
-> Master References
-> Asset-Family-Spec
-> Engine-ready Candidates
-> Flutter-Umsetzung
```

## 12. Risiken

| Risiko | Warum gefaehrlich | Gegenregel |
| --- | --- | --- |
| Stil driftet | Talvori wirkt wie Collage aus mehreren Apps. | Style Bible, Master References und QA gegen Fremdstil. |
| Perspektive inkonsistent | Assets passen nicht auf Insel/Slots. | Structure References und feste Kamera. |
| Asset nicht layerbar | Flutter kann es nicht sauber animieren oder zusammensetzen. | Layer-Export und keine riesigen Gesamtbilder. |
| KI erzeugt unklare Details | Huebsch, aber nicht lesbar oder bedienbar. | Detailgrad begrenzen, nachbearbeiten, mobile QA. |
| Figuren aendern sich | Tali/Vori/Worker verlieren Wiedererkennbarkeit. | Character Master und ggf. LoRA erst nach Style-Set. |
| UI wirkt wie Bild statt interaktiv | Spieler versteht Tap-Ziele nicht. | HUD Master, klare States, getrennte UI-Layer. |
| Lizenz-/Nutzungsrechte unklar | Spaetere Produktnutzung riskant. | Tool-, Source- und License-Metadaten pflegen. |
| Zu malerisch, nicht engine-ready | Schoenes Concept, aber kein Spielasset. | Engine-ready Export-Regeln und Asset-Gate. |

## 13. Empfohlener Naechster Schritt

Empfohlener Folgepfad:

```text
M16-CA Talvori Art Bible v1
-> M16-CB Starter Island Master Reference Set
-> M16-CC Asset Family and Export Spec
```

Warum:

- M16-BY hat die konzeptionelle Richtung gesetzt.
- M16-BZ definiert die Produktionspipeline.
- M16-CA muss daraus eine konkrete Art Bible machen.
- Erst danach koennen Starter-Insel-Masters und Asset-Familien sinnvoll
  entstehen.

Nicht empfohlen als naechster Schritt:

- direkt Flutter-Code,
- direkt finale Assets,
- weitere freie Direction Boards,
- Codex-Nachzeichnen der Referenz,
- Asset-Export nach `assets/`.

M16-BZ ersetzt die Art Bible nicht. Es verhindert nur, dass visuelle Qualitaet
aus Codex-Nachbau, freien Einzelprompts oder einem nicht akzeptierten
Zwischenboard abgeleitet wird.

## 14. Pipeline-Visual

Repo-native Visuals:

- [ai_art_pipeline_overview.svg](previews/m16_bz_ai_art_pipeline_and_style_consistency/ai_art_pipeline_overview.svg)
- [ai_art_pipeline_overview.png](previews/m16_bz_ai_art_pipeline_and_style_consistency/ai_art_pipeline_overview.png)

Das Diagramm zeigt nur die Produktionspipeline:

```text
Reference -> Style Bible -> Tool Pipeline -> Postprocess -> QA -> Engine-ready candidate
```

Es zeigt keine neuen Spielbilder, keine App-Screens und keine Assets.

## 15. Stop-Regeln

- keine Flutter-/Dart-Dateien,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- keine Supabase/local DB Writes,
- keine SRS-/`word_progress`-Aenderung,
- keine automatische Wortplatzierung,
- keine Assets unter `assets/`,
- kein BuildState,
- keine Tests,
- keine Figma-Writes,
- keine Notion-Writes,
- keine Linear-Writes,
- keine GitHub-Writes,
- kein Plugin-Write,
- keine neuen Spielbilder,
- kein Commit.
