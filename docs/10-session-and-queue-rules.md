# 10 Session And Queue Rules

Stand: 2026-05-13

## Ziel

Sessions müssen robust, fortsetzbar und nicht manipulierbar sein. Die Queue ist Teil des Lernzustands und darf nicht nur flüchtig im Speicher existieren.

## Session-Erzeugung

Beim Start einer Lernsession:

1. App prüft, ob eine aktive Session für `profile_id + category_id + mode_id + training_area_id` existiert.
2. Falls ja: bestehende Session laden und fortsetzen.
3. Falls nein: neue Session erzeugen.
4. Queue nach Modus-/Bereichsregeln erzeugen.
5. Session und Queue sofort in SQLite speichern.

Regel: Es darf pro Kategorie, Modus und Trainingsbereich nur eine aktive Session geben.

## Session-Größe

Version-1-Standard:

- Standard-Sessiongröße: 20 Karten.
- Die Session-Queue ist endlich und wird beim Erzeugen der Session gespeichert.
- Eine spätere Nutzerwahl 10/20/40 bleibt eine spätere Option.
- Für Version 1 ist 20 der Standardwert.
- A-SRS hat kein Tageslimit, aber auch A-SRS-Sessions haben diese technische Session-Größe.
- Nach Ende einer A-SRS-Session darf der Nutzer bewusst weiterlernen oder eine weitere A-SRS-Session starten.

## Laufende Session speichern

Persistiert werden:

- Session-ID
- aktueller Index
- Queue-Version
- alle Session-Items mit Position
- Status jedes Items
- Review-Events
- Requeue-Positionen
- Fortschrittsänderungen

Wichtig: Nach jeder Antwort wird zuerst persistiert, dann UI aktualisiert.

## Fortsetzung nach App-Neustart

Beim App-Start:

- aktive Sessions bleiben aktiv.
- Start in derselben Kategorie/Modus/Bereich führt zur Fortsetzung.
- Queue wird nicht neu gemischt.
- Fehler und Requeues bleiben erhalten.

Wenn eine Session vollständig abgeschlossen ist:

- Status `completed`.
- Erst danach darf eine neue Session erzeugt werden.

## Manipulationsschutz

Nicht erlaubt:

- falsche Antwort durch App-Schließen verlieren
- Queue durch Neustart neu würfeln
- Fortschritt durch Abbruch zurücksetzen
- neue Session erzeugen, obwohl aktive Session existiert

Technische Regeln:

- Review-Event atomar mit Progress-Update speichern.
- Requeue atomar mit Fehler speichern.
- `current_index` nach persistierter Antwort weiterbewegen.
- Session-Abbruch ist kein Reset.

## Fehler-Requeue

Anforderung:

- Falsch beantwortete Karten erscheinen ungefähr nach 10 anderen Karten erneut.

Grundregel:

- `retry_after_cards = 10`
- Wenn mindestens 10 andere noch offene Karten vorhanden sind: Karte an Position `current_position + 10` einfügen.
- Wenn weniger als 10 andere Karten vorhanden sind: Karte ans Ende der aktuellen Queue.
- Karte bleibt in der Session und im Fortschritt sichtbar.
- `pass_count = 0`.
- Rückfall je nach Stufe anwenden.

Bei mehrfachen Fehlern:

- 1. Fehler derselben Karte in derselben Session: nach ca. 10 anderen Karten erneut zeigen.
- 2. Fehler derselben Karte in derselben Session: nach ca. 5 anderen Karten erneut zeigen.
- 3. Fehler derselben Karte in derselben Session: als schwierig markieren und ans Ende der aktuellen Session-Queue legen.
- Die Karte darf nicht dauerhaft aus der Wiederholung verschwinden.
- Keine Duplikate gleichzeitig aktiv; ein bestehender Retry-Eintrag wird aktualisiert.

## Neue Karten aus S0

Regeln:

- S0 wird nur in `Alles lernen` eingeführt.
- `Nur wiederholen` führt keine neuen Karten ein.
- `Gezielt üben` ist in Version 1 Fokus-Training außerhalb der normalen SRS-Progression.
- `Gezielt üben` verändert nicht `stage`, `pass_count`, `next_due_at` oder S5-Status.
- `Gezielt üben` führt in Version 1 keine neuen S0-Karten in die normale SRS-Progression ein.
- T-SRS und Hybrid beachten Tages-/Sessionlimits.
- A-SRS beachtet kein hartes Tageslimit, aber Session-Caps.
- T-SRS führt maximal 5 neue S0-Karten pro Session ein.
- Hybrid führt maximal 8 neue S0-Karten pro Session ein.
- A-SRS lädt neue S0-Karten nicht unkontrolliert automatisch nach; weiteres neues Material entsteht durch bewusste Nutzerentscheidung zum Weiterlernen oder durch eine weitere A-SRS-Session.
- A-SRS nutzt bei aktiven Wiederholungskarten die 2:1-Mischregel: zwei aktive Wiederholungskarten, dann eine neue S0-Karte.
- Wenn in A-SRS nicht genug Wiederholungskarten vorhanden sind, dürfen freie Plätze mit neuen S0-Karten gefüllt werden.

Wenn innerhalb der letzten 10 Antworten mindestens 3 Fehler auftreten:

- T-SRS: keine neuen S0-Karten mehr in dieser Session.
- Hybrid: keine neuen S0-Karten mehr in dieser Session.
- A-SRS: kein automatischer Nachschub neuer S0-Karten; bewusstes intensives Weiterlernen kann erlaubt bleiben.
- Bereits aktive Wiederholungen laufen weiter.

## Rückfälle

Empfehlung:

- S0 falsch -> S0
- S1 falsch -> S1
- S2 falsch -> S1
- S3 falsch -> S2
- S4 falsch -> S3
- S5 falsch -> S3

Rückfälle dürfen nicht automatisch Massenkaskaden auslösen. Eine Karte wird einzeln angepasst.

## S5 wiederholen und reaktivieren

S5-Regeln:

- S5 bleibt in `word_progress`.
- S5 kann fällig werden.
- S5 kann manuell reaktiviert werden.
- S5 falsch fällt auf S3.
- S5 richtig setzt ein neues `next_due_at`.
- `is_mastered` darf S5-Karten nicht aus Wiederholung, Queue oder Engine entfernen.

Manuelle Reaktivierung:

- Option A: S5 -> S4
- Option B: S5 bleibt S5, `next_due_at = now`

Empfehlung: Option B, weil sie Fortschritt nicht künstlich verschlechtert.

## Bewusst nicht einbauen

Um die Engine stabil zu halten, zunächst nicht einbauen:

- komplexe Ease-Factor-Formeln
- mehrere Fehlerqualitäten
- dynamische KI-Optimierung
- automatische globale Umschichtung aller Stufen
- versteckte Mastered-Ausschlüsse
- mehr als eine aktive Queue pro Bereich
- zufällige Queue ohne gespeicherten Zustand

## Invarianten

- Eine aktive Session ist eindeutig.
- Eine falsche Karte wird erneut gezeigt.
- Eine Antwort erzeugt genau ein Review-Event.
- Fortschritt pro Modus bleibt getrennt.
- S0 wird kontrolliert eingeführt.
- S5 bleibt wiederholbar.
