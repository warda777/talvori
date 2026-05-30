# Store-/Build-Identitaetscheck

Stand: 2026-05-30

Dieser Check dokumentiert die technische Store-Identitaet der Talvori-App fuer den MVP. Es wurden keine Store-Einreichung, keine Supabase-Aenderung, kein Import, keine SQLite-/Vokabeldaten-Aenderung, keine SRS-Aenderung und keine UI-Aenderung vorgenommen.

## 1. Gepruefte Dateien

- `pubspec.yaml`
- `ios/Runner.xcodeproj/project.pbxproj`
- `ios/Runner/Info.plist`
- `ios/ShareExtension/Info.plist`
- `ios/Runner/Runner.entitlements`
- `ios/ShareExtension/ShareExtension.entitlements`
- `android/app/build.gradle.kts`
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/kotlin/eu/talvori/app/MainActivity.kt`
- `android/app/src/main/java/eu/talvori/app/plugins/AppGroupDirectoryPlugin.java`
- `web/manifest.json`
- `web/index.html`

## 2. Aktueller App-Name

- Store-/Produktname in Doku: `Talvori`
- Flutter package name in `pubspec.yaml`: `talvori`
- iOS Display Name: `Talvori`
- iOS `CFBundleName`: `talvori`
- Android App Label: `Talvori`
- Web Manifest/Title: `talvori`

Bewertung:

- Fuer iOS und Android ist der sichtbare App-Name jetzt konsistent `Talvori`.
- Der lowercase Flutter package name `talvori` ist technisch normal und kein Store-Problem.
- Web-Metadaten sind noch lowercase; fuer den mobilen MVP ist das kein Blocker, sollte aber vor einer Web/PWA-Veroeffentlichung auf `Talvori` angepasst werden.

## 3. iOS Bundle Identifier

Aktueller iOS App Bundle Identifier:

- `eu.talvori.app`

Zugehoerige iOS Identitaeten:

- Share Extension: `eu.talvori.app.ShareExtension`
- RunnerTests: `eu.talvori.app.RunnerTests`
- App Group: `group.eu.talvori.app`
- URL Scheme: `talvori`
- Share URL Name: `eu.talvori.app.share`

Bewertung:

- iOS App, Share Extension und App Group sind intern konsistent.
- Eine spaetere Bundle-ID-Aenderung muss App Group, Share Extension, Entitlements und ggf. Store-/Signing-Konfiguration gemeinsam beruecksichtigen.
- Die finale MVP-ID ist auf `eu.talvori.app` umgestellt. Die passende App ID und App Group muessen im Apple Developer Portal noch angelegt bzw. bestaetigt werden.

## 4. Android Package Name

Aktueller Android Package Name / Application ID:

- `eu.talvori.app`

Weitere Android-Werte:

- `namespace = "eu.talvori.app"`
- Kotlin MainActivity package: `eu.talvori.app`
- Java Plugin package: `eu.talvori.app.plugins`
- App Label: `Talvori`

Bewertung:

- Android `applicationId`, `namespace` und Native Packages sind konsistent.
- In `android/app/build.gradle.kts` steht noch der Flutter-Template-Kommentar zur eigenen Application ID. Das ist nur Kommentartext; die aktive ID ist final auf `eu.talvori.app` gesetzt.
- Android Release Signing ist noch auf Debug-Signing gesetzt. Das ist fuer lokale Release-Laeufe praktisch, aber fuer Play Store Release nicht ausreichend.

## 5. Version / Build Number

Aktueller Wert aus `pubspec.yaml`:

- Version: `1.0.0`
- Build Number: `1`
- Voller Flutter-Wert: `1.0.0+1`

iOS:

- `CFBundleShortVersionString = $(FLUTTER_BUILD_NAME)`
- `CFBundleVersion = $(FLUTTER_BUILD_NUMBER)`
- Runner Build Settings verwenden `$(FLUTTER_BUILD_NUMBER)`.

Android:

- `versionName = flutter.versionName`
- `versionCode = flutter.versionCode`

Bewertung:

- Flutter, iOS und Android leiten die Version konsistent aus `pubspec.yaml` ab.
- `1.0.0+1` ist als erster MVP-Release-Wert passend, wenn der Release wirklich als erste oeffentliche Version positioniert wird.

## 6. Konsistenz iOS / Android

Konsistent:

- Produktname sichtbar: `Talvori`
- Haupt-App-Identifier: `eu.talvori.app`
- Version/Build: `1.0.0+1`
- Share-/Deep-Link-Schema: `talvori`

Abweichungen / Hinweise:

- Finale Ziel-ID fuer den MVP: `eu.talvori.app`.
- Android Release Signing ist noch nicht store-ready.
- Web-Metadaten sind lowercase `talvori`.
- iOS `CFBundleName` ist lowercase `talvori`, waehrend `CFBundleDisplayName` korrekt `Talvori` ist. Fuer den sichtbaren App-Namen ist `CFBundleDisplayName` entscheidend.

## 7. Empfohlene Zielwerte fuer MVP

Empfohlen:

- App-Name: `Talvori`
- Version: `1.0.0+1`
- URL Scheme: `talvori`

Finale Bundle-/Package-ID:

### `eu.talvori.app`

Vorteile:

- Passt sehr gut zur Domain `talvori.eu`.
- Wirkt fuer eine europaeische Marke konsistent.
- Ist in iOS, Android, Share Extension, App Group und Native Packages konsistent verdrahtet.
- Vermeidet die alte redundante `com.talvori.talvori`-Struktur.

Empfehlung:

- `eu.talvori.app` als finale MVP-ID beibehalten.
- Vor Store-Einreichung die ID in Apple Developer / App Store Connect und Google Play Console passend reservieren bzw. bestaetigen.

## 8. Plattformempfehlung

Empfohlenes Vorgehen:

1. Zuerst die Plattform priorisieren, die zuerst eingereicht werden soll.
2. Wenn iOS zuerst kommt: Apple Developer Team, Bundle ID, App Group, Share Extension und Signing final pruefen.
3. Wenn Android zuerst kommt: Application ID, Release Signing, Play Console App-Datensatz und Data Safety final pruefen.
4. Wenn beide kommen: `eu.talvori.app` auf beiden Plattformen als gemeinsame finale Identifier-Struktur verwenden.

Aktueller Stand:

- Beide Plattformen sind technisch vorbereitet.
- iOS hat zusaetzliche Share-Extension-/App-Group-Abhaengigkeiten.
- Android braucht vor Store-Release zwingend eine echte Release-Signing-Konfiguration.

## 9. Risiken / Abweichungen

- Bundle ID / Package Name sind technisch auf `eu.talvori.app` umgestellt.
- Apple Developer App ID und App Group `group.eu.talvori.app` muessen im Developer Portal passend angelegt bzw. bestaetigt werden.
- Eine spaetere Identifier-Aenderung sollte vermieden werden, weil Share Extension, App Group und Native Packages betroffen sind.
- Android Release Signing nutzt aktuell Debug-Signing im Release-Build.
- Store-Reservierung, App Store Connect / Play Console, Altersfreigabe und Datenschutzangaben bleiben offen.
- App-Icon wurde in diesem Check nicht visuell geprueft.
- Screenshots wurden nicht erstellt.

## 10. Build-Check

Ausgefuehrte technische Checks:

- `flutter test`: bestanden
- `flutter build apk --debug`: bestanden
- `flutter build ios --debug --no-codesign`: bestanden
- `git diff --check`: sauber

Hinweis:

- Der erste Android-Buildlauf hat Core Library Desugaring fuer `flutter_local_notifications` verlangt. Die Android-Build-Konfiguration wurde entsprechend ergaenzt. Das ist eine Build-Konfigurationskorrektur und keine App-Logikaenderung.
- iOS wurde ohne Codesigning gebaut. Signing, Provisioning Profile, App ID und App Group muessen vor Geraete-/Store-Release im Apple Developer Portal final konfiguriert werden.

## 11. Konkrete naechste Schritte

1. Store-App-Datensatz fuer die erste Zielplattform mit `eu.talvori.app` anlegen oder pruefen.
2. iOS Signing/App Group/Share Extension gegen `eu.talvori.app` und `group.eu.talvori.app` pruefen.
3. Google Play Application ID `eu.talvori.app` bestaetigen.
4. Android Release Signing konfigurieren.
5. App-Icon final pruefen.
6. Danach finalen Release-Build erstellen und Device-Smoke-Test wiederholen.
