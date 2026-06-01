# Store-Signing-Setup-Plan

> Supersession notice: This document belongs to the old vocabulary-app MVP
> launch path. It is preserved as Foundation Build / future compliance
> material. The current public product direction is Talvori Welt; do not
> continue this as the next launch path without explicit decision.

Stand: 2026-05-30

Dieser Plan bereitet Apple Developer Signing/App Groups und Android Release Signing fuer den Talvori-MVP vor. Es wurden keine Store-Einreichung, keine echten Secrets, keine Keystore-Dateien, keine Provisioning Profiles, keine Supabase-Daten, keine Imports, keine SQLite-/Vokabeldaten und keine SRS-/`word_progress`-Daten geaendert.

## 1. Aktueller Identifier-Stand

- iOS App Bundle ID: `eu.talvori.app`
- iOS Share Extension Bundle ID: `eu.talvori.app.ShareExtension`
- iOS App Group: `group.eu.talvori.app`
- Android Application ID: `eu.talvori.app`
- Android Namespace: `eu.talvori.app`
- App-Name: `Talvori`
- Version: `1.0.0+1`

## 2. Android Release Signing

### Aktueller Befund

- `android/app/build.gradle.kts` war bisher fuer Release-Builds auf Debug-Signing gesetzt.
- `flutter_local_notifications` benoetigt Core Library Desugaring; das ist bereits in der Android-Build-Konfiguration aktiviert.
- Release Signing ist lokal vorbereitet. Ein lokaler Release-Appbundle-Build wurde erfolgreich ausgefuehrt und dokumentiert: `docs/android_release_build_check.md`.
- Der Release-Build-Blocker durch dynamische `IconData(...)`-Erzeugung wurde behoben; der AppBundle-Build laeuft erfolgreich durch.

### Vorbereitete Struktur

Die Android-Build-Konfiguration liest optional:

- `android/key.properties`

Wenn diese Datei existiert, nutzt der Release-Build die darin angegebenen Werte fuer den Release-Keystore. Wenn sie fehlt, bleibt der lokale Release-Build weiterhin mit Debug-Signing baubar. Fuer einen Store-Release muss `android/key.properties` lokal korrekt gesetzt sein.

Aktueller lokaler Build-Status:

- Build-Befehl: `flutter build appbundle --release`
- Ergebnis: erfolgreich
- AAB: `build/app/outputs/bundle/release/app-release.aab`
- Signing: lokal mit vorbereitetem Release-Keystore
- `android/key.properties` und `android/app/talvori-release-key.jks` bleiben ignored und duerfen nicht committed werden.

Sichere Beispiel-Datei:

- `android/key.properties.example`

Beispielinhalt ohne echte Secrets:

```properties
storePassword=CHANGE_ME
keyPassword=CHANGE_ME
keyAlias=talvori
storeFile=../app/talvori-release-key.jks
```

### Dateien, die nie committed werden duerfen

- `android/key.properties`
- `android/app/*.jks`
- `android/app/*.keystore`
- echte Passwoerter
- echte Keystore-Dateien
- Zertifikate oder private Keys

Diese Muster sind in `.gitignore` abgesichert.

### Android ToDos

1. Release-Keystore lokal erzeugen und sicher verwahren.
2. `android/key.properties` lokal aus `android/key.properties.example` ableiten.
3. Passwoerter nicht in Git, Chat, Doku oder Tickets schreiben.
4. `flutter build appbundle --release` vor Store-Upload erneut lokal mit echter Signing-Konfiguration testen.
5. Google Play Application ID `eu.talvori.app` bestaetigen.
6. Play App Signing / Upload Key Strategie festlegen.

## 3. iOS Signing, App ID und App Group

### Aktueller Befund

Die iOS-Projektdateien nutzen:

- Runner Bundle ID: `eu.talvori.app`
- Share Extension Bundle ID: `eu.talvori.app.ShareExtension`
- Runner Entitlement App Group: `group.eu.talvori.app`
- Share Extension Entitlement App Group: `group.eu.talvori.app`
- Xcode Signing Style: Automatic
- Development Team in Projektdatei: `QZT95PHR34`

### Apple Developer ToDos

1. App ID `eu.talvori.app` im Apple Developer Portal anlegen oder bestaetigen.
2. App ID `eu.talvori.app.ShareExtension` fuer die Share Extension anlegen oder bestaetigen.
3. App Group `group.eu.talvori.app` anlegen oder bestaetigen.
4. App Group fuer Haupt-App und Share Extension aktivieren.
5. Entitlements in Xcode gegen Developer Portal pruefen.
6. Provisioning Profiles fuer Debug/Profile/Release neu generieren oder automatisch durch Xcode verwalten lassen.
7. App Store Connect App-Datensatz mit Bundle ID `eu.talvori.app` anlegen.
8. Vor Device-/Store-Release echten iOS Build mit Codesigning pruefen.

## 4. Sicherheitsregeln

- Keine Keystore-Dateien committen.
- Keine `android/key.properties` committen.
- Keine Passwoerter, Zertifikate, private Keys oder Provisioning Profiles ins Repo legen.
- Keine echten Secrets in Markdown-Doku oder Tests schreiben.
- Lokale Signing-Dateien nur in sicherem Passwortmanager oder Secret-Speicher dokumentieren.
- Store-/Developer-Portale separat mit 2FA und rollenbasiertem Zugriff absichern.

## 5. Google Play ToDos

- Play Console App mit Application ID `eu.talvori.app` anlegen oder bestaetigen.
- App Signing Strategie entscheiden:
  - Google Play App Signing aktivieren.
  - Upload Key sicher erzeugen und verwahren.
- Release AAB lokal signiert bauen.
- Data Safety Angaben gegen tatsaechliches App-Verhalten pruefen.
- Internal Testing Track fuer ersten Release-Build nutzen.

## 6. Naechste Schritte

1. Apple Developer App IDs und App Group anlegen/bestaetigen.
2. Android Keystore lokal sichern und nicht committen.
3. `android/key.properties` lokal befuellt halten und nicht committen.
4. Erfolgreich erzeugtes AppBundle im Play Console Internal Testing Track pruefen.
5. iOS Build mit echtem Codesigning auf Geraet testen.
6. Store-Checkliste nach erfolgreichem Signing-Test aktualisieren.
