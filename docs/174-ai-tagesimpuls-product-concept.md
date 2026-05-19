# Tagesimpuls Product Concept

## Ziel des Features

Der Tagesimpuls ist ein appweites Lernfeature, bei dem der Nutzer 3–5 Wörter sammelt.

Aus diesen Wörtern erzeugt die KI eine kurze natürliche Nachricht. Diese Nachricht soll sich nicht wie eine trockene Vokabelliste anfühlen, sondern wie ein kleiner Alltagsimpuls: verständlich, kontextnah und leicht wiederholbar.

Die ausgewählten Wörter werden dadurch passiv im Kontext wiederholt.

## Warum das Feature wichtig ist

Wörter werden nicht nur isoliert gelernt.

Kontext hilft beim Verstehen, Erinnern und Wiedererkennen. Besonders schwierige Wörter können dem Nutzer später erneut begegnen, ohne dass dafür eine komplette SRS-Session gestartet werden muss.

Der Tagesimpuls ergänzt SRS, ersetzt es aber nicht. SRS bleibt für strukturierten Lernfortschritt zuständig. Der Tagesimpuls ist ein zusätzlicher Kontext- und Wiederholungsraum.

## Appweite Verfügbarkeit

Der HomeScreen bleibt ein Einstieg.

Die Tagesimpuls-Auswahl darf aber nicht nur an den HomeScreen gekoppelt sein. Sie soll appweit nutzbar werden:

- HomeScreen: bestehende Auswahlleiste und Counter
- Lernmodus: direkter Add-Button auf der Karte
- Wortdetailseite: später optional ebenfalls ein Add-Button

So kann der Nutzer ein Wort genau dann hinzufügen, wenn es auffällt oder schwerfällt.

## Globale Tagesimpuls-Auswahl

Die Tagesimpuls-Auswahl ist ein globaler lokaler Zustand.

Regeln:

- maximal 5 Wörter
- lokal gespeichert
- appweit verfügbar
- Counter zeigt globalen Stand, z. B. `0/5`
- Duplikate werden verhindert
- Auswahl kann geleert werden

Der Counter im HomeScreen soll denselben globalen Zustand anzeigen, den später auch Lernmodus und Wortdetail verwenden.

## Lernmodus-Integration

Wenn ein Wort im Lernmodus schwerfällt oder später wiederholt werden soll, kann der Nutzer es direkt zur Tagesimpuls-Auswahl hinzufügen.

Mögliche UI:

- Button oder Icon auf der Lernkarte
- optisch klar, aber nicht störend
- keine Verwechslung mit richtig/falsch Swipe

Feedback:

- Erfolg: `Wort wurde zum Tagesimpuls hinzugefügt.`
- Auswahl voll: `Tagesimpuls ist voll.`
- Duplikat: optional `Wort ist bereits im Tagesimpuls.`

Das Hinzufügen verändert keinen SRS-Fortschritt.

## KI-Nachricht

Die KI nutzt die ausgewählten Wörter und erzeugt daraus eine kurze Nachricht.

Ziel:

- natürlich formuliert
- kurz genug für einen Tagesimpuls
- verständlich als Lernkontext
- bevorzugt Deutsch als Erklärung oder Lernsprache, abhängig von späterer Einstellung

Es darf keine automatische KI-Anfrage ohne Nutzeraktion geben.

Später kann daraus eine geplante Tagesnachricht oder Benachrichtigung entstehen. Das ist aber ein eigener späterer Schritt.

## Offline-First

Die Auswahl der Wörter funktioniert lokal.

Die KI-Erzeugung braucht Internet, weil sie über eine Supabase Edge Function läuft. Wenn der Nutzer offline ist, bleibt die Auswahl erhalten und kann später verwendet werden.

Lokales Lernen bleibt unabhängig:

- SRS funktioniert ohne KI
- Tagesimpuls-Auswahl bleibt lokal
- keine Online-Pflicht für Lernmodus oder Wortdetail

## Datenschutz und Kosten

Nur ausgewählte Wörter werden an die KI gesendet.

Keine API-Keys liegen in Flutter. KI-Anfragen laufen über Supabase Edge Function, damit Secrets serverseitig bleiben.

Usage Limits und Kostenkontrolle müssen später auch für Tagesimpuls gelten. Das Feature darf keine unbegrenzten automatischen KI-Anfragen erzeugen.

## Abgrenzung

Der Tagesimpuls ist:

- kein allgemeiner Chat
- kein automatisches Sammeln ohne Nutzerentscheidung
- kein Ersatz für den Lernmodus
- kein sofortiger Push-Benachrichtigungs-Zwang

Der Nutzer entscheidet bewusst, welche Wörter in den Tagesimpuls aufgenommen werden.

## Umsetzung in Phasen

### Phase 1

- globale Tagesimpuls-Auswahl
- Add-Button im Lernmodus
- Counter appweit korrekt
- Duplikat- und Maximalgrenze lokal absichern

### Phase 2

- KI-Nachricht manuell generieren
- ausgewählte Wörter an `ai-chat` oder eine spezialisierte Edge Function senden
- Ergebnis lokal anzeigen
- Fehler und Limits verständlich kommunizieren

### Phase 3

- geplante Tagesnachrichten
- optionale Benachrichtigungen
- klare Nutzerentscheidung für Benachrichtigungen

### Phase 4

- adaptive Vorschläge durch Lernverhalten
- schwierige Wörter vorschlagen
- weiterhin keine automatische Aufnahme ohne Nutzerentscheidung

## Nächster technischer Schritt

Die Tagesimpuls-Auswahl sollte aus dem HomeScreen gelöst werden.

Empfehlung:

1. Eigenen lokalen Provider/Service für Tagesimpuls-Auswahl erstellen.
2. Auswahl lokal persistieren.
3. HomeScreen an denselben globalen Zustand anbinden.
4. Lernmodus-Button auf denselben Zustand schreiben lassen.
5. Counter `0/5` überall aus derselben Quelle lesen.
