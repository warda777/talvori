# M16-CV: Talvori Camera Modes and Visit/Wander Rule

Status: `docs_gate / no code`
Template: `docs_only_slice`
Commit status: no commit in this slice

## 1. Zweck

M16-CV legt eine feste Talvori-Regel fuer mehrere Kamera- und Weltmodi fest.
Uferwald darf nicht nur fuer eine Build-/Map-Kamera, ein statisches Posterbild
oder eine einzelne lokale Preview optimiert werden. Jede kuenftige World-,
Map-, Build-, UI- oder Asset-Entscheidung muss pruefen, welcher Kameramodus
betroffen ist und welche spaeteren Besuchs- und Wanderfaehigkeiten dadurch
geschuetzt oder blockiert werden.

Der Slice erzeugt keinen Code, keine Bilder, keine Assets, keine App-
Integration, keine Route und keine Persistenz.

## 2. Eingangsquellen

M16-CV baut auf diesen verbindlichen Quellen auf:

- `336-documentation-map-and-slice-reading-rules.md`
- `381-uferwald-anchor-zone-layer-overlay-plan.md`
- `382-uferwald-mobile-map-camera-research-and-decision.md`
- Uferwald bleibt nach M16-CQ/M16-CR eine Struktur-/Postprocess- und
  Overlay-Planungsreferenz, kein finaler Asset- oder Runtime-Zustand.

## 3. Harte Regel

Uferwald Map-/Build-Modus ist nicht automatisch Wander-/Besucher-Modus.

Jede World-/Map-/Build-/UI-/Asset-Entscheidung muss ab jetzt explizit pruefen:

- Welche Kamera-Modi werden durch diese Entscheidung betroffen?
- Wird eine spaetere Besuchs- oder Wanderansicht erschwert?
- Wird die Welt zu stark als statisches Posterbild oder einzelnes Bitmap
  gedacht?
- Bleiben Nutzerinseln individuell begehbar, betrachtbar und besuchbar?
- Kann ein Objekt spaeter fokussiert werden, ohne die Insel-/Besucherlogik zu
  brechen?

Keine Architektur darf nur auf ein statisches Posterbild oder eine einzige
Map-Kamera ausgelegt werden.

## 4. Die vier Pflichtmodi

| Modus | Zweck | Kamera-Gefuehl | Was schuetzen |
| --- | --- | --- | --- |
| Build/Map Camera | Bauen, freie Ortswahl, lokale Auswahlraeume und Kapazitaet pruefen | Fullscreen/cover, frei schieb- und zoombar, keine sichtbare Bildkante | Baukapazitaet, Review-Zonen, Build Station, HUD-Kompaktheit |
| Overview Camera | Insel als Ganzes verstehen, Reset, Review, Orientierung | bewusst herausgezogen, klar als Ueberblick markiert | Insel-Identitaet, Reserveflaechen, keine Poster-Default-Ansicht |
| Visit/Wander Camera | fremde oder eigene Insel besuchen, durch den Ort wandern, soziale Showcase-Momente | naeher, ruhiger, objekt- und wegbezogen, nicht primaer Bau-Overlay | Begehbarkeit, Wege, Raumsinn, individuelle Nutzerinseln, spaetere Cloud-/Besucheransichten |
| Object Focus Camera | Haus, Build Station, Worker, Raum, Moebel oder Container fokussieren | fokussierter Ausschnitt mit Umgebungskontext | Objektinteraktion, Tiefe, Bubbles/HUD, Rueckkehr zur Welt |

## 5. Build/Map Camera

Die Build/Map Camera ist der aktuelle Uferwald-Preview-Fokus:

- Standard ist fullscreen/cover, nicht ein gerahmtes Bild.
- Pinch/Pan sind natuerlich, aber Bounds schuetzen die Welt.
- Review-Zonen sind antippbare Auswahlraeume, keine festen Slots.
- Sechs Start-Baukapazitaeten sind Kapazitaet, keine festen Orte.
- Kategorien bleiben frei waehlbar; Terrain darf Varianten nahelegen, aber
  nicht hart blockieren.
- HUD bleibt kompakt und darf zentrale Bauzonen nicht dauerhaft verdecken.

Diese Kamera darf nicht mit Visit/Wander verwechselt werden. Sie dient
Planung, Bauen und Orientierung, nicht dem spaeteren sozialen Besuchserlebnis.

## 6. Overview Camera

Die Overview Camera ist ein bewusster anderer Zustand:

- Sie darf die ganze Insel zeigen.
- Sie ist fuer Orientierung, Review, Reset, Debug oder Scenic-/Planungsblick.
- Sie darf nicht der normale Build-/Map-Default sein.
- Sie darf nicht dazu fuehren, dass die Insel wie ein einzelnes Posterbild im
  UI liegt.

Wenn ein Slice eine "komplette Inselansicht" fordert, muss er sagen, ob es
Overview ist oder faelschlich Build/Map ersetzt.

## 7. Visit/Wander Camera

Visit/Wander ist der spaetere Modus fuer begehbare und besuchbare Inseln:

- Besucher sollen eine Nutzerinsel als individuellen Ort erleben koennen.
- Wege, Wasser, Hain, Bauzonen, Erweiterungen und Objektnaehe muessen schon in
  fruehen Strukturentscheidungen mitgedacht werden.
- Cloud-/Besucheransichten duerfen nicht erst nachtraeglich an eine reine
  Build-Map angeklebt werden.
- Eine Insel, die nur als flaches Poster funktioniert, ist fuer Visit/Wander
  nicht ausreichend.

Visit/Wander kann spaeter indirekte Figurenbewegung, Hotspots, sanfte Kamera-
Schwenks, Companion-Kommentare oder Showcase-Momente enthalten. Diese
Funktionen brauchen eigene Gates; M16-CV gibt sie nicht frei.

## 8. Object Focus Camera

Object Focus ist der Modus fuer einzelne Weltobjekte:

- Build Station am Slot,
- Haus und Bauphasen,
- Worker/Tali/Vori-Momente,
- Raum-, Moebel- und Container-Tiefe,
- kurze kontextuelle Bubbles.

Object Focus zoomt in den Ort hinein, ohne die Welt zu verlieren. Er ist kein
Bottom Sheet, keine Route und kein Formularersatz. Jeder Object-Focus-Slice
muss einen Rueckweg zur Build/Map oder Visit/Wander Camera benennen.

## 9. Auswirkungen auf Assets und Layer

Asset- und Layerentscheidungen muessen mehrere Kamera-Modi tragen:

- `island_base` darf nicht nur als posterartige Gesamtgrafik gedacht werden.
- `water_paths`, `terrain_layers`, `slot_markers`, `build_stations`,
  `building_phases`, `workers_companions` und `ui_hud_bubbles` muessen
  ueberlagerbar bleiben.
- Objektgroessen muessen in Build/Map, Object Focus und spaeterem Visit/Wander
  plausibel bleiben.
- Raender, Wasser, Wege, Hain und Reservebereiche muessen Edge-Masking,
  Overview und Besuchslesbarkeit zugleich unterstuetzen.
- Transparente Layer, Engine-ready Exporte oder Runtime-Platzierung bleiben
  weiterhin durch eigene Asset-/Layer-Gates blockiert.

## 10. Auswirkungen auf UI und HUD

UI-Entscheidungen muessen pro Modus begruendet werden:

- Build/Map: kleine Kapazitaetsanzeige, Overlay/Reset sparsam, keine
  dominant verdeckenden Panels.
- Overview: Orientierung darf sichtbarer sein, bleibt aber als eigener Modus
  gekennzeichnet.
- Visit/Wander: HUD muss sehr ruhig sein, damit die Insel als Ort wirkt.
- Object Focus: kurze Bubble oder Objekt-Hinweis, kein Tutorial-Panel und
  keine Textwand.

Ein HUD, das im Build-Modus akzeptabel ist, ist nicht automatisch fuer
Visit/Wander oder Object Focus geeignet.

## 11. Entscheidung fuer Uferwald

| Frage | Entscheidung |
| --- | --- |
| Ist Uferwald Build/Map automatisch Wander-/Besucher-Modus? | NEIN |
| Muss Uferwald fullscreen/cover im Build/Map-Modus bleiben? | JA |
| Darf Overview die ganze Insel zeigen? | JA, aber nur bewusst als Overview/Review |
| Muessen spaetere Visit-/Wanderansichten mitgedacht werden? | JA |
| Duerfen Nutzerinseln individuell begehbar/besuchbar bleiben? | JA |
| Darf Architektur auf ein statisches Posterbild optimiert werden? | NEIN |
| Gibt M16-CV Code, Assets oder Cloud frei? | NEIN |

## 12. Prueffragen fuer kuenftige Slices

Jeder relevante Slice muss beantworten:

1. Welcher Kamera-Modus ist primaer?
2. Welche anderen Modi werden durch die Entscheidung beruehrt?
3. Bleibt Build/Map frei beweglich und nicht posterartig?
4. Bleibt Overview ein eigener Zustand?
5. Wird Visit/Wander spaeter ermoeglicht statt blockiert?
6. Kann Object Focus spaeter ohne neue Route oder Formularlogik entstehen?
7. Sind HUD, Layer, Groessen und Anchors pro Modus plausibel?
8. Bleiben `assets/`, Engine-ready, Persistenz, Route und BuildState
   blockiert, falls kein eigener Gate sie oeffnet?

Wenn diese Fragen nicht beantwortet sind, ist der Slice fuer komplexe
World-/Map-/Build-/UI-/Asset-Entscheidungen nicht commitfaehig.

## 13. Folgepfad

Naechster sinnvoller Implementierungsfolge-Slice:

```text
M16-CW Uferwald Camera Modes Preview Toggle
```

Dieser Folge-Slice waere nur sinnvoll, wenn er weiterhin isoliert bleibt und
keine App-Integration, Route, Persistenz, BuildState, Assets oder neuen Bilder
erzeugt. Er koennte Build/Map, Overview und einen sehr einfachen Visit/Wander-
Review-Zustand in derselben Preview unterscheidbar machen.

## 14. Stop-Regeln

M16-CV gibt nicht frei:

- keinen Code,
- keine neuen Bilder,
- keine Assets,
- keine Dateien unter `assets/`,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- keinen BuildState,
- keine Cloud-/Besucheransicht,
- keine Runtime-Placement-Daten,
- keine Supabase/local DB Writes,
- keine SRS-/`word_progress`-Aenderung,
- keinen Commit.
