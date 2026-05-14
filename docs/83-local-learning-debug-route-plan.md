# 83 Local Learning Debug Route Plan

Stand: 2026-05-14

## 1. Zweck der Debug-Route

Die Debug-Route soll den bestehenden `LocalLearningTestScreen` manuell erreichbar machen, damit die lokale Offline-first-Lernkette in einer App-Umgebung visuell geprueft werden kann.

Ziele:

- `LocalLearningTestScreen` bewusst oeffnen.
- Start/Fortsetzen, Richtig/Falsch und Completion visuell pruefen.
- Lokale Provider-, Controller-, ViewModel- und ScreenContract-Kette in einer App-Huelle testen.
- Keine produktive Navigation einfuehren.
- Keine bestehende Lernoberflaeche ersetzen.
- Keine bestehende UI oder App-Flows veraendern.

Die Route ist nur ein geplanter Debug-Zugang. Sie ist kein Produktfeature und keine finale Offline-first-Integration.

## 2. Sinnvolle Route

Eine klare Debug-Route waere:

- `/debug/local-learning`

Eigenschaften:

- Nur fuer Debug/Dev gedacht.
- Nicht in normaler Produktnavigation sichtbar.
- Nicht ueber bestehende Lernbuttons erreichbar.
- Nicht als Ersatz fuer `learn_mode_screen.dart`.
- Nicht als neuer regulaerer Lernflow.

Die Route sollte spaeter eindeutig als intern/debug markiert sein. Falls ein Router-Name gebraucht wird, waere ein sprechender Name sinnvoll, z. B.:

- `debugLocalLearning`

## 3. categoryId-Uebergabe

`LocalLearningTestScreen` bekommt `categoryId` bereits als Konstruktor-Parameter. Das sollte fuer die Debug-Route beibehalten werden.

Regeln:

- `categoryId` wird per Konstruktor uebergeben.
- Der Screen laedt keine Kategorien selbst.
- Der Screen macht keine Kategorieabfrage.
- Der Screen nutzt keine Supabase-Datenquelle.
- Der Screen startet keinen Seed.
- Der Screen startet keinen Asset-Import.

Fuer einen ersten Debug-Zugang kann spaeter bewusst eine feste Debug-`categoryId` verwendet werden, zum Beispiel:

- `basics`

Das ist nur sicher, wenn die passende lokale Kategorie vorher bewusst importiert wurde. Die Route darf nicht versuchen, fehlende Daten automatisch zu erzeugen.

Alternativ kann eine spaetere Debug-Route die `categoryId` als Query-Parameter oder Route-Parameter annehmen. Fuer Version 1 ist eine feste, bewusst gewaehlte Debug-ID einfacher und besser testbar.

## 4. Voraussetzung Lokaler Daten

Lokale Daten muessen vor der Nutzung bewusst vorhanden sein.

Moegliche Zustaende:

- Asset-Import wurde vorher explizit ausgeloest.
  - Dann kann `categoryId: basics` auf echte lokale Woerter zeigen.

- Kein Import wurde ausgefuehrt.
  - Dann kann der Testscreen nur den Initialzustand zeigen.
  - Start/Fortsetzen kann scheitern oder einen Fehlerzustand erzeugen, wenn die Kategorie nicht existiert oder keine Woerter vorhanden sind.

Nicht erlaubt:

- Kein automatischer Import beim Oeffnen der Route.
- Kein automatischer Seed beim Oeffnen der Route.
- Keine Datenbankabfrage im Screen, um eine Kategorie zu suchen.
- Keine stille Datenbefuellung durch Navigation.

Der Debug-Zugang soll sichtbar machen, ob die lokale Kette korrekt vorbereitet ist, nicht die Vorbereitung heimlich selbst erledigen.

## 5. Was nicht passieren darf

Die Debug-Route darf nicht:

- automatisch Import ausloesen.
- automatisch Seed-Daten erzeugen.
- Supabase verwenden.
- bestehende App-Flows veraendern.
- bestehende Navigation fuer normale Nutzer erweitern.
- `learn_mode_screen.dart` ersetzen.
- `LearnModeController` veraendern.
- `word_providers.dart` veraendern.
- `main.dart` ohne separate Planung anfassen.
- Produktnavigation einfuehren.
- alte `local_word_database.dart` verwenden.
- alte `word_progress.db` beruehren.

Der lokale Testscreen bleibt isoliert. Die Debug-Route waere nur ein kontrollierter Zugang zu diesem isolierten Screen.

## 6. Sichere Varianten

### Variante A: Route nur planen, noch nicht einhaengen

Beschreibung:

- Es wird nur diese Planungsdatei erstellt.
- Keine Router-Datei wird geaendert.
- Kein App-Zugang wird geschaffen.

Vorteile:

- Null Risiko fuer bestehende App-Flows.
- Saubere Entscheidungsgrundlage.
- Kein versehentlich sichtbarer Debug-Zugang.

Nachteile:

- Keine manuelle App-Pruefung moeglich.

Bewertung:

- Sicherste Variante fuer den aktuellen Schritt.

### Variante B: Separate Debug-Router-Datei vorbereiten

Beschreibung:

- Eine isolierte Datei koennte spaeter Debug-Routen definieren, ohne sie an `main.dart` oder Produktnavigation anzuschliessen.
- Beispielort fuer eine spaetere Planung:
  - `lib/features/local_learning_debug/routing/`

Vorteile:

- Debug-Route bleibt vom Produkt-Router getrennt.
- Tests koennen Route-Building isoliert pruefen.
- Keine direkte Produktnavigation.

Nachteile:

- Solange nicht eingebunden, ist sie nicht manuell erreichbar.
- Wenn spaeter eingebunden, braucht es klare Debug-Gates.

Bewertung:

- Gute naechste technische Variante, aber erst nach einem separaten TDD-Schritt.

### Variante C: Interner Dev-Schalter spaeter

Beschreibung:

- Ein spaeterer interner Dev-Schalter koennte Debug-Features sichtbar machen.

Vorteile:

- Bewusster Zugang.
- Koennte mehrere Debug-Werkzeuge buendeln.

Nachteile:

- Hoeheres Risiko fuer Produkt-Sichtbarkeit.
- Braucht klare Build-/Environment-Regeln.
- Kann schnell bestehende UI beruehren.

Bewertung:

- Nicht der kleinste naechste Schritt.

### Variante D: Direkte main.dart-Anbindung

Beschreibung:

- Route direkt in bestehende App-Konfiguration einhaengen.

Vorteile:

- Schnell manuell erreichbar.

Nachteile:

- Beruehrt App-Composition.
- Erhoeht Risiko fuer bestehende Flows.
- Kann Debug-Zugang versehentlich produktiv machen.
- Widerspricht der aktuellen Vorsicht.

Bewertung:

- Aktuell vermeiden.

## 7. Sinnvolle Tests

Spaetere Tests sollten ohne Supabase und ohne echte Produktnavigation laufen.

Sinnvolle Tests:

- `debug_route_can_build_local_learning_test_screen_with_category_id`
  - Prueft, dass die geplante Debug-Route den Screen mit einer `categoryId` baut.
  - Keine Datenbank noetig.
  - Provider koennen im Test ueberschrieben werden.

- `debug_route_does_not_start_import_automatically`
  - Prueft, dass Route-Building keinen Importservice aufruft.
  - Kein Asset-Import beim Oeffnen.

- `debug_route_does_not_touch_supabase`
  - Prueft praktisch ueber lokale Provider-Overrides, dass keine Supabase-Initialisierung noetig ist.

- `debug_route_not_connected_to_production_navigation`
  - Prueft, dass die Debug-Route nicht in einer produktiven Navigationsliste oder einem normalen Menue auftaucht.
  - Alternativ: fuer eine isolierte Debug-Router-Datei pruefen, dass sie nicht automatisch in den App-Router eingebunden ist.

Ergaenzend koennte ein Widget-Test fuer den Screen weiter ausreichen, solange die Route noch nicht wirklich eingebunden ist.

## 8. Risiken

Risiken:

- Debug-Route wird versehentlich produktiv sichtbar.
- `categoryId` fehlt oder zeigt auf eine nicht importierte Kategorie.
- Import und Lernscreen werden zu frueh gekoppelt.
- Bestehender Supabase-Lernflow und lokaler Lernflow werden vermischt.
- `main.dart` oder Produkt-Router wird zu frueh geaendert.
- Debug-Route erzeugt falschen Eindruck einer fertigen Produktintegration.
- QA erwartet Daten, obwohl kein bewusster Import ausgefuehrt wurde.

Gegenmassnahmen:

- Route zunaechst nur planen.
- Spaeter eine separate Debug-Router-Datei bevorzugen.
- `categoryId` explizit uebergeben.
- Keine automatische Datenbefuellung.
- Keine Produktnavigation.
- Klare Debug-Benennung fuer Route und Dateien.

## 9. Klare Empfehlung

Empfehlung fuer jetzt:

- Nur diese Planung abschliessen.
- Keine Route einhaengen.
- Keine Aenderung an `main.dart`.
- Keine Aenderung an bestehender Navigation.

Kleinster naechster TDD-Schritt, falls die Route spaeter umgesetzt werden soll:

1. Eine isolierte Debug-Route-Builder-Datei planen oder erstellen, die noch nicht in die App eingebunden ist.
2. Einen Test schreiben:
   - `debug_route_can_build_local_learning_test_screen_with_category_id`
3. Im Test Provider-Overrides fuer `localLearningViewModelProvider` und `localLearningScreenContractProvider` nutzen.
4. Pruefen, dass `LocalLearningTestScreen(categoryId: 'basics')` gebaut werden kann.
5. Pruefen, dass kein Import, kein Supabase und keine Produktnavigation noetig sind.

Erst danach sollte entschieden werden, ob ein Debug-Only-Gate oder eine interne Dev-Navigation sinnvoll ist.
