# Release-ToDo-Ausführung: Sichtbare vorbereitete Bereiche

Stand: 30.05.2026

Diese Arbeitsliste ergänzt die Release-ToDo-Analyse. Ziel dieses Blocks war nicht, geplante Produktbereiche zu entfernen, sondern sichtbare vorbereitete Bereiche zu bewerten und die schnellsten MVP-tauglichen UX-Verbesserungen umzusetzen.

## Grundsatz

Preview-, Coming-soon- und vorbereitete Bereiche bleiben Teil der Produktplanung. Sie sollen aber nicht wie zufällige Dummys wirken. Jeder Bereich wird daher einer von drei Entscheidungen zugeordnet:

1. **Kurzfristig MVP-fähig machen:** Text, Button-Verhalten oder leere Zustände verbessern.
2. **Hochwertig vorbereitet lassen:** als geplanten Bereich erklären, ohne Fake-Funktionalität.
3. **Später ausbauen:** größere Funktion dokumentieren und nicht halb fertig anfangen.

## Gefundene vorbereitete oder unfertige Bereiche

### Settings

- Anmeldung/Konto ist vorbereitet, aktuell lokal nutzbar.
- Hilfe, Feedback, Bewertung, Datenschutzrichtlinie und AGB sind sichtbare vorbereitete Bereiche.
- Premium/Abonnement ist sichtbar, aber noch kein echter Kauf- oder Abo-Flow.
- Entwicklerbereich mit Supabase-Import ist vorhanden.

Bewertung:

- **MVP-fähig mit Textverbesserung:** Anmeldung, Hilfe, Feedback, Datenschutz, AGB, Bewertung.
- **Späterer Ausbau:** echtes Konto, Abo-Flow, Support/Feedback-Kanal.
- **Release-Sicherheit:** Entwicklerbereich ist bereits über `kDebugMode` geschützt.

### Profil

- Premium, Sammlungen, Verlauf, Stimmen und Widgets sind als Produktbereiche sichtbar vorbereitet.
- Der Einstufungstest ist sichtbar, aber die echte Testlogik ist noch nicht aktiv.
- Wortwelten, Favoriten, Meine Wörter, Erinnerungen und Belohnungen sind echte oder bestehende Ziele.

Bewertung:

- **MVP-fähig mit Textverbesserung:** vorbereitete Profilbereiche klarer als Roadmap-/Ausbaubereiche erklären.
- **Bestehende echte Navigation behalten:** Favoriten, Meine Wörter, Wortwelten, Erinnerungen, Belohnungen.
- **Späterer Ausbau:** Premium, Sammlungen, Verlauf, Stimmen, Widgets und echter Einstufungstest.

### Home

- Der HomeScreen ist grundsätzlich nutzbar.
- V-Button führt in den lokalen Wörter-prüfen-Flow.
- Browser-/Share-Import ist sichtbar und wurde bereits optisch verbessert.

Bewertung:

- **MVP-nah:** Home bleibt Hauptentry.
- **Später prüfen:** weitere Feinjustierung für Chat-Hinweise, Companion-Verläufe und Browser-Import-Randfälle.

### Wortspiele / Arcade

- Viele Wortspiele sind echte Screens.
- Wort-Duell ist eine Preview.
- Einige Spielstatus sind als vorbereitet geplant.

Bewertung:

- **Nicht entfernen:** Wort-Duell bleibt als geplanter Mehrspieler-Ausblick sichtbar.
- **MVP-fähig mit Textverbesserung:** Preview-Text klarer als Ausblick ohne Fortschrittswirkung formulieren.
- **Späterer Ausbau:** echtes Duell, Multiplayer, Ranking und Duell-Anfragen.

### Tagesimpuls

- Tagesimpuls hat echte Auswahl-/Planungslogik, aber automatische Wortauswahl ist noch nicht aktiv.
- Testplanung für Impulse ist sichtbar.
- Notification-Debug-Panel existiert im Code.

Bewertung:

- **MVP-fähig mit Textverbesserung:** Status erklärt jetzt bewusste manuelle Wortauswahl statt unklarer späterer Automatik.
- **Späterer Ausbau:** automatische Wortauswahl.
- **Release-Sicherheit prüfen:** Debug-/Testelemente vor Release weiterhin genau prüfen.

### Companion / Chat

- Chat-Aktionen wie Weiterleiten, Vorlesen, Übersetzen und zusätzliche Reaktionen sind sichtbar vorbereitet.
- Kopieren, Reaktionen, Antworten, Fixieren, Stern und Löschen sind echte lokale Aktionen.

Bewertung:

- **MVP-fähig mit Textverbesserung:** geplante Chat-Aktionen werden hochwertiger erklärt.
- **Nicht entfernen:** geplante Chat-Erweiterungen bleiben sichtbar, solange sie nicht wie defekte Buttons wirken.
- **Späterer Ausbau:** Vorlesen, Übersetzen, Weiterleiten und erweiterte Reaktionen.

### Wortwelten / CategoryDetail

- `Alles freischalten` war sichtbar, aber ohne Aktion.
- Add-Button in CategoryDetail zeigte bisher `Add tapped`.
- Lokaler Debug-Lernscreen ist in CategoryDetail vorhanden.

Bewertung:

- **Direkt verbessert:** `Alles freischalten` zeigt jetzt Nutzerfeedback statt leerem Tap.
- **Direkt verbessert:** Add-Button erklärt jetzt den aktuellen Weg über Meine Wörter und Browser-Import.
- **Release-Sicherheit:** Debug-Lernscreen ist über `kDebugMode` geschützt.

### Developer / Debug

- Debug-Routen werden in `main.dart` nur in `kDebugMode` registriert.
- Entwickler-Sektion in Settings ist über `kDebugMode` sichtbar.
- CategoryDetail Debug-Button ist über `kDebugMode` geschützt.

Bewertung:

- **Nicht entfernt:** Debug-Werkzeuge bleiben für Entwicklung erhalten.
- **Release-sicher:** bestehende `kDebugMode`-Guards bleiben aktiv.
- **Später prüfen:** Release-Build-Snapshot oder Widget-Test, der Debug-Zugänge im Release-Kontext absichert.

## Direkt verbessert

- Settings-Platzhaltertexte für Anmeldung, Hilfe, Feedback, Datenschutz und AGB wurden professioneller formuliert.
- Settings-Premium wurde von „Premium ist vorbereitet“ auf eine klarere Premium-Erweiterung umgestellt.
- Profil-Premium, Sammlungen, Verlauf, Stimmen, Widgets und Hilfe wurden als bewusst vorbereitete Produktbereiche formuliert.
- Profil-Leveltest wurde klarer als Einstufung in Vorbereitung beschrieben.
- Wort-Duell-Preview wurde als geplanter Mehrspieler-Ausblick formuliert, ohne echte Fortschrittswirkung zu behaupten.
- Tagesimpuls-Status für fehlende Wortauswahl verweist nun auf bewusste manuelle Auswahl.
- Tagesimpuls-Teststatus klingt aktiver und weniger unfertig.
- Chat-Aktionen für Weiterleiten, Vorlesen, Übersetzen und zusätzliche Reaktionen zeigen klare geplante Zustände.
- CategoryDetail-Add-Button zeigt kein technisches `Add tapped` mehr.
- WordHub-Button `Alles freischalten` ist nicht mehr stumm, sondern erklärt geprüfte Wortwelten als Freischaltgrundlage.

## Bewusst nicht entfernt

- Premium-Bereiche
- Sammlungen
- Verlauf
- Stimmen
- Widgets
- Einstufungstest
- Wort-Duell-Preview
- Tagesimpuls-Automatik-Hinweise
- Chat-Erweiterungen
- Developer-/Debug-Werkzeuge in Debug-Builds

Diese Bereiche sind geplante Produktflächen und sollen nicht pauschal gelöscht werden.

## Später auszubauen

### Kleine bis mittlere Folgeaufgaben

1. Hilfe-/Feedback-Screen mit echtem lokalem Kontakt- oder Mail-Link ausstatten.
2. Rechtliche Screens mit finalen Datenschutz-/AGB-Texten füllen.
3. Premium-Screen als echte Vergleichs-/Wartelistenansicht ausarbeiten.
4. Einstufungstest als kleiner MVP-Test mit wenigen lokalen Fragen bauen.
5. Sammlungen als lokale Filter-/Listenlogik prüfen.
6. Verlauf zunächst als lokale Übersicht aus vorhandenen Belohnungs-/Lernereignissen aufbauen.

### Größere spätere Ausbauten

1. Echter Account- und Sync-Flow.
2. Echtes Premium-/Abo-System.
3. Wort-Duell mit Multiplayer, Anfrage, Ranking und Anti-Abuse-Regeln.
4. Chat-Vorlesen, Chat-Übersetzung und Weiterleiten.
5. Automatische Tagesimpuls-Wortauswahl.
6. Widget-Integration für iOS/Android.

## Empfohlene nächste Reihenfolge

1. Release-Build prüfen: Debug-Routen, Entwickler-Sektion und Debug-Buttons dürfen nicht sichtbar sein.
2. Rechtliche MVP-Seiten final befüllen.
3. Hilfe/Feedback als echten einfachen Kontaktpunkt aktivieren.
4. Einstufungstest-Flow entweder als MVP-Minifunktion bauen oder weiterhin bewusst vorbereitet lassen.
5. Premium- und Wort-Duell-Screens visuell weiter polieren, aber ohne Fake-Funktionalität.
6. Sichtbare Texte nach späterer l10n-Einführung zentralisieren.

## Unverändert gelassen

- Keine Supabase-Daten geändert.
- Kein Import ausgeführt.
- Keine SRS- oder `word_progress`-Daten geändert.
- Keine Vokabeldaten geändert.
- Keine Mehrsprachigkeits-/l10n-Umsetzung gestartet.
- Keine geplanten Produktbereiche entfernt.
