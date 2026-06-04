# Talvori Welt: Economy Und Balancing

Stand: 2026-06-04

Dieses Dokument beschreibt ein erstes belastbares Diskussionsmodell fuer
Ressourcen, Belohnungen, Baukosten und Fortschrittsgeschwindigkeit in Talvori
Welt. Es ist konkreter als der Masterplan, legt aber keine finalen Zahlen fest.

Es ist ein reines Planungsdokument. Es wurden keine Dart-/Flutter-Dateien,
keine Assets, keine Supabase-Daten, keine SQLite-/Vokabeldaten, keine SRS-Daten,
kein `word_progress`, keine Reward Bridge, keine Persistenz, keine Secrets und
keine Release-Artefakte geaendert.

Grundlagen:

- `docs/world_design/000-world-design-document-map.md`
- `docs/world_design/223-learning-to-building-loop.md`
- `docs/222-talvori-world-game-system-master-plan.md`
- `docs/221-talvori-world-build-and-expansion-architecture.md`

## 1. Ziel Des Economy-/Balancing-Dokuments

Talvori braucht ein Ressourcenmodell, weil Weltaufbau nicht beliebig aus
Lernaktionen entstehen darf. Wenn jede Aufgabe einfach irgendeinen Fortschritt
ausloest, wird das System spaeter schwer testbar, schwer balancierbar und
anfällig fuer Ausnutzung.

Das Ressourcenmodell muss klaeren:

- welche Lernhandlung welche Ressource erzeugen kann,
- welche Bauziele welche Ressourcen verbrauchen,
- wie schnell erste sichtbare Fortschritte entstehen,
- wie lange groessere Ziele dauern duerfen,
- wie Comeback, Social, Premium und Kostenkontrolle eingebettet werden.

Lernen darf nicht zu langsam belohnen:

- sonst wirkt es wie Arbeit,
- kurze Sessions fuehlen sich nutzlos an,
- Nutzer verstehen den Weltzusammenhang nicht.

Lernen darf aber auch nicht zu schnell belohnen:

- sonst sind Gebaeude zu schnell fertig,
- Ressourcen verlieren Bedeutung,
- Community-Projekte werden trivial,
- Premium- und Kostenmodelle werden verzerrt.

Ressourcen, Baukosten, Sessionlaenge, Monetarisierung und Kostenkontrolle
muessen zusammen gedacht werden. Besonders KI, DeepL, Cloud, Storage und Social
koennen spaeter echte Betriebskosten erzeugen. Economy ist deshalb nicht nur
Game Design, sondern auch Produktsicherheit.

## 2. Grundprinzipien

Talvori-Economy folgt diesen Grundsaetzen:

- Lernen bleibt Hauptquelle fuer bedeutenden Fortschritt.
- Kleine Spielaktionen duerfen ohne Lernen moeglich sein.
- Premium darf verschoenern, erweitern und Komfort geben, aber Lernen nicht
  ersetzen.
- Ressourcen muessen verstaendlich bleiben.
- Die Fruehphase darf nicht zu viele Ressourcen gleichzeitig zeigen.
- Grosse Ziele brauchen Zwischenstufen.
- Jede wichtige Ressource braucht erkennbare Quellen und Senken.
- Weltfortschritt muss deterministisch, kontrollierbar und testbar bleiben.
- Bestehende SRS-/`word_progress`-Semantik bleibt unangetastet.

Fruehe UI-Regel:

In der ersten Session sollten nicht alle spaeteren Ressourcen sichtbar sein.
Der Nutzer muss zuerst verstehen:

> Aufgabe loesen -> Ressource erhalten -> Bauplatz veraendert sich.

## 2a. Ressource, Bauimpuls Und Weltveraenderung

Nicht jede richtige Antwort muss sofort eine sichtbare Ressource erzeugen.
Talvori muss drei Ebenen getrennt denken:

| Ebene | Bedeutung |
| --- | --- |
| Lernfortschritt | Antwort ist richtig, Aufgabe wurde sinnvoll geloest |
| Ressource / Bauimpuls | kontrollierter Fortschrittswert fuer ein Bauziel |
| Sichtbare Weltveraenderung | BuildZone, Gebaeude oder Objekt wechselt Zustand |

Beispiel:

1. Antwort richtig -> Lernfortschritt.
2. Mehrere richtige Antworten -> Bauimpuls.
3. Bauimpuls erfuellt Kosten -> Bauzustand aendert sich sichtbar.

Das verhindert, dass jede Einzelantwort die Welt hektisch veraendert. Gleichzeitig
bleibt der Zusammenhang klar:

> Lernen zaehlt sofort, Weltveraenderung passiert in lesbaren Schritten.

Fuer fruehe Slices darf ein Bauimpuls lokal/mock direkt aus einer kleinen
Aufgabengruppe entstehen. Spaeter muss die Reward Bridge diese Umrechnung
deterministisch und testbar uebernehmen.

## 3. Ressourcenphasen

### Phase A / Frueher Loop

Ressourcen:

- Stein,
- Holz,
- Wissen.

Rolle:

- Stein und Holz erklaeren Fundament und erste Struktur.
- Wissen erklaert Bibliothek, Satzverstehen und naechste Bauziele.
- Diese Ressourcen sind leicht genug, um den ersten Loop zu verstehen.

Sichtbarkeit:

- Phase A kann frueh sichtbar sein.
- UI sollte trotzdem kompakt bleiben.
- Eine erste Aufgabe kann nur Stein zeigen, bevor weitere Ressourcen auftauchen.

### Phase B / Ausbau

Ressourcen:

- Glas,
- Metall,
- Licht/Energie.

Rolle:

- Glas steht fuer Satzverstaendnis, Fenster, Schilder und Sichtbarkeit.
- Metall steht fuer Phrasen, Spezialteile, Bruecken und stabile Strukturen.
- Licht/Energie steht fuer Hoeren, Aussprache und Aktivierung.

Sichtbarkeit:

- Phase B erscheint, wenn erste Bauphasen verstanden sind.
- Diese Ressourcen duerfen mehr Spezialisierung tragen.
- Sie sollten nicht den ersten Wow-Moment verkomplizieren.

### Phase C / Lebendigkeit Und Comeback

Ressourcen:

- Bewohner,
- Reparaturpunkte,
- Muenzen.

Rolle:

- Bewohner zeigen Leben und Dialogfortschritt.
- Reparaturpunkte machen Wiederholung und Comeback positiv.
- Muenzen sind flexible Deko- oder Komfortwaehrung, aber kein Lernersatz.

Sichtbarkeit:

- Phase C sollte erst eingefuehrt werden, wenn Nutzer Besitz und Baufortschritt
  verstanden haben.
- Reparaturpunkte brauchen einen sensiblen Comeback-Kontext.
- Muenzen duerfen nicht wie die Hauptressource wirken.

Warum nicht alles sofort:

- Zu viele Ressourcen ueberfordern neue Nutzer.
- Frueher Fokus muss auf Weltwirkung liegen, nicht auf Inventarverwaltung.
- Spaetere Ressourcen fuehlen sich wertvoller an, wenn sie neue Bau- und
  Lernarten oeffnen.

## 3a. Ressourcen-Sichtbarkeit In Der UI

Die UI soll Ressourcen gestaffelt einfuehren:

1. Erste Session: maximal Stein sichtbar.
2. Danach: Holz, sobald Struktur, Wand oder Rohbau erklaert wird.
3. Wissen: sobald Bibliothek, Satzaufgabe oder Bauziel-Hinweis relevant wird.
4. Glas, Metall und Licht/Energie: erst bei passenden Ausbau- oder
   Spezialaktionen.
5. Bewohner: erst bei Dialogen, NPCs oder lebendigen Gebaeudezustaenden.
6. Reparaturpunkte: erst bei Comeback, SRS oder privatem Nebel.
7. Muenzen: erst bei Deko, Markt oder Komfortaktionen.

Regel:

Die UI darf nicht alle Ressourcen dauerhaft zeigen. Im Welt-Screen sollten nur
die fuer den aktuellen Kontext wichtigen Werte sichtbar sein. Details koennen
beim Tippen, in einer Baukarte oder in einer spaeteren Wallet-Ansicht erscheinen.

## 4. Ressourcen Und Lernarten

| Ressource | Lernaktion | Weltwirkung | Fruehe Verwendung | Spaetere Verwendung | Balancing-Risiko |
| --- | --- | --- | --- | --- | --- |
| Stein | Wort erkennen | Fundament, Sockel, erste Stabilitaet | erstes Fundament, Bauplatz vorbereiten | Brueckenanker, Mauern, Community-Fundamente | zu leicht farmbar, wenn Erkennen unbegrenzt belohnt |
| Holz | Wort aktiv erinnern | Waende, Konstruktion, Zaun, Steg | Hauswaende, kleiner Zaun | Werkstatt, Garten, Brueckenstege | aktive Erinnerung darf nicht frustrieren |
| Wissen | Satzverstaendnis, Tippen | Bibliothek, Forschung, Freischaltung | erstes Bibliothekslicht, Bauzielhinweis | Forschung, Satzfunken, neue Varianten | zu abstrakt, wenn Weltwirkung fehlt |
| Glas | Satzverstaendnis | Fenster, Schilder, Sichtbarkeit | einfache Fenster, Wegtafeln | Bibliothek, Turm, Marktanzeigen | kann mit Wissen verschwimmen |
| Metall | Phrasen | Bruecken, Spezialteile, stabile Mechanik | kleines Brueckenteil, Werkzeug | Hafen, Turm, Maschinen, Community-Projekte | Phrasen koennen zu spaet oder zu teuer wirken |
| Licht/Energie | Hoeren, Aussprache | Aktivierung, Glow, Effekte | Laterne, Kristall, Fensterlicht | magische Anlagen, Companion-Orte, Events | Audio muss optional und robust bleiben |
| Bewohner | Dialoge | Lebendigkeit, NPCs, Besuchsreaktionen | erster Bewohner am Haus/Markt | Dorfleben, Social-Orte, Community-Platz | KI/Dialog darf keine freien Rewards drucken |
| Reparaturpunkte | SRS/Wiederholung | Nebelrettung, Stabilisierung | privater Nebel lichtet sich | Comeback, alte Wege, Reparaturzustand | darf nicht wie Strafe fuer Pause wirken |
| Muenzen | flexible kleine Aktionen, Tagesziel, Markt | Deko, Komfort, kleine Organisation | kleine Deko, Schild, Marktobjekt | kosmetische Auswahl, Events, Komfort | Pay-to-Win-Gefahr, wenn Fortschritt kaufbar wird |

Regel:

Jede Ressource braucht eine klare emotionale Bedeutung. Wenn zwei Ressourcen
sich gleich anfuehlen, muss eine davon spaeter zusammengelegt oder staerker
umdefiniert werden.

## 4a. Schwierigkeit Und Reward-Gewichtung

Das folgende Gewichtungsmodell ist nicht final. Es dient nur dazu, spaeter
Tests und erste Mock-Slices einheitlicher zu bewerten.

| Lernart | Gewichtungsrichtung | Hinweis |
| --- | --- | --- |
| Erkennen | Basiswert | leichtester Einstieg, gut fuer Stein |
| Aktiv erinnern | hoeher als Erkennen | aktive Abrufleistung, gut fuer Holz |
| Tippen/Schreiben | hoeher, aber vorsichtig | Tippfehlerfrust vermeiden, nicht zu streng |
| Satzverstaendnis | hoeherer Wert | Wissen/Glas, Niveau muss passen |
| Phrase | hoeherer Wert | Metall/Verbindung, eher spaeter einfuehren |
| Dialog | kontrolliert | Bewohner/Leben, keine freien KI-Rewards |
| Wiederholung/SRS | Reparatur/Stabilitaet | nicht unbegrenzt neue Rohstoffe erzeugen |

Leitregel:

Schwierigere Aufgaben duerfen mehr bewirken, aber der Unterschied darf nicht so
gross werden, dass Nutzer leichte Aufgaben als wertlos oder schwere Aufgaben als
Pflicht empfinden.

## 5. Erste Balancing-Werte Als Diskussionsmodell

Die folgenden Werte sind nicht final. Sie sind ein Diskussionsmodell fuer
spaetere Tests.

| Aktion / Umfang | Beispielwert | Bedeutung |
| --- | --- | --- |
| 1 einfache Aufgabe | 1-2 Basispunkte | kleiner Mikrofortschritt |
| 3-5 Woerter | sichtbarer kleiner Fortschritt | Bauplatz reagiert sichtbar |
| erstes Fundament | nach 3-6 kurzen Aufgaben erreichbar | frueher Aha-Moment |
| erstes kleines Gebaeude | mehrere kurze Sessions | erster echter Besitzfortschritt |
| grosses Gebaeude | mehrere Tage | langfristiges Ziel |
| Community-Projekt | Woche/Saison | Gruppenfortschritt, nicht sofort fertig |

Interpretation:

- `Basispunkt` ist kein finaler Name und keine UI-Ressource.
- Es beschreibt nur die kleinste interne Diskussionsgroesse.
- Spaeter kann eine Reward Bridge daraus echte Ressourcen ableiten.
- In fruehen Mock-Slices darf diese Logik lokal simuliert werden.

Leitwerte:

- Nach 1 Aufgabe soll etwas reagieren.
- Nach 3-5 Woertern soll etwas sichtbar anders aussehen.
- Nach 10-15 Minuten soll ein spuerbares Bauziel erreicht oder fast erreicht
  sein.
- Nach einem Tagesziel soll ein klarer Ausbauabschnitt sichtbar sein.

### Test-Balancing-Modell A

Dieses Modell ist ausdruecklich nicht final. Es ist nur ein erstes
Testmodell, um lokale Mock-Slices und Diskussionen vergleichbarer zu machen.

| Ereignis / Bauziel | Testwert |
| --- | --- |
| 1 richtig erkannte Vokabel | 1 Stein |
| 1 aktiv erinnerte Vokabel | 1 Holz |
| 1 verstandener Satz | 1 Wissen |
| 3 richtige Antworten | 1 kleiner Bauimpuls |
| Fundament Stufe 1 | z. B. 5 Stein |
| Haus Rohbau | z. B. 5 Stein + 4 Holz |
| erstes Bibliothekslicht | z. B. 3 Wissen |
| erste Deko | kleine Muenzen-/Holz-/Lichtkosten |

Interpretation:

- Diese Werte sind keine finalen Regeln.
- Sie duerfen nicht ungeprueft in eine echte Reward Bridge uebernommen werden.
- Sie sollen nur helfen, fruehe UI- und Bauzustands-Slices nachvollziehbar zu
  testen.
- Wenn sich das erste Fundament zu langsam oder zu schnell anfuehlt, muss das
  Modell angepasst werden.

## 5a. Erste Bauziel-Reihenfolge

Das fruehe Balancing soll zuerst fuer diese Abfolge funktionieren:

1. Insel waehlen.
2. Bauplatz vorbereiten.
3. Fundament beginnen.
4. Fundament fertigstellen.
5. Einfache Huette / Haus-Rohbau.
6. Erster Weg oder Lichtpunkt.
7. Bibliotheks-/Wissenspunkt.
8. Spaeter Markt, Bruecke oder Deko.

Warum:

- Diese Reihenfolge erklaert Besitz, Bauplatz, Ressource und Weltwirkung in
  kleinen Schritten.
- Sie vermeidet, dass Markt, Bruecke, Deko und Spezialressourcen zu frueh
  konkurrieren.
- Sie gibt ein klares Ziel fuer Phase-2E/2F-Tests.

## 6. Baukosten-Raster

Auch diese Werte sind nicht final. Sie beschreiben grobe Kategorien.

| Kategorie | Grober Ressourcenmix | Erwartete Sessionanzahl | Sichtbare Zwischenstufen |
| --- | --- | --- | --- |
| Mikroobjekt | 1 Ressource, meist Stein/Holz/Wissen | 1 kurze Aufgabe | Funke, Markierung, kleines Objekt |
| Fundament | vor allem Stein, optional Wissen | 3-6 kurze Aufgaben | Bauplatz, Markierung, Platten, fertiges Fundament |
| Kleines Gebaeude Stufe 1 | Stein + Holz + wenig Wissen | mehrere kurze Sessions | Fundament, Waende, Dach, Licht |
| Gebaeude Stufe 2 | Holz + Glas + Wissen | mehrere Tage oder viele kurze Sessions | Fenster, Schild, Deko, Funktion |
| Gebaeude Stufe 3 | Wissen + Metall + Licht | mehrtaegiges Ziel | Spezialteil, Animation, Bewohner |
| Dekoobjekt | Muenzen oder kleine Ressource | 1-3 kurze Aktionen | Vorschau, Platzierung, Aktivierung |
| Wegstueck | Stein/Holz, spaeter Glas | kurze bis mittlere Session | Pfadmarkierung, Belag, Laterne |
| Bruecken-/Connector-Vorbereitung | Stein + Metall + Phrase-bezogene Ressource | mittlere bis laengere Session | Dockingpunkt, Anker, Segmentvorschau |
| Community-Beitrag | kleine Menge verschiedener Ressourcen | beliebig kleine Beitraege, aggregiert | Beitragspartikel, Fortschrittsbalken, Bauphase |

Regel:

Jedes groessere Objekt braucht mehrere sichtbare Zwischenstufen, damit Nutzer
nicht nur auf einen spaeteren Fertig-Zustand warten.

## 7. Quellen Und Senken

Quellen:

| Quelle | Geeignete Ressourcen | Rolle |
| --- | --- | --- |
| Lernquest | Stein, Holz, Wissen, Glas, Metall, Licht | Hauptquelle fuer persoenlichen Fortschritt |
| Tagesziel | kleine Auswahl, oft Phase-A-Ressourcen | Richtung und Zusatzmotivation |
| Wiederholung | Reparaturpunkte, wenig Stein/Wissen | Stabilisierung und Comeback |
| Satzfunken | Wissen, Licht | kreative Satz- und Bibliothekswirkung |
| Dialog | Bewohner, Licht, Wissen | Lebendigkeit und Anwendung |
| Community-Aufgabe | kleiner Beitrag verschiedener Ressourcen | Gruppenprojekt |
| Comeback-Quest | Reparaturpunkte, Phase-A-Ressourcen | sanfter Wiedereinstieg |

Senken:

| Senke | Geeignete Ressourcen | Risiko |
| --- | --- | --- |
| Bau | Stein, Holz, Wissen | zu teuer blockiert ersten Loop |
| Ausbau | Holz, Glas, Metall, Licht | zu schnell entwertet Stufen |
| Deko | Muenzen, Holz, Licht | darf Lernen nicht ersetzen |
| Wege | Stein, Holz, Glas | kann langweilig wirken, wenn nur kosmetisch |
| Bruecken | Stein, Metall, Licht | ohne Dockingpunkte wirkt falsch |
| Reparatur | Reparaturpunkte | darf nicht strafend wirken |
| Community-Projekte | alle kontrolliert | darf nicht unerreichbar oder von Einzelnen dominiert sein |
| Inselerweiterung | seltene Mischung, spaeter | kann Pay-to-Win-Gefahr erzeugen |

Grundsatz:

- Jede Ressource braucht Quellen und Senken.
- Keine Ressource darf wertlos werden.
- Keine Senke darf frustrieren.
- Senken muessen mit sichtbaren Zwischenschritten arbeiten.

## 8. Session-Balancing

| Sessiontyp | Erreichbar | Sichtbare Weltwirkung | Darf nicht passieren |
| --- | --- | --- | --- |
| 2-Minuten-Session | 1 kleine Aufgabe, Mikrofortschritt | Funke, Markierung, kleiner Fundamentimpuls | ganzes Gebaeude fertig |
| 5-Minuten-Session | 3-5 Woerter oder kleiner Aufgabenblock | Bauplatz sichtbar vorbereitet, kleiner Abschnitt | zu viele Ressourcen gleichzeitig |
| 10-15-Minuten-Session | spuerbares Ziel | Fundament/Teilwand/Wegabschnitt deutlich fortgeschritten | mehrere grosse Stufen ueberspringen |
| Laengere Session | Fortschritt vertiefen | mehrere Zwischenstufen, Deko oder Tageszielabschluss | komplette Progression entwerten |
| Tagesziel | klarer Abschnitt | sichtbarer Ausbauabschnitt, Companion-Kommentar | Pflichtgefuehl oder Druckspirale |

Session-Regeln:

- Kurze Sessions muessen wertvoll sein.
- Lange Sessions duerfen mehr bringen, aber nicht exponentiell eskalieren.
- Tagesziele geben Orientierung, nicht Zwang.
- Erste Session bevorzugt Phase-A-Ressourcen.
- Spaetere Sessions koennen spezialisierte Ressourcen einblenden.

## 9. Frustschutz

Talvori braucht Frustschutz auf mehreren Ebenen:

- Mikrofortschritt nach kurzer Aktion.
- Zwischenstufen statt langer leerer Wartezeit.
- Klare naechste Aufgabe.
- Keine oeffentliche Bestrafung.
- Private Nebel/Reparatur statt sichtbarer Ruine.
- Comeback-Vereinfachung nach Pause.
- Keine Ressourcenfallen.
- Keine unklaren Ressourcennamen.
- Keine Baukosten, die ohne Hinweis unerreichbar wirken.

Comeback:

- Nach Pause zuerst leichte Aufgaben anbieten.
- Reparaturpunkte positiv rahmen.
- Companion erklaert naechsten kleinen Schritt.
- Keine Meldung, die Schuldgefuehl erzeugt.

## 10. Schutz Vor Ausnutzung

Talvori muss verhindern, dass Ressourcen gedruckt werden koennen.

Regeln:

- Keine unbegrenzten Rewards durch einfache Wiederholung derselben Aufgabe.
- Gleiche Aufgabe direkt wiederholen gibt abnehmenden Ertrag.
- Bereits sehr bekannte Woerter erzeugen eher Stabilitaet oder Reparatur statt
  neue Rohstoffe.
- Keine KI-generierten Aufgaben als freie Ressourcendruckmaschine.
- SRS und `word_progress` werden nicht manipuliert.
- Taegliche weiche Limits begrenzen extreme Ausnutzung.
- Qualitaet der Antwort zaehlt.
- Schwierige Aufgaben duerfen mehr wert sein, aber nicht unfair viel.
- Wiederholte sehr einfache Aufgaben koennen abnehmenden Ertrag haben.
- Community-Beitraege brauchen Missbrauchsschutz.
- Rewards muessen ueber eine kontrollierte lokale oder spaetere Reward-Schicht
  validiert werden.

KI-Regel:

KI darf Aufgaben, Saetze, Erklaerungen und Vorschlaege liefern. Die
Ressourcenvergabe bleibt spaeter deterministisch in einer kontrollierten
Reward-Schicht.

Weiche Limits:

- Limits sollen nicht als harte Sperre wirken.
- Nach hoher Tagesaktivitaet koennen Rewards sanfter abflachen.
- Lernqualitaet und Abwechslung duerfen hoeher gewichtet werden als reine
  Menge.
- Community-Beitraege brauchen eigene Schutzregeln gegen automatisiertes oder
  einseitiges Farmen.

## 11. Monetarisierung Und Balancing

Talvori muss Kosten decken:

- KI,
- DeepL/Uebersetzung,
- Cloud/Supabase,
- Storage/CDN,
- Push,
- Moderation,
- Support.

Monetarisierung darf das Balancing nicht zerstoeren.

Erlaubte Richtungen:

- Premium gibt mehr Komfort.
- Premium gibt mehr eigene Inseln.
- Premium gibt mehr Deko und kosmetische Vielfalt.
- Premium kann groessere oder thematische Inselvarianten ermoeglichen.
- Premium kann KI-Kontingente und erweiterten Import enthalten.
- Aussprachetraining kann spaeter Teil eines Plus- oder Lernpakets sein.
- Founder Pass kann fruehe Unterstuetzung und kosmetische Anerkennung geben.

Grenzen:

- Premium darf nicht einfach Lernressourcen kaufen.
- Kosmetik ist sicherer als Progress-Verkauf.
- KI-Kontingente und Importlimits sind Kostenkontrolle, nicht Pay-to-Win.
- Der erste Wow-Moment bleibt kostenlos.
- Lernen bleibt der wichtigste Weg zu bedeutendem Fortschritt.

Balancing-Gefahr:

Wenn Premium Ressourcen ersetzt, verliert Talvori seinen Kern. Premium darf die
Welt schoener, breiter und komfortabler machen, aber nicht Lernen ueberfluessig
machen.

## 11a. KI-/DeepL-Kosten Im Balancing

Teure Aktionen muessen bewusst platziert werden.

Regeln:

- KI-Satzfunken werden nicht bei jeder kleinen Aufgabe erzeugt.
- KI-Ergebnisse sollen gecacht und wiederverwendet werden, soweit fachlich
  sinnvoll.
- DeepL-/Uebersetzungsanfragen sollen gebuendelt werden.
- Kostenlose Limits muessen frueh mitgedacht werden.
- Plus-Kontingente dienen der Kostenabdeckung, nicht als Lernersatz.
- Teure Aktionen brauchen klare Nutzerwirkung, z. B. Satzfunken, Import,
  Aussprache oder Companion-Kontext.
- Standard-Bauimpulse duerfen nicht von teuren KI-Calls abhaengen.

Balancing-Konsequenz:

Die Economy darf keine Schleife erzeugen, in der normale kleine Baufortschritte
staendig KI- oder DeepL-Kosten ausloesen. KI und Uebersetzung sind hochwertige
Kontextfunktionen, nicht die Basis jeder Ressourcenauszahlung.

## 12. Community-Balancing

Community-Projekte funktionieren anders als private Gebaeude.

Regeln:

- Community-Projekte brauchen viele kleine Beitraege.
- Einzelne Nutzer duerfen nicht alles dominieren.
- Beitraege sollen sichtbar, aber fair aggregiert sein.
- Wochen-/Saisonziel statt sofort fertig.
- Solo- und Gruppenbeitraege muessen beide sinnvoll sein.
- Neue Nutzer sollen kleine sinnvolle Beitraege leisten koennen.
- Power-Nutzer duerfen helfen, aber nicht alles allein entscheiden.

Moegliche Schutzmechaniken:

- Tages-/Wochenbeitragsfenster.
- Beitrag nach Lernart oder Projektphase gewichten.
- Oeffentliche Anerkennung ohne Pay-to-Win.
- Community-Projekt in Bauphasen aufteilen.
- Private Lernprobleme nicht oeffentlich zeigen.

## 13. Balancing-Risiken

Risiken:

- zu schnelle Progression,
- zu langsame Progression,
- zu viele Ressourcen,
- unklare Ressourcennamen,
- Pay-to-Win-Gefahr,
- KI-Kostenexplosion,
- Spieler spielt nur Deko, lernt aber nicht,
- Spieler lernt, sieht aber keinen Fortschritt,
- Community-Projekte wirken unerreichbar,
- Tagesziele erzeugen Druck,
- Wiederholung/SRS fuehlt sich wie Strafe an,
- Muenzen verdraengen Lernressourcen,
- Ressourcenmodell wird zu komplex fuer die UI.

Fruehe Warnsignale:

- Nutzer koennen nicht erklaeren, wofuer eine Ressource gut ist.
- Nutzer sammeln Ressourcen, ohne Baufortschritt zu sehen.
- Nutzer bauen, ohne zu lernen.
- Erste Session zeigt zu viele Zahlen.
- Community-Projekt wirkt entweder sofort fertig oder voellig unerreichbar.

## 14. Erste Empfehlung Fuer Phase 2E/2F

Fuer den ersten technischen Slice nur:

- sichtbar Stein,
- Holz und Wissen nur als architektonische Vorbereitung, nicht UI-dominant,
- eine `main_build_area`,
- ein Fundament,
- eine lokale Mock-Aufgabe,
- lokale Mock-Kosten,
- kein echtes Wallet,
- keine Persistenz,
- keine Reward Bridge.

Empfohlener Mini-Slice:

1. `main_build_area` zeigt `Fundament beginnen`.
2. Lokale Mock-Aufgabe erzeugt `Stein`.
3. Mock-Kosten pruefen, ob das Fundament einen Fortschrittsschritt bekommt.
4. Sichtbarer Zustand wechselt von `empty` zu `foundation_started`.
5. Kein SRS, kein `word_progress`, kein Supabase, keine Cloud.

Warum so klein:

- Der erste Slice prueft nur den Zusammenhang Aufgabe -> Ressource ->
  Bauzustand.
- Er soll keine Economy als Vollsystem bauen.
- Er soll keine Reward Bridge vorwegnehmen.

### V1-/Phase-2E-Reduktion

Der erste technische Slice nutzt sichtbar nur Stein.

Holz und Wissen duerfen architektonisch vorbereitet sein, sollen aber noch nicht
dominant in der UI erscheinen. Glas, Metall, Licht/Energie, Bewohner,
Reparaturpunkte und Muenzen bleiben fuer spaetere Phasen.

Erstes Ziel:

- Bauplatz vorbereiten,
- Fundament beginnen,
- sichtbaren Baufortschritt zeigen.

Der Nutzer soll Baufortschritt sehen, nicht Ressourcenverwaltung. Die erste
Session braucht keine Tabellen-, Zahlen- oder Wallet-Last. Diese Reduktion
schuetzt UX, Balancing und Implementierungsscope.

## 15. Offene Fragen

Offene Fragen fuer Folgeplaene und Tests:

- Wie schnell soll das erste Haus entstehen?
- Wann kommt die zweite Insel?
- Wie viele Ressourcen sind in V1 wirklich noetig?
- Welche Ressource ist besonders Premium-gefaehrdet?
- Wie wird KI-Kostenkontrolle genau umgesetzt?
- Wie werden SRS und Reward Bridge spaeter sauber verbunden?
- Wie stark sollen Tagesziele Ressourcen beeinflussen?
- Wie werden Schwierigkeit und Ressourcenertrag fair gekoppelt?
- Welche Ressourcen duerfen in Community-Projekte fliessen?
- Wie werden Offline-Vormerkungen spaeter gegen Missbrauch abgesichert?

## 15a. Balancing-Testfragen

Diese Fragen sollen spaeter bei Konzepttests, Device-Tests und kleinen
technischen Slices beantwortet werden:

- Sieht der Nutzer nach 2 Minuten etwas?
- Versteht der Nutzer nach 5 Minuten den Zusammenhang Lernen -> Bauen?
- Ist nach 10-15 Minuten ein klares Bauziel erreichbar?
- Ist das erste Haus zu schnell oder zu langsam?
- Sind Ressourcen verstaendlich?
- Gibt es genug kleine Belohnungen?
- Kann der Nutzer ohne Lernen spielen, aber nicht stark vorankommen?
- Kann Premium Lernen umgehen? Falls ja, muss es geaendert werden.
- Entstehen KI-/Cloud-Kosten durch den Loop? Falls ja, sind Limits geplant?
- Wirkt das erste Fundament wie ein echter Fortschritt oder nur wie eine Zahl?
- Ist die UI in der ersten Session ruhig genug?

## 16. Akzeptanzkriterien

Dieses Dokument ist gut, wenn:

- Ressourcenphasen klar sind,
- erste Diskussionswerte vorhanden sind,
- Quellen/Senken beschrieben sind,
- Session-Balancing nachvollziehbar ist,
- Frustschutz und Ausnutzungsschutz benannt sind,
- Monetarisierung/Fairness beruecksichtigt ist,
- Community-Balancing als eigenes Problem erkannt ist,
- ein kleiner technischer Slice ableitbar ist,
- keine finale Reward Bridge oder Persistenz vorweggenommen wird.
