#!/usr/bin/env bash
set -euo pipefail

# Ordner vorbereiten
mkdir -p docs

# 1) Mermaid aus ERD.md extrahieren → .mmd
awk '
  /```mermaid/ {inblk=1; next}
  /```/ && inblk {inblk=0; next}
  inblk
' ERD.md > docs/erd.mmd

# 2) Mermaid → PNG rendern
mmdc -i docs/erd.mmd -o docs/erd.png -b transparent

# 3) Gesamt-Markdown bauen (Titel + ERD-Bild + Data Dictionary)
# 3) Gesamt-Markdown bauen (ohne raw TeX)
{
  echo "# Talvori – Database Structure"
  echo
  echo "![ERD](erd.png){ width=100% }"
  echo
  echo "---"
  echo
  cat DATA_DICTIONARY.md
} > docs/Database_Structure.md

# Unicode-Pfeile ersetzen (PDF-Kompatibilität)
sed -i '' -e 's/↔/<->/g' -e 's/→/->/g' docs/Database_Structure.md

# 4) Markdown → PDF (kein raw_tex, kein landscape)
pandoc docs/Database_Structure.md -o docs/Database_Structure.pdf \
  --from=gfm --pdf-engine=tectonic \
  --resource-path=docs --embed-resources \
  -H docs/pdf-style.tex \
  -V geometry:"margin=15mm" \
  -V papersize:a4 \
  -V title="Talvori Database Structure" \
  -V author="Andreas Warda" \
  -V date="$(date +'%d.%m.%Y')"




echo "✅ PDF erstellt: docs/Database_Structure.pdf"
