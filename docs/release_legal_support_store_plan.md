# Release-Plan: Rechtliches, Hilfe/Feedback und Store-Basics

Stand: 2026-05-30

Dieses Dokument ist eine technische und produktorganisatorische Vorbereitung fuer den Release-MVP. Es ist keine Rechtsberatung und ersetzt keine finale juristische Pruefung. Alle rechtlichen Texte muessen vor Veroeffentlichung extern oder fachkundig geprueft und final freigegeben werden.

## 1. Ziel

Talvori braucht vor einem oeffentlichen Release eine belastbare Mindeststruktur fuer:

- Datenschutz
- Nutzungsbedingungen oder AGB
- Impressum oder Anbieterinformationen
- Hilfe/FAQ
- Feedback/Kontakt
- Store-Metadaten und Review-Angaben

Ohne diese Grundlagen kann eine technisch stabile App trotzdem am Store-Review, an rechtlichen Pflichtangaben oder am Nutzervertrauen scheitern.

## 2. Gepruefte App-Bereiche

### Settings

Datei: `lib/features/home/ui/screens/settings_screen.dart`

Vorhanden:

- Bereich `Unterstuetzung`
- Eintrag `Hilfe & Support`
- Eintrag `Eine Bewertung schreiben`
- Eintrag `Feedback & Kontakt`
- Bereich `Rechtliches`
- Eintrag `Datenschutzrichtlinie`
- Eintrag `Nutzungsbedingungen / AGB`
- Eintrag `Impressum / Anbieterinformationen`
- Toggle `Marketing & Analysen`
- Debug-only Entwicklerbereich hinter `kDebugMode`

Bewertung:

- Die Stellen fuer Hilfe, Feedback, Datenschutz, AGB und Impressum existieren.
- Hilfe und Support verweisen auf `https://talvori.eu/support/`.
- Feedback/Kontakt nutzt `support@talvori.eu` als Mail-Kontakt.
- Rechtliches verweist auf Web-Links statt Rechtstexte in der App zu duplizieren.
- Die Bewertungsfunktion ist vorbereitet, aber noch kein echter Store-Link.

### Profil

Datei: `lib/features/home/ui/screens/profile_screen.dart`

Vorhanden:

- Bereich `Hilfe & Konto`
- Eintrag `Hilfe`
- vorbereitete Premium-, Sammlungen-, Verlauf-, Stimmen- und Widgets-Bereiche

Bewertung:

- Das Profil bleibt bewusst ruhiger als Settings.
- `Hilfe & Support` fuehrt ebenfalls zur Support-Seite.
- Rechtliches liegt aktuell eher in Settings, was fuer MVP ausreichend sein kann.

### Onboarding

Datei: `lib/features/onboarding/ui/screens/onboarding_flow_screen.dart`

Vorhanden:

- Einstieg in Lernziele, Impulse und vorbereitete Widgets
- keine sichtbare Datenschutz-/AGB-Zustimmung im geprueften Ausschnitt

Bewertung:

- Fuer MVP muss entschieden werden, ob Datenschutz/AGB nur in Settings erreichbar sind oder ob beim ersten Start ein kurzer Hinweis erforderlich ist.
- Keine neue Onboarding-Architektur wurde in diesem Schritt gebaut.

### Navigation und Debug

Dateien:

- `lib/main.dart`
- `lib/features/home/ui/screens/supabase_words_local_import_screen.dart`

Bewertung:

- Debug-Routen sind laut aktuellem Stand hinter `kDebugMode` registriert.
- Der manuelle Supabase-Import ist in Settings nur im Entwicklerbereich sichtbar.
- Eine manuelle Pruefung im echten Release-Build bleibt Pflicht.

## 3. Rechtliche MVP-Bausteine

### Datenschutz

MVP braucht eine finale Datenschutzseite oder Datenschutz-URL.

Festgelegter Link:

- `https://talvori.eu/privacy/`

Zu klaeren:

- Welche Daten werden lokal gespeichert?
- Welche Daten koennen optional oder spaeter online verarbeitet werden?
- Welche Supabase-Verbindungen sind im Release aktiv?
- Welche AI-/Companion-Funktionen senden Daten an externe Dienste?
- Welche Daten nutzen Tagesimpuls/Notifications?
- Werden Analytics oder Marketingmessungen aktiv genutzt?
- Wie koennen Nutzer Daten loeschen oder Support kontaktieren?

Wichtig fuer Talvori:

- Lokale Lernstaende, bekannte Woerter, Favoriten, Einstellungen und ggf. Streaks liegen aktuell primaer lokal.
- Supabase bleibt langfristig vorbereitet, aber der Legacy-Auto-Sync ist im Release gegated.
- Ein spaeteres Account-/Backup-System braucht eigene Datenschutzhinweise.
- Companion-/Chat-Sync ist spaeterer Ausbau und darf nicht stillschweigend wie schon produktiv behandelt werden.
- AI-/Companion-Funktionen brauchen klare Hinweise, falls Inhalte an Server oder Drittanbieter gehen.
- Notifications/Tagesimpuls brauchen transparente Beschreibung, besonders bei generierten Inhalten und Berechtigungen.
- Fuer Google Play liegt ein Data-Safety-Draft vor:
  `docs/google_play_data_safety_draft.md`.
- Final zu pruefen bleiben Supabase-Startcalls, AI/Companion, KI-Wortspiele,
  Uebersetzung, Tagesimpuls/Notifications, Voice/Audio, Fotozugriff und
  Marketing/Analytics gegen den tatsaechlichen Release-Build.

### AGB / Nutzungsbedingungen

MVP braucht entweder AGB, Nutzungsbedingungen oder eine klare Entscheidung, welche rechtliche Form fuer Zielmarkt und Store genutzt wird.

Festgelegter Link:

- `https://talvori.eu/terms/`

Zu klaeren:

- Nutzungsumfang der App
- lokale Daten und Haftung bei Datenverlust
- Grenzen von AI-/Companion-Inhalten
- Umgang mit Nutzerinhalten, eigenen Woertern und spaeteren Chats
- Premium/Abo-Hinweise, falls vor Release sichtbar oder geplant
- Mindestalter und Altersfreigabe
- Kontakt- und Anbieterinformationen

### Impressum / Anbieterinformationen

MVP braucht einen sichtbaren Ort fuer Anbieterinformationen, wenn fuer den Zielmarkt erforderlich.

Festgelegter Link:

- `https://talvori.eu/imprint/`

Zu klaeren:

- Anbietername
- ladungsfaehige Anschrift oder rechtlich zulaessige Alternative
- Kontakt-E-Mail
- Verantwortliche Person oder Firma
- Steuer-/Registerangaben, falls relevant
- Zielmarkt: Deutschland/EU, USA oder mehrere Stores

Aktueller Stand:

- Settings hat einen eigenen Impressum-/Anbieterinfo-Eintrag.

### Hilfe / FAQ

MVP braucht mindestens eine kleine Hilfe-Struktur fuer haeufige erste Fragen:

- Was speichert Talvori lokal?
- Wie funktionieren Wortwelten?
- Was bedeutet `Kenn ich`?
- Was bedeutet `Noch lernen`?
- Wie funktionieren Lernlevel?
- Was passiert bei Erinnerungen/Tagesimpuls?
- Warum sind manche Bereiche vorbereitet?
- Wie kontaktiert man Support?

### Feedback / Kontakt

MVP braucht einen echten Kontaktpunkt.

Festgelegte Kontakte:

- Support-Seite: `https://talvori.eu/support/`
- Support-E-Mail: `support@talvori.eu`
- Legal-E-Mail: `legal@talvori.eu`

Nicht ausreichend fuer Release:

- reine Platzhalter ohne reale Kontaktmoeglichkeit
- Fake-Formular ohne Versand
- unklare Aussage, dass Feedback spaeter kommt

## 4. Store-Basics

Vor Store-Einreichung benoetigt:

- App-Name: `Talvori`
- Untertitel oder Kurzbeschreibung
- Langbeschreibung
- Kategorie
- Altersfreigabe
- Support-URL
- Datenschutz-URL
- Anbieterinformationen
- Screenshots je Zielplattform und Geraeteklasse
- App-Icon und ggf. Feature-Grafiken
- Versionsnummer und Buildnummer
- Bundle ID / Package Name
- Datenverwendungsangaben
- Testhinweise fuer Store Review
- Hinweise auf nicht enthaltene oder vorbereitete Features

Die konkreten Store-Anforderungen muessen kurz vor Einreichung gegen die aktuellen Apple- und Google-Vorgaben geprueft werden.

## 5. Empfohlene MVP-Umsetzung

### Phase 1: Inhalte und Kontakt finalisieren

1. Datenschutz-/AGB-/Impressum-Inhalte auf `talvori.eu` final pruefen
2. Datenschutz-Entwurf juristisch pruefen lassen
3. Nutzungsbedingungen/AGB-Entwurf juristisch pruefen lassen
4. Anbieterinformationen/Impressum juristisch pruefen lassen
5. Support- und Legal-Mailpostfaecher pruefen

### Phase 2: App-Stellen anbinden

1. Settings-Links auf echtem Geraet testen
2. Datenschutz, Nutzungsbedingungen und Impressum im Browser pruefen
3. Hilfe/Support im Browser pruefen
4. Feedback-Mail-Link auf iOS/Android pruefen
5. Bewertung erst mit echtem Store-Link aktivieren oder weiter klar als vorbereitet kennzeichnen

### Phase 3: Release-Pruefung

1. Release-Build auf echtem Geraet pruefen
2. Settings/Profile/Onboarding pruefen
3. Debug-Zugaenge im Release manuell pruefen
4. Offline-Start und Fehlerfaelle pruefen
5. Store-Metadaten und Screenshots fertigstellen

## 6. Bewusste Nicht-Aenderungen In Diesem Schritt

- keine App-Logik geaendert
- keine UI-Screens neu gebaut
- keine finalen juristischen Texte erfunden
- echte Talvori-Domainlinks wurden als Web-Verweise genutzt
- keine Supabase-Daten geaendert
- keine lokalen Vokabeldaten geaendert
- keine Store-Funktion aktiv geschaltet

## 7. Offene Fragen

- Sind die Inhalte unter `talvori.eu/privacy/`, `talvori.eu/terms/` und
  `talvori.eu/imprint/` final juristisch geprueft?
- Sind `support@talvori.eu` und `legal@talvori.eu` technisch eingerichtet und
  werden sie regelmaessig gelesen?
- Wird der erste Release nur in Deutschland/EU oder auch international geplant?
- Sind AI-/Companion-Funktionen im MVP so aktiv, dass besondere Hinweise noetig sind?
- Sind Notifications/Tagesimpuls im MVP aktiv oder optional vorbereitet?
- Wird Marketing/Analytics im ersten Release tatsaechlich genutzt oder bleibt der Toggle ohne Tracking?
- Soll Onboarding vor Abschluss auf Datenschutz/AGB verweisen?
- Welche Altersfreigabe ist fuer Store-Einreichung realistisch?
- Welche Store-Kategorie passt am besten: Bildung, Produktivitaet oder Spiele-nahe Bildung?

## 8. Naechster Empfohlener Schritt

Als naechstes sollte ein echter Support-/Legal-Pruefblock folgen:

1. Talvori-Domainlinks auf echtem Geraet testen
2. Zielmarkt fuer MVP festlegen
3. Datenschutz-/AGB-/Impressum-Inhalte final pruefen lassen
4. Support- und Legal-Mailpostfaecher pruefen
5. danach Store-Metadaten und Device-Smoke-Test anschliessen
