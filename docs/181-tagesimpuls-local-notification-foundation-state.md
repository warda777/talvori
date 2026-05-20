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

Bei `Automatisch` nutzt Talvori die Slots der generierten Impulse oder sichere Fallback-Zeiten. Bei manuellem Zeitfenster werden mehrere Impulse in sinnvollen Abständen innerhalb dieses Fensters geplant. Nachtzeiten werden standardmäßig vermieden. Wenn ein Zeitpunkt für heute schon vorbei ist, wird auf den nächsten Tag geplant.

Die geplanten Notifications verwenden:

- Titel: „Talvori Tagesimpuls“
- Body: generierte Tagesimpuls-Nachricht
- eindeutige IDs pro Tag und Impuls
- Payload mit Tagesimpuls-Kontext

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
- Permission-Status
- Anzahl erzeugter Impulse
- geplante Notification-Zeitpunkte
- Scheduling-Result
- Anzahl pending Notifications nach dem Planen, soweit vom Plugin verfügbar

Es werden keine API-Keys, Secrets oder vollständigen KI-Prompts geloggt.

## Test-Benachrichtigung

Für die Geräte-Diagnose gibt es eine technische Testfunktion:

- `scheduleTestNotificationInTenSeconds()`
- Titel: „Talvori Test“
- Body: „Benachrichtigungen funktionieren.“
- Planung: `now + 10 Sekunden`

Diese Test-Benachrichtigung benötigt keine KI, keine ausgewählten Wörter und keinen Tagesimpuls-Plan. Damit lässt sich trennen, ob das lokale Notification-System grundsätzlich funktioniert oder ob der Fehler in KI-Generierung, Wortauswahl oder Tagesimpuls-Planung liegt.

Wenn die Test-Benachrichtigung funktioniert, aber der normale Tagesimpuls nicht, liegt die Ursache typischerweise vor dem Scheduling:

- `generate-daily-impulses` nicht erreichbar
- Flutter ruft nicht exakt `generate-daily-impulses` auf
- der Supabase Function Caller ist im App-Flow nicht korrekt verdrahtet
- KI-Provider nicht konfiguriert
- Tagesimpuls-Limit erreicht
- KI-Antwort nicht parsebar
- keine Impulse in der Response
- weniger als 3 ausgewählte Wörter

Die appseitigen Diagnosezustände für die KI-Generierung sind:

- `aiClientNotConfigured`
- `functionCallFailed`
- `quotaExceeded`
- `invalidAiResponse`
- `noImpulsesReturned`
- `notEnoughWords`
- `generationSucceeded`

Der Flutter-Client ruft für normale Tagesimpulse ausschließlich `generate-daily-impulses` auf. Der gemeinsame `SupabaseEdgeFunctionCaller` normalisiert JSON-Fehlerdetails aus Supabase `FunctionException`s, sodass Edge-Function-Fehler wie `quota_exceeded`, `ai_not_configured` oder `ai_invalid_response` nicht pauschal als `functionCallFailed` verschwinden.

Sichere Debug-Logs für diesen Pfad enthalten:

- Function-Name
- Payload-Keys
- Response-Keys
- Exception-Typ
- gekürzte Fehlermeldung

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
- Nachtzeiten werden vermieden.
- Fehlende Permission wird kontrolliert als Status angezeigt.
- Normale Einstellungsänderungen zeigen keine Fehlersnackbar.
- Plattformfehler werden als strukturierter Planungsstatus behandelt.
- Test-Benachrichtigung plant ohne KI und ohne Wörter.
- KI-Fehler und leere Impulse werden konkret angezeigt.
- Doppelte Snackbar/Status-Meldungen werden vermieden.
- Erfolgreiches Scheduling liefert den geplanten Zeitpunkt und optional Pending-Count.
- Geplante Tagesimpuls-Zeitpunkte werden im State gespeichert und in der UI angezeigt.
- Statusanzeige und Snackbars werden nicht mit identischem Text gedoppelt.
- KI-Texte werden nicht sichtbar als Vorschau angezeigt.
- Wortauswahl-Änderungen aktualisieren den Status ohne Zeitfensterwechsel.
- Wortauswahl-Änderungen lösen keine KI-Anfrage aus.
- Keine echten Platform Channel Calls in Tests.

## Nächster Schritt

Als nächstes sollte ein echter Gerätetest auf Android und iOS erfolgen. Danach kann eine separate Planung für automatische Wortauswahl, wiederkehrende lokale Tagesplanung oder späteren Server-Push über APNs/FCM entstehen.
