# 12 Theoretical SRS Simulations

Stand: 2026-05-13

## Ziel

Diese Szenarien prüfen die geplanten Regeln ohne Code. Sie ersetzen keine Tests, helfen aber, fachliche Instabilität früh zu erkennen.

## Szenario 1: 20 Wörter

Ausgang:

- 20 S0
- Modus: Nach Zeitplan
- Bereich: Alles lernen

Erwartung:

- Tag 1 führt max. 5 neue Karten ein.
- Nach richtiger Antwort gehen sie S1.
- S1 wird früh wiederholt, aber nicht an einem Tag bis S5 geschoben.
- S0 bleibt nach Tag 1 nicht leer.

Bewertung:

- Stabil, wenn Tageslimit und S1-Tagesaufstiegsregel greifen.
- Bei kleinen Kategorien kann später optional "weitere neue Wörter lernen" angeboten werden; das blockiert die Version-1-Engine nicht.

## Szenario 2: 50 Wörter

Ausgang:

- 50 S0
- Modus: Ausgewogen lernen
- Nutzer lernt täglich eine Session.

Erwartung:

- Pro Session bis 8 neue Karten.
- Wiederholungen steigen nach wenigen Tagen.
- Neue Karten werden reduziert, wenn viele S3-S5 fällig sind.

Bewertung:

- Stabil, wenn Hybrid ab ca. 30 fälligen Wiederholungen S0 pausiert.

## Szenario 3: 200 Wörter

Ausgang:

- 200 S0
- Modus: Nach Zeitplan

Erwartung:

- S0 leert sich über mehrere Wochen, nicht in wenigen Sessions.
- Wiederholungslast bleibt kontrolliert.
- Bei 10 neuen pro Tag entstehen nach einigen Tagen genug Reviews.

Bewertung:

- Stabil für langfristiges Lernen.
- Für Prüfungssituationen zu langsam, deshalb braucht es Intensiv lernen.

## Szenario 4: Viele Fehler in S3

Ausgang:

- 40 Karten S3
- 50% falsch

Erwartung:

- falsche Karten fallen S3 -> S2.
- Karten erscheinen nach ca. 10 anderen Karten erneut.
- Queue bekommt mehr S2.
- neue Karten werden reduziert.

Risiko:

- S2 kann überfüllt werden.

Bewertung:

- Akzeptabel, wenn keine automatische Massenkaskade eingebaut wird.
- Bei hoher Fehlerquote sollte die nächste Session weniger neue Karten bringen.
- Mit der Version-1-Regel werden nach 3 Fehlern in 10 Antworten keine neuen S0-Karten mehr automatisch eingeführt.

## Szenario 5: Viele neue Karten aus S0

Ausgang:

- 300 S0
- Nutzer wählt Intensiv lernen.

Erwartung:

- Session darf z. B. 20 neue Karten einführen.
- Nutzer kann weitere Sessions starten.
- Fehler werden innerhalb der Session wiederholt.
- Aufstieg in höhere Stufen braucht mehrere richtige Antworten.

Risiko:

- Nutzer kann sich bewusst überfordern.

Bewertung:

- Fachlich gewollt für Prüfungssituation.
- UI sollte klar machen, dass "intensiv" viel Wiederholung erzeugen kann.
- Aufstieg bis S5 am selben Tag ist erlaubt, aber nur nach 1/2/2/3/3 richtigen Antworten über die Stufen.

## Szenario 6: App-Neustart mitten in Session

Ausgang:

- Session mit 20 Karten.
- Karte 7 wurde falsch beantwortet.
- Retry geplant nach 10 Karten.
- App wird geschlossen.

Erwartung:

- Review-Event bleibt gespeichert.
- Karte 7 bleibt in Retry-Position.
- Nach Neustart wird dieselbe Session fortgesetzt.
- Keine neue Queue.

Bewertung:

- Kritisch für Launch.
- Ohne persistierte Session-Items nicht stabil.

## Szenario 7: Prüfungssituation mit Intensiv lernen

Ausgang:

- 200 Wörter
- Nutzer will an einem Tag viel schaffen.

Erwartung:

- kein hartes Tageslimit.
- Session 1 führt viele neue Karten ein.
- Fehler kommen wieder.
- Karten steigen nicht ohne ausreichend `pass_count`.
- S5 wird nicht "fertig für immer".

Bewertung:

- Stabil, wenn pass_count-Schwellen streng bleiben.
- Intensiv lernen darf Karten am selben Tag bis S5 bringen, aber nur mit allen pass_count-Hürden, Requeues und Rückfällen.

## Szenario 8: Normale langfristige Nutzung mit Nach Zeitplan

Ausgang:

- Nutzer lernt täglich 10 Minuten.
- 100 Wörter.

Erwartung:

- neue Karten kommen langsam.
- fällige Wiederholungen zuerst.
- S5-Karten kommen selten wieder.
- Nutzer wird nicht überlastet.

Bewertung:

- Stabil mit den Version-1-Intervallen 1/3/7/14/30 Tagen.
- S5 bleibt wiederholbar.

## Szenario 9: Gemischte Nutzung mit Ausgewogen lernen

Ausgang:

- 100 Wörter
- Nutzer will etwas aktiver lernen, aber nicht komplett frei.

Erwartung:

- S0-S2 lassen aktives Lernen zu.
- S3-S5 werden zeitbasiert.
- erste S5-Wiederholung nach ca. 5 Tagen.
- S5-Wiederholungen bleiben im Hybrid bei 5 Tagen.

Bewertung:

- Sinnvoll für eine aktivere Mischform.
- S5 alle 5 Tage ist bewusst kürzer als T-SRS und sollte in Tests auf Überlast geprüft werden.

## Weiter zu beobachtende Regeln

- Hybrid-S5 alle 5 Tage kann bei großen Kategorien mehr Wiederholungslast erzeugen und sollte simuliert werden.
- A-SRS kann viele Karten an einem Tag bewegen; Schutz erfolgt nur über pass_count, Fehler, Requeue und S5-Wiederholbarkeit.
- Rückfälle können S2 überfüllen; es braucht Tests, aber keine komplexen Kaskaden.
