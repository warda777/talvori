# Finaler MVP-Blocker-Review

Stand: 2026-05-30

Dieser Review fasst den aktuellen Release-Zustand der Talvori-App nach Legal-/Support-Verdrahtung, Smoke-Test, Store-Metadatenentwurf und Wortspiele-Scope zusammen. Es wurden keine App-Logik, keine Supabase-Daten, keine Imports, keine SQLite-/Vokabeldaten, keine SRS-Daten und kein `word_progress` geaendert.

## 1. Gesamtstatus

### Releasefaehig vorbereitet

- Legal- und Support-Verweise sind in der App auf echte Talvori-Links verdrahtet:
  - Datenschutz: `https://talvori.eu/privacy/`
  - Nutzungsbedingungen: `https://talvori.eu/terms/`
  - Impressum: `https://talvori.eu/imprint/`
  - Support: `https://talvori.eu/support/`
  - Feedback: `mailto:support@talvori.eu`
- Settings und Profile bieten erreichbare Support-/Legal-Einstiege.
- Debug-/Developer-Zugaenge sind technisch auf `kDebugMode` ausgerichtet und dokumentiert.
- Der Legacy-Supabase-Woerter-Auto-Sync ist im Release ueber `ReleaseSyncPolicy` gegated.
- Der manuelle Smoke-Test fuer zentrale MVP-Pfade ist dokumentiert.
- Der Android Release-Appbundle-Build mit Application ID `eu.talvori.app` ist lokal erfolgreich durchgelaufen und dokumentiert: `docs/android_release_build_check.md`.
- Der MVP-Content-Scope ist als Entwurf festgelegt: erster Content-Fokus Englisch -> Deutsch, kleiner gepruefter sichtbarer Kernbestand, keine Bewerbung vollstaendiger Mehrsprachigkeit.
- Store-Metadaten, Store-Review-Hinweise und Nicht-bewerben-Liste liegen als Entwurf vor.
- Der Wortspiele-Scope ist geklaert: nutzbare Modi sind als spielbar eingeordnet, Wort-Duell bleibt Vorschau.
- Content-Package-, Supabase- und Vokabelreview-Strategie sind vorbereitet, ohne produktive Daten zu veraendern.

### Noch nicht releasefaehig

- Datenschutz, AGB/Nutzungsbedingungen und Impressum muessen final fachkundig/juristisch geprueft werden.
- Ein echter finaler installierter Release-Build-Test direkt vor Store-Einreichung steht noch aus.
- Store-Account-/Store-Konfiguration, Bundle ID, Version/Build Number, Altersfreigabe, Datenverwendungsangaben und Screenshots sind noch offen.
- App-Icon und finale Store-Screenshots muessen gegen den tatsaechlichen Release-Build geprueft werden.
- Debug-Sichtbarkeit muss im finalen Release-Build manuell gegengeprueft werden.
- Der sichtbare MVP-Wortbestand braucht noch konkrete Review-Arbeitsbatches fuer die priorisierten Start-Wortwelten.

### Wirkliche Store-/MVP-Blocker

1. Finale Legal-Seiten und Datenschutz-/Datenverwendungsangaben.
2. Finaler installierter Release-Build-Test auf den Zielplattformen.
3. Store-Konfiguration inklusive Bundle ID, Version, App-Icon, Screenshots und Altersfreigabe.
4. Debug-/Developer-Sichtbarkeit im finalen Release-Build.
5. MVP-Contentqualitaet fuer den sichtbaren Wortbestand.

## 2. Muss-vor-Release Blocker

### A. Finale juristische Pruefung von Datenschutz, AGB und Impressum

Warum Blocker:

- Stores verlangen Datenschutzangaben und erreichbare rechtliche Informationen.
- Talvori beruehrt lokale Lerndaten, Praeferenzen, AI-/Companion-Funktionen, Notifications und vorbereitete Supabase-Anbindung.

Naechste Aktion:

- Web-Inhalte auf `talvori.eu/privacy/`, `/terms/`, `/imprint/` final pruefen lassen.
- Datenverwendungsangaben im Store mit tatsaechlichem App-Verhalten abgleichen.

### B. Finaler Release-Build-Test direkt vor Store-Einreichung

Warum Blocker:

- Der dokumentierte Smoke-Test war manuell bestanden, aber der Build-Typ ist nicht dokumentiert.
- Android hat zusaetzlich einen erfolgreichen lokalen Release-Appbundle-Build: `build/app/outputs/bundle/release/app-release.aab`.
- Widget-Tests ersetzen keinen echten Release-Build auf Geraet.

Naechste Aktion:

- Release-Build installieren.
- Start, Onboarding, Home, Settings/Profile, Lernmodus, Wortspiele, Browser oeffnen, Offline-Start und Neustart testen.
- iOS und Android getrennt testen, falls beide Plattformen veroeffentlicht werden.

### C. Store-Account, Metadaten, Bundle ID und Version

Warum Blocker:

- Ohne Store-Konfiguration kann keine Einreichung erfolgen.
- Bundle ID, Version/Build Number, Kategorie, Altersfreigabe und Datenverwendungsangaben muessen konsistent sein.
- Die technische Identitaet wurde in `docs/store_build_identity_check.md` geprueft und auf die finale MVP-ID umgestellt: iOS und Android nutzen `eu.talvori.app`, Version `1.0.0+1`, sichtbarer App-Name `Talvori`.

Naechste Aktion:

- Store-App-Datensatz anlegen oder pruefen.
- Store-App-Datensatz mit `eu.talvori.app` anlegen oder pruefen.
- Apple Developer App ID und App Group `group.eu.talvori.app` anlegen bzw. bestaetigen.
- Google Play Application ID `eu.talvori.app` im Play Console Setup bestaetigen.
- Version `1.0.0+1` als MVP-Startwert bestaetigen.
- Store-Metadaten aus `docs/store_metadata_draft.md` an Plattformlimits anpassen.
- Android Release Signing fuer Play Store konfigurieren, falls Android MVP ist.
- Android Release Signing ist lokal vorbereitet und erfolgreich fuer den AppBundle-Build genutzt. Signing-Setup-Plan nutzen: `docs/store_signing_setup_plan.md`. Keystore, Passwoerter, Zertifikate und Provisioning Profiles duerfen nicht committed werden.
- Google Play Application ID `eu.talvori.app` bleibt in der Play Console zu bestaetigen.

### D. App-Icon und Screenshots aus finalem Build

Warum Blocker:

- Store-Einreichung braucht visuelle Assets.
- Screenshots duerfen keine unfertigen oder irrefuehrenden Preview-Funktionen bewerben.

Naechste Aktion:

- App-Icon final pruefen.
- Screenshots nur aus finalem Release-Build erstellen.
- Wort-Duell nicht als fertigen Multiplayer zeigen.
- Keine Premium-, Cloud-Sync-, TOEFL-/IELTS-/Cambridge- oder Weltsprachenversprechen zeigen.

### E. Datenschutz-/Datenverwendungsangaben

Warum Blocker:

- App Store und Google Play verlangen konkrete Angaben zu erfassten/verarbeiteten Daten.
- AI-/Companion-, Notification-, Support- und Supabase-Vorbereitung muessen korrekt eingeordnet werden.

Naechste Aktion:

- Angaben fuer lokale Lernstaende, Praeferenzen, Favoriten/bekannte Woerter, AI-/Companion-Daten, Notifications und Supportkontakt final beschreiben.
- Nicht als aktiv darstellen: Cloud-Backup, Account-Sync, Chat-Sync, produktiver Content-Package-Sync.

### F. MVP-Contentqualitaet / sichtbarer Wortbestand

Warum Blocker:

- Eine Sprachlern-App wird unmittelbar an Vokabelqualitaet gemessen.
- Der Review-Workflow ist vorbereitet, aber nicht der gesamte sichtbare Bestand ist final fachlich freigegeben.

Naechste Aktion:

- MVP-Content-Scope aus `docs/mvp_content_scope.md` nutzen.
- Erste Review-Arbeitsliste nutzen: `docs/word-review/mvp_content_first_review_batch.csv`.
- Travel und Food & Cooking sind in der lokalen Working-Copy vorgeprueft.
- Home & Living bleibt offen; Overlay erst nach vollstaendigen 150 Entscheidungen erzeugen.
- Die 150 Zeilen vor Release intensiv finalisieren: 50 Travel, 50 Food & Cooking, 50 Home & Living als Screenshot-/Startkandidaten.
- Weitere Review-Batches nach Risiko priorisieren: gleiche `base_term`/`de_translation`, Strukturissues, kleine/auffaellige Wortwelten.

### G. Debug-Sichtbarkeit im finalen Release-Build

Warum Blocker:

- Debug-/Admin-Tools duerfen fuer normale Nutzer nicht sichtbar oder erreichbar sein.

Naechste Aktion:

- Settings-Entwicklerbereich, lokale Debug-Routen, CategoryDetail-Debugbutton und Supabase-Importscreen im finalen Release-Build manuell pruefen.

## 3. Kein Blocker / Nach Release

Diese Punkte sind strategisch wichtig, blockieren aber den ersten MVP nicht, solange sie nicht beworben werden:

- komplette Content-Package-Migration
- produktiver Supabase-Content-Package-Sync
- Cloud-Backup und Account-Sync
- TOEFL-/IELTS-/Cambridge-Pakete
- Business-/Grammar-/Phrase-Spezialpakete
- vollstaendige Weltsprachenabdeckung
- vollstaendiger Spanisch-/Franzoesisch-Content
- Premium-/Abo-System
- Companion-/Chat-Sync
- Community-/Expert-Review-System
- Analytics/Monitoring

## 4. Store-Risiken

### Texte, die zu viel versprechen wuerden

- `Wort-Duell` oder Multiplayer als verfuegbar.
- Cloud-Backup, Account-Sync oder Geraetewechsel als aktiv.
- produktiver Supabase-Paket-Sync oder automatisch aktualisierte Online-Pakete.
- TOEFL, IELTS, Cambridge, Premium oder Abo als verfuegbar.
- vollstaendige Spanisch-/Franzoesisch-Inhalte oder globale Mehrsprachigkeit.
- fehlerfreie KI- oder Companion-Antworten.
- vollstaendig gepruefte automatische Uebersetzungen fuer alle Inhalte.

### Screenshots, die vermieden werden sollten

- Wort-Duell als Hauptmotiv oder scheinbar aktiver Multiplayer.
- Preview-/Ausblickbereiche als fertige Feature-Screens.
- Premium-/Abo-Bereiche, solange kein Store-/Payment-Flow fertig ist.
- Debug-/Developer-Bereiche.
- KI-Fehlerzustaende oder unklare Placeholder.
- Wortlisten oder Wortwelten mit sichtbar ungeprueftem oder missverstaendlichem Content.

### Features, die nicht beworben werden duerfen

- TOEFL/IELTS/Cambridge
- Cloud-Backup / Account-Sync
- Chat-Sync
- Premium/Abo
- weltweite vollstaendige Mehrsprachigkeit
- produktive Remote-Content-Pakete
- fertiger Multiplayer

## 5. App-Risiken

- Prepared-/Preview-Bereiche muessen im finalen Build hochwertig und ehrlich wirken.
- Bewertung schreiben ist vorbereitet, aber noch nicht mit Store-Ziel verknuepft.
- Hilfe/FAQ ist noch nicht voll ausgebaut.
- Tagesimpuls/Notifications brauchen vor Store je Plattform eine echte Geraetepruefung, falls sichtbar beworben.
- Browser-/Share-Import sollte auf echten iOS-/Android-Browsern geprueft werden, falls als MVP-Pfad relevant.
- Offline-Start wurde manuell bestanden, muss aber im finalen Release-Build erneut getestet werden.
- Debug-/Developer-Sichtbarkeit muss im finalen Release-Build erneut geprueft werden.
- Fehlerfaelle duerfen keine Entwicklertexte oder internen Debug-Hinweise fuer Nutzer zeigen.

## 6. Content-Risiken

### Noch offen

- Der gesamte Bestand ist noch nicht Wort fuer Wort fachlich freigegeben.
- 992 gleiche `base_term`/`de_translation`-Faelle bleiben auffaellig.
- 6.096 Strukturissue-Kandidaten sind noch nicht vollstaendig in grosse Review-Batches ueberfuehrt.
- Level, Wortwelten und Paketzuordnung sind strukturell geplant, aber noch nicht produktiv migriert.
- Spanisch/Franzoesisch sind vorbereitet, aber nicht als vollstaendige Produktinhalte releasefaehig.

### Minimal sinnvoller MVP-Content-Scope

Empfehlung:

- Nicht den kompletten 13k-Bestand als perfekt darstellen.
- Fuer den MVP einen kleinen, gut pruefbaren Englisch-Deutsch-Kernbestand definieren.
- Groessenordnung: 100 bis 200 gepruefte Woerter oder 30 bis 50 Woerter je priorisierter Wortwelt.
- Fokus auf sichtbare erste Nutzerreise:
  - Travel / Reisen
  - Food & Cooking / Essen & Kochen
  - Home & Living / Zuhause & Alltag
  - erste Lernlevel
  - Lernmodus-Beispiele
  - Wortspiele mit stabilen Beispiel-/Lokaldaten
- Nur gepruefte Inhalte fuer Store-Screenshots verwenden.

### Ist weiterer Content-Review vor Store zwingend?

Ja, aber gezielt. Nicht die gesamte Content-Architektur muss weitergebaut werden. Zwingend ist die fachliche Pruefung des sichtbaren MVP-Minimalbestands nach `docs/mvp_content_scope.md`. Weitere Review-Batches sind vor Store sinnvoll, wenn sie direkt den sichtbaren Startbestand betreffen.

## 7. Konkrete naechste Reihenfolge

### A. Juristische Pruefung / finale Legal-Seiten

- Datenschutz, Nutzungsbedingungen und Impressum final pruefen.
- Datenverwendungsangaben fuer Store vorbereiten.
- Support-/Legal-Mailpostfaecher operativ sicherstellen.

### B. Store-Account / Metadaten / Bundle / Version

- Store-Datensatz vorbereiten.
- Bundle ID / Package Name, Version und Build Number pruefen.
- Store-Texte aus dem Draft an Plattformlimits anpassen.
- Altersfreigabe und Datenschutzangaben vorbereiten.

### C. Finaler Release-Build-Test

- Release-Build auf Zielgeraeten installieren.
- Smoke-Test aus `docs/release_device_smoke_test.md` wiederholen.
- Debug-Sichtbarkeit im finalen Release-Build pruefen.

### D. Screenshots aus finalem Build

- Nur stabile, echte MVP-Bereiche zeigen.
- Keine Preview-Funktionen als fertige Features zeigen.
- Wortspiele nur mit stabilen, spielbaren Modi zeigen.

### E. Content-Minimalbestand pruefen

- MVP-Minimalwortbestand festlegen.
- Startwortwelten und sichtbare Lernpfade fachlich pruefen.
- Auffaellige Review-Kandidaten fuer den sichtbaren Bestand priorisieren.

### F. Store-Einreichung vorbereiten

- Store-Review-Hinweise finalisieren.
- finalen Check gegen Store-Checkliste machen.
- keine unfertigen Funktionen bewerben.

## 8. Entscheidungsvorschlag

Als naechstes sollte nicht weiter tief an Content-Architektur gearbeitet werden. Die Architektur ist fuer den MVP ausreichend vorbereitet und groessere Migrationen wuerden vor dem ersten Release mehr Risiko als Nutzen bringen.

Empfehlung:

1. Erst Store-/Release-Technik und Legal-Finale abschliessen.
2. Danach den finalen Release-Build-Test auf Geraeten durchfuehren.
3. Parallel oder direkt danach den sichtbaren MVP-Minimalcontent fachlich pruefen.

Damit bleibt Talvori auf dem schnellsten Weg zu einem glaubwuerdigen MVP: stabile lokale App, ehrliche Store-Kommunikation, rechtliche Basis, keine versteckte Debug-/Sync-Magie und ein bewusst begrenzter, gepruefter Content-Start.
