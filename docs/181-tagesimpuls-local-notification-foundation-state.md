# Tagesimpuls Local Notification Foundation State

## Ausgangslage

Tagesimpulse können über die Supabase Edge Function `generate-daily-impulses` erzeugt und im Flutter-Planungsflow als strukturierte Vorschau angezeigt werden. Ein Tagesimpuls besteht aus:

- `slot`
- `message`
- `usedWords`

Das langfristige Produktziel bleibt eine Messenger-/WhatsApp-ähnliche Nachricht auf dem Sperrbildschirm. In diesem Schritt wurde dafür nur die lokale Scheduling-Grundlage vorbereitet.

## Lokale Notification-Grundlage

Neu vorbereitet wurde eine lokale Notification-Schicht unter:

- `lib/features/tagesimpuls/notifications/`

Sie enthält:

- `TagesimpulsNotificationSchedule`
- `TagesimpulsNotificationPlanningResult`
- `TagesimpulsNotificationScheduler`
- `FlutterLocalTagesimpulsNotificationScheduler`
- `TagesimpulsNotificationService`

Die echte Plugin-Anbindung liegt hinter einem Scheduler-Interface. Tests verwenden Fakes und lösen keine echten Platform Channels aus.

## Paket

Als lokales Notification-Paket wurde vorbereitet:

- `flutter_local_notifications`
- `timezone`

Damit kann später lokal auf dem Gerät geplant werden, ohne Server-Push, APNs oder FCM zu benötigen.

## Nutzeraktion erforderlich

Notifications werden nicht automatisch geplant.

Der aktuelle UI-Flow zeigt den Button:

- „Benachrichtigungen planen“

Dieser Button erscheint erst, wenn generierte Tagesimpulse vorhanden sind. Die Planung passiert nur nach bewusstem Antippen durch den Nutzer.

Es gibt weiterhin:

- keine automatische Planung beim Generieren
- keine automatische Planung beim App-Start
- keine automatische KI-Anfrage
- keine Hintergrundgenerierung

## Slots und Zeitpunkte

Die erste Planungslogik übersetzt Slots in feste lokale Uhrzeiten:

- `morning` → 09:00
- `midday` / `noon` → 12:30
- `afternoon` → 14:00
- `evening` → 18:30

Unbekannte Slots fallen auf sichere Tageszeiten zurück. Nachtzeiten werden standardmäßig vermieden. Wenn ein Slot für heute schon vorbei ist, wird er auf den nächsten Tag geplant.

## Berechtigungen

Der Scheduler bereitet Permission-Anfragen vor:

- iOS über Darwin Notification Permissions
- Android über Notification Permission, soweit vom Plugin unterstützt

Wenn die Berechtigung fehlt, zeigt der UI-Flow:

- „Benachrichtigungen müssen erlaubt werden.“

## Bewusst nicht umgesetzt

- Kein Server-Push
- Kein APNs
- Kein FCM
- Keine produktive Notification-Strategie
- Keine automatische Planung
- Keine Supabase-Datenbank-Änderung
- Kein Secret in Flutter
- Keine SRS-Änderung

## Offene Plattformpunkte

Vor echter Geräteabnahme müssen iOS- und Android-Konfigurationen geprüft werden:

- iOS Notification Permissions und App Capabilities
- Android 13 Notification Permission
- Android Scheduling-Verhalten im Energiesparmodus
- App-Icon/Channel-Optik
- Verhalten bei Zeitzonenwechsel

## Tests

Abgedeckt sind:

- Service plant 1 Impuls.
- Service plant mehrere Impulse.
- Slots werden in Zeitpunkte übersetzt.
- Nachtzeiten werden vermieden.
- UI plant erst nach Nutzeraktion.
- Fehlende Permission wird kontrolliert angezeigt.
- Keine echten Platform Channel Calls in Tests.

## Nächster Schritt

Als nächstes sollte ein echter Gerätetest auf Android und iOS erfolgen. Danach kann eine separate Planung für wiederkehrende lokale Tagesplanung oder späteren Server-Push über APNs/FCM entstehen.
