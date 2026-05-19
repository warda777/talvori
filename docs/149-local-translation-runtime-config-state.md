# Local Translation Runtime Config State

## Ausgangslage

Die lokale Translation-Architektur besitzt bereits ein `TranslationClient`-Interface, einen `FakeTranslationClient`, einen vorbereiteten `DeepLTranslationClient` und den `PendingTranslationProcessor`.

Dieser Stand ergänzt die lokale Runtime-Konfiguration, ohne DeepL automatisch zu aktivieren.

## Runtime-Konfiguration

Die zentrale Konfiguration ist `LocalTranslationConfig`.

Sie bildet ab:

- Modus: `fake` oder `deepl`
- optionaler API-Key
- optionale Base-URL
- Zielsprache mit Default `DE`
- optionale Quellsprache

Die Spracheinstellungen werden normalisiert, damit spätere Clients mit stabilen Werten arbeiten können.

## Default-Verhalten

`FakeTranslationClient` bleibt der Default.

Ohne expliziten DeepL-Modus und gültigen API-Key wird kein `DeepLTranslationClient` erzeugt. Damit bleibt die lokale App ohne echte Online-Übersetzung sicher lauffähig.

## DeepL nur explizit

Ein `DeepLTranslationClient` kann nur entstehen, wenn:

- `LocalTranslationConfig` auf `deepl` steht
- ein nicht-leerer API-Key übergeben wird

Der API-Key wird nicht gespeichert und nicht hart im Code hinterlegt.

## Bewusste Grenzen

Es gibt weiterhin:

- keine UI für Translation-Einstellungen
- keinen echten API-Key im Repository
- keine automatische Übersetzung beim Import
- keine automatische Übersetzung beim App-Start
- keine Supabase-Änderung
- keine Online-Sync-Logik

## Tests

Abgesichert ist:

- Default-Konfiguration nutzt Fake
- DeepL ohne Key fällt sicher auf Fake zurück
- DeepL mit Test-Key erzeugt einen `DeepLTranslationClient`
- Runtime-Sprachen werden normalisiert
- `PendingTranslationProcessor` bleibt über den Provider injizierbar

## Nächster sinnvoller Schritt

Vor produktiver DeepL-Nutzung muss entschieden werden, wo der API-Key sicher zur Laufzeit herkommt. Mögliche nächste Schritte sind sichere lokale Speicherung nur für Entwicklung, eine geschützte Runtime-Konfiguration oder ein Backend-Proxy.
