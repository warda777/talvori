# Manual Local Translation Retry State

## Ausgangslage

Lokale importierte Wörter können den Übersetzungsstatus `pending`, `translated` oder `failed` haben. Pending-Wörter können bereits manuell über die lokale Wortliste verarbeitet werden.

Dieser Stand ergänzt einen gezielten manuellen Retry für fehlgeschlagene lokale Übersetzungen.

## Verhalten

Fehlgeschlagene Wörter bleiben in „Meine Wörter“ sichtbar und zeigen weiterhin den Status „Übersetzung fehlgeschlagen“. Wenn mindestens ein `pending`- oder `failed`-Wort vorhanden ist, zeigt die lokale Wortliste eine manuelle Übersetzungsaktion.

Bei `failed`-Wörtern setzt der manuelle Retry diese Wörter zuerst kontrolliert auf `pending` zurück und verarbeitet sie danach über den bestehenden `PendingTranslationProcessor`.

## Kein Auto-Retry

Der Retry ist ausschließlich manuell.

Es gibt weiterhin:

- keine automatische Übersetzung beim Import
- keine automatische Übersetzung beim App-Start
- keinen Auto-Retry
- keine Endlosschleife

Fehler beim Retry führen nicht zum App-Crash. Wörter können erneut den Status `failed` erhalten, wenn der konfigurierte TranslationClient wieder fehlschlägt.

## Technische Bausteine

- `WordRepository.resetFailedTranslationsToPending(...)`
- `PendingTranslationProcessor.processPendingAndRetryFailedTranslations(...)`
- `pendingAndFailedTranslationRunnerProvider`
- `LocalWordListScreen` mit gemeinsamer manueller Aktion für pending/failed Wörter

Der bestehende `processPendingTranslations(...)`-Pfad bleibt erhalten und verarbeitet weiterhin nur `pending`-Wörter.

## Konfiguration

`FakeTranslationClient` bleibt ohne explizite Konfiguration die sichere Standardbasis. DeepL ist weiterhin nur über die vorhandene Konfigurationsstruktur vorbereitbar und wird nicht automatisch aktiviert.

Es wurde kein echter API-Key eingebaut.

## Tests

Abgesichert sind:

- failed Wörter können wieder auf `pending` gesetzt werden
- Retry verarbeitet zurückgesetzte Wörter
- erneuter Fehler setzt Wörter wieder auf `failed`
- UI zeigt eine Retry-Aktion, wenn failed Wörter vorhanden sind
- pending-only Flow bleibt unverändert
- Fehlerfall crasht nicht

## Bewusst nicht geändert

- keine Supabase-Logik
- keine automatische Online-Übersetzung
- kein echter DeepL-Key
- kein Auto-Retry
- keine UI-Großänderung
- keine SRS-Änderung

## Nächster sinnvoller Schritt

Später kann ein einzelner Retry im Wortdetail ergänzt werden. Danach wäre ein sicher konfigurierter echter `DeepLTranslationClient` der nächste technische Schritt, sobald das API-Key-Konzept final ist.
