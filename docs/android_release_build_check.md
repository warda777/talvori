# Android Release-Build-Check

> Supersession notice: This document belongs to the old vocabulary-app MVP
> launch path. It is preserved as Foundation Build / future compliance
> material. The current public product direction is Talvori Welt; do not
> continue this as the next launch path without explicit decision.

Datum: 2026-05-30

Diese Notiz dokumentiert den erfolgreichen lokalen Android Release-Appbundle-Build fuer den Talvori-MVP. Es wurden keine Supabase-Daten, keine Imports, keine SQLite-/Vokabeldaten, keine SRS-Daten und kein `word_progress` geaendert. Es werden keine Secrets dokumentiert.

## 1. Build-Befehl

```bash
flutter build appbundle --release
```

## 2. Ergebnis

- Ergebnis: erfolgreich
- Erzeugte AAB-Datei: `build/app/outputs/bundle/release/app-release.aab`
- Build-Artefaktgroesse lokal: ca. 84 MB
- Android Application ID: `eu.talvori.app`
- Version: `1.0.0+1`

## 3. Signing-Status

- Der Build wurde lokal mit vorbereitetem Release-Keystore ausgefuehrt.
- `android/key.properties` bleibt lokal und ignored.
- `android/app/talvori-release-key.jks` bleibt lokal und ignored.
- Keine Passwoerter, Keys, Zertifikate oder Keystore-Inhalte wurden dokumentiert.
- Die `.aab`-Datei ist ein Build-Artefakt und darf nicht committed werden.

## 4. Behobene Release-Build-Blocker

- Der vorherige Kotlin-DSL-Fehler im Android Signing Setup wurde behoben.
- Der anschliessende Flutter Release-Build-Blocker durch dynamische `IconData(...)`-Erzeugung im WordHub-Override-Pfad wurde behoben.
- Material Icons werden im Release-Build wieder erfolgreich tree-shaken.

## 5. Offene naechste Schritte

- Google Play Console Application ID `eu.talvori.app` anlegen oder bestaetigen.
- Play Console Internal Testing Track fuer den ersten Store-Test vorbereiten.
- Data Safety Angaben mit dem tatsaechlichen App-Verhalten abgleichen.
- Finale Store-Metadaten und Screenshots gegen den Release-Build pruefen.
- Finalen Device-Test mit installierbarem Build durchfuehren.
- Keystore, `key.properties` und lokale Signing-Informationen weiterhin ausserhalb des Repos sichern.
