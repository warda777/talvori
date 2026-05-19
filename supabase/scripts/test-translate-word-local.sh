#!/usr/bin/env sh
set -eu

FUNCTION_URL="${TRANSLATE_WORD_LOCAL_URL:-http://localhost:54321/functions/v1/translate-word}"

read_env_value() {
  key="$1"
  file="$2"
  if [ ! -f "$file" ]; then
    return 0
  fi
  grep -E "^${key}=" "$file" | tail -n 1 | cut -d '=' -f 2-
}

DEEPL_KEY="${DEEPL_API_KEY:-$(read_env_value DEEPL_API_KEY .env)}"

if [ -z "$DEEPL_KEY" ] || [ "$DEEPL_KEY" = "your_deepl_api_key_here" ]; then
  cat <<'MESSAGE'
DEEPL_API_KEY fehlt.

Lege lokal eine nicht versionierte .env an oder exportiere den Key nur fuer diese Shell:

  DEEPL_API_KEY=<DEEPL_API_KEY>

Starte danach die Function z. B. mit:

  supabase functions serve translate-word --env-file .env

Es wird kein echter Key ins Repository geschrieben.
MESSAGE
  exit 1
fi

echo "Teste translate-word lokal unter: $FUNCTION_URL"

curl -i --request POST \
  --header "Content-Type: application/json" \
  --data '{"text":"house","sourceLang":"EN","targetLang":"DE"}' \
  "$FUNCTION_URL"
