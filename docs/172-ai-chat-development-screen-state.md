# AI Chat Development Screen State

## Ausgangslage

Die Supabase Edge Function `ai-chat` ist deployed und der OpenAI-kompatible Provider wurde per curl erfolgreich getestet.

Flutter enthält weiterhin keine KI-Secrets. API-Keys liegen ausschließlich serverseitig als Supabase Secrets.

## Was neu ist

Es gibt eine interne Entwicklungsseite:

```text
AiChatDevScreen
```

Die Seite dient nur zum manuellen Testen der Edge Function aus der App heraus.

## Einstieg

Der Einstieg erfolgt über den bestehenden lokalen Debug-Hub:

```text
Lokaler Debug-Hub -> AI Chat Test
```

Damit ist die Seite kein normales Endnutzer-Feature.

## Funktionen

Die Seite bietet:

- Textfeld für eine Nachricht
- Sprache mit Default `DE`
- Button `KI testen`
- Ladezustand
- Antwortanzeige
- kontrollierte Fehleranzeige

Fehler werden verständlich gemappt:

- `ai_not_configured` -> `KI ist noch nicht konfiguriert.`
- `quota_exceeded` / `ai_rate_limited` -> `Limit erreicht oder Anbieter begrenzt Anfrage.`
- `ai_request_failed` / `ai_auth_failed` -> `KI-Anfrage fehlgeschlagen.`

## Client-Anbindung

Produktiv im Dev-Screen wird `SupabaseAiChatClient` über den vorhandenen Supabase Function Caller genutzt.

Tests injizieren einen Fake-Client, damit keine echten Netzwerkaufrufe stattfinden.

## Bewusst nicht umgesetzt

- keine produktive Endnutzer-UI
- keine automatische KI-Anfrage beim App-Start
- kein Hintergrundprozess
- kein Secret in Flutter
- keine Änderung an Offline-/SRS-Logik
- keine Änderung am Translation Flow

## Testablauf im Simulator

1. App im Debug-Modus starten.
2. Lokalen Debug-Hub öffnen.
3. `AI Chat Test` antippen.
4. Nachricht eingeben, z. B. `Erkläre mir das Wort house auf Deutsch.`
5. `KI testen` drücken.
6. Antwort oder Fehleranzeige prüfen.

## Nächster Schritt

Wenn der Dev-Test stabil ist, kann später eine echte Produkt-UX für Lernkontext geplant werden.

Vor einer Endnutzer-Freischaltung müssen Auth, Limits, Kostenkontrolle und Datenschutz final geklärt sein.
