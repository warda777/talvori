# Manual Local Translation Trigger State

## Ausgangslage

Lokale importierte Wörter können den Übersetzungsstatus `pending`, `translated` oder `failed` haben. Die Verarbeitung läuft über den `PendingTranslationProcessor`, der einen injizierten `TranslationClient` verwendet.

## Manueller Trigger

In der lokalen Wortliste erscheint nun eine manuelle Aktion, wenn in der aktuellen Kategorie pending-Wörter vorhanden sind:

`Ausstehende Übersetzungen verarbeiten`

Der Nutzer kann damit bewusst die Verarbeitung auslösen. Es gibt weiterhin keine automatische Übersetzung beim Import und keine automatische Übersetzung beim App-Start.

## Verhalten

Beim Auslösen:

- pending-Wörter der aktuellen Kategorie werden über den `PendingTranslationProcessor` verarbeitet.
- Während der Verarbeitung wird ein Ladezustand angezeigt.
- Nach Abschluss wird die lokale Wortliste neu geladen.
- Status-Badges aktualisieren sich.
- Fehler werden als Meldung angezeigt und führen nicht zum App-Crash.
- Failed-Wörter bleiben sichtbar.

## TranslationClient

Der `FakeTranslationClient` bleibt ohne explizite Konfiguration der Default.

Ein `DeepLTranslationClient` kann nur über die bestehende lokale Konfigurations-/Provider-Struktur verwendet werden. Es wurde kein echter API-Key eingebaut und keine produktive DeepL-Aktivierung vorgenommen.

## Bewusste Grenzen

- Keine automatische Online-Übersetzung.
- Kein echter API-Key im Repository.
- Keine Supabase-Änderung.
- Keine Online-Sync-Logik.
- Kein Retry für `failed`-Wörter in diesem Schritt.

## Tests

Die Tests prüfen:

- Button erscheint bei pending-Wörtern.
- Button erscheint nicht ohne pending-Wörter.
- Klick triggert die lokale Provider-/Runner-Struktur.
- Nach Verarbeitung wird die Liste aktualisiert.
- Fehler führen nicht zum Crash.

## Offene nächste Schritte

Mögliche spätere Erweiterungen:

- Retry für `failed`-Wörter.
- Sicherer Runtime-Key-Pfad.
- Manuelle Aktivierung eines echten DeepL-Clients.
- Optionaler einzelner Übersetzen-Button im Wortdetail.
