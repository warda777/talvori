# Tagesimpuls Local Notification Foundation State

## Ausgangslage

Tagesimpulse können über die Supabase Edge Function `generate-daily-impulses` erzeugt werden. Ein Tagesimpuls besteht intern aus:

- `slot`
- `message`
- `usedWords`

Das langfristige Produktziel bleibt eine Messenger-/WhatsApp-ähnliche Nachricht auf dem Sperrbildschirm. In diesem Schritt wurde die lokale Scheduling-Grundlage nutzerfreundlicher an eine selbstlaufende Einstellung angepasst.

## Selbstläufer-Logik

Der Tagesimpuls funktioniert als dauerhafte Einstellung:

- Standard ist `Automatisch`.
- Standard-Häufigkeit ist `1` Tagesimpuls pro Tag.
- Standard-Zeitfenster ist `Automatisch`.
- Nutzer kann jederzeit `Aus` wählen.
- Nutzer kann bewusst `1`, `2`, `3`, `4` oder `5` wählen.
- Nutzer kann ein bevorzugtes Zeitfenster wählen.
- Es gibt keinen zusätzlichen Speichern-/Planen-Button mehr.
- Änderungen werden direkt gespeichert und die lokale Planung wird ruhig aktualisiert, wenn genug Wörter vorhanden sind.
- Normale Änderungen an Häufigkeit oder Zeitfenster erzeugen keine Fehlersnackbar.

KI-Texte werden nicht als Vorschau angezeigt. Nutzer müssen nur zurückkehren, wenn Wörter, Häufigkeit, Zeitfenster oder Deaktivierung geändert werden sollen.

## Lokale Notification-Grundlage

Die lokale Notification-Schicht liegt unter:

- `lib/features/tagesimpuls/notifications/`

Sie enthält:

- `TagesimpulsNotificationSchedule`
- `TagesimpulsNotificationPlanningResult`
- `TagesimpulsNotificationScheduler`
- `FlutterLocalTagesimpulsNotificationScheduler`
- `TagesimpulsNotificationService`
- `TagesimpulsNotificationSettings`
- `TagesimpulsNotificationSettingsController`
- `SharedPreferencesTagesimpulsNotificationSettingsRepository`

Die echte Plugin-Anbindung liegt hinter einem Scheduler-Interface. Tests verwenden Fakes und lösen keine echten Platform Channels aus.

## iOS-Anbindung

Für iOS ist die lokale Notification-Anbindung technisch vorbereitet:

- `DarwinInitializationSettings` initialisiert die iOS-Seite des Plugins.
- iOS-Permissions werden nicht still beim Initialisieren angefragt, sondern explizit beim Planen über `requestPermissions(alert:badge:sound:)`.
- Die Permission-Anfrage fordert `alert`, `badge` und `sound` an.
- `DarwinNotificationDetails` setzt Foreground Presentation für Alert, Badge und Sound.
- `GeneratedPluginRegistrant` wird nicht zusätzlich im normalen App-Start aufgerufen, damit `AppLinksIosPlugin` nicht doppelt registriert wird.
- Der Notification-Service wird lazy genutzt und darf den App-Start nicht blockieren.

Damit kann `flutter_local_notifications` lokale iOS-Notifications initialisieren, Permission aktiv abfragen und planen, ohne den AppLinks-Duplicate-Key-Crash wieder einzubauen.

## Paket

Vorbereitet sind:

- `flutter_local_notifications`
- `timezone`

Damit kann lokal auf dem Gerät geplant werden, ohne Server-Push, APNs oder FCM zu nutzen.

## Nutzeraktion und Automatik

Es gibt keine automatische Planung beim Öffnen der App und keine automatische KI-Anfrage beim Hinzufügen eines Wortes.

Sobald der Nutzer in der Verwaltung Modus, Häufigkeit oder Zeitfenster ändert:

- die Einstellung wird gespeichert
- bei `Aus` werden geplante Tagesimpulse gelöscht
- bei `Automatisch` und mindestens 3 Wörtern werden KI-Impulse intern erzeugt
- lokale Notifications werden geplant
- es wird ein Status wie „Nächster Impuls: heute um 12:30 Uhr.“ angezeigt

Änderungen an der globalen Tagesimpuls-Wortauswahl werden separat live beobachtet. Wenn die Auswahl unter 3 Wörter fällt, erscheint der Status „Füge mindestens 3 Wörter hinzu.“ sofort. Wenn wieder mindestens 3 Wörter ausgewählt sind, wird dieser Hinweis sofort entfernt. Diese reine Status-Synchronisierung löst keine KI-Anfrage und keine neue Planung aus.

Header-Counter und Planungsbereich verwenden dieselbe globale Tagesimpuls-Auswahl. Der Planungsbereich hält keine eigene dauerhafte Kopie der ausgewählten Wörter. Beim echten Debug-Test „Tagesimpuls in 10 Sekunden testen“ wird die aktuelle Auswahl direkt aus dem globalen Provider gelesen, damit neu hinzugefügte Wörter ohne Zeitfensterwechsel verwendet werden.

Falls „Füge mindestens 3 Wörter hinzu.“ vorher als Fehlerstatus gespeichert wurde, wird diese alte Meldung beim Wechsel auf mindestens 3 Wörter ebenfalls entfernt. Damit bleibt kein stale `notEnoughWords`-Status im Planungsbereich stehen.

Die sichtbare Statusanzeige im Planungsbereich wird aus einer zentralen View-Logik abgeleitet. Sie liefert:

- `statusText`
- optionalen `secondaryText`
- Status-Schweregrad
- `canRunRealTenSecondTest`

Dadurch gibt es nicht mehr gleichzeitig mehrere konkurrierende Hinweise. Bei weniger als 3 Wörtern lautet der Status genau „Füge mindestens 3 Wörter hinzu.“; „Automatische Wortauswahl folgt später.“ ist nur noch ein optionaler Untertext derselben Statuskomponente.

Fehler beim Hintergrund-Scheduling werden nicht als Snackbar-Spam angezeigt. Sie erscheinen als ruhiger Status unter den Einstellungen.

Statusanzeige und Snackbar sind getrennt: Die Statusanzeige beschreibt den aktuellen Zustand. Wenn der Status eine Aktion bereits bestätigt, wird keine Snackbar mit demselben Inhalt gezeigt. Das gilt unter anderem für:

- „Test-Benachrichtigung geplant.“
- „Tagesimpuls ist ausgeschaltet.“
- „Tagesimpuls ist aktiv.“
- gespeicherte Einstellungsänderungen

Snackbars bleiben nur für kritische, einmalige Fälle vorgesehen, zum Beispiel wenn Permission bewusst abgelehnt wurde.

Wenn weniger als 3 Wörter ausgewählt sind, erscheint:

- „Füge mindestens 3 Wörter hinzu.“

Automatische Wortauswahl folgt später.

## Zeitfenster

Der Nutzer kann wählen:

- `Automatisch`
- `Morgens`
- `Mittags`
- `Nachmittags`
- `Abends`
- `Eigene Zeit`

Bei `Automatisch` nutzt Talvori die Slots der generierten Impulse oder sichere Fallback-Zeiten. Bei manuellem Zeitfenster werden mehrere Impulse in sinnvollen Abständen innerhalb dieses Fensters geplant. Nachtzeiten werden standardmäßig vermieden. Wenn ein Zeitpunkt für heute schon vorbei ist, wird auf den nächsten Tag geplant.

Bei `Eigene Zeit` wählt der Nutzer eine konkrete Uhrzeit über einen Time Picker. Die Uhrzeit wird lokal gespeichert und in der UI angezeigt, zum Beispiel:

- „Eigene Zeit: 12:07 Uhr“
- „Nächster Impuls: heute um 12:07 Uhr.“
- „Nächster Impuls: morgen um 12:07 Uhr.“, wenn die Uhrzeit heute bereits vorbei ist

Bei mehreren Tagesimpulsen wird die eigene Uhrzeit als Startzeit verwendet. Weitere Impulse werden in sinnvollem Abstand danach geplant, solange keine Nachtzeit entsteht.

Der echte Tagesimpuls-Pfad nutzt dieselbe lokale Notification-Schicht wie die technische Test-Benachrichtigung. Der Unterschied ist nur, dass Tagesimpulse vorher über `generate-daily-impulses` erzeugt und lokal im Impuls-Postfach gespeichert werden. Die Notification verwendet danach die generierte Nachricht als Body und eine Payload mit `chatId`/`messageId`.

Die geplanten Notifications verwenden:

- Titel: „Talvori Tagesimpuls“
- Body: generierte Tagesimpuls-Nachricht
- eindeutige, kleine lokale IDs pro Tag und Impuls in einem reservierten Tagesimpuls-Bereich
- Payload mit Impuls-Postfach-Kontext, wenn eine gespeicherte Nachricht vorhanden ist

Die geplanten Zeitpunkte werden im lokalen Tagesimpuls-State gehalten:

- `nextPlannedAt`
- `plannedTimes`
- `plannedCount`
- Anzeige-Status wie `active`, `off`, `needsWords`, `permissionDenied` oder `error`

Dadurch kann die UI konkrete Zeiten anzeigen, zum Beispiel:

- „Nächster Impuls: heute um 12:30 Uhr.“
- „Heute geplant: 12:30 · 16:00 · 19:15“
- „Nächster Impuls: morgen um 09:00 Uhr.“

Die aktuelle Umsetzung plant lokale Notifications auf dem Gerät. Nach erfolgreicher Planung kann iOS die Nachricht auch anzeigen, wenn die App geschlossen ist. Es gibt in diesem Schritt keinen Supabase Server-Push.

Abgelaufene geplante Zeiten werden nicht mehr als nächster Impuls angezeigt. Beim Öffnen des Tagesimpuls-Screens und beim Zurückkehren in die App werden gespeicherte `plannedTimes` gegen die aktuelle Uhrzeit geprüft. Zeiten, die kleiner oder gleich `now` sind, werden aus dem lokalen State entfernt. Wenn dadurch kein gültiger Zeitpunkt übrig bleibt und der Tagesimpuls aktiv ist, wird der Planungsstatus neu berechnet.

Zusätzlich kann die lokale Notification-Schicht die vom Betriebssystem registrierten Pending Notifications prüfen. Nach dem Scheduling werden Pending-Count und Pending-IDs diagnostiziert. Wenn lokal ein Zeitpunkt gespeichert ist, aber iOS keine passende Pending Notification mehr kennt, wird der lokale Status korrigiert und es wird keine abgelaufene Uhrzeit mehr als „Nächster Impuls“ angezeigt.

## Berechtigungen

Der Scheduler bereitet Permission-Anfragen vor:

- iOS über Darwin Notification Permissions
- Android über Notification Permission, soweit vom Plugin unterstützt

Android deklariert `POST_NOTIFICATIONS` für Android 13+.

Wenn die Berechtigung fehlt, zeigt der UI-Flow:

- als ruhigen Status „Benachrichtigungen sind nicht erlaubt.“
- bei bewusster Aktivierung zusätzlich „Benachrichtigungen müssen erlaubt werden.“

Wenn die Plattformkonfiguration noch nicht vollständig ist oder Scheduling fehlschlägt, wird kontrolliert angezeigt:

- „Benachrichtigungen konnten vom System nicht geplant werden.“
- „Tagesimpuls konnte nicht geplant werden.“, falls kein konkreterer Grund verfügbar ist

Für iOS muss im Gerätetest geprüft werden, ob der Permission-Dialog erscheint und ob lokale Notifications im Simulator/Gerät zugestellt werden. Wenn iOS weiterhin nicht plant, sind als nächste Punkte native Notification-Capabilities, Simulator-Berechtigungen und Plugin-Konfiguration zu prüfen.

Der Service unterscheidet strukturierte Planungsergebnisse:

- `scheduledSuccessfully`
- `scheduledButNoPendingNotification`
- `noPendingNotifications`
- `expiredScheduleRecomputed`
- `permissionGranted`
- `permissionDenied`
- `permissionNotRequested`
- `notificationServiceNotInitialized`
- `impulseGenerationFailed`
- `noGeneratedImpulses`
- `invalidScheduleTime`
- `timezoneNotInitialized`
- `schedulePlatformError`

Bei Plattformfehlern wird intern eine debugbare Fehlermeldung im Result gehalten und per Debug-Log ausgegeben, ohne die App abstürzen zu lassen. Wenn iOS-Permission bereits abgelehnt wurde, zeigt iOS keinen neuen Dialog; der Flow liefert dann `permissionDenied` und der Nutzer muss die Berechtigung in den iOS-Einstellungen wieder aktivieren.

Scheduling-Zeiten werden immer in die Zukunft geschoben. Wenn das gewählte Zeitfenster für heute vorbei ist, wird für morgen geplant.

## Technische Diagnose

Der Planungsflow gibt jetzt gezieltere Hinweise aus, damit iOS-Probleme getrennt geprüft werden können:

- `permissionDenied`: iOS hat Benachrichtigungen nicht erlaubt oder der Nutzer hat sie früher abgelehnt.
- `impulseGenerationFailed`: Die KI konnte keine Tagesimpulse erzeugen.
- `noGeneratedImpulses`: Es gibt keine erzeugten Impulse zum Planen.
- `invalidScheduleTime`: Ein geplanter Zeitpunkt wäre ungültig.
- `timezoneNotInitialized`: Die Zeitzonenbasis für `zonedSchedule` ist nicht bereit.
- `schedulePlatformError`: Das iOS-/Android-System oder das Plugin hat den Scheduling-Aufruf abgelehnt.
- `scheduledSuccessfully`: Mindestens eine lokale Notification wurde geplant.

Im Entwicklungsmodus loggt der Flow sicher:

- Anzahl ausgewählter Wörter
- Häufigkeit
- gewähltes Zeitfenster
- eigene Uhrzeit, falls `Eigene Zeit` aktiv ist
- Permission-Status
- Anzahl erzeugter Impulse
- Anzahl gespeicherter Postfach-Nachrichten
- geplante Notification-Zeitpunkte
- geplante Notification-IDs
- ob die Payload auf das Impuls-Postfach zeigt
- Scheduling-Result
- Anzahl pending Notifications nach dem Planen, soweit vom Plugin verfügbar
- Pending Notification IDs, soweit vom Plugin verfügbar
- Abgleich zwischen lokal gespeicherten Zeiten und tatsächlich pending Notifications

Es werden keine API-Keys, Secrets oder vollständigen KI-Prompts geloggt.

## Test-Benachrichtigung

Die Notification-IDs sind bewusst in getrennte Bereiche aufgeteilt:

- `900001`: technische Test-Benachrichtigung ohne KI
- `910000` bis `910099`: echte Tagesimpuls-10-Sekunden-Tests
- `920000` bis `920999`: regulär geplante Tagesimpulse

Reguläres Replanning und `Aus` löschen nur reguläre Tagesimpuls-IDs. Der echte 10-Sekunden-Test wird dadurch nicht mehr durch normale Custom-Time-/Tagesplan-Replanung entfernt. Ein explizites Debug-Löschen für Testbereiche kann später separat ergänzt werden.

Für die Geräte-Diagnose gibt es eine technische Testfunktion:

- `scheduleTestNotificationInTenSeconds()`
- Debug-Button: „Test in 10 Sekunden“
- Titel: „Talvori Test“
- Body: „Benachrichtigungen funktionieren.“
- Planung: `now + 10 Sekunden`

Diese Test-Benachrichtigung benötigt keine KI, keine ausgewählten Wörter und keinen Tagesimpuls-Plan. Damit lässt sich trennen, ob das lokale Notification-System grundsätzlich funktioniert oder ob der Fehler in KI-Generierung, Wortauswahl oder Tagesimpuls-Planung liegt.

Zusätzlich gibt es im Debug-/Dev-Modus eine echte Tagesimpuls-Testfunktion:

- Debug-Button: „Tagesimpuls in 10 Sekunden testen“
- zentrale Methode: `runRealTagesimpulsTestInTenSeconds`
- setzt sofort den Status „Tagesimpuls-Test wird vorbereitet...“
- nutzt die aktuelle globale Tagesimpuls-Wortauswahl
- ist nur bei mindestens 3 aktuell ausgewählten Wörtern aktiv
- ruft `generate-daily-impulses` über den normalen Flutter-Client auf
- speichert die erzeugte Nachricht im lokalen Impuls-Postfach
- baut eine JSON-Payload mit `type`, `chatId` und `messageId`
- plant die lokale Notification für `now + 10 Sekunden`
- prüft danach Pending-Count und Pending-IDs

Dieser Test nutzt nicht die technische Platzhalter-Nachricht. Er prüft den echten Tagesimpuls-Pfad bis zur lokalen Notification und unterscheidet dadurch KI-/Postfach-/Payload-Probleme von reinen iOS-Notification-Problemen.

Der echte 10-Sekunden-Test schreibt seine Zeit nicht in den regulären `plannedTimes`-State. Er setzt nur einen sichtbaren Status. Dadurch behandelt die Pending-Validierung den Test nicht mehr als normalen Tagesimpuls-Plan und startet danach keine automatische Custom-Time-Replanung.

Die Payload für Tagesimpuls-Notifications ist versionierbar strukturiert:

```json
{
  "type": "impulse_message",
  "chatId": "impulse-chat-daily-impulse",
  "messageId": "...",
  "source": "daily_impulse"
}
```

Beim Antippen einer Notification liest der Response-Handler diese Payload. `type = impulse_message` öffnet direkt das passende Impuls-Postfach-Chatdetail. Wenn die Payload fehlt, ungültig ist oder der Chat lokal nicht gefunden wird, fällt die App kontrolliert auf das Impuls-Postfach zurück. Der Tagesimpuls-Einstellungsbereich ist kein Fallback-Ziel mehr.

Der echte Test loggt sicher und ohne Secrets:

- `real 10s button tapped`
- aktuelle Wortanzahl und gekürzte Wortliste
- Start des `generate-daily-impulses`-Aufrufs
- Anzahl erzeugter Impulse
- gespeicherte Postfach-Nachrichten
- `chatId` und `messageId`
- ob der Notification-Body leer wäre
- geplanter Zeitpunkt
- lokale Notification-ID
- ob die Payload ins Impuls-Postfach zeigt
- Pending-Count nach dem Scheduling

Wenn ein Schritt fehlschlägt, wird der nächste Schritt nicht ausgeführt. KI-Fehler, Postfach-Speicherfehler und Notification-Scheduling-Fehler bekommen jeweils eigene sichtbare Statusmeldungen.

Wenn die Test-Benachrichtigung funktioniert, aber der normale Tagesimpuls nicht, liegt die Ursache typischerweise vor dem Scheduling:

- `generate-daily-impulses` nicht erreichbar
- Flutter ruft nicht exakt `generate-daily-impulses` auf
- der Supabase Function Caller ist im App-Flow nicht korrekt verdrahtet
- KI-Provider nicht konfiguriert
- Tagesimpuls-Limit erreicht
- KI-Antwort nicht parsebar
- keine Impulse in der Response
- weniger als 3 ausgewählte Wörter

Wenn die technische Test-Benachrichtigung funktioniert, aber die echte 10-Sekunden-Tagesimpuls-Benachrichtigung nicht, liegt die Ursache typischerweise im echten Tagesimpuls-Pfad:

- keine Impulse aus `generate-daily-impulses`
- erzeugte Nachricht leer
- Speichern im Impuls-Postfach fehlgeschlagen
- `chatId` oder `messageId` fehlt
- Payload ungültig oder zu groß
- geplante Zeit nicht in der Zukunft
- iOS registriert nach dem Scheduling keine Pending Notification mit der erwarteten ID

Die appseitigen Diagnosezustände für die KI-Generierung sind:

- `aiClientNotConfigured`
- `functionCallFailed`
- `quotaExceeded`
- `invalidAiResponse`
- `noImpulsesReturned`
- `notEnoughWords`
- `wordsRequired`
- `generationSucceeded`

Für die Notification-Diagnose wurden zusätzliche Statuswerte ergänzt:

- `realImpulseTestScheduled`
- `realImpulseTestDeliveredUnknown`
- `realImpulseScheduleFailed`
- `notificationPendingMissing`
- `notificationBodyEmpty`
- `notificationPayloadInvalid`
- `scheduledAtInPast`

Der Flutter-Client ruft für normale Tagesimpulse ausschließlich `generate-daily-impulses` auf. Der gemeinsame `SupabaseEdgeFunctionCaller` normalisiert JSON-Fehlerdetails aus Supabase `FunctionException`s, sodass Edge-Function-Fehler wie `quota_exceeded`, `ai_not_configured` oder `ai_invalid_response` nicht pauschal als `functionCallFailed` verschwinden.

Die Edge Function erwartet Tagesimpuls-Wörter im Format `words[].word`. Flutter sendet deshalb nicht den lokalen Selection-Key `text`, sondern baut vor dem Aufruf ein bereinigtes Payload-Format mit `word` und optional `translation`. Importreste wie URLs oder Zeilenumbrüche werden dabei entfernt, damit keine kompletten Quelltext-/URL-Fragmente an die KI gesendet werden. `words_required` war ein Payload-/Normalisierungsproblem und wird nun konkret als `wordsRequired` diagnostiziert.

Sichere Debug-Logs für diesen Pfad enthalten:

- Function-Name
- Payload-Keys
- Response-Keys
- Exception-Typ
- gekürzte Fehlermeldung
- Cancel-Grund
- gelöschter ID-Bereich
- Pending-IDs vor und nach Replanning

Side Effects bleiben aus dem `build()` heraus. Der Build rendert Status und Auswahl; Planung passiert nur über explizite Nutzeraktionen, Validierung beim Öffnen/Resume oder kontrollierte Recompute-Pfade. Nach einem echten 10-Sekunden-Test wird die automatische Validierung kurz übersprungen, damit die Testnotification bis zur Auslieferung pending bleibt.

## Notification-Tap-Routing

Tagesimpuls-Notifications werden fachlich dem Impuls-Postfach zugeordnet. Ein Tap auf eine Notification mit `impulse_message` Payload öffnet deshalb nicht den Tagesimpuls-Planungsbereich, sondern den passenden Impuls-Postfach-Chat.

Der Tap-Pfad ist:

- `flutter_local_notifications` liefert `onDidReceiveNotificationResponse`
- der Payload-Handler reicht die Payload an den Impuls-Postfach-Router weiter
- JSON-Payloads mit `type: impulse_message` werden nach `chatId` und `messageId` ausgewertet
- Legacy-Payloads im Format `impuls-postfach:<chatId>:<messageId>` bleiben lesbar
- ungültige Payloads fallen kontrolliert ins Impuls-Postfach zurück
- kein Fallback öffnet den Tagesimpuls-Screen

Für Cold-Starts wird die Navigation erst ausgeführt, wenn die App und der Navigator bereit sind. Payloads werden bis dahin zwischengespeichert und nach dem ersten stabilen Frame verarbeitet. Dadurch geht ein Notification-Tap während des App-Starts nicht verloren.

Der Notification-Payload-Handler wird bereits vor `runApp` registriert. Der lokale Notification-Scheduler nutzt eine gemeinsame idempotente Instanz, damit spätere Service-Aufrufe den Tap-Handler nicht durch eine zweite Initialisierung verlieren. Falls ein Launch-Payload vor der Handler-Registrierung eintrifft, wird er zwischengespeichert und nach der Registrierung verarbeitet.

Das sichtbare Routing läuft über den Root-Navigator. Für Notification-Ziele wird zuerst `pushAndRemoveUntil` bis zur ersten Route genutzt, dann wird das Impuls-Postfach geöffnet und bei `impulse_message` anschließend das Chatdetail darüber gelegt. Der fachliche Stack lautet damit:

- Home/root
- `ImpulsPostfachScreen`
- `ImpulseChatDetailScreen`

Dadurch können ein vorher sichtbarer Tagesimpuls-Screen, ein Dialog oder ein Bottom Sheet das Chatdetail nicht verdecken. Gleichzeitig führt Zurück aus dem Chatdetail zuerst ins Impuls-Postfach und Zurück aus dem Impuls-Postfach nach Home. Der Tagesimpuls-Screen bleibt kein Back-Ziel. Der Debug-State meldet für diesen Pfad `success_stack_home_inbox_chat_detail`.

Zusätzlich hält `NotificationTapDebugState` den letzten bekannten Tap-/Launch-Zustand:

- `lastTapReceivedAt`
- `lastPayloadRawPreview`
- `lastParsedType`
- `lastChatId`
- `lastMessageId`
- `lastRouteTarget`
- `lastRouteResult`
- `lastError`
- `launchDetailsCheckedAt`
- `didNotificationLaunchApp`

Der Debug-Bereich zeigt dadurch entweder „Noch kein Notification-Tap empfangen“ oder den zuletzt erkannten Payload-Typ. Damit ist im Gerätetest sichtbar, ob der iOS-Tap überhaupt in Flutter angekommen ist. Wenn der echte Tap keinen Debug-State setzt, liegt der Fehler vor dem Router im iOS/Plugin-Response-Pfad. Wenn der Debug-State `impulse_message` zeigt, aber die Navigation nicht öffnet, liegt der Fehler im Router/Navigator-Pfad.

Für die Diagnose gibt es im Debug-Bereich zwei manuelle Aktionen:

- „Letzte Notification-Payload öffnen“ führt den gespeicherten Payload erneut durch denselben Router.
- „Chat-Payload simulieren“ erzeugt eine interne `impulse_message` Payload und prüft damit den Router unabhängig von iOS.

Beim echten 10-Sekunden-Tagesimpuls-Test werden alte Testnotifications im ID-Bereich `910000-910099` vor dem neuen Test gezielt gelöscht. Reguläre Tagesimpulse und technische Testnotifications bleiben davon getrennt.

Die Tap-Diagnose loggt ohne Secrets:

- Payload-Länge und gekürzte Payload-Vorschau
- erkannten Payload-Typ
- ob `chatId` und `messageId` vorhanden sind
- Routing-Ziel
- Fallback-Grund bei ungültiger Payload

## One-Shot Scheduling im MVP

Für den MVP werden Tagesimpulse als konkrete lokale One-Shot Notifications geplant. Die Planung verwendet konkrete `DateTime`-Zeitpunkte und keine wiederkehrenden Kalendertrigger. Das macht `Eigene Zeit`, 10-Sekunden-Tests und Pending-ID-Diagnosen auf iOS zuverlässiger überprüfbar.

`Eigene Zeit` nutzt denselben Scheduling-Pfad wie die technische Test-Benachrichtigung und der echte 10-Sekunden-Tagesimpuls-Test. Vor dem Planen wird geprüft:

- `scheduledAt` liegt in der Zukunft
- Notification-Body ist nicht leer
- Payload ist vorhanden und nicht übermäßig groß
- Pending Notifications enthalten nach dem Planen die erwartete ID

Wenn die gewählte eigene Uhrzeit heute bereits vorbei ist, wird für morgen geplant. Für schnelle Gerätetests kann eine Uhrzeit 1-2 Minuten in der Zukunft gewählt werden.

Secrets, Supabase Tokens und vollständige Prompts werden nicht geloggt.

## App-Start und Logs

Der Notification-Service darf beim App-Start keine Permission-Abfrage und keine Planung auslösen. Permission wird erst beim aktiven Tagesimpuls-Planungsflow angefragt.

Supabase-URL, Anon-Key oder gekürzte Tokens dürfen nicht in Logs ausgegeben werden.

## Bewusst nicht umgesetzt

- Kein Server-Push
- Kein APNs
- Kein FCM
- Keine sichtbare KI-Vorschau
- Keine automatische Mehrfachbenachrichtigung
- Keine Supabase-Datenbank-Änderung
- Kein Secret in Flutter
- Keine SRS-Änderung

## Tests

Abgedeckt sind:

- Standard ist `Automatisch`.
- Standard-Häufigkeit ist `1`.
- Standard-Zeitfenster ist `Automatisch`.
- `Aus` löscht geplante Tagesimpuls-Benachrichtigungen.
- Auswahl `3` plant drei Benachrichtigungen nach Nutzerwahl.
- Manuelle Zeitfenster werden in Zeitpunkte übersetzt.
- Slots werden in Zeitpunkte übersetzt.
- `Eigene Zeit` wird gespeichert.
- `Eigene Zeit` plant heute, wenn die Uhrzeit noch kommt.
- `Eigene Zeit` plant morgen, wenn die Uhrzeit heute vorbei ist.
- Mehrere Impulse mit `Eigene Zeit` werden ab der gewählten Uhrzeit verteilt.
- Nachtzeiten werden vermieden.
- Fehlende Permission wird kontrolliert als Status angezeigt.
- Normale Einstellungsänderungen zeigen keine Fehlersnackbar.
- Plattformfehler werden als strukturierter Planungsstatus behandelt.
- Test-Benachrichtigung plant ohne KI und ohne Wörter.
- KI-Fehler und leere Impulse werden konkret angezeigt.
- Doppelte Snackbar/Status-Meldungen werden vermieden.
- Erfolgreiches Scheduling liefert den geplanten Zeitpunkt und optional Pending-Count.
- Pending-Count `0` nach Scheduling wird als eigener Status behandelt.
- Abgelaufene geplante Zeiten werden aus dem State entfernt.
- `nextPlannedAt` darf nicht in der Vergangenheit liegen.
- Geplante Tagesimpuls-Zeitpunkte werden im State gespeichert und in der UI angezeigt.
- Statusanzeige und Snackbars werden nicht mit identischem Text gedoppelt.
- KI-Texte werden nicht sichtbar als Vorschau angezeigt.
- Wortauswahl-Änderungen aktualisieren den Status ohne Zeitfensterwechsel.
- Wortauswahl-Änderungen lösen keine KI-Anfrage aus.
- Keine echten Platform Channel Calls in Tests.

## Nächster Schritt

Als nächstes sollte ein echter Gerätetest auf Android und iOS erfolgen. Danach kann eine separate Planung für automatische Wortauswahl, wiederkehrende lokale Tagesplanung oder späteren Server-Push über APNs/FCM entstehen.
