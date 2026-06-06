# Phase 2G-M8: World Depth, Gameplay Motivation And Retention Research

Stand: 2026-06-06

Status: `Research-/Planungsblock gestartet`

Dieses Dokument ist ein reiner Research- und Planungsblock. Es wurden keine
Flutter-/Dart-Dateien, keine Spielassets, keine PNGs, keine App-Integration,
keine Tests, keine Supabase-Daten, keine Persistenz, keine SRS-/
`word_progress`-Daten, keine Reward Bridge, keine Ressourcenlogik und kein
`frame_started` geaendert.

M8 fuehrt zwei bisher getrennte Fragen zusammen:

1. Wie verhindert Talvori visuelle Ueberladung durch World Depth, Zoom,
   Interior-, Object- und Container-Ebenen?
2. Wie wird Talvori mehr als ein schoenes Museum, also ein motivierendes,
   langfristig spielbares Lernspiel mit fairer Retention und spaeter fairer
   Monetarisierung?

Fuehrende interne Grundlagen:

- `docs/world_design/223-learning-to-building-loop.md`
- `docs/world_design/224-economy-balancing.md`
- `docs/world_design/225-in-world-learning-ui.md`
- `docs/world_design/232-onboarding-first-session.md`
- `docs/220-talvori-world-professional-game-architecture-research.md`
- `docs/222-talvori-world-game-system-master-plan.md`
- `docs/world_design/252-flexible-plot-placement-and-learning-semantics.md`
- `docs/world_design/253-capability-greybox-plan.md`
- `docs/world_design/254-capability-greybox-visual-review.md`

Ethik-Leitlinie:

Talvori darf motivierend, belohnend und wirtschaftlich tragfaehig werden. Es
darf aber keine manipulativen, ausbeuterischen oder gesundheitsschaedlichen
Suchtmechaniken verwenden. Besonders wichtig sind junge Nutzer, Datenschutz,
Pausenfreundlichkeit, kein Pay-to-Win beim Lernen und keine harte Bestrafung
von Lernpausen.

## Research Gate

Die folgenden Quellen und Spiele wurden fuer M8 kurz, aber fokussiert
ausgewertet. Die Ableitungen sind research-informed Orientierung, keine
Kopiervorlage.

| Quelle / Spiel / System | Beobachtung | Ableitung Fuer Talvori | Risiko | Entscheidung |
| --- | --- | --- | --- | --- |
| Supercell: [Clash of Clans Clan Games Rewards](https://support.supercell.com/clash-of-clans/en/articles/clan-games-rewards.html) | Herausforderungen zahlen auf gemeinsame Reward-Tiers ein; Belohnungsauswahl gibt Kontrolle. | Kleine Lernquests koennen auf sichtbare Weltziele, Blueprints und optionale Auswahlbelohnungen einzahlen. | Clan-/Tier-Druck, Zeitdruck und Pay-to-Win-Gefahr duerfen Lernen nicht dominieren. | Uebernehmen: sichtbare Ziele, Beitragslogik, Auswahl. Vermeiden: aggressiven Druck, harte Timer, gekaufte Lernvorteile. |
| Supercell: [Clash of Clans Clan Capital Rewards](https://ingame.support.supercell.com/clash-of-clans/en/articles/rewards-2.html) | Gemeinsame Aktivitaet wird belohnt und bleibt sozial lesbar. | Spaeter koennen Freunde/Showcase/Community-Projekte private Lernleistungen sichtbar machen, ohne globalen Druck. | Social kann schnell Pflichtgefuehl oder Vergleichsdruck erzeugen. | Social erst nach lokalem Wow-Moment; keine globale Pflicht-Competition. |
| Supercell: [Hay Day Derby Tasks](https://support.supercell.com/hay-day/en/articles/derby-tasks.html) | Aufgabenwahl, Produktionsgebaeude, Timer und Nachbarschaft erzeugen strukturierte Tagesziele. | Garten-, Markt-, Farm- und Containeraufgaben koennen kurze, thematische Wortketten bilden. | Timer und Extra-Tasks gegen Premiumwaehrung koennen ausbeuterisch wirken. | Uebernehmen: thematische Aufgabenketten. Vermeiden: bezahlte Pflichtaufgaben und harte Lernfristen. |
| Nintendo: [Animal Crossing: New Horizons](https://animalcrossing.nintendo.com/new-horizons/?cd=true) | Persoenliche Insel, Sammeln, Dekorieren, Crafting und Tagesrhythmus erzeugen ruhige Langzeitbindung. | Talvori sollte persoenliche Inseln, Container-Sammlungen, Deko und Tali/Vori-Routine nutzen. | Reines Dekorieren kann ohne Lernhandlung zum Museum werden. | Uebernehmen: Besitzgefuehl, Routine, Atmosphaere. Ergaenzen: Lern-Challenges pro Tiefe. |
| Stardew Valley Wiki: [Getting Started](https://wiki.stardewvalley.net/Getting_Started) und [Crafting](https://wiki.stardewvalley.net/Crafting) | Offene Ziele, mehrere Aktivitaeten, Skills, Quests, Crafting und Beziehungen tragen langfristige Motivation. | Nutzer darf Lern- und Baupfad frei waehlen: Garten, Haus, Markt, Natur, Reisen, Technik usw. | Zu viele Optionen koennen ueberfordern. | Uebernehmen: freie Aktivitaetswahl. Absichern: Onboarding, Vorschlaege, kleine Ziele. |
| Duolingo Blog: [Streaks keep learners committed](https://blog.duolingo.com/how-streaks-keep-duolingo-learners-committed-to-their-language-goals/) | Streaks, Ziele, Erinnerungen und kleine Sessions erzeugen Rueckkehranlaesse. | Talvori kann Tagesimpuls, kurze Weltquests und sanfte Streak-/Comeback-Momente nutzen. | Streak-Verlust kann Stress, Schuldgefuehl oder Zwang erzeugen. | Streaks nur weich und pausenfreundlich; keine harte Bestrafung. |
| Niantic: [Pokemon GO Community Days](https://niantic.helpshift.com/hc/en/6-pokemon-go/faq/1770-what-are-community-days/) | Begrenzte Themenereignisse, seltene Funde und Sammlung erzeugen Event-Motivation. | Talvori kann Wortsets, Container-Sets, Themeninsel-Events und saisonale Lernimpulse nutzen. | FOMO, Datenschutz und Orts-/Zeitdruck sind kritisch, besonders fuer junge Nutzer. | Uebernehmen: Themen-Events und Sammlungen. Vermeiden: harte FOMO, GPS-Zwang, Druckfenster. |
| King: [Candy Royale / Candy Crush Saga](https://candycrush.zendesk.com/hc/en-us/articles/4404903647517--Candy-Royale) | Kurze Level, klare Ziele, Serienerfolg und Events erzeugen schnelle Erfolgsmomente. | Container-/Detailansichten koennen Mikro-Challenges mit klarem Abschluss tragen. | Verlustserien, Booster-Druck und monetarisierte Friktion sind ungeeignet fuer Lernen. | Uebernehmen: kurze Challenges, klares Ergebnis. Vermeiden: bezahlte Fehlerreparatur und Druckspiralen. |
| Unity Docs: [LiveOps](https://docs.unity.com/liveops) und [Remote Config](https://docs.unity.com/en-us/remote-config/_index) | Erfolgreiche LiveOps nutzen Analytics, Events, Remote Config, Economy und segmentierte Einstellungen. | Spaeter braucht Talvori steuerbare Events, Pausenfreundlichkeit, Experiment-Gates und Kostenkontrolle. | LiveOps kann Dark Patterns, Ueberoptimierung und Datenschutzrisiken erzeugen. | Erst lokal planen; spaeter eigenes LiveOps-/Privacy-/Monetization-Dokument. |

Zusammenfassung der Research-Entscheidung:

- Erfolgreiche Spiele halten Nutzer durch klare Kurzloops, sichtbare
  Fortschritte, langfristige Projekte, Sammlung, Tagesziele, persoenliche
  Weltbindung, Social/Showcase und Events.
- Talvori uebernimmt diese Muster nur, wenn sie Lernen sichtbar machen,
  Nutzerfreiheit respektieren und Pausen nicht bestrafen.
- Talvori vermeidet aggressive Timer, harte FOMO, bezahlte Lernvorteile,
  manipulative Streak-Druckmechanik, Kinder-/Familien-Druck und jedes
  Pay-to-Win beim Lernen.

## 1. World Depth And Zoom System

Talvori darf nicht versuchen, alle Woerter und Objekte gleichzeitig in der
Island View sichtbar zu machen. Die Welt braucht Tiefe.

Geplante Ebenen:

| Ebene | Zweck | Sichtbare Beispiele |
| --- | --- | --- |
| `IslandView` | Ganze Insel, Themeninsel, grobe Plot-Uebersicht. | Starterinsel, Kuesteninsel, Stadtinsel, grobe Plot-Slots. |
| `PlotView` | Konkretes Grundstueck oder Bereich. | Gartenbereich, Marktbereich, Hof, Schulhof, Hafenplot. |
| `BuildingView` | Gebaeude von aussen, Bauzustand, Eingang, Fassade. | Haus, Marktstand, Schule, Werkstatt, Bootshaus. |
| `InteriorView` | Raum / Innenbereich. | Kueche, Klassenzimmer, Garage, Werkstatt, Kajute. |
| `ObjectView` | Einzelnes Objekt fokussiert. | Schrank, Kuehlschrank, Tisch, Boot, Werkzeugkasten. |
| `ContainerOpenView` | Geoeffnetes Objekt mit Inneninhalt. | Schublade mit Besteck, Federmappe mit Stiften, Koffer mit Kleidung. |
| `DetailInteractionView` | Mini-Interaktion, Aufgabe, Quiz, Sortieren, Zuordnen. | Besteck sortieren, Werkzeug finden, Rezept vervollstaendigen. |

Beispielketten:

- Insel -> Haus -> Kueche -> Schublade -> Loeffel / Gabel / Messer
- Insel -> Schule -> Klassenraum -> Federmappe -> Bleistift / Lineal /
  Anspitzer
- Insel -> Hafen -> Boot -> Kajute -> Kompass / Karte / Seil
- Insel -> Garten -> Beet -> Pflanze -> Bluete / Samen / Giesskanne

Regeln:

- Nicht alles ist gleichzeitig sichtbar.
- Die Island View zeigt nur Hauptstruktur, Fortschritt und wenige Highlights.
- Kleine Woerter gehoeren in Container-, Object- oder Detailansichten, nicht
  zwangslaeufig auf die Inseloberflaeche.
- Tiefe ist der zentrale Schutz gegen visuelle Ueberladung.
- Zoom ist nicht nur Kameraeffekt, sondern semantischer Ebenenwechsel.

## 2. Container Objects

Container-Objekte sind Lernraeume in Miniatur. Sie sind nicht nur Deko.

Moegliche Container:

- Schublade
- Schrank
- Kuehlschrank
- Federmappe
- Rucksack
- Werkzeugkasten
- Koffer
- Regal
- Kiste
- Bootskajute
- Auto-Kofferraum
- Medizinschrank
- Marktstand-Korb
- Buecherregal

Container-Regeln:

- Ein Container kann geschlossen sichtbar sein.
- Ein Container kann angetippt werden.
- Ein Container kann sich oeffnen.
- Ein Container kann eigene `innerObjectAnchors` haben.
- Ein Container kann Woerter thematisch gruppieren.
- Ein Container kann Aufgaben enthalten.
- Ein Container kann neue Inhalte spaeter freischalten.
- Ein Container darf nicht beliebig viele Objekte gleichzeitig zeigen.

Beispiele:

| Container | Passende Woerter | Moegliche Aufgabe |
| --- | --- | --- |
| Schublade | Loeffel, Gabel, Messer, Serviette | Besteck richtig zuordnen. |
| Federmappe | Bleistift, Lineal, Radiergummi, Anspitzer | Schulobjekte finden und sortieren. |
| Werkzeugkasten | Hammer, Schraube, Zange, Schraubenzieher | Werkzeug zum Bild/Wort passen. |
| Kuehlschrank | Milch, Kaese, Apfel, Saft | Lebensmittel nach Kategorie sortieren. |
| Koffer | Hemd, Hose, Ticket, Pass | Reisegegenstaende packen. |
| Medizinschrank | Pflaster, Salbe, Tablette | Sensible Gesundheitsbegriffe vorsichtig als Kontextkarte. |
| Bootskajute | Kompass, Seil, Karte | Route vorbereiten. |

## 3. Word Type To Depth Mapping

Ein Wort soll auf der kleinstsinnvollen Ebene erscheinen. Das vermeidet
ueberladene Inseln und falsche Platzierung.

| Worttyp | Bevorzugte Tiefe | Beispiele | Regel |
| --- | --- | --- | --- |
| Grosse Orte | `IslandView`, `PlotView`, `BuildingView` | Schule, Krankenhaus, Markt, Hafen | Eher Themeninsel, Plot oder Gebaeude, nicht kleines Objekt. |
| Raeume | `InteriorView` | Kueche, Schlafzimmer, Klassenzimmer | Nur sichtbar, wenn passendes Gebaeude oder Blueprint existiert. |
| Moebel / Hauptobjekte | `InteriorView`, `ObjectView` | Tisch, Schrank, Kuehlschrank | Traegt oft Container- oder Interaktionsanker. |
| Kleine Objekte | `ContainerOpenView`, `ObjectView` | Loeffel, Messer, Stift, Schluessel | Nicht auf Hauptinsel erzwingen. |
| Bauteile | `BuildingView`, `BuildState` | Fenster, Tuer, Dach, Wand | Nur an passendem Gebaeudezustand; nie frei schwebend. |
| Aktionen | `DetailInteractionView`, Animation, Quest | oeffnen, schliessen, fahren, kochen | Als Handlung, Mini-Szene oder Aufgabe, nicht als statisches Objekt. |
| Abstrakte Begriffe | Codex, Dialog, Szene, Spezialbereich | Freiheit, Politik, Meinung | Nicht als beliebiger Gegenstand platzieren. |

Konsequenz:

- `Fenster` gehoert nicht auf einen freien Plot, sondern an ein Gebaeude mit
  Wand-/Fassadenzustand.
- `Giesskanne` gehoert in Garten, Hof, Schuppen, Container oder ObjectView.
- `politisch` gehoert in Codex, Dialog oder spaeter Debatten-/Forum-Kontext.
- `Loeffel` gehoert eher in eine Schublade als sichtbar auf die Insel.

## 4. Anchor Semantics

Die M7-B-Capability-Greybox zeigt `objectAnchors`. M8 klaert deren Bedeutung:

- `objectAnchor` bedeutet nur optionaler moeglicher Objektplatz.
- `objectAnchor` bedeutet nicht, dass dort immer ein Objekt stehen muss.
- Drei `objectAnchors` bedeuten maximal moegliche Platzierungspunkte auf
  dieser Ebene, nicht Pflicht fuer drei sichtbare Objekte.
- Ein `objectAnchor` kann ein sichtbares Objekt, ein Detailobjekt, ein
  Container-Einstiegspunkt oder ein spaeter leerer Platz sein.
- Container haben eigene innere Anchors.

Noetige Anchor-Typen:

- `outerObjectAnchor`
- `containerEntryAnchor`
- `innerObjectAnchor`
- `interactionAnchor`
- `rewardAnchor`
- `decorationAnchor`

Beispiel Kueche:

| Ebene | Anchor | Moegliche Nutzung |
| --- | --- | --- |
| `InteriorView` | `outerObjectAnchor_fridge` | Kuehlschrank als Objekt oder Container. |
| `InteriorView` | `containerEntryAnchor_drawer` | Schublade oeffnen. |
| `ContainerOpenView` | `innerObjectAnchor_spoon` | Loeffel sichtbar, wenn relevant. |
| `ContainerOpenView` | `innerObjectAnchor_fork` | Gabel sichtbar, wenn relevant. |
| `DetailInteractionView` | `interactionAnchor_sort` | Besteck sortieren. |

Sichtbarkeit wird begrenzt durch:

- Visual-Clutter-Regeln,
- Nutzerwahl,
- Lernstand,
- Wortkontext,
- aktive Aufgabe,
- Mobile-Lesbarkeit,
- Insel-/Plot-/Container-Ebene.

## 5. Interaction And Challenge Loop

Talvori darf kein Museum werden, in dem man Dinge nur anschaut.

Jede Tiefe kann Spiel-/Aufgabenlogik tragen:

- entdecken,
- oeffnen,
- finden,
- zuordnen,
- sortieren,
- reparieren,
- vervollstaendigen,
- kombinieren,
- sammeln,
- verbessern,
- freischalten,
- Mini-Quest loesen.

Beispiele:

- Schublade ist verschlossen -> richtige Vokabel auswaehlen -> Schublade
  oeffnet sich.
- Federmappe enthaelt falsche Gegenstaende -> Bleistift, Lineal und
  Radiergummi sortieren.
- Kueche braucht 3 Woerter -> Rezept-Minispiel wird freigeschaltet.
- Hafen braucht Seil, Karte und Kompass -> Boot vorbereiten.
- Garten braucht Giesskanne, Samen und Erde -> Pflanze waechst.
- Markt braucht Apfel, Brot und Preis -> Verkaufsdialog freischalten.

Regel:

Eine sichtbare Weltreaktion soll moeglichst mit einer kleinen Lernhandlung
verbunden sein. Reine Betrachtung bleibt erlaubt, ist aber nicht der Kernloop.

## 6. Talvori Core Loop And Meta Loop

### Core Loop

1. Nutzer lernt oder importiert Woerter.
2. Talvori analysiert Woerter und schlaegt passende Welt-, Plot-, Objekt-,
   Container- oder Codex-Bezuege vor.
3. Nutzer waehlt Aufgabe, Bereich, Plot, Container oder Detailobjekt.
4. Nutzer loest eine kleine Lerninteraktion.
5. Welt reagiert sichtbar.
6. Nutzer erhaelt Fortschritt, Blueprint, Objekt, Detail, Ressource, XP oder
   Codex-Fortschritt.
7. Naechste sinnvolle Aufgabe wird vorgeschlagen.

### Meta Loop

- Inseln ausbauen,
- Themeninseln freischalten,
- Raeume oeffnen,
- Container entdecken,
- Sammlungen vervollstaendigen,
- Objekte verbessern,
- Tali/Vori-Beziehung vertiefen,
- Daily/Weekly Aufgaben,
- Events,
- Showcase / private Insel-Praesentation spaeter,
- langfristige Lernpfade verfolgen.

Leitregel:

Der Core Loop muss in 2 bis 5 Minuten funktionieren. Der Meta Loop muss ueber
Wochen und Monate motivieren, ohne Schuldgefuehl oder Pay-to-Win.

## 7. Lessons From Successful Games

### Clash Of Clans

Analysierte Muster:

- Basisaufbau,
- Upgrades,
- Ressourcen,
- Wartezeiten,
- Bau-/Upgrade-Vorfreude,
- Clan-Aufgaben,
- sichtbare Fortschrittsstufen,
- regelmaessige Rueckkehr.

Fuer Talvori geeignet:

- kleine sichtbare Fortschritte,
- vorbereitete Blueprints,
- Upgrade-Stufen,
- Auswahlbelohnungen,
- spaeter Social/Showcase oder Freunde als leichte Beitragslogik.

Fuer Talvori ungeeignet:

- aggressiver Timer-Druck,
- Lernen gegen Geld beschleunigen,
- Pay-to-Win,
- Verlust-/Angriffslogik, die Lernfortschritt bedroht.

Talvori-Entscheidung:

Bau-/Upgrade-Vorfreude und Reward-Tiers sind brauchbar. Lernen bleibt fair;
Wartezeiten duerfen nicht das Lernen blockieren.

### Hay Day / Township

Analysierte Muster:

- Produktionsketten,
- Bestellungen,
- Ernten,
- Sammeln,
- ruhiges Wachstum,
- Nachbarschaftsaufgaben,
- Deko.

Fuer Talvori geeignet:

- Garten-/Markt-/Farm-Woerter als kleine Produktionsketten,
- Wortsets als Bestellungen oder Rezepte,
- ruhige Tagesaufgaben,
- Deko als kosmetische Belohnung.

Fuer Talvori ungeeignet:

- harte Timer,
- Premium-Aufgaben als Pflicht,
- Grind ohne Lernwert.

Talvori-Entscheidung:

Produktionsketten koennen als Lernketten dienen, z. B. Samen -> Pflanze ->
Ernte -> Marktgespraech. Sie duerfen nicht zur reinen Farmarbeit ohne Lernen
werden.

### Animal Crossing / Stardew Valley

Analysierte Muster:

- persoenliche Welt,
- freie Ziele,
- Sammeln,
- Atmosphaere,
- Routine,
- Beziehungen zu Figuren,
- Tagesziele,
- Dekoration,
- offene Langzeitmotivation.

Fuer Talvori geeignet:

- Personal Learning Archipelago,
- Tali/Vori als emotionaler Begleiter,
- ruhiger Besitz,
- Sammlungen,
- flexible Bauprioritaeten,
- kleine Tagesziele ohne Druck.

Fuer Talvori ungeeignet:

- reine Beschaeftigungsroutine ohne Lernhandlung,
- zu viele parallele Aufgaben,
- Pflichtalltag, der wie Arbeit wirkt.

Talvori-Entscheidung:

Talvori soll die Ruhe und Personalitaet uebernehmen, aber jede wichtige
Weltveraenderung mit Lernhandlung, Challenge oder Codex-Fortschritt verbinden.

### Duolingo

Analysierte Muster:

- kurze taegliche Aufgaben,
- Streaks,
- Ziele,
- Wiederholung,
- Units/Lernpfade,
- Erinnerung,
- Belohnungsfeedback.

Fuer Talvori geeignet:

- Tagesimpuls,
- Daily Word Quest,
- kurze Weltaufgabe,
- sanfte Rueckkehr,
- sichtbarer Lernpfad.

Fuer Talvori ungeeignet:

- harter Streak-Verlust,
- Schuld- oder Angstkommunikation,
- Streak als wichtiger als echtes Lernen.

Talvori-Entscheidung:

Streaks duerfen nur weich sein. Comeback soll belohnen, nicht bestrafen.

### Pokemon GO / Collection Games

Analysierte Muster:

- Sammeln,
- Entdecken,
- Set-Vervollstaendigung,
- Community Days,
- seltene Funde,
- Themenereignisse.

Fuer Talvori geeignet:

- Wortsets,
- Objektsets,
- Container-Sets,
- Themeninsel-Sammlungen,
- saisonale Lernimpulse,
- seltene, aber faire Entdeckungen.

Fuer Talvori ungeeignet:

- harte FOMO,
- GPS-Zwang,
- Eventzeiten, die Lernen ungesund dominieren,
- Datenschutzrisiken.

Talvori-Entscheidung:

Sammlung und Eventmotivation sind passend, aber ohne Ortszwang und ohne harte
Zeitfenster fuer Core Learning.

### Puzzle-/Level-Spiele

Analysierte Muster:

- kurzer Levelabschluss,
- klare Erfolgsbedingungen,
- steigende Schwierigkeit,
- schnelle Wiederholbarkeit,
- Events,
- Serienerfolg.

Fuer Talvori geeignet:

- Container-Mikro-Challenges,
- DetailInteractionView,
- klare Erfolgsmomente,
- kurze Lernaufgaben mit sichtbarer Weltreaktion.

Fuer Talvori ungeeignet:

- monetisierte Fehlerreparatur,
- Booster-Druck,
- kuenstlich frustrierende Schwierigkeit.

Talvori-Entscheidung:

Mikro-Challenges sind zentral fuer Tiefe. Sie muessen lernfair, kurz und
pausenfreundlich bleiben.

### Mobile LiveOps

Analysierte Muster:

- Events,
- Remote Config,
- Analytics,
- saisonale Inhalte,
- Segmentierung,
- Economy-Tuning,
- Push Notifications,
- Live-Balance.

Fuer Talvori geeignet:

- spaetere saisonale Lernereignisse,
- Kostenkontrolle fuer KI/Import,
- vorsichtige Produktmessung,
- Feature-Gates,
- pausenfreundliche Erinnerungen.

Fuer Talvori ungeeignet:

- aggressive Push-Flut,
- dunkle Monetarisierungsoptimierung,
- personenbezogene Sensibilitaets- oder Lerndaten ohne klares Privacy-Konzept.

Talvori-Entscheidung:

LiveOps kommt spaeter und braucht eigenes Datenschutz-, Safety-, Kosten- und
Monetarisierungsdokument. M8 plant nur Prinzipien.

## 8. Reward Moments And Motivation

Faire Motivationsmomente:

- sichtbarer Fortschritt,
- kurzes Feedback,
- Animation / Glow / Sound spaeter,
- Objekt erscheint,
- Container oeffnet sich,
- Set wird vervollstaendigt,
- Raum wird schoener,
- Tali/Vori reagiert emotional,
- neues Mini-Ziel erscheint,
- seltene Entdeckung,
- taegliche kleine Belohnung,
- langfristige Sammlung.

Regeln:

- Belohnung soll Kompetenz und Weltfortschritt zeigen, nicht Druck erzeugen.
- Kleine Sessions muessen sich sinnvoll anfuehlen.
- Grosses Wachstum braucht langfristige Ziele.
- Keine manipulative Dark-Pattern-Logik.
- Keine harten Verluste, die Nutzer psychologisch unter Druck setzen.
- Keine Pay-to-Win-Mechanik im Lernen.

## 9. Retention Without Exploitation

Geeignete Retention-Mechaniken:

- Daily Word Quest,
- Tagesimpuls,
- kleine Bau-/Objektziele,
- Container-Entdeckungen,
- Wochenziel,
- Event-Inseln,
- saisonale Deko,
- Tali/Vori-Erinnerungen,
- persoenliche Roadmap,
- Sammlungen,
- Fortschrittsjournal,
- sichtbare Rueckkehrbelohnung.

Fairness-Regeln:

- Rueckkehr soll belohnend sein, nicht bestrafend.
- Streaks duerfen motivieren, aber nicht schaden.
- Pausen duerfen nicht hart bestraft werden.
- Nutzer mit wenig Zeit sollen sinnvolle kurze Sessions haben.
- Verpasste Events duerfen Core Learning nicht blockieren.
- Comeback-Zustaende sollen privat, freundlich und reparierbar bleiben.

Moegliche Talvori-Retention-Loops:

| Loop | Sessionlaenge | Weltwirkung | Fairness-Grenze |
| --- | --- | --- | --- |
| Daily Word Quest | 2-5 Minuten | kleines Objekt, Blueprint oder Codex-Fortschritt | kein harter Streak-Zwang |
| Container Discovery | 3-7 Minuten | Container oeffnet sich, 1-3 Woerter werden sichtbar | nicht zu viele Objekte auf einmal |
| Weekly Set | 10-20 Minuten verteilt | Set wird vervollstaendigt, Raum wird schoener | kein FOMO fuer Core Learning |
| Theme Event | optional | saisonale Deko, Objektvariante, neue Szene | keine Pflicht, keine unfairen Paywalls |
| Comeback | 2-5 Minuten | freundliche Rueckkehrbelohnung, Nebel/Reminder privat | keine Strafe fuer Pause |

## 10. Monetization Fit

Talvori muss wirtschaftlich tragfaehig sein. Gleichzeitig darf Core Learning
nicht unfair blockiert werden.

Denkbare faire Monetarisierung:

- kosmetische Inselvarianten,
- zusaetzliche Deko,
- mehr parallele Insel-Slots,
- Komfortfunktionen,
- erweiterte KI-/Import-Funktionen, falls echte Kosten entstehen,
- Premium-Events,
- zusaetzliche Companion-Styles,
- bessere Showcase-/Layoutoptionen,
- zusaetzliche Container-/Interior-Varianten ohne Lernvorteil.

Nicht erlauben:

- Pay-to-Win beim Lernen,
- notwendige Grundwoerter hinter Paywall,
- manipulative Timer,
- bezahlte Pflicht-Booster fuer Lernfortschritt,
- Kinder-/Familiennutzer unfair unter Druck setzen,
- Core Learning als FOMO-Event verkaufen,
- notwendige Datenschutz-/Safety-Funktionen monetarisieren.

Monetarisierung braucht spaeter ein eigenes Dokument mit:

- Free/Paid-Prinzipien,
- Kinder-/Familien-Schutz,
- Kostenmodell fuer KI/Import,
- Fairness-Gates,
- Datenschutz,
- Store-/Compliance-Regeln,
- keine Pay-to-Win-Grenzen.

## 11. M8 Grundsatzentscheidungen

- Talvori braucht ein Depth-/Zoom-/Container-System.
- `objectAnchors` sind optionale technische Moeglichkeiten, keine
  Pflichtobjekte.
- Kleine Woerter gehoeren oft in Container-, Object- oder Detailansichten,
  nicht auf die Island View.
- Reines Anschauen reicht nicht; jede Tiefe braucht moegliche Aufgaben,
  Entdeckungen, Sortierungen, Reparaturen, Kombinationen oder Mini-Quests.
- Retention soll ueber sichtbaren Fortschritt, persoenliche Welt, Tagesimpuls,
  Container-Entdeckungen und Tali/Vori laufen, nicht ueber Druck.
- Monetarisierung bleibt geplant, aber blockiert bis eigenes Dokument.
- M7-D/M8 darf nicht nur textlich geplant werden. Depth-/Container-Flows wie
  Kueche -> Schublade -> Besteck oder Schule -> Federmappe -> Stifte muessen
  spaeter als Nutzerflow-Diagramm, Storyboard-Greybox oder Preview pruefbar
  gemacht werden.

## 12. Weiterhin Blockiert

Weiterhin blockiert bleiben:

- `frame_started`,
- neue Spielassets,
- PNGs im Asset-Ordner,
- finales Inselbild,
- Flutter-/Dart-Code,
- App-Integration,
- neue Bauzustaende,
- Persistence,
- Supabase,
- SRS-/`word_progress`,
- Reward Bridge,
- Ressourcenlogik,
- Sound-/FX-Schicht,
- echte LiveOps,
- Monetarisierung,
- Social-/Showcase-Funktionen.

## 13. Stop-Regeln

Stoppen, wenn:

- ein `objectAnchor` als Pflichtobjekt interpretiert wird,
- eine Ebene mit zu vielen sichtbaren Objekten ueberfuellt wird,
- eine technische Anchor-/Capability-Ansicht als Nutzeransicht verwendet wird,
- Container-/Zoom-Logik ohne Depth-System geplant wird,
- Talvori wie ein reines Museum ohne Interaktion oder Challenge wirkt,
- Retention-Mechaniken ohne Fairness-/Ethikpruefung geplant werden,
- Monetarisierung ohne eigenes Dokument konkretisiert wird,
- Pay-to-Win, Dark Patterns oder manipulative Timer in Lernfortschritt
  eingebaut werden,
- Streaks oder Events Core Learning blockieren,
- sensible oder junge Nutzer durch Druckmechaniken benachteiligt werden.

## 14. Naechster Erlaubter Schritt

Nach M8 ist erlaubt:

- M8 pruefen,
- M7-D/M8 als vereinfachte Nutzer-/Produktansicht planen,
- die Depth-/Container-Logik in eine Nutzerflow-Preview uebersetzen,
- Depth-/Container-Beispiele als Flowchart, Storyboard-Greybox oder einfache
  Produktansicht visuell pruefbar machen,
- Gameplay-/Retention-Fragen weiter vertiefen.

Weiterhin nicht erlaubt:

- Code,
- Assets,
- App-Integration,
- `frame_started`,
- produktive Bau-/Lernlogik,
- Monetarisierungsimplementierung,
- LiveOps-Implementierung.
