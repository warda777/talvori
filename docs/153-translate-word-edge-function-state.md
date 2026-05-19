# Translate Word Edge Function State

## Ausgangslage

Talvori soll produktive DeepL-Übersetzungen nicht direkt aus Flutter aufrufen. Der DeepL-Key soll serverseitig als Supabase Secret geschützt bleiben.

## Was vorbereitet wurde

Die Supabase Edge Function `translate-word` wurde vorbereitet:

```text
supabase/functions/translate-word/index.ts
```

Die Function akzeptiert `POST` Requests, liest JSON und ruft DeepL über `POST /v2/translate` auf.

## Request

```json
{
  "text": "house",
  "sourceLang": "EN",
  "targetLang": "DE"
}
```

`sourceLang` ist optional. `text` und `targetLang` sind Pflichtfelder.

## Response

Erfolg:

```json
{
  "translation": "Haus"
}
```

Fehler:

```json
{
  "error": "translation_failed"
}
```

## Secrets und Konfiguration

Der DeepL-Key wird über `DEEPL_API_KEY` erwartet. Die DeepL Base URL kann optional über `DEEPL_API_BASE_URL` gesetzt werden.

Default:

```text
https://api-free.deepl.com
```

Es wurde kein echter API-Key in das Repository eingefügt.

## Sicherheit

Die Function loggt keine Secrets. Fehlende Konfiguration, ungültige Requests, DeepL-Fehler und ungültige DeepL-Antworten werden kontrolliert als JSON-Fehler zurückgegeben.

Auth und Rate Limiting werden noch nicht erzwungen. Vor produktiver Aktivierung müssen ergänzt werden:

- Authentifizierung
- Rate Limiting
- Missbrauchsschutz
- Monitoring
- Logging ohne sensible Inhalte

## Flutter-Anbindung

Die Flutter-Seite ist über `SupabaseTranslationClient` vorbereitet. Dieser kann später die Edge Function `translate-word` ansprechen.

Aktuell bleibt `FakeTranslationClient` Default. Es wurde keine automatische Übersetzung aktiviert.

## Lokaler Test später

Beispielhafte lokale Ausführung:

```sh
supabase functions serve translate-word --env-file .env
```

Beispielhafter Request:

```sh
curl -i --request POST \
  --header "Content-Type: application/json" \
  --data '{"text":"house","sourceLang":"EN","targetLang":"DE"}' \
  http://localhost:54321/functions/v1/translate-word
```

Für produktive Nutzung müssen die Secrets in Supabase gesetzt werden, nicht im Flutter-Code.

## Bewusst nicht geändert

- keine Flutter-UI
- keine automatische Übersetzung
- keine lokale Offline-Logik
- kein echter API-Key
- keine produktive Aktivierung

## Nächster Schritt

Als nächstes kann ein echter Supabase Function Caller in Flutter geplant werden, der `SupabaseTranslationClient` mit der Edge Function verbindet. Danach müssen Auth und Rate-Limit-Konzept finalisiert werden.
