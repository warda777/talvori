# AI Chat Provider Debug Fix State

## Ausgangslage

Die Supabase Edge Function `ai-chat` war deployed und serverseitig konfiguriert:

- `AI_PROVIDER=openai`
- `AI_MODEL=gpt-4o-mini`
- `AI_BASE_URL=https://api.openai.com/v1`
- `AI_API_KEY` als Supabase Secret
- `AI_DAILY_REQUEST_LIMIT=1000`

Der Remote-Test lieferte jedoch nur:

```json
{
  "error": "ai_request_failed"
}
```

Die Provider-Fehlerdiagnose war zu grob, um im Supabase Dashboard den konkreten Fehler zu erkennen.

## OpenAI-kompatibler Endpoint

Die Function baut den Chat-Completions-Endpunkt jetzt defensiv:

```text
<AI_BASE_URL>/chat/completions
```

`AI_BASE_URL` wird normalisiert, damit ein abschließender Slash nicht zu falschen Pfaden führt.

Falls eine komplette URL bis `/chat/completions` konfiguriert wird, wird kein zweites `/chat/completions` angehängt.

Für OpenAI bleibt der erwartete Zielpfad:

```text
https://api.openai.com/v1/chat/completions
```

## Sichere Provider-Logs

Wenn der Provider nicht mit 2xx antwortet, loggt die Function jetzt nur sichere Metadaten:

- HTTP-Status
- `error.code`, falls vorhanden
- `error.type`, falls vorhanden

Nicht geloggt werden:

- `AI_API_KEY`
- vollständige Prompts
- vollständige Nutzereingaben
- vollständige Provider-Response-Texte

Beispiel:

```ts
console.error("AI provider request failed", {
  status: response.status,
  errorCode,
  errorType,
});
```

## Fehler-Mapping

Provider-Fehler werden kontrollierter nach außen gemappt:

- `401` / `403` -> `ai_auth_failed`
- `429` -> `ai_rate_limited`
- andere Providerfehler -> `ai_request_failed`

Zusätzlich kann ein kurzer `reason` zurückgegeben werden, z. B.:

```json
{
  "error": "ai_auth_failed",
  "reason": "provider_auth_failed"
}
```

Flutter bleibt kompatibel, weil der Client weiterhin auf das vorhandene `error`-Feld reagiert.

## Unveränderte Erfolgsantwort

Erfolg bleibt:

```json
{
  "answer": "..."
}
```

## Tests

Der Flutter-Client behandelt weiterhin kontrolliert:

- `ai_not_configured`
- `quota_exceeded`
- `ai_request_failed`
- `ai_auth_failed`
- `ai_rate_limited`

Die Tests nutzen Fake Function Caller und führen keine echten Netzwerkaufrufe aus.

## Nächster Remote-Test

Nach Deploy:

```sh
supabase functions deploy ai-chat
```

Danach:

```sh
curl -X POST "https://<SUPABASE_PROJECT_REF>.functions.supabase.co/ai-chat" \
  -H "Authorization: Bearer <SUPABASE_ANON_KEY>" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Erkläre mir das Wort house in einem kurzen deutschen Satz.",
    "language": "de"
  }'
```

Wenn weiterhin ein Fehler kommt, sollten die Supabase Function Logs jetzt Status, `errorCode` und `errorType` des Providers zeigen, ohne Secrets oder Prompts offenzulegen.
