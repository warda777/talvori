# Talvori KI-Companion Plan

## 1. Ziel des Companion

Das Talvori-Maskottchen soll nicht nur Dekoration sein. Es soll langfristig als KI-gestuetzter Begleiter dienen, der Nutzerinnen und Nutzer beim Lernen kurz, passend und hilfreich begleitet.

Der Home Screen ist dabei der schnelle Companion-Moment: ein kurzer Hinweis, eine Begruessung oder eine kleine Reaktion. Das Impuls-Postfach bleibt der Ort fuer den vollstaendigen Verlauf, laengere Antworten und spaetere Rueckgriffe.

## 2. Grundprinzip

Der Home Screen ruft keine KI direkt auf. Die UI bleibt bewusst duenn und delegiert Companion-Logik an eine zentrale Schicht:

```text
Home UI -> CompanionController -> vorhandener KI-/Chat-Service
```

So bleiben UI, Zustand, KI-Zugriff und Persistenz sauber getrennt. Der CompanionController entscheidet, ob lokal eine Regel reicht oder ob spaeter ein bestehender KI-/Chat-Service genutzt wird.

## 3. Home-Verhalten

Beim Start kann der Companion kurz gruessen und eine kompakte Bubble anzeigen. Nach einigen Sekunden verschwindet die Bubble, und das Maskottchen wird kleiner oder ruhiger.

Wenn der Nutzer das Maskottchen antippt, kann es wieder groesser erscheinen. Optional kann dann eine kompakte Chat-Eingabezeile auf dem Home Screen geoeffnet werden. Eine Antwort wird kurz in der Bubble angezeigt und anschliessend im Impuls-Postfach gespeichert.

Der Home Screen bleibt damit leicht und schnell. Ausfuehrlichere Gespraeche gehoeren ins Postfach.

## 4. Impuls-Postfach / Companion-Chat

Das Impuls-Postfach ist der vollstaendige Companion-Chat. Dort koennen liegen:

- KI-Antworten
- Lernvorschlaege
- Hinweise
- Tagesimpuls-Verknuepfungen
- Rueckfragen und kleine Coaching-Momente

Der Chat soll sowohl vom Home Screen als auch direkt aus dem Postfach nutzbar sein. Home ist der Einstieg, das Postfach ist das Gedaechtnis.

## 5. KI-Kontext

Der Companion soll spaeter kontextbewusst antworten. Moegliche Kontextquellen:

- Nutzername
- Lernziel aus dem Onboarding
- heutiger Lernstatus
- neue geteilte Woerter
- Tagesimpuls-Status
- letzte Wortwelt
- letzte Wortspiele
- schwierige Woerter
- lokale Wortanzahl

Wichtig: Kontext wird sparsam genutzt. Der Companion soll nicht ueberladen wirken und keine sensiblen Daten unnoetig anzeigen.

## 6. Noch-nicht-ausprobiert-Logik

Der Companion soll erkennen koennen, welche Kernfunktionen noch nicht genutzt wurden:

- Nutzer hat noch nie Safari-/Browser-Share genutzt
- Nutzer hat noch nie Wortspiele genutzt
- Nutzer hat noch nie einen Tagesimpuls erstellt
- Nutzer hat noch nie Favoriten genutzt
- Nutzer hat noch nie Meine Woerter geoeffnet
- Nutzer hat noch nie Lernlevel ausprobiert
- Nutzer hat noch nie Sprachwerkzeuge genutzt

Beispielhinweis:

> Du kannst Woerter direkt aus dem Browser speichern. Markiere ein englisches Wort, teile es mit Talvori und baue dir deine eigene Vokabelbox auf.

Diese Hinweise sollen kurz, konkret und handlungsnah sein. Kein Tutorial-Textblock im Home Screen.

## 7. Motivation aus Onboarding

Der Companion kann das Lernziel aus dem Onboarding nutzen. Beispiele:

- Beruf
- Reisen
- Studium
- fluessiger sprechen
- Filme und Serien verstehen

Die Motivation darf persoenlich wirken, aber nicht kitschig. Gute Companion-Texte sind kurz, ruhig und hilfreich.

Beispiel:

```text
Ein kleines Paket heute reicht. Nimm dir fuenf Minuten fuer Reisewoerter.
```

## 8. Anti-Nerv-Regeln

Der Companion darf nicht stoeren. Grundregeln:

- keine dauerhafte Bubble
- nicht dieselbe Nachricht mehrfach am Tag
- maximal 1-2 aktive Hinweise pro Session
- nach Wegklicken ruhig bleiben
- Companion wird klein oder inaktiv, wenn er nicht genutzt wird

Spaeter sollten Companion-Hinweise in den Einstellungen steuerbar sein:

- Aktiv
- Dezent
- Nur wichtige Hinweise
- Aus

## 9. Moegliche Moods

Die vorhandenen Mascot-Zustaende koennen als Companion-Moods genutzt werden:

- greeting
- idle
- bored
- thinking
- happy
- proud
- sad
- surprised
- angry / furious nur sparsam

Negative oder sehr starke Emotionen sollten selten eingesetzt werden. Talvori soll motivieren, nicht druecken.

## 10. MVP-Reihenfolge

### Phase 1

- CompanionController mit lokalen Regeln
- Home-Bubble zeitgesteuert
- Tap zum Aufwecken
- Bubble uebernimmt Browser-Share-Hinweis

### Phase 2

- Home-Chat-Eingabe
- Antworten ueber vorhandenen KI-Client
- Verlauf ins Impuls-Postfach schreiben

### Phase 3

- kontextbasierte Vorschlaege
- Noch-nicht-ausprobiert-Regeln
- Onboarding-Ziel einbeziehen

### Phase 4

- Einstellungen fuer Companion-Hinweise
- Frequenzsteuerung
- Anti-Nerv-Logik
