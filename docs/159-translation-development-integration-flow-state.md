# Translation Development Integration Flow State

## Ausgangslage

Talvori besitzt eine lokale Translation-Architektur mit `TranslationClient`, `FakeTranslationClient`, `SupabaseTranslationClient`, `SupabaseEdgeFunctionCaller` und `PendingTranslationProcessor`.

Der lokale Import- und Lernflow bleibt offline-first. Importierte Wörter werden lokal gespeichert und behalten ihren Translation-Status in SQLite.

## Entwicklungs-Integrationsfluss

Für Entwicklungs- und Beta-Tests kann der manuelle Pending-/Retry-Pfad explizit mit Supabase verbunden werden.

Dafür gibt es einen zentralen lokalen Builder:

```dart
buildLocalTranslationProcessorForConfig(...)
```

Der Builder nimmt eine `LocalTranslationConfig`, ein lokales `WordRepository` und optional einen `SupabaseFunctionCaller` entgegen. Daraus wird ein `PendingTranslationProcessor` gebaut.

## Default bleibt Fake

Die normale App-Konfiguration bleibt unverändert:

```dart
LocalTranslationConfig.defaultConfig
```

Diese Konfiguration nutzt weiterhin den `FakeTranslationClient`.

Ohne explizite Supabase-Konfiguration und ohne Function Caller entsteht kein Supabase-Client.

## Supabase nur explizit

Supabase wird nur verwendet, wenn bewusst eine Supabase-Konfiguration gesetzt wird, z. B.:

```dart
LocalTranslationConfig.developmentSupabase()
```

Zusätzlich muss ein `SupabaseFunctionCaller` vorhanden sein. Fehlt dieser Caller, fällt der Flow sicher auf Fake zurück.

## Manueller Pending-/Retry-Pfad

Der bestehende manuelle Button in der lokalen Wortliste bleibt der Einstieg.

Der `LocalWordListScreen` kennt weiterhin keine Supabase-Details. Er ruft nur den injizierten Runner auf. Der Runner nutzt intern den konfigurierten `PendingTranslationProcessor`.

Damit kann derselbe manuelle Pfad in Entwicklung/Beta mit Supabase getestet werden, ohne separate UI-Logik einzubauen.

## Keine automatische Übersetzung

Es wurde keine automatische Verarbeitung aktiviert:

- nicht beim Import
- nicht beim App-Start
- nicht im Hintergrund
- nicht per Endnutzer-UI

Pending- und failed-Wörter werden nur verarbeitet, wenn der manuelle Flow gestartet wird.

## Keine Secrets in Flutter

Der Flutter-Code enthält keinen DeepL-Key und kein Secret.

Der Supabase-Client ruft nur die Edge Function auf. Der DeepL-Key bleibt weiterhin serverseitig für die Supabase Edge Function vorgesehen.

## Tests

Abgesichert ist:

- Default-Flow nutzt Fake
- Entwicklungs-Supabase-Flow nutzt `SupabaseTranslationClient` mit Fake Function Caller
- pending Wort wird über Supabase-Fake-Response zu `translated`
- failed Wort kann über Supabase-Fake-Response erneut verarbeitet werden
- Fehlerantwort der Function führt zu `failed` und keinem Crash
- lokale Wortliste bleibt im Fake-Default unverändert
- keine echten Netzwerkaufrufe
- keine Secrets nötig
- Import allein löst keine automatische Übersetzung aus

## Produktionsgrenze

Das ist keine produktive Aktivierung.

Vor Produktion gelten weiterhin:

- `docs/156-translation-production-activation-checklist.md`
- Edge Function Deployment prüfen
- Auth und Rate Limits ergänzen
- Missbrauchsschutz und Kostenkontrolle planen
- echte Supabase-Function-Tests mit Supabase CLI durchführen

## Nächster Schritt

Der nächste sinnvolle Schritt ist eine echte lokale Edge-Function-Testausführung mit Supabase CLI und Platzhalter-/Secret-Konfiguration außerhalb des Repositorys.
