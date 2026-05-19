# Translate Word Edge Function Setup

## Ausgangslage

Die Supabase Edge Function `translate-word` existiert unter:

```text
supabase/functions/translate-word/index.ts
```

Die Function nutzt DeepL serverseitig. Der DeepL-Key darf nicht ins Repository und nicht in den Flutter-Code gelangen.

Flutter-seitig ist `SupabaseTranslationClient` vorbereitet. Eine produktive Aktivierung ist noch nicht erfolgt.

## Benötigte Secrets

Pflicht:

```text
DEEPL_API_KEY=<DEEPL_API_KEY>
```

Optional:

```text
DEEPL_API_BASE_URL=https://api-free.deepl.com
```

Für DeepL Pro kann später eine andere Base URL gesetzt werden:

```text
DEEPL_API_BASE_URL=https://api.deepl.com
```

Diese Werte sind Platzhalter. Echte Keys dürfen nicht committed werden.

## Lokale Entwicklung

Supabase CLI prüfen:

```sh
supabase --version
```

Falls nötig Supabase lokal starten:

```sh
supabase start
```

Lokale Secrets nur in einer nicht committed `.env` bereitstellen:

```sh
DEEPL_API_KEY=<DEEPL_API_KEY>
DEEPL_API_BASE_URL=https://api-free.deepl.com
```

Die Function lokal starten:

```sh
supabase functions serve translate-word --env-file .env
```

## Beispiel-curl lokal

```sh
curl -i --request POST \
  --header "Content-Type: application/json" \
  --data '{"text":"house","sourceLang":"EN","targetLang":"DE"}' \
  http://localhost:54321/functions/v1/translate-word
```

Request Body:

```json
{
  "text": "house",
  "sourceLang": "EN",
  "targetLang": "DE"
}
```

## Deployment

Secret im Supabase-Projekt setzen:

```sh
supabase secrets set DEEPL_API_KEY=<DEEPL_API_KEY> --project-ref <SUPABASE_PROJECT_REF>
```

Optional Base URL setzen:

```sh
supabase secrets set DEEPL_API_BASE_URL=https://api-free.deepl.com --project-ref <SUPABASE_PROJECT_REF>
```

Function deployen:

```sh
supabase functions deploy translate-word --project-ref <SUPABASE_PROJECT_REF>
```

Nach dem Deploy mit Testrequest prüfen:

```sh
curl -i --request POST \
  --header "Authorization: Bearer <SUPABASE_ANON_KEY>" \
  --header "Content-Type: application/json" \
  --data '{"text":"house","sourceLang":"EN","targetLang":"DE"}' \
  https://<SUPABASE_PROJECT_REF>.supabase.co/functions/v1/translate-word
```

## Erwartete Responses

Erfolg:

```json
{
  "translation": "Haus"
}
```

DeepL-Fehler:

```json
{
  "error": "translation_failed"
}
```

Fehlender Key:

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

## Offene Produktionspunkte

Vor produktiver Aktivierung müssen ergänzt oder final entschieden werden:

- Authentifizierung prüfen
- Rate Limiting
- Premium- oder Nutzerlimits
- Missbrauchsschutz
- vorsichtiges Logging ohne sensible Texte oder Secrets
- Monitoring und Fehleranalyse
- spätere KI-Chatfunction nach gleichem Edge-Function-Muster

## Bezug zu Offline-first

Talvori bleibt offline-first. Ohne Internet bleiben Wörter lokal `pending` oder `failed`. Lernen und lokaler Fortschritt bleiben weiterhin möglich.

Übersetzung ist eine optionale Online-Ergänzung und darf den lokalen Lernflow nicht blockieren.
