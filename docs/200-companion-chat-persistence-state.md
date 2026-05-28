# Companion-Chat-Persistenz: aktueller Stand

## 1. Ausgangsproblem

Der Home-Companion konnte bereits kurze Antworten anzeigen, aber der Verlauf war nur ein flüchtiger Home-Moment. Nach dem Schließen oder Wechseln in den Bereich `Talvori Chat` war nicht nachvollziehbar, was der Nutzer Tali gefragt hatte und was Tali geantwortet hat.

## 2. Ziel

Home und `Talvori Chat` sollen denselben Companion-Verlauf nutzen. Wenn der Nutzer im Home Screen mit Tali schreibt, werden User-Nachricht und Companion-Antwort im bestehenden Chat-Bereich gespeichert.

## 3. Name

Der feste Chat heißt:

- `Tali`

Die stabile Thread-ID ist:

- `talvori-companion`

## 4. Umsetzung

Der Companion-Thread ist zentral definiert in:

- `lib/features/companion/domain/companion_chat_constants.dart`

Die bestehende Chat-Persistenz wurde erweitert:

- `ImpulseInboxRepository.ensureCompanionChat()`
- `SharedPreferencesImpulseInboxRepository.ensureCompanionChat()`
- `ImpulseInboxController.ensureCompanionChat()`
- `ImpulseInboxController.addAiMessage(...)`

Der Home-Chat schreibt beim Senden:

1. User-Nachricht in den Companion-Thread.
2. Thinking-State im Home-Companion.
3. KI-/Fallback-Antwort in den Companion-Thread.
4. Antwort weiterhin in der Companion-Bubble.

Der Thread nutzt die vorhandene Chat-Struktur mit `customAi` als Source-Typ. Dadurch kann die bestehende Chat-Detail-UI den Verlauf anzeigen und über den vorhandenen `AiChatClient` weiterführen.

## 5. Was umgesetzt ist

- Fester Companion-Thread `talvori-companion`.
- Titel `Tali`.
- User-Nachrichten aus dem Home-Companion werden gespeichert.
- Companion-/AI-Antworten werden gespeichert.
- Speicherfehler werden abgefangen und crashen den Home-Chat nicht.
- Sobald Nachrichten existieren, erscheint der Companion-Thread in der Chatliste.
- Der Verlauf ist in `Talvori Chat` sichtbar.
- Die bestehende Chat-Detail-UI kann den Thread weiterverwenden.

## 6. Was bewusst noch offen ist

- Keine Supabase-Write-Integration.
- Keine Account- oder Cross-Device-Synchronisation.
- Keine separate Companion-Chat-Historie außerhalb von `Talvori Chat`.
- Keine spezielle Companion-Detail-UI.
- Keine dedizierte Konfliktauflösung, falls lokale Chatdaten gelöscht werden.

## 7. Tests

Ergänzt bzw. genutzt:

- Home-Companion-Chat speichert User- und AI-Nachricht im Companion-Thread.
- `Talvori Chat` zeigt `Tali`, sobald Nachrichten existieren.
- Das Chat-Detail zeigt User- und AI-Nachrichten aus demselben Thread.
- Bestehende Companion- und Home-Tests bleiben relevant.

## 8. Nächste Schritte

- Companion-spezifische Darstellung im Chat-Detail prüfen.
- Optional Tages-/Frequenzlogik für Companion-Hinweise mit Chatverlauf verbinden.
- Später Account-/Cloud-Sync nur nach sauberer Datenmodell-Prüfung.
- Später KI-Kontext aus dem gemeinsamen Verlauf gezielter zusammenstellen.
