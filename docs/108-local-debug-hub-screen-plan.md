# 108 Local Debug Hub Screen Plan

Stand: 2026-05-15

## 1. Ziel

Ziel ist ein kleiner isolierter Debug-Hub fuer lokale Offline-first-Funktionen.

Der Hub soll spaeter als zentraler Einstieg fuer lokale Debug-/QA-Funktionen dienen, damit der `HomeScreen`-Debug-FAB nicht direkt genau einen einzelnen Screen oeffnen muss.

Erste Eintraege:

- Lokaler Lernscreen
- Lokale Kategorien / WordHub Debug

Der Hub bleibt ein Debug-/Dev-Werkzeug. Er ersetzt keine produktive Navigation und veraendert keine bestehenden Lernflows.

## 2. Warum Ein Debug-Hub Besser Ist Als Mehrere FloatingActionButtons

Ein Debug-Hub ist risikoaermer als mehrere Debug-FABs im `HomeScreen`, weil:

- der `HomeScreen` nur einen Debug-Einstieg behalten muss
- lokale Debug-Funktionen klar gebuendelt werden
- spaetere lokale Werkzeuge ergaenzt werden koennen, ohne den `HomeScreen` weiter aufzublaehen
- die Trennung zwischen Produkt-UI und Debug-UI deutlicher bleibt
- Debug-Navigation spaeter gezielter hinter `kDebugMode` oder einem Dev-Gate gehalten werden kann

Mehrere FloatingActionButtons wuerden dagegen schneller Layout- und Bedeutungsprobleme erzeugen und koennten mit produktiven Aktionen verwechselt werden.

## 3. Erste Hub-Eintraege

Der Hub sollte zunaechst nur zwei Eintraege haben:

- `Lokaler Lernscreen`
- `Lokale Kategorien`

### Lokaler Lernscreen

Dieser Eintrag oeffnet den bestehenden isolierten `LocalLearningTestScreen`.

Startwert:

- `categoryId: basics`

Der Eintrag ist weiterhin nur ein Debug-Einstieg. Wenn keine lokalen Daten vorhanden sind, zeigt der Testscreen seinen Initialzustand oder spaeter einen Fehler-/Leerlaufzustand. Er darf keinen Import automatisch starten.

### Lokale Kategorien

Dieser Eintrag oeffnet den bestehenden `LocalWordHubDebugScreen`.

Der Screen liest lokale Kategorien ueber `localCategoriesProvider` und nutzt `LocalWordHubDebugEntryPresenter`, um sichtbare lokale Debug-Items abzuleiten.

## 4. Verhalten Beim Tap

### Tap Auf Lokaler Lernscreen

Beim Tap soll der Hub oeffnen:

- `buildLocalLearningDebugScreen(categoryId: 'basics')`

Oder aequivalent:

- `buildLocalLearningDebugScreen(categoryId: localLearningDebugDefaultCategoryId)`

Dabei darf nicht passieren:

- kein automatischer Import
- keine automatische Session
- keine Datenbankoeffnung durch den Hub selbst
- kein Supabase-Zugriff

### Tap Auf Lokale Kategorien

Beim Tap soll der Hub oeffnen:

- `LocalWordHubDebugScreen`

Der `LocalWordHubDebugScreen` darf lokale Kategorien ueber den bestehenden Provider lesen. Der Hub selbst soll keine Kategorien laden, keinen Import starten und keine Session starten.

## 5. Was Nicht Passieren Darf

Nicht erlaubt:

- kein automatischer Import
- keine automatische Session
- kein Supabase
- keine Aenderung bestehender Lernflows
- keine Aenderung an `LearnModeController`
- keine Aenderung an `learn_mode_screen.dart`
- keine Aenderung an `word_providers.dart`
- keine Aenderung an `word_hub_screen.dart`
- keine produktive Navigation
- kein Umbau der bestehenden Home-/WordHub-/Lernoberflaechen

Der Hub ist nur ein Debug-Container fuer bereits isolierte lokale Screens.

## 6. Sinnvolle Tests

Sinnvolle spaetere Tests:

- `debug_hub_shows_local_learning_entry`
  - prueft, dass der Eintrag `Lokaler Lernscreen` sichtbar ist

- `debug_hub_shows_local_wordhub_entry`
  - prueft, dass der Eintrag `Lokale Kategorien` sichtbar ist

- `debug_hub_opens_local_learning_screen`
  - tippt auf `Lokaler Lernscreen`
  - prueft, dass der `LocalLearningTestScreen` im Initialzustand sichtbar ist
  - prueft, dass `categoryId: basics` verwendet wird, soweit testbar

- `debug_hub_opens_local_wordhub_debug_screen`
  - tippt auf `Lokale Kategorien`
  - prueft, dass `LocalWordHubDebugScreen` geoeffnet wird
  - nutzt Provider-Overrides, damit keine echte DB noetig ist

- `debug_hub_does_not_import_or_start_session`
  - prueft, dass Screen-Build und Navigation keinen Import und keine Session ausloesen

## 7. Spaetere HomeScreen-FAB-Aenderung

Der bestehende `HomeScreen`-Debug-FAB sollte spaeter nicht mehr direkt:

- `localLearningDebugRoutePath`

oeffnen.

Stattdessen sollte er nur im Debug-Modus den neuen Debug-Hub oeffnen.

Regeln:

- weiterhin nur `kDebugMode`
- kein produktiver Menueintrag
- keine weitere HomeScreen-Logik
- kein Import beim Tap auf den FAB
- keine Session beim Tap auf den FAB

Damit bleibt der `HomeScreen` bei einem einzigen Debug-Einstieg, waehrend die lokalen Debug-Funktionen im Hub wachsen koennen.

## 8. Risiken

Risiken:

- Debug-Hub wird versehentlich produktiv sichtbar
- Debug-Hub wird mit einem Produktmenue verwechselt
- zu viele Debug-Funktionen landen direkt im `HomeScreen`
- der Hub startet versehentlich Import oder Session beim Oeffnen
- lokale Debug-Screens werden zu frueh als Produktnavigation verstanden

Gegenmassnahmen:

- Hub nur unter `kDebugMode` erreichbar machen
- HomeScreen nur mit einem Debug-FAB belassen
- Hub-Datei im Bereich `local_learning_debug` halten
- keine automatische Datenaktion im Hub implementieren
- Produktintegration separat planen

## 9. Kleinster Naechster TDD-Schritt

Der kleinste naechste TDD-Schritt:

1. Einen isolierten `LocalDebugHubScreen` im Bereich `local_learning_debug` anlegen.
2. Einen Widget-Test anlegen.
3. Erster Test:
   - `debug_hub_shows_local_learning_entry`
4. Der Test prueft nur:
   - Hub rendert
   - `Lokaler Lernscreen` ist sichtbar
   - kein Import wird gestartet
   - keine Session wird gestartet
   - kein Supabase ist noetig

Noch nicht im ersten Schritt:

- keine HomeScreen-Anbindung
- keine Aenderung am bestehenden Debug-FAB
- kein produktiver Router
- kein Importbutton
- keine Datenbankpflicht

Danach sinnvoll:

- zweiten Eintrag `Lokale Kategorien` testen
- Navigation zum `LocalLearningTestScreen` testen
- Navigation zum `LocalWordHubDebugScreen` testen
- erst danach die Debug-FAB-Umleitung separat planen
