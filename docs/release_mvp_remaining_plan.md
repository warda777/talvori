# Release-MVP-Restplan

Stand: 2026-05-30

Dieser Plan sortiert den MVP-Restweg nach den abgeschlossenen Blöcken zu
Debug-Sicherheit, Supabase-Guard, Sprachcodes, Content-Package-Architektur
und Vokabelreview neu. Es wurden keine App-Logik, keine Supabase-Daten, keine
SQLite-/Vokabeldaten, keine SRS-Daten und kein `word_progress` verändert.

## 1. Kurze Gesamtbewertung

Talvori ist deutlich näher an einem kontrollierten MVP als zu Beginn der
Release-Analyse.

Verbessert wurde:

- Debug- und Developer-Zugänge sind release-sicherer eingeordnet.
- Der alte wortanzahlbasierte Supabase-Auto-Sync ist im Release gegated.
- Supabase bleibt strategisch erhalten, läuft aber nicht mehr als
  unkontrollierte Hintergrundmagie.
- App-Sprache, Muttersprache, Lernsprache und Content-Sprachpaar sind
  fachlich klarer getrennt.
- Content-Package-Metadaten, Taxonomie und Sync-Policy sind vorbereitet.
- Der Vokabelreview hat einen sicheren Workflow mit Seed, Analyse,
  Kandidatenlisten, Working-Copy, Validatoren und Overlays.
- Der erste manuelle Review-Batch ist abgeschlossen.
- Die Trennung von Level, Top-Wortschatz und Wortwelten ist strukturell
  vorbereitet.

Entschärfte Risiken:

- ungeprüfte Supabase-Inhalte werden im Release nicht automatisch durch den
  Legacy-Sync nachgeladen
- Debug-/Admin-Werkzeuge sind nicht mehr nur lose dokumentiert, sondern
  systematisch geprüft
- `word_progress`, SRS und User-Flags sind in den Sync- und Review-Plänen als
  geschützte Daten definiert
- Top 500, A1-C2 und Spezialpakete sind fachlich nicht mehr als normale
  Wortwelten geplant

Größter verbleibender Blocker:

- Content-Qualität und Release-Basis: Ein MVP braucht rechtliche/Store-Basis,
  echten Device-Smoke-Test und einen geprüften Minimalwortbestand. Die
  Architektur ist vorbereitet; jetzt zählt, dass Nutzer im ersten Release
  nicht auf rechtliche Lücken, Store-Blocker, instabile Startpfade oder
  ungeprüften Content treffen.

## 2. Erledigte große Blöcke

### Debug-/Release-Sicherheit

- Debug-Routen wurden geprüft.
- Entwicklerbereiche sind über `kDebugMode` eingeordnet.
- CategoryDetail-Debug-Zugänge sind geschützt.
- Dokumentiert ist: Debug-Werkzeuge bleiben für Entwicklung, sollen aber im
  Release-Build manuell gegengeprüft werden.

### Supabase-/Auto-Sync-Sicherheit

- Supabase bleibt langfristig Teil der Talvori-Strategie.
- Der Legacy-`SupabaseWordsLocalAutoSyncService` ist im Release über
  `ReleaseSyncPolicy` standardmäßig geschützt.
- Debug darf den Legacy-Sync weiterhin nutzen.
- Die Release-Entscheidung ist dokumentiert: kontrollierter Paket-Sync später,
  kein unkontrollierter wortanzahlbasierter Auto-Sync für MVP.

### Sprachmodell/Sprachcodes

- `TalvoriLanguages` stellt stabile Codes für App-/Native-/Learning-Language
  und Content-Sprachpaare bereit.
- Bestehende UI-Labels bleiben kompatibel.
- Settings erklärt App-Sprache, Muttersprache und Lernsprache verständlicher.
- Weitere Sprachen sind intern vorbereitet, aber nicht produktiv sichtbar
  freigeschaltet.

### Content-Package-Architektur

- `ContentPackageMetadata`, `ContentPackageImportMarker`,
  `ContentPackageSyncPolicy`, `ContentPackageTaxonomy` und `VersionCompare`
  sind vorbereitet.
- Top-Wortschatz wird als Paketfamilie geplant.
- Spezialpakete wie TOEFL, IELTS, Cambridge, Business, Grammar und Phrases
  sind als Content-Pakete eingeordnet.
- Das Migrationsdesign trennt:
  - Paketdefinition: `content_packages`
  - Paketmitgliedschaft: `content_package_memberships`
  - lokaler Importmarker: `content_package_imports`

### Vokabelreview-Workflow

- Review-Workflow dokumentiert.
- Master-Review-Template erstellt.
- Seed-Exporter und Seed-Analyse gebaut.
- Qualitätsreport und Kandidatenlisten erzeugt.
- Working-Copy-, Validator- und Overlay-Workflow vorhanden.
- Große Seed-Dateien bleiben ignored und werden nicht committed.

### Erster manueller Review-Batch

- 103 Review-Zeilen bearbeitet.
- Exakte Dubletten, Case-Varianten, Bedeutungsvarianten und fehlende
  Level/Kategorien wurden als Review-Entscheidungen vorbereitet.
- Overlay enthält Entscheidungen, aber keine produktiven Korrekturen.
- Keine `approved`-Freigabe und kein `release_ready=true` wurden gesetzt.

### Strukturreview Level/Top-500/Wortwelten

- A1-C2 sind als Lernlevel definiert.
- Top 500 ist als Paketfamilie definiert.
- Themen wie Travel, Food und Work bleiben Wortwelten.
- Erster repräsentativer Struktur-Batch wurde reviewed.
- Größere Strukturissues werden nicht automatisch korrigiert.

## 3. Offene Muss-vor-Release Punkte

### 1. Rechtliches, Datenschutz, AGB, Impressum, Hilfe und Feedback

Warum wichtig:

- Store-Review und Nutzervertrauen können daran hängen.
- Datenschutz ist besonders relevant wegen Supabase, AI-/Companion-Funktionen,
  Notifications und späterem Sync.

Aufwand: mittel

Risiko: hoch

Konkrete Richtung:

- finale Datenschutzseite
- AGB/Nutzungsbedingungen
- Impressum oder Anbieterinformationen je Zielmarkt
- einfache Hilfe/FAQ
- echter Feedback-/Kontaktpunkt, mindestens Mail-Link oder Support-Hinweis

### 2. Release-Build auf echtem Gerät prüfen

Warum wichtig:

- Widget-Tests ersetzen keinen echten iOS/Android-Release-Smoke-Test.
- Besonders kritisch: Start, Home, Onboarding, lokale DB, Importpfade,
  Notifications, Browser-Öffnen, Companion/Chat und Wortspiele.

Aufwand: mittel

Risiko: hoch

Konkrete Richtung:

- Release-Build installieren
- App frisch starten
- Onboarding durchlaufen
- lokale Wörter prüfen
- Lernmodus starten
- Wortspiele öffnen
- Settings/Profile öffnen
- Offline-Modus testen
- App killen/neustarten

### 3. Debug-/Developer-Sichtbarkeit im Release manuell prüfen

Warum wichtig:

- Debug-Tools dürfen für normale Nutzer nicht sichtbar oder erreichbar sein.
- Automatische Tests geben Sicherheit, aber der echte Release-Build ist die
  letzte Instanz.

Aufwand: klein bis mittel

Risiko: hoch

Konkrete Richtung:

- Settings prüfen
- CategoryDetail prüfen
- bekannte Debug-Routen manuell versuchen
- Supabase-Importscreen darf im Release nicht normal erreichbar sein

### 4. App Store / Play Store Mindestanforderungen

Warum wichtig:

- Store-Metadaten, Datenschutzangaben, Screenshots, Altersfreigabe,
  App-Kategorie und ggf. Datenverwendungsangaben können Release blockieren.

Aufwand: mittel

Risiko: hoch

Konkrete Richtung:

- Store-Checkliste erstellen
- App-Name, Kurzbeschreibung, Langbeschreibung
- Screenshots
- Privacy Nutrition / Data Safety Angaben
- Support-URL und Datenschutz-URL
- Altersfreigabe

### 5. Vokabelqualität: mindestens MVP-Bestand prüfen

Warum wichtig:

- Content-Qualität ist der direkteste Qualitätsbeweis für eine Sprachlern-App.
- Nicht der gesamte 13k-Bestand muss vor MVP perfekt sein, aber der sichtbare
  Minimalbestand muss vertrauenswürdig sein.

Aufwand: groß

Risiko: hoch

Konkrete Richtung:

- klaren MVP-Wortumfang festlegen
- ersten geprüften Basisbestand definieren
- keine ungeprüften Pakete als releasefähig markieren
- Review-Overlays weiterführen

### 6. Entscheidung: lokaler Seed vs. remote Content-Pakete für ersten Release

Empfehlung:

- Für den ersten MVP lokale geprüfte Inhalte bevorzugen.
- Supabase initialisiert und vorbereitet lassen.
- Kontrollierter Content-Paket-Sync kommt später.

Aufwand: klein für Entscheidung, groß für Umsetzung falls remote gewählt wird

Risiko: hoch, wenn remote Content zu früh aktiviert wird

### 7. Onboarding und erste Nutzerreise final testen

Warum wichtig:

- Nutzer müssen sofort verstehen: Welche Sprache lerne ich? Wo starte ich?
  Was mache ich mit Wortwelten, Wörter prüfen, Spielen und Companion?

Aufwand: mittel

Risiko: mittel bis hoch

Konkrete Richtung:

- Erststart bis erster Lernmoment testen
- Sprachwahl prüfen
- Home-Hauptpfade prüfen
- leere Zustände prüfen
- Offline-Start prüfen

### 8. Wortspiele Release-Scope final festlegen

Warum wichtig:

- Viele Spiele sind sichtbar. Für MVP müssen sie stabil, ehrlich beschriftet
  und ohne kaputte Preview-Wirkung sein.

Aufwand: mittel

Risiko: mittel

Konkrete Richtung:

- entscheiden, welche Spiele im MVP offiziell sind
- Preview-/Ausblick-Bereiche klar lassen
- leere Zustände und kleine Wortbestände prüfen

### 9. Crash-, Offline- und Fehlerfälle prüfen

Warum wichtig:

- Offline-first ist ein Kernversprechen.
- Fehler in Supabase, AI, Notifications oder lokaler DB dürfen den MVP nicht
  hart abbrechen.

Aufwand: mittel

Risiko: hoch

Konkrete Richtung:

- Offline-Start
- fehlende Supabase-Verbindung
- leere lokale DB
- fehlerhafte AI/Notification-Fälle
- App-Neustart nach lokaler Nutzung

## 4. Offene Sollte-vor-Release Punkte

- größere Content-Package-Migration noch nicht bauen, aber Review-Ergebnisse
  weiter gegen das Design prüfen
- weitere Vokabelreview-Batches durchführen
- 992 gleiche `base_term`/`de_translation`-Fälle prüfen
- 6.096 Strukturissues in sinnvolle größere Batches aufteilen
- Hilfe/Feedback als echten Kontaktpunkt ausbauen
- Premium-/Preview-Bereiche weiter polieren, ohne Fake-Funktionalität
- Profile und Settings final gegen Release-Texte prüfen
- Store-Screenshots vorbereiten
- Tagesimpuls und Notifications auf echtem Gerät gesondert testen
- Browser-/Share-Import auf iOS und Android gegen reale Browser teilen/testen

## 5. Kann nach Release kommen

- Cloud-Backup für Nutzer
- Account-Sync
- echte Supabase Content-Package-Sync-Implementierung
- SQLite-Migration für `content_packages`,
  `content_package_memberships` und `content_package_imports`
- TOEFL-/IELTS-/Cambridge-Pakete produktiv erstellen
- Business-/Grammar-/Phrase-Pakete produktiv erstellen
- vollständiger Spanisch- und Französisch-Content
- weitere UI-Sprachen
- Companion-/Chat-Sync
- Premium-/Abo-System
- Analytics/Monitoring
- Community-/Expert-Review-System
- automatische Qualitätschecks für Content-Pakete

## 6. Nächste sehr große Arbeitsblöcke

### Block A: Rechtliches, Hilfe/Feedback und Store-Basics

Ziel:

- MVP-relevante rechtliche und Store-Grundlagen releasefähig machen.
- Der Block ist jetzt als Planungs- und Checklistenbasis vorbereitet.
- Talvori-Domainlinks sind in der App vorbereitet:
  `https://talvori.eu/privacy/`, `https://talvori.eu/terms/`,
  `https://talvori.eu/imprint/` und `https://talvori.eu/support/`.
- Support-Mail ist `support@talvori.eu`; Legal-Mail ist `legal@talvori.eu`.
- Finale juristische Pruefung der Web-Inhalte bleibt offen.

Enthält:

- Datenschutz
- AGB/Nutzungsbedingungen
- Impressum/Anbieterinfos
- Hilfe/FAQ
- Feedback/Kontakt
- Store-Metadaten-Checkliste
- Detaildokument: `docs/release_legal_support_store_plan.md`
- Arbeitscheckliste: `docs/store_release_checklist.md`

Priorität: zuerst

### Block B: Release-Build und Device-Smoke-Test

Ziel:

- echten Release-Build auf Gerät prüfen.
- Ein manueller Smoke-Test fuer zentrale MVP-Pfade wurde dokumentiert:
  `docs/release_device_smoke_test.md`.
- Der getestete Build-Typ ist nicht dokumentiert; ein finaler Release-Build-Test
  direkt vor Store-Einreichung bleibt offen.

Enthält:

- Start/Onboarding/Home
- lokale DB
- Lernmodus
- Wörter prüfen
- Wortspiele
- Settings/Profile
- Browser/Share-Import
- Offline/Neustart
- Debug-Sichtbarkeit

Priorität: direkt nach oder parallel zu Block A

### Block C: Onboarding und erste Nutzerreise prüfen

Ziel:

- ersten Lernmoment klar und stabil machen.

Enthält:

- Sprachwahl
- erste Wortwelt
- erster Lernmodus
- erster Wörter-prüfen-Pfad
- leere Zustände

Priorität: hoch

### Block D: Wortspiel-Release-Scope finalisieren

Ziel:

- festlegen, welche Spiele wirklich MVP-Scope sind.
- Der Release-Scope ist dokumentiert:
  `docs/word_games_release_scope.md`.
- Spielbare Wortspiele werden im Hub als `spielbar` markiert; Wort-Duell ist
  als `Vorschau` eingeordnet.

Enthält:

- Spielkarten prüfen
- leere Zustände prüfen
- kleine Wortbestände prüfen
- Preview-Bereiche sauber benennen

Priorität: erledigt fuer MVP-Planung, vor Screenshots nochmals visuell pruefen

### Block E: Content-Review weiterführen

Ziel:

- sichtbaren MVP-Content vertrauenswürdig machen.

Enthält:

- gleiche base/de-Fälle
- nächste Strukturissue-Batches
- MVP-Minimalwortbestand
- keine automatische Freigabe

Priorität: hoch, aber nicht weiter Architektur vertiefen

### Block F: Store-Material und Screenshots

Ziel:

- Store-Auftritt vorbereiten.
- Store-Metadaten sind als Entwurf vorbereitet:
  `docs/store_metadata_draft.md`.
- Store-Review-Hinweise sind als Entwurf vorbereitet:
  `docs/store_review_notes_draft.md`.
- Screenshots und finale Store-Einreichung bleiben offen.

Enthält:

- Screenshots
- Kurztexte
- Feature-Liste
- Datenschutz-/Support-Links
- Release Notes

Priorität: nach rechtlicher Basis und Device-Smoke-Test

## 7. Entscheidungsvorschlag für den MVP

Für den ersten MVP sollte Talvori nicht versuchen, die vollständige
Content-Package-Migration, alle Sprachpaare und den kompletten Supabase-Sync
gleichzeitig produktiv zu machen.

Empfehlung:

- keine vollständige Content-Package-Migration für den ersten MVP
- keine vollständige Mehrsprachigkeits-/Content-Offensive für den ersten MVP
- lokale geprüfte Inhalte bevorzugen
- Supabase vorbereitet lassen, aber kontrollierter Paket-Sync erst später
- kein ungeprüfter Remote-Content im Release-Autostart
- Fokus auf stabile lokale App, geprüften Minimalcontent,
  rechtliche/Store-Basis und echten Device-Smoke-Test

Das ist der schnellste Weg zu einem glaubwürdigen MVP, ohne die langfristige
Supabase- und Mehrsprachigkeitsstrategie zu verbauen.

## 8. Risiken

- Content-Qualität bleibt der größte inhaltliche Aufwand.
- Rechtliches darf nicht fehlen und kann Store-Review oder Veröffentlichung
  blockieren.
- Store-Vorgaben können zusätzliche Pflichtangaben erzwingen.
- Mehrsprachigkeit ist vorbereitet, aber noch nicht produktiv vollständig.
- Supabase ist vorbereitet, aber noch kein Backup-/Account-System.
- Companion-/AI-/Notification-Funktionen brauchen klare Datenschutz- und
  Fehlerfall-Kommunikation.
- Zu viele sichtbare Preview-Bereiche können MVP unfertig wirken, wenn sie
  nicht sauber erklärt sind.
- Ein kompletter Content-Package-Sync vor MVP würde unnötig Risiko und
  Testaufwand erhöhen.

## 9. Konkrete nächste Empfehlung

Der nächste Arbeitsblock sollte **Block A: Rechtliches, Hilfe/Feedback und
Store-Basics** sein.

Begründung:

- Content-Architektur und Sync sind ausreichend vorbereitet.
- Der größte nicht-technische Release-Blocker ist jetzt die rechtliche und
  Store-relevante Basis.
- Ohne Datenschutz, Support-/Feedback-Kanal und Store-Grundlagen kann selbst
  eine technisch stabile App nicht sauber veröffentlicht werden.
- Danach sollte unmittelbar Block B folgen: Release-Build auf echtem Gerät
  mit Debug-Sichtbarkeitsprüfung.

Empfohlene Reihenfolge ab jetzt:

1. Rechtliches/Hilfe/Feedback/Store-Basics
2. Release-Build und Device-Smoke-Test
3. Onboarding und erste Nutzerreise
4. Wortspiel-Release-Scope
5. MVP-Content-Review weiterführen
6. Store-Screenshots und finale Release-Unterlagen
