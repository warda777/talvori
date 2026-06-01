# Talvori Project Current State Summary

> Transition note: This summary captures the pre-transition Foundation Build
> state. The current public product direction is now Talvori Welt; use
> `docs/talvori_world_transition_plan.md` as the strategic continuation.

Stand: 2026-05-31

Diese Zusammenfassung beschreibt den aktuellen Stand der Talvori Flutter-App
als Uebergabe fuer spaetere Arbeitsbloecke. Sie ist eine Projekt- und
Release-Zusammenfassung. Es wurden keine Supabase-Daten, keine Imports, keine
SQLite-/Vokabeldaten, keine SRS- oder `word_progress`-Daten, keine UI und keine
App-Logik geaendert. Es werden keine Secrets, Keystore-Inhalte oder Passwoerter
dokumentiert.

## 1. Projektziel Von Talvori

Talvori ist eine Sprachlern-App mit Fokus auf Wortschatz, Wortwelten,
Wiederholung, Lernfortschritt und kurzen spielerischen Uebungen. Der erste MVP
soll eine stabile, lokale und ehrlich positionierte Lern-App zeigen, nicht die
vollstaendige langfristige Vision.

MVP-Fokus:

- Englisch -> Deutsch als erster gepruefter Content-Fokus
- App-Sprache, Muttersprache und Lernsprache verstaendlich einstellbar
- lokale Woerter, Wortwelten, Lernmodus und Lernfortschritt
- Wortspiele als unterstuetzende Lernform
- echte Legal-/Support-Links in der App
- kontrollierte Release-Sicherheit ohne unkontrollierte Remote-Imports

Bewusst noch nicht als fertig bewerben:

- vollstaendig gepruefter 13k-Wortbestand
- vollstaendige Spanisch-/Franzoesisch-Inhalte
- Cloud-Backup, Account-Sync oder Chat-Sync
- produktiver Content-Package-Sync aus Supabase
- TOEFL-/IELTS-/Cambridge-/Business-English-Pakete
- Premium/Abo
- fertiger Multiplayer oder Wort-Duell als Online-Funktion
- perfekte oder fehlerfreie KI-Antworten

## 2. Aktueller Release-Stand

Vorbereitet:

- Debug-/Developer-Zugaenge wurden release-sicherer eingeordnet.
- Legacy Supabase Words Auto-Sync ist im Release durch `ReleaseSyncPolicy`
  gegated.
- Supabase-Strategie, Content-Package-Strategie und Migrationsdesign sind
  dokumentiert.
- Zentrale Sprachcodes und kompatible Profil-Getter sind vorbereitet.
- Settings/Profile zeigen echte Legal-/Support-Verweise auf `talvori.eu`.
- Store-Metadaten-Draft, Screenshot-Shotlist und Data-Safety-Draft sind
  vorbereitet.
- Android Identifier sind auf `eu.talvori.app` umgestellt.
- Android Release Signing ist lokal vorbereitet.
- `flutter build appbundle --release` war erfolgreich.
- AAB: `build/app/outputs/bundle/release/app-release.aab`
- MVP-Content-Scope und Screenshot-Content-Auswahl sind vorbereitet.

Aktueller externer Stand:

- Google Play Developer Identitaetspruefung laeuft bzw. ist als naechster
  Store-Prozess beruecksichtigt.
- Store-Einreichung wurde noch nicht durchgefuehrt.

Oeffentlichen Release blockieren noch:

- finale juristische Pruefung von Datenschutz, AGB/Nutzungsbedingungen und
  Impressum
- finale Google-Play-Data-Safety-Angaben gegen den echten Build
- Google Play Console App/App-ID/Internal Testing Setup
- finaler installierter Release-Build-Test auf Geraet
- Debug-Sichtbarkeit im finalen Release-Build
- App-Icon final pruefen
- Store-Screenshots aus finalem Build erstellen
- sichtbaren MVP-Content weiter absichern, falls er in Startpfaden erscheint

## 3. Technische Architektur

Talvori ist eine Flutter-App mit lokaler Datenhaltung und vorbereitetem
Supabase-Backend.

Wichtige Bereiche:

- `lib/main.dart`: App-Bootstrap, Supabase-Initialisierung,
  Notification-Initialisierung, Debug-Routen und Legacy-Auto-Sync-Bootstrap.
- `lib/core/local_database/`: lokale SQLite/sqflite-Datenhaltung,
  Repositories, lokale Import-/Uebersetzungs- und Wortservices.
- `lib/core/sync/`: Release-Sync-Policy, Content-Package-Value-Objects,
  Sync-Policy, Taxonomie und Versionvergleich.
- `lib/core/language/`: zentrale Sprachcode-Struktur.
- `lib/features/home/`: Home, Settings, Profile, Course, Wortspiele,
  Data-Safety-relevante Einstiege wie Companion, Tagesimpuls und Share/Import.
- `lib/features/words/`: WordHub, Lernmodus, Wortlisten, lokale Woerter,
  Kategorien und Wortwelt-Ansichten.
- `lib/features/tagesimpuls/`: Impulse, AI-Generierung und Notifications.
- iOS/Android Native-Konfiguration: Bundle IDs, Share Extension, App Group,
  Android namespace/applicationId und Signing-Setup.

Lokale Datenhaltung:

- Woerter und Uebersetzungen
- Kategorien und Wortwelt-Memberships
- Lernstaende und `word_progress`
- bekannte/reviewte/favorisierte Woerter und lokale User-Flags
- Settings und Profilpraeferenzen
- lokale Import-/Share-/Uebersetzungspfade

Supabase:

- Supabase wird im App-Start initialisiert.
- Ein kleiner Kategorien-Read im Startpfad ist dokumentiert.
- Der alte wortanzahlbasierte Auto-Sync bleibt in Debug erlaubt.
- Im Release ist dieser Legacy-Auto-Sync standardmaessig deaktiviert.
- Es gibt keinen produktiven Nutzer-Cloud-Backup-/Account-Sync im MVP.
- Es gibt keinen unkontrollierten Remote-Content-Import beim Release-Start.
- Das Content-Package-System ist vorbereitet, aber nicht produktiv aktiv.

## 4. Daten- Und Sync-Architektur

Talvori trennt fachlich drei Datenarten:

- Content-Daten: Woerter, Uebersetzungen, Wortwelten, Level,
  Content-Pakete, Beispielsaetze und spaetere Paketmitgliedschaften.
- User-Daten: `word_progress`, SRS-Staende, Favoriten, bekannte Woerter,
  reviewte Woerter, eigene Woerter, Einstellungen, Streaks und spaetere Chats.
- System-/Review-Daten: Review-CSV, Working-Copies, Reports, Overlays,
  Store-/Release-Dokumentation.

Schutzregeln:

- Content-Sync darf `word_progress` nie ungefragt anfassen.
- SRS, Favoriten, bekannte Woerter und User-Flags duerfen nicht durch
  Content-Pakete ueberschrieben werden.
- Importmarker duerfen spaeter erst nach erfolgreicher Transaktion geschrieben
  werden.
- Konflikte sollen berichtet, nicht still korrigiert werden.
- Review-Overlays sind Entscheidungsvorbereitung, keine Produktivdaten.

Aktuelle Sync-Bausteine:

- `ReleaseSyncPolicy`: steuert den Legacy Supabase Words Auto-Sync. Debug ist
  erlaubt, Release ist ohne Override deaktiviert.
- `ContentPackageMetadata`: Value-Object fuer Paketmetadaten mit
  Sprachcodes, Version, Status, Checksum, Paketfamilie, Paketstufe,
  Pakettyp und Levelbereich.
- `ContentPackageImportMarker`: vorbereitetes lokales Marker-Modell fuer
  bereits importierte Pakete.
- `ContentPackageSyncPolicy`: entscheidet mit Begruendung, ob ein Paket
  importiert, uebersprungen oder blockiert werden soll.
- `ContentPackageTaxonomy`: normalisiert Paketfamilien und Spezialpakete wie
  `top_words`, `toefl`, `ielts`, `cambridge_english`,
  `business_english`, `grammar_syntax` und `phrases_idioms`.
- `VersionCompare`: kleiner semantischer Versionsvergleich.

Geplante spaetere Tabellen:

- `content_packages`: Paketdefinitionen mit Sprache, Version, Status,
  Checksum, Paketfamilie, Pakettyp, Stufe und Metadaten.
- `content_package_memberships`: Many-to-many-Zuordnung von Woertern zu
  Paketen, inklusive `rank` fuer Top-Wortschatz.
- `content_package_imports`: lokaler Importmarker fuer erfolgreich importierte
  Paketversionen.

Warum die Content-Package-Migration noch kein MVP-Blocker ist:

- Der erste MVP soll mit lokalem, geprueftem sichtbarem Minimalcontent starten.
- Supabase bleibt vorbereitet, aber ein kompletter Paket-Sync wuerde vor dem
  ersten Release mehr Risiko als Nutzen bringen.
- Das Migrationsdesign ist dokumentiert, aber eine DB-Migration soll erst nach
  finalem Remote-Paketformat, Review-Regeln und Konfliktstrategie erfolgen.

## 5. Spracharchitektur

Die zentrale Sprachgrundlage liegt in `lib/core/language/language_code.dart`.

Bausteine:

- `TalvoriLanguages`
- stabile Codes wie `de`, `en`, `es`, `fr`
- intern vorbereitete weitere Codes wie `zh`, `hi`, `ja`, `ru`, `ar`
- deutsche und englische Labels
- robuste Normalisierung von Codes und bekannten Labels
- `normalizeLanguagePair`, z. B. `Englisch-Deutsch` -> `en-de`

Profil-/Settings-Logik:

- `appLanguageCode`
- `nativeLanguageCode`
- `learningLanguageCode`
- `contentLanguagePair`

MVP-Fokus:

- Lernsprache: Englisch
- Muttersprache/Uebersetzungssprache: Deutsch
- Content-Paar: `en-de`

Spanisch und Franzoesisch sind als sichtbare MVP-Sprachlabels kompatibel
vorbereitet, aber nicht als vollstaendige Release-Inhalte freigegeben. Weitere
Sprachen sind intern vorbereitet, aber nicht produktiv beworben.

## 6. Vokabelreview-Architektur

Der Vokabelreview ist als sicherer, read-only-orientierter Workflow aufgebaut.
Er veraendert keine App-Datenbank, keine Supabase-Daten und keine produktiven
Vokabeldaten.

Vorhandene Strukturen:

- Master-Review-Template:
  `docs/word-review/vocabulary_review_template.csv`
- Workflow-Doku:
  `docs/vocabulary_review_workflow.md`
- Gap-Analyse:
  `docs/word-review/master_schema_gap_analysis.md`
- Master-Seed-Exporter:
  `tool/export_vocabulary_review_seed.dart`
- Seed-Analyse:
  `tool/analyze_vocabulary_review_seed.dart`
- Qualitaetsreport:
  `docs/word-review/vocabulary_review_seed_quality_report.md`
- Kandidatenlisten fuer leere Uebersetzungen, Dubletten,
  Bedeutungsvarianten und Strukturissues
- Working-Copy-Prinzip: `*_working.csv` bleibt ignored
- Validatoren fuer Review-Batches
- Overlay-Exporter fuer reviewte Entscheidungen

Grundprinzip:

- Rohdaten und Seed-Dateien werden nicht direkt fachlich korrigiert.
- Menschen tragen Entscheidungen in Working-Copies ein.
- Validatoren pruefen Header, Pflichtfelder, erlaubte Entscheidungen und
  Notizpflichten.
- Overlays enthalten nur Entscheidungen, keine Produktivkorrekturen.
- Produktivdaten werden erst spaeter durch einen separaten, sicheren Prozess
  geaendert.

Abgeschlossene Review-Bloecke:

- erster allgemeiner manueller Review-Batch mit 103 Entscheidungen
- Strukturreview fuer Level/Top-500/Wortwelten
- Top 500 als Paketfamilie geplant
- TOEFL/IELTS/Cambridge/Business/Grammar/Phrases als Spezialpakete geplant
- MVP-Content-Batch fuer Travel, Food & Cooking, Home & Living
- Screenshot-Content-Auswahl aus `approved_for_mvp`

## 7. Aktueller MVP-Content-Stand

Fokus:

- Englisch -> Deutsch
- kleiner, sichtbarer, gepruefter Kernbestand
- keine vollstaendige 13k-Freigabe
- keine vollstaendige Spanisch-/Franzoesisch-Bewerbung

Priorisierte Wortwelten:

- Travel
- Food & Cooking
- Home & Living

Erster MVP-Content-Batch:

- Datei: `docs/word-review/mvp_content_first_review_batch.csv`
- 150 Review-Zeilen plus Header
- 50 Travel
- 50 Food & Cooking
- 50 Home & Living

Review-Overlay:

- Datei: `docs/word-review/mvp_content_first_review_overlay.csv`
- 150 Entscheidungen plus Header

Review-Ergebnis:

| Entscheidung | Anzahl |
| --- | ---: |
| `approved_for_mvp` | 115 |
| `fix_translation_later` | 24 |
| `reject_for_mvp` | 6 |
| `move_out_of_mvp` | 3 |
| `needs_context` | 2 |

Screenshot-Auswahl:

- Datei: `docs/word-review/mvp_screenshot_content_selection.csv`
- 51 Zeilen plus Header
- 11 Travel
- 20 Food & Cooking
- 20 Home & Living

Regel:

- Nur `approved_for_mvp` darf fuer Screenshots, Store-Material und
  Startcontent-Auswahl genutzt werden.
- `fix_translation_later`, `needs_context`, `reject_for_mvp` und
  `move_out_of_mvp` duerfen nicht in Screenshots erscheinen.

## 8. Store-/Legal-/Support-Stand

Festgelegte Domain und Kontakte:

- Domain: `talvori.eu`
- Datenschutz: `https://talvori.eu/privacy/`
- Nutzungsbedingungen: `https://talvori.eu/terms/`
- Impressum: `https://talvori.eu/imprint/`
- Support: `https://talvori.eu/support/`
- Support-Mail: `support@talvori.eu`
- Legal-Mail: `legal@talvori.eu`

App-Stand:

- Settings/Profile sind auf echte Links und Kontakte verdrahtet.
- Externe Links nutzen das vorhandene Link-Oeffnungs-/URL-Launcher-Muster.
- Feedback nutzt `mailto:support@talvori.eu`.
- Keine finalen juristischen Texte werden in der App dupliziert.

Offen:

- finale juristische Pruefung der Datenschutz-, AGB-/Terms- und
  Impressumsinhalte
- finaler Abgleich zwischen Datenschutztext, Data-Safety-Angaben und
  tatsaechlichem Release-Build

## 9. Store-Screenshots Und Store-Metadaten

Vorhanden:

- Store-Metadaten-Draft: `docs/store_metadata_draft.md`
- Nicht-bewerben-Liste im Store-Draft
- Screenshot-Shotlist: `docs/store_screenshot_shotlist.md`
- Wortzuordnung je Screen:
  `docs/word-review/mvp_screenshot_words_by_screen.csv`
- Screenshot-Content-Auswahl:
  `docs/word-review/mvp_screenshot_content_selection.csv`

Geplante Screenshots:

- Onboarding / erster Eindruck
- Home
- Wortwelten
- Lernmodus
- Wortspiele
- Settings / Datenschutz / Support

Companion/Impuls:

- optional, aber eher nicht fuer den ersten Store-Durchlauf, solange
  Data-Safety, KI-Kommunikation und Screenshot-Wirkung nicht final geprueft
  sind.

No-Gos fuer Store-Screenshots:

- Wort-Duell als fertiger Multiplayer
- Premium/Abo
- Cloud-Backup oder Account-Sync
- TOEFL/IELTS/Cambridge
- Debug-/Developer-Screens
- ungepruefte Woerter
- Spanisch-/Franzoesisch-Inhalte als fertige Release-Inhalte
- AI/Companion als rein lokal oder fehlerfrei darstellen

## 10. Build-/Signing-Stand

Finale technische IDs:

- App-Name: `Talvori`
- iOS Bundle ID: `eu.talvori.app`
- iOS Share Extension: `eu.talvori.app.ShareExtension`
- iOS App Group: `group.eu.talvori.app`
- Android Application ID: `eu.talvori.app`
- Android Namespace: `eu.talvori.app`
- Android Native Package: `eu.talvori.app`
- Android Plugin Package: `eu.talvori.app.plugins`
- URL Scheme: `talvori`
- Version: `1.0.0+1`

Android:

- Android Release Signing ist lokal vorbereitet.
- `android/key.properties` bleibt lokal und ignored.
- `android/app/talvori-release-key.jks` bleibt lokal und ignored.
- Es werden keine Secrets dokumentiert.
- `flutter build appbundle --release` war erfolgreich.
- AAB: `build/app/outputs/bundle/release/app-release.aab`
- `.aab` ist Build-Artefakt und darf nicht committed werden.

iOS:

- Bundle ID, Share Extension und App Group sind in Projektdateien umgestellt.
- iOS Codesigning und App Group muessen im Apple Developer Portal noch final
  angelegt bzw. bestaetigt werden.
- Share Extension Signing muss vor Store-/Device-Release final geprueft werden.

## 11. Datenschutz / Data Safety

Vorhanden:

- Data-Safety-Draft: `docs/google_play_data_safety_draft.md`
- technische Entscheidungsmatrix:
  `docs/mvp_data_safety_decision_matrix.md`

Aktive lokale Daten:

- lokale Lernstaende und `word_progress`
- lokale Woerter und Wortwelten
- bekannte Woerter und Favoriten
- App-, Sprach- und Onboarding-Praeferenzen

Aktive oder optionale externe Pfade:

- Support-Mail nur bei aktiver Nutzerkontaktaufnahme
- Legal-/Support-Weblinks beim Oeffnen im Browser
- Supabase-Initialisierung und kleiner Kategorien-Read im Startpfad
- AI/Companion ueber Supabase Edge Function `ai-chat`, wenn Nutzer KI-/Chat-
  Pfade nutzt
- Tagesimpuls mit lokaler Notification und optionaler externer
  Impuls-Generierung
- Translation-Edge-Function fuer ausstehende/eigene Woerter, wenn ausgelöst
- Browser-/Share-Import als nutzerinitiierter Pfad
- Voice/Audio/Foto im Chat als optionale, final zu pruefende Pfade

Nicht aktiv als MVP-Versprechen:

- Nutzer-Cloud-Sync
- Cloud-Backup
- produktiver Content-Package-Sync
- vollstaendige Analytics/Tracking; aktuell wurde nur ein lokaler
  Marketing-&-Analysen-Toggle gefunden

Offen:

- finale Google-Play-Data-Safety-Angaben
- finaler Abgleich mit Datenschutzseite
- finaler Geraetetest fuer Supabase-Startcalls, AI, Tagesimpuls,
  Notifications, Voice/Foto und Share-Import
- Loesch-/Supportprozess fuer lokale Daten, Support-Mails und ggf. AI-Anfragen

## 12. Was Nicht Zum MVP Gehoert

Nicht Teil des ersten oeffentlichen MVP:

- vollstaendige 13k-Freigabe
- vollstaendige Spanisch-/Franzoesisch-Inhalte
- vollstaendige Weltsprachenabdeckung
- TOEFL-/IELTS-/Cambridge-Pakete
- Business-/Grammar-/Phrase-Pakete als produktive Spezialpakete
- Cloud-Backup
- Account-Sync
- Chat-Sync
- Premium/Abo
- produktiver Content-Package-Sync
- vollstaendige Content-Package-Migration
- perfekte KI-Antworten
- fertiger Multiplayer/Wort-Duell

## 13. Offene Hauptblocker

Priorisierte Blocker vor oeffentlichem Release:

1. Finale juristische Pruefung von Datenschutz, AGB/Nutzungsbedingungen und
   Impressum.
2. Google Play Developer Identitaetspruefung abschliessen.
3. Google Play Console App/App-ID/Data Safety/Internal Testing vorbereiten.
4. Finale Data-Safety-Entscheidungen gegen den installierten Release-Build
   pruefen.
5. Finalen installierten Release-Build-Test auf echtem Geraet durchfuehren.
6. Debug-/Developer-Sichtbarkeit im finalen Release-Build pruefen.
7. App-Icon final pruefen.
8. Store-Screenshots aus finalem Build erstellen.
9. MVP-Content fuer alle sichtbaren Startpfade absichern.
10. Store-Metadaten, Altersfreigabe und Review-Hinweise finalisieren.

## 14. Empfohlene Naechste Arbeitsbloecke

Empfohlene Reihenfolge:

1. Data-Safety-Entscheidungen final gegen Build und Datenschutzseite klaeren.
2. Google Play Console nach Verifikation fortsetzen.
3. Android Internal Testing mit finalem AAB vorbereiten.
4. App-Icon visuell und technisch pruefen.
5. Finalen Release-Smoke-Test auf installiertem Geraet durchfuehren.
6. Screenshots aus finalem Build erstellen.
7. Store-Metadaten und Review-Hinweise final anpassen.
8. Legal-Seiten parallel final juristisch pruefen lassen.
9. Danach weitere Content-Batches fuer sichtbare Startpfade oder zweite
   Wortweltgruppe fortsetzen.

Entscheidungsvorschlag:

- Nicht weiter tief in Content-Package-Architektur gehen, bevor die
  Store-/Data-Safety-/Release-Technik abgeschlossen ist.
- Fuer den ersten MVP lokale, gepruefte Inhalte bevorzugen.
- Supabase bleibt vorbereitet, aber kontrollierter Paket-Sync kommt spaeter.

## 15. Arbeitsstil Und Wichtige Regeln

Projektregeln fuer kommende Arbeitsbloecke:

- Grosse, zusammenhaengende Bloecke statt zu vieler Mini-Schritte.
- Keine Produktivdaten ohne ausdrueckliche Freigabe aendern.
- Keine Supabase Writes ohne ausdrueckliche Freigabe.
- Keine Imports ohne ausdrueckliche Freigabe.
- Keine SQLite-/Vokabel-/SRS-/`word_progress`-Aenderungen ohne klaren Auftrag.
- Keine Keystores, `key.properties`, Zertifikate, Provisioning Profiles,
  Passwoerter oder Secrets committen oder dokumentieren.
- Working-Copies wie `*_working.csv` bleiben ignored.
- Review-Ergebnisse werden als kleine Overlays dokumentiert.
- Store-Texte duerfen keine unfertigen Features bewerben.
- Screenshots duerfen keinen ungeprueften Content zeigen.
- `approved_for_mvp` ist eine Review-Entscheidung fuer den MVP-Content-Scope,
  keine automatische Produktivfreigabe in SQLite oder Supabase.
- Content-Package-Architektur bleibt vorbereitet, aber wird erst nach finalem
  Paketformat, Migration und Teststrategie produktiv aktiviert.
