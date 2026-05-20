# Impuls-Postfach MVP State

## Ausgangslage

Tagesimpulse werden lokal geplant und über `generate-daily-impulses` erzeugt. Notifications funktionieren lokal auf dem Gerät. Das Produktkonzept für ein Messenger-ähnliches Impuls-Postfach ist in `docs/182-impuls-postfach-category-chat-concept.md` dokumentiert.

## Was vorbereitet wurde

Das MVP ergänzt ein lokales Impuls-Postfach mit:

- Chatliste
- Tagesimpuls-Chat
- Chatdetail mit Sprechblasen
- lokal gespeicherten Impulsnachrichten
- ungelesenem Status
- vorbereiteter Notification-Payload mit `chatId` und `messageId`

Es wurde kein Server-Push, kein Supabase-Verlauf und keine Antwortfunktion eingebaut.

## Lokale Speicherung

Die Daten werden im MVP über `SharedPreferences` gespeichert und über ein Repository gekapselt:

- `ImpulseInboxRepository`
- `SharedPreferencesImpulseInboxRepository`

Diese Kapselung hält den Weg offen, später auf SQLite oder einen anderen lokalen Speicher umzuziehen.

## Datenmodelle

`ImpulseChat` enthält unter anderem:

- `id`
- `sourceType`
- `sourceId`
- `title`
- `avatarKey`
- `enabled`
- `createdAt`
- `lastMessageAt`
- `unreadCount`

`ImpulseMessage` enthält unter anderem:

- `id`
- `chatId`
- `text`
- `usedWords`
- `createdAt`
- `readAt`
- `source`
- `notificationId`
- `slot`

## Tagesimpuls-Chat

Wenn Tagesimpulse erzeugt und geplant werden, stellt die App sicher, dass der Tagesimpuls-Chat existiert. Die erzeugten Impulse werden als lokale Nachrichten gespeichert.

Die Nachrichten werden weiterhin nicht als Vorschau im Tagesimpuls-Planungsbereich angezeigt. Sie erscheinen im Impuls-Postfach.

Auch bei `Eigene Zeit` läuft der echte Tagesimpuls-Pfad über diesen Speicher:

- `ensureDailyImpulseChat()`
- generierte Tagesimpulse als `ImpulseMessage` speichern
- `unreadCount` erhöhen
- `lastMessageAt` aktualisieren
- `chatId` und `messageId` an die lokale Notification-Payload übergeben

Für die Geräte-Diagnose gibt es zusätzlich zum technischen Notification-Test einen echten Tagesimpuls-Test in 10 Sekunden. Dieser Test erzeugt die Nachricht über den normalen Tagesimpuls-AI-Client, speichert sie im Tagesimpuls-Chat und plant dann eine lokale Notification mit genau dieser gespeicherten Nachricht. Damit wird überprüft, dass nicht nur das iOS-Notification-System funktioniert, sondern auch der komplette Pfad:

- KI-Generierung
- lokales Speichern im Postfach
- Payload mit `chatId`/`messageId`
- lokale One-Shot Notification
- Pending-ID-Prüfung

Der echte Tagesimpuls-Test nutzt immer die aktuelle globale Tagesimpuls-Auswahl. Er ist erst aktiv, wenn mindestens 3 Wörter ausgewählt sind. Die technische Test-Benachrichtigung bleibt davon getrennt und verwendet weder KI noch Postfach.

Die App führt diesen echten Test über `runRealTagesimpulsTestInTenSeconds` aus. Der Flow setzt sofort einen sichtbaren Vorbereitungsstatus, speichert die erzeugte Nachricht im Tagesimpuls-Chat und verwendet die gespeicherte `messageId` für die Notification-Payload. Wenn das Speichern im Postfach fehlschlägt, wird keine Notification geplant.

Der echte 10-Sekunden-Test nutzt einen eigenen Notification-ID-Bereich (`910000` bis `910099`) und wird nicht in den regulären Tagesimpuls-Planungsstate (`plannedTimes`) geschrieben. Reguläres Replanning löscht nur reguläre IDs (`920000` bis `920999`) und kann dadurch keine gerade geplante echte Testnotification entfernen.

## Chatliste

`ImpulsPostfachScreen` zeigt:

- Titel „Impuls-Postfach“
- aktive Chats
- runden Avatar/Icon
- Chat-Titel
- letzte Nachricht
- Uhrzeit oder Datum
- ungelesen Badge
- leeren Zustand

Der Stil folgt Talvoris Dark-Neon-Look und kopiert keine externe Messenger-App 1:1.

## Chatdetail

`ImpulseChatDetailScreen` zeigt:

- Chat-Titel
- Nachrichten als Sprechblasen
- Datum/Uhrzeit
- verwendete Wörter als Chips

Beim Öffnen wird der Chat als gelesen markiert. Es gibt noch keine Texteingabe und keine Antwortfunktion.

## Notification-Payload

Geplante Tagesimpuls-Notifications erhalten eine strukturierte JSON-Payload:

```json
{
  "type": "impulse_message",
  "chatId": "impulse-chat-daily-impulse",
  "messageId": "...",
  "source": "daily_impulse"
}
```

Damit kann der Notification-Tap-Handler direkt den passenden Chat und die passende Nachricht öffnen. Falls die Payload unvollständig ist oder der Chat nicht gefunden wird, fällt die App kontrolliert ins Impuls-Postfach und navigiert nicht in den Tagesimpuls-Screen. Legacy-Payloads im alten Format `impuls-postfach:<chatId>:<messageId>` werden weiterhin tolerant gelesen.

Beim Öffnen des Chatdetails wird der Chat als gelesen markiert. Das reduziert den Ungelesen-Badge im Impuls-Postfach.

Der Notification-Router wartet bei Cold-Starts, bis der App-Navigator bereit ist. Dadurch wird eine Payload nicht mehr zu früh während des Init-/Splash-Zustands verarbeitet. Sobald die App bereit ist, wird der gespeicherte Tap in das Chatdetail oder bei ungültiger Payload ins Postfach weitergeleitet.

Die Notification-Initialisierung ist zentralisiert: Der Payload-Handler wird vor dem App-Start registriert und der lokale Notification-Scheduler initialisiert das Plugin idempotent. Dadurch kann ein Tagesimpuls-Tap nicht durch eine zweite Scheduler-Instanz oder ein zu frühes Launch-Payload verloren gehen.

Das sichtbare Öffnen läuft über den Root-Navigator. Bestehende Tagesimpuls-Routen, Dialoge oder Bottom Sheets werden per `pushAndRemoveUntil` bis zur ersten Route aus dem Weg geräumt. Danach baut der Router den fachlichen Messenger-Stack:

- Home/root
- `ImpulsPostfachScreen`
- `ImpulseChatDetailScreen`

Ein Log `routeSuccess=chat_detail` mit `navigationMethod=root_stack_inbox_then_detail` bedeutet damit, dass das Chatdetail als oberstes sichtbares Ziel geöffnet wurde und das Impuls-Postfach als Parent darunter liegt. Zurück aus dem Chatdetail führt ins Postfach, Zurück aus dem Postfach führt nach Home. Der Tagesimpuls-Bereich ist kein Back-Ziel für Impuls-Nachrichten.

Das Routing-Ziel für `impulse_message` ist immer:

- `ImpulseChatDetailScreen`, wenn der Chat vorhanden ist
- `ImpulsPostfachScreen`, wenn Payload, Chat oder Nachricht nicht sauber auflösbar sind

Der Tagesimpuls-Planungsbereich ist kein Fallback-Ziel für Impuls-Nachrichten.

Zur Tap-Diagnose gibt es einen kleinen globalen Debug-State. Er speichert den letzten Notification-Tap, eine gekürzte Payload-Vorschau, den geparsten Typ, `chatId`, `messageId`, das geplante Routing-Ziel, das Routing-Ergebnis und mögliche Fehler. Der Debug-Bereich kann dadurch anzeigen, ob noch kein Tap empfangen wurde oder ob zuletzt eine `impulse_message` Payload angekommen ist.

Zusätzlich sind zwei Debug-Aktionen vorbereitet:

- „Letzte Notification-Payload öffnen“ routet den zuletzt empfangenen Payload erneut.
- „Chat-Payload simulieren“ erzeugt eine lokale `impulse_message` Payload und öffnet damit den Router ohne iOS-Notification.

So lässt sich trennen, ob das lokale Scheduling funktioniert, ob iOS den Tap an Flutter übergibt und ob der Impuls-Postfach-Router korrekt zum Chatdetail navigiert.

Nach dem Scheduling wird diagnostiziert, ob iOS die erwartete Pending Notification kennt. Die Logs enthalten keine Secrets, aber sie zeigen für die Tagesimpuls-Planung unter anderem:

- Anzahl gespeicherter Nachrichten
- ob eine Inbox-Payload vorhanden ist
- geplante kleine Notification-ID
- Pending-Count
- Pending-IDs
- Payload-Länge
- Cancel-Grund und betroffener ID-Bereich bei Replanning

Der primäre Einstieg ins Impuls-Postfach liegt auf der Home-Seite. Der Button sitzt als sichtbares Chat-/Sprechblasen-Icon neben den Home-Quick-Actions und kann optional einen Ungelesen-Badge anzeigen.

## Bewusst nicht umgesetzt

- Kein Server-Push
- Kein APNs-/FCM-Ausbau
- Kein Supabase-Verlauf
- Kein Premium-Gating
- Kein freier Chat
- Keine Antwortfunktion
- Keine SRS-Änderung

## Tests

Abgedeckt sind:

- DailyImpulseChat wird automatisch erstellt.
- Nachrichten werden lokal gespeichert.
- Ungelesen-Count steigt beim Speichern.
- Chat öffnen markiert Nachrichten als gelesen.
- Chatliste zeigt letzte Nachricht.
- Chatdetail zeigt Sprechblasen und usedWords.
- Tagesimpuls-Planung speichert generierte Nachrichten im Postfach.
- Notification-Payload enthält `chatId` und `messageId`.

## Nächster Schritt

Als nächstes können Kategorie-Chats aktiviert und deaktiviert werden. Dafür braucht es eine lokale Aktivierungslogik pro Kategorie und später ein Sprechblasen-Icon auf Kategorie-Kacheln.
