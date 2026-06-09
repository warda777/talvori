# 358 - Fun, Adventure, Curiosity and Reward Gameplay Spine Gate

Status: verbindliches Strategie-/Gameplay-Gate fuer M16-BN.

Scope: Dokumentation, Gameplay-Regel, Slice-Prompt-Regel.

Nicht-Scope: Code, App-Integration, Route, Persistenz, Assets, Economy,
Reward-Implementierung, BuildState, Produktivmechanik-Freigabe.

## 1. Zweck

Dieses Gate ist die hoechste Spielspass-, Adventure-, Curiosity- und
Reward-Regel fuer Talvori Welt.

Talvori darf nicht nur korrekt, sicher und lehrreich sein. Talvori muss Spass
machen, Neugier erzeugen, Ownership geben und Nutzer freiwillig weiterspielen
lassen.

Der sichtbare Produktanker ist nicht:

> Ich erledige Lernaufgaben.

Sondern:

> Ich entdecke Orte, baue etwas, oeffne Dinge, repariere Welt, finde Bedeutungen
> und will sehen, was als Naechstes moeglich wird.

Lernen ist weiterhin der Motor. Das sichtbare Gefuehl ist Spiel, Aufbau,
Entdeckung, Reparatur, Sammlung und neue Moeglichkeit.

## 2. Harte Produktregel

Jeder zukuenftige Bau-, Lern-, Insel-, Quest-, Container-, Objekt-, UI- oder
Implementierungs-Slice muss beantworten:

- Warum macht diese Aktion Spass?
- Welche Neugier entsteht?
- Was will der Spieler als Naechstes tun?
- Was wird gebaut, geoeffnet, gefunden, gesammelt, gerettet, repariert oder
  verbessert?
- Welche kleine Belohnung oder neue Moeglichkeit entsteht?
- Warum fuehlt es sich nicht wie Lernen an?
- Welche erfolgreiche Spielmuster-Logik wurde uebertragen?

Wenn ein Slice diese Fragen nicht beantworten kann, ist er noch nicht reif fuer
Code. Dann braucht er zuerst ein Gameplay-/UX-Gate oder einen kleineren
spielbaren Proof.

## 3. Benchmark-/Research-Check

Dieses Gate baut auf den Research-Dokumenten 340, 343, 344, 346 und 350 auf.
Talvori kopiert keine Spiele blind. Talvori uebernimmt nur die Logik hinter
erfolgreichen Mustern und verwirft Druck-, FOMO- und Pay-to-Win-Mechaniken.

| Musterfeld | Was funktioniert? | Warum funktioniert es? | Was uebernimmt Talvori? | Was verwirft Talvori? | Risiken |
| --- | --- | --- | --- | --- | --- |
| Aufbau-/Base-Games | Sichtbares Wachstum, Besitz, Ausbau, neue Bauoptionen | Spieler sieht: Mein Ort veraendert sich durch mein Handeln. | Welt-/Grundstuecks-/Gebaeudeausbau als Fortschrittsgefuehl | Timer, Ressourcen-Druck, Pay-to-Win, Angriffsdruck | Bau kann zu Grind werden, wenn Lernen nur Kostenstelle ist. |
| Adventure-/RPG-Spiele | Orte erkunden, kleine Geheimnisse, Wege, Begleiter | Neugier und Kontext ziehen den Spieler weiter. | Inseln, Wege, Container, Tali/Vori-Hinweise, Orte mit Bedeutung | lange Dialogwaende, Pflichtquests, Drama mit sensiblen Inhalten | Adventure darf Lernen nicht verstecken, bis es irrelevant wird. |
| Crafting-/Werkbank-Spiele | Dinge kombinieren, herstellen, verbessern | Spieler versteht Funktion durch Handlung. | Bauteile, Werkbank, Reparatur, Objektwahl, Container-Depth | Material-Grind, harte Rezepte, Scheitern mit Verlust | Crafting darf nicht zu Verwaltungsarbeit werden. |
| Puzzle-/Match-/Runner-Spiele | Kleine Huerde, schnelle Handlung, klares Feedback | Kurze Schleifen erzeugen Flow ohne grosse Erklaerung. | Mini-Huerden als Weltaktionen: sortieren, einsetzen, Weg waehlen | Score-Druck, Timer, Fehlerbestrafung, Streak-Zwang | Zu abstrakte Puzzles fuehlen sich wieder wie Lernfenster an. |
| Sammel-/Karten-/Inventar-Spiele | Sammeln, ordnen, wiederfinden, Deck/Archiv | Besitz und Wiedererkennung machen Fortschritt greifbar. | Wortarchiv, Fundstuecke, Container, Sammlungsorte | Gacha, Lootboxen, Seltenheitsdruck, Sammelzwang | Sammlung darf nicht in FOMO kippen. |
| Social-/Clan-/Competition-Games | Freunde, Reaktionen, Showcase, gemeinsames Staunen | Soziale Bedeutung verstaerkt Ownership. | Spaeter: Freunde, Showcase, Reaktionen | PvP, Leaderboard, Clanpflicht, sozialer Druck im MVP | Social kann Druck erzeugen und ist nach dem lokalen Wow-Moment. |

## 4. Fun-/Adventure-Loop

Der Fun-/Adventure-Layer liegt ueber dem Construction-Learning-Spine:

```text
Neugier-Hook
-> Ziel sichtbar
-> kleine Huerde
-> spielerische Handlung
-> Feedback
-> sichtbarer Fortschritt
-> kleine Belohnung / neue Moeglichkeit
-> naechster Hook
```

Beispiel fuer den ersten Bauplatz:

- Neugier-Hook: Auf der Lichtung ist ein leerer Bauplatz.
- Ziel sichtbar: Hier kann ein erstes Haus entstehen.
- Kleine Huerde: Drei Bauteile liegen bereit, aber nur eines stabilisiert den
  Ort zuerst.
- Spielerische Handlung: Der Spieler waehlt das Fundament am Bauplatz.
- Feedback: Der Boden wird fester und die Fundament-Skizze leuchtet klarer.
- Sichtbarer Fortschritt: Der Fundament-Candidate wirkt greifbarer.
- Kleine Belohnung / neue Moeglichkeit: "Aussenwaende spaeter" wird angedeutet.
- Naechster Hook: Welche Wandteile passen als Naechstes?

## 5. Talvori-Spielspannungen

Erlaubte Spielspannungen:

- etwas oeffnen
- etwas finden
- etwas freischalten
- etwas reparieren
- etwas bauen
- etwas retten
- etwas einsammeln
- etwas kombinieren
- einen Weg waehlen
- einen Container oeffnen
- ein Geheimnis entdecken
- einen beschaedigten Ort wiederherstellen
- eine neue Faehigkeit oder Zusatzkraft erhalten
- eine neue Bauoption sichtbar machen
- eine kleine Mission abschliessen

Diese Spannungen muessen ruhig, freiwillig und spielerisch bleiben. Sie duerfen
keinen Verlust-, Zeit- oder Schuld-Druck erzeugen.

## 6. Nicht erlaubte Spannungen

Blockiert fuer Talvori, besonders im MVP:

- Timer-Druck
- Streak-Schuld
- Pay-to-Win
- FOMO
- Verlustangst
- Zwangsreview
- bestrafende Fehler
- sensible Inhalte als Drama oder Reward
- Lernen kaufen
- Lootbox-/Gacha-Druck
- PvP oder Leaderboard im MVP
- Vernichtung als Stressmechanik

Fehler sind Hinweise. Pausen sind erlaubt. Fortschritt darf Neugier erzeugen,
aber keinen Zwang.

## 7. Vernichtung / Gefahr / Rettung richtig einordnen

"Gegen Vernichtung ankaempfen" kann als Spielspannung funktionieren, ist fuer
Talvori aber nur in einer sicheren, druckfreien Form erlaubt.

Nicht erlaubt:

- Weltverlust
- Zeitdruck
- Bestrafung
- Angst
- soziale Bloesse
- Pflicht-Rettung

Erlaubte Talvori-Versionen:

- Nebel vertreiben
- kaputten Weg reparieren
- verwilderten Ort aufraeumen
- verlorenes Objekt finden
- dunkle Flaeche wieder beleuchten
- beschaedigten Bauplatz stabilisieren
- Woerter aus dem Archiv wiederfinden

Ziel ist Spannung ohne Druck: Die Welt bittet um Hilfe, sie droht nicht mit
Verlust.

## 8. Belohnungen als neue Moeglichkeiten

Belohnungen sind in Talvori primaer neue Moeglichkeiten, nicht manipulative
Retention.

Erlaubte Belohnungsarten fuer lokale Previews und spaetere Gates:

- neuer Bauabschnitt wird sichtbar
- neue Blueprint-Idee erscheint
- neuer Slot-Hinweis wird sichtbar
- neues Fundstueck taucht auf
- kleine Dekor-/Lichtreaktion als Preview
- ein Container oeffnet sich
- neue Tali/Vori-Hilfe wird verfuegbar
- neue Insel-Andeutung erscheint
- Archiv-Eintrag wird auffindbar
- Zusatzkraft als lokale Faehigkeit, z. B. "Blick", "Lupe", "Reparieren"

Nicht freigegeben:

- echte Economy
- Persistenz-Reward
- Premium-/Paywall-Reward
- Lootbox
- Timer-Boost
- BuildState-Freigabe

## 9. Spielmechanik-zu-Lernnutzen-Matrix

| Spielmechanik | Lernnutzen | Talvori-Form |
| --- | --- | --- |
| Weg waehlen | Praepositionen, Richtung, Bewegung | Spieler waehlt Pfad, Bruecke, Tuer oder Route in der Welt. |
| Objekt finden | Nomen, Ort, Kontext | Ein Gegenstand liegt am richtigen Ort und macht Bedeutung sichtbar. |
| Container oeffnen | TinyObjects, Alltagswoerter | Fach, Schublade, Tasche oder Kiste wird als kleiner Bedeutungsraum geoeffnet. |
| Bauteil sortieren | Reihenfolge, Funktion, Bauwortfeld | Fundament, Fenster, Dach werden am Bauplatz als Objekte verstanden. |
| Reparieren | Verben, Ursache/Wirkung | Spieler stabilisiert, flickt, richtet, verbindet oder beleuchtet. |
| Sammeln | Kategorien, Wiedererkennung | Fundstuecke, Wortgruppen oder Objekte landen in Ort, Archiv oder Container. |
| Schatz finden | Kontext, Bedeutung, Erinnerung | Ein Fund erklaert ein Wort ueber Umgebung und Geschichte. |
| Zusatzkraft nutzen | Strategie, Wiederholung, Entscheidung | Lupe/Blick/Reparieren hilft, ohne Druck eine Bedeutung zu klaeren. |
| Nebel/Blockade loesen | Verstaendnis/Recall als Weltklarheit | Ein Ort wird klarer, weil Bedeutung verstanden wurde. |
| Raum betreten | Interior-Wortfelder | Kueche, Wohnzimmer, Schrank und Fach tragen Alltagswortfelder. |

## 10. Mission-Struktur

Eine kleine Talvori-Mission besteht aus:

- Ziel
- Ort
- Handlung
- Lernnutzen
- sichtbarem Feedback
- freiwilligem naechsten Schritt

Beispiel:

| Feld | Inhalt |
| --- | --- |
| Ziel | Fundament vorbereiten |
| Ort | Uferhain-Lichtung |
| Handlung | Bauteile richtig waehlen |
| Lernnutzen | Fundament, Fenster und Dach unterscheiden |
| Sichtbares Feedback | Fundament wird klarer und der Boden wirkt stabil |
| Freiwilliger naechster Schritt | "Aussenwaende spaeter" |

Eine Mission ist kein Formular und keine Aufgabenliste im Vordergrund. Die Welt
traegt Ziel, Huerde und Feedback.

## 11. Beispiel fuer den ersten Vertical Slice

M16-BM darf nicht so gelesen werden:

> Waehle Fundament aus drei Optionen.

Die richtige Lesart ist:

> Der Bauplatz ist leer. Drei Bauteile liegen bereit. Welches Teil stabilisiert
> den Ort zuerst?

Richtiges Feedback:

> Der Boden wird fest. Jetzt kann hier spaeter ein Haus wachsen.

Naechster Hook:

> Aussenwaende spaeter.

Die Lernhandlung ist damit nicht ein Quiz, sondern eine Bauhandlung am Ort.

## 12. Konsequenz fuer M16-BM

M16-BM-FIX ist fachlich in die richtige Richtung gegangen: Insel-Showcase,
Weltansicht, mehrere Slots, BuildChoice-Preview und Bauplatz-Aufgabe zeigen den
gewuenschten Spine besser als ein isoliertes Lernfenster.

Trotzdem ist M16-BM-FIX noch ein technischer Zwischenstand:

- zu greyboxig
- zu wenig Hook
- zu wenig kleine Weltreaktion
- zu wenig Belohnung als neue Moeglichkeit
- Bauteile koennen noch staerker wie Spielobjekte wirken

Empfehlung: M16-BM nicht verwerfen, sondern vor Commit oder vor dem naechsten
Produktions-Gate als technische Basis weiter polieren.

## 13. Folge-Code-Slice: M16-BO

Empfohlener naechster Code-Slice:

> M16-BO Game-like Construction Hook Polish

Ziel:

- bestehende M16-BM-Preview weiter polieren
- weniger UI-Text
- staerkerer Hook
- Bauplatz wirkt wie Aufgabe
- Bauteile wirken wie Spielobjekte
- richtiges Fundament erzeugt kleine Weltreaktion
- neuer Hook "Aussenwaende spaeter"
- kein BuildState
- keine Persistenz

Erlaubte Dateien fuer M16-BO:

- `lib/features/world/local_world/ui/widgets/local_island_showcase_foundation_camera_preview.dart`
- `lib/features/world/local_world/ui/widgets/local_island_showcase_foundation_camera_preview_main.dart`

Nicht empfohlen:

- Starter-Island-Board weiter ueberladen
- isolierte Bank-/Wortmomente als naechsten Code-Schritt
- neue Route oder App-Integration

## 14. M16T-FUN IDs

Dieses Gate dokumentiert folgende erledigte Regel-IDs:

- M16T-FUN-001 Fun/Adventure/Curiosity Spine
- M16T-FUN-002 Every slice must define player hook
- M16T-FUN-003 Construction task must include playful tension
- M16T-FUN-004 Reward means new possibility, not pressure
- M16T-FUN-005 Safe danger/repair/discovery patterns
- M16T-FUN-006 M16-BO Hook Polish readiness

## 15. Prompt-Regel fuer 336

Kuenftige Gameplay-, World-, UI-, BuildChoice-, Learning- und
Implementierungs-Slices muessen 358 lesen.

Jeder solche Prompt muss beantworten:

- Was ist der Player Hook?
- Was ist die kleine Huerde?
- Welche Spielhandlung entsteht?
- Welche Belohnung oder neue Moeglichkeit entsteht?
- Warum will der Spieler weitermachen?
- Welche erfolgreichen Spielmuster wurden uebertragen?
- Welche Druck-, FOMO-, Pay-to-Win- oder Schuldmuster wurden verworfen?

## 16. Play-First-Ergaenzung fuer 345

Die Play-First Doctrine wird durch dieses Gate erweitert:

- Spass, Neugier, Entdeckung, Baufortschritt, Sammeln, Oeffnen, Reparieren und
  neue Moeglichkeiten sind harte Prioritaet.
- Lernen darf nie das sichtbare Pflichtgefuehl sein.
- Jede Implementierung braucht einen Fun-/Hook-Check.
- Belohnung bedeutet neue Moeglichkeit, nicht Druck.

## 17. Referenz zu 355 und 357

- 355 definiert den Construction Learning Spine.
- 357 definiert den Game-like Kamera-/Showcase-Flow.
- 358 definiert den Fun-/Adventure-/Curiosity-Layer, der ueber beiden liegt.

Ein Slice kann den Spine technisch korrekt treffen und trotzdem noch falsch
sein, wenn Hook, Neugier, Belohnung und Spielhandlung fehlen.

## Stop-Regeln

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
