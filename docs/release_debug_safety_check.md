# Release Debug Safety Check

## Ziel

Diese Prüfung bewertet, ob Debug-, Developer-, Import- und Admin-Zugänge im Release-Build sichtbar oder erreichbar sind. Geprüft wurde rein lokal im Code. Es wurden keine Supabase-Daten, keine Importdaten, keine SRS-/word_progress-Daten und keine Vokabeldaten verändert.

## Geprüfte Stellen

### App-Routen

- Datei: `lib/main.dart`
- Befund:
  - Die lokale Debug-Route `/debug/local-learning` wird nur registriert, wenn `kDebugMode` aktiv ist.
  - Im Release-Build ist die `routes`-Map leer.
- Ergebnis: release-sicher.

### Debug-Auto-Login

- Datei: `lib/main.dart`
- Befund:
  - Der automatische Test-Login läuft nur innerhalb von `if (kDebugMode && auth.currentUser == null)`.
- Ergebnis: release-sicher.

### Test-SharedPreference

- Datei: `lib/main.dart`
- Befund:
  - `last_shared_word = umbrella` wurde bisher beim Start unabhängig vom Build gesetzt.
  - Das ist kein sichtbarer Developer-Zugang, aber ein Testdaten-Artefakt im Release-Pfad.
- Änderung:
  - Das Setzen des TEST-Worts wurde hinter `kDebugMode` gekapselt.
- Ergebnis: release-sicherer als vorher.

### Settings Entwicklerbereich

- Datei: `lib/features/home/ui/screens/settings_screen.dart`
- Befund:
  - Die Sektion `Entwickler` ist mit `if (kDebugMode)` geschützt.
  - Der Einstieg `Supabase-Wörter lokal importieren` ist dadurch im Release nicht sichtbar.
- Ergebnis: release-sicher.

### Supabase-Wörter-Import-Screen

- Dateien:
  - `lib/features/home/ui/screens/supabase_words_local_import_screen.dart`
  - `lib/core/local_database/providers/supabase_words_local_import_controller_provider.dart`
- Befund:
  - Der Screen kann den Admin-Import auslösen, ist aber aus der normalen App-Navigation nur über den debug-geschützten Settings-Entwicklerbereich erreichbar.
  - Es wurde keine öffentliche Route für diesen Screen gefunden.
- Ergebnis: release-sicher, solange keine neue produktive Route auf diesen Screen gelegt wird.

### Home Debug Hub

- Datei: `lib/features/home/ui/screens/home_screen.dart`
- Befund:
  - Der FloatingActionButton `Local Learning Debug` wird nur bei `kDebugMode` angezeigt.
  - Er öffnet `LocalDebugHubScreen`.
- Ergebnis: release-sicher.

### CategoryDetail Debug-Button

- Datei: `lib/features/words/ui/screens/category_detail_screen.dart`
- Befund:
  - Der Button `Lokalen Debug-Lernscreen öffnen` ist mit `if (kDebugMode && debugLocalButtonState.isVisible)` geschützt.
- Ergebnis: release-sicher.

### Lokale Debug-Hubs

- Ordner: `lib/features/local_learning_debug/`
- Befund:
  - Enthält Debug-Hub, lokalen Lernscreen, Debug-Import und Entwicklungsansichten.
  - Gefundene Einstiege aus der App sind `kDebugMode`-geschützt.
- Ergebnis: release-sicher in der aktuellen Navigation.

### Tagesimpuls-Testbuttons

- Datei: `lib/features/home/ui/screens/course_screen.dart`
- Befund:
  - Testbenachrichtigung, echter 10-Sekunden-Test und Debug-Panel sind mit `if (kDebugMode)` geschützt.
- Ergebnis: release-sicher.

### Lokale Seed- und Asset-Import-Services

- Ordner: `lib/core/local_database/`
- Befund:
  - Seed- und Importservices existieren als technische Infrastruktur.
  - Keine sichtbare Admin-UI außerhalb debug-geschützter Einstiege gefunden.
- Ergebnis: keine direkte Release-UI-Lücke gefunden.

## Ergebnis

Die sichtbaren Debug-/Developer-Zugänge sind nach Codeprüfung im Release-Build nicht sichtbar oder nicht normal erreichbar. Eine kleine Testdaten-Lücke in `main.dart` wurde geschlossen, indem das Setzen von `last_shared_word` auf `kDebugMode` begrenzt wurde.

## Offene Risiken

- `SupabaseWordsLocalAutoSyncService` läuft weiterhin als produktive Bootstrap-Logik. Das ist kein sichtbarer Admin-Zugang, sollte aber vor Release fachlich bestätigt werden: Soll der lokale Auto-Sync im Release aktiv bleiben oder nur für Migration/Testphasen laufen?
- Debug-Screens bleiben im Release-Bundle referenzierbar, sind aber über die aktuelle App-Navigation und Route-Registrierung nicht erreichbar.

## Empfohlene Nachprüfung Auf Echtem Gerät

1. Release-/Profile-Build starten.
2. Settings öffnen und prüfen, dass keine Sektion `Entwickler` sichtbar ist.
3. Home öffnen und prüfen, dass kein Bug-/Debug-FloatingActionButton sichtbar ist.
4. Wortwelt/CategoryDetail öffnen und prüfen, dass kein lokaler Debug-Lernscreen-Button sichtbar ist.
5. Tagesimpuls öffnen und prüfen, dass keine Testbenachrichtigungs-Buttons sichtbar sind.
6. Deep Link oder manuelle Navigation zu `/debug/local-learning` im Release prüfen, falls später Routing erweitert wird.
