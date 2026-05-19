# DeepL Translation Client State

## Was wurde vorbereitet

Es wurde ein isolierter `DeepLTranslationClient` vorbereitet. Er implementiert das bestehende `TranslationClient`-Interface und kann später vom lokalen Translation-Provider verwendet werden.

Der Client ist noch nicht automatisch aktiv. Die lokale App nutzt weiterhin den `FakeTranslationClient` als sichere Standardbasis.

## Warum FakeTranslationClient Default bleibt

Der `FakeTranslationClient` bleibt Default, damit lokale Entwicklung, Tests und Importpfade ohne Netzwerk, API-Key oder externe DeepL-Abhängigkeit funktionieren.

Damit bleibt der lokale Offline-Flow stabil:

- Importierte Wörter können weiter lokal mit Status `pending` gespeichert werden.
- Tests laufen deterministisch.
- Keine automatische Online-Übersetzung wird gestartet.

## API-Key-Sicherheit

Es wurde kein echter API-Key committed.

Der `DeepLTranslationClient` erwartet den API-Key über den Konstruktor. Ein leerer Key wird abgelehnt. Dadurch wird verhindert, dass ein Key hart im Client-Code steht.

`.env.example` enthält nur Platzhalter:

- `DEEPL_API_KEY=your_deepl_api_key_here`
- `DEEPL_API_BASE_URL=https://api-free.deepl.com`

Echte `.env`-Dateien bleiben durch `.gitignore` geschützt.

## Spätere Aktivierung

DeepL kann später aktiviert werden, indem im Provider-/Composition-Layer ein `DeepLTranslationClient` statt des `FakeTranslationClient` bereitgestellt wird.

Die Stelle dafür ist der lokale Translation-Provider. Importlogik, UI und `PendingTranslationProcessor` müssen dafür möglichst nicht direkt von DeepL abhängig werden.

## Tests

Der DeepL-Client ist durch Tests mit injiziertem Fake-HTTP-Client abgesichert.

Die Tests prüfen:

- korrekte URL und HTTP-Methode
- `Authorization`-Header
- JSON-Request mit `text`, `target_lang` und optional `source_lang`
- Mapping erfolgreicher DeepL-Antworten
- leeren API-Key
- API-Fehlerstatus
- ungültige JSON-Antworten
- Netzwerkfehler

## Bewusste Grenzen

- Keine automatische Online-Übersetzung.
- Kein echter API-Key im Repository.
- Keine Supabase-Änderung.
- Keine UI-Änderung.
- Kein produktiver DeepL-Default.
