# Lokaler Supabase-Wort-Auto-Sync: Status

## 1. Ausgangsproblem

Nach App-Löschung oder Neuinstallation ist die lokale SQLite-Datenbank leer oder nur mit Seed-Wörtern gefüllt. Nutzer mussten bisher manuell über die Entwickler-Einstellungen den Import „Supabase-Wörter lokal importieren“ starten.

Das ist für normale Nutzer nicht akzeptabel, weil die Wortwelten und lokalen Übungsquellen nach einer Neuinstallation ohne manuellen Debug-Schritt unvollständig bleiben.

## 2. Ziel

Lokale Supabase-Wörter sollen automatisch wiederhergestellt werden. Nutzer sollen keinen manuellen Import starten müssen.

Dabei gelten klare Sicherheitsgrenzen:

- SRS- und `word_progress`-Daten dürfen nicht überschrieben oder verändert werden.
- Der App-Start darf nicht blockiert werden.
- Supabase darf nur gelesen werden.
- Der bestehende lokale Import muss idempotent bleiben.

## 3. Umsetzung

Der Auto-Sync wurde als kleine Grundlage auf der bestehenden Import-Logik aufgebaut.

Geänderte oder neue Dateien:

- `lib/core/local_database/services/supabase_words_local_auto_sync_service.dart`
  - Neuer Service für `runIfNeeded()`, lokale Count-Prüfung, In-flight-Guard und Fehlerfang.
- `lib/core/local_database/providers/supabase_words_local_import_controller_provider.dart`
  - Neuer Provider für den Auto-Sync-Service.
  - Nutzt weiterhin den bestehenden Supabase-Reader und den bestehenden lokalen Import-Service.
- `lib/core/local_database/repositories/word_repository.dart`
  - Ergänzt `countAllWords()`, damit die lokale Wortanzahl leicht geprüft werden kann.
- `lib/main.dart`
  - Startet den Auto-Sync nach App-Initialisierung und nach dem ersten Frame im Hintergrund.
- `test/core/local_database/supabase_words_local_auto_sync_service_test.dart`
  - Tests für Import-Auslösung, Skip-Verhalten, Parallelstart-Schutz und Fehlerfang.

## 4. Auto-Sync-Verhalten

Der Auto-Sync startet nach der App-Initialisierung und nach dem ersten Frame. Dadurch kann die App normal rendern, während der Sync im Hintergrund entscheidet, ob etwas zu tun ist.

Ablauf:

1. `runIfNeeded()` wird einmalig angestoßen.
2. Die lokale Wortanzahl wird geprüft.
3. Wenn lokale Wörter `< 1000` sind, wird der lokale Supabase-Wortimport ausgelöst.
4. Wenn lokale Wörter `>= 1000` sind, wird der Import übersprungen.
5. Der Import läuft im Hintergrund.
6. Fehler werden abgefangen und geloggt.
7. Die App bleibt auch bei fehlender Verbindung oder Importfehler nutzbar.

## 5. Sicherheitsregeln

- Supabase wird nur lesend verwendet.
- Der lokale Import bleibt idempotent.
- `word_progress` wird nicht verändert.
- Bestehende SRS-Daten werden nicht gelöscht, überschrieben oder neu berechnet.
- Parallele mehrfach gestartete Auto-Syncs werden durch einen In-flight-Guard verhindert.
- Der Entwickler-Import bleibt als manueller Fallback erhalten.

## 6. Warum Nicht Nur `count == 0`?

Nach einer Neuinstallation können lokale Seed-Wörter vorhanden sein. Eine reine Prüfung auf `count == 0` würde dann keinen Restore auslösen, obwohl die große lokale Supabase-Wortbasis noch fehlt.

Deshalb wurde für die erste Version pragmatisch die Schwelle `< 1000` gewählt:

- Seed-Daten lösen weiterhin den Restore aus.
- Eine vollständig importierte lokale Wortbasis mit ca. 13.000 Wörtern löst keinen unnötigen Import bei jedem App-Start aus.
- Die Logik bleibt einfach und risikoarm.

## 7. Noch Offene Punkte

- Später Premium- oder freigeschaltete Pakete berücksichtigen.
- Später echte Delta- oder Update-Sync-Logik ergänzen.
- Später optional sichtbaren Sync-Status anzeigen.
- Später genauer prüfen, wann Auto-Sync erneut laufen soll.
- Später Nutzer- und Account-Kontext sauber berücksichtigen.

## 8. Tests

Gelaufene Tests:

- `flutter test test/core/local_database/supabase_words_local_auto_sync_service_test.dart --reporter compact`
- `flutter test test/core/local_database/supabase_words_local_import_service_test.dart --reporter compact`
- `flutter test test/features/supabase_words_local_import_screen_test.dart --reporter compact`
- `flutter test`

Zusätzlich wurde `git diff --check` ausgeführt.

## 9. Aktueller Stand

Der Auto-Sync ist eine MVP-Grundlage.

Er enthält noch kein Premium-Paket-System und keine komplexe Update-Synchronisation. Das Ziel dieses Schritts ist: Nach Neuinstallation werden freie oder lokale Basiswörter automatisch wiederhergestellt, ohne dass Nutzer den Entwickler-Import manuell starten müssen.
