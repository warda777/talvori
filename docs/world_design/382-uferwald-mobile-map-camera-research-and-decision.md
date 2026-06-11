# M16-CT: Uferwald Mobile Map Camera Research and Decision

Status: `research_decision / documentation only`
Template: `review_slice`
Commit status: no commit in this slice

## 1. Zweck

M16-CT entscheidet, wie die lokale Uferwald Map Interaction Preview auf Mobile
wirken soll: wie eine Spielkarte und nicht wie ein statisches Bild in einem
Viewer.

Der Slice erzeugt keinen Code, keine Bilder, keine Assets, keine App-
Integration und keine Route. Er leitet aus Mobile-Game-Referenzen konkrete
Kamera-, HUD-, Rand- und Folge-Code-Regeln fuer Uferwald ab.

## 2. Research-Grundlage

Geprueft wurden:

- `336-documentation-map-and-slice-reading-rules.md`
- `379-uferwald-layer-candidate-intake-and-qa.md`
- `380-uferwald-layer-candidate-review-and-postprocess-decision.md`
- `381-uferwald-anchor-zone-layer-overlay-plan.md`
- App-Store-/offizielle Seiten und aktuelle Store-Screenshots/Trailer-Kontext
  zu erfolgreichen Mobile Games.

Quellen:

- Clash of Clans, App Store:
  <https://apps.apple.com/us/app/clash-of-clans/id529479190>
- Clash of Clans, Supercell:
  <https://supercell.com/en/games/clashofclans/>
- Hay Day, App Store:
  <https://apps.apple.com/us/app/hay-day/id506627515>
- Hay Day, Supercell:
  <https://supercell.com/en/games/hayday/>
- Township, App Store:
  <https://apps.apple.com/us/app/township/id638689075>
- Gardenscapes, App Store:
  <https://apps.apple.com/us/app/gardenscapes/id1105855019>
- Pokemon GO, App Store:
  <https://apps.apple.com/us/app/pok%C3%A9mon-go/id1094591345>
- Animal Crossing: Pocket Camp Complete, App Store:
  <https://apps.apple.com/us/app/animal-crossing-pocket-camp-c/id6547834967>

Die Analyse kopiert keine Mechanik blind. Sie uebersetzt Muster in Talvori-
Regeln.

## 3. Vergleich

| Referenz | Was funktioniert | Risiko fuer Talvori | Uebertragung |
| --- | --- | --- | --- |
| Clash of Clans | Village ist die Spielflaeche. Die Welt liegt unter dem HUD, Gebaeude sind tappbar, der Spieler baut und verteidigt seinen Ort. | Zu taktisch, zu grid-/defense-lastig. | Uferwald darf nicht in einem Card-/Image-Frame liegen. Kamera muss eine Welt zeigen, nicht eine Grafikdatei. |
| Hay Day | Farm wirkt wie ein Ort mit freier Gestaltung, Deko und ruhigem Alltag. App-Store-Updates nennen Scenic Mode und Edit-Mode-UX. | Zu landwirtschaftlich und zu produktionstimer-lastig. | Uferwald braucht ruhige Top-HUDs, freie Gestaltung und spaeter einen Scenic-/Overview-Modus statt dauerhaftem Vollbild-Fit. |
| Township | Stadt/Farm ist eine wachsende, pannbare Welt mit vielen Objekten und HUD nur am Rand. | Zu viel Produktions-/City-Builder-Dichte. | Talvori kann expansionartige Randbereiche nutzen, aber muss Dichte und UI staerker reduzieren. |
| Gardenscapes/Homescapes | Story-/Renovierungsfokus: Kamera zeigt relevante Bereiche, Aufgaben passieren in der Szene, nicht in Formularen. | Zu stark task-/puzzle-getrieben, weniger frei begehbare Karte. | Build-Momente duerfen Kamera-Fokus bekommen; normale Map bleibt aber frei erkundbar. |
| Pokemon GO | Karte ist Fullscreen-Welt, nicht Screenshot. HUD ist daruebergelegt; das Spielfeld endet nicht als sichtbare Bildkante. | Location-based passt nicht zu Talvori; keine GPS-Logik uebernehmen. | Talvori braucht den Grundsatz: Karte ist eine lebendige Flaeche unter der UI, mit harten Bounds unsichtbar kaschiert. |
| Animal Crossing: Pocket Camp | Kleiner, gemuetlicher Raum wird durch Deko, Figuren und Objektinteraktion lebendig. | Zu stark statischer Campsite-Raum, wenn Kamera kaum frei ist. | Uferwald soll cozy und objektbezogen wirken; Figuren/Worker spaeter als Lebendigkeit, nicht als Tutorial-Panel. |

## 4. Gemeinsame Muster

### Fullscreen statt contained image

Erfolgreiche Builder zeigen die Welt als die Hauptflaeche. Selbst wenn intern
ein Bild oder Tilemap genutzt wird, wird es nicht als gerahmte Grafik gezeigt.
Der Spieler sieht keine quadratische Bildkante, keine weisse Board-Flaeche und
keinen Dokumentationsrahmen.

Talvori-Regel:

- Uferwald wird in der Interaktions-Preview fullscreen/cover dargestellt.
- Kein sichtbarer Bildrahmen.
- Kein statischer Screenshot-Look.
- Die Karte liegt unter einem kleinen HUD.

### Vollstaendige Karte nur fuer Overview

Viele Spiele erlauben einen Ueberblick, aber die Standardansicht ist nicht
zwingend die komplett sichtbare Welt. Der normale Spielmodus zeigt einen
interessanten Ausschnitt mit erkundbaren Raendern. Vollstaendig sichtbar ist
die Welt eher fuer:

- Insel-/Ort-Auswahl,
- Scenic Mode / Foto-Modus,
- Layout-/Edit-Uebersicht,
- Debug-/Review-Modus.

Talvori-Regel:

- Der normale Uferwald-Interaktionsmodus startet mit einer Cover-Kamera.
- Die komplette Insel darf nur in einem bewussten Ueberblicksmodus oder per
  Reset/Overview-Zustand sichtbar werden.
- Der Build-/Erkundungsmodus darf beim Zoom-out nicht so weit herausgehen, dass
  die Karte als quadratisches Bild auf Hintergrund liegt.

### Ränder werden kaschiert

Spielkarten wirken nicht wie Einzelbilder, weil ihre Raender unsichtbar gemacht
werden:

- Kamera-Bounds verhindern leere Flaechen.
- Wasser, Nebel, Wald, Schatten, Wolken, Berge oder UI-Gradienten kaschieren
  harte Aussenkanten.
- Randbereiche bleiben Teil der Welt und nicht Teil eines Frames.

Talvori-Regel:

- Uferwald braucht im Preview-Code einen Edge-Mask-/Ocean-Background-Layer.
- Die Bildkante darf nicht sichtbar als Rechteck erscheinen.
- Spaeter soll ein echter `water_paths`/Ozean-/Atmosphaeren-Layer entstehen.

### Min-/Max-Zoom ist spielmodusabhaengig

Ein guter Mobile-Zoom fuehlt frei an, aber die Kamera schuetzt die Welt:

- `minScale` zeigt keinen leeren Rand.
- `maxScale` geht nur so weit hinein, dass Pixel/Details nicht zerfallen.
- Zu starkes Herauszoomen federt oder animiert in eine erlaubte Ansicht zurueck.
- Pan-Bounds verhindern, dass die Welt aus dem Bildschirm verschwindet.

Talvori-Regel:

- `minScale` darf nicht absolut `0.20` bleiben.
- `minScale` muss aus Viewport und Bildgroesse als Cover-Minimum berechnet
  werden.
- `maxScale` soll relativ zu diesem Cover-Minimum gesetzt werden.
- Nach Interaktionsende wird unterhalb des erlaubten Minimums sanft zurueck
  animiert.
- Pan wird so begrenzt, dass mindestens die Spielflaeche den Viewport deckt.

### HUD bleibt Rand, nicht Karteninhalt

Builder-HUDs liegen am Rand und blockieren nicht den eigentlichen Ort:

- Ressourcen/Status oben oder seitlich.
- Aktionen in kleinen Buttons/Chips.
- Hinweise zeitlich begrenzt oder unten als kompakte Bubble.
- Kein grosses Panel ueber dem Objekt, das man pruefen will.

Talvori-Regel:

- Uferwald-HUD bleibt kompakt und SafeArea-aware.
- Overlay/Reset duerfen die Inselmitte nicht bedecken.
- Nach kurzer Zeit oder bei Interaktion darf das HUD weiter abdunkeln oder
  einklappen.

### Die Welt ist nicht nur Pixel

Spiele vermeiden den Einzelbild-Eindruck durch:

- tappbare Objekte,
- kleine Animationen,
- Figuren,
- Partikel/Wasser/Licht,
- Parallaxen,
- Fokuswechsel auf Interaktion,
- klare Reaktion beim Tap.

Talvori-Regel:

- Bereits die Preview braucht lokale Tap-Reaktionen auf Review-Zonen.
- Spaeter braucht Uferwald mindestens animiertes Wasser/Atmosphaere oder
  Layer-Parallaxen, bevor es als hochwertige Map gelten kann.
- Ein einzelnes 1254x1254-RGB-Bitmap bleibt nur Strukturreferenz, nicht
  finaler Kartenuntergrund.

## 5. Entscheidung fuer Uferwald

| Frage | Entscheidung |
| --- | --- |
| Soll Uferwald fullscreen/cover dargestellt werden? | JA. Standardansicht ist fullscreen/cover, nicht contained image. |
| Soll die Insel freigestellt werden? | Langfristig JA, aber erst nach Asset-/Layer-Gate. Kurzfristig wird die Bildkante durch Cover-Kamera, Clip und Edge Mask kaschiert. |
| Brauchen wir animierten Ozean/Hintergrund? | JA fuer das Zielbild. Kurzfristig nur Gradient/Mask; spaeter eigener Wasser-/Atmosphaeren-Layer. |
| Darf die komplette Insel sichtbar sein? | Nur in Overview/Reset/Review, nicht als normaler Spielzustand. |
| Wie sollen Pan/Zoom funktionieren? | Native Pinch/Pan, cover-basierter Mindestzoom, sanfte Rueckkehr, Pan-Clamp. |
| Wie werden Review-Zonen genutzt? | Tappbare lokale Auswahlraeume, keine festen Slots, keine Runtime-Platzierung. |
| Ist der aktuelle Uferwald-Candidate produktionsreif? | NEIN. Er bleibt Struktur-/Postprocess-Referenz. |

## 6. Konkrete Kamera-Regel

Fuer die naechste Preview-Iteration gilt:

```text
coverScale = max(viewportWidth / mapWidth, viewportHeight / mapHeight)
minScale = coverScale * 1.02
initialScale = coverScale * 1.12
overviewScale = min(viewportWidth / mapWidth, viewportHeight / mapHeight) * 0.94
maxScale = coverScale * 3.0
```

Regeln:

- Normalmodus nutzt `initialScale`, nicht `overviewScale`.
- Pinch-out darf sich kurz frei anfuehlen, endet aber nie dauerhaft unter
  `minScale`.
- Reset setzt nicht auf komplett sichtbare Insel, sondern auf `initialScale`.
- Ein separater Overview-Button kann spaeter bewusst `overviewScale` nutzen.
- Pan wird so geklemmt, dass keine leere Flaeche sichtbar bleibt.
- Wenn die Karte kleiner als der Viewport wuerde, wird sie mittig und gedeckt
  zurueckanimiert.

## 7. Rand-/Ozean-Regel

Kurzfristige Preview:

- Hintergrund ist dunkler/lebendiger Ozean-Gradient statt leerer Flaeche.
- Das Bild wird geclippt und mit weichem Edge-Mask/Shadow versehen.
- Die Kamera startet so nah, dass die harte quadratische Kante nicht sichtbar
  ist.

Spaeter:

- `water_paths` und Ocean/Atmosphere als eigener Layer.
- Subtile Bewegung: Wasser-Glanz, Wolkenschatten, Licht-Flicker oder Partikel.
- Kein neues Bild ohne Asset-/Layer-Gate.

## 8. HUD-Regel

Der Mobile-HUD-Standard fuer die Preview:

- oben links nur `6 frei` als kleiner Chip,
- oben rechts Overlay/Reset als Icon-Controls,
- unten nur kurze Bubble, wenn eine Zone gewaehlt wurde,
- bei Pan/Zoom koennen Hinweise optional ausblenden,
- keine grossen Textkarten ueber der Karte,
- keine Dokumentationssprache im Hauptspielraum.

## 9. Tap-Regel fuer Bauzonen

Review-Zonen duerfen in der Preview antippbar sein, aber nur lokal:

- Tap waehlt eine Review-Zone.
- Zone bekommt Highlight/Glow.
- Text: `Auswahlraum, kein fester Slot.`
- Keine Speicherung.
- Kein BuildState.
- Keine Kategoriebindung.
- Keine echte Bebauung.

## 10. Naechster Code-Fix

Empfohlener naechster Slice:

```text
M16-CU Uferwald Fullscreen Cover Camera Preview Fix
```

Auftrag:

- bestehende Preview-Datei weiterverwenden,
- `InteractiveViewer`-Kamera auf dynamische Cover-Skalen umstellen,
- initiale Kamera auf `initialScale` setzen,
- `minScale` als `coverScale * 1.02` durchsetzen,
- `maxScale` als `coverScale * 3.0` setzen,
- Pan-Clamp oder sanfte Rueckkehr nach `onInteractionEnd` einbauen,
- harte Bildkante per Clip/Edge-Mask/Ocean-Gradient kaschieren,
- HUD weiter verdichten und Karte dominieren lassen,
- keine Assets, keine App-Integration, keine Route, keine Persistenz.

Nicht zuerst tun:

- keine neue Bildvariante,
- kein `assets/`-Import,
- keine produktive Map Engine,
- kein Build-/Speicherfluss,
- keine finale Layer-Separation.

## 11. Akzeptanzkriterien fuer M16-CU

- Uferwald startet auf iPhone als fullscreen/cover Spielkarte.
- Keine sichtbare quadratische Bildkante im normalen Zustand.
- Pinch-in und Pinch-out fuehlen natuerlich.
- Zurueckzoomen ohne Reset ist moeglich, aber dauerhaft nicht unter
  Cover-Minimum.
- Pan laesst die Karte nicht aus dem Viewport verschwinden.
- Reset setzt auf spielbare Cover-Ansicht.
- Optionaler Overview ist klar als anderer Modus erkennbar.
- HUD verdeckt keine zentrale Bauzone dauerhaft.
- Review-Zonen bleiben antippbar.
- Status bleibt Preview: kein Asset, kein Code-Integration, kein BuildState,
  keine Persistenz.

## 12. Stop-Regeln

M16-CT gibt nicht frei:

- keine Code-Aenderung,
- keine neuen Bilder,
- keine Assets,
- keine Dateien unter `assets/`,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- kein BuildState,
- keine Supabase/local DB Writes,
- keine SRS-/`word_progress`-Aenderung,
- kein Commit.
