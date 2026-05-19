# Local Edge Function Test Workflow

## Ziel

Dieser Workflow beschreibt, wie die Supabase Edge Function `translate-word` lokal getestet werden kann, ohne echte Secrets ins Repository zu schreiben.

Die Function liegt hier:

```text
supabase/functions/translate-word/index.ts
```

## Voraussetzungen

Supabase CLI muss lokal verfügbar sein:

```sh
supabase --version
```

Optional kann die lokale Supabase-Umgebung gestartet werden:

```sh
supabase start
```

Für den Test wird außerdem ein eigener DeepL-Key benötigt. Dieser Key darf nicht committed werden.

## Lokale Secrets

Lege lokal eine nicht versionierte `.env` im Projektroot an:

```sh
DEEPL_API_KEY=<DEEPL_API_KEY>
DEEPL_API_BASE_URL=https://api-free.deepl.com
```

Die Datei `.env` ist in `.gitignore` geschützt. `.env.example` enthält nur Platzhalter.

## Function lokal starten

Starte die Function mit lokaler Env-Datei:

```sh
supabase functions serve translate-word --env-file .env
```

Standardmäßig ist die Function danach hier erreichbar:

```text
http://localhost:54321/functions/v1/translate-word
```

## Test per Script

Für den schnellen lokalen Test gibt es:

```sh
sh supabase/scripts/test-translate-word-local.sh
```

Das Script:

- prüft, ob `DEEPL_API_KEY` lokal verfügbar ist
- schreibt keinen Key ins Repository
- sendet einen Testrequest für `house` von `EN` nach `DE`
- nutzt standardmäßig `http://localhost:54321/functions/v1/translate-word`

Falls die lokale Function unter einer anderen URL läuft:

```sh
TRANSLATE_WORD_LOCAL_URL=http://localhost:54321/functions/v1/translate-word \
  sh supabase/scripts/test-translate-word-local.sh
```

## Manueller curl-Test

Alternativ kann direkt mit `curl` getestet werden:

```sh
curl -i --request POST \
  --header "Content-Type: application/json" \
  --data '{"text":"house","sourceLang":"EN","targetLang":"DE"}' \
  http://localhost:54321/functions/v1/translate-word
```

Request:

```json
{
  "text": "house",
  "sourceLang": "EN",
  "targetLang": "DE"
}
```

## Erwartete Antworten

Erfolg:

```json
{
  "translation": "Haus"
}
```

Fehlender DeepL-Key:

```json
{
  "error": "translation_not_configured"
}
```

Ungültiger Body ohne Text:

```json
{
  "error": "text_required"
}
```

Ungültiger Body ohne Zielsprache:

```json
{
  "error": "target_lang_required"
}
```

DeepL- oder Netzwerkfehler:

```json
{
  "error": "translation_failed"
}
```

oder:

```json
{
  "error": "translation_request_failed"
}
```

## Häufige Fehler

### `DEEPL_API_KEY` fehlt

Die Function antwortet mit `translation_not_configured` oder das Testscript bricht vor dem Request ab.

Lösung: Key nur lokal in `.env` oder als Shell-Variable setzen.

### Function läuft nicht

`curl` kann `localhost:54321` nicht erreichen.

Lösung: `supabase functions serve translate-word --env-file .env` starten.

### Falsche Base URL

DeepL Free nutzt:

```text
https://api-free.deepl.com
```

DeepL Pro nutzt:

```text
https://api.deepl.com
```

Für lokale Tests sollte `DEEPL_API_BASE_URL` explizit in `.env` stehen.

### Ungültiger Body

Die Function erwartet mindestens:

```json
{
  "text": "house",
  "targetLang": "DE"
}
```

`sourceLang` ist optional.

## Sicherheit

- Kein echter DeepL-Key in Git.
- Kein Secret in Flutter.
- Keine Secrets in Doku oder Tests eintragen.
- `.env` lokal halten.
- `.env.example` nur mit Platzhaltern pflegen.

## Bezug zum Offline-Flow

Dieser Workflow testet nur die lokale Edge Function.

Talvori bleibt offline-first:

- lokale Wörter bleiben in SQLite
- pending/failed Status bleibt lokal
- Lernen funktioniert ohne Internet
- Übersetzung bleibt eine optionale Online-Ergänzung

## Nächster Schritt

Nach erfolgreichem lokalen Function-Test kann der Entwicklungsmodus aus `docs/159-translation-development-integration-flow-state.md` mit einer echten lokalen Supabase Function geprüft werden.
