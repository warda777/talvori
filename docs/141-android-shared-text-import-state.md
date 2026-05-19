# Android Shared Text Import State

## 1. Ausgangslage

Ziel dieses Blocks war, markierte Wörter aus Browsern oder Websites über das Android-Teilen-Menü an Talvori zu senden. Der Import soll lokal und offline-first funktionieren und importierte Wörter in der lokalen Kategorie „Meine Wörter“ ablegen.

DeepL-Übersetzung und iOS Share Extension sind noch nicht Teil dieses Blocks.

## 2. Aktueller Android-Flow

Der aktuelle Flow:

Browser / Website
→ Wort markieren
→ Teilen
→ Talvori auswählen
→ Android Intent
→ MainActivity
→ Flutter Receiver
→ IncomingSharedTextImportController
→ SharedTextImportService
→ local-category-my-words
→ Meine Wörter

## 3. Android Native Teil

MainActivity empfängt geteilten Text sowohl beim Cold Start als auch beim Warm Start.

Zentrale Kanäle:

- `talvori/share`
- `talvori/share/events`

Das AndroidManifest behält die Share Intent Filter für:

- `ACTION_SEND`
- `ACTION_SEND_MULTIPLE`
- `text/plain`
- `text/*`

`launchMode="singleTask"` bleibt wichtig, damit ein Share in eine bereits laufende App sauber über `onNewIntent` gelangt.

## 4. Flutter Import-Pfad

Zentrale Bausteine:

- `SharedTextPlatformReceiver`
- `IncomingSharedTextImportController`
- `IncomingSharedTextImportListener`
- `SharedTextImportService`
- `sharedTextImportServiceProvider`

Der Importpfad nutzt die lokale SQLite-Datenbank und keine Supabase-Edge-Function.

## 5. Meine Wörter

Importierte Wörter landen in:

- `local-category-my-words`

Sichtbares Label:

- „Meine Wörter“

Der Category-Popup-Eintrag „Meine Wörter“ zeigt den lokalen Count und öffnet den `LocalWordListScreen`. Der manuelle Import-Screen kann nach erfolgreichem Import ebenfalls „Meine Wörter öffnen“.

## 6. Normalisierung

Der Import normalisiert geteilten Text vor dem Speichern:

- einzelne Wörter werden getrimmt und normalisiert
- Browser-Share-Texte mit URL oder Metadaten werden bereinigt, wenn ein eindeutiges Wort erkennbar ist
- einfache Randzeichen wie Anführungszeichen oder Satzzeichen werden entfernt
- Duplikate werden case-insensitive erkannt
- Mehrwort- oder Satztexte ohne eindeutigen Einzelwort-Kandidaten werden abgelehnt

## 7. Import-Ergebnisse / Benachrichtigung

Der lokale Import unterscheidet:

- Erfolg
- Duplikat
- ungültiger Text
- leere Eingabe
- Fehler

Android-Share-Importe zeigen eine kompakte Import-Benachrichtigung im Talvori-Dark-Neon-Stil. Bei Erfolg und Duplikat gibt es die Action „Meine Wörter öffnen“.

## 8. Bewusst nicht umgesetzt

Nicht umgesetzt in diesem Block:

- keine iOS Share Extension
- keine DeepL-Integration
- keine Supabase-Logik
- keine Übersetzungsautomatik
- keine Browser Extension
- keine Mehrwort-/Satzimport-Logik

## 9. Tests

Relevante Tests:

- `shared_text_import_service_test`
- `incoming_shared_text_import_controller_test`
- `shared_text_platform_receiver_test`
- `incoming_shared_text_import_listener_test`
- `local_word_count_provider_test`
- `local_words_for_category_provider_test`
- `category_popup_test`
- `local_shared_text_import_screen_test`

## 10. Manueller Test

Manueller Test auf Android-Gerät oder Emulator:

1. App installieren.
2. Browser öffnen.
3. Einzelnes Wort markieren.
4. Teilen öffnen.
5. Talvori auswählen.
6. Snackbar / Import-Benachrichtigung prüfen.
7. „Meine Wörter“ öffnen.
8. Prüfen, ob das Wort sichtbar ist.
9. Dasselbe Wort erneut teilen und Duplikatmeldung prüfen.

## 11. Bekannte offene Punkte

- DeepL-Übersetzung fehlt noch.
- iOS Share Extension fehlt noch.
- Übersetzungsstatus / Pending-Feld im lokalen Modell fehlt noch.
- Mehrwort- und Satzimport ist noch nicht final.
- API-Key-Sicherheit für DeepL muss separat geplant werden.

## 12. Nächster sinnvoller Schritt

Sinnvolle nächste Schritte:

- DeepL-Integration planen
- oder iOS Share Extension planen
- oder Übersetzungsstatus / Pending-Modell vorbereiten
