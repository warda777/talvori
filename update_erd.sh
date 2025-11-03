#!/usr/bin/env bash
set -euo pipefail

HOST='aws-1-eu-central-1.pooler.supabase.com'
PORT=5432
USER='postgres.naplllscmpqexahxtbwg'
DB='postgres'

# .env mit PGPASSWORD laden
if [ -f .env ]; then set -a; source .env; set +a; fi
: "${PGPASSWORD:?Set PGPASSWORD in .env}"

export PGSSLMODE=require
psql -h "$HOST" -p "$PORT" -U "$USER" -d "$DB" \
  -t -A -c "SELECT util.mermaid_public();" > ERD.md

echo "ERD.md aktualisiert."
