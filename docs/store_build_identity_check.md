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
- `android/app/src/main/kotlin/com/talvori/talvori/MainActivity.kt`
- `android/app/src/main/java/com/talvori/talvori/plugins/AppGroupDirectoryPlugin.java`
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

- `com.talvori.talvori`

Zugehoerige iOS Identitaeten:

- Share Extension: `com.talvori.talvori.ShareExtension`
- RunnerTests: `com.talvori.talvori.RunnerTests`
- App Group: `group.com.talvori.talvori`
- URL Scheme: `talvori`
- Share URL Name: `com.talvori.talvori.share`

Bewertung:

- iOS App, Share Extension und App Group sind intern konsistent.
- Eine spaetere Bundle-ID-Aenderung muss App Group, Share Extension, Entitlements und ggf. Store-/Signing-Konfiguration gemeinsam beruecksichtigen.
- Keine automatische Aenderung wurde vorgenommen, weil unklar ist, ob `com.talvori.talvori` bereits fuer Apple Developer / App Store Connect reserviert oder verwendet wird.

## 4. Android Package Name

Aktueller Android Package Name / Application ID:

- `com.talvori.talvori`

Weitere Android-Werte:

- `namespace = "com.talvori.talvori"`
- Kotlin MainActivity package: `com.talvori.talvori`
- Java Plugin package: `com.talvori.talvori.plugins`
- App Label: `Talvori`

Bewertung:

- Android `applicationId`, `namespace` und Native Packages sind konsistent.
- In `android/app/build.gradle.kts` steht noch der Flutter-Template-Kommentar zur eigenen Application ID. Das ist nur Kommentartext, aber vor Store-Release sollte final entschieden werden, ob die aktuelle ID bleibt.
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
- Haupt-App-Identifier: `com.talvori.talvori`
- Version/Build: `1.0.0+1`
- Share-/Deep-Link-Schema: `talvori`

Abweichungen / Hinweise:

- Empfohlene Ziel-ID ist noch nicht entschieden: `com.talvori.talvori`, `com.talvori.app` oder `eu.talvori.app`.
- Android Release Signing ist noch nicht store-ready.
- Web-Metadaten sind lowercase `talvori`.
- iOS `CFBundleName` ist lowercase `talvori`, waehrend `CFBundleDisplayName` korrekt `Talvori` ist. Fuer den sichtbaren App-Namen ist `CFBundleDisplayName` entscheidend.

## 7. Empfohlene Zielwerte fuer MVP

Empfohlen:

- App-Name: `Talvori`
- Version: `1.0.0+1`
- URL Scheme: `talvori`

Bundle-/Package-ID-Optionen:

### Option A: `com.talvori.talvori` beibehalten

Vorteile:

- Bereits in iOS, Android, Share Extension, App Group und Native Packages konsistent verdrahtet.
- Weniger Risiko kurz vor MVP.
- Keine Paket-/Entitlements-/Native-Package-Umstellung noetig.

Nachteile:

- Redundant im Namen.
- Weniger elegant als `eu.talvori.app` oder `com.talvori.app`.

### Option B: `com.talvori.app`

Vorteile:

- International ueblich und klar.
- Weniger redundant.

Nachteile:

- Muss in iOS, Android, App Group, Share Extension, Native Packages, Signing und Store-Konfiguration sauber umgestellt werden.
- Kann von Store-/Developer-Account-Verfuegbarkeit abhaengen.

### Option C: `eu.talvori.app`

Vorteile:

- Passt sehr gut zur Domain `talvori.eu`.
- Wirkt fuer eine europaeische Marke konsistent.
- Ebenfalls weniger redundant.

Nachteile:

- Muss vollstaendig umgestellt werden.
- Etwas weniger klassisch als `com.*`, aber technisch voellig gueltig.

Empfehlung:

- Fuer den schnellsten MVP: `com.talvori.talvori` beibehalten, wenn diese ID im Apple/Google-Setup verfuegbar und gewollt ist.
- Fuer einen sauberen Marken-Neustart vor der ersten Store-Reservierung: `eu.talvori.app` bevorzugen, weil Domain und Marke zusammenpassen.
- Nicht ohne Store-/Developer-Account-Entscheidung automatisch aendern.

## 8. Plattformempfehlung

Empfohlenes Vorgehen:

1. Zuerst die Plattform priorisieren, die zuerst eingereicht werden soll.
2. Wenn iOS zuerst kommt: Apple Developer Team, Bundle ID, App Group, Share Extension und Signing final pruefen.
3. Wenn Android zuerst kommt: Application ID, Release Signing, Play Console App-Datensatz und Data Safety final pruefen.
4. Wenn beide kommen: zuerst eine gemeinsame finale Identifier-Entscheidung treffen, dann beide Plattformen konsistent setzen.

Aktueller Stand:

- Beide Plattformen sind technisch vorbereitet.
- iOS hat zusaetzliche Share-Extension-/App-Group-Abhaengigkeiten.
- Android braucht vor Store-Release zwingend eine echte Release-Signing-Konfiguration.

## 9. Risiken / Abweichungen

- Bundle ID / Package Name ist aktuell konsistent, aber noch nicht als finale Store-Entscheidung dokumentiert.
- Eine spaetere Identifier-Aenderung ist moeglich, aber wegen Share Extension und Native Packages nicht trivial.
- Android Release Signing nutzt aktuell Debug-Signing im Release-Build.
- Store-Reservierung, App Store Connect / Play Console, Altersfreigabe und Datenschutzangaben bleiben offen.
- App-Icon wurde in diesem Check nicht visuell geprueft.
- Screenshots wurden nicht erstellt.

## 10. Konkrete naechste Schritte

1. Entscheiden: `com.talvori.talvori` behalten oder vor Store-Reservierung auf `eu.talvori.app` / `com.talvori.app` umstellen.
2. Store-App-Datensatz fuer die erste Zielplattform anlegen oder pruefen.
3. iOS Signing/App Group/Share Extension gegen die finale Bundle ID pruefen.
4. Android Release Signing konfigurieren.
5. App-Icon final pruefen.
6. Danach finalen Release-Build erstellen und Device-Smoke-Test wiederholen.
