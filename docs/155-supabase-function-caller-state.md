# Supabase Function Caller State

## Ausgangslage

`SupabaseTranslationClient` nutzt eine injizierbare Function-Call-Schnittstelle. Dadurch kann die Translation-Architektur getestet werden, ohne echte Supabase- oder DeepL-Aufrufe auszuführen.

Dieser Stand ergänzt die Flutter-seitige Vorbereitung für einen echten Supabase Edge Function Call.

## Was vorbereitet wurde

Es gibt nun einen `SupabaseEdgeFunctionCaller`.

Der Caller:

- nutzt später den vorhandenen `SupabaseClient`
- ruft Supabase Edge Functions per Function-Name auf
- übergibt Payloads als `Map<String, Object?>`
- gibt Responses als `Map<String, Object?>` zurück
- kennt keine DeepL-Secrets
- enthält keine DeepL-spezifische Logik
- übersetzt ungültige Responses und Function-Fehler in kontrollierte `TranslationException`s

## Provider-Status

Der lokale Translation-Provider kann einen Supabase Function Caller bereitstellen, wenn Supabase im Projekt initialisiert ist.

`FakeTranslationClient` bleibt weiterhin Default. Der Supabase-Pfad wird nur relevant, wenn die Translation-Konfiguration explizit auf `supabase` gesetzt wird.

Ohne explizite Supabase-Konfiguration bleibt die App lokal/fake-basiert.

## Keine automatische Aktivierung

Es wurde keine automatische Übersetzung aktiviert:

- nicht beim Import
- nicht beim App-Start
- nicht im Hintergrund

Der bestehende manuelle Pending-/Retry-Pfad bleibt unverändert.

## Sicherheit

Der Flutter-Caller kennt keinen DeepL-Key und speichert keine Secrets. Der DeepL-Key bleibt für die spätere produktive Nutzung ausschließlich serverseitig in der Supabase Edge Function vorgesehen.

## Tests

Abgesichert ist:

- der Caller gibt Map-Responses zurück
- dynamische Map-Keys werden kontrolliert normalisiert
- ungültige Responses werden kontrolliert abgelehnt
- Function-Fehler werden kontrolliert gewrappt
- `SupabaseTranslationClient` bleibt mit Fake Function Caller testbar
- Provider bleibt defaultmäßig bei Fake
- Supabase-Modus kann mit injiziertem Function Caller einen `SupabaseTranslationClient` erzeugen

## Nächster Schritt

Als nächstes kann die produktive Verbindung zwischen `SupabaseTranslationClient` und der Edge Function `translate-word` in einer expliziten Runtime-Konfiguration aktiviert werden. Vorher müssen Auth, Rate Limits und Deployment-Setup final geprüft werden.
