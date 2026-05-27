# Companion AI Chat MVP

## 1. Ziel

Der Talvori Companion soll im Home Screen nicht nur lokale Discovery-Tipps anzeigen, sondern eine kurze Nutzereingabe annehmen und darauf knapp antworten können.

Der MVP ist bewusst klein gehalten: keine vollständige Chat-App, keine neue Persistenzschicht und keine große Home-Umgestaltung.

## 2. Architektur

Der Datenfluss ist:

Home UI → `CompanionController` → `CompanionAIService` → vorhandener `AiChatClient`

Vorhandene KI-Struktur:

- `core/ai/ai_chat_client.dart`
- `core/ai/supabase_ai_chat_client.dart`
- Edge Function `ai-chat`
- bestehende Nutzung im Impuls-Postfach und im internen AI-Chat-Test

Der Home Screen spricht nicht direkt mit Supabase oder einer KI-API. Er ruft den Companion-Service auf.

## 3. Home-Eingabe

Die Companion-Bubble enthält ein kleines Chat-Icon. Ein Tap darauf öffnet eine kompakte Eingabe direkt im Companion-Overlay.

Die Eingabe:

- ist nur sichtbar, wenn `CompanionState.inputVisible == true`
- erzeugt keine zusätzliche Höhe im normalen Home-Column-Layout
- sendet keine leeren Nachrichten
- wird nach dem Senden geleert und bleibt offen

## 3.1 Keyboard-Docking und dynamische Eingabe

Die Eingabe ist als eigenes HomeScreen-Overlay umgesetzt und nicht Teil der CompanionCard.

Wenn die Tastatur offen ist, dockt die Eingabe über `MediaQuery.viewInsets.bottom` direkt oberhalb der Tastatur an. Der Companion wird in diesem Zustand kleiner dargestellt und relativ zur Eingabe positioniert, damit Maskottchen und Bubble wie ein zusammenhängender Chat-Bereich oberhalb des Textfelds wirken.

Das Textfeld wächst von einer bis auf maximal fünf Zeilen. Danach scrollt der Text intern im Feld. Nach dem Senden wird der Controller geleert, sodass die Eingabe beim nächsten Öffnen wieder einzeilig startet.

## 3.2 Chat bleibt nach dem Senden offen

Nach dem Senden bleibt der Companion-Chat im aktiven Chat-Modus:

- die Tastatur bleibt offen
- die Eingabe wird geleert und fällt auf eine Zeile zurück
- der Fokus bleibt im Textfeld
- Thinking- und Antwort-Bubble erscheinen oberhalb der Eingabe
- der Nutzer entscheidet selbst, wann der Chat geschlossen wird

Der Chat wird nur durch bewusstes Schließen beendet, zum Beispiel durch Tippen außerhalb des Overlays oder durch manuelles Schließen der Tastatur. Die Antwort-Bubble darf im Chat-Modus mehr Zeilen nutzen als im normalen Discovery-Modus.

## 4. Thinking- und Antwort-Verhalten

Nach dem Senden:

- `CompanionController.submitUserMessage()` setzt den Companion in den Thinking-State
- Bubble zeigt: `Ich denke kurz nach ...`
- Mood: `thinkingChin`
- Idle-/Compact-Timer wird pausiert

Nach der Antwort:

- Bubble zeigt die kurze Antwort
- Mood: `happy`
- Idle-/Compact-Timer startet wieder

Bei Fehlern wird eine freundliche Fehlermeldung angezeigt.

## 5. Kontext für KI

Der MVP-Kontext ist klein:

- Anzahl eigener Wörter
- letzte Companion-Nachricht
- grober Lernstatus
- optional später Nutzername und aktueller Discovery-Tipp

Der Kontext enthält keine sensiblen Daten und keine großen Verlaufspakete.

## 6. Verhältnis zum Impuls-Postfach

Das Impuls-Postfach hat bereits Chat- und Nachrichtenmodelle. Für diesen MVP wird der Companion-Home-Chat aber noch nicht dort persistiert.

Grund:

- Der Home-Chat soll zunächst stabil als kurzer Companion-Moment funktionieren.
- Persistenz ins Postfach braucht eine klare Produktentscheidung: eigener Companion-Chat, täglicher Verlauf oder Integration in bestehende Chats.

Die Schnittstelle bleibt so vorbereitet, dass Persistenz später ergänzt werden kann.

## 7. Was bewusst noch nicht umgesetzt ist

- keine neue KI-Infrastruktur
- keine direkten API-Keys im Code
- keine Chat-Persistenz
- keine Sprachnachrichten
- kein vollständiger Chatverlauf auf Home
- keine Streaming-Antworten
- keine KI-Kontextsammlung aus vielen Providern
- keine Änderungen an Supabase-Daten, SRS, Import oder Wortspielen

## 8. Tests

Ergänzt wurden Tests für:

- Companion-Controller-Chatzustände
- Companion-AI-Service mit Mock-Client
- lokalen Fallback bei fehlender KI
- Home-Chat-Eingabe
- Thinking-Bubble
- Antwort-Bubble

## 9. Nächste Schritte

- echten Companion-Chat im Impuls-Postfach modellieren
- Nutzungsflags und Discovery-Kontext persistieren
- Companion-Hinweise konfigurierbar machen
- KI-Antworten mit mehr lokalem Lernkontext anreichern
- Antwortlänge und Ton über Edge Function sauber begrenzen
