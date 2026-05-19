# Local Translation Mode Switch State

## Ausgangslage

Talvori besitzt mehrere austauschbare Translation-Clients:

- `FakeTranslationClient`
- `DeepLTranslationClient`
- `SupabaseTranslationClient`

Produktiv soll die App später nicht direkt DeepL aufrufen. Für Entwicklung und Beta-Tests kann der Supabase-Pfad vorbereitet werden, ohne ihn automatisch zu aktivieren.

## Default bleibt Fake

Die zentrale Default-Konfiguration ist:

```dart
LocalTranslationConfig.defaultConfig
```

Sie entspricht `LocalTranslationConfig.fake()`.

Damit bleibt `FakeTranslationClient` weiterhin der Standard, solange keine explizite Runtime-Konfiguration gesetzt wird.

## Supabase nur explizit

Der Supabase-Modus ist über eine explizite Konfiguration vorbereitet:

```dart
LocalTranslationConfig.developmentSupabase()
```

Diese Konfiguration ist für Entwicklungs- und Beta-Tests gedacht. Sie enthält keinen API-Key und keine Secrets.

Ein `SupabaseTranslationClient` entsteht nur, wenn:

- der Modus explizit auf Supabase gesetzt wird
- ein Supabase Function Caller vorhanden ist

Ohne Function Caller fällt die Factory sicher auf `FakeTranslationClient` zurück.

## Keine UI

Es gibt keinen sichtbaren UI-Schalter für den Translation-Modus. Eine Aktivierung darf später nur kontrolliert über Entwicklungs- oder Runtime-Konfiguration erfolgen.

## Keine automatische Übersetzung

Es wurde keine automatische Verarbeitung aktiviert:

- nicht beim Import
- nicht beim App-Start
- nicht im Hintergrund

Der bestehende manuelle Pending-/Retry-Pfad bleibt unverändert.

## Kein Secret in Flutter

Der Supabase-Modus enthält keinen DeepL-Key. Secrets bleiben serverseitig in der Supabase Edge Function vorgesehen.

## Bezug zur Produktions-Checkliste

Vor produktiver Aktivierung gilt weiterhin `docs/156-translation-production-activation-checklist.md`.

Insbesondere müssen Auth, Rate Limits, Missbrauchsschutz und Deployment-Setup geprüft werden, bevor Supabase-basierte Übersetzung produktiv genutzt wird.

## Tests

Abgesichert ist:

- Default-Konfiguration ist Fake
- Fake-Factory liefert Fake-Konfiguration
- Supabase-Factory ist explizit
- Supabase ohne Function Caller fällt auf Fake zurück
- Supabase mit Function Caller erzeugt `SupabaseTranslationClient`
- keine echten Netzwerkaufrufe
