# Category Settings & Help State

## 1. Warum der einfache Entwurf ersetzt wurde

Der erste Entwurf von **„Wortwelt gestalten“** war technisch korrekt, aber visuell zu abstrakt. Die Vorschau bestand eher aus Symbolflächen als aus einer erkennbaren Nachbildung der echten CategoryDetail- und Lernmodus-Screens.

Der neue Ansatz ersetzt diesen einfachen Entwurf durch einen visuellen Vorschau-Editor. Nutzer sollen direkt sehen, welches reale UI-Element sie gestalten, statt eine Liste von abstrakten Optionen zu bedienen.

## 2. Ziel: visueller Vorschau-Editor

Das Panel **„Wortwelt gestalten“** bleibt ein Dark-Neon-BottomSheet mit den Tabs:

- Kategorie
- Lernmodus
- Info

Der Fokus dieses MVP liegt auf einer realistischeren Vorschau, einem beweglichen Farbfenster und lokaler Speicherung pro Wortwelt. Die Farbauswahl öffnet sich erst, wenn ein Element aktiv angetippt wird. Sie erscheint automatisch mit Abstand in der Nähe des gewählten Elements, bevorzugt darunter, bei wenig Platz darüber. Die automatische Positionierung hält das Fenster horizontal im sichtbaren Bereich; nur manuelles Verschieben darf es bewusst teilweise aus dem sichtbaren Bereich schieben.

Designwerte werden lokal in SharedPreferences unter `category_design.<categoryId>` gespeichert. Es gibt keine Supabase-Persistenz und keinen Cloud-Sync.

## 3. Kategorie-Vorschau nahe am echten CategoryDetail

Der Tab **Kategorie** bildet den echten CategoryDetail-Screen als skalierte Mini-Seite nach:

- dunkler Hintergrund
- Zurück-Pfeil
- Header-Kapsel mit Wortweltname
- neutraler Header-Glow ohne zweite Dummy-Kategorie
- Vocabs-Kachel mit Count-Badge
- Add- und Settings-Kreisbutton
- „Wiederholungsauswahl“
- „Alle Stufen“ und „Einzelstufe“
- „Merkstufen“ mit Stufen 0-5
- „Lernmodus“
- „Zeitplan“, „Limitlos“ und „Kombiniert“
- Start-Button
- Reset-Button

Die Elemente sind nur Vorschau, aber antippbar und visuell nahe am echten Screen aufgebaut. Standardmäßig orientieren sich Farben und Glow stärker am echten CategoryDetail, damit Nutzer zuerst einen vertrauten Zustand sehen. Die frühere Dummy-Kapsel mit **„Home & Living“** wurde entfernt; die Vorschau zeigt nur noch die aktuelle Wortwelt und darunter einen neutralen Glow. Die Mini-Seite wurde unten gestrafft, damit Start- und Reset-Bereich nicht mehr in zu viel leerer Fläche hängen.

Der äußere Vorschau-Radius wird device-nah approximiert. Da Flutter den echten Hardware-Corner-Radius nicht direkt bereitstellt, nutzt der Editor eine lokale MediaQuery-basierte Annäherung über die Gerätebreite: kleine Geräte bekommen etwas kleinere Rundungen, moderne große Phones stärkere Rundungen, Tablets wieder moderatere Werte.

## 4. Lernmodus-Vorschau nahe am echten Lernmodus

Der Tab **Lernmodus** bildet den Lernmodus als Mini-Screen nach:

- dunkler/purpurner Hintergrund
- Zurück-Pfeil
- Header-Kapsel
- große Lernkarte
- Audio-Button
- Level-Badge
- Beispielwort
- Favorit-/Status-Aktionen rechts
- Stufen 0-5 unten

Play- und Reset-Button wurden aus der Lernmodus-Vorschau entfernt, weil sie im echten Lernmodus-Screen an dieser Stelle nicht vorkommen. Der frühere schmale Streifen oben in der Lernkarte wurde ebenfalls entfernt; die Karte zeigt jetzt nur Audio, Level-Badge, Wort und rechte Aktionen. Das Beispielwort wird einzeilig per Scale-Down geschützt, damit längere Wörter nicht aus der Karte laufen.

Auch diese Vorschau ist nicht funktional. Sie dient nur zur Auswahl und Gestaltung einzelner Designflächen. Die Proportionen wurden so angepasst, dass Karte und Stufen näher am echten Mini-Lernmodus sitzen und unten weniger freie Fläche bleibt.

## 5. Element-Auswahl

Die Vorschau definiert konkrete Design-Elemente, zum Beispiel:

- Kategorie-Hintergrund
- Kategorie-Header
- Vocabs-Kachel
- Kreisbuttons
- Merkstufen
- Modus-Buttons
- Start-Button
- Reset-Button
- Lernmodus-Hintergrund
- Lernkarte
- Kartenrand
- Level-Badge

Beim Antippen bekommt das ausgewählte Element eine Neon-Auswahlmarkierung mit kleinen Handles. Erst dann erscheint das Farbfenster. Es zeigt den Namen des ausgewählten Elements und steuert nur dieses Element im lokalen Draft.

Das Farbfenster bleibt beim Wechsel zwischen Elementen offen. Wenn ein anderes Element angetippt wird, aktualisiert es Elementname, Farbe und Glow-Wert und positioniert sich erneut günstig über oder unter dem Element. Farbänderungen wirken sofort in der Vorschau und betreffen nur das aktuell ausgewählte Element. Sobald eine Farbe oder Glow-Stärke geändert wird, verschwindet die starke Auswahlmarkierung, damit die neue Farbe nicht vom Rahmen überdeckt wird. Das Element bleibt intern ausgewählt; beim Antippen eines anderen Elements erscheint die Markierung wieder.

Überschriften wie „Wiederholungsauswahl“, „Merkstufen“ und „Lernmodus“ haben enge Auswahlbereiche direkt um den Schriftzug. Sie werden nicht mehr über die komplette Vorschau-Breite markiert.

## 6. Bewegliches Farbfenster

Wenn ein Element ausgewählt ist, erscheint ein schwebendes Farbfenster über der Vorschau.

Das Farbfenster enthält:

- Header „Farbe“
- Name des aktuellen Elements
- Schließen-X
- Swatch-/Farbpalette
- Hex-Anzeige
- Hue- und Opacity-Leisten mit Drag-Bedienung
- Glow-Stärke: Aus, Dezent, Normal, Stark
- Pulsieren: Aus, Dezent, Normal, Stark
- „Element zurücksetzen“

Das Fenster kann per Longpress/Drag bewegt werden und löst beim Greifen einmalig Haptik aus. Interaktive Bereiche wie Farbfeld, Hue-Leiste, Opacity-Leiste, Swatches, Buttons, X und Section-Toggles behalten ihre eigene Bedienung.

Das Farbfenster liegt als eigenes Overlay über dem gesamten Settings-Sheet und ist nicht mehr an den Vorschau-Rahmen gebunden. Es kann also über Kategorie-, Lernmodus- und Info-Bereiche schweben und auch teilweise über die Sheet-/Display-Grenzen hinausgeschoben werden. Für die automatische Elementpositionierung gelten bewusst strengere Regeln als für manuelles Verschieben: Auto-Positionen bleiben links und rechts sichtbar und nutzen einen klaren Abstand zum gesamten angetippten Element; manuelle Drags bleiben großzügig und erlauben teilweises Herausschieben. Während des Panel-Drags wird das darunterliegende Sheet nicht mitgescrollt.

Das Panel lässt sich über den X-Button oder durch einen Tap außerhalb von Vorschau und Farbfenster schließen. Der Tap schließt nur den Farbeditor, nicht das gesamte **„Wortwelt gestalten“**-Sheet. Nach dem Schließen bleibt die Vorschau sichtbar; beim nächsten Element-Tap öffnet sich das Panel wieder sauber.

Die Farbpalette ist intern scrollbar und enthält rund 250 Swatches. Die Farben werden aus Basisfarben, Graustufen und einem HSV-Raster erzeugt, damit Grautöne, Rot, Orange, Gold, Grün, Türkis, Blau, Lila, Pink sowie helle, dunkle und neonartige Varianten abgedeckt sind, ohne das Fenster groß werden zu lassen.

Die früheren Einzelbuttons **„Zurücksetzen“** und **„Anwenden“** wurden aus dem Farbfenster entfernt, weil die finale Übernahme bereits beim Verlassen des Editors abgefragt wird. Stattdessen gibt es unten nur noch **„Element zurücksetzen“** für das aktuell ausgewählte Element. Dieser Button öffnet eine Bestätigung und setzt nur dieses Element im aktuellen Draft zurück.

- Titel: „Element zurücksetzen?“
- Text: „[Elementname] wird auf die Werkseinstellung zurückgesetzt.“
- Aktionen: „Abbrechen“ und „Zurücksetzen“

Bei Bestätigung wird nur das aktuelle Element im Draft auf Default zurückgesetzt. Dauerhaft gespeichert wird erst mit **„Übernehmen“** beim Schließen des Editors.

Pulsieren ist als eigene Draft-Einstellung ergänzt. Im MVP wird daraus noch keine echte Lernmodus-Animation gespeichert oder global aktiviert; die Vorschau nutzt den Wert als statische Pulse-Andeutung über stärkere Kontur-/Glow-Wirkung. Die echte Anwendung auf CategoryDetail/Lernmodus folgt später.

Vorhandene Farbauswahl-Bausteine wurden geprüft:

- `custom_color_picker_dialog.dart`
- `radial_palette_sheet.dart`
- `radial_palette_wheel.dart`
- `floating_palette_button.dart`
- `rotary_color_ring.dart`
- `radial_palette_tools.dart`

Das WordHub-/Radial-Palette-System wurde nicht direkt eingebunden, weil es an globale WordHub-Targets, `radialPaletteProvider`, `paletteControllerProvider`, `wordHubTileOverridesProvider` und WordHub-spezifische Target-IDs gekoppelt ist. Der Settings-Editor nutzt deshalb ein neutrales Farbpanel in `category_design_color_panel.dart`.

Dieses Panel leitet die besseren UI-Prinzipien der alten Palette ab: dunkles schwebendes Toolfenster, großer Farbbereich, Hex-Anzeige, Swatches, Hue/Opacity-Andeutung und Glow-Steuerung. Es hat eine editor-neutrale API und verändert nur den lokalen Preview-Draft. Es gibt keine WordHub-Provider- oder WordHub-Persistenz-Kopplung im Settings-Editor.

## 7. Lokale Persistenz und Werkseinstellung

Die Designwerte sind jetzt echte lokale pro-Wortwelt-Einstellungen:

- Kategorie-Design und Lernmodus-Design werden getrennt modelliert.
- Beide Bereiche teilen sich eine JSON-Datei pro `categoryId`.
- Elemente ohne Override fallen auf definierte Default-Werte zurück.
- Die Default-Werte liegen in `CategoryDesignDefaults` und bilden die aktuellen Talvori-Originalfarben ab.
- **„Kategorie zurücksetzen“** entfernt nur Kategorie-Overrides der aktuellen Wortwelt und invalidiert den lokalen Design-Provider sofort.
- **„Lernmodus zurücksetzen“** entfernt nur Lernmodus-Overrides der aktuellen Wortwelt und lässt Kategorie-Overrides unangetastet.
- **„Alle Designs zurücksetzen“** löscht alle gespeicherten Design-Overrides für alle Wortwelten.

Das Sheet kann nicht mehr unbemerkt per Drag oder Barrier-Tap geschlossen werden: Drag-Dismiss und Barrier-Dismiss sind deaktiviert. X und System-Pop laufen über denselben Übernahme-Flow, sodass ungespeicherte Drafts nicht versehentlich verloren gehen.

Der Übernahme-Flow bleibt bewusst:

- **Verwerfen** schließt ohne Speichern.
- **Weiter bearbeiten** bleibt im Editor.
- **Übernehmen** speichert den aktuellen Draft lokal für die aktuelle Wortwelt.

## 8. Was im MVP noch offen ist

Noch nicht vollständig umgesetzt ist:

- vollständige Anwendung jeder einzelnen Detailfarbe auf alle tief verschachtelten CategoryDetail-Unterelemente
- vollständige Anwendung jeder einzelnen Detailfarbe auf alle tief verschachtelten LearnMode-Spezial- und Fehlerzustände
- feingranulare echte Anwendung von Pulsieren auf weitere Lernmodus-Animationen außerhalb der Karte
- eigene Hintergrundbilder
- Export/Import von Designs
- Cloud-Sync der Designs
- komplexe Theme-Engine

Bereits angebunden sind im echten CategoryDetail:

- Kategorie-Header/Wheel-Kapsel
- Vocabs-Kachel und Vocabs-Counter
- Add-Button
- Settings-Button
- Wiederholungsauswahl-Buttons „Alle Stufen“ und „Einzelstufe“
- Section-Titel „Wiederholungsauswahl“, „Merkstufen“ und „Lernmodus“
- lokale Stage-Switches 0-5 mit individuellen Farben
- Lernmodus-Buttons „Zeitplan“, „Limitlos“ und „Kombiniert“
- Start-Button
- lokaler Reset-Button
- Kategorie-Hintergrund, sofern ein Override gespeichert ist

Im echten Lernmodus werden Lernmodus-Hintergrund, Header/Wheel-Kapsel, Lernkartenfarbe, Kartenrand, Karten-Glow, Worttext, Audio-Button, Level-Badge, Favorit-Button, Known-/Tagesimpuls-Button und Stage-Switches 0-5 gelesen. Der Karten-Glow ist ein eigenes Design-Element (`learnCardGlow`): Farbe, Glow-Stärke und Pulsieren wirken in der Vorschau und im echten Lernmodus. Wenn `pulse = Aus` gespeichert ist, läuft die Karten-Pulse-Animation nicht; der Glow bleibt dann statisch. Der Lernmodus-Hintergrund wird auch in der Vorschau in den Mini-Screen-Gradient eingerechnet, damit Farbänderungen sofort sichtbar sind.

Zusätzlich ist der Header-Fade des Category-Wheels im echten Lernmodus deaktiviert. Der dunkle Blender bleibt damit nicht mehr um die obere „Health & Fitness“-Kapsel liegen; andere Screens können den Edge-Fade weiterhin nutzen.

Für zusammengesetzte Elemente gibt es jetzt eine Teil-Auswahl vor dem Farbfenster. Beispiele:

- Header: Rahmen/Glow, Innenfläche, Schrift
- Vocabs: Rahmen/Glow, Innenfläche, Schrift, Icon, Counter-Rahmen, Counter-Fläche, Counter-Zahl
- Kreisbuttons: Rahmen/Glow, Innenfläche, Icon
- Buttons: Rahmen/Glow, Innenfläche, Schrift
- Stage-Switches: Außenkapsel, Innenfläche, Zahl
- Lernkarte: Kartenfläche, Kartenrand, Karten-Glow, Wortschrift
- Lernmodus-Icons und Badges: Rahmen/Glow, Innenfläche, Icon oder Schrift

Das Farbfenster enthält außerdem eine stabile In-App-Pipette: „Farbe aufnehmen“ speichert die aktuell gemischte/ausgewählte Farbe in eine lokale Custom-Palette. Die eigenen Farben werden über SharedPreferences unter `category_design.custom_palette` gespeichert und stehen im Kategorie- und Lernmodus-Editor gleichermaßen zur Verfügung. Es wird bewusst keine globale Screenshot-Pixelanalyse verwendet.

Der Confirm-Dialog lautet:

- Titel: „Änderungen übernehmen?“
- Text: „Möchtest du die Gestaltung für die aktuelle Wortwelt übernehmen?“
- Optionen: „Verwerfen“, „Weiter bearbeiten“, „Übernehmen“

Wenn keine Änderungen vorhanden sind, schließt der Editor ohne Dialog.

## 9. Nächste Schritte

Sinnvolle nächste Schritte:

- weitere CategoryDetail-Widgets an die gespeicherten Einzelelemente anschließen
- weitere LearnMode-Widgets an die gespeicherten Einzelelemente anschließen
- Sub-Target-Anwendung für noch tiefere Spezialzustände wie deaktivierte/gesperrte Stages weiter ausbauen
- Pulsieren feingranularer auf echte Animationscontroller abbilden
- eigene Hintergrund-/Bildoptionen später ergänzen
- Reset-/Export-Strategie definieren
- optional Cloud-Sync für Designs vorbereiten

## 10. Tests

Der CategoryDetail-Test prüft:

- Settings-Button öffnet „Wortwelt gestalten“
- Tabs „Kategorie“, „Lernmodus“ und „Info“ sind erreichbar
- Kategorie-Vorschau zeigt die echten Kernbereiche
- Lernmodus-Vorschau zeigt Karte, Beispielwort, Audio, Level-Badge und Stufen
- Farbfenster ist beim Öffnen nicht automatisch sichtbar
- Element-Auswahl markiert ein Element
- Farbfenster erscheint
- automatische Farbfenster-Position bleibt horizontal sichtbar
- manuelles Verschieben darf das Farbfenster teilweise aus dem sichtbaren Bereich bewegen
- Farbfenster lässt sich schließen
- Farbfenster lässt sich per Tap außerhalb schließen
- Farbwahl aktualisiert den lokalen Preview-State
- Farbwahl verändert nur das ausgewählte Element
- Farbwahl blendet die starke Auswahlmarkierung aus
- neue Element-Auswahl zeigt die Markierung wieder
- Überschrift-Auswahl bleibt eng am Text
- Farbfenster bleibt beim Wechsel zwischen Elementen offen
- Schließen ohne Änderungen fragt nicht nach
- Schließen mit Änderungen zeigt den Übernahme-Dialog
- „Verwerfen“, „Weiter bearbeiten“ und „Übernehmen“ sind im Dialog vorhanden
- Farbfenster ist verschiebbar
- die Palette enthält 200+ Swatches und ist scrollbar
- Farbfeld und Hue-Leiste reagieren auf Drag
- Farbfenster zeigt Pulsieren und die Pulse-Optionen sind auswählbar
- Karten-Glow hat ein eigenes Element mit Farbe, Glow-Stärke und Pulsieren
- zusammengesetzte Preview-Elemente öffnen zuerst eine Teil-Auswahl
- nach Auswahl eines Sub-Targets öffnet der Farb-Editor
- Custom-Farben können über „Farbe aufnehmen“ gespeichert und wieder ausgewählt werden
- der Lernmodus-Header rendert ohne dunklen Wheel-Edge-Fade
- „Übernehmen“ speichert lokal pro Wortwelt
- erneutes Öffnen lädt gespeicherte Werte
- gespeicherte Kategorie-Designwerte werden von echten CategoryDetail-Controls gelesen
- die Kategorie-Vorschau zeigt keinen **„Home & Living“**-Dummy mehr
- Section-Titel wie **„Merkstufen“** lesen echte Overrides
- gespeicherte Lernmodus-Designwerte werden von Hintergrund, Karten-Glow, Worttext, Audio, Level-Badge, Favorit/Known und Karten-Pulse gelesen
- Kategorie-Reset löscht nur Kategorie-Overrides der aktuellen Wortwelt und erhält Lernmodus-Overrides
- Bereichs-Reset und globaler Reset sind über eigene Bestätigungen getrennt
- Info-Hilfetexte sind auffindbar
