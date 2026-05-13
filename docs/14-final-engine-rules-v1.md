# 14 Final Engine Rules V1

Stand: 2026-05-13

## Zweck

Dieses Dokument fasst die aktuell entschiedenen Version-1-Regeln für die lokale SRS-Engine zusammen. Es ist eine fachliche Kurzspezifikation, kein Implementierungsplan und kein Dart-Code.

## Grundsätze

- Flutter/Dart bleibt die einzige App-Technologie.
- Die App ist offline-first.
- SQLite ist die lokale Datenbasis.
- Die SRS-Engine hat keine direkte SQLite-Abhängigkeit.
- Die Engine entscheidet nur Lernlogik.
- Das Repository speichert Daten.
- UI, Engine und Datenbank bleiben getrennt.

## Engine-Zuständigkeit

Die Engine entscheidet:

- Stage-Wechsel
- `next_due_at`
- Requeue
- neue Karten ja/nein
- Session-Queue

Die Engine speichert nicht selbst.

## Repository-Zuständigkeit

Das Repository speichert:

- Wörter
- Kategorien
- Fortschritt
- Sessions
- Review-Historie
- Einstellungen

## SQLite-Mindestmodell

Für Version 1 werden mindestens diese Tabellen geplant:

- `categories`
- `words`
- `word_progress`
- `review_history`
- `learning_sessions`
- `session_items`
- `settings`

`word_progress` speichert Fortschritt pro Wort, Kategorie und Modus getrennt und benötigt mindestens:

- `word_id`
- `category_id`
- `mode_id`
- `stage`
- `pass_count`
- `wrong_count`
- `next_due_at`
- `last_reviewed_at`

## Stufen

- S0: neu
- S1: begonnen
- S2: im Aufbau
- S3: gefestigt
- S4: sicher
- S5: Langzeit

S5 ist der höchste aktive und wiederholbare Langzeitstatus. S5 ist kein endgültiger Abschlusszustand.

## Session-Größe

Version-1-Standard:

- Standard-Sessiongröße: 20 Karten
- Die Session-Queue ist endlich und wird beim Session-Start erzeugt und gespeichert.
- Eine spätere Nutzerwahl 10/20/40 bleibt eine spätere Option.
- Für Version 1 ist 20 der Standardwert.

## is_mastered

`is_mastered` wird nicht als harter Engine-Zustand verwendet.

- S5-Karten dürfen nicht aus der Wiederholung verschwinden.
- `is_mastered` darf später höchstens Anzeige- oder Statistikfeld sein.
- `is_mastered` darf keine Karte aus Queue, Fälligkeit oder Engine entfernen.

## Aufstieg

Version-1-Aufstiegsregel:

- S0 -> S1 nach 1 richtiger Antwort
- S1 -> S2 nach 2 richtigen Antworten
- S2 -> S3 nach 2 richtigen Antworten
- S3 -> S4 nach 3 richtigen Antworten
- S4 -> S5 nach 3 richtigen Antworten

Bei Aufstieg wird `pass_count` für die neue Stufe zurückgesetzt.

## Rückfall

Bei falscher Antwort:

- `pass_count = 0`
- `wrong_count` steigt
- Karte wird requeued
- Rückfall je nach Stufe:
  - S0 falsch -> S0
  - S1 falsch -> S1
  - S2 falsch -> S1
  - S3 falsch -> S2
  - S4 falsch -> S3
  - S5 falsch -> S3

S5 fällt nicht auf S0 zurück.

## T-SRS: Nach Zeitplan

T-SRS arbeitet vollständig zeitbasiert.

Version-1-Intervalle:

- S0: sofort / neu
- S1: 1 Tag
- S2: 3 Tage
- S3: 7 Tage
- S4: 14 Tage
- S5: 30 Tage

T-SRS darf S1-Karten am selben Tag zur Festigung erneut zeigen. Ein weiterer Aufstieg am selben Tag ist aber nicht erlaubt.

Beispiel:

- S0 richtig -> S1
- am selben Tag erneut richtig -> bleibt S1
- erst ab dem nächsten Tag kann S1 zu S2 werden

## A-SRS: Intensiv lernen

A-SRS hat:

- kein hartes Tageslimit
- keine zeitliche Sperre für Stufenaufstieg
- getrennten Fortschritt von T-SRS und Hybrid
- eine endliche technische Session-Größe

A-SRS darf bewusst ermöglichen, dass Nutzer für eine Prüfung viele oder alle Karten an einem Tag intensiv durcharbeiten.

Karten dürfen bei ausreichender Leistung am selben Tag bis S5 aufsteigen.

Eine einzelne A-SRS-Session wächst trotzdem nicht endlos:

- Die Session startet mit der Version-1-Standardgröße von 20 Karten.
- A-SRS darf innerhalb einer Session bis zu 20 Karten aus S0 enthalten, wenn keine aktiven Wiederholungskarten vorhanden sind.
- Wenn aktive Wiederholungskarten vorhanden sind, verwendet A-SRS eine deterministische 2:1-Mischregel: zwei aktive Wiederholungskarten, dann eine neue S0-Karte.
- Wenn nicht genug Wiederholungskarten vorhanden sind, dürfen freie Plätze mit neuen S0-Karten gefüllt werden.
- Neue S0-Karten werden nicht unkontrolliert automatisch nachgeladen.
- Nach Ende einer Session darf der Nutzer bewusst weiterlernen oder eine weitere A-SRS-Session starten.
- Weiterlernen ist eine Nutzerentscheidung, kein automatischer Endlos-Refill.

Schutz gegen zu schnelles Lernen erfolgt durch:

- mehrere notwendige richtige Antworten pro Stufe
- Rückfall bei Fehlern
- erneutes Zeigen falscher Karten
- strengere Anforderungen in höheren Stufen
- wiederholbare S5-Karten

## Hybrid: Ausgewogen lernen

Hybrid kombiniert freie frühe Stufen und zeitbasierte höhere Stufen.

Version-1-Regel:

- S0-S2: eher wie A-SRS / Intensiv lernen
- S3: 1 Tag
- S4: 3 Tage
- S5: 5 Tage

S5-Karten verschwinden nicht dauerhaft.

## Neue Karten Pro Session

Version-1-Regeln:

- T-SRS: maximal 5 neue S0-Karten pro Session
- Hybrid: maximal 8 neue S0-Karten pro Session
- A-SRS: kein Tageslimit, aber pro einzelner Session technisch auf die Standardgröße von 20 Karten begrenzt
- A-SRS: bis zu 20 S0-Karten in einer Session, wenn keine aktiven Wiederholungskarten vorhanden sind
- A-SRS: wenn aktive Wiederholungskarten vorhanden sind, gilt die 2:1-Mischregel: zwei aktive Wiederholungskarten, dann eine neue S0-Karte
- A-SRS: wenn nicht genug Wiederholungskarten vorhanden sind, dürfen freie Plätze mit neuen S0-Karten gefüllt werden
- A-SRS kann durch bewusstes Weiterlernen oder eine weitere A-SRS-Session fortgesetzt werden
- Keine neue Karte wird durch einen unkontrollierten automatischen Endlos-Refill eingeführt

## Fehlerquote

Wenn innerhalb der letzten 10 Antworten mindestens 3 Fehler auftreten:

- T-SRS: keine neuen S0-Karten mehr in dieser Session
- Hybrid: keine neuen S0-Karten mehr in dieser Session
- A-SRS: kein automatischer Nachschub neuer S0-Karten

Bereits aktive Wiederholungen laufen weiter.

Für A-SRS ist diese Regel keine harte Lernblockade. Sie stoppt nur automatischen Nachschub. Der Nutzer darf bewusst weiterlernen oder eine weitere A-SRS-Session starten, weil der Modus für Prüfungssituationen gedacht ist.

## Mehrfach-Requeue

Bei falsch beantworteter Karte:

1. Fehler derselben Karte in derselben Session: nach ca. 10 anderen Karten erneut zeigen.
2. Fehler derselben Karte in derselben Session: nach ca. 5 anderen Karten erneut zeigen.
3. Fehler derselben Karte in derselben Session: als schwierig markieren und ans Ende der aktuellen Session-Queue legen.

Die Karte darf nicht dauerhaft aus der Wiederholung verschwinden.

## Gezielt Üben

`Gezielt üben` verändert in Version 1 nicht die normale SRS-Progression.

Es ändert nicht:

- `stage`
- `pass_count`
- `next_due_at`
- S5-Status

Richtige und falsche Antworten dürfen später optional als separate Statistik gespeichert werden.

## Zurückgestellte Themen

Supabase-Datenmigration und DeepL/Wortimport werden für jetzt zurückgestellt. Sie dürfen als spätere Launch- oder Post-Launch-Themen dokumentiert werden, blockieren aber nicht die erste lokale Engine.

## Weiter Zu Testen

- Hybrid-S5 alle 5 Tage bei großen Kategorien.
- A-SRS-Prüfungssituation mit vielen Karten am selben Tag.
- Rückfälle, die S2 überfüllen könnten.
- Fehlerquote-Regel bei kleinen Sessions.
- Mehrfach-Requeue bei kurzer Queue.
