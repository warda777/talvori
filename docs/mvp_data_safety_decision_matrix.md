# MVP Data Safety Decision Matrix

Stand: 2026-05-31

Diese Matrix klaert die offenen Data-Safety-Entscheidungen gegen den aktuellen Code- und Buildstand. Sie ist eine technische Release-Vorbereitung, keine Rechtsberatung und keine finale Play-Console-Angabe.

## Gepruefte Einstiegspunkte

- `lib/main.dart`: Supabase-Initialisierung, Kategorien-Read, `ReleaseSyncPolicy`, Notifications-Initialisierung
- `lib/features/home/ui/screens/settings_screen.dart`: Legal-/Support-Links, Marketing-&-Analysen-Toggle, Debug-only Import
- `lib/features/home/ui/screens/profile_screen.dart`: Support-Link, Erinnerungen, Wortwelten, vorbereitete Bereiche
- `lib/features/home/ui/screens/home_screen.dart`: Companion-Eingabe, Impuls-Postfach, Aussprache
- `lib/features/home/ui/screens/course_screen.dart`: Tagesimpuls-Auswahl, AI-Generierung, Notification-Planung
- `lib/features/impuls_postfach/...`: Chat, Companion, Voice, Fotoauswahl, lokale Speicherung
- `lib/features/home/ui/screens/word_game_arcade_screen.dart` und KI-Spiel-Provider
- `lib/core/local_database/...`: SQLite, Share-Import, Translation-Edge-Function, lokale Woerter/SRS
- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`

## Entscheidungsmatrix

| Bereich | Sichtbar im MVP? | Technisch aktiv? | Sendet Daten extern? | Enthalt personenbezogene Daten? | Data-Safety-Relevanz | Entscheidung fuer MVP | Offene Pruefung |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Lokale Lernstaende / `word_progress` | ja | ja, lokal SQLite | nein im normalen lokalen Lernpfad | Nutzungs-/Lernfortschrittsdaten | App-Aktivitaet lokal | aktiv, lokal beschreiben | Loesch-/Reset-Pfad final klaeren |
| Lokale Woerter / Wortwelten | ja | ja, lokal SQLite/Assets | nein im lokalen Pfad | Contentdaten; eigene Woerter koennen nutzergeneriert sein | App-Inhalte und nutzergenerierte Inhalte lokal | aktiv, lokal/offline-first beschreiben | sichtbaren MVP-Bestand weiter qualitaetssichern |
| Favoriten / bekannte Woerter | ja | ja, lokal | nein | Nutzungs-/Lernpraeferenzen | App-Aktivitaet lokal | aktiv, lokal beschreiben | keine Cloud-Sicherung behaupten |
| App-/Sprachpraeferenzen | ja | ja, SharedPreferences | nein | Einstellungen/Profilpraeferenzen | App-Informationen/Praeferenzen | aktiv, lokal beschreiben | Datenschutztext gegen Settings-Felder pruefen |
| Supabase Initialisierung | nicht als Feature sichtbar | ja beim Start | ja: Supabase Init und `categories` Read | eher technische Verbindung; keine aktive Nutzeraccount-Daten im MVP | Netzwerk-/Backend-Nutzung | aktiv, transparent in Datenschutz/Data Safety beruecksichtigen | finalen Release-Start mit Netzwerk beobachten |
| Supabase Legacy Auto-Sync | nein | Debug ja, Release durch Policy false | im Release standardmaessig nein | nein, Contentdaten | gering fuer Release, aber wichtig dokumentiert | nicht als MVP-Release-Funktion; gegated | finaler Release-Build muss Guard bestaetigen |
| Supabase Content-Pakete | nein | nur vorbereitet/Policy/Modelle | nein, kein produktiver Sync | nein | nicht aktive Zukunftsfunktion | nicht bewerben, nicht in Data Safety als aktive Datenerhebung behandeln | spaeter bei Paket-Sync neu bewerten |
| Support-Mail | ja | ja per `mailto:` | ja, nur wenn Nutzer aktiv schreibt | ja, E-Mail/Inhalt moeglich | Kontaktinformationen/Nutzerkommunikation | aktiv optional; in Store/Datenschutz erwaehnen | Support-/Loeschanfragenprozess final beschreiben |
| Legal-/Support-Weblinks | ja | ja per `url_launcher` | ja, beim Oeffnen der Website | Webserver-/Browserdaten moeglich | externe Website-Aufrufe | aktiv; Weblinks transparent nennen | talvori.eu Datenschutz final konsistent halten |
| Tagesimpuls/Notifications | ja | ja optional; Scheduling nach Nutzeraktion und genug Woertern | ja fuer AI-Generierung `generate-daily-impulses`; lokale Notification selbst nein | ausgewaehlte Woerter und Impulsdaten | Notifications + externe AI-Verarbeitung | optional aktiv, aber nicht als rein lokal darstellen | Permission-/Scheduling-Flow im finalen Release-Geraetetest pruefen |
| AI/Companion | ja | ja; Home-Companion und Chat nutzen `ai-chat` mit Fallback | ja bei Nachricht an Supabase Edge Function | ja, Nutzertexte/Chatkontext | nutzergenerierte Inhalte/externe Verarbeitung | aktiv sichtbar, aber vorsichtig bewerben; Data Safety relevant | Datenschutztext muss AI-Verarbeitung klar beschreiben |
| KI-Wortspiele/Kontext-Challenge | ja, einzelne Modi/Arcade | ja, KI-Modi koennen `ai-chat` nutzen | ja, wenn KI-Modus gestartet wird | Wort-/Kontextdaten, ggf. Nutzerinteraktion | externe Verarbeitung | als optional aktive KI-Funktion behandeln; nicht uebertreiben | Store-Screenshots nur stabile Modi; KI-Nutzung final testen |
| Browser-/Share-Import | ja/vorhanden | ja, Android Share Intents und Listener; lokale Speicherung | direkte Verarbeitung lokal; externe Website nur durch Browser/Weblinks | geteilte Texte/URLs koennen nutzerbezogen sein | nutzergenerierte Inhalte | aktiv, aber nur als nutzerinitiierter Import/Share beschreiben | iOS/Android Share-Flows final testen |
| Marketing & Analysen | ja als Toggle | nur lokale Praeferenz gefunden | nein, keine aktive Analytics-/Firebase-Integration gefunden | Einwilligungs-/Settingwert lokal | gering solange kein Tracking aktiv | fuer MVP: nicht aktiv, nicht bewerben; Toggle als vorbereitet/lokal einordnen | vor Einreichung erneut nach Tracking-SDKs suchen |
| Foto/Kamera | Fotoauswahl im Chat sichtbar; Kamera nicht gefunden | `image_picker` Gallery im Chat aktiv | nein im lokalen Pfad; Bildpfad lokal gespeichert | Fotos/Bilder koennen personenbezogen sein | Fotos/Dateien optional | Fotoauswahl als optional aktiv behandeln; Kamera nicht als aktiv | iOS/Android Permission-Verhalten final testen |
| Mikrofon/Audio/Voice | ja im Chat | ja; `record`, `speech_to_text`, lokale Audio-Datei, Transkript | Audio-Datei bleibt lokal; Transkript kann bei Chatantwort an `ai-chat` gehen | Audio/Sprachdaten/Transkript | Audio + externe Verarbeitung bei Transkript | optional aktiv und Data-Safety-relevant | Sprach-/OS-Dienst und Permission-Flow final pruefen |
| Account/Cloud-Backup | Login-Placeholder sichtbar | nein als Nutzerfunktion | nein | nicht aktiv | nicht aktive Zukunftsfunktion | nicht bewerben, nicht als aktiv angeben | spaeter eigenes Datenschutz-/Sync-Konzept |
| Premium/Abo | Preview/Placeholder sichtbar | kein Payment-Flow gefunden | nein | nein | nicht aktive Zukunftsfunktion | nicht bewerben, keine Store-Versprechen | Store-Texte/Screenshots meiden |

## Klare MVP-Entscheidungen

- Marketing & Analysen: im aktuellen Code nur lokale Praeferenz, keine gefundene aktive Analytics-/Tracking-Integration. Fuer MVP als nicht aktiv behandeln und nicht bewerben.
- AI/Companion: sichtbar und technisch ausloesbar. Nutzertexte koennen an Supabase Edge Function `ai-chat` gesendet werden. Fuer Data Safety als aktive optionale externe Verarbeitung behandeln.
- KI-Wortspiele: KI-bezogene Modi sind technisch vorhanden. Als optionale KI-Funktion behandeln, aber im Store nicht als Hauptversprechen ueberzeichnen.
- Tagesimpuls/Notifications: sichtbar und optional aktiv. Die lokale Notification ist lokal, aber die Impuls-Generierung nutzt Supabase Edge Function `generate-daily-impulses`. Data Safety muss beide Teile unterscheiden.
- Supabase: im Release nicht nur vorbereitet, sondern beim Start initialisiert und mit kleinem `categories`-Read genutzt. Kein Nutzer-Cloud-Sync und kein unkontrollierter Legacy-Auto-Import im Release.
- Voice/Audio/Foto: im Chat sichtbar/ausloesbar. Audio bleibt lokal, Transkript kann bei Chatantwort extern verarbeitet werden; Fotoauswahl speichert lokale Pfade. Optional aktiv und Data-Safety-relevant.
- Browser-/Share-Import: technisch aktiv als nutzerinitiierter Importpfad. Nicht als automatisches Scraping darstellen.
- Translation-Edge-Function: technisch erreichbar bei ausstehenden/eigenen Woertern, insbesondere nach Share-/Textimport oder manuellem Uebersetzen. Nicht als fertige KI-Uebersetzungsqualitaet bewerben; als externe Verarbeitung beruecksichtigen, wenn im MVP erreichbar.

## Nicht Bewerben

- Kein Cloud-Backup oder Account-Sync.
- Kein produktiver Content-Package-Sync.
- Keine vollstaendige Analytics-/Tracking-Funktion.
- Keine fertigen Premium-/Abo-Funktionen.
- Keine TOEFL-/IELTS-/Cambridge-Pakete.
- Keine vollstaendige Mehrsprachigkeits- oder 13k-Content-Freigabe.
- Keine Aussage, dass AI/Companion rein lokal arbeitet.

## Naechste Pruefungen Vor Store-Einreichung

1. Finalen Release-Build auf Geraet mit Netzwerkmonitoring/Logs pruefen: Start, Supabase, AI, Tagesimpuls, Share-Import.
2. Play-Console-Data-Safety anhand dieser Matrix und finalem Datenschutztext ausfuellen.
3. Datenschutzseite fuer AI/Companion, Tagesimpuls, Voice/Audio, Foto, Support-Mail, externe Links und Supabase-Startpfad final konsistent machen.
4. Entscheiden, ob Voice/Foto/KI-Screens in Store-Screenshots komplett vermieden werden.
5. Loesch-/Supportprozess fuer lokale Daten, Support-Mails und ggf. AI-Anfragen dokumentieren.
