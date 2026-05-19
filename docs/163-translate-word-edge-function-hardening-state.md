# Translate Word Edge Function Hardening State

## Ausgangslage

Die Supabase Edge Function `translate-word` ist deployed und wurde remote erfolgreich getestet.

Talvori nutzt weiterhin einen offline-first Flow:

- lokale Wörter bleiben in SQLite
- Translation-Status bleibt lokal
- Flutter enthält keine DeepL-Secrets
- Übersetzung wird nur manuell ausgelöst

## Gehärtete Fehlerfälle

Die Function gibt kontrollierte JSON-Fehler zurück:

```json
{
  "error": "..."
}
```

Abgesicherte Fehlercodes:

- `method_not_allowed`
- `invalid_json`
- `text_required`
- `target_lang_required`
- `translation_not_configured`
- `translation_failed`
- `translation_request_failed`
- `invalid_translation_response`

Die erfolgreiche Response bleibt kompatibel:

```json
{
  "translation": "Haus"
}
```

## Request-Validierung

Die Function erlaubt nur:

- `OPTIONS`
- `POST`

Der Body muss ein JSON-Objekt sein.

Pflichtfelder:

- `text`
- `targetLang`

Optional:

- `sourceLang`

Alle Sprachcodes werden getrimmt und großgeschrieben. `text` wird getrimmt.

## Textlimit

Für die produktionsnähere Absicherung ist ein maximales Textlimit gesetzt.

Zu lange Texte werden kontrolliert mit:

```json
{
  "error": "translation_failed",
  "reason": "text_too_long"
}
```

abgelehnt.

Das passt zum aktuellen Phase-1-Fokus auf einzelne Wörter und kurze Importtexte.

## Logging und Secrets

Die Function loggt keine Secrets.

Es werden keine vollständigen Nutzereingaben geloggt.

Der DeepL-Key wird ausschließlich über Supabase Secret / Environment Variable erwartet:

```text
DEEPL_API_KEY
```

Optional:

```text
DEEPL_API_BASE_URL
```

## Auth- und Rate-Limit-Vorbereitung

Noch nicht produktiv umgesetzt:

- Auth-Prüfung
- Nutzer-/Premiumlimits
- Rate Limiting
- Missbrauchsschutz
- Kostenkontrolle

Im Function-Code ist markiert, wo diese Prüfung vor einer echten Veröffentlichung ergänzt werden muss.

## Weiterhin bewusst nicht aktiviert

- keine automatische Übersetzung beim Import
- keine automatische Übersetzung beim App-Start
- keine Hintergrundverarbeitung
- keine Endnutzer-Produktiv-UI
- keine Supabase-Datenbank-Logik im Flutter-Offline-Flow

## Flutter-Kompatibilität

Der Flutter-Client bleibt kompatibel:

- Erfolg nutzt weiterhin `translation`
- Fehler nutzt weiterhin `error`
- zusätzliche Felder wie `reason` sind optional und brechen den bestehenden Client nicht

## Offene Produktionspunkte

Vor produktiver Freigabe müssen weiterhin erledigt werden:

- Auth/Entitlement finalisieren
- Rate Limits technisch umsetzen
- Premium-/Nutzerlimits definieren
- Monitoring ohne sensible Textlogs planen
- Kosten- und Missbrauchsschutz prüfen
- deployed Function mit Fehlerfällen manuell testen

## Testhinweise

Lokale Tests:

```sh
supabase functions serve translate-word --env-file .env
sh supabase/scripts/test-translate-word-local.sh
```

Flutter-Regression:

```sh
flutter test test/core/local_database/supabase_translation_client_test.dart
```

Ohne Internet oder bei Function-Fehlern bleiben lokale Wörter `pending` oder `failed`; der Lernflow bleibt lokal nutzbar.
