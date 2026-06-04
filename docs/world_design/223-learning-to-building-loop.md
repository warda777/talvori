# Talvori Welt: Learning-to-Building-Loop

Stand: 2026-06-04

Dieses Dokument konkretisiert den Kern von Talvori Welt:

> Lernen erzeugt sichtbaren Weltaufbau.

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
- `docs/222-talvori-world-game-system-master-plan.md`

Orientierung:

Erfolgreiche Aufbau-, Mobile-Retention-, Lern- und Social-Progressionssysteme
zeigen wiederkehrende Muster: kurze Aufgaben, klare Ziele, sichtbare
Zwischenbelohnungen, langfristige Projekte, Gruppenbeitraege und sichere
Rueckkehranlaesse. Talvori nutzt diese Muster nur als Orientierung. Talvori
kopiert keine Spiele. Talvori bleibt eine Lernwelt.

Orientierungsquellen fuer spaetere Detailrecherche:

- Supercell: [Clash of Clans Clan Games Rewards](https://support.supercell.com/clash-of-clans/en/articles/clan-games-rewards.html)
  als Orientierung fuer Aufgabenbeitraege und Reward-Tiers.
- Supercell: [Hay Day Derby Tasks](https://support.supercell.com/hay-day/en/articles/derby-tasks.html)
  als Orientierung fuer Aufgabenwahl, Timer und Nachbarschaftsbeitraege.
- Supercell: [Clash of Clans Clan Capital Rewards](https://ingame.support.supercell.com/clash-of-clans/en/articles/rewards-2.html)
  als Orientierung fuer gemeinsames Beitragen zu Community-Strukturen.
- Duolingo: [How streaks keep learners committed](https://blog.duolingo.com/how-streaks-keep-duolingo-learners-committed-to-their-language-goals/)
  als Orientierung fuer Gewohnheit, Rueckkehr und sanften Frustschutz.

## 1. Ziel Des Learning-to-Building-Loops

Lernen darf in Talvori nicht getrennt neben dem Spiel stehen. Der Nutzer soll
nicht erst in einem abstrakten Lernscreen arbeiten und spaeter irgendwo anders
einen Bonus sehen. Der staerkste Modus ist:

1. Der Nutzer sieht ein konkretes Weltziel.
2. Dieses Weltziel fragt eine passende Lernhandlung ab.
3. Die Lernhandlung erzeugt Ressource oder Bauenergie.
4. Die Welt veraendert sich sichtbar.

Der zentrale Nutzersatz nach kurzer Zeit soll sein:

> Ich habe gelernt, also veraendert sich meine Insel.

Das bedeutet:

- Ein Bauplatz ist nicht nur Deko, sondern ein Lernanlass.
- Ein Fundament ist nicht nur Grafik, sondern sichtbarer Wortfortschritt.
- Eine Bibliothek ist nicht nur ein Gebaeude, sondern ein Satz- und
  Wissensort.
- Eine Bruecke ist nicht nur ein Connector, sondern ein Phrasen- und
  Verbindungsziel.
- Comeback-Nebel ist kein Strafzustand, sondern eine private Einladung zur
  Wiederholung.

## 2. Hauptloop

Der konkrete Hauptloop:

1. Wort, Phrase oder Satz auswaehlen.
2. Lernaufgabe an einem Weltobjekt starten.
3. Aufgabe loesen.
4. Ressource erhalten.
5. Baufortschritt ausloesen.
6. Animation/Feedback zeigen.
7. Naechstes Bauziel sichtbar machen.
8. Companion reagiert.

Beispiel als kurzer Ablauf:

1. Nutzer tippt auf einen freien Bauplatz.
2. Talvori zeigt: `Fundament beginnen`.
3. Aufgabe: drei neue Woerter erkennen.
4. Nach Erfolg: kleine Menge Stein.
5. Stein fliegt zum Bauplatz.
6. Ein Fundament erscheint zu 20 Prozent.
7. Naechstes Ziel: `Noch 2 Wortaufgaben bis Fundament fertig`.
8. Tali/Vori kommentiert: `Das erste Fundament steht fast. Deine Woerter
   halten es zusammen.`

Der Loop muss klein genug fuer Alltagssessions sein und gleichzeitig
langfristige Ziele tragen.

## 3. Lernarten Und Ressourcentypen

Die Zuordnung ist Designrichtung, keine finale Reward Bridge.

| Lernart | Trainiert | Ressource | Weltwirkung | Passender Gebaeudetyp | Balancing-Gefahr |
| --- | --- | --- | --- | --- | --- |
| Wort erkennen | passives Erkennen, Bedeutung zuordnen | Stein | Fundament, Sockel, Bodenmarkierung | Haus, Markt, Bruecke | zu leicht, wenn es zu viel Stein gibt |
| Wort aktiv erinnern | aktive Abrufleistung | Holz | Waende, Zaun, Steg, Konstruktion | Haus, Werkstatt, Garten | darf nicht zu streng werden |
| Schreiben/Tippen | Praezision, Orthografie, aktive Produktion | Metall oder Wissen | Schilder, Mechanik, stabile Details | Werkstatt, Bibliothek, Turm | Tippfehlerfrust vermeiden |
| Satzverstaendnis | Kontext, Grammatik, Bedeutung | Glas/Wissen | Fenster, Regal, Wegtafel, Aussicht | Bibliothek, Schule, Markt | Saetze muessen zum Niveau passen |
| Phrase meistern | Chunking, fluessige Ausdrucksbausteine | Metall/Verbindung | Brueckenteile, Gelenke, Spezialteile | Bruecke, Hafen, Turm | Phrasen duerfen nicht wie Auswendigstrafe wirken |
| Dialog schaffen | Anwendung, Antwortlogik, soziale Sprache | Bewohner | NPC erscheint, Ort wird lebendig | Haus, Markt, Platz | KI/Content darf keine freien Rewards vergeben |
| Aussprache/Hoeren | Klang, Aussprache, Verstehen | Licht/Energie | Lampen, Kristalle, Aktivierung | Brunnen, Bibliothek, Companion-Ort | Audio muss optional/robust sein |
| Wiederholung/SRS | Langzeitgedaechtnis, Stabilisierung | Reparaturpunkte | Nebelrettung, Reparatur, Stabilitaet | private Overlays, alte Wege | SRS darf nicht beschaedigt oder umgedeutet werden |

Ressourcenlogik:

- Stein und Holz sind fruehe Bauressourcen.
- Glas, Metall und Wissen gehoeren zu praeziseren oder hoeheren Ausbaustufen.
- Licht/Energie macht Fortschritt emotional sichtbar.
- Bewohner sind kein Material, sondern Zeichen von Leben.
- Reparaturpunkte gehoeren zu Comeback und Wiederholung.

## 4. Aufgabenarten Im Spiel

### Bauplatz-Aufgabe

Lernziel:

- erste Woerter erkennen oder aktiv erinnern.

Spielerische Situation:

- Nutzer tippt auf freien Bauplatz.
- Der Bauplatz fragt nach Lernenergie fuer den ersten Schritt.

Moegliche Belohnung:

- Stein oder Holz.

Sichtbare Weltwirkung:

- Bauplatz leuchtet kurz,
- Erde wird geglaettet,
- erster Markierungsring oder kleine Baupfosten erscheinen.

Beispiel-User-Story:

> Als neuer Nutzer tippe ich auf meine freie Bauzone, loese drei einfache
> Wortaufgaben und sehe, wie der erste Bauplatz vorbereitet wird.

### Fundament-Aufgabe

Lernziel:

- Wort erkennen und Bedeutung sicher zuordnen.

Spielerische Situation:

- Ein geplantes Gebaeude braucht stabile Grundlage.

Moegliche Belohnung:

- Stein.

Sichtbare Weltwirkung:

- Fundamentplatten erscheinen,
- Risse werden geschlossen,
- Bauplatz wirkt stabiler.

Beispiel-User-Story:

> Ich wiederhole kurze Woerter und sehe danach, wie ein Hausfundament Stueck
> fuer Stueck sichtbar wird.

### Wand-/Struktur-Aufgabe

Lernziel:

- aktive Erinnerung, Schreiben oder Phrasen.

Spielerische Situation:

- Das Fundament steht. Jetzt braucht das Gebaeude Struktur.

Moegliche Belohnung:

- Holz, Metall oder Wissen.

Sichtbare Weltwirkung:

- Waende wachsen,
- Geruest entsteht,
- Schild oder Dachbalken erscheint.

Beispiel-User-Story:

> Ich rufe Woerter aktiv ab und sehe danach, wie die Waende meines Hauses
> wachsen.

### Bibliotheks-Aufgabe

Lernziel:

- Satzverstaendnis, Satzfunken, Schreiben.

Spielerische Situation:

- Die Bibliothek will ein neues Regal, Fenster oder Lesepult aktivieren.

Moegliche Belohnung:

- Wissen, Glas oder Licht.

Sichtbare Weltwirkung:

- Regal leuchtet,
- Fenster erscheint,
- Satzstein oder Buch pulsiert.

Beispiel-User-Story:

> Ich verstehe einen Beispielsatz und danach bekommt meine Bibliothek ein neues
> leuchtendes Fenster.

### Markt-Aufgabe

Lernziel:

- aktive Wortnutzung, kleine Phrasen, Kategorien.

Spielerische Situation:

- Marktstand braucht Waren, Schilder oder Besucher.

Moegliche Belohnung:

- Muenzen, Holz, Wissen oder Bewohner.

Sichtbare Weltwirkung:

- Kiste erscheint,
- Schild wird lesbarer,
- erster Besucher kommt vorbei.

Beispiel-User-Story:

> Ich uebe Woerter aus einer Kategorie und der Markt bekommt eine neue Kiste mit
> Waren.

### Bruecken-Aufgabe

Lernziel:

- Phrasen, stabile Ausdrucksbausteine, spaeter Dialog.

Spielerische Situation:

- Zwei Dockingpunkte koennen verbunden werden, aber die Bruecke braucht
  sprachliche Stabilitaet.

Moegliche Belohnung:

- Metall, Glas oder Verbindungsteile.

Sichtbare Weltwirkung:

- ein Connector-Segment erscheint,
- ein End-Cap rastet an,
- kleine Plattform wird sichtbar.

Beispiel-User-Story:

> Ich meistere eine Phrase und ein erstes kleines Verbindungsstueck zwischen
> zwei Inselpunkten entsteht.

### Nebelrettung

Lernziel:

- Wiederholung, SRS, Comeback.

Spielerische Situation:

- Ein privater Nebel liegt ueber einem Lernbereich oder alten Weg.

Moegliche Belohnung:

- Reparaturpunkte.

Sichtbare Weltwirkung:

- Nebel lichtet sich,
- Weg wird klar,
- Lichtpunkt stabilisiert den Bereich.

Beispiel-User-Story:

> Nach einer Pause starte ich eine leichte Wiederholung und sehe, wie privater
> Nebel auf meiner Insel weicht.

### Bewohner-Dialog

Lernziel:

- Anwendung in kurzer sozialer Situation.

Spielerische Situation:

- Ein Bewohner fragt etwas Einfaches oder reagiert auf ein Gebaeude.

Moegliche Belohnung:

- Bewohner-Fortschritt, Licht oder Wissen.

Sichtbare Weltwirkung:

- Bewohner winkt,
- kleiner NPC bleibt am Ort,
- Ort wirkt lebendiger.

Beispiel-User-Story:

> Ich beantworte eine kurze Dialogfrage und danach bleibt ein Bewohner vor dem
> Markt stehen.

### Companion-Vorschlag

Lernziel:

- naechste sinnvolle Aktion finden.

Spielerische Situation:

- Tali/Vori erkennt Inselzustand, Sessionlaenge und offene Bauziele.

Moegliche Belohnung:

- keine direkte Ressource durch den Vorschlag selbst,
- Ressource erst nach der Aufgabe.

Sichtbare Weltwirkung:

- Fokus auf Bauplatz, Bibliothek, Nebel oder Bruecke.

Beispiel-User-Story:

> Ich bin unsicher, was ich tun soll. Vori schlaegt eine kurze Aufgabe fuer das
> Hausfundament vor.

### Satzfunken-Aufgabe

Lernziel:

- KI-gestuetzter Satz im Kontext, Verstehen oder Produktion.

Spielerische Situation:

- Ein Satzfunken-Platz oder Bibliothekspunkt will einen Satz mit gesammelten
  Woertern aktivieren.

Moegliche Belohnung:

- Wissen oder Licht.

Sichtbare Weltwirkung:

- Satzstein erscheint,
- kleines magisches Objekt aktiviert sich,
- Bibliothek bekommt lebendigen Effekt.

Beispiel-User-Story:

> Ich nutze drei gesammelte Woerter in einem Satzfunken und sehe danach einen
> leuchtenden Satzstein in meiner Bibliothek.

## 5. Erste Session

Ziel der ersten 5 Minuten:

- Nutzer versteht Inselwahl.
- Nutzer versteht erstes Weltziel.
- Nutzer erledigt eine kurze Aufgabe.
- Nutzer sieht einen echten Weltfortschritt.

Moeglicher Ablauf:

1. Nutzer tippt auf den Globe.
2. Weltansicht oeffnet sich.
3. Showcase-Insel zeigt das spaetere Versprechen.
4. Nutzer waehlt eine freie Starter-Insel.
5. Tali/Vori sagt sinngemaess: `Das ist dein Anfang. Lass uns den ersten
   Bauplatz wecken.`
6. Nutzer tippt auf den ersten Bauplatz.
7. Aufgabe: 3 einfache Woerter erkennen.
8. Belohnung: kleine Menge Stein.
9. Sichtbare Wirkung: Bauplatz wird geglaettet, erste Fundamentmarkierung
   erscheint.
10. Tagesziel: `Beginne dein erstes Fundament`.

Angemessener Fortschritt:

- Ein erstes Fundament soll sehr frueh erreichbar wirken.
- In den ersten Minuten sollte nicht schon ein ganzes Haus fertig sein.
- Der sichtbare Fortschritt muss klar, aber klein sein.
- Der Nutzer soll die naechste Aufgabe verstehen, nicht mit Ressourcenlisten
  ueberfordert werden.

Moeglicher Companion-Kommentar:

- Tali: `Siehst du? Dein erstes Wort hat gerade Stein in deine Welt gebracht.`
- Vori: `Das Fundament merkt sich, was du gelernt hast. Noch ein kleiner Schritt
  und es steht.`

## 6. Fortschrittsgeschwindigkeit

Dies sind Diskussionswerte, keine finalen Zahlen.

| Umfang | Moegliche Wirkung |
| --- | --- |
| 1 Aufgabe | Mikrofortschritt, Funken, 5-20 Prozent an einem kleinen Teilziel |
| 3-5 Woerter | kleiner sichtbarer Baufortschritt, z. B. Bauplatz vorbereitet |
| 10-15 Minuten | spuerbares Bauziel, z. B. Fundament oder Wandabschnitt |
| 1 Tagesquest | sichtbarer Ausbauabschnitt mit Abschlussfeedback |
| 3-5 Tage | kleines Gebaeude sichtbar fortgeschritten oder fast fertig |
| Groessere Gebaeude | mehrtaegige oder woechentliche Ziele |

Richtung:

- Das erste Fundament kommt frueh.
- Ein kleines Gebaeude braucht mehrere kurze Sessions.
- Grosse Gebaeude brauchen Tage.
- Community-Projekte brauchen Wochen oder Saisons.
- Jede lange Struktur braucht sichtbare Zwischenstufen.

Warum:

- Zu schnelle Belohnung entwertet Bauziele.
- Zu langsame Belohnung laesst Lernen wie Arbeit wirken.
- Kleine Fortschritte nach kurzer Zeit halten den Loop lebendig.
- Grosse Ziele geben Grund zur Rueckkehr.

## 7. Ressourcenquellen Und Ressourcensenken

Quellen:

| Quelle | Rolle |
| --- | --- |
| Lernquests | Hauptquelle fuer persoenlichen Fortschritt |
| Tagesziele | Richtung und kleine Zusatzbelohnung |
| Wiederholung | Reparatur, Stabilisierung, Comeback |
| Satzfunken | Wissen, Licht, kreative Weltobjekte |
| Dialoge | Bewohner, Leben, soziale Anwendung |
| Community-Aufgaben | Beitrag zu gemeinsamen Projekten |

Senken:

| Senke | Rolle |
| --- | --- |
| Fundament | frueher sichtbarer Baufortschritt |
| Gebaeudeausbau | langfristige persoenliche Ziele |
| Wege | Inselstruktur, Orientierung |
| Deko | Besitzgefuehl, kosmetischer Ausdruck |
| Bruecken | Verbindung, Progression, Erweiterung |
| Reparatur | Comeback, private Nebelrettung |
| Community-Projekte | Social-Ziele, Wochen-/Saisonprojekte |

Regel:

Jede wichtige Ressource braucht sinnvolle Quellen und Sinks. Eine Ressource ohne
Sink fuehlt sich wertlos an. Eine Senke ohne verlaessliche Quelle fuehlt sich
frustrierend an.

## 8. Lernen Ohne Frust

Talvori soll Lernen ernst nehmen, aber nicht wie Strafarbeit wirken.

Schutzmechaniken:

- kurze Aufgaben,
- sichtbare Zwischenbelohnungen,
- keine harte Bestrafung,
- private Nebel statt oeffentliche Ruinen,
- Comeback-Quest nach Pause,
- Companion-Hilfe,
- leichte Aufgaben nach Pause,
- kleine Bauaktion auch bei wenig Zeit.

Comeback-Regel:

Wenn ein Nutzer zurueckkommt, soll Talvori nicht sagen: `Du bist gescheitert.`
Talvori soll sagen: `Hier ist ein kleiner sicherer Schritt zurueck in deine
Welt.`

SRS-Regel:

Wiederholung soll als Stabilisierung und Reparatur wirken. Bestehende
SRS-/`word_progress`-Semantik bleibt unangetastet.

## 9. Spielen Ohne Lernverlust

Es muss immer etwas Spielbares geben, auch wenn der Nutzer gerade keine volle
Lernsession machen will.

Ohne Lernpflicht moeglich:

- freie Welt ansehen,
- Bauziele planen,
- Deko ansehen,
- Freunde besuchen,
- Community-Projekte ansehen,
- Companion nach naechstem Schritt fragen,
- Inselstatus verstehen.

Aber:

- bedeutender Baufortschritt braucht Lernen,
- neue Bauphasen brauchen Ressourcen aus Lernhandlungen,
- Community-Beitraege brauchen echte Aufgaben,
- Premium darf Lernen nicht ersetzen.

So bleibt Talvori freundlich, aber der Kern bleibt ehrlich:

> Wer lernt, baut.

## 10. In-World-Learning UI

Keine konkrete Flutter-UI in diesem Dokument. Beschrieben wird nur die
Interaktionslogik.

Bauplatz:

- Nutzer tippt auf BuildZone.
- Kleine Karte oder Bottom Sheet zeigt `Naechster Schritt`.
- Aufgabe startet direkt aus dem Bauziel.
- Nach Erfolg wird die Bauzone sichtbar aktualisiert.

Bibliothek:

- Nutzer tippt auf Regal, Fenster, Satzstein oder Lesepult.
- Satzaufgabe oder Satzfunken erscheint.
- Nach Erfolg erscheinen Wissen, Licht oder Glaswirkung.

Bewohner-Dialog:

- NPC oder Bewohner fragt eine kurze kontextuelle Frage.
- Nutzer antwortet mit Auswahl, Eingabe oder kurzer Dialogaktion.
- Nach Erfolg reagiert der Bewohner und der Ort wird lebendiger.

Bruecke:

- Nutzer tippt auf Dockingpunkt oder Brueckenbaustelle.
- Phrasenaufgabe erklaert die Verbindung.
- Nach Erfolg erscheint ein kleines Segment oder ein vorbereitetes Bauteil.

Nebelrettung:

- Nutzer tippt auf privaten Nebelbereich.
- Wiederholungsaufgabe startet.
- Nach Erfolg lichtet sich der Nebel.

Companion:

- Companion schlaegt passende Weltaktion vor.
- Vorschlag selbst gibt keine Ressource.
- Ressource entsteht erst durch bestandene Aufgabe.

## 11. Animation Und Feedback Im Loop

Animationen muessen den Zusammenhang erklaeren, nicht nur schmuecken.

Moegliche Feedbacks:

- Ressource fliegt zum Bauplatz.
- Fundament erscheint.
- Wand waechst.
- Licht aktiviert sich.
- Nebel verschwindet.
- Bewohner reagiert.
- Companion kommentiert.
- Sound/Haptik optional spaeter.

Regeln:

- Feedback kurz halten.
- Animation ruhig und hochwertig.
- Keine hektische Belohnungsmaschine.
- Ressourcenflug darf nicht zur UI-Ueberladung werden.
- Bei Preview/weiter Kamera weniger Animation als in Detailansicht.

## 12. Risiken

Wichtige Risiken:

- zu viel Lernen wirkt wie Arbeit,
- zu viel Spiel verdraengt Lernen,
- Belohnungen sind zu schnell,
- Belohnungen sind zu langsam,
- Ressourcen werden zu kompliziert,
- KI-Kosten explodieren,
- SRS wird beschaedigt,
- Nutzer versteht den Zusammenhang nicht,
- Weltfortschritt wird untestbar,
- UI wird mit Aufgaben, Ressourcen und Hinweisen ueberladen.

Besonders kritisch:

Wenn der Nutzer nicht innerhalb der ersten Session versteht, dass Lernen direkt
Weltfortschritt erzeugt, verliert Talvori seinen Kern.

## 13. Schutzregeln

Technische und produktliche Schutzregeln:

- Bestehende SRS-/`word_progress`-Logik bleibt unangetastet.
- Reward Bridge kommt spaeter separat.
- Weltfortschritt wird deterministisch berechnet.
- KI darf Aufgaben, Saetze, Erklaerungen und Beispiele liefern.
- KI darf keine Ressourcen frei vergeben.
- Ressourcen muessen kontrollierbar und testbar bleiben.
- UI darf keine Supabase-RPC-Details kennen.
- Weltlogik darf nicht direkt im Renderer stecken.
- Lokale Mock-Ressourcen sind nur UI-Zustand, bis eine eigene Reward Bridge
  geplant und getestet ist.

Validierungsregel:

Eine Lernhandlung darf nur dann Weltfortschritt ausloesen, wenn sie von einer
kontrollierten Lern-/Reward-Schicht als gueltig bewertet wurde. In fruehen
Slices wird das lokal/mock simuliert.

## 14. Erster Technischer Slice Nach Diesem Dokument

Ein spaeterer kleiner Slice sollte bewusst klein bleiben.

Umfang:

- eine Insel,
- eine BuildZone,
- eine Beispielaufgabe,
- lokale Mock-Ressource,
- sichtbarer Baufortschritt,
- Companion-Kommentar als lokaler Text,
- keine Persistenz,
- keine Supabase Writes,
- keine echte Reward Bridge,
- keine SRS-Aenderung.

Moeglicher Ablauf:

1. Nutzer tippt auf eine vorbereitete `BuildZone`.
2. UI zeigt `Fundament beginnen`.
3. Nutzer loest eine lokale Mock-Wortaufgabe.
4. Lokaler Mock-State erhoeht `stone`.
5. BuildZone wechselt visuell von `leer` zu `Fundament begonnen`.
6. Eine kurze Animation oder visuelle Zustandsaenderung zeigt Fortschritt.
7. Companion-Kommentar bestaetigt das Prinzip.

Nicht Teil des ersten Slices:

- keine echten Ressourcen-Wallets,
- keine Cloud,
- keine Persistenz,
- keine Community-Projekte,
- keine Connectoren,
- keine automatische Platzierung,
- keine KI-Kosten verursachenden Aktionen,
- keine Aenderung an bestehenden Lern- oder SRS-Daten.

Akzeptanz fuer den Slice:

- Nutzer sieht den Zusammenhang zwischen Aufgabe und Bauplatz.
- Fortschritt ist sichtbar.
- Kein bestehender Lern-/SRS-Zustand wird veraendert.
- Die Architektur bleibt anschlussfaehig an BuildZones und spaetere Reward
  Bridge.

## 15. Akzeptanzkriterien

Dieses Dokument ist gut, wenn:

- klar ist, wie Lernen sichtbaren Aufbau erzeugt,
- konkrete Aufgabenarten beschrieben sind,
- Ressourcen sinnvoll an Lernarten gekoppelt sind,
- erste Balancing-Richtung vorhanden ist,
- Quellen und Senken benannt sind,
- Frustschutz und Spielspass beruecksichtigt sind,
- In-World-Learning als staerkster Modus erkennbar ist,
- klassische Lernscreens weiter moeglich bleiben,
- SRS-/`word_progress`-Schutz klar bleibt,
- ein kleiner technischer Slice ableitbar ist.

Offene Recherchepunkte:

- Wie viel sichtbarer Fortschritt pro kurzer Session langfristig motiviert,
  ohne Gebaeude zu schnell fertigzustellen.
- Wie stark Tagesziele lenken duerfen, bevor sie Druck erzeugen.
- Wie In-World-Learning und klassischer Lernscreen im Alltag zusammenspielen.
- Wie KI-Satzfunken begrenzt, gecacht und kostenkontrolliert werden.
- Wie Community-Beitraege fair aggregiert werden, ohne Social-Druck zu bauen.
