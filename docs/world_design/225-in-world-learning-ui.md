# Talvori Welt: In-World-Learning-UI

Stand: 2026-06-04

Dieses Dokument plant, wie Lernaufgaben direkt in der Talvori-Welt erscheinen
und bedient werden. Es beschreibt Interaktionslogik und erste lokale
Mock-Slices, aber keine Flutter-Implementierung.

Es ist ein reines Planungsdokument. Es wurden keine Dart-/Flutter-Dateien,
keine Assets, keine Supabase-Daten, keine SQLite-/Vokabeldaten, keine SRS-Daten,
kein `word_progress`, keine Reward Bridge, keine Persistenz, keine Secrets und
keine Release-Artefakte geaendert.

Grundlagen:

- `docs/world_design/000-world-design-document-map.md`
- `docs/world_design/223-learning-to-building-loop.md`
- `docs/world_design/224-economy-balancing.md`
- `docs/222-talvori-world-game-system-master-plan.md`
- `docs/221-talvori-world-build-and-expansion-architecture.md`

## 1. Ziel Der In-World-Learning-UI

Lernen soll in Talvori nicht getrennt vom Spiel wirken. Die Welt selbst stellt
Aufgaben.

Der Nutzer soll verstehen:

> Diese Aufgabe baut genau dieses Objekt weiter.

Das bedeutet:

- Eine BuildZone ist nicht nur ein Tap-Ziel, sondern ein Lernkontext.
- Ein Fundament ist nicht nur ein Bauzustand, sondern ein sichtbarer Effekt
  gelernter Woerter.
- Ein Gebaeude ist nicht nur ein Screen, sondern ein Ort fuer passende
  Lernformen.
- Ein Companion-Hinweis fuehrt zur Weltaktion, ersetzt sie aber nicht.

Der erste technische Slice soll genau diesen Zusammenhang zeigen:

> BuildZone antippen -> Aufgabe erscheint -> lokale Mock-Antwort ->
> Bauzustand aendert sich sichtbar.

## 2. Grundregel

Lernaufgaben entstehen aus Weltkontexten:

- Bauplatz,
- Fundament,
- Gebaeude,
- Bibliothek,
- Markt,
- Bruecke/Dockingpunkt,
- Nebelbereich,
- Bewohner/NPC,
- Companion-Vorschlag.

Klassische Lernscreens duerfen bleiben. In-World-Learning ist aber der
emotionale Hauptmodus, weil der Nutzer dort Ursache und Wirkung direkt sieht.

Regel:

Eine Aufgabe soll nie wie ein losgeloestes Quiz erscheinen. Sie braucht immer
eine klare Weltfrage:

- Was wird gebaut?
- Warum braucht dieses Objekt diese Aufgabe?
- Welche sichtbare Wirkung kann danach passieren?

## 3. Standard-Flow

1. Nutzer tippt auf Weltobjekt oder BuildZone.
2. Kontextkarte oder Bottom Sheet oeffnet sich.
3. Karte zeigt Ziel, Aufgabe, benoetigte Ressource und sichtbare Wirkung.
4. Nutzer startet Aufgabe.
5. Aufgabe wird geloest.
6. Ergebnis wird bewertet.
7. Lokaler Mock-Fortschritt entsteht.
8. Bau- oder Weltzustand aendert sich sichtbar.
9. Companion kommentiert.
10. Naechster sinnvoller Schritt wird angeboten.

Beispiel:

1. Nutzer tippt auf eine freie BuildZone.
2. Karte zeigt `Fundament beginnen`.
3. Aufgabe: `Erkenne 3 einfache Woerter`.
4. Ressource: `Stein`, aber nur kontextuell und klein.
5. Nach Erfolg: BuildZone wechselt von `empty` zu `foundation_started`.
6. Tali/Vori kommentiert kurz.
7. Karte bietet `Noch eine kleine Aufgabe` oder `Spaeter weitermachen`.

## 4. UI-Formate

| Format | Sinnvoll wenn | Staerken | Risiken |
| --- | --- | --- | --- |
| Bottom Sheet | Aufgabe braucht kurze Erklaerung, Startbutton oder Ergebnis | stabil, mobil vertraut, genug Raum | kann Welt verdecken |
| Kleine Kontextkarte | sehr kurze Aktion an einem Objekt | fokussiert, leicht | zu klein fuer komplexe Aufgaben |
| Fokus-Overlay am Bauplatz | Nutzer soll Ursache/Wirkung direkt sehen | zeigt Weltbezug klar | darf nicht wie Debug-Marker wirken |
| Mini-Aufgabe im Gebaeude | Gebaeudeansicht oder spaeter Innenraum aktiv | hoher Immersionswert | braucht mehr UI-Planung |
| Companion-Bubble mit Aktionsbutton | Nutzer braucht Orientierung | persoenlich, schnell | darf nicht Ressourcen geben |
| Gebaeude-Innenraum spaeter | tiefer Zoom, Bibliothek, Werkstatt, Markt | reiches Lernsetting | nicht frueher Slice |

Erster Slice:

- Kontextkarte oder Bottom Sheet ist ausreichend.
- Der Bauplatz muss sichtbar bleiben.
- Keine grosse Lernscreen-Navigation erzwingen.

## 5. Bauplatz-Aufgabe

Kontext:

- Nutzer tippt auf eine BuildZone.
- Die BuildZone ist semantisch `main_build_area` oder vergleichbar.
- Sie ist leer oder vorbereitet.

Text:

- `Fundament beginnen`

Aufgabe:

- 3 einfache Woerter erkennen.

Ressource:

- Stein.

Wirkung:

- Bauplatz wird vorbereitet oder Fundament beginnt.
- Sichtbarer Zustand wechselt von `empty` zu `foundation_started`.

UI-Regeln:

- Sehr einfach.
- Keine Ressourcenueberladung.
- In Phase 2E sichtbar nur Stein.
- Holz und Wissen duerfen vorbereitet sein, aber nicht dominant erscheinen.
- Keine Tabellen oder Wallet-Ansicht in der ersten Session.

Beispielkarte:

- Ziel: `Fundament beginnen`
- Aufgabe: `Erkenne 3 einfache Woerter`
- Wirkung: `Der Bauplatz bekommt seine erste Grundlage`
- Aktion: `Aufgabe starten`

## 6. Bibliotheks-Aufgabe

Kontext:

- Bibliothek oder Wissenspunkt ist sichtbar.
- Nutzer tippt auf Regal, Fenster, Lesepult oder Satzstein.

Lernart:

- Satzverstaendnis,
- Tippen/Schreiben,
- spaeter Satzfunken.

Ressource:

- Wissen,
- spaeter Glas oder Licht.

Weltwirkung:

- Bibliothekslicht aktiviert sich,
- Fenster erscheint,
- Regal leuchtet,
- Satzstein wird sichtbar.

KI-Regel:

- KI ist optional und spaeter.
- Keine KI-Kosten im ersten Slice.
- Satzfunken duerfen hochwertig sein, aber nicht Grundbedingung fuer normale
  Bauaufgaben.

Erste Version:

- Bibliotheks-Aufgaben bleiben Planung.
- Phase 2E konzentriert sich auf BuildZone/Fundament.

## 7. Bruecken-/Connector-Aufgabe

Kontext:

- Bruecke oder Connector ist nur sinnvoll, wenn Dockingpunkte vorhanden sind.
- `docs/218` und `docs/219` bleiben Voraussetzung.

Lernart:

- Phrasenaufgabe,
- spaeter Dialog oder Verbindungssatz.

Ressource:

- Metall,
- Verbindung,
- spaeter Licht/Energie.

Weltwirkung:

- Dockingpunkt wird vorbereitet,
- Brueckenanker erscheint,
- Connector-Segment kann spaeter sichtbar werden.

Regeln:

- Keine frei schwebenden Connectoren.
- Connectoren nur DockingPoint zu DockingPoint.
- Erste Version nur als Planung, nicht sofort bauen.
- Keine Brueckenaufgabe im ersten BuildZone-Slice.

## 8. Nebelrettung / Wiederholung

Kontext:

- Privater Nebelbereich liegt ueber einem Lernort, Weg oder alten Bauplatz.
- Dieser Zustand ist nicht oeffentlich beschamend.

Lernart:

- SRS/Wiederholung.

Ressource:

- Reparaturpunkte.

Weltwirkung:

- Nebel lichtet sich,
- Weg wird klarer,
- Bereich stabilisiert sich,
- kleines Licht kehrt zurueck.

Regeln:

- Keine oeffentliche Bestrafung.
- Keine sichtbare Ruine fuer andere Nutzer.
- Sanftes Comeback.
- Bestehende SRS-/`word_progress`-Semantik bleibt unangetastet.
- Keine Nebelrettung im ersten technischen Slice.

## 9. Bewohner-/NPC-Dialog

Kontext:

- Bewohner erscheint an Haus, Markt, Platz oder spaeter in einem Gebaeude.

Lernart:

- kurzer Dialog,
- Antwortauswahl,
- aktive Wortnutzung,
- spaeter sicher kontrollierte KI-Unterstuetzung.

Weltwirkung:

- Bewohner winkt,
- bleibt an einem Ort,
- Ort wirkt lebendiger,
- Markt oder Haus bekommt soziale Bewegung.

Regeln:

- Dialoge sind spaetere Lernform.
- Bewohner bringen Leben, sind aber keine freie Ressourcendruckmaschine.
- Keine freien KI-Rewards.
- Aufgaben muessen sicher und kontrolliert sein.

## 10. Companion-Vorschlaege

Der Companion erkennt Kontext, z. B.:

- freie BuildZone,
- fast fertiges Fundament,
- Bibliotheksziel,
- privater Nebel,
- offenes Tagesziel,
- kurze verfuegbare Session.

Vorschlag:

- `Fundament beginnen`
- `Woerter ueben`
- `Bibliothek oeffnen`
- `Nebel retten`
- `Naechsten kleinen Schritt zeigen`

Regeln:

- Vorschlag gibt keine Ressource.
- Ressource entsteht erst nach geloester Aufgabe.
- Companion soll fuehren, nicht draengen.
- Keine Schuld- oder Drucksprache.
- Companion kann nach Erfolg kurz kommentieren.

Beispiel:

> Vori: `Hier ist ein guter erster Bauplatz. Drei Woerter reichen, um das
> Fundament zu wecken.`

## 11. Klassischer Lernscreen Als Ergaenzung

Ein effizienter klassischer Lernmodus bleibt erlaubt.

Rolle:

- konzentrierte Wiederholung,
- bekannte Lernflows schuetzen,
- Nutzer mit wenig Zeit bedienen,
- SRS und bestehende Lernlogik nicht zerstoeren.

Aber:

- Fortschritt soll danach in der Welt sichtbar werden.
- Lernen und Weltwirkung duerfen nicht auseinanderfallen.
- Klassischer Screen kann Ressourcen oder Bauimpulse erzeugen.
- Weltfeedback muss folgen, z. B. beim Rueckkehr in die Inselansicht.

Regel:

Der klassische Lernscreen ist ein effizienter Trainingsweg. Die Welt bleibt der
Ort, an dem Fortschritt emotional sichtbar wird.

## 12. Zustand Und Datenfluss

Lokale/mock Planungsobjekte:

| Zustand | Bedeutung |
| --- | --- |
| `selectedWorldObject` | angetipptes Objekt, z. B. Gebaeude oder Nebel |
| `selectedBuildZone` | angetippte BuildZone |
| `activeLearningTask` | aktuell angebotene Aufgabe |
| `taskResult` | lokales Ergebnis der Mock-Aufgabe |
| `localBuildProgress` | lokaler sichtbarer Baufortschritt |
| `localResourcePreview` | kleine kontextuelle Ressourcenanzeige, z. B. Stein |
| `visibleWorldEffect` | Effekt, der nach Aufgabe gezeigt wird |

Fluss fuer ersten Slice:

1. `selectedBuildZone` wird gesetzt.
2. `activeLearningTask` wird lokal erzeugt.
3. Nutzer loest Mock-Aufgabe.
4. `taskResult` wird lokal bewertet.
5. `localResourcePreview` zeigt Stein/Bauimpuls.
6. `localBuildProgress` aendert BuildZone-Zustand.
7. `visibleWorldEffect` zeigt Fortschritt.

Grenzen:

- Keine echte Reward Bridge.
- Keine SRS-/`word_progress`-Aenderung.
- Keine Cloud Writes.
- Keine Persistenz.
- Nur spaeter anschlussfaehig planen.

## 13. Erste Technische Slice-Empfehlung

Umfang:

- Waldlichtung als empfohlene Starter-Insel,
- eine `main_build_area`,
- Kontextkarte `Fundament beginnen`,
- lokale Mock-Aufgabe,
- sichtbar lokaler Fortschritt,
- Companion-Kommentar,
- keine Persistenz,
- keine Supabase Writes,
- keine echte Reward Bridge.

Empfohlener Ablauf:

1. Nutzer tippt auf `main_build_area`.
2. Kontextkarte erscheint.
3. Nutzer startet `3 einfache Woerter erkennen`.
4. Lokale Mock-Antwort wird als erfolgreich bewertet.
5. Bauzustand wechselt sichtbar zu `foundation_started`.
6. Companion kommentiert.
7. Naechster Schritt wird angeboten.

V1-/Phase-2E-Reduktion:

- sichtbar nur Stein,
- keine dauerhafte Ressourcenverwaltung,
- keine Bibliothek, Bruecke, Nebel oder NPC als erster Slice,
- Fokus auf Bauplatz und Fundament,
- Welt bleibt sichtbar.

## 14. UI-Schutzregeln

Schutzregeln:

- Keine ueberladene UI.
- Maximal eine klare Aufgabe gleichzeitig.
- Ressourcen nur kontextuell anzeigen.
- Keine langen Texte waehrend der Aufgabe.
- Welt bleibt sichtbar.
- Nutzer muss jederzeit abbrechen koennen.
- Kein Druck, keine Schuldsprache.
- Keine permanente Wallet- oder Zahlenlast in der ersten Session.
- Keine Debug-Begriffe in sichtbarer UI.

Aufgabenkarten sollen beantworten:

- Was baue ich?
- Was muss ich tun?
- Was passiert danach sichtbar?

## 15. Kosten- Und KI-Regeln

Regeln:

- Keine KI bei jeder kleinen Aufgabe.
- KI nur fuer hochwertige Satzfunken oder Companion-Kontexte.
- Lokale/mock Aufgaben zuerst.
- DeepL/Uebersetzung nicht im Grundloop erzwingen.
- Kostenkontrolle beachten.
- KI-Ergebnisse spaeter cachen.
- Teure Aktionen bewusst platzieren.

Erster Slice:

- keine KI,
- kein DeepL,
- keine Cloud,
- keine Kosten aus der Aufgabe.

## 16. Test- Und Akzeptanzkriterien

Dieses Dokument ist gut, wenn:

- klar ist, wie eine Aufgabe aus einer BuildZone entsteht,
- klar ist, wie Aufgabe, Ressource und Bauwirkung verbunden sind,
- UI nicht ueberladen wird,
- klassischer Lernscreen weiter moeglich bleibt,
- keine SRS-/Reward-/Cloud-Aenderung vorweggenommen wird,
- ein kleiner technischer Slice ableitbar ist.

Ein spaeterer erster UI-Slice gilt als passend, wenn:

- Tap auf `main_build_area` eine Kontextkarte oeffnet,
- die Karte `Fundament beginnen` zeigt,
- eine lokale Mock-Aufgabe geloest werden kann,
- die BuildZone sichtbar zu `foundation_started` wechselt,
- Companion-Kommentar erscheint,
- keine Persistenz, keine Supabase Writes, keine echte Reward Bridge und keine
  SRS-/`word_progress`-Aenderungen passieren.

Offene Fragen:

- Soll die erste Aufgabe direkt im Bottom Sheet oder in einer eigenen kleinen
  Aufgabenkarte laufen?
- Wie viel vom Bauplatz bleibt waehrend der Aufgabe sichtbar?
- Wann wird der klassische Lernscreen in den Weltloop zurueckgemeldet?
- Wie werden spaetere Innenraeume mit der Weltkarte verbunden?
- Welche Begriffe sind fuer Nutzer am verstaendlichsten: `Aufgabe`,
  `Bauziel`, `Lernquest` oder etwas Talvori-eigenes?
