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

# 2) Mermaid → PNG rendern (höhere Skalierung für schärfere Ausgabe)
mmdc -i docs/erd.mmd -o docs/erd.png -c docs/mermaid-config.json --scale 6.0 -b transparent

# 2b) PNG -> PDF (für \includepdf), nur macOS
# Falls mmdc PDF direkt unterstützt, wird es überschrieben; sips ist zuverlässiger auf macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
  sips -s format pdf docs/erd.png --out docs/erd.pdf >/dev/null 2>&1 || {
    # Fallback: Versuche mmdc für PDF
    mmdc -i docs/erd.mmd -o docs/erd.pdf -c docs/mermaid-config.json --scale 6.0 -b transparent || true
  }
else
  # Nicht-macOS: Versuche mmdc direkt für PDF
  mmdc -i docs/erd.mmd -o docs/erd.pdf -c docs/mermaid-config.json --scale 6.0 -b transparent || {
    echo "⚠️  Warnung: PDF konnte nicht direkt generiert werden. PNG wird verwendet."
    # Erstelle ein Dummy-PDF falls nötig, oder skippe die PDF-Einbindung
    touch docs/erd.pdf
  }
fi

# Prüfe ob PDF existiert
if [[ ! -f docs/erd.pdf ]]; then
  echo "❌ Fehler: docs/erd.pdf konnte nicht erstellt werden"
  exit 1
fi



# 3) Gesamt-Markdown bauen (Titel + ERD-Bild + Data Dictionary)
{
  # Titel (Pandoc generiert die Titelseite via --metadata; hier optional)
  echo "# Talvori – Database Structure"
  echo
  # --- ERD als volle Seite (landscape, ohne Caption/Headers) ---
  # pagecommand={} entfernt Kopf-/Fußzeile auf dieser Seite
  # scale=0.85 begrenzt auf 85% der Seitengröße, damit es auf eine Standardseite passt
  echo "\\includepdf[pages=1,scale=0.85,landscape=true,pagecommand={}]{erd.pdf}"
  echo
  # Trennseite (optional)
  echo "\\clearpage"

  # --- Data Dictionary danach ---
  echo "# Talvori – Data Dictionary (public)"
  echo
  cat DATA_DICTIONARY.md
} > docs/Database_Structure.md

# Unicode-Pfeile ersetzen (PDF-Kompatibilität)
sed -i '' -e 's/↔/<->/g' -e 's/→/->/g' docs/Database_Structure.md

# 4) Markdown → PDF (kein raw_tex, kein landscape)
# Wechsle ins docs-Verzeichnis für Pandoc, damit alle Dateien (erd.pdf, latex-header.tex, etc.) relativ gefunden werden
cd docs
pandoc Database_Structure.md \
  --from=markdown+raw_tex+table_captions \
  --to=pdf \
  --pdf-engine=tectonic \
  --metadata=title:"Talvori Database Structure" \
  --metadata=author:"Andreas Warda" \
  --metadata=date:"$(date +%d.%m.%Y)" \
  --toc \
  --include-in-header=latex-header.tex \
  --include-in-header=pdf-style.tex \
  --resource-path=. \
  -o Database_Structure.pdf
cd ..


# macOS: PDF nach Erzeugung automatisch öffnen
if [[ "$OSTYPE" == "darwin"* ]]; then
  open docs/Database_Structure.pdf
fi


echo "✅ PDF erstellt: docs/Database_Structure.pdf"
