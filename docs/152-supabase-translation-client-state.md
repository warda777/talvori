# Supabase Translation Client State

## Ausgangslage

Talvori soll produktive Übersetzungen später nicht direkt über DeepL aus der Flutter-App ausführen. Der DeepL-Key soll serverseitig geschützt bleiben und über eine Supabase Edge Function genutzt werden.

## Was vorbereitet wurde

Ein `SupabaseTranslationClient` wurde als Flutter-seitige `TranslationClient`-Implementierung vorbereitet.

Der Client:

- kennt keine DeepL-Secrets
- kennt keinen API-Key
- bereitet Requests für die spätere Edge Function `translate-word` vor
- sendet `text`, optional `sourceLang` und `targetLang`
- wertet erfolgreiche Responses mit `translation` aus
- übersetzt Fehlerantworten in kontrollierte `TranslationException`s

## Function-Call-Abstraktion

Der Client nutzt eine injizierbare `SupabaseFunctionCaller`-Schnittstelle. Dadurch können Tests Fake-Responses liefern, ohne Supabase aufzurufen.

Die spätere produktive Anbindung kann diese Schnittstelle mit einem echten Supabase Functions-Aufruf füllen.

## Provider-Status

`FakeTranslationClient` bleibt Default.

`LocalTranslationConfig` unterstützt nun auch den Modus `supabase`. Ein `SupabaseTranslationClient` wird nur erzeugt, wenn dieser Modus explizit gewählt wird und ein Function-Caller injiziert ist.

Ohne expliziten Caller fällt die Factory sicher auf `FakeTranslationClient` zurück.

## Bewusst nicht umgesetzt

- keine Supabase Edge Function
- kein Server-Code
- kein echter DeepL-Key
- kein API-Key in Flutter
- keine automatische Übersetzung beim Import
- keine automatische Übersetzung beim App-Start
- keine UI-Änderung

## Tests

Abgesichert ist:

- erfolgreicher Function-Call liefert eine Übersetzung
- Request enthält `text`, `sourceLang` und `targetLang`
- leere Source Language wird ausgelassen
- Fehlerantworten werden kontrolliert behandelt
- ungültige Responses werden kontrolliert behandelt
- Function-/Netzwerkfehler werden kontrolliert behandelt
- Provider bleibt standardmäßig bei Fake
- Supabase-Modus erzeugt nur explizit einen `SupabaseTranslationClient`

## Nächster Schritt

Als nächstes kann die Supabase Edge Function `translate-word` serverseitig geplant und implementiert werden. Danach kann ein echter Function-Caller in Flutter angebunden werden.
