# AI Chat Edge Function Foundation State

## Ausgangslage

Talvori bleibt offline-first.

Lokale Wörter, Lernfortschritt und SRS laufen lokal. Online-Übersetzung läuft bereits über die Supabase Edge Function `translate-word`, wobei Secrets serverseitig bleiben.

Für eine spätere KI-Chatfunktion gilt dieselbe Sicherheitsregel: KI-API-Keys dürfen nicht in Flutter liegen.

## Was vorbereitet wurde

Es wurde eine neue Supabase Edge Function vorbereitet:

```text
supabase/functions/ai-chat/index.ts
```

Die Function verarbeitet:

- `OPTIONS`
- `POST`
- JSON Body
- `message` als Pflichtfeld
- optional `context`
- optional `language`

Sie gibt kontrollierte JSON-Fehler zurück und loggt keine Secrets.

## Fehlercodes

Vorbereitete Fehlercodes:

- `method_not_allowed`
- `invalid_json`
- `message_required`
- `ai_not_configured`
- `ai_request_failed`
- `quota_exceeded`

Wenn kein KI-Provider, kein Modell oder kein API-Key serverseitig konfiguriert ist, antwortet die Function mit:

```json
{
  "error": "ai_not_configured"
}
```

## Provider-Konfiguration

Die Function erwartet später serverseitige Runtime-Konfiguration:

- `AI_PROVIDER`
- `AI_API_KEY`
- `AI_MODEL`

Es wurde kein echter Key eingefügt.

Ein echter Provider-Aufruf ist bewusst noch nicht implementiert. Die Function markiert die Stelle, an der später Auth, Limits und Provider-Anbindung ergänzt werden müssen.

## Usage Tracking

Die Function bereitet Usage Tracking über die vorhandene Usage-Idee vor.

Als Feature-Wert ist vorgesehen:

```text
ai_chat
```

Aktuell wird keine produktive KI-Limitierung freigeschaltet. Vor Produktion muss entschieden werden, ob die bestehende `translation_usage_events` Tabelle langfristig allgemein genug bleibt oder ob eine eigene `ai_usage_events` bzw. allgemeine `usage_events` Tabelle entstehen soll.

## Flutter Client Skeleton

Flutter-seitig wurden vorbereitet:

- `AiChatClient`
- `AiChatRequest`
- `AiChatResult`
- `AiChatException`
- `SupabaseAiChatClient`

Der Client kennt keine Secrets und nutzt einen injizierbaren Function Caller. Dadurch bleiben Tests ohne echte Netzwerkaufrufe möglich.

## Keine produktive Endnutzerfunktion

Noch nicht umgesetzt:

- keine Endnutzer-UI
- kein automatischer KI-Aufruf
- kein Hintergrundprozess
- kein echter KI-Provider-Call
- kein Secret in Flutter
- keine Änderung am lokalen Lernflow

## Offline-First-Bezug

Der lokale Lernflow bleibt unabhängig von KI.

Wenn KI nicht konfiguriert ist oder offline nicht erreichbar ist, funktionieren lokale Wörter, SRS, Wortlisten und Übersetzungsstatus weiterhin.

## Nächster sinnvoller Schritt

Vor einer echten KI-Aktivierung:

1. KI-Anbieter auswählen.
2. API-Key als Supabase Secret setzen.
3. Auth und Rate Limits für `ai_chat` definieren.
4. Usage Tracking finalisieren.
5. Provider-Aufruf in `ai-chat` implementieren.
6. Erst danach eine kontrollierte Dev-/Beta-UI ergänzen.
