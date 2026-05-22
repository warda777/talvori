# Share-Import, Übersetzung und Home-Lernstart

Stand: 2026-05-21

## Ergebnis

- Geteilte Wörter aus Android und iOS werden lokal in der Kategorie `Meine Wörter` gespeichert.
- Neue lokale Importwörter erhalten ohne vorhandene Übersetzung den Status `pending`.
- Duplikate werden anhand des normalisierten Wortes erkannt und nicht erneut angelegt.
- Nach einem erfolgreichen Share-Import startet Talvori automatisch eine einzelne Übersetzung für das importierte bzw. wiedergefundene Wort, sofern noch keine fertige Übersetzung vorliegt.
- Bereits übersetzte Wörter lösen keine neue Übersetzungsanfrage aus; laufende Auto-Übersetzungen desselben Wortes werden lokal entdoppelt.
- Die Übersetzung läuft appseitig ausschließlich über den Supabase-Client zur Edge Function `translate-word`.
- Flutter enthält keinen DeepL-Key und ruft DeepL nicht direkt auf.
- Alte Flutter-seitige Direct-DeepL-Konfigurationen werden nicht mehr als produktiver Translation-Client erzeugt.
- Der lokale Fake-Translator ist nur noch für explizite Tests erlaubt. Im echten App-Lauf ist Supabase `translate-word` der Default; wenn kein Supabase-Caller verfügbar ist, schlägt die Übersetzung kontrolliert fehl und speichert keine `fake-*`-Übersetzung.
- Der Home-Word-Wheel und der Home-Counter verwenden die lokale Kategorie `Meine Wörter`.
- Der große Play-Button auf Home startet nicht mehr den alten QuickSets-/Legacy-Einstieg mit `All Words`, `My words`, `Favorites`, `Words I know`, `My mix`.
- Der Counter öffnet direkt die Vocabs-Seite für `Meine Wörter`; Zurück führt von dort direkt nach Home.
- Nur der große Play-Button auf der Home-Karte öffnet das bestehende Kategorie-/Quellen-Popup.
- Der normale untere `Üben`-Button bleibt beim klassischen Auswahlmenü mit `Vocabs` und `Course`.
- Der frühere untere linke 4-Kästchen-Einstieg wurde durch den Impuls-Postfach-Button ersetzt.
- Das Impuls-Postfach ist damit direkt unten links von Home erreichbar; vorhandene ungelesene Impulse werden dort als Badge angezeigt.
- Die lokale Quellen-Auswahl im Popup ist vom Detail `Meine Wörter` getrennt und bietet fünf lokale Quellen: `Alle Wörter`, `Favoriten`, `Meine Wörter`, `Wörter, die ich kenne`, `Mein Mix`.
- Jede Quelle öffnet eine eigene lokale CategoryDetail-ähnliche Detailseite mit deutschem Titel und lokalem Datenpfad.
- Lokale Detailseiten zeigen oben ein eigenes Quellen-Wheel mit ausschließlich `Alle Wörter`, `Favoriten`, `Meine Wörter`, `Wörter, die ich kenne`, `Mein Mix`.
- Dieses lokale Wheel verwendet keine Wortwelten-Kategorien und keine englischen Legacy-QuickSet-Labels.
- Quellenwechsel im lokalen Wheel bleibt im lokalen Detailkontext und startet keine Lernsession.
- Die lokalen Quellen verwenden getrennte Datenquellen und zeigen nicht mehr pauschal die `Meine Wörter`-Liste.
- Von der aktuell ausgewählten Detailquelle startet der Nutzer den bestehenden lokalen Lernmodus im aktuellen Wortwelten-Aufbau. Der Quellen-Back-Stack bleibt `Home -> Wortquellen -> lokale Detailseite -> Lernmodus`; der Counter-Back-Stack bleibt `Home -> Vocabs/Meine Wörter`.
- Die Lernkarten-Aktionen für Favorit und Tagesimpuls sitzen wieder rechts auf der Karte.
- Der Home-Counter nutzt eine feste Tap-Zone, damit der Tap keine horizontale Verschiebung erzeugt.

## Lokale Quellen

Die lokale CategoryDetail-Route nutzt einen zentralen Source-Typ statt sichtbarer Label-Strings. Die Detailseite, die Vocabs-Liste, die Counts und der lokale Übungsmodus fragen ihre Wörter source-basiert ab:

- `Alle Wörter`: alle nicht archivierten lokalen Wörter.
- `Meine Wörter`: nur lokal importierte/eigene Wörter aus `local-category-my-words`.
- `Favoriten`: nur lokal favorisierte Wörter aus dem lokalen Favoriten-Speicher; fehlende oder archivierte IDs werden ignoriert.
- `Wörter, die ich kenne`: Wörter mit vorhandenem lokalem Fortschritt in `S5` bzw. `isMastered`, rein lesend.
- `Mein Mix`: eine lokale Mischung aus Favoriten und zuletzt hinzugefügten, noch nicht bekannten Wörtern; wenn keine passende Basis existiert, bleibt die Quelle leer.

Leere Quellen zeigen eigene Empty States, z. B. `Noch keine Favoriten`, `Noch keine bekannten Wörter` oder `Noch kein Mix verfügbar`. Das Quellen-Wheel bleibt dabei sichtbar.

## Pending-Übersetzungen

`Meine Wörter` zeigt Wörter mit fehlender Übersetzung als `Übersetzung ausstehend` bzw. `Noch keine Übersetzung`.
Der Share-Import triggert nach dem lokalen Speichern asynchron den bestehenden Single-Word-Pfad des `PendingTranslationProcessor`.
Das Wort ist dadurch sofort lokal sichtbar; die Übersetzung wird danach über `translate-word` nachgeladen und lokal gespeichert.

Wenn das Gerät offline ist, kein Supabase-Client verfügbar ist, das serverseitige Limit erreicht wurde oder die Edge Function einen Fehler meldet, bleibt das Wort lokal erhalten und der Übersetzungsstatus bleibt `pending` oder `failed`.
Fehlerfälle speichern keine erfundenen Fake-Übersetzungen.
Der Button `Ausstehende Übersetzungen starten` bleibt als Fallback erhalten. Er verarbeitet nur Wörter ohne fertige Übersetzung, setzt fehlgeschlagene Übersetzungen kontrolliert zurück und nutzt ebenfalls den bestehenden `PendingTranslationProcessor`.

Bei Fehlern bleiben Wörter lokal erhalten. Fehlgeschlagene Übersetzungen können erneut versucht werden.

Gleiche Share-Payload-IDs werden nicht erneut verarbeitet. Derselbe Worttext mit neuer Share-ID läuft erneut durch den Importpfad, erzeugt aber wegen der normalisierten Duplikaterkennung keinen zweiten lokalen Worteintrag.

## Serverseitige Kostenkontrolle

Die Edge Function `translate-word` bleibt der einzige DeepL-Zugang.

Serverseitig berücksichtigt:

- maximale Textlänge pro Anfrage
- tägliches Request-Limit über `TRANSLATION_DAILY_REQUEST_LIMIT`
- tägliches Zeichenlimit über `TRANSLATION_DAILY_CHARACTER_LIMIT`
- Usage Events in `translation_usage_events`
- per-user Buckets, wenn ein Supabase JWT verifiziert werden kann
- globaler Fallback-Bucket für anonyme/dev Requests

Typische Fehlercodes:

- `invalid_input`
- `quota_exceeded`
- `translation_request_failed`
- `translation_failed`

## SRS-Schutz

Import, Auto-Übersetzung, manuelle Pending-Übersetzung, Home-Counter und Word-Wheel lesen bzw. speichern nur lokale Wortdaten und Übersetzungsstatus.
Sie starten keine Lernsession automatisch und verändern keine bestehenden Lernfortschritte.
SRS-Fortschritt entsteht erst im explizit geöffneten Lernmodus durch Nutzeraktionen.

## Profilbereich

Der Profil-Button auf Home führt weiterhin in den Profilbereich, dieser ist jetzt als deutscher Talvori Dark-Neon-Kontrollraum strukturiert statt als altes Mock-Profil.

Die alten Profil-Schwerpunkte `Your Vocabulary`, `Favoriten`, `Deine eigenen` und `Sammlungen` wurden als Navigations-/Kachelbereiche entfernt, weil diese Inhalte über Vocabs, Wortquellen und lokale Detailseiten sinnvoller erreichbar sind.

Der Profilbereich enthält jetzt:

- `Dein Lernen`: Lernstreak aus dem bestehenden Profil-State sowie lokale Counts für `Meine Wörter`, bekannte Wörter, markierte Wörter und offene Übersetzungen.
- `Sprache & Aussprache`: lokale Lernrichtung, Geräte-TTS-Test, Auto-Aussprache-Vorbereitung und der Hinweis auf `translate-word` als serverseitigen DeepL-Weg.
- `Benachrichtigungen`: bestehende Tagesimpuls-Einstellung plus lokale vorbereitete Schalter für Lern- und Übersetzungserinnerungen.
- `Impuls & KI`: globales Impuls-KI-Profil mit Antwortstil, Antwortlänge, Lernziel und Erklärungssprache.
- `App-Einstellungen`: lokale Schalter für Haptik, Sound/Aussprache, Animationen sowie App-Sprache und Design-Info.
- `Daten & Hilfe`: Importzählung, Übersetzungsstatus, lokaler Datenschutz-Hinweis und App-Version.

Neue Profil-Einstellungen werden lokal über SharedPreferences gespeichert. Sie verändern keine SRS-Werte, starten keine Lernsession und erzeugen keinen Server-Push.

Die Profilkarten verwenden flexible Kennzahlen-Kacheln und rechtsbündige Werte-Spalten, damit deutsche Labels und längere Statuswerte auf iPhone-Breite ohne RenderFlex-Overflow lesbar bleiben. Der Header nutzt wie die übrigen Detailseiten einen Zurück-Pfeil statt eines Schließen-X.
