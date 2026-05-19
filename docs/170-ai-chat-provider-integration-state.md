# AI Chat Provider Integration State

## Ausgangslage

Talvori bleibt offline-first. Lokale Wörter, Lernfortschritt und SRS laufen lokal.

Die KI-Chatfunktion ist als Supabase Edge Function vorbereitet. Flutter kennt keine KI-Secrets und löst keine automatischen KI-Anfragen aus.

## Was neu ist

`supabase/functions/ai-chat` kann jetzt serverseitig einen OpenAI-kompatiblen Chat-Completions-Provider aufrufen.

Die Function akzeptiert:

- `message` als Pflichtfeld
- `context` optional
- `language` optional

Aus diesen Daten baut die Function serverseitig einen kontrollierten Sprachlern-Prompt.

## Server-Konfiguration

Die Provider-Anbindung nutzt ausschließlich serverseitige Environment Variables:

- `AI_PROVIDER`
- `AI_API_KEY`
- `AI_MODEL`
- optional `AI_BASE_URL`

Wenn `AI_BASE_URL` fehlt, wird ein OpenAI-kompatibler Default verwendet:

```text
https://api.openai.com/v1
```

Unterstützte Providerwerte:

- `openai`
- `openai_compatible`

Wenn Provider, Key oder Modell fehlen, antwortet die Function mit:

```json
{
  "error": "ai_not_configured"
}
```

Es wurde kein echter API-Key eingefügt.

## Request und Response

Die Function ruft serverseitig:

```text
POST /chat/completions
```

Erfolg:

```json
{
  "answer": "..."
}
```

Fehler:

```json
{
  "error": "ai_request_failed"
}
```

Limit:

```json
{
  "error": "quota_exceeded"
}
```

## Usage Tracking und Limits

Die Function nutzt die bestehende Usage-Grundlage mit:

```text
feature = ai_chat
```

Es gibt ein serverseitiges Tageslimit:

```text
AI_DAILY_REQUEST_LIMIT
```

Verhalten:

- nicht gesetzt: Dev-Default `1000`
- ungültig: Dev-Default `1000`
- `0`: sofort `quota_exceeded`
- erreichtes Limit: Provider wird nicht aufgerufen

Usage Events:

- `success` bei erfolgreicher KI-Antwort
- `failed` bei Provider-/Netzwerk-/Responsefehler
- `blocked` bei Limitüberschreitung

Aktuell ist die Limitierung noch global pro Tag. Vor Produktion muss sie auf echte Nutzeridentität und Premium-/Free-Limits umgestellt werden.

## Flutter-Kompatibilität

`SupabaseAiChatClient` parst jetzt die neue `answer`-Response.

Fehlercodes wie `ai_not_configured`, `quota_exceeded` und `ai_request_failed` werden kontrolliert als `AiChatException` behandelt.

Der Client kennt keine Secrets und bleibt mit Fake Function Callern testbar.

## Bewusst nicht umgesetzt

- keine produktive Endnutzer-UI
- keine automatische KI-Anfrage beim App-Start
- kein Hintergrundprozess
- kein Secret in Flutter
- keine lokale Offline-Logik geändert
- keine Änderung am Translation-Flow

## Nächster Schritt

Für einen echten Dev-Test:

1. `AI_PROVIDER` setzen, z. B. `openai`.
2. `AI_MODEL` setzen.
3. `AI_API_KEY` als Supabase Secret setzen.
4. Optional `AI_BASE_URL` setzen.
5. Function deployen.
6. Per curl testen.
7. Danach erst eine kontrollierte Dev-/Beta-UI planen.
