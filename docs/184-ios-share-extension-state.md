# 184 iOS Share Extension State

Stand: 2026-05-21

## Ziel

Talvori unterstützt jetzt neben Android auch iOS für den lokalen Share-Import:

- Text markieren
- Teilen öffnen
- Talvori wählen
- geteilten Text lokal an die App übergeben
- bestehenden Import-/Wortanlage-Flow verwenden

Der Flow bleibt offline-first. Es gibt keine Server-Synchronisation, keine Secrets, keinen Server-Push und keine SRS-Änderung.

## Architektur

Android nutzt weiterhin die bestehende native `MainActivity`:

- MethodChannel `talvori/share`
- EventChannel `talvori/share/events`
- `getInitialSharedText`
- laufende Shares über EventStream

iOS ist daran angeglichen:

- neues Share Extension Target `TalvoriShareExtension`
- App Group `group.com.talvori.talvori`
- Share Extension nimmt Plain Text und URLs an
- Extension schreibt eine Payload in App-Group-`UserDefaults`
- Payload enthält `id`, `text`, `createdAt`, `source` und `type`
- Runner liest die pending Payload über `talvori/share`
- Runner stellt `talvori/share/events` weiterhin bereit, pusht auf iOS aber keine Lifecycle-Events aktiv
- Flutter fragt beim App-Resume zusätzlich aktiv nach pending Payloads
- nach erfolgreichem Lesen wird die pending Payload gelöscht
- Flutter verarbeitet jede neue Payload-ID genau einmal
- derselbe Text darf erneut importiert werden, wenn er mit neuer Share-ID geteilt wurde

Damit bleibt der Importservice unverändert: `IncomingSharedTextImportListener` verarbeitet den Payload-Text wie auf Android, nutzt aber auf iOS die Share-ID als Wiederholbarkeits-/Duplikat-Schutz.

## iOS Details

Neue iOS-Dateien:

- `ios/ShareExtension/ShareViewController.swift`
- `ios/ShareExtension/Info.plist`
- `ios/ShareExtension/ShareExtension.entitlements`
- `ios/Runner/Runner.entitlements`

Runner und Share Extension teilen dieselbe App Group:

```text
group.com.talvori.talvori
```

Der Runner registriert zusätzlich das URL-Scheme:

```text
talvori://share
```

Die Extension nutzt das Scheme, um die Haupt-App nach dem Speichern der Payload zu öffnen. Der Runner liest die Payload beim Start über den MethodChannel. Flutter prüft zusätzlich bei `AppLifecycleState.resumed` per MethodChannel, damit kein Share verloren geht, wenn die App bereits läuft oder im Hintergrund war. iOS nutzt weiter den Flutter-eigenen `FlutterSceneDelegate`; eine eigene SceneDelegate ist nicht nötig und greift nicht in den Engine-Lifecycle ein. Wenn kein Share-Payload vorhanden ist, startet die App normal ohne Importdialog.

Mehrfaches Teilen ist abgedeckt:

- App geschlossen: initialer MethodChannel liest die pending Payload.
- App im Hintergrund: der Flutter-Resume-Pull prüft erneut auf pending Payload.
- App bereits geöffnet bzw. nach Vordergrundwechsel: der Resume-Pull liefert die neue Payload.
- identischer Text mit neuer Share-ID wird erneut verarbeitet.
- identische Share-ID wird in Flutter ignoriert, damit keine Doppelverarbeitung durch Lifecycle-Rennen entsteht.

## Einschränkungen

In diesem Schritt werden nur unterstützt:

- Plain Text
- URLs als Text

Nicht enthalten:

- Bilder
- Dateien
- OCR
- Cloud-Upload
- Supabase Storage
- Server-Push
- SRS-Schreibzugriffe

## Gerätetest

1. App auf einem iPhone installieren.
2. Safari, Notizen oder Mail öffnen.
3. Ein einzelnes Wort oder eine URL markieren.
4. Teilen öffnen.
5. Talvori auswählen.
6. Talvori öffnet sich.
7. Der bestehende Import-/Wortanlage-Flow erscheint.
8. Der geteilte Text wird angezeigt/importiert.
9. Einen zweiten, anderen Text teilen: Import erscheint erneut.
10. Denselben Text erneut teilen: Import wird erneut angestoßen, weil eine neue Share-ID geschrieben wird.
11. App schließen und normal starten: kein leerer Importdialog.
12. Dieselbe Share-ID wird nicht doppelt verarbeitet.

Android bleibt unverändert und nutzt weiter seine bestehende Intent-Bridge.
