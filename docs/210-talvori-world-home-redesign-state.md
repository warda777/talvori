# Talvori Welt Home Redesign: aktueller Stand

## 1. Ausgangspunkt

Talvori wurde in den letzten Redesign-Bloecken von einer normalen Vokabel-App-MVP-Richtung staerker zur **Talvori Welt** umgestellt.

Die Home-Seite ist damit nicht mehr primaer ein klassisches Lern-Dashboard, sondern die **Talvori-Welt-Zentrale**:

- der Globus ist das zentrale Hero-Objekt,
- Tali/Vori ist der Companion am Rand der Welt,
- der zentrale Plus-/Wheel-Hub wird zur Hauptnavigation,
- der Tagesstatus ersetzt statische Home-Texte,
- der visuelle Stil bewegt sich Richtung dunkler Neon-/Space-Welt.

## 2. Strategische Designentscheidung

Der alte Play-/Karten-/Dock-Ansatz wurde verworfen bzw. stark reduziert. Die Home soll nicht nach Dashboard, Moduluebersicht oder klassischer Vokabel-App aussehen.

Stattdessen gilt aktuell diese Richtung:

- grosser Globe als visuelles Hauptobjekt,
- Companion links am Globe,
- zentraler Plus-/Wheel-Hub unten,
- dynamischer Tagesstatus oberhalb des Globes,
- dunkler Premium-Neon-Stil mit Cyan, Violett und gezielten Gold-Akzenten am Globe.

Die Navigation soll sich mehr wie ein interaktiver Welt-Hub anfuehlen, nicht wie eine Reihe statischer Bottom-Bar-Buttons.

## 3. Globe-Entwicklung

Der erste Globe-Ansatz als CustomPainter-/Wireframe-Globe war visuell nicht hochwertig genug. Danach wurde auf einen realistischeren animierten Globe auf Basis von `flutter_globe_3d` / Earth3D umgestellt.

Wichtige Schritte:

- Umstellung auf einen realistischeren animierten Globe.
- Einfuehrung eines Talvori-spezifischen Premium-Earth-Shaders.
- Hervorhebung von Kuesten-/Kontinentkanten ueber Shader-/UV-Nachbarschaftssampling.
- Einbindung von Night-Lights und City-/Node-Lichtern.
- Vergrösserung des Globes und Platzierung als dominantes Hero-Element.
- Entfernung des duennen goldenen Aussenkreises.
- Umstellung der Network-Lines von gestrichelt auf durchgehende goldene Linien.
- Verbesserung der Star-/Node-Lichter zu Lens-Flare-artigen Punkten.
- Ergaenzung besser sichtbarer frontseitiger Verbindungen.

Der Globe bleibt das Tap-Ziel fuer die Welt bzw. Startregion. Er wurde nicht in das Plus-Menue verschoben.

## 4. Background / Galaxy

Der bestehende cyan/lila Ambient-Background bleibt die Basis. Mehrere Versuche mit lokalem Glow direkt hinter dem Globe wurden wieder verworfen, darunter:

- milchige/exzentrische Kreis-Overlays,
- goldene Boegen bzw. rechte Blur-Streifen,
- sichtbare cyan/violette Arc-Linien um den Globe.

Bevorzugt wurde stattdessen ein ruhiger Fullscreen-Background mit cyan links und violett rechts, der nach oben und unten dunkler auslaeuft.

Darauf wurde eine Galaxy-/Sternenebene gelegt:

- mehrere Stern-Layer fuer mehr Tiefe,
- dezentes Twinkling,
- vereinzelte Sternschnuppen,
- leichte Galaxy-/Dust-Struktur,
- keine externen Bildassets.

Aktuelle offene Verbesserung:

- Sternschnuppen sollen natuerlicher aus verschiedenen Richtungen kommen.
- Der Sternschnuppen-Kopf soll runder und gluehender wirken.
- Spaeter koennten mehrere Hintergrund-Modi sinnvoll sein:
  - Subtil,
  - Atmosphaerisch,
  - Galaxie.

## 5. Plus-/Wheel-Hub

Der klassische Bottom-Dock wurde verworfen. Das aktuelle Ziel ist ein zentraler Plus-Button unten, der ein drehbares Wheel mit mehreren Funktionen oeffnet.

Aktueller Hub-Gedanke:

- geschlossen ist nur das zentrale Plus sichtbar,
- geoeffnet fliegen Wheel-Buttons radial heraus,
- einige Buttons duerfen teilweise aus dem unteren Displayrahmen verschwinden,
- der Nutzer kann das Wheel radial drehen, nicht horizontal scrollen,
- keine Pfeile, kein sichtbarer grosser Ring, kein klassisches Panel.

Plus/X-Erkenntnis:

- 360 Grad allein ist als Endzustand falsch, weil das Symbol wieder wie ein Plus aussieht.
- Gewuenscht ist: 360 Grad volle Rotation plus 45 Grad Endwinkel, also 405 Grad.
- Geschlossen: Plus bei 0 Grad.
- Geoeffnet: X bei 405 Grad.
- Der X-Zustand soll im Cyan/Violett-Stil aktiver wirken:
  - dunkler Innenkreis,
  - staerkerer Violett-Anteil,
  - intensiverer Violett-Glow,
  - kein Gold im Hub-Button.

Bekannter offener Zustand:

- `lib/features/home/ui/widgets/home_smart_hub_menu.dart` enthaelt noch eine vorhandene unstaged Aenderung am Wheel-Radius.
- Diese Radius-Aenderung wurde in den letzten Plus/X-Commits bewusst nicht mitcommitted.

## 6. Companion / Tali

Tali/Vori ist als aktiver Companion gedacht; es werden nicht beide parallel als gleichwertige Figuren angezeigt.

Aktueller Companion-Stand:

- Tali sitzt links am Globe.
- Idle-, Focus-/Bubble- und Chat-Zustand wurden mehrfach justiert.
- Tali/Bubble sollen bei Chat/Input/Keyboard sichtbar und oberhalb der Eingabeleiste bleiben.

Ein zentraler Bug war, dass der Globe beim Oeffnen des Companion-Chats bzw. der Tastatur groesser wirkte. Die Debug-Phase war laenger und umfasste mehrere Hypothesen:

- Rect-/Hero-Tests,
- Overlay-Ueberdeckung,
- Earth3D-Rebuild,
- Companion-State-Abhaengigkeit,
- Input-Bar-/Keyboard-Inset.

Die Hauptursache wurde schliesslich per Runtime-Logs gefunden:

- Vor Keyboard war `MediaQuery.padding.bottom` auf dem iPhone bei ca. `34.0`.
- Bei geoeffneter Tastatur fiel `MediaQuery.padding.bottom` auf `0.0`.
- Dadurch wurde fuer Home/Hero/Globe mehr verfuegbare Hoehe berechnet.
- Der Hero wurde hoeher und der Globe groesser.

Fix:

- Home-/Hero-/Globe-Layer nutzen fuer die statische Groessenberechnung keyboard-stabile Safe-Area-Werte, insbesondere `viewPadding.bottom`.
- Die Input-Bar nutzt weiterhin echtes `viewInsets.bottom`.

Ergebnis:

- Der Globe bleibt beim Oeffnen der Tastatur stabil.
- Tali/Bubble wurden danach ueber der Input-Bar positioniert.

Aktueller Stand:

- Globe stabil.
- Tali/Bubble sichtbar oberhalb der Tastatur.
- Bubble-Text braucht mehr Raum.
- Quick-Buttons in der Bubble sollen nicht dauerhaft sichtbar sein.

## 7. Companion-Bubble / Chat

Die Bubble enthaelt aktuell Tali-Text, Chat-Icon und Quick Actions.

Problem:

- Dauerhaft sichtbare Quick Actions nehmen Textplatz weg.
- Tali hat dadurch nur sehr wenig Platz fuer laengere Antworten.
- Text kann abgeschnitten wirken.

Gewuenschte Richtung:

- Quick-Buttons nur anzeigen, wenn echte Suggestions vorhanden sind.
- Standard-Bubble zeigt nur:
  - Tali-Name,
  - Text,
  - Chat-Icon.
- Text darf nicht hart auf wenige Zeilen begrenzt werden.
- Bubble darf bis zu einer Max-Hoehe wachsen.
- Laengerer Text soll innerhalb des Textbereichs scrollbar sein.

Zusaetzlich soll im Companion-Chat die Tastatur per Swipe nach unten geschlossen werden koennen, ohne dass Globe oder Home-Layout springen.

## 8. Home-Status-Text

Der alte statische Text wurde kritisch geprueft:

- Headline: `Deine Welt wartet.`
- Unterzeile: `0 Woerter · Talvori-Welt-Zentrale`

Entscheidung:

- Die Home soll keinen statischen Dashboard-Claim zeigen.
- Stattdessen soll ein dynamischer Tagesstatus anzeigen, was gerade relevant ist.

Aktueller Minimalstand:

- Bei `0` Woertern:
  - `Deine Welt wartet`
  - `Sammle dein erstes Wort aus der echten Welt`
- Bei vorhandenen Woertern soll der Status dynamisch werden, z. B. anhand des Wortzaehlers.

Ziel fuer spaetere Erweiterung:

- Tali-Hinweis,
- Satzfunken,
- faellige Woerter,
- neue/importierte Woerter,
- Weltfortschritt,
- sauberer Fallback.

Wichtig: Die Home soll nicht zur statischen Metrik-/Dashboard-Flaeche zurueckfallen.

## 9. Wichtige Bugs und Erkenntnisse

Besonders relevante Erkenntnisse:

- Der sichtbare Globe-Zoom war kein Globe-Shader-Problem.
- Der finale Keyboard-Bug kam von `MediaQuery.padding.bottom`.
- Tests, die nur Widget-Rects pruefen, koennen optische Fehler uebersehen.
- Runtime-Logs waren entscheidend, um den Unterschied zwischen `padding.bottom`, `viewPadding.bottom` und `viewInsets.bottom` sichtbar zu machen.
- Kleine, isolierte Codex-Bloecke funktionieren besser als grosse Prompts mit zu vielen gleichzeitigen Zielen.
- Visuelle Anforderungen muessen sehr praezise formuliert werden, besonders bei Glow, Overlays, Arcs, Bubble-Geometrie und Animationen.

## 10. Aktueller technischer Zustand

Letzte relevante Commits aus diesem Abschnitt:

- `bf123cd3 fix: polish home hub plus x animation`
- `c77b993e fix: rotate home hub plus into x state`
- `7afce1dc feat: improve home shooting star behavior`
- `4cdd2735 feat: enhance home galaxy depth`
- `d4521604 feat: add subtle home galaxy background`
- `ccf9234b feat: add dynamic home status message`
- `821cf5db fix: improve companion chat bubble and keyboard dismiss`
- `b126e53a fix: keep companion above keyboard input`
- `128a9271 fix: keep home hero size stable with keyboard`

Nicht beruehrt in diesen UI-Bloecken:

- keine Supabase Writes,
- keine SQLite-Vokabeldaten,
- keine SRS-/`word_progress`-Daten,
- keine Secrets,
- keine Keystores/Zertifikate,
- keine Release-Artefakte.

Der aktuelle Fokus liegt weiter auf der Home-Zentrale der Talvori Welt.

## 11. Offene naechste Schritte

### A. Kurzfristig

- Companion-Bubble-Textlayout verbessern.
- Quick-Buttons nur bei echten Suggestions anzeigen.
- Keyboard per Swipe nach unten schliessen.
- Sternschnuppen weiter randomisieren und optisch final pruefen.
- Plus/X-Button mit 405-Grad-Rotation und verbessertem X-Zustand auf dem Geraet final pruefen.
- Unstaged Aenderung in `home_smart_hub_menu.dart` pruefen und entscheiden: committen, anpassen oder verwerfen.

### B. Danach

- Wheel-Menue final stabilisieren.
- Tali-Position und Idle-Groesse final auf echten Geraeten pruefen.
- Home-Statuslogik erweitern.
- Satzfunken/Tagesimpuls sinnvoll im Hub und ggf. in der Bubble anbinden.

### C. Spaeter

- Hintergrund-Modi:
  - Subtil,
  - Atmosphaerisch,
  - Galaxie.
- Reward Bridge.
- Lokale Startregion.
- Weltfortschritt aus Lernaktionen.

