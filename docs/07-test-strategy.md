# 07 Test Strategy

Stand: 2026-05-13

## Ziel

Vor jeder Implementierung der neuen SRS-Engine müssen die Regeln durch natürliche Testfälle abgesichert werden. Danach werden daraus Unit- und Integrationstests abgeleitet.

Keine SRS-Engine-Änderung ohne Tests für:

- Aufstieg
- Rückfall
- Fälligkeit
- neue Karten
- Tageslimit
- Session-Queue
- S5-Verhalten
- getrennten Fortschritt pro Modus
- Session-Fortsetzung
- Manipulationsschutz

## Testbereiche

### Stage-Aufstieg

Testfälle:

1. Eine S0-Karte wird richtig beantwortet.
   - Erwartung: S0 -> S1, `pass_count = 0`, `ever_introduced = true`.

2. Eine S1-Karte wird einmal richtig beantwortet.
   - Erwartung: bleibt S1, `pass_count = 1`.

3. Eine S1-Karte wird zweimal richtig beantwortet.
   - Erwartung: S1 -> S2, `pass_count = 0`.

4. Eine S3-Karte wird zweimal richtig beantwortet.
   - Erwartung: bleibt S3, `pass_count = 2`.

5. Eine S3-Karte wird dreimal richtig beantwortet.
   - Erwartung: S3 -> S4.

6. Eine S4-Karte wird dreimal richtig beantwortet.
   - Erwartung: S4 -> S5.

### Rückfall

Testfälle:

1. S0 falsch.
   - Erwartung: bleibt S0, kommt in der Session erneut.

2. S1 falsch.
   - Erwartung: bleibt S1, `pass_count = 0`, Requeue.

3. S2 falsch.
   - Erwartung: S2 -> S1, Requeue.

4. S3 falsch.
   - Erwartung: S3 -> S2, Requeue.

5. S5 falsch.
   - Erwartung: fällt auf S3, `pass_count = 0`, Requeue.

### Fälligkeit

Testfälle:

1. T-SRS Karte mit `next_due_at` in Zukunft.
   - Erwartung: nicht in regulärer Queue.

2. T-SRS Karte mit `next_due_at <= now`.
   - Erwartung: fällig.

3. A-SRS Karte mit `next_due_at` in Zukunft.
   - Erwartung: darf trotzdem gelernt werden.

4. Hybrid S1/S2 mit Zukunftsdatum.
   - Erwartung: darf aktiv gelernt werden, weil Hybrid S0-S2 freier behandelt.

5. Hybrid S4 mit Zukunftsdatum.
   - Erwartung: nicht fällig.

### Neue Karten

Testfälle:

1. T-SRS, 0 Wiederholungen fällig, 100 S0.
   - Erwartung: Session bekommt max. 5 neue Karten.

2. T-SRS, 30 Wiederholungen fällig, 100 S0.
   - Erwartung: keine neuen Karten.

3. Hybrid, 5 Wiederholungen fällig, 100 S0.
   - Erwartung: neue Karten bis max. 8 pro Session.

4. A-SRS, Prüfungssituation, 200 S0.
   - Erwartung: Session darf intensiv lernen lassen, lädt aber nicht automatisch alle 200 Karten nach. Nach Ende der Session darf der Nutzer bewusst weiterlernen oder eine weitere A-SRS-Session starten.

5. T-SRS Session mit vielen verfügbaren S0-Karten.
   - Erwartung: maximal 5 neue S0-Karten in dieser Session.

6. Hybrid Session mit vielen verfügbaren S0-Karten.
   - Erwartung: maximal 8 neue S0-Karten in dieser Session.

7. A-SRS Session mit vielen verfügbaren S0-Karten.
   - Erwartung: kein Tageslimit, aber die einzelne Session bleibt bei 20 Karten und lädt neue Karten nicht unkontrolliert automatisch nach.

8. A-SRS Session mit 200 S0-Karten und keinen aktiven Wiederholungskarten.
   - Erwartung: die Session darf bis zu 20 S0-Karten enthalten.

9. A-SRS Session mit S0-Karten und aktiven Wiederholungskarten.
   - Erwartung: A-SRS nutzt die 2:1-Mischregel: zwei aktive Wiederholungskarten, dann eine neue S0-Karte. Die Session wächst nicht über die technische Standardgröße hinaus.

10. A-SRS Session mit zu wenigen aktiven Wiederholungskarten.
   - Erwartung: freie Plätze dürfen mit neuen S0-Karten gefüllt werden, maximal bis zur technischen Standardgröße von 20 Karten.

### Session-Größe

Testfälle:

1. Neue Standard-Session wird erzeugt.
   - Erwartung: Version-1-Standardgröße ist 20 Karten.

2. Nutzer beendet eine A-SRS-Session.
   - Erwartung: keine automatische Endlos-Erweiterung der Queue.

3. Nutzer will in A-SRS weiterlernen.
   - Erwartung: bewusstes Weiterlernen oder eine weitere A-SRS-Session ist möglich.

4. Spätere Sessiongrößen 10/20/40.
   - Erwartung: bleiben eine spätere Option und sind für Version 1 nicht erforderlich.

### Tageslimit

Testfälle:

1. T-SRS Tageslimit 10 neue erreicht.
   - Erwartung: keine S0-Einführung mehr an diesem Tag.

2. Hybrid Tageslimit 15 neue erreicht.
   - Erwartung: keine S0-Einführung mehr, Wiederholungen bleiben möglich.

3. A-SRS Tageslimit.
   - Erwartung: kein hartes Limit.

### Session-Queue

Testfälle:

1. Eine Karte wird falsch beantwortet, es gibt mindestens 10 andere Karten.
   - Erwartung: Karte erscheint nach ungefähr 10 anderen Karten erneut.

2. Eine Karte wird falsch beantwortet, es gibt weniger als 10 andere Karten.
   - Erwartung: Karte kommt ans Ende der aktuellen Queue.

3. App wird direkt nach falscher Antwort geschlossen.
   - Erwartung: Requeue bleibt gespeichert.

4. Queue wird fortgesetzt.
   - Erwartung: Reihenfolge und Fortschritt bleiben erhalten.

### S5-Verhalten

Testfälle:

1. S5 richtig in T-SRS.
   - Erwartung: bleibt S5, neues langes `next_due_at`.

2. S5 richtig in Hybrid.
   - Erwartung: bleibt S5, `next_due_at` liegt 5 Tage in der Zukunft.

3. S5 falsch.
   - Erwartung: S5 -> S3, nicht S4 und nicht S0.

4. S5 manuell reaktivieren.
   - Erwartung: Karte ist wieder aktiv wiederholbar.

5. S5 mit optionalem `is_mastered`-Anzeigefeld.
   - Erwartung: Karte bleibt wiederholbar und darf nicht aus Queue oder Fälligkeit verschwinden.

### Getrennter Fortschritt pro Modus

Testfälle:

1. Wort A in Kategorie X ist in `time` auf S4.
   - In `adaptive` ist dasselbe Wort S1.
   - Erwartung: beide Fortschritte bleiben unabhängig.

2. Review in Hybrid ändert keinen T-SRS-Fortschritt.

3. Reset in A-SRS löscht nicht T-SRS.

### Gezielt üben

Testfälle:

1. Eine S2-Karte wird in Gezielt üben richtig beantwortet.
   - Erwartung: `stage`, `pass_count` und `next_due_at` bleiben unverändert.

2. Eine S4-Karte wird in Gezielt üben falsch beantwortet.
   - Erwartung: kein Rückfall, kein Requeue in der normalen SRS-Session, keine Änderung an `stage`, `pass_count` oder `next_due_at`.

3. Eine S5-Karte wird in Gezielt üben falsch beantwortet.
   - Erwartung: S5 bleibt S5, weil Gezielt üben in Version 1 außerhalb der normalen SRS-Progression liegt.

4. Antworten in Gezielt üben werden später optional statistisch gespeichert.
   - Erwartung: falls Statistik eingeführt wird, bleibt sie getrennt von SRS-Fortschritt.

### T-SRS Tagesaufstieg

Testfälle:

1. S0 wird in T-SRS richtig beantwortet.
   - Erwartung: S0 -> S1.

2. Dieselbe S1-Karte wird am selben Tag erneut richtig beantwortet.
   - Erwartung: bleibt S1, kein Aufstieg zu S2.

3. Dieselbe S1-Karte wird am nächsten Tag richtig beantwortet und erfüllt `pass_count`.
   - Erwartung: S1 -> S2.

### A-SRS Aufstieg Am Selben Tag

Testfälle:

1. Eine Karte erhält in A-SRS ausreichend richtige Antworten für S0 -> S5 am selben Tag.
   - Erwartung: Aufstieg bis S5 ist erlaubt, sofern alle `pass_count`-Schwellen erfüllt sind.

2. Eine Karte macht in A-SRS einen Fehler in S3.
   - Erwartung: Rückfall S3 -> S2, `pass_count = 0`, Requeue.

### Fehlerquote Neue Karten

Testfälle:

1. In T-SRS treten innerhalb der letzten 10 Antworten 3 Fehler auf.
   - Erwartung: keine neuen S0-Karten mehr in dieser Session; aktive Wiederholungen laufen weiter.

2. In Hybrid treten innerhalb der letzten 10 Antworten 3 Fehler auf.
   - Erwartung: keine neuen S0-Karten mehr in dieser Session; aktive Wiederholungen laufen weiter.

3. In A-SRS treten innerhalb der letzten 10 Antworten 3 Fehler auf.
   - Erwartung: kein automatischer Nachschub neuer Karten; bewusstes intensives Weiterlernen oder eine weitere A-SRS-Session bleibt erlaubt.

### Mehrfach-Requeue

Testfälle:

1. Erster Fehler derselben Karte in derselben Session.
   - Erwartung: Karte erscheint nach ca. 10 anderen Karten erneut.

2. Zweiter Fehler derselben Karte in derselben Session.
   - Erwartung: Karte erscheint nach ca. 5 anderen Karten erneut.

3. Dritter Fehler derselben Karte in derselben Session.
   - Erwartung: Karte wird als schwierig markiert und ans Ende der aktuellen Session-Queue gelegt.

4. Schwierige Karte verschwindet nicht dauerhaft.
   - Erwartung: Fortschritt und Wiederholbarkeit bleiben erhalten.

### Session-Fortsetzung

Testfälle:

1. Aktive Session existiert für Kategorie X, Modus Y, Bereich Z.
   - App startet neu.
   - Erwartung: gleiche Session wird fortgesetzt.

2. Nutzer drückt Start erneut.
   - Erwartung: keine zweite aktive Session, sondern Fortsetzen.

3. Eine andere Kategorie wird gestartet.
   - Erwartung: eigene aktive Session erlaubt.

### Manipulationsschutz

Testfälle:

1. Nutzer beantwortet falsch und beendet App.
   - Erwartung: Fehler bleibt als Review-Event gespeichert.

2. Nutzer startet App neu.
   - Erwartung: Karte ist weiterhin in Requeue.

3. Nutzer bricht Session ab.
   - Erwartung: Fortschritt wird nicht zurückgesetzt.

4. Nutzer versucht durch Neustart eine bessere Reihenfolge zu bekommen.
   - Erwartung: persistierte Queue bleibt.

## Testarten später

- reine Unit-Tests für Engine-Regeln
- Unit-Tests für Queue-Builder
- SQLite-Repository-Tests mit Testdatenbank
- Controller-Tests für Session-Fortsetzung
- Widget-Tests nur für UI-Zustände
