# M16-BD: Starter Island Identity, Biome and Category Scope Gate

Stand: 2026-06-09

Status: `Dokumentations-/Strategie-Slice / keine Implementierung`

## 1. Zweck

M16-BD konkretisiert nach M16-BA und M16-BB die Identitaet der ersten
Talvori-Starter-Insel. Bevor weitere Board-, BuildChoice-, Kategorie-, Bank-
oder Spielmoment-Code-Slices entstehen, muss klar sein, welche Welt diese erste
Insel eigentlich ist.

Dieses Gate definiert:

- Starter-Insel-Identitaet,
- Biome-/Landschaftscharakter,
- Kategorie-Scope fuer den MVP,
- Terrain-zu-Variante-Regeln,
- Start-/Erweiterungslogik,
- fixe Infrastruktur vs. spaetere Spielerfreiheit,
- Folgekonsequenzen fuer die aktuelle Starter-Island-Preview.

M16-BD ist grobe Welt-, Biome- und Kategorie-Strategie. Es ist kein finaler
Art Style, keine Assetfreigabe, kein Runtime-Modell und keine
Implementierungsfreigabe.

Nachtrag M16-BI:

`355-talvori-core-construction-learning-spine.md` definiert den fuehrenden
Bau-/Lern-Spine, der auf den Uferhain angewendet wird. M16-BD beschreibt also
die Starter-Insel-Identitaet; M16-BI beschreibt, wie Lernen dort Bau,
Ausbau, Raum-, Container- und Weltfortschritt spielerisch antreibt.

## 2. Non-Goals und Stop-Regeln

M16-BD erzeugt nicht:

- keine Implementierung,
- keine Flutter-/Dart-Codeaenderung,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine neue Seite,
- keine Tests,
- keine Widget-Tests,
- keine Screenshots als Repo-Artefakte,
- keine Persistenz,
- keine Supabase Writes,
- keine lokalen DB-Writes,
- keine SRS-/`word_progress`-Aenderung,
- keine automatische Wortplatzierung,
- kein Build-Wheel-Code,
- keine Assets,
- keine Asset-Dateien unter `assets/`,
- kein BuildState,
- kein `frame_started`,
- keine Bauzustaende,
- keine Economy-Implementierung,
- keine Muenzen-Implementierung,
- keine Produktivmechanik-Freigabe.

Jede Landschaft, jeder Slot, jede Kategorie und jede Variante in diesem
Dokument ist Fachplanung. Nichts davon erzeugt Placement, BuildState,
Persistenz, Asset oder App-Integration.

## 3. Gelesene Grundlagen

| Dokument | Beitrag fuer M16-BD |
| --- | --- |
| `351-starter-island-infrastructure-strategy-gate.md` | Fuehrende Ebenen: Base Terrain, Free Slots, Templates, Varianten, Unlocks und BuildChoice. |
| `352-starter-island-preview-vs-infrastructure-audit.md` | Audit der aktuellen Preview und Start-/Expansion-Slot-Abweichungen. |
| `350-interaction-pattern-decision-matrix.md` | UI- und Spielaufbau-Entscheidungen brauchen Pattern- und Research-Abgleich. |
| `328-talvori-learning-game-readiness-todo-checklist.md` | Fuehrendes M16-T-Dashboard und neue Infra-IDs. |
| `336-documentation-map-and-slice-reading-rules.md` | Pflichtlektuere- und Prompt-Regeln fuer kuenftige Slices. |
| `345-play-first-learning-experience-doctrine.md` | Play-First, Island-First und UI-Muster muessen den Weltmoment tragen. |
| `346-non-learning-game-patterns-for-play-first-talvori.md` | Non-Learning-Game-Patterns fuer Neugier, Flow, Discovery und Ownership. |
| `338-world-loop-plot-family-and-buildchoice-gate.md` | WorldCandidate, Plot Family und BuildChoice bleiben Candidates, kein Build. |
| `339-theme-island-resizing-and-remaining-world-rules-gate.md` | Capability, Resizing, TinyObject, Container und Asset-Gates. |
| `318-theme-island-plot-capacity-and-build-wheel-plan.md` | Thema -> Plotbedarf -> Groessenmix -> Slot-Auswahl -> spaeteres Gate. |
| `320-global-theme-island-plot-capacity-matrix.md` | Globale Kategorieprofile; Starter-Insel ist nur eine erste Familie, nicht alle Welt. |
| `272-plot-capability-derivation.md` | Plot-Capabilities sind Erlaubnisse, keine Pflichtbelegung. |
| `337-mobile-density-accessibility-and-depth-planning-gate.md` | Mobile-Dichte, Landmarken-vor-Kleinteilen und Overlay-Grenzen. |

## 4. Benchmark-/Research-Check nach M16-AX

Dieser Check nutzt die in M16-AX, M16-AL und M16-BA vorbereiteten
Benchmark-Prinzipien. Er ist kein neues Deep Research und keine Kopie
einzelner Spiele.

| Geprueftes Muster | Beobachtetes Prinzip | Talvori uebernimmt | Talvori verwirft |
| --- | --- | --- | --- |
| Starter-Zonen in Aufbau-/Base-Spielen | Ein erster Bereich gibt Orientierung, aber zeigt spaetere Erweiterungen. | klarer Hub, wenige Startslots, ruhige Erweiterungsslots. | Timer, Bauzwang, Pay-to-Win, War-/Clan-Druck. |
| Regionen/Biome in Mobile-/RPG-/Adventure-Games | Ein Biome macht Orte erinnerbar und erzeugt Erwartungen. | lesbare Landmarken: Wasser, Hain, Hub, Huegel, Rand. | Biome als harte Kategorieblockade oder Asset-Scope. |
| Hub-Welten mit Unlocks | Ein zentraler sicherer Ort fuehrt zu neuen Bereichen. | Start-Hub, Hauptweg, spaetere Bruecke/Zone als Neugier. | Pflichtpfade, FOMO, Countdown, Verlustdruck. |
| Karten mit starken Landmarks | Spieler orientieren sich ueber Formen, Wege, Wasser und Hoehen. | Wasserarm, Kuestenrand, Lichtung, Huegel und ruhige Randorte. | Labelwolke, Debugkarte, UI-Fenster als Hauptspielraum. |
| Crafting-/Inventar-/Showcase-Spiele | Kleine Wahl bleibt im Spielbild; groessere Auswahl braucht eigene Spielstation. | Kategorie-Wahl klein; BuildChoice spaeter als Showcase/Werkbank. | komplexes Crafting, Economy, Materialgrind im MVP. |

Entscheidung:

- Gewaehltes Muster: lesbare Starter-Biome-Karte mit Hub, Wasser-Landmarke,
  Hain, freien Slots und ruhigen Erweiterungsflaechen.
- Bewusst verworfen: komplette Sandbox-Terrainbearbeitung, reine Strand- oder
  reine Waldinsel, Stadtkarte mit zu vielen Systemen, feste Kategorieplaetze,
  Drag/Drop als Standardflow und Economy-/Timer-/Unlock-Druck.
- Vorbildlogik: erfolgreiche Spiele machen den ersten Raum schnell lesbar,
  geben wenige sichere erste Handlungen und lassen Zukunft sichtbar werden.
- Talvori-Filter: Die Insel muss Spielgefuehl und Neugier tragen, aber Lernen,
  Safety, Mobile-Dichte, Reversibility und Candidate-Grenzen bleiben fuehrend.

## 5. Starter-Insel-Identitaet: Optionen und Entscheidung

| Option | Staerken | Risiken fuer MVP | Entscheidung |
| --- | --- | --- | --- |
| Kuesteninsel | starke Wasser-Landmarke, Hafen-/Uferwoerter, klarer Rand. | kann zu sehr nach Hafen-/Bootssystem wirken. | nicht allein fuehrend |
| Waldinsel | ruhig, naturbezogen, gute Starter-Atmosphaere. | kann Wasser-/Bank-/Markt-/Alltagsmomente verengen. | nicht allein fuehrend |
| Berginsel | starke Hoehen und Aussicht. | kann schwer, abgeschieden oder spaeter nach Bergbau/Schnee wirken. | nach MVP |
| Wuesteninsel | markant und eigenstaendig. | falscher Starterton, wenig Alltag/Wasser, hoher Asset-/Biome-Scope. | blockiert fuer MVP |
| Stadt-/Dorfinsel | viele Alltags- und Marktmoeglichkeiten. | wirkt schnell wie City-Scope, Gebaeudeliste oder BuildState. | spaeter als Familie |
| Gemischte Kuestenhain-/Flussufer-Starterinsel | Wasser, Hain, Hub, Alltag, Natur, Wissen und Ruheorte zugleich. | braucht klare Grenzen, damit es nicht alles auf einmal wird. | MVP-Entscheidung |

MVP-Entscheidung:

```text
Die erste Starter-Insel ist eine Kuestenhain-/Flussufer-Starterinsel.
```

Charakter:

- Kueste,
- Flussarm / Wasserband,
- kleiner Hain,
- zentrale Lichtung / Hub,
- ruhige Bau-/Plot-Flaechen,
- leichte Hoehen,
- sichere Randbereiche,
- sichtbare Zukunft ohne Druck.

Nicht fuehrend:

- nicht reine Strandinsel,
- nicht reine Waldinsel,
- nicht Wuesteninsel,
- nicht Stadt-/Dorf-Komplettkarte,
- nicht Hafen-/Bootssystem,
- nicht Terrain-Sandbox.

## 6. Name / Arbeitstitel

Namenskandidaten:

| Kandidat | Lesart | Bewertung |
| --- | --- | --- |
| Uferhain | Wasser + Hain + Ruhe; kurz und freundlich. | beste MVP-Lesart |
| Kuestenhain | staerker Richtung Kueste und Natur. | gut, etwas generischer |
| Flusslicht-Insel | poetisch, betont Lichtung und Fluss. | schoen, aber laenger |
| Talvori-Hain | markennah, ruhig. | gut spaeter, vielleicht zu allgemein |
| Startufer | funktional, klarer Anfang. | gut fuer Debug/Preview, weniger atmosphaerisch |

Vorlaeufiger Arbeitstitel:

```text
Uferhain
```

Der Name ist kein finaler Markenname. Er ist ein Arbeitsname fuer
Dokumentation, Preview, Slot-Strategie und Prompt-Scope.

## 7. Landschaftscharakter

Der Uferhain besteht aus diesen Grundelementen:

| Element | MVP-Rolle | Regeln |
| --- | --- | --- |
| Kueste | aeusserer Rand, Weltform, Blick in spaetere Inselwelt. | fix im MVP, nicht frei bearbeitbar. |
| Fluss / Wasserarm | starke Landmarke, Bank-/Ufer-/Wasser-Kontexte. | fix im MVP; keine freie Flusskonstruktion. |
| Hain / Waldzone | ruhige Naturzone, Garten-/Ruhe-/Alltagsvarianten. | fix als Biome-Gefuehl, nicht als Baumobjekt-Masse. |
| Zentrale Lichtung / Hub | sicherer Startpunkt und Orientierung. | fix als Startlesart; keine Pflichtkategorie. |
| 1-2 Hauptwege | Orientierung zwischen Hub, Ufer und Hain. | teilweise fix; keine Pflichtpfade. |
| 2-3 Nebenwege | neugierige Verbindung zu Erweiterungsslots. | spaeter erweiterbar, kein Pfadbau im MVP. |
| Leichte Huegel / Hoehen | Ueberblick, Wissen/Archiv-/Aussicht-Varianten. | fixe Gelaende-Andeutung, kein Bergbau-Scope. |
| Ruhige Randbereiche | Spaeter/Ablage/Ruheort und Erweiterung. | sichtbar, aber nicht als sensitive Deko. |
| Bruecke | spaetere Verbindung / Unlock-Idee. | nach MVP eigenes Gate. |
| Hafenansatz | kleine Uferidee, kein Hafen-System. | nach MVP eigenes Gate. |
| Wasserfall / Aussichtspunkt | staerkerer Landmark-Ausbau. | nach MVP oder eigener Visual-/World-Gate. |

## 8. Was gehoert auf diese Insel?

| Bereich | Sichtbare Gelaendeidee | Passende Weltobjekt-Ideen spaeter | Lernwortfelder | Moegliche Spielmomente |
| --- | --- | --- | --- | --- |
| Wasser / Ufer | Flusskante, Uferplatz, Wasserweg. | Bank, Fluss, Steg-Idee, Boot spaeter, Hafen spaeter. | Wasser, Bewegung, Orte, Mehrdeutigkeit. | `Bank` Context Door, `schwimmen` ActionChallenge, Ufer-Archiv. |
| Zuhause / Alltag | ruhige freie Flaeche nahe Hub oder Hain. | Haus-Idee, Zimmer-Idee, Garage-Idee, Garten-Idee. | Alltag, Raum, Familie, Gegenstaende. | Meaning Puzzle, Container-Hunt, Choice Fork. |
| Natur | Hain, Lichtung, Baumgruppen als Landmarken. | Baum, Blume, Samen, Tier spaeter. | Natur, Farben, Wachstum, Beobachtung. | Tiny Mystery, Container/Garten-Fund, ContextCard. |
| Markt / Kueche | zentraler oder wasser-/hubnaher Slot. | Marktstand-Idee, Brot, Kochen, Kaufen. | Essen, Einkaufen, Handlungen. | Action Moment, kurze Wahl, Context Door. |
| Werkstatt | Rand-/Hain-/Wasser-nahe Flaeche. | Werkzeug, Reparieren, Bauen, Bootswerkstatt-Idee. | Verben, Tools, Ursache/Wirkung. | ActionChallenge, Container Findability. |
| Wissen / Archiv | Huegel, ruhige Lichtung oder Archiv-Ort. | Frage, Bedeutung, Karte, Buch, Schild. | Sense, Kontext, abstrakte Begriffe. | Archiv-Fund, ContextCard Challenge. |
| Spaeter / Ablage | ruhiger Randbereich oder geschuetzte Lichtung. | Angst, unklar, Polizei, sensible Begriffe parken. | Safety, Mehrdeutigkeit, Unsicherheit. | Spaeter, Hide, Ablage, ruhiger Companion-Hinweis. |

Alle Weltobjekt-Ideen sind spaeterer Scope. M16-BD erzeugt keine Assets,
keine Objekte und keine Bauzustaende.

## 9. Kategorien pro Starter-Insel

Starter-Kategorie-Templates:

| Kategorie | Warum sie zum Uferhain passt | Wortfelder | Terrain-Varianten | Blockiert |
| --- | --- | --- | --- | --- |
| Zuhause | Alltag braucht einen ruhigen Einstieg, darf aber kein Pflicht-Haus sein. | Haus, Zimmer, Tuer, Garage, Familie. | Zuhause am Ufer, Zuhause im Hain, Zuhause zentral. | gebautes Haus, Pflicht-Zuhause, Interior ohne Gate. |
| Garten | Hain und Wasser tragen Naturmomente. | Garten, Baum, Blume, Samen, Erde. | Ufergarten, Waldgarten, Huegelgarten. | Growth-Timer, Pflegepflicht, Pflanzen-Asset-Masse. |
| Markt | Hub und Wege erlauben Versorgung und Begegnung. | Brot, kaufen, verkaufen, Tasche, Kueche. | Markt zentral, Hafenmarkt-Idee, Waldstand. | Economy, Shop, Kaufdruck, Warenlisten. |
| Werkstatt | Rand- und Wassernaehe geben Machen/Reparieren-Raum. | Werkzeug, bauen, reparieren, Messer, Schluessel. | Aussenwerkstatt, Bootswerkstatt-Idee, Waldwerkbank. | Produktion, Crafting-System, Tool-Clutter. |
| Lager/Container | TinyObjects brauchen Depth statt Inselobjektwolke. | Tasche, Kiste, Schluessel, Stift, Werkzeug. | Tasche am Hub, Kiste am Ufer, Lager am Rand. | Inventar-Dump, TinyObject-Plot, Persistenz. |
| Wissen | Hoehen, Lichtung und Archiv-Ort tragen Bedeutung. | lernen, Frage, Bedeutung, Sprache, Karte. | Wissen am Huegel, Lernplatz zentral, Wasserwissen. | Schulpflicht, Testfenster, Textwand. |
| Archiv / Wortarchiv | Mehrdeutige und abstrakte Begriffe brauchen einen ruhigen, wiederauffindbaren Ort. | Bank, Freiheit, Kontext, Beispiel, Sinn. | Archiv-Lichtung, stilles Wortarchiv, Ufer-Schild. | Symbolzwang, permanente Lernkarte. |
| Spaeter / Ablage / Ruheort | Unsichere und sensitive Begriffe brauchen sichere Ausgaenge. | Angst, Polizei, Krankheit, unklar, spaeter. | Rueckzugsort am Rand, Spaeter-Lichtung. | sensitive Deko, Reward, Retention-Trigger. |
| Ufer/Wasser | Der Flussarm ist die starke Starter-Landmarke. | Fluss, Ufer, schwimmen, Bank, Boot spaeter. | Uferplatz, Wasserweg, kleiner Steg. | Bootssystem, Hafen-System, freie Wasserbearbeitung. |

Regeln:

- Kategorie ist Template.
- Kategorie ist mehrfach nutzbar.
- Kategorie erzeugt kein fertiges Gebaeude.
- Slot + Kategorie + Terrain erzeugt nur eine lokale Variante.
- Terrain darf beschreiben, aber nicht hart blockieren.
- BuildChoice, Asset, Persistenz und BuildState bleiben eigene Gates.

## 10. User-facing Naming

Interne Systembegriffe duerfen in Fachdocs, Code-IDs oder Gates weiter
praezise bleiben. Die sichtbare Nutzeroberflaeche soll aber keine internen
Systembegriffe als normale Kategorie zeigen.

| Interner Fachbegriff | Sichtbarer Nutzerbegriff | Warum |
| --- | --- | --- |
| Codex | Archiv / Wortarchiv | Verstaendlicher als Systembegriff und naeher am Sammel-/Wiederfinden-Gefuehl. |
| Safe / Later / Backlog | Spaeter / Ablage / Ruheort | Ruhiger, weniger technisch und weniger nach Fehler-Queue klingend. |
| BuildChoice | Auswahl / Bauidee / Vorschau | BuildChoice bleibt Fachbegriff; Nutzer sieht eine spielartige Auswahl. |
| Candidate | Vorschlag / lokale Vorschau | Candidate ist technisch; Nutzer soll Freiheit, nicht Statuslogik spueren. |

Regeln:

- Kategorie-Wheels zeigen Hauptkategorien mit Icon + Kurzname.
- Das erste Wheel zeigt keine internen Begriffe wie Codex, Safe oder Backlog.
- Sichtbare Texte bevorzugen Archiv, Wortarchiv, Spaeter, Ablage oder Ruheort.
- Fachbegriffe duerfen im Details-/Dev-Kontext kurz erklaert werden, aber nicht
  das Hauptspielbild dominieren.

## 11. BuildChoice-Hierarchie unter Hauptkategorien

Die erste Kategorieauswahl bleibt flach. Detaillierte Bauideen werden spaeter
als BuildChoice-/Showcase-Kandidaten unter passenden Hauptkategorien behandelt.
Sie gehoeren nicht alle in das erste Kategorie-Wheel.

| Hauptkategorie | Spaetere BuildChoice-/Showcase-Kandidaten |
| --- | --- |
| Zuhause | Haus, Zimmer, Garage, Vorhof, Terrasse |
| Garten | Gartenbereich, Teich, Pool, Outdoor-Sauna, Blumenbereich |
| Ufer/Wasser | Steg, Uferplatz, Wasserweg, kleiner Bootsort |
| Werkstatt | Werkbank, Garage-Werkstatt, Bootswerkstatt |
| Markt | Marktstand, Laden, Hafenmarkt-Idee |
| Lager | Kiste, Tasche, Schuppen, Vorratsplatz |
| Wissen | Lernort, Aussichtspunkt, Bibliothek-Idee |
| Archiv | Wortarchiv, Erinnerungsort, Bedeutungssammlung |
| Spaeter | Ablage, Rueckzugsort, unsichere Woerter |

Grenzen:

- Diese Unterideen sind BuildChoice-/Showcase-Kandidaten, keine Kategorien im
  ersten Wheel.
- Keine Implementierungsfreigabe.
- Kein BuildState.
- Keine Assets.
- Keine Persistenz.
- Keine produktive Auswahlseite ohne eigenes BuildChoice-/Showcase-Gate.

## 12. Kategorien ausserhalb des Starter-Scopes

| Kategorie / System | Warum nicht im MVP-Starter-Scope | Spaeterer Weg |
| --- | --- | --- |
| Arena / Competition | Wuerde Play-First in Vergleich, Rang oder Druck kippen. | nach MVP, Fairness-/Safety-/Privacy-Gate. |
| Hafen als vollstaendiges System | Wasser, Boote, Handel, Travel und Assets waeren zu viel Scope. | eigener Hafen-/Water-/Travel-Gate. |
| Labor | Technik, Safety, Prozesse und Asset-Scope zu komplex. | spaeter Werkstatt-/Technik-Gate. |
| Grosse Stadt | zu viele Systeme: Verkehr, Civic, Markt, Social, Navigation. | eigene Stadt-/Dorfinsel-Familie. |
| Wueste | starkes eigenes Biome, falscher Starterton. | Future Island Family. |
| Schnee / Bergbau | eigenes Terrain-, Resource- und Safety-Gefuehl. | Future Island Family. |
| Freie Fluss-/Terrain-Bearbeitung | wuerde Editor-, Persistenz- und Undo-Scope oeffnen. | nach MVP mit Terrain-Gate. |
| Social / PvP | Druck, Privacy, Safety und Moderation. | nach MVP, eigenes Social-/Competition-Gate. |
| Voller Crafting-/Economy-Loop | Materialgrind, Timer, Kaufdruck. | nach MVP, Werkbank-/Economy-Gate. |

## 13. Variantenlogik pro Terrain

Varianten sind lokale Namen oder Preview-Lesarten. Sie sind keine Assets, kein
Build, kein Placement und keine Persistenz.

| Terrain + Kategorie | Variantenname / Idee | Lern- und Spielnutzen | Blockiert |
| --- | --- | --- | --- |
| Ufer + Zuhause | Kuestenhaus / Hausboot-Idee | Alltag + Wassernaehe, Kontext fuer Raum- und Uferwoerter. | gebautes Haus, Hausboot-System. |
| Ufer + Markt | Hafenmarkt / Fischmarkt-Idee | Versorgung + Wasserkontext. | Commerce, Hafen-System. |
| Ufer + Werkstatt | Bootswerkstatt-Idee | Tool-/Action-Verben mit Wassernaehe. | Bootsbau, Crafting-Loop. |
| Ufer + Garten | Ufergarten | Natur + Wasser, ruhige Beobachtung. | Growth-/Timerlogik. |
| Wald + Zuhause | Waldhaus | ruhiges Zuhause, Alltag im Hain. | Pflicht-Hausstart. |
| Wald + Garten | Waldgarten | Naturworte, Pflanzen und kleine Funde. | Deko-/Objektwolke. |
| Wald + Spaeter | Rueckzugslichtung | sichere Ausgaenge und sensitive Fallbacks. | sensitive Deko. |
| Huegel + Wissen | Aussichtspunkt / Bibliothek / Turm-Idee | Ueberblick, Bedeutung, Archiv. | Turm-Asset, Lerngebaeude als Pflicht. |
| Huegel + Archiv | stiller Archiv-Ort | Bedeutung und Kontext auffindbar. | Textwand als Hauptspielraum. |
| Zentrum + Markt | Dorfmarkt | einfache Begegnung und Versorgung. | Economy, Shop. |
| Zentrum + Lager | Hub-Tasche / Kistenpunkt | TinyObjects auffindbar machen. | Inventar-Dump. |
| Rand + Spaeter | Rueckzugsort | Spaeter/Ablage/Hide ohne Druck. | Retention-Trigger. |
| Rand + Werkstatt | Aussenwerkstatt | Machen am Rand, weniger Clutter im Hub. | Produktionssystem. |

Formel:

```text
freier Slot + Kategorie-Template + Terrain-Charakter
= lokaler Variantenname
= Candidate / Preview
!= Build / Placement / Persistenz / Asset
```

## 14. Slot-Positionierungslogik

Slot-Positionierung ist Gelaendelogik, keine harte Kategorie-Vorgabe.

| Slot-Typ | Empfohlene Lage | Zweck | Kategorie-Regel |
| --- | --- | --- | --- |
| Startslot 1 | nahe Hub / zentrale Lichtung | erster kreativer Anker. | jede Starter-Kategorie waehlbar. |
| Startslot 2 | am Wasser / Uferplatz | starker Context-Door-Ort. | jede Starter-Kategorie waehlbar, Wasser-Variante moeglich. |
| Startslot 3 | Hain / Waldlichtung | ruhige Natur-/Alltagsvariante. | jede Starter-Kategorie waehlbar, Hain-Variante moeglich. |
| Startslot 4 | Weg- oder Hub-nahe Flaeche | Markt/Wissen/Lager sichtbar, aber nicht erzwungen. | jede Starter-Kategorie waehlbar. |
| Optional Startslot 5-6 | Rand/Huegel oder Wassernaehe | mehr kreative Wahl ohne Ueberforderung. | jede Starter-Kategorie waehlbar. |
| Erweiterungsslot 1-2 | jenseits Nebenweg oder Brueckenidee | Zukunft sichtbar machen. | noch nicht waehlbar im MVP-Start. |
| Erweiterungsslot 3-4 | Rand/Huegel/Hain | ruhige Progression. | Unlock nur fachlich. |
| Erweiterungsslot 5-6 | Wasser- oder Kuesterweiterung | spaeter Hafen/Wasser/Travel andeuten. | kein Hafen-System im MVP. |

Regeln:

- Wassernahe Slots erzeugen Wasser-Varianten.
- Hubnahe Slots erzeugen zentrale Varianten.
- Wald-/Hain-Slots erzeugen Natur-/Ruhevarianten.
- Huegel-Slots erzeugen Ueberblicks-/Wissensvarianten.
- Rand-Slots erzeugen ruhige, geschuetzte oder expansive Varianten.
- Keine Lage sagt: "Hier muss Markt hin."
- Keine Lage blockiert eine freigegebene Starter-Kategorie hart.

## 15. Fixe Infrastruktur vs. spaetere Spielerfreiheit

| Ebene | MVP fix | MVP frei | Nach MVP / Gate |
| --- | --- | --- | --- |
| Kueste | Inselrand und Kuestenlesart. | keine freie Kuestenbearbeitung. | neue Kueste/Inselzonen. |
| Fluss / Wasserarm | starke Landmarke und Uferkontext. | Kategorie am Wasser waehlbar. | Bruecken, Wasserfall, Hafenansatz. |
| Hauptwege | Hub, Ufer, Hain und Erweiterung grob verbinden. | keine freie Wegbearbeitung. | neue Wege/Pfadbau-Gate. |
| Hub / Lichtung | sicherer Startort. | Kategorie nahe Hub waehlbar. | Hub-Ausbau nach Gate. |
| Landmarken | Wasser, Hain, Huegel, Rand. | dienen nur Orientierung. | groessere Landmarken/Assets nach Gate. |
| Sichtbare Slots | 8-12 freie/ruhige Flaechen. | 4-6 Startslots waehlbar. | 4-6 Erweiterungsslots freischaltbar. |
| Kategorien | Starter-Templates im Scope. | Kategorie pro Startslot frei waehlen. | neue Templates nach Gate. |
| Varianten | Name/Preview aus Terrain + Kategorie. | Change, Cancel, Spaeter. | BuildChoice/Showcase nach Gate. |
| Terrainmodifikation | blockiert. | keine freie Bearbeitung. | eigenes Terrain-/Undo-/Persistenz-Gate. |

## 16. Unlock-/Muenzen-Strategie nur fachlich

M16-BD bestaetigt die M16-BA-Regeln:

- Erweiterungsslots koennen spaeter freigeschaltet werden.
- Muenzen koennen spaeter freie Slots, Bruecken oder neue Inselzonen
  freischalten.
- Keine Muenzen-Implementierung in diesem Gate.
- Keine Economy-Implementierung.
- Kein Timer.
- Kein Pay-to-Win.
- Kein Lernen kaufen.
- Kein Druck.
- Kein FOMO.
- Kein Social-/Competition-Vorteil.
- Kein Weltverfall.

Sichere Lesart fuer den MVP:

```text
Erweiterung ist sichtbar als Zukunft.
Sie fordert jetzt nichts und verkauft nichts.
```

## 17. Future Island Families

| Inseltyp | Charakter | Moegliche Wortfelder | Moegliche Kategorien | Warum nicht MVP |
| --- | --- | --- | --- | --- |
| Wuesteninsel | trocken, weit, Oasen, Ruinen-Idee. | Hitze, Sand, Reise, Orientierung. | Reise, Spaeter, Wissen, Natur spaeter. | falscher Starterton, eigenes Asset-/Biome-Scope. |
| Berg-/Schneeinsel | Hoehe, Kaelte, Aussicht, schwierige Wege. | Schnee, Berg, klettern, Schutz. | Wissen, Werkstatt, Spaeter, Natur. | Terrain-/Safety-/Path-Scope. |
| Hafen-/Meerinsel | Hafen, Pier, Boote, Handel, Kueste. | Boot, Hafen, Fisch, Reise, Wasser. | Ufer, Markt, Werkstatt, Lager. | Wasser-/Travel-/Commerce-System zu frueh. |
| Wald-/Naturinsel | dichter Hain, Tiere, Pfade, Pflanzen. | Baum, Tier, Blatt, laufen, suchen. | Garten, Spaeter, Container, Wissen. | Clutter-/Tier-/Nature-Scope braucht Gate. |
| Stadt-/Dorfinsel | Platz, Strassen, Services, mehrere Gebaeude. | kaufen, arbeiten, Schule, Verwaltung. | Markt, Zuhause, Civic, Wissen. | zu viele Systeme und Gebaeudeerwartungen. |
| Wissens-/Archiv-Insel | Archiv, Turm, Raeume, Bedeutung. | Sinn, Frage, Beispiel, erinnern. | Archiv, Wissen, Spaeter, Container. | kann zu Lernformular wirken, braucht Play-First-Gate. |
| Werkstatt-/Technikinsel | Bauen, Reparieren, Geraete, Werkbank. | Werkzeug, reparieren, Maschine, digital. | Werkstatt, Lager, Wissen, Technik. | Crafting-/Production-/Asset-Scope. |

Roadmap-Regel:

Future Island Families duerfen Inspiration geben, aber keine Starter-Insel
ueberladen. Neue Inseltypen brauchen eigene Gates.

## 18. Konsequenz fuer die aktuelle Starter-Island-Preview

Die aktuelle Preview muss sich fachlich an `Uferhain` ausrichten.

Pruefpunkte fuer einen spaeteren Code-Slice:

| Bereich | Konsequenz |
| --- | --- |
| Grundform | zusammenhaengende Insel mit Kueste, Flussarm, Hain, Hub und Hoehen sichtbar halten. |
| Slotzahl | M16-BA-Ziel behalten: 8-12 sichtbar, 4-6 Start, 4-6 Erweiterung. |
| Slotlabels | keine Kategorie-Vorgaben zeigen; IDs und neutrale Terrainnamen reichen. |
| Terrainnamen | Uferplatz, zentrale Lichtung, Waldlichtung, Huegelplatz, ruhiger Rand. |
| Kategorieauswahl | Starter-Templates frei waehlen, keine harte Terrain-Filterung. |
| Varianten | Auswahl soll z. B. `Markt am Ufer` oder `Zuhause im Hain` als lokalen Candidate zeigen. |
| Erweiterungsslots | ruhig sichtbar, kein Wheel, kein Muenzen-Dialog. |
| Bank-Spielmoment | bleibt nur ein Ufer-/Flussufer-Beispiel, nicht der Hauptzweck des Boards. |
| UI-Dichte | Insel bleibt Hauptflaeche; HUD/Picker erklaeren nur. |

Empfohlene Folge-Code-Anpassung, falls noetig:

- erlaubte Datei: `lib/features/world/local_world/ui/widgets/starter_island_plot_board_preview.dart`,
- Ziel: sichtbare Terrain-/Slot-Sprache auf `Uferhain` ausrichten,
- keine neuen Dateien,
- keine Route,
- keine App-Integration,
- keine Persistenz,
- keine Assets,
- kein BuildState,
- kein `frame_started`.

Dieser Folge-Code ist durch M16-BD nicht freigegeben. Er braucht einen eigenen
Implementierungs-Prompt.

## 19. M16-T-ID-Entscheidung

| ID | Status | Entscheidung |
| --- | --- | --- |
| `M16T-INFRA-007` | `[x]` | Starter Island Identity / Biome ist als Uferhain-/Kuestenhain-/Flussufer-Starterinsel entschieden. |
| `M16T-INFRA-008` | `[x]` | Starter Island Category Scope ist mit 9 MVP-Templates und blockierten Nicht-MVP-Kategorien definiert. |
| `M16T-INFRA-009` | `[x]` | Terrain-to-Variant Mapping ist als lokale Variantenlogik ohne Build/Placement/Persistenz dokumentiert. |
| `M16T-INFRA-010` | `[x]` | Future Island Family Roadmap ist fachlich vorbereitet und vom MVP abgegrenzt. |
| `M16T-INFRA-011` | `[x]` | Player-editable Terrain Boundary ist geklaert: MVP fixiert Grundterrain, Spieler waehlen Kategorien/Varianten. |
| `M16T-INFRA-012` | `[x]` | User-facing category naming and BuildChoice hierarchy trennt interne Begriffe von sichtbaren Kategorien und ordnet Unterideen dem spaeteren Showcase-/BuildChoice-Schritt zu. |

## 20. Prompt-Regel fuer kuenftige Slices

Kuenftige World-/Island-/Plot-/UI-/BuildChoice-/Implementierungs-Slices
muessen M16-BD lesen, wenn Starter-Insel, Biome, Kategorie-Scope,
Terrain-Variante oder Insel-Identitaet betroffen sind.

Jeder solche Prompt muss beantworten:

- Welche Inselidentitaet gilt?
- Ist der Slice noch im Uferhain-MVP oder betrifft er eine Future Island
  Family?
- Welche Kategorie-Templates sind im Scope?
- Welche Kategorie ist bewusst nicht im Scope?
- Welche Terrain-Variante wird erzeugt?
- Ist das fixe Infrastruktur, freier Slot, Kategorie-Template, Variante,
  Unlock, BuildChoice oder Future Island?
- Wird Terrain veraendert oder nur ein Slot genutzt?
- Ist die Entscheidung MVP, nach MVP oder blockiert?
- Welche Interaction-Pattern-Entscheidung aus `350` passt?
- Welche Safe Defaults bleiben sichtbar: Cancel, Change, Spaeter, Archiv,
  Ablage oder ContextCard?

## 21. Entscheidung

M16-BD entscheidet:

```text
Starter-Insel = Uferhain
Biome = Kuestenhain / Flussufer / ruhiger Hain mit Hub
Scope = 9 wiederverwendbare Starter-Kategorie-Templates
Varianten = Terrain beschreibt, blockiert aber nicht hart
Build = blockiert
Persistenz = blockiert
Assets = blockiert
Economy = blockiert
```

Damit hat die erste Starter-Insel eine klare Identitaet, ohne die kreative
Freiheit des Nutzers zu verlieren: Die Welt gibt Orientierung, der Spieler
waehlt auf freien Slots, und jede Kategorie bleibt ein lokaler Candidate bis
eigene Gates BuildChoice, Persistenz, Assets und Produktintegration erlauben.
