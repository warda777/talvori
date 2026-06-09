# 360 - Character-Assisted World Action Rule

Status: verbindliches Dokumentations-/Gameplay-Regel-Gate fuer M16-BR.

Scope: Character-assisted World Actions, Worker-Loop, indirekte Steuerung,
Prompt-Regeln fuer kuenftige Gameplay-/Build-/World-/Object-Slices.

Nicht-Scope: Code, App-Integration, Route, Navigation, Persistenz, Assets,
Tests, Economy, Reward-Implementierung, BuildChoice-Implementierung,
BuildState, Produktivmechanik-Freigabe.

## 1. Zweck

Talvori-Spielhandlungen sollen nicht nur durch Buttons, Text oder UI-
Bestaetigung passieren. Bei Bau-, Reparatur-, Sammel-, Container-, Werkstatt-,
Objekt- und Weltaktionen muss kuenftig geprueft werden, ob eine sichtbare
Figur, ein Worker, Bauhelfer, Tali/Vori oder ein anderes Weltobjekt die
Handlung spielerischer macht.

Die Regel lautet nicht:

```text
Jede Aktion braucht eine Figur.
```

Die Regel lautet:

```text
Jede passende Weltaktion muss pruefen, ob sichtbare Figuren-/Worker-Handlung
den Moment lebendiger, klarer und spielerischer macht.
```

## 2. Harte Pflichtregel

Jeder kuenftige Gameplay-, Build-, World-, Learning-, Container-, Object-, UI-
oder Implementierungs-Slice muss bei betroffenen Weltaktionen beantworten:

- Gibt es eine Figur, einen Bauhelfer, Tali/Vori oder ein sichtbares
  Weltobjekt, das die Handlung ausfuehrt?
- Steuert der Spieler direkt die Figur oder gibt er einen Auftrag?
- Warum ist diese Steuerungsart passend?
- Welche sichtbare Arbeitsbewegung entsteht?
- Wie veraendert sich die Welt waehrend oder nach der Handlung?
- Welche neue Moeglichkeit entsteht danach?
- Warum fuehlt es sich mehr wie Spiel an als eine UI-Auswahl?

Wenn eine Aktion nur durch Button-Label und Feedback-Text lebt, ist sie fuer
Talvori meist noch nicht weltlich genug.

## 3. Standardentscheidung fuer MVP

MVP-Standard ist indirekte Steuerung.

Der Spieler:

- waehlt Ziel,
- waehlt Werkzeug,
- waehlt Material,
- waehlt Reihenfolge,
- tippt oder zieht ein Objekt.

Die Figur, der Worker oder das Weltobjekt:

- laeuft hin,
- graebt,
- haemmert,
- traegt,
- legt,
- oeffnet,
- sortiert,
- repariert,
- zeigt,
- sammelt ein.

Nicht Standard im MVP:

- freie Joystick-Steuerung,
- dauerhaftes Movement-System,
- Pathfinding,
- Kollisionen,
- Kampf-/Action-Steuerung,
- vollstaendige Avatarsteuerung.

Indirekte Steuerung ist fuer Talvori stark, weil der Spieler Entscheidungen
trifft und die Welt danach sichtbar handelt. Das schuetzt Mobile-Dichte,
Accessibility und Scope, ohne das Spielgefuehl auf UI-Bestaetigung zu
reduzieren.

## 4. Direkte Steuerung nur mit eigenem Gate

Direkte Figurensteuerung ist nicht verboten, aber blockiert bis zu einem
eigenen Gate.

Vor direkter Steuerung braucht Talvori:

- eigenes UX-/Control-Gate,
- Mobile-Steuerungsentscheidung,
- Accessibility-Regeln,
- Kamera-Regeln,
- Pathfinding/Kollision oder klare Begrenzung,
- Fehlbedienungsregeln,
- Scope-/Testplan,
- Stop-Regeln fuer Persistenz, BuildState und App-Integration.

Ohne dieses Gate bleibt direkte Avatarsteuerung ausserhalb des MVP-Scope.

## 5. Worker-Loop fuer Bauhandlungen

Empfohlener Bauhelfer-Loop:

```text
Auftrag sichtbar
-> Figur laeuft zum Ort
-> Figur arbeitet sichtbar
-> Ort veraendert sich in kleinen Stufen
-> neue Moeglichkeit erscheint
-> naechster Hook
```

Beispiel Foundation:

- Boden ist locker.
- Spieler waehlt Spaten.
- Figur laeuft zum Boden.
- Figur ebnet oder graebt in 2-3 kleinen Bewegungen.
- Boden wird ruhiger.
- Spieler waehlt Fundamentsteine.
- Figur traegt oder legt Steine.
- Fundament fuellt sich.
- Wand-Schatten erscheint.
- Hook: Aussenwaende spaeter.

Die Figur muss nicht aufwendig animiert sein. Fuer lokale Previews reichen
einfache Positionswechsel, kleine Arbeitsposes, Ghosts, Partikel, kurze
Werkzeugbewegungen oder sichtbare Stufen am Ort.

## 6. Wann Figur sinnvoll ist

Figur/Worker besonders pruefen bei:

- Bauen,
- Reparieren,
- Aufraeumen,
- Sammeln,
- Tragen,
- Container oeffnen,
- Werkstatt/Crafting,
- Wege reparieren,
- Nebel oder Blockade loesen,
- Fundstueck bergen,
- Moebel oder Objekte platzieren,
- Raum, Schrank oder Fach oeffnen.

Je physischer, raeumlicher oder handwerklicher eine Handlung ist, desto eher
hilft eine sichtbare Figur.

## 7. Wann Figur nicht noetig ist

Figur muss nicht erzwungen werden bei:

- reiner Insel-Showcase-Auswahl,
- abstrakter Archivansicht,
- kurzer Kontext-Bubble,
- reinem Kamerafokus,
- kleinen UI-Safe-Actions,
- sensiblen oder abstrakten Themen, wenn eine Figur die Sache dramatisieren
  wuerde.

Eine Figur darf nie als Deko-Zwang eingesetzt werden. Sie muss die Handlung
klarer, lebendiger oder besser lesbar machen.

## 8. Vergleich zu erfolgreichen Aufbau-Spielen

Aufbau- und Base-Spiele nutzen oft sichtbare Arbeiter, Bewohner oder
Einheiten, um Fortschritt lebendig zu machen.

Musterlogik:

- Spieler entscheidet ueber Bau, Auftrag oder Prioritaet.
- Figuren machen die Arbeit sichtbar.
- Fortschritt wirkt raeumlich, nicht nur numerisch.
- Der Ort fuehlt sich bewohnt und eigener an.

Talvori uebernimmt:

- indirekten Auftrag,
- sichtbare Arbeitsbewegung,
- kleine Stufen von Weltveraenderung,
- Ownership durch belebte Orte.

Talvori verwirft:

- Timer,
- Pay-to-Win,
- Ressourcenstress,
- Bauzwang,
- Angriffsdruck,
- Worker als Monetarisierungs- oder Wartezeit-System.

## 9. Beziehung zu 358 und 359

- 358 definiert Player Hook, kleine Huerde, Spielhandlung, sichtbaren
  Fortschritt und Belohnung als neue Moeglichkeit.
- 359 definiert object-first, sichtbares Problem vor Text und sichtbare
  Weltveraenderung.
- 360 ergaenzt: Wenn passend, soll eine Figur/Worker-Handlung diese
  Weltveraenderung sichtbar, lebendig und spielerisch machen.

Character-assisted Action ist damit keine eigene Produktmechanik-Freigabe,
sondern eine Umsetzungsregel fuer bessere Spielmomente.

## 10. Konsequenz fuer M16-BQ

M16-BQ-FIX ist in der richtigen Richtung, weil ein Bauhelfer sichtbar wird und
die Foundation-Aufgabe nicht mehr nur Bauteil-Kacheln zeigt.

Vor Commit muss M16-BQ trotzdem geprueft werden:

- Zeigt die Figur nur Positionswechsel?
- Oder entsteht ein klarer Arbeitsloop mit Auftrag, Bewegung, Arbeitsgeste,
  sichtbarer Bodenveraenderung, Fundamentstufe und neuem Hook?
- Ist die Weltveraenderung ohne viel Text lesbar?
- Bleibt es ohne BuildState, Persistenz, App-Integration und Assets?

Empfohlener Folge-Code-Fix:

> M16-BQ-FIX-2 Worker Task Loop and Visible Construction Progress

Ziel fuer diesen Folge-Fix:

- Worker-Bewegung und Arbeitsgeste staerker machen,
- Boden-vorbereiten-Stufe visuell klarer zeigen,
- Fundamentsteine sichtbar als gelegte Stufe lesen lassen,
- Aussenwand-Hook als neue Moeglichkeit sichtbar halten,
- keine neue Mechanik, keine Persistenz, kein BuildState.

## 11. Prompt-Regel fuer kuenftige Slices

Kuenftige Gameplay-, World-, Build-, Object-, Container-, Learning- und
Implementierungs-Slices muessen 360 lesen, wenn eine Figur, Worker,
Tali/Vori, Objektaktion, Bauhandlung, Reparatur, Sammeln, Tragen, Oeffnen,
Werkstatt/Crafting oder Container betroffen ist.

Jeder entsprechende Prompt muss beantworten:

- Auftrag oder direkte Steuerung?
- Welche Figur oder welches Objekt handelt sichtbar?
- Welche Arbeitsbewegung entsteht?
- Welche Weltveraenderung entsteht?
- Welche neue Moeglichkeit entsteht?
- Warum wird kein Movement-/Pathfinding-Scope geoeffnet?

## 12. M16T-FUN IDs

Dieses Gate dokumentiert folgende erledigte Regel-IDs:

- M16T-FUN-012 Character-assisted world action rule
- M16T-FUN-013 Indirect worker control as MVP default
- M16T-FUN-014 Direct avatar control requires own gate
- M16T-FUN-015 Worker task loop and visible construction progress
- M16T-FUN-016 M16-BQ-FIX-2 readiness

## 13. Stop-Regeln

- keine Flutter-/Dart-Dateien
- keine App-Integration
- keine Route
- keine Navigation
- keine Persistenz
- keine Supabase/local DB Writes
- keine SRS-/word_progress-Aenderung
- keine automatische Wortplatzierung
- keine Assets
- kein BuildState
- kein frame_started
- keine Tests
- keine Screenshots als Repo-Artefakte
- keine Economy
- keine Muenzen
- keine Reward-Implementierung
- keine BuildChoice-Implementierung
- keine Produktivmechanik-Freigabe
- nicht committen
