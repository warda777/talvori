# Supabase Translation Development Mode State

## Ausgangslage

Talvori besitzt eine lokale Translation-Architektur mit austauschbarem `TranslationClient`.

Vorhanden sind:

- `FakeTranslationClient`
- `SupabaseTranslationClient`
- `SupabaseEdgeFunctionCaller`
- `PendingTranslationProcessor`
- manueller Pending-/Failed-Retry in der lokalen Wortliste

## Entwicklungs-/Beta-Modus

Der Supabase-Modus ist als expliziter Entwicklungs-/Beta-Modus aktivierbar.

Dafür existiert:

```dart
LocalTranslationConfig.developmentSupabase()
```

Zusätzlich gibt es eine zentrale Builder-Hilfe:

```dart
buildDevelopmentSupabaseTranslationClient(...)
```

Diese Stelle erzeugt einen `SupabaseTranslationClient` nur mit explizit übergebenem Function Caller.

## Default bleibt Fake

Der normale Default bleibt:

```dart
LocalTranslationConfig.defaultConfig
```

Diese Konfiguration entspricht weiterhin `LocalTranslationConfig.fake()`.

Ohne expliziten Override verwendet Talvori den `FakeTranslationClient`.

## Keine automatische Aktivierung

Der Supabase-Modus wird nicht automatisch aktiviert:

- nicht beim Import
- nicht beim App-Start
- nicht im Hintergrund
- nicht durch UI

Der bestehende manuelle Button für pending/failed Übersetzungen bleibt der einzige Verarbeitungspfad.

## Kein Secret in Flutter

Der Supabase-Entwicklungsmodus enthält keinen DeepL-Key und kein Secret.

Der spätere DeepL-Key bleibt serverseitig in der Supabase Edge Function vorgesehen.

## Manuelle Verarbeitung

Der `PendingTranslationProcessor` erhält weiterhin nur einen `TranslationClient`.

Wenn in Entwicklung/Beta explizit ein `SupabaseTranslationClient` injiziert wird, nutzt derselbe manuelle Pending-/Retry-Pfad die Supabase Edge Function. Es gibt keine separate UI-Logik für Supabase.

## Tests

Abgesichert ist:

- Default bleibt Fake
- Supabase ohne Function Caller fällt auf Fake zurück
- Supabase mit Function Caller erzeugt `SupabaseTranslationClient`
- zentrale Development-Builder-Hilfe erzeugt `SupabaseTranslationClient`
- Pending-Verarbeitung funktioniert mit `SupabaseTranslationClient`
- Failed-Retry funktioniert mit `SupabaseTranslationClient`
- keine echten Netzwerkaufrufe
- keine Secrets nötig

## Produktionsgrenze

Das ist keine produktive Aktivierung.

Vor Produktion gelten weiterhin:

- `docs/156-translation-production-activation-checklist.md`
- Auth prüfen
- Rate Limits einplanen
- Deployment und Secrets prüfen
- Missbrauchsschutz ergänzen
- Kostenkontrolle sicherstellen
