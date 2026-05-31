# Google Play Data Safety Draft

Stand: 2026-05-31

## 1. Ziel

Dieses Dokument bereitet die Google-Play-Data-Safety- und Datenschutzangaben fuer den Talvori-MVP vor. Es ist keine Rechtsberatung und keine finale Store-Angabe.

Vor Store-Einreichung muessen die Angaben gegen den tatsaechlichen Release-Build, die finalen Datenschutztexte und die Play-Console-Fragen abgeglichen werden.

## 2. Gepruefte Bereiche

Geprueft wurden:

- Android Berechtigungen in `android/app/src/main/AndroidManifest.xml`
- iOS Berechtigungstexte in `ios/Runner/Info.plist`
- `pubspec.yaml` Dependencies
- Supabase-Initialisierung in `lib/main.dart`
- `ReleaseSyncPolicy`
- lokale SQLite-/sqflite-Struktur
- SharedPreferences fuer Einstellungen, Onboarding, Favoriten, Impuls-Postfach und Tagesimpuls
- Support-/Legal-/mailto-Links in Settings/Profile
- Browser-/Share-Import-Pfade
- Tagesimpuls-/Notification-Code
- AI-/Companion-/Wortspiel-AI-Pfade ueber Supabase Edge Functions
- Marketing-&-Analysen-Toggle

## 3. Berechtigungen Und Technische Hinweise

Android Manifest:

| Berechtigung | Befund | MVP-Bewertung |
| --- | --- | --- |
| `INTERNET` | in main manifest aktiv | noetig fuer Supabase, externe Links, AI/Edge Functions und ggf. Browser-/Support-Flows |
| `POST_NOTIFICATIONS` | in main manifest aktiv | relevant fuer Tagesimpuls/Notifications, Nutzerzustimmung erforderlich |
| `RECORD_AUDIO` | in main manifest aktiv | relevant fuer Sprach-/Voice-Funktionen im Impuls-/Chat-Kontext |

iOS Info.plist:

| Permission-Text | Befund | MVP-Bewertung |
| --- | --- | --- |
| `NSMicrophoneUsageDescription` | Mikrofon fuer diktierte Chatnachrichten | pruefen, ob Voice im MVP sichtbar/aktiv bleibt |
| `NSSpeechRecognitionUsageDescription` | Spracherkennung fuer Impuls-Chat | pruefen, ob externe/OS-Spracherkennung in Datenschutz erwaehnt werden muss |
| `NSPhotoLibraryUsageDescription` | lokale Chat-Bildauswahl | pruefen, ob Bildauswahl im MVP sichtbar/aktiv bleibt |

Keine Firebase-/Crashlytics-/Analytics-Abhaengigkeit wurde im Code als aktive Integration gefunden. Es gibt aber einen lokalen Toggle `Marketing & Analysen`, der aktuell nur als Praeferenz gespeichert wirkt. Das muss vor Release final bestaetigt werden.

## 4. Datenkategorien

| Kategorie | Lokal oder extern | Personenbezogen oder Appdaten | Serveruebertragung | Zweck | MVP-Status | Store-Angabe-Empfehlung |
| --- | --- | --- | --- | --- | --- | --- |
| Lokale Lernstaende / `word_progress` | lokal SQLite | Nutzungs-/Lernfortschrittsdaten | normalerweise nein; alte Supabase-SRS-Pfade existieren im Code | Lernfortschritt, Wiederholungen, SRS | aktiv lokal, Online-Pfade pruefen | als App-Aktivitaet/Lernfortschritt lokal beschreiben; Serveruebertragung nur angeben, wenn im Release aktiv |
| Lokale Woerter / Wortwelten | lokal SQLite / Assets | App-/Contentdaten, teilweise nutzergeneriert bei eigenen Woertern | lokale Imports nein; Supabase-Leser/Import-Pfade vorhanden | Lernen, Wortlisten, Wortwelten | aktiv lokal; Supabase vorbereitet | lokale Speicherung angeben; Remote-Content nur nennen, falls Release-Build tatsaechlich laedt |
| Favoriten / bekannte Woerter | lokal / Memberships / SharedPreferences | Nutzungsdaten | nein, soweit MVP lokal genutzt wird | Uebersicht, Lernfilter | aktiv | lokale App-Aktivitaet, nicht als Cloud-Backup darstellen |
| App-/Sprachpraeferenzen | SharedPreferences | App-Einstellungen | nein | App-Sprache, Muttersprache, Lernsprache, Settings | aktiv | lokale Einstellungen |
| Onboarding-Antworten | SharedPreferences | Nutzungs-/Profilangaben, ggf. Interessen/Motivation | nein | Personalisierter Einstieg | aktiv | als App-Aktivitaet/Praeferenzen lokal einordnen |
| Support-E-Mail-Kommunikation | extern ueber Mail-App/Nutzer-Mailanbieter | personenbezogene Kommunikation | ja, wenn Nutzer aktiv schreibt | Support und Feedback | aktiv durch `mailto:support@talvori.eu` | als optionalen Kontakt/Support ausserhalb der App beschreiben |
| Externe Legal-/Support-Links | extern im Browser | ggf. technische Browser-/Webserverdaten | ja, beim Oeffnen der Website | Datenschutz, AGB, Impressum, Support | aktiv | externe Website-Aufrufe transparent machen |
| Notifications / Tagesimpuls | lokal geplant, OS-Notification | App-Aktivitaet/Erinnerungen | nein fuer lokale Schedule; AI-Generierung kann extern sein | Erinnerung, Lernimpuls | vorbereitet/teilweise aktiv | Benachrichtigungen als optional; AI-Generierung separat pruefen |
| AI-/Companion-Funktionen | Supabase Edge Function `ai-chat` | Nutzerinhalt/Chatinhalt | ja, wenn ausgelöst | Companion, Kategorie-Chat, KI-Wortspiele, Kontext/Hinweise | aktiv oder sichtbar vorbereitet; final pruefen | als externe Verarbeitung markieren, falls im Release nutzbar |
| Uebersetzungsfunktion | Supabase Edge Function `translate-word` moeglich | vom Nutzer eingegebene Woerter/Texte | ja, wenn ausgelöst | manuelle/ausstehende Uebersetzung | vorbereitet/teilweise aktiv | als externe Verarbeitung markieren, falls im Release nutzbar |
| Supabase Bootstrap | Supabase | technische Netzwerkverbindung; evtl. Auth/User-ID | ja, App initialisiert Supabase und liest `categories` count | Backend-Verfuegbarkeit, spaetere Sync-/Content-Pfade | aktiv im Startpfad | Supabase nicht verschweigen; konkrete Datenarten final pruefen |
| Legacy Supabase Words Auto-Sync | Supabase read -> lokale SQLite | Contentdaten | im Release durch `ReleaseSyncPolicy` standardmaessig aus | alter Content-Bootstrap | Debug aktiv, Release gegated | als nicht aktiven Release-Autoimport dokumentieren, final Build pruefen |
| Browser-/Share-Import | lokal + externe Browser/Share-Intents | vom Nutzer geteilte Texte/URLs | lokale Verarbeitung; externe Websites nur beim Browseroeffnen | Woerter aus Texten/Quellen aufnehmen | aktiv | als nutzerinitiierte Inhalte/Share-Funktion einordnen |
| Marketing/Analytics | SharedPreferences-Toggle | Praeferenz | aktuell keine aktive Analytics-Integration gefunden | spaetere Einwilligung/Steuerung | vorbereitet/unklar | vor Release entscheiden: deaktiviert lassen oder korrekt deklarieren |
| Voice/Audio im Chat | lokal aufgenommen, ggf. Speech-to-Text | Audio/Transkript | moeglich je nach Plattform/Feature | Sprachnachrichten/Diktat | vorbereitet/unklar aktiv | vor Release pruefen; bei Aktivitaet als Audio/Sprachdaten deklarieren |
| Bilder im Chat | lokale Fotoauswahl moeglich laut iOS Permission | Fotos/Dateipfade | unklar | Chat-Bildauswahl | vorbereitet/unklar aktiv | vor Release pruefen; falls aktiv, Fotos/Dateien deklarieren |

## 5. Wahrscheinliche Google-Play-Data-Safety-Antworten

Entwurf, final zu pruefen:

| Frage | Entwurfsantwort | Hinweis |
| --- | --- | --- |
| Sammelt die App personenbezogene Daten? | Wahrscheinlich ja, wenn Support-Mail, AI/Chat, Voice oder Supabase-Verbindung im Release aktiv sind. Rein lokale Lernstaende sind ebenfalls Daten in der App, aber nicht zwingend serverseitig gesammelt. | Final gegen Play-Definitionen und Datenschutztext pruefen. |
| Werden Daten geteilt? | Zu pruefen. Support-Mail geht an Mailanbieter/Talvori-Support; AI/Edge Functions/Supabase koennen externe Verarbeitung bedeuten. | Nicht vorschnell `nein` angeben, solange Supabase/AI aktiv sind. |
| Werden Daten verschluesselt uebertragen? | Wahrscheinlich ja fuer HTTPS/Supabase/talvori.eu/mailto-Provider, aber final technisch pruefen. | Play Console verlangt sichere Aussage. |
| Koennen Nutzer Daten loeschen? | Lokal ggf. durch App-Daten loeschen/OS; in App muessen konkrete Loeschpfade final geprueft werden. Support-Mail kann Loeschanfrage ermoeglichen. | In-App-Datenloeschung und Supportprozess klaeren. |
| Sind Daten optional oder erforderlich? | Lokale Lern-/Einstellungsdaten fuer App-Nutzung erforderlich bzw. funktional; Support-Mail, Notifications, Voice, AI optional. | Granular in Play Console abbilden. |
| Welche Datenarten koennten zutreffen? | App-Aktivitaet, App-Informationen und Leistung, Nutzergenerierte Inhalte, Audio, Fotos/Dateien, Kontaktinformationen bei Support-Mail. | Nur angeben, wenn im finalen Build aktiv. |
| Welche Datenarten treffen wahrscheinlich nicht zu? | Standort, Kontakte, Kalender, Gesundheitsdaten, Finanzdaten, SMS/Anruflisten. | Gegen Manifest und Dependencies final pruefen. |

## 6. MVP-Einschaetzung

### Aktiv Im MVP

- lokale Lernstaende und SRS-/`word_progress`-Daten
- lokale Woerter, Wortwelten, bekannte Woerter, Favoriten
- lokale App-, Sprach- und Onboarding-Praeferenzen
- externe Legal-/Support-Links zu `talvori.eu`
- Support-Mail, wenn Nutzer aktiv schreibt
- Supabase-Initialisierung und ein kleiner Kategorien-Read im Startpfad
- lokale Notifications-Infrastruktur; konkrete Nutzung final pruefen

### Vorbereitet, Aber Nicht Als Aktiv Bewerben

- Cloud-Backup
- Account-Sync
- produktiver Supabase-Content-Package-Sync
- Chat-Sync
- Premium/Abo
- vollstaendige Analytics
- TOEFL/IELTS/Cambridge-Content-Pakete

### Unklar / Vor Release Pruefen

- ob AI-/Companion-/Kategorie-Chat im MVP sichtbar aktiv bleibt
- ob KI-Wortspiele im finalen Store-Scope aktiv gezeigt werden
- ob `translate-word` fuer lokale Woerter im MVP aktiv erreichbar ist
- ob Tagesimpuls-Notifications im Release Nutzerzustimmung abfragen und planen
- ob Voice Recording, Speech-to-Text und lokale Audio-Dateien im MVP sichtbar nutzbar sind
- ob Fotoauswahl im Chat sichtbar nutzbar ist
- ob der Marketing-&-Analysen-Toggle nur lokal bleibt oder echte Analyse aktiviert
- welche Supabase-Netzwerkcalls im Release-Startpfad wirklich laufen
- ob Android App Links/http(s)-Intent-Filter in Store-Angaben oder Datenschutztexten erklaert werden muessen

## 7. Store-Risiken

- Falsche Data-Safety-Angaben koennen Store-Probleme verursachen.
- Supabase darf nicht verschwiegen werden, falls im Release tatsaechlich Daten uebertragen werden.
- AI/Companion muss klar beschrieben werden, falls Nutzertexte extern verarbeitet werden.
- Lokale Daten duerfen nicht als Cloud-Backup dargestellt werden.
- Support-Mail erzeugt personenbezogene Kommunikation ausserhalb der App.
- `RECORD_AUDIO`, Spracherkennung und Fotozugriff muessen im Store konsistent erklaert werden, wenn die Funktionen sichtbar sind.
- Der Marketing-&-Analysen-Toggle darf nicht suggerieren, dass Tracking laeuft, wenn keine Analytics aktiv ist; umgekehrt duerfen echte Analytics nicht undeklariert bleiben.

## 8. Konkrete Naechste ToDos

1. Release-Build technisch pruefen: Welche Netzwerkcalls laufen direkt beim Start?
2. Entscheiden, ob Supabase-Kategorien-Read im MVP-Release aktiv bleibt oder nur intern dokumentiert wird.
3. Entscheiden, ob AI/Companion/KI-Wortspiele fuer den MVP aktiv, sichtbar oder nur vorbereitet sind.
4. Entscheiden, ob Voice, Speech-to-Text und Fotoauswahl im MVP sichtbar bleiben.
5. Entscheiden, ob Marketing/Analytics im MVP komplett deaktiviert bleibt.
6. Notifications/Tagesimpuls gegen finalen Flow pruefen: Permission, Opt-in, Scheduling, Payload.
7. Datenschutzseite final auf lokale Daten, Supabase, AI, Support-Mail, Notifications, Voice und externe Links abstimmen.
8. Play Console Data Safety mit finalem Build und finalem Datenschutztext ausfuellen.
9. Support-/Loeschanfragen-Prozess dokumentieren.

## 9. Vorlaeufiger Store-Hinweis

Fuer den MVP sollte Talvori vorsichtig als lokal fokussierte, offline-first wirkende Lern-App beschrieben werden, aber nicht als rein offline oder komplett serverfrei, solange Supabase, AI-Funktionen, Support-Mail und externe Links im Build vorhanden sind.
