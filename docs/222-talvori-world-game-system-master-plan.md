# Talvori Welt: Game-System-Masterplan

Stand: 2026-06-04

Dieses Dokument beschreibt Talvori Welt als vollstaendiges Spielsystem. Es
verbindet Lernen, Ressourcen, Aufbau, Weltfortschritt, Social, Retention,
Monetarisierung, Cloud und Betrieb zu einem gemeinsamen Zielbild.

Es ist ein reines Planungsdokument. Es wurden keine Dart-/Flutter-Dateien,
keine Assets, keine Supabase-Daten, keine SQLite-/Vokabeldaten, keine SRS-Daten,
kein `word_progress`, keine Reward Bridge, keine Persistenz, keine Secrets und
keine Release-Artefakte geaendert.

Grundlagen:

- `docs/217-talvori-world-start-island-claiming-plan.md`
- `docs/218-talvori-world-connector-system-plan.md`
- `docs/219-talvori-world-docking-points-plan.md`
- `docs/220-talvori-world-professional-game-architecture-research.md`
- `docs/221-talvori-world-build-and-expansion-architecture.md`
- Talvori-Welt-Produktvision aus AGENTS.md und bisherigen Planungsbloecken

Hinweis:

Eine alte Konzept-PDF wurde bei Erstellung dieses Dokuments im Repository nicht
gefunden. Strategische Leitplanken daraus werden nur soweit beruecksichtigt, wie
sie in den bisherigen Talvori-Welt-Dokumenten enthalten sind.

Orientierung:

Talvori darf von erfolgreichen Aufbau-, Social- und Mobile-Game-Strukturen
lernen, z. B. langfristige Progression, kurze Belohnungsschleifen, saisonale
Ziele, Social Help und Community-Projekte. Talvori kopiert diese Spiele nicht.
Talvori bleibt ein Lern-Welt-Produkt.

Kernprinzip:

> Lernen erzeugt Ressourcen. Ressourcen ermoeglichen Aufbau. Aufbau macht
> Fortschritt sichtbar. Soziale und lebendige Elemente bringen Nutzer zurueck.

## 1. Warum Dieses Master-Dokument Noetig Ist

`docs/220` und `docs/221` klaeren die Weltstruktur:

- sichtbares Asset plus semantische Unsichtbar-Ebene,
- BuildZones,
- DockingPoints,
- PathNodes,
- DecorationZones,
- BlockedAreas,
- Templates,
- Renderer-Unabhaengigkeit.

Damit ist die technische Weltarchitektur vorbereitet. Es fehlt aber noch die
Spielsystem-Architektur.

Ohne Spielsystem-Architektur entstehen einzelne Features ohne klaren
Gesamtloop:

- ein schoener World-Screen ohne Grund zum Wiederkommen,
- Lernaufgaben ohne sichtbaren Weltgewinn,
- Ressourcen ohne Balancing,
- Gebaeude ohne emotionale Bedeutung,
- Social ohne sicheren und sinnvollen Nutzen,
- Monetarisierung ohne Bezug zu Kosten und Fairness,
- Cloud-Logik ohne klare Autoritaet.

Dieses Dokument klaert deshalb:

- wie Lernen und Bauen zusammenhaengen,
- wie Progression sichtbar wird,
- warum Nutzer zurueckkommen,
- welche Systeme spaeter Geld kosten,
- welche Einnahmequellen fair denkbar sind,
- welche Detaildokumente vor weiterer Implementierung noetig sind.

## 2. Kernspiel-Loop

Der Hauptloop von Talvori Welt:

1. Woerter sammeln oder importieren.
2. Woerter, Phrasen und Saetze im Kontext ueben.
3. Ressourcen erhalten.
4. Insel ausbauen.
5. sichtbaren Fortschritt sehen.
6. Companion reagiert.
7. neue Bauziele freischalten.
8. Freunde oder Community-Regionen besuchen.
9. mit neuer Motivation zurueckkommen.

Kurzloop fuer 2 bis 5 Minuten:

- ein Wort oder eine kleine Wortgruppe ueben,
- kleine Ressource erhalten,
- sichtbaren Mikrofortschritt sehen,
- Companion gibt Rueckmeldung.

Mittlerer Loop fuer 10 bis 15 Minuten:

- mehrere Woerter/Phrasen/Saetze bearbeiten,
- ein Fundament, Bauteil, Wegstueck oder Deko-Element sichtbar verbessern,
- Tagesziel teilweise oder ganz abschliessen.

Langfristiger Loop:

- eigene Insel ausbauen,
- weitere private Inseln freischalten,
- Community-Projekte mittragen,
- Freunde besuchen,
- saisonale Ziele verfolgen,
- Talvori Welt als eigenen Lernort erleben.

## 2a. First-Session-Flow

Der erste Einstieg muss sehr schnell erklaeren:

> Ich lerne Woerter und damit entsteht meine Welt.

Erste 1 Minute:

- Nutzer sieht die Talvori Welt, nicht zuerst ein Formular oder Dashboard.
- Der Globe-Tap fuehrt in eine hochwertige Weltansicht.
- Die Showcase-Insel zeigt, was spaeter moeglich ist.
- Der Companion benennt knapp das Prinzip: Lernen baut diese Welt.

Erste 5 Minuten:

- Nutzer sieht mehrere freie Starter-Inseln.
- Nutzer waehlt eine erste Insel.
- Der Besitzstatus wird visuell ruhig markiert.
- Das erste Tagesziel erscheint klein und konkret, z. B. eine erste Bauaktion
  vorbereiten.

Erste 15 Minuten:

- Nutzer loest eine erste Lernaufgabe direkt aus der Welt heraus.
- Ein erstes sichtbares Bauobjekt erscheint, z. B. ein Fundament, ein
  freigelegter Bauplatz oder ein kleiner Lichtpunkt.
- Der Companion kommentiert den Fortschritt kurz und persoenlich.
- Die Ressourcenwirkung wird sichtbar, ohne den Nutzer mit Zahlen zu
  ueberladen.

Erste 30 Minuten:

- Nutzer versteht den Unterschied zwischen freiem Erkunden,
  Bauplanung und Lernquest.
- Ein kleines Bauziel ist gestartet oder abgeschlossen.
- Das Tagesziel zeigt einen erreichbaren naechsten Schritt.
- Die Welt laedt zum Wiederkommen ein, ohne Druck aufzubauen.

Erster Wow-Moment:

- Die Welt sieht hochwertig aus, bevor der Nutzer etwas bezahlt.
- Die erste Inselwahl fuehlt sich wie Besitz an.
- Die erste Lernaufgabe veraendert die Welt sichtbar.
- Das erste Bauobjekt macht klar, dass Lernen nicht getrennt neben dem Spiel
  steht.

## 3. Lernen Im Spiel Statt Getrenntes Lernen

Lernen soll moeglichst in der Welt stattfinden. Ein klassischer Lernscreen darf
weiter existieren, aber der staerkste Modus ist In-World-Lernen.

Beispiele:

- Ein Bauplatz braucht ein Fundament. Der Nutzer loest eine Wortaufgabe. Das
  Fundament erscheint.
- Eine Bibliothek braucht Wissen. Der Nutzer versteht einen Satz. Ein Fenster,
  Regal oder Lichtpunkt erscheint.
- Eine Bruecke braucht Phrasen. Der Nutzer meistert Phrasen. Ein
  Verbindungsstueck entsteht.
- Ein Nebelbereich braucht Wiederholung. Der Nutzer erledigt SRS-Aufgaben. Der
  Nebel weicht privat zurueck.
- Ein Bewohner will einen Mini-Dialog. Der Nutzer antwortet mit bekannten
  Woertern. Der Ort wirkt lebendiger.
- Der Companion erkennt den aktuellen Inselzustand und schlaegt eine passende
  Weltaktion vor, z. B. Bauplatz, Bibliothek, Bruecke oder Comeback-Nebel.

Leitregel:

Lernen ist nicht nur Voraussetzung. Lernen ist die Handlung, durch die die Welt
sichtbar gebaut wird.

Kernentscheidung:

- Bauplaetze fragen Wortaufgaben ab.
- Bewohner fragen Dialoge ab.
- Bibliotheken geben Satzaufgaben.
- Bruecken geben Phrasenaufgaben.
- Nebelbereiche geben Wiederholungsaufgaben.
- Klassische Lernscreens bleiben als effizienter Modus erhalten, aber die
  emotional staerkste Erfahrung ist Weltaktion.

## 4. Lernarten Und Weltwirkung

Die folgenden Zuordnungen sind eine Designrichtung, keine finale Reward Bridge.

| Lernart | Moegliche Ressource | Moegliche Weltwirkung | Passende Objekte |
| --- | --- | --- | --- |
| Wort erkennen | Stein | Fundament, Sockel, erste Markierung | Haus, Markt, Bruecke |
| Wort aktiv erinnern | Holz | Waende, Konstruktion, Zaun, Steg | Haus, Werkstatt, Garten |
| Schreiben/Tippen | Metall, Wissen | Praezise Bauteile, Schilder, Mechanik | Bibliothek, Turm, Werkstatt |
| Hoeren | Licht/Energie | Klangpunkte, Laternen, lebendige Effekte | Brunnen, Bibliothek, Companion-Ort |
| Aussprache | Licht/Energie | Leuchten, Aktivierung, magische Adern | Kristalle, Lampen, Bruecken |
| Satzverstaendnis | Glas, Wissen | Fenster, Regal, Wegtafel, Aussichtspunkt | Bibliothek, Schule, Markt |
| Phrasen | Metall, Glas | stabile Struktur, Verbindung, Spezialteil | Bruecke, Hafen, Turm |
| Dialoge mit NPC/Companion | Bewohner | Bewegung, Leben, Besuchsreaktionen | Haus, Platz, Markt |
| Satzfunken mit KI | Wissen, Licht | Questobjekt, Satzstein, Kreativ-Deko | Satzfunken-Platz, Bibliothek |
| Wiederholung / SRS | Reparaturpunkte | Nebelrettung, Reparatur, Stabilisierung | private Lernoverlays, alte Wege |

Grundsatz:

- einfache Lernaktionen geben kleine sichtbare Fortschritte,
- kombinierte Lernaktionen geben groessere Bauimpulse,
- SRS/Wiederholung erhaelt oder repariert private Lernbereiche,
- KI-Satzfunken duerfen kreativ wirken, aber nicht die deterministische
  Reward-Logik ersetzen.

## 5. Ressourcen- Und Belohnungssystem

Geplante Ressourcen:

| Ressource | Rolle |
| --- | --- |
| Stein | Fundament, Sockel, stabile Basis |
| Holz | Waende, Konstruktion, Naturbau, Zaun |
| Glas | Fenster, Schilder, Wegelemente, Sichtbarkeit |
| Metall | Spezialteile, Maschinen, stabile Bruecken |
| Licht/Energie | Aktivierung, Glow, Magie, Effekte |
| Bewohner | Leben, Dialog, soziale Lebendigkeit |
| Wissen | Bibliothek, Forschung, Freischaltung |
| Muenzen | flexible Bau-/Deko-Waehrung, nicht Lernersatz |
| Reparaturpunkte | private Nebelrettung, Comeback, Wiederholung |

Balancing-Richtung:

- Lernen darf nicht zu langsam belohnen.
- Aufbau darf nicht zu schnell fertig sein.
- Kurze Sessions muessen sichtbar etwas bringen.
- Lange Sessions duerfen Fortschritt vertiefen, aber nicht alles sprengen.
- Ressourcen sollen Lernarten sichtbar unterscheiden.
- Muenzen duerfen helfen, aber nicht Lernen ersetzen.
- Premium darf schoener, schneller organisiert oder breiter machen, aber nicht
  Pay-to-Win werden.

Quellen von Ressourcen:

- Lernquests,
- Bauquests,
- Tagesziele,
- Comeback-Quests,
- Community-Beitraege,
- vorsichtig dosierte Events,
- spaeter Freundeshilfe in sicheren Grenzen.

Sinks von Ressourcen:

- Fundamente,
- Gebaeudeausbau,
- Wege,
- Connectoren,
- Deko,
- Reparatur/Nebelrettung,
- Community-Projekte,
- Inselerweiterungen.

Balancing-Schutz:

- zu schneller Ausbau wird durch Bauphasen, Ressourcentypen, Tagesziele und
  groessere Zwischenstufen verhindert,
- frustrierend langsamer Ausbau wird durch Mikrofortschritte,
  Zwischenbelohnungen und fruehe Fundamente verhindert,
- weiche Limits sind besser als harte Sperren,
- Tagesziele geben Richtung, duerfen aber nicht zur Pflichtspirale werden.

## 6. Verhaeltnis Lernen Zu Spielen

Talvori ist kein reines Spiel und keine reine Vokabel-App.

Fragen:

- Wie viel Lernen ist noetig, bevor etwas gebaut wird?
- Wie verhindert man, dass Lernen wie Arbeit wirkt?
- Wie verhindert man, dass Nutzer nur spielen und nichts lernen?
- Welche Aktionen sind ohne starke Lernpflicht moeglich?
- Welche Aktionen brauchen Lernleistung?
- Wie wird Frust verhindert?

Leitidee:

Es soll immer kleine spielerische Aktionen geben, aber bedeutender Fortschritt
kommt durch Lernen.

Ohne starke Lernpflicht moeglich:

- Welt ansehen,
- eigene Insel besuchen,
- Bauziele betrachten,
- Companion-Frage stellen,
- Deko planen,
- Freunde besuchen,
- Community-Projekte ansehen,
- naechste Lernquest waehlen.

Mit Lernleistung verbunden:

- Gebaeude bauen,
- Gebaeude ausbauen,
- Bruecken/Connectoren freischalten,
- Nebel privat entfernen,
- Bewohner aktivieren,
- groessere Community-Beitraege leisten,
- besondere Deko freischalten.

Frustschutz:

- kleine Belohnung auch bei kurzer Session,
- klare naechste Aufgabe,
- keine harte oeffentliche Bestrafung,
- private Lernoverlays statt oeffentlicher Ruinen,
- sanfte Comeback-Quest statt Schuldgefuehl,
- Companion erklaert, nicht beschimpft.

## 6a. Lern-/Spiel-Modi

Talvori braucht mehrere Modi, damit immer etwas Spielbares da ist, ohne den
Lernkern zu verwischen.

| Modus | Lernpflicht | Zweck |
| --- | --- | --- |
| Freies Erkunden | nein | Welt ansehen, Inseln besuchen, Motivation aufbauen |
| Bauplanung | nein | Bauplatz, Ziel und Variante waehlen |
| Deko/Organisation klein | nein oder sehr leicht | Besitzgefuehl und Ordnung |
| Lernquest | ja | echter Ressourcen- und Fortschrittsgewinn |
| Bauquest | ja | Fundament, Gebaeude, Weg oder Objekt sichtbar bauen |
| Comeback-Quest | ja, sanft | Nebel lichten, Wiederholung positiv rahmen |
| Community-Quest | ja | Beitrag zu gemeinsamen Projekten |
| Social-/Freundesaufgabe | optional/kontextuell | Freundeshilfe, Reaktion, gemeinsames Ziel |

Regel:

Es soll immer eine kleine spielerische Aktion moeglich sein. Bedeutender
Fortschritt entsteht aber durch Lernen.

## 7. Bau- Und Ausbaugefuehl

Zoom- und Erlebnisstufen:

| Stufe | Rolle |
| --- | --- |
| Weltansicht | Orientierung, Freunde, Community, Inseln |
| Inselansicht | eigene Insel, Bauplaetze, Wege, Ressourcenwirkung |
| Bauplatzansicht | konkretes Bauziel, naechste Lernaufgabe |
| Gebaeudeansicht | Ausbau, Varianten, Leben, Status |
| Innenraum spaeter | Bibliothek, Dialog, Companion-/NPC-Orte |

Innenraeume sind nicht Teil der fruehen Phase, aber architektonisch wichtig:

- Haus-Innenraum: persoenlicher Raum, Deko, Companion-Kommentar,
  Rueckkehrgefuehl.
- Bibliothek-Innenraum: Satzaufgaben, Wissen, Regale, Lesepulte,
  Satzfunken.
- Werkstatt-Innenraum: Materialien, Metall/Holz-Logik, Bauvarianten,
  Reparatur.
- Markt-Innenraum: kleine Tausch-/Organisationslogik, Muenzen, spaeter
  kosmetische Angebote.
- Lernstationen: klar definierte Orte fuer Wort, Satz, Phrase, Hoeren und
  Aussprache.
- NPCs: geben kontextuelle Dialoge und lassen Gebaeude lebendig wirken.

Baugefuehl:

- leerer Bauplatz,
- gerodet/geebnet,
- Fundament,
- Waende,
- Dach,
- Fenster/Schild/Weg,
- Deko,
- Licht,
- Bewohner/Leben.

Nach einer Aufgabe sollte eine kurze sichtbare Belohnung passieren:

- Stein legt sich ins Fundament,
- Licht wandert in ein Fenster,
- Holzteil erscheint,
- Weg wird ein Stueck klarer,
- Bewohner winkt,
- Companion kommentiert knapp.

## 8. Lebendigkeit Und Animation

Die Welt darf nicht statisch wirken, auch wenn gerade nicht gebaut wird.

Kategorien:

| Kategorie | Beispiele |
| --- | --- |
| Ambient | Wasser, Rauch, Licht, Wind, Partikel |
| Bauanimation | Fundament erscheint, Wand waechst, Licht aktiviert |
| Lernbelohnung | Ressource fliegt zum Bauplatz, Bauplatz leuchtet kurz |
| Social | Besucher, Reaktion, Freundesmarker |
| Comeback | Nebel lichtet sich, Reparaturpunkt stabilisiert Bereich |
| Idle | kleine Bewohner, Tiere, Laternen, Baeume |

Regeln:

- Animationen bleiben ruhig und hochwertig.
- Keine hektische Effektflut.
- Animationen duerfen UI und Lesbarkeit nicht stoeren.
- Performance wird frueh beruecksichtigt.
- Preview-LOD zeigt weniger Animation als Detail-LOD.
- Detail-LOD darf lebendiger sein, aber nicht zur Performance-Falle werden.

## 9. Retention Und Comeback

Talvori kann von erfolgreichen Mobile-Games lernen, soll aber keine aggressive
Bestrafungslogik uebernehmen.

Moegliche Retention-Systeme:

- Daily Rewards,
- Tagesquests,
- sanfte Bauzeiten oder Wartezeiten,
- Events,
- saisonale Ziele,
- Comeback-Quest,
- sanfte Erinnerungen,
- Community-Ziele.

Talvori-spezifische Regeln:

- Oeffentliche Welt bleibt schoen.
- Private Lernoverlays zeigen, was zu tun ist.
- Comeback soll motivieren, nicht beschuldigen.
- Streaks duerfen helfen, aber nicht zum Hauptdruckmittel werden.
- Tagesziele sollen klein genug fuer echte Alltagssessions bleiben.

## 10. Social Und Community

Social startet klein und sicher.

Moegliche Funktionen:

- Freunde besuchen,
- Freundesinseln ansehen,
- Reaktionen senden,
- gemeinsam an Community-Gebaeuden bauen,
- Gruppenlernaufgaben,
- Gruppenlernquest fuer ein gemeinsames Ziel,
- Community-Bruecke gemeinsam aufbauen,
- Freund hilft bei Comeback/Reparatur als sichere kleine Unterstuetzung,
- 1-gegen-1-Vokabelduell optional spaeter,
- kleine Wettbewerbe,
- Kooperationsziele,
- sichere Kommunikation.

Nicht am Anfang:

- kein globaler offener Chat,
- keine unmoderierten Grossgruppen,
- keine fremden Eingriffe in private Inseln,
- keine Social-Mechanik, die Lernen ersetzt.

Sicherheitsregeln:

- Kommunikation zuerst ueber Reaktionen, Sticker, vordefinierte Hilfen oder
  sichere kleine Nachrichten.
- Freundesbesuche zeigen oeffentliche Inselzustande, nicht private
  Lernprobleme.
- Private Lernoverlays bleiben privat.

## 11. Gemeinsames Bauen

Community-Projekte geben Social einen sichtbaren Zweck.

Konkrete Ideen:

| Projekt | Rolle |
| --- | --- |
| Stadion | Events, Wettbewerbe, Community-Ziele |
| Fernsehturm / Aussichtsturm | Weltuebersicht, Landmarke, Fortschritt |
| Hafen | Verbindungen, Reisen, Brueckenlogik |
| Bahnhof | spaetere Regionen, Navigation, Events |
| Leuchtturm | Orientierung, Comeback, Licht/Energie |
| Wald | Naturprojekt, Pflege, gemeinsames Wachstum |
| Universitaet | Wissen, Satzfunken, Lernquests |
| Community-Bruecke | Verbindung zwischen Regionen |

Zu klaeren:

- Welche Lernaktionen zahlen auf Community-Projekte ein?
- Was sieht jeder Nutzer?
- Was ist privat?
- Was ist oeffentlich?
- Wie verhindert man Chaos?

Leitregel:

Community-Projekte sind kuratierte BuildZones mit gemeinsamen Fortschrittsdaten,
nicht frei editierbare Multiplayer-Bauplaetze.

## 12. Monetarisierung Und Kostenabdeckung

Talvori muss laufende Kosten decken:

- KI,
- DeepL oder andere Uebersetzungsdienste,
- Cloud/Supabase,
- Storage/CDN,
- Push,
- Moderation,
- Support,
- App-Store-Kosten.

Moegliche Einnahmequellen:

- Talvori Welt Plus,
- mehr eigene Inseln,
- groessere Inseln,
- kosmetische Insel-, Gebaeude- und Theme-Packs,
- saisonale Deko,
- Founder Pass,
- KI-Kontingente,
- erweiterter Import,
- Aussprachetraining,
- Classroom/B2B spaeter.

Fairness-Regeln:

- Kein Pay-to-Win.
- Keine Lootboxen.
- Keine harte Lernbestrafung.
- Erster Wow-Moment kostenlos.
- Premium erweitert, verschoenert und vertieft.
- Lernen bleibt der wichtigste Weg zu bedeutendem Fortschritt.
- Premium darf Zeit organisieren oder kosmetische Vielfalt geben, aber nicht
  Lernleistung kaufen.

Kostenkontrolle:

- KI-Aktionen brauchen Kontingente, Caching und klare Rate Limits.
- DeepL/Uebersetzungsdienste brauchen Import-Limits, Batch-Strategien und
  spaetere Plus-/Classroom-Abgrenzung.
- Cloud/Supabase braucht klare authoritative Daten und sparsame Writes.
- Storage/CDN muss Asset-Auslieferung vom Nutzerfortschritt trennen.
- Push muss vorsichtig eingesetzt werden und darf kein Drucksystem werden.
- Moderation und Support sind vor groesserem Social-Ausbau einzuplanen.

Premium-Grenze:

Premium darf Talvori erweitern, verschoenern und Betriebskosten decken. Premium
darf Lernen nicht ersetzen und keinen unfairen Lern- oder Social-Vorteil
verkaufen.

## 13. UI/Screen-Informationsarchitektur

Wichtige Informationen im Welt-Screen:

- Ressourcen,
- Tagesziel,
- Bauziel,
- Companion-Hinweis,
- Meine Insel,
- Freunde,
- Weltkarte/Uebersicht,
- Bau-Modus,
- Lernquest,
- Community-Projekt,
- Event,
- Profil/Settings.

Regel:

Nicht alles dauerhaft anzeigen.

Informationsarten:

- Dauerhaft: Titel, knappe Ressourcen, Meine Insel/Freunde oder Ruecknavigation.
- Kontextuell: Bauziel, Lernquest, Community-Projekt, Event.
- Beim Tap: Details, Kosten, naechste Aufgabe, Belohnung, Social-Aktion.
- Companion: kurze Hinweise, keine dauerhaft ueberladene Anleitung.

Ziel:

Die Welt bleibt der Star. UI fuehrt, aber erdrueckt nicht.

## 14. Cloud Und Lokal

Zu klaeren:

| Bereich | Lokal | Cloud / authoritative |
| --- | --- | --- |
| aktuelle Kamera/Zoom | ja | nein |
| lokale Preview-Daten | ja | Cache aus Cloud |
| eigene Insel-Details | ja, Cache | spaeter authoritative |
| Lernfortschritt | bestehende Logik schuetzen | spaeter syncfaehig |
| Ressourcen-Wallet | lokal/mock in fruehen Phasen | spaeter authoritative |
| Community-Projekte | Preview lokal | Cloud authoritative |
| Freundesinseln | Cache | Cloud authoritative |
| KI/DeepL Nutzung | Anfrage lokal ausgeloest | Limits/Abrechnung Cloud |

Offline-Regeln:

- Offline kann lokal geuebt und vorgemerkt werden, soweit die Aktion sicher,
  deterministisch und konfliktarm ist.
- Unsichere Aktionen, Premium, Community-Projekte und Social brauchen spaeter
  Cloud-Bestaetigung.
- Weltveraenderungen mit Konfliktpotenzial werden spaeter synchronisiert.
- Community-Beitraege brauchen spaeter Cloud-Bestaetigung.
- Keine Supabase Writes ohne explizite Freigabe in aktuellen Phasen.

Synchronisation:

- eigene Inseln: spaeter bei Login/Start und nach Aenderungen,
- Freunde: Preview zuerst, Detail beim Besuch,
- Community-Projekte: periodisch oder eventgetrieben,
- KI/DeepL: rate-limited und kostenkontrolliert.

Konfliktloesung spaeter:

- Cloud ist authoritative fuer Besitz, Ressourcen, Community-Projekte, Freunde
  und Premium.
- Lokal bleibt verantwortlich fuer Kamera, Cache, Assets und schnelle UI.
- Offline-Vormerkungen brauchen spaeter idempotente Operationen und klare
  Konfliktregeln.
- Preview-Daten duerfen veraltet sein, Detaildaten muessen beim Besuch
  aktualisiert werden.

## 15. Skalierung Und Betrieb

Skalierung fuer grosse Weltkarten:

- sichtbarer Viewport,
- geladene Inseln,
- Detaildaten erst beim Besuch,
- Preview-Daten fuer Uebersicht,
- Asset-CDN,
- Supabase/Postgres oder spaetere Alternativen,
- Edge Functions / Jobs,
- Moderation,
- Rate Limits fuer KI/DeepL.

Betriebsregeln:

- Nicht alle Inseln live laden.
- Nicht alle Details im Weltueberblick rendern.
- Community-Projekte bekommen aggregierte Fortschrittsdaten.
- Freundesinseln werden als Preview geladen, Details beim Besuch.
- KI- und Uebersetzungsfunktionen brauchen harte Kostenkontrolle.
- Moderation muss vor globaler Social-Oeffnung geplant sein.
- CDN/Storage muss grosse Weltassets effizient ausliefern.
- Rate Limits fuer KI/DeepL gehoeren zum Produktdesign, nicht nur zum
  Backend-Schutz.

## 16. Balancing-Startwerte Als Diskussionsbasis

Keine finalen Zahlen, aber erste Richtung:

| Aktivitaet | Wirkung |
| --- | --- |
| kurze Aufgabe | kleine Ressource |
| 3-5 Woerter | sichtbarer Mikrofortschritt |
| 10-15 Minuten Lernen | spuerbares Bauziel |
| Tagesquest | sichtbarer Ausbau |
| grosses Gebaeude | mehrtaegiges Ziel |
| Community-Projekt | Wochen-/Saisonziel |

Balancing-Leitlinien:

- Nutzer sollen nach wenigen Minuten etwas sehen.
- Ein ganzes Gebaeude darf nicht nach einer Mini-Session fertig sein.
- Grosse Ziele brauchen Zwischenstufen.
- Lange Sessions sollen Fortschritt vertiefen, aber nicht alles entwerten.
- Wiederholung/SRS soll sich nuetzlich anfuehlen, nicht wie Strafarbeit.
- 1 kurze Aufgabe erzeugt Mikrofortschritt.
- 3-5 Woerter erzeugen sichtbaren kleinen Baufortschritt.
- 10-15 Minuten Lernen erzeugen ein spuerbares Ziel.
- Ein erstes Fundament soll sehr frueh erreichbar sein.
- Ein kleines Gebaeude braucht mehrere kurze Sessions.
- Grosse Gebaeude brauchen Tage.
- Community-Projekte brauchen Wochen oder Saisons.

Balancing-Raster:

- Quellen und Sinks muessen zusammen geplant werden.
- Zwischenbelohnungen verhindern Frust.
- Weiche Limits verhindern Durchrennen ohne harte Sperren.
- Tagesziele geben Orientierung, duerfen aber nicht alles kontrollieren.

## 16a. Analytics/KPIs Als Spaeterer Pruefrahmen

Keine Tracking-Implementierung in diesem Dokument. Spaeter braucht Talvori aber
einen Pruefrahmen, um zu sehen, ob Lern- und Spielsystem wirklich greifen.

Moegliche KPIs:

- D1/D7 Retention,
- erste Lernaufgabe abgeschlossen,
- erste Insel gewaehlt,
- erstes Fundament gebaut,
- erste Rueckkehr nach einem Tag,
- Kosten pro aktivem Nutzer,
- KI-/DeepL-Nutzung pro aktivem Nutzer,
- Conversion zu Talvori Welt Plus,
- Abbruchstellen im Onboarding,
- Anteil der Nutzer, die In-World-Learning statt nur klassischen Lernscreen
  nutzen.

Regel:

KPIs duerfen helfen, Friktion und Kosten zu verstehen. Sie duerfen Talvori nicht
in aggressive Manipulationslogik druecken.

## 17. Vergleichs- Und Recherchebedarf

Folgende Systeme sollten gezielt recherchiert werden:

| Spiel/System | Recherchefokus |
| --- | --- |
| Clash of Clans | Langzeitprogression, Builder, Clans, Events |
| Hay Day | Produktions-/Warenketten, ruhiger Aufbau, Social Help |
| Township | Stadtaufbau, Events, Produktion |
| Animal Crossing | Besitzgefuehl, Tagesroutine, Deko |
| Duolingo | Lernstreak, kurze Sessions, Wiederkehr |
| Merge-/Builder-Games | kurze Belohnungsschleifen |
| Idle-/Cozy-Games | Rueckkehr ohne Druck |

Fragestellung:

- Welche Mechaniken erzeugen Wiederkehr ohne Aggression?
- Welche Progressionssysteme bleiben auch nach Monaten lesbar?
- Wie wird Social Help sicher und nicht ausnutzbar?
- Wie bleiben Kosten durch KI/Cloud kontrollierbar?
- Wie kann Talvori Lernen sichtbar machen, ohne Lernqualitaet zu opfern?

## 18. Empfohlene Folge-Dokumente

Priorisierte Detaildokumente:

- `docs/world_design/223-learning-to-building-loop.md`
- `docs/world_design/224-economy-balancing.md`
- `docs/world_design/225-in-world-learning-ui.md`
- `docs/world_design/226-monetization-and-cost-coverage.md`
- `docs/world_design/227-cloud-local-architecture.md`
- `docs/world_design/228-retention-liveops-comeback.md`
- `docs/world_design/229-social-community-systems.md`
- `docs/world_design/230-animation-and-liveliness.md`

Diese Dokumente sollen Detailentscheidungen vorbereiten, bevor groessere
Implementierungsbloecke starten.

## 19. Scope-Grenzen

Nicht Teil dieses Dokuments:

- keine Implementierung,
- keine echten Zahlen verbindlich machen,
- keine Supabase Writes,
- keine Reward Bridge,
- keine Monetarisierung bauen,
- kein Social-Backend bauen,
- keine Cloud-Persistenz bauen,
- keine SRS-/`word_progress`-Aenderungen,
- keine Assets erzeugen oder aendern.

Dieses Dokument plant das Gesamtsystem. Es nimmt keine Umsetzung vorweg.

## 20. Akzeptanzkriterien

Das Dokument ist gut, wenn:

- klar ist, wie Lernen und Bauen zusammenhaengen,
- klar ist, warum Nutzer zurueckkommen,
- klar ist, wie Kosten spaeter gedeckt werden koennen,
- klar ist, was lokal und was cloudbasiert gedacht werden muss,
- klar ist, welche weiteren Detail-Dokumente noetig sind,
- Lernen, Bauen, Ressourcen, Social, Monetarisierung, Cloud und Retention als
  gemeinsames System gedacht sind,
- keine Umsetzung vorweggenommen wird.
